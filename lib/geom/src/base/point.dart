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

class Point extends Geometry {
  /**
   * The [Coordinate] wrapped by this [Point]
   */
  List<Coordinate> _coords;
  Point._(List<Coordinate> this._coords, GeometryFactory factory)
      : super._(factory);

  Coordinate get coordinate =>
      isNotEmptyGeometry ? _coords.first : null;

  bool get isEmptyGeometry => _coords.length == 0;

  bool get isSimple => true;

  int get dimension => dim.POINT;

  int get boundaryDimension => dim.EMPTY;

  Geometry get copy => factory.createPoint(new Coordinate.copy(coordinate));

  Geometry get reversed => copy;

  Geometry get boundary =>
      factory.createEmptyGeometryList();

  List<Coordinate> get coordinates => _coords.toList();

  Envelope _computeEnvelope() {
    Envelope env = new Envelope.empty();
    if (isEmptyGeometry) {
      return env;
    }
    return env.expandToCoordinate(this.coordinate);
  }

  bool equalsExact(Geometry other, [double tolerance = 0.0]) {
    if (other is Point) {
      if (isEmptyGeometry && other.isEmptyGeometry) return true;
      if (isEmptyGeometry || other.isEmptyGeometry) return false;
      if (tolerance > 0) {
        return coordinate == other.coordinate;
      }
      return coordinate.equals2d(other.coordinate, tolerance);
    }
    return false;
  }


  void normalize() {
    // a point is always normalized
  }

  @override
  int _compareToSameType(Point other, Comparator<List<Coordinate>> comparator) {
    return comparator(_coords, other._coords);
  }


}