library spatially.algorithm.coordinate_arrays_test;

import 'package:test/test.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/algorithm/coordinate_arrays.dart';

void main() {
  group("coordinate arrays", () {
    test("should be able to remove repeated coordinates from a list", () {
      var coords =
          [ new Coordinate(0, 0),
            new Coordinate(0,0),
            new Coordinate(1,0),
            new Coordinate(2, 0),
            new Coordinate(1, 0),
            new Coordinate(1, 0),
            new Coordinate(1,1)
          ];
      expect(removeRepeatedCoordinates(coords),
          [ new Coordinate(0,0),
            new Coordinate(1,0),
            new Coordinate(2,0),
            new Coordinate(1,0),
            new Coordinate(1,1)]);
    });

    test("should be able to remove colinear triples from a list", () {
      var coords =
          [ new Coordinate(0,0),
            new Coordinate(0, 0.5),
            new Coordinate(0, 0.5),
            new Coordinate(1,1),
            new Coordinate(0.75, 1),
            new Coordinate(0.5, 1),
            new Coordinate(0, 1)
          ];
      expect(removeCollinearTriples(coords),
          [ new Coordinate(0,0),
            new Coordinate(1,1),
            new Coordinate(0,1) ]);
    });

    test("should be able to get the direction of increase of a coordinate array", () {
      var coords =
          [ new Coordinate(0, 0),
            new Coordinate(0.5, 0),
            new Coordinate(1, 0) ];
      expect(directionOfIncrease(coords), 1);

      var coords2 =
          [ new Coordinate(0, 0),
            new Coordinate(1, 0),
            new Coordinate(0.5, 0),
            new Coordinate(0,0)
          ];
      expect(directionOfIncrease(coords2), -1);

      var coords3 =
          [ new Coordinate(0,0),
            new Coordinate(1,0),
            new Coordinate(1,0),
            new Coordinate(0,0)
          ];
      expect(directionOfIncrease(coords3), 0);
    });
  });
}