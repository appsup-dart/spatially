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

class Ring extends Linestring {
  Ring._(List<Coordinate> coords, GeometryFactory factory) :
      super._(coords, factory);

  //Rings do not have a boundary
  int get boundaryDimension => dim.EMPTY;

  bool get isClosed => isEmptyGeometry || super.isClosed;

  Ring get reversed {
    return factory.createRing(_coords.reversed);
  }

  Ring get copy =>
      factory.createRing(_coords.map((c) => new Coordinate.copy(c)));

}