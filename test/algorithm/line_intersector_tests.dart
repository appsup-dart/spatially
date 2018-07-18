library spatially.algorithm.line_intersector_tests;
import 'package:test/test.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';
import 'package:spatially/algorithm/line_intersector.dart';

void main() {
  testCollinear();
  testRobustness();
}

void testCollinear() {
  group("collinear segments", () {
    test("collinear intersect at point", () {
      var lseg1 = new LineSegment(
          new Coordinate(0.0, 0.0),
          new Coordinate(10.0, 10.0));
      var lseg2 = new LineSegment(
          new Coordinate(10.0, 10.0),
          new Coordinate(20.0, 20.0));
      var expectIntersection = new Coordinate(10.0, 10.0);
      var actualIntersection = segmentIntersection(lseg1, lseg2);
      expect(actualIntersection, equals(expectIntersection));
    });
    test("collinear intersect along segment", () {
      var lseg1 = new LineSegment(
          new Coordinate(0.0, 0.0),
          new Coordinate(10.0, 10.0));
      var lseg2 = new LineSegment(
          new Coordinate(5.0, 5.0),
          new Coordinate(20.0, 20.0));
      var expectIntersection =
          new LineSegment(
              new Coordinate(5.0, 5.0),
              new Coordinate(10.0, 10.0));
      var actualIntersection = segmentIntersection(lseg1, lseg2);
      expect(actualIntersection, equals(expectIntersection));
    });
    test("non-intersecting", () {
      var lseg1 = new LineSegment(
          new Coordinate(0.0, 0.0),
          new Coordinate(10.0, 10.0));
      var lseg2 = new LineSegment(
          new Coordinate(11.0, 11.0),
          new Coordinate(20.0, 20.0));
      var actualIntersection = segmentIntersection(lseg1, lseg2);
      expect(actualIntersection, isNull);
    });
  });
  group("point intersections", () {
    test("intersect at endpoint", () {
      var lseg1 = new LineSegment(
          new Coordinate(0.0, 0.0),
          new Coordinate(10.0, 10.0));
      var lseg2 = new LineSegment(
          new Coordinate(10.0, 10.0),
          new Coordinate(10.0, 0.0));
      var expectIntersection = new Coordinate(10.0, 10.0);
      var actualIntersection = segmentIntersection(lseg1, lseg2);
      expect(actualIntersection, equals(expectIntersection));
    });
    test("intersect at midpoint", () {
      var lseg1 = new LineSegment(
          new Coordinate(0.0, 0.0),
          new Coordinate(10.0, 10.0));
      var lseg2 = new LineSegment(
          new Coordinate(0.0, 10.0),
          new Coordinate(10.0, 0.0));
      var expectIntersection = new Coordinate(5.0, 5.0);
      var actualIntersection = segmentIntersection(lseg1, lseg2);
      expect(actualIntersection, equals(expectIntersection));
    });
    test("intersect at 2/3 of seg1", () {
      var lseg1 = new LineSegment(
          new Coordinate(0.0, 0.0),
          new Coordinate(10.0, 10.0));
      var lseg2 = new LineSegment(
          new Coordinate(0.0, 10.0),
          new Coordinate(20.0, 0.0));
      var expectIntersection = new Coordinate(6.666666666666667, 6.666666666666667);
      var actualIntersection = segmentIntersection(lseg1, lseg2);
      expect(actualIntersection, equals(expectIntersection));
    });
  });
}

void testRobustness() {
  test("equal endpoints", () {
    final lseg1 =
        new LineSegment(
            new Coordinate(19.850257749638203,46.29709338043669),
            new Coordinate(20.31970698357233, 46.76654261437082 ));
    final lseg2 =
        new LineSegment(
            new Coordinate(-48.51001596420236, -22.063180333403878),
            new Coordinate(19.850257749638203, 46.29709338043669 ));
    final expectIntersection =
        new Coordinate(19.850257749638203,46.29709338043669);
    final actualIntersection =
        segmentIntersection(lseg1, lseg2);
    expect(actualIntersection, equals(expectIntersection));
  });
  test("Rounding error", () {
    var lseg1 = new LineSegment(
        new Coordinate(2089426.5233462777, 1180182.3877339689),
        new Coordinate(2085646.6891757075, 1195618.7333999649));
    var lseg2 = new LineSegment(
        new Coordinate(1889281.8148903656,1997547.0560044837),
        new Coordinate(2259977.3672235999,483675.17050843034));
    var actualIntersection = segmentIntersection(lseg1, lseg2);
    expect(lseg1.envelope.intersectsCoordinate(actualIntersection), isTrue);
    expect(lseg2.envelope.intersectsCoordinate(actualIntersection), isTrue);
  });
}