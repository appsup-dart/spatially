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

class Polygon extends Geometry {
  Ring _shell;
  List<Ring> _holes;

  Polygon._(Ring this._shell, List<Ring> this._holes, GeometryFactory factory)
      : super._(factory);

  int get dimension => 2;
  int get boundaryDimension => 1;

  bool get isEmptyGeometry => _shell.isEmptyGeometry;

  Coordinate get coordinate => _shell.coordinate;

  Ring get exteriorRing => _shell;
  List<Ring> get interiorRings => _holes;

  /**
   * All the rings of the polygon, interior and exterior
   */
  List<Ring> get _rings {
    List<Ring> rings = new List<Ring>(_holes.length + 1);
    rings[0] = _shell;
    rings.setAll(1, _holes);
    return rings;
  }

  List<Coordinate> get coordinates {
    if (isEmptyGeometry) return new List(0);
    List<Coordinate> coords = new List<Coordinate>();
    _rings.forEach((r) => coords.addAll(r.coordinates));
    return coords;
  }

  /**
   * The topological area of the polygon
   */
  double get topologicalArea {
    throw 'NotImplemented';
  }

  /**
   * The topological length of the polygon
   */
  double get topologicalLength =>
      _rings.fold(0.0, (l, r) => l + r.length);

  Geometry get boundary {
    if (isEmptyGeometry) {
      return factory.createEmptyMultiLinestring();
    }
    if (_holes.isEmpty) {
      //Just a linestring
      return factory.createLinestring(_shell.coordinates);
    } else {
      return factory.createMultiLinestring(_rings);
    }
  }

  Envelope _computeEnvelope() {
    return _shell._computeEnvelope();
  }

  bool equalsExact(Geometry geom, [double tolerance=0.0]) {
    if (geom is Polygon) {
      if (!_shell.equalsExact(geom._shell, tolerance)) {
        return false;
      }
      if (_holes.length != geom._holes.length)
        return false;
      return range(_holes.length)
          .every((i) => _holes[i].equalsExact(geom._holes[i], tolerance));
    }
    return false;
  }

  Geometry get copy {
    Polygon poly = factory.createEmptyPolygon();
    poly._shell = _shell.copy;
    poly._holes = new List.from(_holes.map((h) => h.copy));
    return poly;
  }

  void normalize() {
    void normalizeRing(Ring r, bool clockwise) {
      if (r.isEmptyGeometry)
        return;

      final ringCoords = r._coords;
      //Drop the endpoint
      final uniqCoords = new List<Coordinate>.from(ringCoords.getRange(0, ringCoords.length - 1));
      final minCoord = minCoordinate(ringCoords);
      //The minimum coordinate should be the first element of the normalized ring
      scrollCoordinates(ringCoords, minCoord);
      //Copy the scrolled list back onto the ring
      ringCoords.setRange(0, ringCoords.length - 1, uniqCoords);
      //Close the ring
      ringCoords[ringCoords.length - 1] = ringCoords[0];

      if (cg_algorithms.isCounterClockwise(ringCoords)) {
        ringCoords.reversed;
      }
    }
    normalizeRing(_shell, true);
    for (var r in _holes) {
      normalizeRing(r, false);
    }
    _holes.sort();
  }

  int _compareToSameType(Polygon poly, Comparator<List<Coordinate>> comparator) {
    var cmpShells = _shell._compareToSameType(poly._shell, comparator);
    if (cmpShells != 0) return cmpShells;

    int numHoles1 = _holes.length;
    int numHoles2 = poly._holes.length;
    int i = 0;
    while (i < numHoles1 && i < numHoles2) {
      var cmpHoles = _holes[i]._compareToSameType(poly._holes[i], comparator);
      if (cmpHoles != 0) return cmpHoles;
    }
    if (i < numHoles1) return 1;
    if (i < numHoles2) return -1;
    return 0;
  }
}