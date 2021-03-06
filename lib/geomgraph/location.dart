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


library spatially.geomgraph.location;

import 'dart:math' as math show min, max;
import 'package:quiver/core.dart' show Optional, hash4;

import 'package:spatially/geom/base.dart';
import 'package:spatially/geom/location.dart' as loc;


class Location {
  /**
   * Initializes the depth given a particular location
   */
  static Optional<int> _depthAtLocation(int location) {
    if (location == null || location == loc.NONE)
      return new Optional.absent();
    return new Optional.of(location == loc.INTERIOR ? 1 : 0);
  }

  Geometry relativeTo;

  int on;

  /**
   * The location directly to the left of this edge.
   * Only present if the edge represents the boundary of a [Ring] or [Polygon]
   */
  Optional<int> leftDepth;
  /**
   * The location directly to the right of this edge.
   * Only present if the edge represents the boundary of a [Ring] or [Polygon]
   */
  Optional<int> rightDepth;

  Optional<int> get left =>
      leftDepth.transform((depth) => depth > 0 ? loc.INTERIOR : loc.EXTERIOR);
  Optional<int> get right =>
      rightDepth.transform((depth) => depth > 0 ? loc.INTERIOR : loc.EXTERIOR);

  Location(this.relativeTo, { int on, int left, int right }) :
    this.on = on,
    leftDepth = _depthAtLocation(left),
    rightDepth = _depthAtLocation(right) {
    assert(on != null);
    if (leftDepth.isPresent || rightDepth.isPresent) {
      if (!(leftDepth.isPresent && rightDepth.isPresent)) {
        throw new ArgumentError(
            "Both left and right depths must be provided "
            "for a valid planar label");
      }
    }
  }

  Location.unknown(Geometry geom) : this(geom, on: loc.NONE);

  factory Location.merged(Location loc1, Location loc2) {
    var loc = new Location.fromLocation(loc1, asNodal: false);
    loc.mergeWith(loc2);
    return loc;
  }

  /**
   * Copies a location. If [:asNodal:] is `true`, the left and right depths of the old location
   * are ignored and not copied onto the new location.
   */
  factory Location.fromLocation(Location location, {asNodal: true}) {
    Location newLocation = new Location(location.relativeTo, on: location.on);
    if (!asNodal) {
      newLocation.leftDepth = location.leftDepth;
      newLocation.rightDepth = location.rightDepth;
    }
    return newLocation;
  }

  bool get isPlanar => leftDepth.isPresent;

  /**
   * A location is known iff `on != loc.NONE`.
   */
  bool get isKnown => on != loc.NONE;

  /**
   * An location is dimensionally collapse if both the left depth
   * and right depth are equal.
   * Linear and nodal locations are always dimensionally collapsed.
   */
  bool get isDimensionallyCollapsed => leftDepth == rightDepth;

  /**
   * Returns an location with the left and right locations reversed
   */
  Location get flipped {
    //The only reason edges should have left and right depths
    //is because they exist on the boundary of a polygon.
    var flipped = new Location(relativeTo, on: loc.BOUNDARY);
    flipped.leftDepth = rightDepth.transform((x) => x);
    flipped.rightDepth = leftDepth.transform((x) => x);
    return flipped;
  }

  /**
   * Resets the depths so that the lower one is on the
   * exterior of the polygon.
   *
   * Normalizing a linear or nodal location does nothing.
   */
  void normalizeDepths() {
    if (left.isPresent) {
      var left = leftDepth.value; var right = rightDepth.value;
      var minDepth = math.min(left, right);
      assert(minDepth >= 0);
      leftDepth = leftDepth.transform((depth) => depth - minDepth);
      rightDepth = rightDepth.transform((depth) => depth - minDepth);
    }
  }

  /**
   * Merges a location with another location.
   * If [:on:] is [loc.NONE], it will be set to the value of locationData.on.
   * The left and right depths will be incremented by the value of the
   * location data's depths.
   */
  void mergeWith(Location locationData) {
    if (on == loc.NONE)
      on = locationData.on;
    if (locationData.left.isPresent) {
      //If merging with a planar location, increase the left and right
      //depths.
      leftDepth = new Optional.of(
          leftDepth
          .transform((depth) => depth + locationData.leftDepth.value)
          .or(locationData.leftDepth.value));
      rightDepth = new Optional.of(
          rightDepth
          .transform((depth) => depth + locationData.rightDepth.value)
          .or(locationData.rightDepth.value));
    }
  }

  bool operator ==(Object other) {
    if (other is Location) {
      return other.relativeTo == relativeTo
          && other.on == on
          && other.leftDepth == leftDepth
          && other.rightDepth == rightDepth;
    }
    return false;
  }

  int get hashCode => hash4(relativeTo, on, leftDepth, rightDepth);

  String toString() {
    var str = "Location(on: ${loc.toLocationSymbol(on)}";
    if (leftDepth.isPresent) {
      str += ", left: ${loc.toLocationSymbol(left.value)} (depth: ${leftDepth.value})"
             ", right: ${loc.toLocationSymbol(right.value)} (depth: ${rightDepth.value}";
    }
    str += ")";
    return str;
  }
}