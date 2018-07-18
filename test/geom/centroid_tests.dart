library spatially.geom.centroid_tests;

import 'package:test/test.dart';
import 'package:spatially/geom/base.dart';

void main() {
  testCentroid();
}

void testCentroid() {
  GeometryFactory geomFactory = new GeometryFactory();
  group("centroid: ", () {
    group("point: ", () {
      test("empty point", () {
        var p = geomFactory.createEmptyPoint();
        expect(() => p.centroid, throwsA(new isInstanceOf<StateError>()));
      });
      test("non-empty point", () {
        var p = geomFactory.fromWkt("POINT(10.0 10.0)");
        expect(p.centroid, equals(p));
      });
    });
    group("multipoint: ", () {
      test("two points", () {
        var mp = geomFactory.fromWkt("MULTIPOINT((10.0 10.0), (20.0 20.0))");
        var centroid = geomFactory.fromWkt("POINT(15.0 15.0)");
        expect(mp.centroid, equals(centroid));
      });
      test("four points", () {
        var mp = geomFactory.fromWkt("MULTIPOINT((10 10), (20 20), (10 20), (20 10))");
        var centroid = geomFactory.fromWkt("POINT(15 15)");
        expect(mp.centroid, equals(centroid));
      });
    });
    group("linestring: ", () {
      test("single segment", () {
        var lstr = geomFactory.fromWkt("LINESTRING(10 10, 20 20)");
        var centroid = geomFactory.fromWkt("POiNT(15 15)");
        expect(lstr.centroid, equals(centroid));
      });
      test("two segments", () {
        var lstr = geomFactory.fromWkt("LINESTRING(60 180, 120 100, 180 180)");
        var centroid = geomFactory.fromWkt("POINT (120 140)");
        expect(lstr.centroid, equals(centroid));
      });
      test("horseshoe", () {
        var lstr = geomFactory.fromWkt("LINESTRING (80 0, 80 120, 120 120, 120 0))");
        var centroid = geomFactory.fromWkt("POINT (100 68.57142857142857)");
      });
      group("multilinestring: ", () {
        test("two single-segment lines", () {
          var multilstr = geomFactory.fromWkt("MULTILINESTRING ((0 0, 0 100), (100 0, 100 100))");
          var centroid = geomFactory.fromWkt("POINT(50 50)");
          expect(multilstr.centroid, equals(centroid));
        });
        test("two concentroid rings, offset", () {
          var multilstr = geomFactory.fromWkt(
              """MULTILINESTRING ((0 0, 0 200, 200 200, 200 0, 0 0), 
                                  (60 180, 20 180, 20 140, 60 140, 60 180))
              """);
          var centroid = geomFactory.fromWkt("POINT (90 110)");
          expect(multilstr.centroid, equals(centroid));
        });
        test("complicated symmetrical collection of lines", () {
          var multilstr = geomFactory.fromWkt(
              """
              MULTILINESTRING ( (20 20, 60 60), 
                                (20 -20, 60 -60), 
                                (-20 -20, -60 -60), 
                                (-20 20, -60 60), 
                                (-80 0, 0 80, 80 0, 0 -80, -80 0), 
                                (-40 20, -40 -20), 
                                (-20 40, 20 40), 
                                (40 20, 40 -20), 
                                (20 -40, -20 -40))
              """);
          var centroid = geomFactory.fromWkt("POINT (0 0)");
          expect(multilstr.centroid, equals(centroid));
        });
      });
      group("polygon: ", () {
        test("box", () {
          var poly = geomFactory.fromWkt("POLYGON ((40 160, 160 160, 160 40, 40 40, 40 160))");
          var centroid = geomFactory.fromWkt("POINT (100 100)");
          expect(poly.centroid, equals(centroid));
        });
        test("box with a hole", () {
          var poly = geomFactory.fromWkt(
              """POLYGON ((0 200, 200 200, 200 0, 0 0, 0 200), 
                          (20 180, 80 180, 80 20, 20 20, 20 180))
              """);
          var centroid = geomFactory.fromWkt("POINT (115.78947368421052 100)");
          expect(poly.centroid, equals(centroid));
        });
        test("box with offset hole (showing difference between area and line centroid)", () {
          var poly = geomFactory.fromWkt(
              """POLYGON ((0 0, 0 200, 200 200, 200 0, 0 0), 
                          (60 180, 20 180, 20 140, 60 140, 60 180))
              """);
              var centroid = geomFactory.fromWkt("POINT (102.5 97.5)");
          expect(poly.centroid, equals(centroid));

        });
        test("box with 2 symmetric holes", () {
          var poly = geomFactory.fromWkt(
              """POLYGON ((0 0, 0 200, 200 200, 200 0, 0 0), 
                          (60 180, 20 180, 20 140, 60 140, 60 180), 
                          (180 60, 140 60, 140 20, 180 20, 180 60))
              """);
          var centroid = geomFactory.fromWkt("POINT (100 100)");
          expect(poly.centroid, equals(centroid));

        });
        test("degenerate box", () {
          var poly = geomFactory.fromWkt("POLYGON ((40 160, 160 160, 160 160, 40 160, 40 160))");
          expect(() => poly.centroid, throwsA(new isInstanceOf<StateError>()));
        });
        test("degenerate triangle", () {
          var poly = geomFactory.fromWkt("POLYGON ((10 10, 100 100, 100 100, 10 10))");
          expect(() => poly.centroid, throwsA(new isInstanceOf<StateError>()));
        });
        test("empty", () {
          var poly = geomFactory.fromWkt("POLYGON EMPTY");
          var centroid = geomFactory.fromWkt("POINT EMPTY");
          expect(() => poly.centroid, throwsA(new isInstanceOf<StateError>()));

        });
        test("almost degenerate triangle", () {
          var poly = geomFactory.fromWkt(
              """POLYGON((56.528666666700 25.2101666667,
                          56.529000000000 25.2105000000,
                          56.528833333300 25.2103333333,
                          56.528666666700 25.2101666667))
              """);
          var centroid = geomFactory.fromWkt("POINT (56.52883333333333 25.210333333333335)");
          expect(poly.centroid, equals(centroid));

        });
      });
      group("multipolygon: ", () {
        test("symmetric angles", () {
          var multipolygon = geomFactory.fromWkt(
              """MULTIPOLYGON (((0 40, 0 140, 140 140, 140 120, 20 120, 20 40, 0 40)), 
                               ((0 0, 0 20, 120 20, 120 100, 140 100, 140 0, 0 0))) 
              """);
          var centroid = geomFactory.fromWkt("POINT (70 70)");
          expect(multipolygon.centroid, equals(centroid));
        });
      });
      group("geometrylist: ", () {
        test("two adjacent polygons (showing that centroids are additive) ", () {
          var geomList = geomFactory.fromWkt(
              """GEOMETRYCOLLECTION (POLYGON ((0 200, 20 180, 20 140, 60 140, 200 0, 0 0, 0 200)), 
                                     POLYGON ((200 200, 0 200, 20 180, 60 180, 60 140, 200 0, 200 200)))
              """);
          var centroid = geomFactory.fromWkt("POINT (102.5 97.5)");
          expect(geomList.centroid, equals(centroid));
        });
        test("", () {
          var geomList = geomFactory.fromWkt(
              """GEOMETRYCOLLECTION (LINESTRING (80 0, 80 120, 120 120, 120 0), 
                                     MULTIPOINT ((20 60), (40 80), (60 60)))
              """);
          var centroid = geomFactory.fromWkt("POINT (100 68.57142857142857)");
          expect(geomList.centroid, equals(centroid));
        });
        test(" heterogeneous collection of polygons, line", () {
          var geomList = geomFactory.fromWkt(
              """ GEOMETRYCOLLECTION (POLYGON ((0 40, 40 40, 40 0, 0 0, 0 40)), 
                                      LINESTRING (80 0, 80 80, 120 40))
              """);
          var centroid = geomFactory.fromWkt("POINT (20 20)");
          expect(geomList.centroid, equals(centroid));
        });
        test("heterogeneous collection of polygons, lines, points", () {
            var geomList = geomFactory.fromWkt(
              """GEOMETRYCOLLECTION (POLYGON ((0 40, 40 40, 40 0, 0 0, 0 40)), 
                                     LINESTRING (80 0, 80 80, 120 40), 
                                     MULTIPOINT ((20 60), (40 80), (60 60)))
              """);
          var centroid = geomFactory.fromWkt("POINT (20 20)");
          expect(geomList.centroid, equals(centroid));

        });
        test("overlapping polygons", () {
            var geomList = geomFactory.fromWkt(
              """GEOMETRYCOLLECTION (POLYGON ((20 100, 20 -20, 60 -20, 60 100, 20 100)), 
                                     POLYGON ((-20 60, 100 60, 100 20, -20 20, -20 60)))
              """);
         var centroid = geomFactory.fromWkt(" POINT (40 40)");
         expect(geomList.centroid, equals(centroid));

        });

      });
    });
  });
}