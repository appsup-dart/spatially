library spatially.geom.boundary_tests;

import 'package:spatially/geom/base.dart';
import 'package:test/test.dart';

final GeometryFactory factory = new GeometryFactory();

void main() {
  testBoundary();
}
void testBoundary() {
  group("boundary", () {
    test("Point boundary", () {
      var p = factory.fromWkt("POINT(10.0 10.0)");
      expect(p.boundary, factory.createEmptyGeometryList());
    });
    test("Multipoint boundary", () {
      var multipoint = factory.fromWkt("MULTIPOINT((10.0 10.0), (20.0 20.0))");
      expect(multipoint.boundary, factory.createEmptyGeometryList());
    });
    test("Line boundary -- not closed", () {
      var lstr = factory.fromWkt("LINESTRING(10.0 10.0, 20.0 20.0)");
      var boundary = factory.fromWkt("MULTIPOINT((10.0 10.0), (20.0 20.0))");
      expect(lstr.boundary, equals(boundary));
    });
  test("Line boundary -- closed", () {
      final lstr =
          factory.fromWkt("LINESTRING(10.0 10.0, 20.0 20.0, 20.0 10.0, 10.0 10.0)");
      expect(lstr.boundary, equals(factory.createEmptyMultiPoint()));
    });
    test("self intersecting with boundary", () {
      final lstr = factory.fromWkt(
          "LINESTRING(40 40, 100 100, 180 100, 180 180, 100 180, 100 100)");
      final boundary = factory.fromWkt(
          "MULTIPOINT((40 40), (100 100))");
      expect(lstr.boundary, equals(boundary));
    });
    test("multi-linestring - two lines with common endpoint", () {
      var multilstr = factory.fromWkt(
          "MULTILINESTRING( (10 10, 20 20), (20 20, 30 30))");
      var boundary = factory.fromWkt(
          "MULTIPOINT((10 10), (30 30))");
      expect(multilstr.boundary, equals(boundary));

    });
    test("multilinestring - three lines with common endpoint", () {
      var multilstr = factory.fromWkt(
          "multilinestring( (10 10, 20 20), "
                          " (20 20, 30 20), "
                          " (20 20, 30 30) )");
      var boundary = factory.fromWkt(
          "multipoint((10 10), (20 20), (30 20), (30 30))");
      expect(multilstr.boundary, equals(boundary));
    });
    test("multilinestring - four lines with common endpoint", () {
      var multilinestring = factory.fromWkt(
          "multilinestring( (10 10, 20 20), "
                          " (20 20, 30 20), "
                          " (20 20, 30 30), "
                          " (20 20, 30 40))");
      var boundary = factory.fromWkt(
          "multipoint((10 10), (30 20), (30 30), (30 40))");
      expect(multilinestring.boundary, equals(boundary));
    });
    test("two lines, one closed, with common endpoint", () {
      var multilinestring = factory.fromWkt(
          "multilinestring( (10 10, 20 20), "
                          " (20 20, 20 30, 30 30, 30 20, 20 20))");
      var boundary = factory.fromWkt(
          "multipoint((10 10), (20 20))");
      expect(multilinestring.boundary, equals(boundary));
    });
    test("1 line, self intersecting, topologically equal to previous case", () {
      var multilinestring = factory.fromWkt(
          "multilinestring((10 10, 20 20, 20 30, 30 30, 30 20, 20 20))");
      var boundary = factory.fromWkt(
          "multipoint((10 10), (20 20))");
      expect(multilinestring.boundary, equals(boundary));
    });
    test("Polygon with no holes", () {
      var poly = factory.fromWkt(
          "polygon((40 60, 420 60, 420 430, 40 320, 40 60))");
      var boundary = factory.fromWkt(
          "linestring(40 60, 420 60, 420 430, 40 320, 40 60)");
      expect(poly.boundary, equals(boundary));
    });
    test("polygon with 1 hole", () {
      var poly = factory.fromWkt(
          "polygon((40 60, 420 60, 420 320, 40 320, 40 60), "
                 " (200 140, 160 220, 260 200, 200 140))");
      var boundary = factory.fromWkt(
          "multilinestring( "
              "(40 60, 420 60, 420 320, 40 320, 40 60), "
              "(200 140, 160 220, 260 200, 200 140))");
      expect(poly.boundary, equals(boundary));
    });
  });
}

