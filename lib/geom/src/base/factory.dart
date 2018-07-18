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


part of geom.base;

class GeometryFactory {

  final PrecisionModel _precisionModel;
  PrecisionModel get precisionModel =>
      _precisionModel != null
      ? _precisionModel
      : new PrecisionModel(PrecisionModel.PREC_FLOATING);

  final int srid;

  /**
   * Create a new [GeometryFactory] with the given
   * [PrecisionModel], [List<Coordinate>Factory] and spatial reference system identifier.
   */
   GeometryFactory([PrecisionModel this._precisionModel,
                    int this.srid = 0]);

  /**
   * Parses a geometry from the WKT string representation of the geometry.
   */
  Geometry fromWkt(String wktGeom) {
    wkt.WktCodec wktCodec = new wkt.WktCodec(this);
    return wktCodec.decoder.convert(wktGeom);
  }

  /**
   * Creates a full copy of the argument geometry
   */
  T clone<T extends Geometry>(T geom) {
    if (geom is Point) {
      if (geom.isEmptyGeometry) {
        return createEmptyPoint() as T;
      }
      return createPoint(geom.coordinate) as T;
    }
    if (geom is Ring) {
      if (geom.isEmptyGeometry)
        return createEmptyRing() as T;
      return createRing(geom.coordinates) as T;
    }
    if (geom is Linestring) {
      if (geom.isEmptyGeometry) {
        return createEmptyLinestring() as T;
      }
      return createLinestring(geom.coordinates) as T;
    }
    if (geom is Polygon) {
      if (geom.isEmptyGeometry) {
        return createEmptyPolygon() as T;
      }
      var extRing = clone(geom.exteriorRing);
      var intRings = geom.interiorRings.map(clone);
      return createPolygon(extRing, intRings) as T;
    }
    if (geom is MultiPoint) {
      return createMultiPoint(geom.map(clone)) as T;
    }
    if (geom is MultiLinestring) {
      return createMultiLinestring(geom.map(clone)) as T;
    }
    if (geom is MultiPolygon) {
      return createMultiPolygon(geom.map(clone)) as T;
    }
    if (geom is GeometryList) {
      return createGeometryList(geom.map(clone)) as T;
    }
    throw new ArgumentError("Don't know how to clone $geom");
  }


  Point createEmptyPoint() {
    List<Coordinate> _coords = new List(0);
    return new Point._(_coords, this);
  }

  Point createPoint(Coordinate coordinate) {
    precisionModel.makePreciseCoordinate(coordinate);
    List<Coordinate> _coords = new List(1);
    _coords[0] = coordinate;
    return new Point._(_coords, this);
  }

  Linestring createEmptyLinestring([lb_rule.VertexInBoundaryRule boundaryRule]) {
    List<Coordinate> _coords = new List(0);
    return new Linestring._(_coords, this);
  }

  Linestring createLinestring(Iterable<Coordinate> coords) {
    if (coords.length == 1) {
      throw new ArgumentError(
          "Invalid number of coordinates in linestring (1). "
          "Expected 0 or >= 2");
    }
    List<Coordinate> _coords = new List(coords.length);
    _coords.setAll(0, coords);
    _coords.forEach(precisionModel.makePreciseCoordinate);
    return new Linestring._(_coords, this);
  }

  Ring createEmptyRing() {
    List<Coordinate> coords = new List(0);
    return new Ring._(coords, this);
  }
  Ring createRing(Iterable<Coordinate> coords) {
    if (coords.length >= 1 && coords.length < 4) {
      throw new ArgumentError(
          "Invalid number of coordinates in ring (${coords.length}). "
          "Expected 0 or >= 2");
    }
    if (coords.isNotEmpty && coords.first != coords.last){
      throw new ArgumentError(
          "Coordinates must form a closed ring");
    }
    List<Coordinate> coordSeq = new List(coords.length);
    coordSeq.setAll(0, coords);
    coords.forEach(precisionModel.makePreciseCoordinate);
    return new Ring._(coordSeq, this);
  }

  Polygon createEmptyPolygon() {
    return new Polygon._(createEmptyRing(), new List(0), this);
  }

  Polygon createPolygon(Ring shell, [Iterable<Ring> holes = const[]]) {
    if (holes.any((h) => h == null)) {
      throw new ArgumentError("Holes cannot contain null elements");
    }
    if (shell.isEmptyGeometry && holes.any((h) => h.isNotEmptyGeometry)) {
      throw new ArgumentError("Shell is empty but contains non-empty hole");
    }
    return new Polygon._(shell, new List.from(holes), this);
  }

  GeometryList createEmptyGeometryList() {
    return new GeometryList._([], this);
  }

  GeometryList createGeometryList(Iterable<Geometry> geoms) {
    return new GeometryList._(new List<Geometry>.from(geoms), this);
  }

  MultiPoint createEmptyMultiPoint() {
    return new MultiPoint._([], this);
  }
  MultiPoint createMultiPoint(Iterable<Point> points) {
    return new MultiPoint._(new List<Point>.from(points), this);
  }

  MultiLinestring createEmptyMultiLinestring() {
    return new MultiLinestring._([], this);
  }
  MultiLinestring createMultiLinestring(Iterable<Linestring> linestrings) {
    return new MultiLinestring._(
        new List<Linestring>.from(linestrings),
        this);
  }

  MultiPolygon createEmptyMultiPolygon() {
    return new MultiPolygon._([], this);
  }

  MultiPolygon createMultiPolygon(Iterable<Polygon> polys) {
    return new MultiPolygon._(
        new List<Polygon>.from(polys),
        this);
  }
}