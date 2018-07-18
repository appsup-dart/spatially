

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

/**
 * Utility methods for dealing with lists of coordinates
 */
library spatially.algorithm.coordinate_arrays;

import 'package:quiver/iterables.dart';

import 'package:spatially/base/coordinate.dart';
import 'cg_algorithms.dart' as cg_algorithms;

/**
 * Tests whether the [CoordinateArray] forms a ring,
 * by checking its [:length:] and closure.
 *
 * Self-intersection is not checked
 */
bool isRing(Iterable<Coordinate> coords) =>
    coords.isEmpty || (coords.length >= 4 && coords.first == coords.last);

/**
 * The minimum [Coordinate] in the [CoordinateArray], using
 * the default lexicographic ordering on [Coordinate]s
 *
 * If the [CoordinateArray] is empty, returns
 *  `(double.INFINITY, double.INFINITY)`
 */
Coordinate minCoordinate(Iterable<Coordinate> coords) =>
    coords.fold(
      new Coordinate(double.INFINITY, double.INFINITY),
      (min, coord) => min < coord ? min : coord);

/**
 * The maximum [Coordinate] in the [CoordinateArray], using
 * the default lexicographic ordering on [Coordinate]s
 *
 * If the [CoordinateArray] is empty, returns
 *  `(double.NEGATIVE_INFINITY, double.NEGATIVE_INFINITY)`
 */
Coordinate maxCoordinate(Iterable<Coordinate> coords) =>
  coords.fold(
      new Coordinate(double.NEGATIVE_INFINITY, double.NEGATIVE_INFINITY),
      (max, coord) => max > coord ? max : coord);


/**
 * Tests whether the [CoordinateArray] has two consecutive [Coordinate]s
 * which compare equal
 */
bool hasRepeatedCoordinates(List<Coordinate> coords) =>
    range(1,coords.length).any((i) => coords[i] == coords[i-1]);

/**
 * Returns a new [CoordinateArray], with all repeated [Coordinate]s
 * removed.
 * Since the [:length:] of the returned array will likely be different
 * to [:length:], the removal is not performed in place.
 */
List<Coordinate> removeRepeatedCoordinates(List<Coordinate> coords) =>
    new List<Coordinate>.from(
      range(0, coords.length)
          .where((i) => i == 0 || coords[i] != coords[i - 1])
          .map((i) => coords[i]),
      growable: false);

/**
 * If any triple of adjacent coordinates in [:coords:] forms a collinear
 * triple, removes the middle coordinate from the list.
 * Stronger result than [:removeRepeatedCoordinates:]
 */
List<Coordinate> removeCollinearTriples(List<Coordinate> coords) {
  if (coords.length < 2) {
    return removeRepeatedCoordinates(coords);
  }
  var li = new List<Coordinate>();
  li.add(coords.first);
  for (var i in range(1, coords.length - 1)) {
    var orientation = cg_algorithms.orientationIndex(coords[i - 1], coords[i], coords[i+1]);
    if (orientation == cg_algorithms.COLLINEAR) {
      continue;
    }
    li.add(coords[i]);
  }
  li.add(coords.last);
  return li;
}

/**
 * Shifts the positions of coordinates until [:coord:] is the
 * first element of `this`.
 * The scroll is performed in-place on the array.
 */
void scrollCoordinates(List<Coordinate> coords, Coordinate c) {
  int i = coords.indexOf(c);
  final coordsBefore = coords.getRange(0, i);
  final coordsAfter = coords.getRange(i, coords.length);

  coords.setRange(0, coordsAfter.length, coordsAfter);
  coords.setRange(coordsAfter.length, coords.length, coordsBefore);
}

/**
* Returns an integer representing the direction in which
* the [Coordinate]s in the array increase according to their
* natural ordering.
*
* If a positive integer is returned, the start of the array
* is "smaller" than the end of the array.
* A palindromic array is defined to travel in a positive direction
*/
int directionOfIncrease(List<Coordinate> coords) {
  for (int i=0;i<coords.length / 2; i++) {
    var j = coords[coords.length - 1 - i];
    // skip equal on both ends
    var cmp = coords[i].compareTo(j);
    if (cmp != 0) return cmp;
  }
  //palindromic arrays are positive
  return 1;
}

/**
 * A [Comparator] which compares two coordinate arrays coordinate-wise
 */
Comparator<List<Coordinate>> get forwardComparator {
  int compare(List<Coordinate> coordArray1, List<Coordinate> coordArray2) {
    int l1 = coordArray1.length;
    int l2 = coordArray2.length;
    int i=0;
    while (i < l1 && i < l2) {
      var cmp = coordArray1[i].compareTo(coordArray2[i]);
      if (cmp != 0) return cmp;
      i++;
    }
    if (i < l1) return 1;
    if (i < l2) return -1;
    return 0;
  }
  return compare;
}

/**
 * If two coordinate arrays are identical, but reversed, returns 0.
 * Otherwise return the result of ordering the arrays in the forward
 * direction
 */
Comparator<List<Coordinate>> get bidirectionalComparator {
  bool isEqualReversed(List<Coordinate> coords1, List<Coordinate> coords2) {
    if (coords1.length != coords2.length) return false;
    var l = coords1.length;
    for (var i in range(l)) {
      var j = l - 1 - i;
      if (coords1[i] != coords2[j]) {
        return false;
      }
    }
    return true;
  }
  int compare(List<Coordinate> coordArray1, List<Coordinate> coordArray2) {

    var cmp = forwardComparator(coordArray1, coordArray2);
    if (cmp != 0 && isEqualReversed(coordArray1, coordArray2)) {
      return 0;
    }
    return cmp;
  }
  return compare;
}