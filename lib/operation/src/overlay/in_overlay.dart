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

part of spatially.operation.overlay;


bool _interiorOrBoundary(int location) => location == loc.INTERIOR || location == loc.BOUNDARY;

/**
 * test whether a location is in the overlay intersection
 */
bool _inIntersection(Tuple<int,int> onLocations) =>
    onLocations.both((v)=>_interiorOrBoundary(v));

/**
 *test whether a location is in the overlay union
 */
bool _inUnion(Tuple<int,int> onLocations) =>
    onLocations.either((v)=>_interiorOrBoundary(v));

/**
 * test whether a tuple of locations is in the overlay difference.
 * The left operand is assumed to be the location of the minuend geometry
 */
bool _inDifference(Tuple<int,int> onLocations) =>
    _interiorOrBoundary(onLocations.$1)
    && !_interiorOrBoundary(onLocations.$2);

/**
 * test whether a tuple of locations is in the overlay symmetric difference
 */
bool _inSymmetricDifference(Tuple<int,int> onLocations) =>
    onLocations.either((v)=>_interiorOrBoundary(v))
      && !onLocations.both((v)=>_interiorOrBoundary(v));


