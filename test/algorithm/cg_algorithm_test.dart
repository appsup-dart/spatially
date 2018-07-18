library spatially.algorithm.cg_algorithm_test;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/algorithm/cg_algorithms.dart' as cg_algorithm;
import 'package:spatially/geom/location.dart' as loc;

main() {
  group('cg_algorithm', () {
    locateCoordinateInRingTest();
  });

}

locateCoordinateInRingTest() {
  group("coordinate in ring", () {
    var ring = [ new Coordinate(0, 0),
                 new Coordinate(1, 0),
                 new Coordinate(1, 1),
                 new Coordinate(0, 0)
               ];
    //A u-shaped ring
    var uring = [ new Coordinate(0, 0),
                 new Coordinate(3, 0),
                 new Coordinate(3, 3),
                 new Coordinate(2, 3),
                 new Coordinate(2, 2),
                 new Coordinate(1, 2),
                 new Coordinate(1, 3),
                 new Coordinate(0, 3),
                 new Coordinate(0,0) ];
    test("should locate a coordinate outside the ring", () {
      expect(cg_algorithm.locateCoordinateInRing(new Coordinate(-1, 0.5), ring),
             loc.EXTERIOR, reason: "left of the ring");
      expect(cg_algorithm.locateCoordinateInRing(new Coordinate(3, 0.5), ring),
             loc.EXTERIOR, reason: "right of the ring");
      expect(cg_algorithm.locateCoordinateInRing(new Coordinate(0.5, 1.5), ring),
             loc.EXTERIOR, reason: "above the ring");
    });

    test("should locate a coordinate inside the ring", () {
      expect(cg_algorithm.locateCoordinateInRing(new Coordinate(0.75, 0.25), ring), loc.INTERIOR);
    });

    test("should locate a coordinate at a vertex", () {
      expect(cg_algorithm.locateCoordinateInRing(new Coordinate(0, 0), ring), loc.BOUNDARY);
    });

    test("should locate a coordinate on an edge", () {
      expect(cg_algorithm.locateCoordinateInRing(new Coordinate(0.5, 0), ring), loc.BOUNDARY);
      expect(cg_algorithm.locateCoordinateInRing(new Coordinate(0.5, 0.5), ring), loc.BOUNDARY);
    });

    test("should be able to locate a coordinate in the 'hollow' portion of a u-shaped ring", () {
      expect(cg_algorithm.locateCoordinateInRing(new Coordinate(1.5, 2.5), uring), loc.EXTERIOR);
      expect(cg_algorithm.locateCoordinateInRing(new Coordinate(0.5, 2.5), uring), loc.INTERIOR);
    });
  });
}

