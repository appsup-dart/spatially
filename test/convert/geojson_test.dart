library spatially.convert.geojson_test;

import 'dart:convert';
import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/convert/geojson.dart';

main() {
  group("geojson", () {
    testEncode();
    testDecode();
  });

}

void testEncode() {
  group("encode", () {
    GeometryFactory geomFactory = new GeometryFactory();
    Codec codec = new GeoJsonCodec(geomFactory);
    test("a point", () {
      var p = geomFactory.fromWkt("POINT(0 0)");
      expect(codec.encode(p), '{"type":"Point","coordinates":[0.0,0.0]}');
    });

    test("a point with non-zero z coordinate", () {
      var p = geomFactory.createPoint(new Coordinate(0,0,1));
      expect(codec.encode(p), '{"type":"Point","coordinates":[0.0,0.0,1.0]}');
    });

    test("a point with nonzero m coordinate", () {
      var p = geomFactory.createPoint(new Coordinate(0,0,1,1));
      expect(codec.encode(p), '{"type":"Point","coordinates":[0.0,0.0,1.0,1.0]}');
    });

    test("a linestring", () {
      var lstr = geomFactory.fromWkt("LInESTRING(0 0, 1 1)");
      expect(codec.encode(lstr), '{"type":"LineString","coordinates":[[0.0,0.0],[1.0,1.0]]}');
    });

    test("a polygon", () {
      var poly = geomFactory.fromWkt("""
        POLYGON((0 0, 3 0, 3 3, 0 3, 0 0),
                (1 1, 2 1, 2 2, 1 2, 1 1))
        """);
      expect(codec.encode(poly),
        '{"type":"Polygon","coordinates":['
            '[[0.0,0.0],[3.0,0.0],[3.0,3.0],[0.0,3.0],[0.0,0.0]],'
            '[[1.0,1.0],[2.0,1.0],[2.0,2.0],[1.0,2.0],[1.0,1.0]]'
        ']}');
    });
    test("a  multipoint", () {
      var mpoint = geomFactory.fromWkt(
          "MULTIPOINT((0 0),(1 1))");
      expect(codec.encode(mpoint),
          '{"type":"MultiPoint","coordinates":[[0.0,0.0],[1.0,1.0]]}');
    });
    test("a multilinestring", () {
      var mlstr = geomFactory.fromWkt(
          "MULTILINESTRING((0 0, 1 1, 1 0), (-1 -1, 0 0))");
      expect(codec.encode(mlstr),
          '{"type":"MultiLineString","coordinates":['
            '[[0.0,0.0],[1.0,1.0],[1.0,0.0]],'
            '[[-1.0,-1.0],[0.0,0.0]]'
          ']}');
    });

    test("a multipolygon", () {
      var mpoly = geomFactory.fromWkt(
          """
            MULTIPOLYGON(((0 0, 1 0, 1 1, 0 1, 0 0)), 
                         ((1 1, 2 1, 2 2, 1 2, 1 1)))
          """);
      expect(codec.encode(mpoly),
          '{"type":"MultiPolygon","coordinates":['
            '[[[0.0,0.0],[1.0,0.0],[1.0,1.0],[0.0,1.0],[0.0,0.0]]],'
            '[[[1.0,1.0],[2.0,1.0],[2.0,2.0],[1.0,2.0],[1.0,1.0]]]'
          ']}');
    });
    test("a geometrylist", () {
      var glist = geomFactory.fromWkt(
      "GEOMETRYCOLLECTION(POINT(0 0),LINESTRING(0 0, 1 1))");
      expect(codec.encode(glist),
          '{"type":"GeometryCollection","geometries":['
          '{"type":"Point","coordinates":[0.0,0.0]},'
          '{"type":"LineString","coordinates":[[0.0,0.0],[1.0,1.0]]}'
      ']}');
    });
  });
}

void testDecode() {
  group("decode", () {
    GeometryFactory geomFactory = new GeometryFactory();
    Codec codec = new GeoJsonCodec(geomFactory);
    test("a point", () {
      var p = geomFactory.fromWkt("POINT(0 0)");
      var json = '{"type":"Point","coordinates":[0.0,0.0]}';
      expect(codec.decode(json), p);
    });

    test("a point with non-zero z coordinate", () {
      var p = geomFactory.createPoint(new Coordinate(0,0,1));
      var json = '{"type":"Point","coordinates":[0.0,0.0,1.0]}';
      expect(codec.decode(json), p);
    });

    test("a point with nonzer m coordinate", () {
      var p = geomFactory.createPoint(new Coordinate(0,0,1,1));
      var json = '{"type":"Point","coordinates":[0.0,0.0,1.0,1.0]}';
      expect(codec.decode(json), p);
    });

    test("a linestring", () {
      var lstr = geomFactory.fromWkt("LInESTRING(0 0, 1 1)");
      var json = '{"type":"LineString","coordinates":[[0.0,0.0],[1.0,1.0]]}';
      expect(codec.decode(json), lstr);
    });

    test("a polygon", () {
      var poly = geomFactory.fromWkt("""
        POLYGON((0 0, 3 0, 3 3, 0 3, 0 0),
                (1 1, 2 1, 2 2, 1 2, 1 1))
        """);
      var json =
          '{"type":"Polygon","coordinates":['
            '[[0.0,0.0],[3.0,0.0],[3.0,3.0],[0.0,3.0],[0.0,0.0]],'
            '[[1.0,1.0],[2.0,1.0],[2.0,2.0],[1.0,2.0],[1.0,1.0]]'
          ']}';
      expect(codec.decode(json), poly);
    });
    test("a multipoint", () {
      var mpoint = geomFactory.fromWkt("MULTIPOINT((0 0),(1 1))");
      var json = '{"type":"MultiPoint","coordinates":[[0.0,0.0],[1.0,1.0]]}';
      expect(codec.decode(json), mpoint);
    });
    test("a multilinestring", () {
      var mlstr = geomFactory.fromWkt("MULTILINESTRING((0 0, 1 1, 1 0), (-1 -1, 0 0))");
      var json =
        '{"type":"MultiLineString","coordinates":['
          '[[0.0,0.0],[1.0,1.0],[1.0,0.0]],'
          '[[-1.0,-1.0],[0.0,0.0]]'
        ']}';

      expect(codec.decode(json), mlstr);
    });

    test("a multipolygon", () {
      var mpoly = geomFactory.fromWkt(
          """
            MULTIPOLYGON(((0 0, 1 0, 1 1, 0 1, 0 0)), 
                         ((1 1, 2 1, 2 2, 1 2, 1 1)))
          """);
      var json =
          '{"type":"MultiPolygon","coordinates":['
            '[[[0.0,0.0],[1.0,0.0],[1.0,1.0],[0.0,1.0],[0.0,0.0]]],'
            '[[[1.0,1.0],[2.0,1.0],[2.0,2.0],[1.0,2.0],[1.0,1.0]]]'
          ']}';

      expect(codec.decode(json), mpoly);
    });
    test("a geometrylist", () {
      var glist = geomFactory.fromWkt("GEOMETRYCOLLECTION(POINT(0 0),LINESTRING(0 0, 1 1))");
      var json =
          '{"type":"GeometryCollection","geometries":['
              '{"type":"Point","coordinates":[0.0,0.0]},'
              '{"type":"LineString","coordinates":[[0.0,0.0],[1.0,1.0]]}'
          ']}';
      expect(codec.decode(json), glist);
    });

  });

}