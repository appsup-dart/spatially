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


library algorithms.interior_point;

import 'package:quiver/iterables.dart';

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/envelope.dart';
import 'package:spatially/geom/base.dart';


/**
 * Computes a point in the interior of a [Geometry] with dimension `0`,
 * closest to the centroid of the geometry.
 *
 * If the [Geometry] is a [GeometryList], only components with dimension `0`
 * will be tested as interior points.
 *
 * Throws a [StateError] if the geometry is degenerate.
 */
Coordinate interiorPointPoint(Geometry geom) {
  Coordinate centroid = geom.centroid.coordinate;
  Coordinate interiorPoint = null;
  double minDistance = double.INFINITY;
  void addCoordinate(Coordinate c) {
    final dist = c.distance(centroid);
    if (dist < minDistance) {
      interiorPoint = c;
      minDistance = dist;
    }
  }
  void add(Geometry geom) {
    if (geom is Point) {
      addCoordinate(geom.coordinate);
    } else if (geom is GeometryList) {
      geom.forEach(add);
    }
  }
  add(geom);
  if (interiorPoint == null)
    throw new StateError("Interior point of degenerate geometry");
  return interiorPoint;
}

/**
 * Finds a vertex in the interior of the geometry of dimension `1` which is
 * closest to the centroid of the geometry. If there is no interior vertex
 * of the geometry, finds an endpoint which is closest to the centroid.
 *
 * If the [Geometry] is a [GeometryList], only components with dimension `1`
 * will be tested for interior points.
 *
 * Throws a [StateError] if the geometry is degenerate.
 */
Coordinate interiorPointLine(Geometry geom) {
  Coordinate centroid = geom.centroid.coordinate;
  double minDistance = double.INFINITY;
  Coordinate interiorPoint = null;

  if (geom.isDegenerate) {
    throw new StateError("Interior point of degenerate geometry");
  }

  void addCoordinate(Coordinate c) {
    final dist = centroid.distance(c);
    if (dist < minDistance) {
      minDistance = dist;
      interiorPoint = c;
    }
  }
  void addCoordsAt(Iterable<num> indexes, List<Coordinate> coords) =>
      indexes.forEach((i) => addCoordinate(coords[i]));

  void addEndpoints(Geometry geom) {
    if (geom is Linestring) {
      var endpointIndicies = [1, geom.length - 1];
      addCoordsAt(endpointIndicies, geom.coordinates);
    } else if (geom is GeometryList) {
      geom.forEach(addEndpoints);
    }
  }

  void addInterior(Geometry geom) {
    if (geom is Linestring) {
      var interiorIndicies = range(1, geom.length - 1);
      addCoordsAt(interiorIndicies, geom.coordinates);
    } else if (geom is GeometryList) {
      geom.forEach(addInterior);
    }
  }
  addInterior(geom);
  if (interiorPoint == null)
    addEndpoints(geom);
  return interiorPoint;
}
/**
 * Computes a pont in the interior of an [Geometry] with dimension `2`.
 * Finds all intersections of the geometry with the bisector of the [Geometry]s
 * envelope and returns the midpoint of the largest intersection.
 *
 * If the [Geometry] is a [GeometryList], only components with dimension `2`
 * will be tested for interior points.
 *
 * NOTE: If a fixed precision model is used, this method may return a point which
 * does not lie in the interior
 */
Coordinate interiorPointArea(Geometry geom) {
  GeometryFactory factory = geom.factory;
  Coordinate interiorPoint = null;
  double maxWidth = 0.0;
  double avg(double d1, double d2) => (d1 + d2) / 2;

  Linestring horizontalBisector(Geometry geom) {
    Envelope envelope = geom.envelope;
    var avgy = avg(envelope.miny, envelope.maxy);
    return factory.createLinestring(
        [ new Coordinate(envelope.minx, avgy),
          new Coordinate(envelope.maxx, avgy)
        ]);
  }

  /**
   * If [:geom:] is a [GeometryList], returns the widest component
   * otherwise, returns geom.
   */
  Geometry widestGeometry(Geometry geom) {
    if (geom is GeometryList && !geom.isEmpty) {
      return geom.fold(geom[0],
          (widest, g) => (g.envelope.width > widest.envelope.width) ? g : widest);
    }
    return geom;
  }

  /**
   * Find a reasonable point to label a [Geometry]
   */
  void addPolygon(Polygon polygon) {
    var bisector = horizontalBisector(polygon);
    var intersections = bisector.intersection(polygon);
    var widestIntersection = widestGeometry(intersections);

    double width = widestIntersection.envelope.width;
    if (interiorPoint == null || width > maxWidth) {
      interiorPoint = widestIntersection.envelope.centre;
      maxWidth = width;
    }
  }

  void add(Geometry geom) {
    if (geom is Polygon) {
      addPolygon(geom);
    } else if (geom is GeometryList) {
      geom.forEach(add);
    }
  }
  add(geom);

  return interiorPoint;
}

