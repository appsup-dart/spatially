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


library geom.base;

import 'dart:math' as math;
import 'dart:collection';

import 'package:quiver/iterables.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';
import 'package:spatially/algorithm/lb_rule.dart'
          as lb_rule;
import 'package:spatially/algorithm/cg_algorithms.dart'
          as cg_algorithms;
import 'package:spatially/algorithm/centroid.dart'
          as cent;
import 'package:spatially/algorithm/interior_point.dart'
          as interior;
import 'package:spatially/operation/boundary.dart' as bnd;
import 'package:spatially/convert/wkt.dart' as wkt;


import '../base/envelope.dart';
import 'precision_model.dart';
import 'intersection_matrix.dart';

import 'dimension.dart' as dim;
import '../algorithm/coordinate_arrays.dart';
import '../operation/overlay.dart';

part 'src/base/factory.dart';
part 'src/base/point.dart';
part 'src/base/linestring.dart';
part 'src/base/ring.dart';
part 'src/base/polygon.dart';
part 'src/base/geometry_list.dart';
part 'src/base/multipoint.dart';
part 'src/base/multilinestring.dart';
part 'src/base/multipolygon.dart';



abstract class Geometry implements Comparable<Geometry>{


  /**
   * Dynamically dispatches the implementation to the geometry type.
   * * If [geom] is a [Point], then applyPoint is called on [geom].
   * * If [geom] is a [Linestring], then applyLinestring is called on [geom]
   * * If [geom] is a [Polygon], then applyPolygon is called on [geom].
   * * If [geom] is a [GeometryList] (or a subtype of [GeometryList]), then
   *   the dispatch is called on all component geometries on [geom] and the
   *   results are collected in a [List].
   */
  static dynamic dispatchToType(
      Geometry geom,
      { dynamic applyPoint(Point p),
        dynamic applyLinestring(Linestring lstr),
        dynamic applyPolygon(Polygon poly),
        dynamic applyMultiPoint(MultiPoint mpoint),
        dynamic applyMultiLinestring(MultiLinestring mlstr),
        dynamic applyMultiPolygon(MultiPolygon mpoly),
        dynamic applyGeometryList(GeometryList geomList)
      }) {
    if (applyGeometryList == null) {
      _applyGeometryList(GeometryList geomList) {
        List li = new List();
        for (var geom in geomList) {
          li.add(dispatchToType(geom, applyPoint: applyPoint,
                                      applyLinestring: applyLinestring,
                                      applyPolygon: applyPolygon,
                                      applyMultiPoint: applyMultiPoint,
                                      applyMultiLinestring: applyMultiLinestring,
                                      applyMultiPolygon: applyMultiPolygon));
        }
        return li;
      }
      applyGeometryList = _applyGeometryList;
    }
    if (geom is Point) {
      if (applyPoint == null) {
        throw new ArgumentError("applyPoint cannot be null");
      }
      return applyPoint(geom);
    } else if (geom is Linestring) {
      if (applyLinestring == null) {
        throw new ArgumentError("applyLinestring cannot be null");
      }
      return applyLinestring(geom);
    } else if (geom is Polygon) {
      if (applyPolygon == null) {
        throw new ArgumentError("applyPolygon cannot be null");
      }
      return applyPolygon(geom);
    } else if (geom is MultiPoint) {
      if (applyMultiPoint == null) {
        return applyGeometryList(geom);
      }
      return applyMultiPoint(geom);
    } else if (geom is MultiLinestring) {
      if (applyMultiLinestring == null) {
        return applyGeometryList(geom);
      }
      return applyMultiLinestring(geom);
    } else if (geom is MultiPolygon) {
      if (applyMultiPolygon == null) {
        return applyGeometryList(geom);
      }
      return applyMultiPolygon(geom);
    } else if (geom is GeometryList) {
      return applyGeometryList(geom);
    } else {
      throw new ArgumentError("Not a recognised geometry type: ${geom.runtimeType}");
    }
  }


  /**
   * The supported subclasses of [Geometry]
   * in the order they are sorted when comparing
   * [Geometry]s
   * --[Point] (lowest)
   * -- [MultiPoint]
   * -- [Linestring]
   * -- [Ring]
   * -- [MultiLinestring]
   * -- [Polygon]
   * -- [MultiPolygon]
   * -- [GeometryList] (highest)
   */
  static const List<Type> types =
      const [ Point,
              MultiPoint,
              Linestring,
              Ring,
              MultiLinestring,
              Polygon,
              MultiPolygon];

  /**
   * The bounding box of `this`.
   */
  Envelope _envelope;

  /**
   * The [GeometryFactory] which was used to create this [Geometry]
   */
  final GeometryFactory factory;

  /**
   * A [Map] containing ancilliary data which can be used to store
   * data associated with the [Geometry].
   *
   * The semantics of this data is defined by the application using the [Geometry]
   */
  final Map<String,dynamic> userData;

  /**
   * Create a new geometry from the given [GeometryFactory]
   */
  Geometry._(GeometryFactory this.factory)
      : userData = new Map<String,dynamic>(),
        _envelope = null;

  /**
   * The ID of the spatial reference system used by the [Geometry]
   */
  int get srid => factory.srid;

  /**
   * The [PrecisionModel] used by the [Geometry]
   */
  PrecisionModel get precisionModel =>
      factory.precisionModel;

  /**
   * The topological [:dimension:] of the [Geometry]. The [:dimension:] value will
   * always be in `0 (Point), 1 (Curve) or 2 (Planar)`.
   */
  int get dimension;

  /**
   * Return a sample [Coordinate] which forms a vertex of the [Geometry].
   * Usually the first coordinate in the coordinate array.
   */
  Coordinate get coordinate;

  /**
   * A [List] containing all vertices of the [Geometry].
   * If the [Geometry] is composite, all vertices of component geometries wiin the array, in the order the component appears in the [Geometry].
   *
   * Modifying the array will not modify the [Geometry] itself.
   * Use the [:setOrdinate:] method to modify the geometry.
   * After doing so [:geometryChanged:] *must* be called.
   */
  List<Coordinate> get coordinates;

  /**
   * Test whether the [Geometry] is simple or not.
   * A [Geometry] is simple if it is not self-tangent, self-intersecting.
   *
   * Simplicity is defined as follows:
   * -- A valid [Polygon] or [LinearRing] is simple, since it's rings may not self-intersect.
   *    A polygon may be simple but not valid, since [:isSimple:] will only
   *    test for self-intersection.
   * -- A [Linear] geometry is simple iff it intersects only at it's [:boundary:] points.
   * -- Zero-dimensional and empty geometries are always simple.
   *
   */
  bool get isSimple {
    throw 'Unimplemented';
  }

  /**
   * Tests whether the [Geometry] is valid or not.
   * Validity is defined on a class by class basis, check the documentation
   * for the specific type for more information.
   */
  bool get isValid {
    throw 'Unimplemented';
  }

  /**
   * Check whether the [Geometry] is the empty geometry or not.
   */
  bool get isEmptyGeometry;

  /**
   * Check whether the [Geometry] is the not the empty geometry
   */
  bool get isNotEmptyGeometry => !isEmptyGeometry;

  /**
   * The minimum distance between `this` and the [Geometry] [:g:].
   * Returns `0` if either geometry is empty.
   */
  double distanceTo(Geometry g) {
    throw 'Unimplemented';
  }

  /**
   * Check whether the distance between `this` and the [Geometry] [:g:]
   * is less than a specified value
   */
  bool withinDistanceOf(Geometry g, double dist) {
    throw 'Unimplemented';
  }

  /**
   * Tests whether the geometry is degenerate.
   *
   * If the geometry has dimension `0`, it is considered degenerate
   * if it is the empty geometry.
   *
   * If the geometry has dimension `1`, it is considered degenerate
   * if has a [:topologicalLength:] of `0.0`.
   *
   * If the geometry has dimension `2`, it is considered degenerate
   * if it has a topological area of `0.0`.
   */
  bool get isDegenerate {
    if (dimension == dim.AREA) return topologicalArea == 0.0;
    if (dimension == dim.LINE) return topologicalLength == 0.0;
    return isEmptyGeometry;
  }

  /**
   * the [:topologicalArea:] of this [Geometry]. Any non-planar geometry will return `0.0`.
   */
  double get topologicalArea => 0.0;

  /**
   * the [:topologicalLength:] of this [Geometry].
   * For a linear geometry, this is the length of the geometry.
   * For planar geometries, this is the length of the perimeter
   * All other geometries will return `0.0`.
   */
  double get topologicalLength => 0.0;

  /**
   * Get the [:centroid:] of `this`.
   * If `this` is a composite geometry, the centroid is the centroid
   * of the subset of the components of the highest dimension (lower dimensions
   * contribute zero weight to the centroid).
   * The centroid of the void geometry is the empty Point.
   *
   * Throws a [StateError] if the geometry is empty or degenerate.
   * Note: This behaviour differs from JTS.
   */
  Point get centroid {
    if (isEmptyGeometry) {
      throw new StateError("Empty geometry has no centroid");
    }
    var dimension = this.dimension;
    Coordinate centroid;
    if (dimension == dim.POINT) {
      centroid = cent.centroidPoint(this);
    } else if (dimension == dim.LINE) {
      centroid = cent.centroidLine(this);
    } else if (dimension == dim.AREA) {
      centroid = cent.centroidArea(this);
    }
    return factory.createPoint(centroid);
  }

  /**
   * Returns an [:interiorPoint:] of `this`.
   * The point is guaranteed to lie in the interior if possible, otherwise
   * will be on the boundary of the geometry.
   * The point will lie as close to the centroid of the polygon as feasible,
   * so is a good point to place labels on geometries.
   * The interior point of an empty geometry is the empty Point.
   */
  Point get interiorPoint {
    if (isEmptyGeometry) return factory.createEmptyPoint();
    Coordinate interiorCoord;
    switch(dimension) {
      case dim.POINT:
        interiorCoord = interior.interiorPointPoint(this);
        break;
      case dim.LINE:
        interiorCoord = interior.interiorPointLine(this);
        break;
      case dim.AREA:
        interiorCoord = interior.interiorPointArea(this);
        break;
      default:
        throw 'Unrecognised dimension value: $dimension';
    }
    return factory.createPoint(interiorCoord);
  }

  /**
   * Returns the [:boundary:] of the [Geometry], or an empty geometry
   * of the appropriate dimension if `this` is empty. The boundary
   * of a geometry is always a collection of geometries of dimension
   * one lower than the dimension of `this`.
   *
   * The boundary of a [Point] imetryCollection].
   */
  Geometry get boundary;

  /**
   * The dimension of the boundary of this geometry.
   * An empty geometry will return `DIM_EMPTY`.
   */
  int get boundaryDimension;

  /**
   * Converts this [Geometry] to a normal form.
   * Normal form is a unique representation for
   * geometries.
   * The normalization is performed in-place
   */
  void normalize();

  /**
   * Returns a [:normalized:] copy of `this`
   */
  Geometry get normalized {
    return copy
        ..normalize();
  }

  /**
   * A copy of `this`.
   */
  Geometry get copy;

  /**
   * The bounding box of the [Geometry]
   */
  Envelope get envelope {
    if (_envelope == null) {
      //Cache it because we'll compute this quite a bit
      _envelope = _computeEnvelope();
    }
    return _envelope;
  }

  /**
   * Get the bounding box of `this`.
   */
  Envelope _computeEnvelope();

  /**
   * Notify the geometry that it should clear all cached values, since
   * it has been modified externally.
   */
  void geometryChanged() {
    this._envelope = null;
  }

  //RELATIONS
  /**
   * Tests whether the envelopes of `this` and [:g:] intersect.
   * Used to short-circuit geometry calculations
   */
  bool _envelopeIntersects(Geometry g) =>
      envelope.intersectsEnvelope(g.envelope);

  /**
   * Tests whether `this` intersects [:g:]
   *
   * Two [Geometry]s satisfy the [:intersects:] predicate if they satisfy
   * the following equivalent definitions:
   * -- The two geometries have at least one point in common.
   * -- The DE-91M matrix matches at least one of
   *  -- `T********`
   *  -- `*T*******`
   *  -- `***T*****`
   *  -- `****T****`
   * -- Not `this disjoint g`
   */
  bool intersects(Geometry g) => !_envelopeIntersects(g)
                              && _relate("intersects", g).isIntersects;


  /**
   * Tests whether `this` is disjoint from [:g:]
   *
   * Two [Geometry]s satisfy the [:disjoint:] predicate if they satisfy the
   * following equivalent definitions:
   * -- The two geometries do not share a common point.
   * -- The DE-9IM intersection matrix for the two geometries matches `FF*FF****`.
   * -- Not `this intersects g`
   */
  bool disjoint(Geometry g) => !intersects(g);

  /**
   * Tests whether `this` touches [:g:]
   *
   * Two [Geometry]s satisfy the [:touches:] predicate if they satisfy the
   * following equivalent definitions:
   * -- The geometries have at least one point in common, but their
   *    interiors do not intersect.
   * -- The DE-9IM intersection matrix for the two geometries matches at least one of
   *  -- `FT*******`
   *  -- `F**T*****`
   *  -- `F***T****`
   *
   * If both geometries have dimension `DIM_POINT`, this predicate returns `false`.
   */
  bool touches(Geometry g) =>
      _envelopeIntersects(g) && _relate("touches", g).isTouches(dimension, g.dimension);

  /**
   * Tests whether `this` crosses [:g:]
   *
   * Two [Geometry]s satisfy the [:crosses:] predicate if they satisfy the
   * following equivalent definitions:
   * -- The geometries have some but not all interior points in common
   * -- The DE-91M intersection matrix for the two geometries matches at least one of
   *  -- `T*T******` (for P/L, P/A and L/A situations)
   *  -- `T*****T**` (for L/P, A/P and A/L situations)
   *  -- `0********` (for L/L situations)
   *
   *  [:spatially:] follows JTS by extending the SFS definition to L/P, A/P and A/L
   *  situations in order to make the relation symmetric.
   */
  bool crosses(Geometry g) =>
      _envelopeIntersects(g) && _relate("crosses", g).isCrosses(dimension, g.dimension);

  /**
   * Test whether `this` is within [:g:]
   *
   * Two [Geometry]s satisfy the [:within:] predicate if they satisfy the
   * following equivalient definitions:
   * -- Every point of the first geometry is a point of the other geometry,
   *    and the interiors of the two geometries have at least one point in common.
   * -- The DE-9IM intersection matrix for the two geometries matches
   *    the pattern `T*F**F***`
   * -- the second geometry contains the first
   *
   * An implication of the definition is that "The boundary of a Geometry is not
   * within a geometry" (so a line contained by the boundary of a polygon is not
   * inside the polygon). See [:coveredBy:] for a predicate with similar behaviour
   * which avoids this subtlety
   */
  bool within(Geometry g) => g.contains(this);

  /**
   * Tests whether `this` contains [:g:]
   *
   * Two [Geometry]s satisfy the [:contains:] predicate if they satisfy the
   * following equivalent definitions:
   * -- Every point on the second geometry is a point on the first and the
   *    interiors of the two geometries have at least one point in common.
   * -- The DE-9IM intersection matrix for the two geometries matches
   *    the pattern `T*****FF*`
   * -- the second geometry is within the first
   *
   *  An implication of the definition is that "The boundary of a Geometry is not
   * within a geometry" (so a line contained by the boundary of a polygon is not
   * inside the polygon). See [:covers:] for a predicate with similar behaviour
   * which avoids this subtlety
   */
  bool contains(Geometry g) => _envelopeIntersects(g)
                            && _relate("contains", g).isContains;

  /**
   * Tests whether `this` overlaps g
   *
   * Two geometries satisfy the [:overlaps:] predicate if they satisfy the
   * following equivalent definitions:
   * -- The geometries have at least one point not shared by the other
   *    and the intersection of the interiors of the two geometries has the
   *    same dimensions as the geometries themselves.
   * -- The DE-9IM intersection matrix for the two geometries matches
   *    either
   *  -- `T*T***T**` (for two points or two surfaces)
   *  -- `1*T***T**` (for two curves)
   *  If the geometries are of different dimensions, returns `false`.
   */
  bool overlaps(Geometry g) => _envelopeIntersects(g)
                            && _relate("overlaps", g).isOverlaps(dimension, g.dimension);

  /**
   * Tests whether `this` covers g
   *
   * Two geometries satisfy the [:covers:] predicate if they satisfy the
   * following equivalent definitions:
   * -- Every point of the second geometry is a point of the first
   * -- The DE-9IM intersection matrix for the two geometries matches
   *    one of the following patterns:
   *  -- `T*****FF*`
   *  -- `*T****FF*`
   *  -- `***T**FF*`
   *  -- `****T*FF*`
   * -- the second geometry is [:coveredBy:] the first
   *
   * This predicate is similar to [:contains:] but does not distinguish
   * between points in the boundary and interior of geometries. For most situations
   * [:covers:] should be used in preference to [:contains:]
   */
  bool covers(Geometry g) => _envelopeIntersects(g)
                          && _relate("covers", g).isCovers;

  /**
   * Tests whether `this` is covered by [:g:]
   *
   * Two geometries satisfy the [:coveredBy:] predicate if they satisfy
   * the following equivalent definitions:
   * -- Every point on the first geometry is a point on the second
   * -- The DE-9IM intersection matrix for the two geometries matches
   *    at least one of the following patterns:
   *  -- `T*F**F***`
   *  -- `*TF**F***`
   *  -- `**FT*F***`
   *  -- `**F*TF***`
   * -- The second geometry [:cover:]s the first
   *
   * If either geoometry is empty, the value of this predicate is [:false:]
   */
  bool coveredBy(Geometry g) => g.covers(this);

  /**
   * Tests whether `this` is topologically equal to [:g:]
   *
   * Two geometries satisfy the [:equals:] predicate if the satisfy
   * the following equivalent definitions:
   * -- The two geometries have at least one point in common and no point of
   *    either geometry lies in the exterior of the other geometry
   * -- The DE-9IM intersection matrix for the two geometries matches
   *    the pattern `T*F**FFF*`
   *
   * For structural equality, see [:equalsExact:]
   */
  bool equals(Geometry g) => _envelopeIntersects(g)
                          && _relate("equals", g).isEquals(dimension, g.dimension);


  /**
   * Return the DE-9IM between `this` and the geometry [:g:]
   * describing the intersections of the boundaries and exteriors
   * of the two geometries.
   */
  IntersectionMatrix _relate(String methodName, Geometry g) {
    _checkNotGeometryList(methodName, this);
    _checkNotGeometryList(methodName, g);
    throw 'Unimplemneted';
  }

  /**
   * Tests whether the geometry [:g:] matches against an
   * arbitrary [:relationPattern:]. The pattern is a 9 character string,
   * with symbols from
   * -- '0' (dimension 0)
   * -- '1' (dimension 1)
   * -- '2' (dimension 2)
   * -- 'T' (dimension matches 0, 1 or 2)
   * -- 'F' (matches empty geometry)
   * -- '*' (mathches any dimension)
   *
   * For more information, see the OpenGIS simple Features Specification
   */
  bool relateMatches(Geometry g, String relatePattern) {
    return _relate("relateMatches", g).matches(relatePattern);
  }

  /**
   * Computes a [Geometry] representing the point-set which is common
   * to both `this` and [:geom:].
   *
   * The intersection of two geometries of different dimension produces
   * a geometry with dimension less than or equal to the minimum dimension
   * of the two geometries.
   *
   * The result may be a heterogeneous [GeometryList]
   * Intersection of [GeometryList]s is supported only for homogenous
   * collections.
   * If the result is empty, the result is an empty geometry with dimension
   * equal to the minimum of the two dimensions.
   */
  Geometry intersection(Geometry geom) {
    return overlayGeometries(this,geom, OVERLAY_INTERSECTION);
  }

  /**
   * Computes a [Geometry] which is equal to the point-set which is contained
   * in both `this` and [:geom:].
   *
   * The [:union:] of two geometries of different dimension produces a geometry
   * of dimension equal to the maximum dimension of the input geometries.
   * The result may be a heterogeneous [GeometryList]
   *
   * Non-empty [GeometryList]s (homogeneous or otherwise) are ot supported
   */
  Geometry union(Geometry geom) {
    //TODO: Geometry.union
    throw 'NotImplemented';
  }

  /**
   * Computes a [Geometry] representing the closure of the point-set of points
   * in `this` which are not in [:geom:]
   *
   * Non-empty [GeometryList]s (homogeneous or otherwise) are not supported
   */
  Geometry difference(Geometry geom) {
    //TODO: Geometry.difference
    throw 'NotImplemented';
  }

  /**
   * Computes a [Geometry] representing the closure of the point-set formed by
   * the union of `this.difference(geom)` and `geom.difference(this)`.
   *
   * Non-empty [GeometryList]s (homogeneous or otherwise) are not supported.
   */
  Geometry symmetricDifference(Geometry geom) {
    //TODO: Geometry.symmetricDifference
    throw 'NotImplemented';
  }

  /**
   * Tests if two geometris are exactly equal.
   *
   * Two geometries are exactly equal if
   * -- They have the same structure
   * -- Each of their vertices is less than a distance
   *    [:tolerance:] away from the corresponding vertex in
   *    the other geometry
   *
   * This method does *not* check the [:factory:], [:SRID:]
   * and [:userData:] fields for equality.
   *
   * To properly test for structural equality between two
   * geometries, it is usually necessary to [:normalize:] them
   * first.
   */
  bool equalsExact(Geometry g, [double tolerance = 0.0]);

  /**
   * normalize `this` and [:g:] before comparing them
   * for (structural) equality
   */
  bool equalsNormalized(Geometry g) => normalized.equalsExact(g.normalized);

  /**
   * Compare this geometry to the other geometry for order
   *
   * If classes are different, they are compared using the following
   * order:
   * -- [Point] (lowest)
   * -- [MultiPoint]
   * -- [Linestring]
   * -- [Ring]
   * -- [MultiLinestring]
   * -- [Polygon]
   * -- [MultiPolygon]
   * -- [GeometryList] (highest)
   * Otherwise, their [:vertices:] are compared for equality.
   * If [:comparator:] is provided, the [:vertices:] of the geometries
   * will be compared using the [:comparator:], and the result will be returned
   *
   */
  int compareTo(Geometry g, [Comparator<List<Coordinate>> comparator]) {
    final cmpTypes =
        Comparable.compare(types.indexOf(runtimeType),
                           types.indexOf(g.runtimeType));
    if (cmpTypes != 0) return cmpTypes;
    if (isEmptyGeometry) {
      return g.isEmptyGeometry ? 0 : -1;
    } else if (g.isEmptyGeometry) {
      return 1;
    }
    if (comparator == null) {
      comparator = forwardComparator;
    }
    return _compareToSameType(g, comparator);
  }

  int _compareToSameType(covariant Geometry g, Comparator<List<Coordinate>> comparator);

  /**
   * Tests whether this geometry is structurally and
   * numerically equal to a given object.
   *
   * The result is computed using [:equalsExact:]. For topographical
   * equality, use the [:equals:] method
   */
  bool operator ==(Object o) => o is Geometry && equalsExact(o);

  int get hashCode => coordinates.fold(31, (h, v) => h * 31 + v.hashCode);

  String toString() {
    var codec = new wkt.WktCodec(factory);
    return codec.encode(this);
  }
}

void _checkNotGeometryList(String methodName, Geometry g) {
  if (g is GeometryList) {
    throw new ArgumentError(
        "Geometry.$methodName does not support GeometryList arguments");
  }
}



class GeometryError extends Error {
  GeometryError(String message) : super();
}
