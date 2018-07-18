library spatially.convert.wkt_tests.dart;

import 'package:test/test.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/convert/wkt.dart';

void main() {
  testEncode();
}

void testEncode() {
  group("convert:Encode", () {
    GeometryFactory geomFactory = new GeometryFactory();
    WktEncoder encoder = new WktEncoder();
    WktDecoder decoder = new WktDecoder(geomFactory);
    test("Empty point encoding", () {
      var p1 = geomFactory.createEmptyPoint();
      var wktPoint = "POINT EMPTY";
      expect(encoder.convert(p1), equals(wktPoint));
      expect(decoder.convert(wktPoint), equals(p1));
    });
    test("Point encoding", () {
      var p1 = geomFactory.createPoint(new Coordinate(100.0, 100.0));
      var wktPoint = "POINT (100.0 100.0)";
      expect(encoder.convert(p1), equals(wktPoint));
      expect(decoder.convert(wktPoint), equals(p1));
    });
    test("Empty linestring encoding", () {
      var lstr = geomFactory.createEmptyLinestring();
      var wktLstr = "LINESTRING EMPTY";
      expect(encoder.convert(lstr), equals(wktLstr));
      expect(decoder.convert(wktLstr), equals(lstr));
    });
    test("Linestring encoding", () {
      var p1 = geomFactory.createPoint(new Coordinate(100.0, 100.0));
      var p2 = geomFactory.createPoint(new Coordinate(200.0, 200.0));
      var lstr = geomFactory.createLinestring([p1.coordinate, p2.coordinate]);
      var wktLstr = "LINESTRING (100.0 100.0, 200.0 200.0)";
      expect(encoder.convert(lstr), equals(wktLstr));
      expect(decoder.convert(wktLstr), equals(lstr));
    });
    test("Empty ring encoding", () {
      var ring = geomFactory.createEmptyRing();
      var wktRing = "LINEARRING EMPTY";
      expect(encoder.convert(ring), equals(wktRing));
    });
    test("Ring encoding", () {
      var c1 = new Coordinate(100.0, 100.0);
      var c2 = new Coordinate(200.0, 200.0);
      var c3 = new Coordinate(200.0, 100.0);
      var ring = geomFactory.createRing([c1, c2, c3, c1]);
      var wktRing = "LINEARRING (100.0 100.0, 200.0 200.0, 200.0 100.0, 100.0 100.0)";
      expect(encoder.convert(ring), equals(wktRing));
    });
    test("Empty polygon encoding", () {
      var poly = geomFactory.createEmptyPolygon();
      var wktPoly = "POLYGON (EMPTY)";
      expect(encoder.convert(poly), equals(wktPoly));
      expect(decoder.convert(wktPoly), equals(poly));
    });
    test("Polygon encoding", () {
      var c1 = new Coordinate(100.0, 100.0);
      var c2 = new Coordinate(200.0, 200.0);
      var c3 = new Coordinate(200.0, 100.0);
      var shell = geomFactory.createRing([c1, c2, c3, c1]);
      var c4 = new Coordinate(125.0, 100.0);
      var c5 = new Coordinate(175.0, 150.0);
      var c6 = new Coordinate(150.0, 125.0);
      var h1 = geomFactory.createRing([c4, c5, c6, c4]);
      var poly = geomFactory.createPolygon(shell, [h1]);
      var wktPoly = "POLYGON ((100.0 100.0, 200.0 200.0, 200.0 100.0, 100.0 100.0), "
                             "(125.0 100.0, 175.0 150.0, 150.0 125.0, 125.0 100.0))";
      expect(encoder.convert(poly), equals(wktPoly));
      expect(decoder.convert(wktPoly), equals(poly));
    });
    test("Empty multipoint encoding", () {
      var mp = geomFactory.createEmptyMultiPoint();
      var wktmp = "MULTIPOINT EMPTY";
      expect(encoder.convert(mp), equals(wktmp));
    });
    test("Multipoint encoding", () {
      var p1 = geomFactory.createPoint(new Coordinate(100.0, 100.0));
      var p2 = geomFactory.createPoint(new Coordinate(200.0, 200.0));
      var mp = geomFactory.createMultiPoint([p1, p2]);
      var wktmp = "MULTIPOINT ((100.0 100.0), (200.0 200.0))";
      expect(encoder.convert(mp), equals(wktmp));
      expect(decoder.convert(wktmp), equals(mp));
    });
    test("MultiLinestring encoding", () {
      var p1 = geomFactory.createPoint(new Coordinate(100.0, 100.0));
      var p2 = geomFactory.createPoint(new Coordinate(200.0, 200.0));
      var lstr1 = geomFactory.createLinestring([p1.coordinate, p2.coordinate]);
      var p3 = geomFactory.createPoint(new Coordinate(100.0, 200.0));
      var p4 = geomFactory.createPoint(new Coordinate(200.0, 100.0));
      var lstr2 = geomFactory.createLinestring([p3.coordinate, p4.coordinate]);
      var mlstr = geomFactory.createMultiLinestring([lstr1, lstr2]);
      var wktMlstr = "MULTILINESTRING ((100.0 100.0, 200.0 200.0), (100.0 200.0, 200.0 100.0))";
      expect(encoder.convert(mlstr), equals(wktMlstr));
      expect(decoder.convert(wktMlstr), equals(mlstr));
    });
    test("MultiPolygon encoding", () {
      var c1 = new Coordinate(100.0, 100.0);
      var c2 = new Coordinate(200.0, 200.0);
      var c3 = new Coordinate(200.0, 100.0);
      var shell = geomFactory.createRing([c1, c2, c3, c1]);
      var c4 = new Coordinate(125.0, 100.0);
      var c5 = new Coordinate(175.0, 150.0);
      var c6 = new Coordinate(150.0, 125.0);
      var h1 = geomFactory.createRing([c4, c5, c6, c4]);
      var poly = geomFactory.createPolygon(shell, [h1]);
      var c7 = new Coordinate(0.0, 0.0);
      var c8 = new Coordinate(10.0, 10.0);
      var c9 = new Coordinate(0.0, 10.0);
      var poly2 = geomFactory.createPolygon(geomFactory.createRing([c7,c8,c9,c7]));
      var mpoly = geomFactory.createMultiPolygon([poly, poly2]);
      var wktMpoly = "MULTIPOLYGON (((100.0 100.0, 200.0 200.0, 200.0 100.0, 100.0 100.0), (125.0 100.0, 175.0 150.0, 150.0 125.0, 125.0 100.0)), "
                                   "((0.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0)))";
      expect(encoder.convert(mpoly), equals(wktMpoly));
      expect(decoder.convert(wktMpoly), equals(mpoly));
    });
    test("Empty geometry list encoding", () {
      var glist = geomFactory.createEmptyGeometryList();
      var wktGlist = "GEOMETRYCOLLECTION EMPTY";
      expect(encoder.convert(glist), equals(wktGlist));
      expect(decoder.convert(wktGlist), equals(glist));
    });
    test("Geometry collection encoding", () {
      var p = geomFactory.createPoint(new Coordinate(100.0, 100.0));
      var c1 = new Coordinate(0.0, 0.0);
      var c2 = new Coordinate(10.0, 10.0);
      var c3 = new Coordinate(0.0, 10.0);
      var poly2 = geomFactory.createPolygon(geomFactory.createRing([c1,c2,c3,c1]));
      var p1 = geomFactory.createPoint(new Coordinate(100.0, 100.0));
      var p2 = geomFactory.createPoint(new Coordinate(200.0, 200.0));
      var mp = geomFactory.createMultiPoint([p1, p2]);
      var geomList = geomFactory.createGeometryList([p, poly2, mp]);
      var wktGeomList = "GEOMETRYCOLLECTION (POINT (100.0 100.0), "
                                            "POLYGON ((0.0 0.0, 10.0 10.0, 0.0 10.0, 0.0 0.0)), "
                                            "MULTIPOINT ((100.0 100.0), (200.0 200.0)))";
      expect(encoder.convert(geomList), equals(wktGeomList));
      expect(decoder.convert(wktGeomList), equals(geomList));
    });
  });
}