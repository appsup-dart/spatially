library spatially.operation.overlay.linestring_test;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/operation/overlay.dart';

void main() {
  group('linestring &', () {
    GeometryFactory geomFactory = new GeometryFactory();
    group('linestring:', () {
      test("two empty linestrings", () {
        var g1 = geomFactory.fromWkt("LINESTRING EMPTY");
        var g2 = geomFactory.fromWkt("LINESTRING EMPTY");

        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
            geomFactory.createEmptyLinestring(),
            reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
               geomFactory.createEmptyLinestring(),
               reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
               geomFactory.createEmptyLinestring(),
               reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
               geomFactory.createEmptyLinestring(),
               reason: "symmetric difference");
      });

      test("non-empty linestring and empty linestring", () {
        var g1 = geomFactory.fromWkt("LINESTRING (0 0, 1 1)");
        var g2 = geomFactory.fromWkt("LINESTRING EMPTY");

        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
            geomFactory.createEmptyLinestring(),
            reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
               geomFactory.fromWkt("LINESTRING(0 0, 1 1)"),
               reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
               geomFactory.fromWkt("LINESTRING(0 0, 1 1)"),
               reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
               geomFactory.fromWkt("LINESTRING(0 0, 1 1)"),
               reason: "symmetric difference");
      });

      test("empty linestring and nonempty linestring", () {
        var g1 = geomFactory.fromWkt("LINESTRING (0 0, 1 1)");
        var g2 = geomFactory.fromWkt("LINESTRING EMPTY");

        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
            geomFactory.createEmptyLinestring(),
            reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
               geomFactory.fromWkt("LINESTRING(0 0, 1 1)"),
               reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
               geomFactory.fromWkt("LINESTRING(0 0, 1 1)"),
               reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
               geomFactory.fromWkt("LINESTRING(0 0, 1 1)"),
               reason: "symmetric difference");
      });

      test("non intersecting (single segment) linestrings", () {
        var g1 = geomFactory.fromWkt("LINESTRING(0 0, 1 0)");
        var g2 = geomFactory.fromWkt("LINESTRING(1 0, 0 1)");

        expect(overlayGeometries(g1,g2, OVERLAY_INTERSECTION),
            geomFactory.createEmptyLinestring(),
            reason: "intersection");

        expect(overlayGeometries(g1,g2, OVERLAY_UNION),
               geomFactory.fromWkt("MULTILINESTRING((0 0, 1 0), (1 0, 0 1)"),
               reason: "union");

        expect(overlayGeometries(g1,g2, OVERLAY_DIFFERENCE),
               geomFactory.createEmptyLinestring(),
               reason: "difference");

        expect(overlayGeometries(g1,g2, OVERLAY_SYMMETRIC_DIFFERENCE),
               geomFactory.fromWkt("MULTILINESTRING((0 0, 1 0), (1 0, 0 1)"),
               reason: "symmetric difference");
      });


    });

    group('polygon:', () {

    });
  });

}