library spatially.geomgraph.location_tests;

import 'package:test/test.dart';
import 'package:quiver/core.dart';
import 'package:spatially/geomgraph/location.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/geom/location.dart' as loc;

main() {
  group("location", () {
    GeometryFactory geomFactory = new GeometryFactory();
    Geometry relativeTo = geomFactory.createEmptyPoint();
    test("should be able to create a nodal or linear location", () {
      var location = new Location(relativeTo,
                                  on: loc.INTERIOR);
      expect(location.on, loc.INTERIOR);
      expect(() => new Location(relativeTo), throws);
    });

    test("should be able to create a planar location", () {
      var location = new Location(relativeTo,
                                  on: loc.BOUNDARY,
                                  left: loc.INTERIOR,
                                  right: loc.EXTERIOR);
      expect(location.on, loc.BOUNDARY);
      expect(location.left, new Optional.of(loc.INTERIOR));
      expect(location.right, new Optional.of(loc.EXTERIOR));

      expect(() => new Location(relativeTo, on: loc.BOUNDARY, left: loc.INTERIOR), throws);
      expect(() => new Location(relativeTo, on: loc.BOUNDARY, right: loc.EXTERIOR), throws);
    });

    test("should be able to merge two nodal or linear locations", () {
      var location1 = new Location(relativeTo, on: loc.NONE);
      location1.mergeWith(new Location(relativeTo, on: loc.EXTERIOR));
      expect(location1.on, loc.EXTERIOR);
      location1.mergeWith(new Location(relativeTo, on: loc.INTERIOR));
      expect(location1.on, loc.EXTERIOR, reason: "merging with a non-null location does nothing");
    });

    test("should be able to merge a planar location with a nodal or linear location", () {
      var location1 = new Location(relativeTo, on: loc.NONE, left: loc.INTERIOR, right: loc.EXTERIOR);
      location1.mergeWith(new Location(relativeTo, on: loc.INTERIOR));
      expect(location1.on, loc.INTERIOR, reason: "on");
      expect(location1.left, new Optional.of(loc.INTERIOR), reason: "left");
      expect(location1.right, new Optional.of(loc.EXTERIOR), reason: "right");
    });

    test("should be able to merge two planar locations", () {
      var location1 = new Location(relativeTo, on: loc.NONE, left: loc.NONE, right: loc.NONE);

      location1.mergeWith(
          new Location(relativeTo, on: loc.NONE,
                                   left: loc.INTERIOR,
                                   right: loc.EXTERIOR));
      expect(location1.left, new Optional.of(loc.INTERIOR));
      expect(location1.right, new Optional.of(loc.EXTERIOR));

      location1.mergeWith(
          new Location(relativeTo, on: loc.NONE,
                        left: loc.INTERIOR,
                        right: loc.INTERIOR));
      expect(location1.left, new Optional.of(loc.INTERIOR));
      expect(location1.right, new Optional.of(loc.INTERIOR));
    });

    test("should be able to normalize depths", () {
      var location = new Location(relativeTo, on: loc.NONE);
      location.leftDepth = new Optional.of(4);
      location.rightDepth = new Optional.of(6);
      location.normalizeDepths();
      expect(location.leftDepth, new Optional.of(0));
      expect(location.rightDepth, new Optional.of(2));
    });

    test("should be able to copy a location", () {
      var location = new Location(relativeTo, on: loc.INTERIOR, left: loc.EXTERIOR, right: loc.INTERIOR);
      var loc2 = new Location.fromLocation(location);

      expect(loc2.on, loc.INTERIOR);
      expect(loc2.left.isPresent, isFalse);
      expect(loc2.right.isPresent, isFalse);

      var loc3 = new Location.fromLocation(location, asNodal: false);
      expect(loc3.on, loc.INTERIOR);
      expect(loc3.left, new Optional.of(loc.EXTERIOR));
    });

    test("should be able to flip a location", () {
      var location = new Location(relativeTo, on: loc.BOUNDARY, left: loc.EXTERIOR, right: loc.INTERIOR);
      expect(location.flipped, new Location(relativeTo, on: loc.BOUNDARY, left: loc.INTERIOR, right: loc.EXTERIOR));
    });
  });
}