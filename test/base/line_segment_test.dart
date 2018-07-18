library spatially.base.line_segment_test;

import 'dart:math' as math show sqrt;
import 'package:test/test.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';

main() {
  group("linesegment", () {
    test("should be able to get the midpoint of a linesegment", () {
      var lseg = new LineSegment(new Coordinate(0, 0), new Coordinate(1,1));
      expect(lseg.midpoint, new Coordinate(0.5, 0.5));
    });

    test("should be able to create an iterable of linesegments from an iterable of coordinates", () {
      var coords = [new Coordinate(0, 0), new Coordinate(1,1), new Coordinate(1,0), new Coordinate(0,1)];
      expect(coordinateSegments(coords),
             [ new LineSegment(new Coordinate(0,0), new Coordinate(1,1)),
               new LineSegment(new Coordinate(1,1), new Coordinate(1,0)),
               new LineSegment(new Coordinate(1,0), new Coordinate(0,1))
             ]);
    });

    test("should be able to get the magnitude of a line segment", () {
      var lseg = new LineSegment(new Coordinate(0,0), new Coordinate(1,1));
      expect(lseg.magnitude, math.sqrt(2));

      var lseg2 = new LineSegment(new Coordinate(3,3), new Coordinate(3,3));
      expect(lseg2.magnitude, 0, reason: "Trivial line segment");
    });
  });
}