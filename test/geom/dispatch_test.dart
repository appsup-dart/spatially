library spatially.geom.dispatch_test;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';

main() {
  group("dispatch", () {
    GeometryFactory geomFactory = new GeometryFactory();
    testDispatch(Geometry geom) {
      return Geometry.dispatchToType(geom,
          applyPoint: (p) => p.coordinate,
          applyLinestring: (lstr) => lstr.coordinates,
          applyPolygon: (poly) => poly.exteriorRing);
    }

    test("should dispatch to a point", () {
      var p = geomFactory.fromWkt("POINT(0 0)");
      expect(testDispatch(p), new Coordinate(0,0));
    });
    test("should dispatch to a linestring", () {
      var lstr = geomFactory.fromWkt("LINESTRING(0 0, 1 1, 1 0)");
      expect(testDispatch(lstr), [new Coordinate(0,0), new Coordinate(1,1), new Coordinate(1,0)]);
    });
    test("should dispatch to a polygon", () {
      var poly = geomFactory.fromWkt("POLYGON((0 0, 1 0, 1 1, 0 0))");
      expect(testDispatch(poly), geomFactory.fromWkt("LINEARRING(0 0, 1 0, 1 1, 0 0)"));
    });
    test("should dispatch to the components of a multipoint", () {
      var mpoint = geomFactory.fromWkt("MULTIPOINT((0 0), (1 0))");
      expect(testDispatch(mpoint), [new Coordinate(0,0), new Coordinate(1,0)]);
    });
    test("should dispatch to the components of a multilinestring", () {
      var mlstr = geomFactory.fromWkt("MULTILINESTRING((0 0, 1 1, 1 0), (1 0, 0 1))");
      expect(testDispatch(mlstr),
             [ [new Coordinate(0, 0), new Coordinate(1,1), new Coordinate(1,0)],
               [new Coordinate(1, 0), new Coordinate(0,1)]
             ]);
    });
    test("should dispatch to the components of a multipolygon", () {
      var mpoly = geomFactory.fromWkt("MULTIPOLYGON(((0 0, 1 0, 1 1, 0 0)))");
      expect(testDispatch(mpoly), [geomFactory.fromWkt("LINEARRING(0 0, 1 0, 1 1, 0 0)")]);
    });

  });
}