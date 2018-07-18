library spatially.geom.factory_test;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';

main() {
  group("geometry factory", () {
    GeometryFactory geomFactory = new GeometryFactory();
    test("clone empty point", () {
      var p1 = geomFactory.createEmptyPoint();
      var clone1 = geomFactory.clone(p1);
      expect(clone1 is Point, isTrue);
      expect(identical(p1,clone1), isFalse);
      expect(clone1.isEmptyGeometry, isTrue);
    });

    test("clone point", () {
      var p2 = geomFactory.fromWkt("POINT (1 1)");
      var clone2 = geomFactory.clone(p2);
      expect(clone2 is Point, isTrue);
      expect(identical(p2, clone2), isFalse);
      expect(clone2.coordinate, new Coordinate(1,1));
    });

    test("clone empty linestring", () {
      var lstr1 = geomFactory.createEmptyLinestring();
      var clone1 = geomFactory.clone(lstr1);
      expect(clone1 is Linestring, isTrue);
      expect(clone1.isEmptyGeometry, isTrue);
      expect(identical(lstr1, clone1), isFalse);
    });

    test("clone linestring", () {
      var lstr2 = geomFactory.fromWkt("Linestring( 0 0, 1 1)");
      var clone2 = geomFactory.clone(lstr2);
      expect(clone2 is Linestring, isTrue);
      expect(clone2.coordinates, [new Coordinate(0,0), new Coordinate(1,1)]);
      expect(identical(clone2, lstr2), isFalse);
    });

    test("clone empty ring", () {
      var ring1 = geomFactory.createEmptyRing();
      var clone1 = geomFactory.clone(ring1);
      expect(clone1 is Ring, isTrue);
      expect(clone1.isEmptyGeometry, isTrue);
      expect(identical(ring1, clone1), isFalse);
    });

    test("clone empty polygon", () {
      var poly1 = geomFactory.createEmptyPolygon();
      var clone1 = geomFactory.clone(poly1);
      expect(clone1 is Polygon, isTrue);
      expect(clone1.isEmptyGeometry, isTrue);
      expect(identical(poly1, clone1), isFalse);
    });

    test("clone polygon", () {
      var poly2 = geomFactory.fromWkt("POLYGON((0 0, 1 0, 1 1, 0 0))");
      var clone2 = geomFactory.clone(poly2);
      expect(clone2 is Polygon, isTrue);
      expect(clone2.coordinates, [new Coordinate(0,0), new Coordinate(1,0), new Coordinate(1,1), new Coordinate(0,0)]);
      expect(identical(poly2, clone2), isFalse);
    });

    test("clone multipoint", () {
      var multipoint = geomFactory.fromWkt("Multipoint((0 0), (1 0), (1 1), (0 0))");
      var clone2 = geomFactory.clone(multipoint);
      expect(clone2 is MultiPoint, isTrue);
      expect(clone2.coordinates, [new Coordinate(0,0), new Coordinate(1,0), new Coordinate(1,1), new Coordinate(0,0)]);
      expect(identical(multipoint, clone2), isFalse);
    });
  });
}

