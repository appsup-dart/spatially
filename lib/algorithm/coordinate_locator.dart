//This file is part of Spatially.
//
//    Spatially is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Spatially is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with Spatially.  If not, see <http://www.gnu.org/licenses/>.


library algorithm.coordinate_locator;

import 'package:spatially/geom/base.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'cg_algorithms.dart' as cg_algorithms;
import 'lb_rule.dart' as lb_rule;

/**
 * Utility function to test a [Coordinate] for intersection with a [Geometry]
 */
bool intersects(Coordinate p, Geometry geom) {
  return locateCoordinateIn(p, geom) != loc.EXTERIOR;
}

/**
 * Computes the topological [Location] of a single [Coordinate] relative to a [Geometry].
 * A [VertexInBoundaryRule] may be specified to control evaluation of whether
 * the point lies on the boundary or not.
 *
 * The default rule is the *SFS Boundary Determination Rule*
 *
 * NOTE:
 * -- [LinearRing]s do not enclose any area -- points inside the
 * ring are still int the EXTERIOR of the ring.
 */
int locateCoordinateIn(Coordinate c, Geometry geom,
                       [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) {
  if (geom.isEmptyGeometry) {
    return loc.EXTERIOR;
  }
  if (geom is Point) {
    return _locateCoordinateInPoint(c, geom);
  } else if (geom is Linestring) {
    return _locateCoordinateInLinestring(c, geom);
  } else if (geom is Polygon) {
    return _locateCoordinateInPolygon(c, geom);
  } else {
    GeometryList geomList = geom as GeometryList;
    bool isIn = false;
    int boundaryCount = 0;
    for (var g in geomList) {
      int componentLocation = locateCoordinateIn(c, g);
      if (componentLocation == loc.INTERIOR) isIn = true;
      if (componentLocation == loc.BOUNDARY) boundaryCount++;
    }

    if (boundaryRule(boundaryCount))
      return loc.BOUNDARY;
    if (boundaryCount > 0 || isIn) {
      return loc.INTERIOR;
    }
    return loc.EXTERIOR;
  }
}

int _locateCoordinateInPoint(Coordinate c, Point p) =>
    (p.coordinate == c) ? loc.INTERIOR : loc.EXTERIOR;

int _locateCoordinateInLinestring(Coordinate c, Linestring geom) {
  if (geom.envelope.disjointCoordinate(c)) {
    return loc.EXTERIOR;
  }
  var coords = geom.coordinates;
  if (!geom.isClosed) {
    if (c == coords.first || c == coords.last) {
      return loc.BOUNDARY;
    }
  }
  if (cg_algorithms.isOnLine(c, geom.segments)) {
    return loc.INTERIOR;
  }
  return loc.EXTERIOR;
}

int _locateInPolygonRing(Coordinate c, Ring ring) {
  if (ring.envelope.disjointCoordinate(c)) {
    return loc.EXTERIOR;
  }
  return cg_algorithms.locateCoordinateInRing(c, ring.coordinates);
}

int _locateCoordinateInPolygon(Coordinate c, Polygon poly) {
  if (poly.isEmptyGeometry) return loc.EXTERIOR;

  var shellLocation = _locateInPolygonRing(c, poly.exteriorRing);
  if (shellLocation == loc.EXTERIOR) return loc.EXTERIOR;
  if (shellLocation == loc.BOUNDARY) return loc.BOUNDARY;

  //The coordinate lies on the interior of the shell.
  //Does it lie on the boundary or interior of one of the holes?
  for (var hole in poly.interiorRings) {
    var holeLocation = _locateInPolygonRing(c, hole);
    if (holeLocation == loc.INTERIOR) return loc.EXTERIOR;
    if (holeLocation == loc.BOUNDARY) return loc.BOUNDARY;
  }
  return loc.INTERIOR;
}