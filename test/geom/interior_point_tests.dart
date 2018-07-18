library spatially.geom.interior_point_tests.dart;
import 'package:test/test.dart';
import 'package:spatially/geom/base.dart';

void main() {
  testInteriorPoint();
}


void testInteriorPoint() {
  GeometryFactory geomFactory = new GeometryFactory();
  group("interior point: ", () {
    group("point: ", () {
      test("empty", () {
        var p = geomFactory.createEmptyPoint();
        expect(p.interiorPoint, equals(p));
      });
      test("non-empty point", () {
        var p = geomFactory.fromWkt("POINT(10 10)");
        expect(p.interiorPoint, equals(p));
      });
    });
    group("multipoint: ", () {
      test("non-empty", () {
        var mp = geomFactory.fromWkt(
            "MULTIPOINT ((60 300), (200 200), (240 240), "
                        "(200 300), (40 140), (80 240), "
                        "(140 240), (100 160), (140 200), (60 200))");
        expect(mp.interiorPoint, equals(geomFactory.fromWkt("POINT(140 240)")));
      });
    });
    group("linestring: ", () {
      test("single segment", () {
        var lstr = geomFactory.fromWkt("LINESTRING(0 0, 7 14)");
        var interior_point = geomFactory.fromWkt("POINT(7 14)");
        expect(lstr.interiorPoint, equals(interior_point));
      });
      test("multiple segments", () {
        var lstr = geomFactory.fromWkt(
            "LINESTRING(0 0, 3 15, 6 2, 11 14, 16 5, 16 18, 2 22)");
        var interior_point = geomFactory.fromWkt("POINT(11 14)");
        expect(lstr.interiorPoint, equals(interior_point));
      });
    });
    group("multilinestring: ", () {
      test("complex linestrings", () {
        var multilstr = geomFactory.fromWkt(
            """
            MULTILINESTRING ((60 240, 140 300, 180 200, 40 140, 100 100, 120 220), 
                             (240 80, 260 160, 200 240, 180 340, 280 340, 240 180, 180 140, 40 200, 140 260))
            """);
        var interior_point = geomFactory.fromWkt("POINT(180 200)");
        expect(multilstr.interiorPoint, equals(interior_point));
      });
    });
    group("polygon: ", () {
      test("empty", () {
        var poly = geomFactory.createEmptyPolygon();
        expect(poly.interiorPoint, equals(geomFactory.createEmptyPoint()));
      });
      test("box", () {
        var poly = geomFactory.fromWkt("polygon((0 0, 0 10, 10 10, 10 0, 0 0))");
        var interior_point = geomFactory.fromWkt("POINT(5 5)");
        expect(poly.interiorPoint, equals(interior_point));
      });

    });
    group("multipolygon: ", () {
        test("polygons with holes", () {
          var multipoly = geomFactory.fromWkt(
             """
              MULTIPOLYGON (
                ( (60 320, 240 340, 260 100, 20 60, 120 180, 60 320), 
                  (200 280, 140 260, 180 160, 240 140, 200 280)), 
                ( (380 280, 300 260, 340 100, 440 80, 380 280), 
                  (380 220, 340 200, 400 100, 380 220)))
             """);
          var interior_point = geomFactory.fromWkt("POINT(138 200)");
          expect(multipoly.interiorPoint, equals(interior_point));
        });
    });
    group("geometrylist: ", () {

    });
  });
}