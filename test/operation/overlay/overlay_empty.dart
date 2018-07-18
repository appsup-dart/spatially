library spatially.operation.overlay.overlay_empty_tests;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/operation/overlay.dart';

main() {
  group("overlay: empty", () {
    GeometryFactory geomFactory = new GeometryFactory();
    test("empty points", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.createEmptyPoint();

      expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.createEmptyPoint(),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "sym difference");

    });
    test("empty point and empty linestring", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.createEmptyLinestring();

      expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.createEmptyLinestring(),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.createEmptyLinestring(),
          reason: "sym difference");
    });

    test("empty point and empty polygon", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.createEmptyPolygon();
      expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.createEmptyPolygon(),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.createEmptyPolygon(),
          reason: "sym difference");
    });

    test("empty point and nonempty point", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.fromWkt("POINT(1 1)");

      expect(
          overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(
          overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.fromWkt("POINT(1 1)"),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.fromWkt("POINT(1 1)"),
          reason: "sym difference");
    });

    test("empty point and nonempty linestring", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.fromWkt("LINESTRING (5 5, 6 6)");

      expect(
          overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(
          overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.fromWkt("LINESTRING(5 5, 6 6)"),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.fromWkt("LINESTRING(5 5, 6 6)"),
          reason: "sym difference");
    });

    test("empty point and empty multipoint", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.createEmptyMultiPoint();

      expect(
          overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(
          overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.createEmptyPoint(),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "sym difference");
    });

    test("empty point and empty multilinestring", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.createEmptyMultiLinestring();

      expect(
          overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(
          overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.createEmptyLinestring(),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.createEmptyLinestring(),
          reason: "sym difference");

    });

    test("empty point and nonempty multipoint", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.fromWkt("MULTIPOINT((2 2), (3 3))");

      expect(
          overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(
          overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.fromWkt("MULTIPOINT((2 2), (3 3))"),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.fromWkt("MULTIPOINT((2 2), (3 3))"),
          reason: "sym difference");
    });

    test("empty point and empty multipolygon", () {

      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.createEmptyMultiPolygon();
      expect(
          overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(
          overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.createEmptyPolygon(),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.createEmptyPolygon(),
          reason: "sym difference");
    });

    test("empty point and nonempty multipoint", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.fromWkt("MULTIPOINT((2 2),(3 3))");

      expect(
          overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(
          overlayGeometries(g1,g2, OVERLAY_UNION),
          geomFactory.fromWkt("MULTIPOINT((2 2),(3 3))"),
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          geomFactory.fromWkt("MULTIPOINT((2 2),(3 3))"),
          reason: "sym difference");
    });

    test("empty point and nonempty multilinestring", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.fromWkt(
          """ MULTILINESTRING((7 7, 8 8), (9 9, 10 10))
          """);
      expect(
          overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(
          overlayGeometries(g1,g2, OVERLAY_UNION),
          g2,
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          g2,
          reason: "sym difference");
    });

    test("empty point and nonempty multipolygon", () {
      var g1 = geomFactory.createEmptyPoint();
      var g2 = geomFactory.fromWkt(
          """MULTIPOLYGON (((50 50, 50 60, 60 60, 60 50, 50 50)),
                           ((70 70, 70 80, 80 80, 80 70, 70 70))
                          )
          """);

      expect(
          overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
          geomFactory.createEmptyPoint(),
          reason: "intersection");

      expect(
          overlayGeometries(g1,g2, OVERLAY_UNION),
          g2,
          reason: "union");

      expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
          geomFactory.createEmptyPoint(),
          reason: "difference");

      expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
          g2,
          reason: "sym difference");
    });

    //TODO: rest of empty geometries from JTS tests.
  });
}