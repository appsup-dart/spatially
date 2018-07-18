library spatially.base.coordinate_test;

import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:spatially/base/coordinate.dart';

main() {
  group("coordinate", () {
    test("should be convertible to a math.Point", () {
      var coord = new Coordinate(0.0, 0.0);
      expect(coord.toPoint(), new math.Point(0.0, 0.0));
    });

    test("should be convertible from a math.Point", () {
      expect(new Coordinate.fromPoint(new math.Point(1.0, 1.0)), new Coordinate(1.0, 1.0));
    });
  });
}