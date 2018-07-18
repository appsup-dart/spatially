library spatially.operation.overlay.intersection;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/operation/overlay.dart';

void main() {
  group('point &', () {
    GeometryFactory geomFactory = new GeometryFactory();
    group("point:", () {
      test("POINT EMPTY, POINT EMPTY", () {
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
               reason: "symmetric difference");
      });

      test("POINT EMPTY, POINT(0 0)", () {
        var g1 = geomFactory.createEmptyPoint();
        var g2 = geomFactory.fromWkt("POINT (0 0)");

        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
            geomFactory.createEmptyPoint(),
            reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
               g2,
               reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
               geomFactory.createEmptyPoint(),
               reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
              g2,
               reason: "symmetric difference");

      });

      test("POINT (0,0), POINT EMPTY", () {
        var g1 = geomFactory.fromWkt("POINT (0 0)");
        var g2 = geomFactory.createEmptyPoint();

        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
            geomFactory.createEmptyPoint(),
            reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
               g1,
               reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
               g1,
               reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
              g1,
               reason: "symmetric difference");

      });

      test("POINT(1 1), POINT(0 0)", () {
        var g1 = geomFactory.fromWkt("POINT(1 1)");
        var g2 = geomFactory.fromWkt("POINT(0 0)");

        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
               geomFactory.createEmptyPoint(),
               reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
               unorderedEquals(geomFactory.fromWkt("MULTIPOINT((0 0), (1 1))") as MultiPoint),
               reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
               g1,
               reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
               unorderedEquals(geomFactory.fromWkt("MULTIPOINT((0 0),(1 1))") as MultiPoint),
               reason: "symmetric difference");
      });

      test("POINT(0 0), POINT(0 0)", () {
        var g1 = geomFactory.fromWkt("POINT(0 0)");
        var g2 = geomFactory.fromWkt("POINT(0 0)");

        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
              g1,
              reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
               g1,
               reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
               geomFactory.createEmptyPoint(),
               reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
               geomFactory.createEmptyPoint(),
               reason: "symmetric difference");
      });
    });
    group("linestring:", () {
      test("POINT EMPTY, LINESTRING EMPTY", () {
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
            reason: "symmetric difference");
      });

      test("POINT (1 1), Linestring(0 0, 1 0)", () {
        var g1 = geomFactory.fromWkt("POINT(1 1)");
        var g2 = geomFactory.fromWkt("LINESTRING(0 0, 1 0)");
        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
            geomFactory.createEmptyPoint(),
            reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
            geomFactory.fromWkt("LINESTRING(0 0, 1 0)"),
            reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
            g1,
            reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
            geomFactory.fromWkt("LINESTRING(0 0, 1 0)"),
            reason: "symmetric difference");
      });

      test("POINT(1 1), LINESTRING(0 0, 1 1)", () {
        var g1 = geomFactory.fromWkt("POInT(1 1)");
        var g2 = geomFactory.fromWkt("LINESTRING(0 0, 1 1)");
        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
               g1,
               reason: "intersection");
        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
            geomFactory.fromWkt("LINESTRING(0 0, 1 1)"),
            reason: "union");

        expect(overlayGeometries(g1, g2, OVERLAY_DIFFERENCE),
               geomFactory.createEmptyPoint(),
               reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
            geomFactory.fromWkt("LINESTRING(0 0, 1 1)"),
            reason: "symmetric difference");

      });
    });

    group("polygon:", () {
      //No intersection
      test("POINT(-1 0), Polygon(0 0, 1 0, 1 1, 0 1, 0 0)", () {
        var g1 = geomFactory.fromWkt("POINT(-1 0)");
        var g2 = geomFactory.fromWkt("POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))");
        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
            geomFactory.createEmptyPoint(),
            reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
            geomFactory.fromWkt("POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))"),
            reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
            g1,
            reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
            geomFactory.fromWkt("POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))"),
            reason: "symmetric difference");
      });
    });

  });
}