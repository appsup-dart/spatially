library spatially.geomgraph.geometry_graph.add_test;

import 'package:collection/equality.dart';

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/base/tuple.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/geomgraph/location.dart';
import 'package:spatially/geomgraph/geometry_graph.dart';

UnorderedIterableEquality<List> iterEq =
    new UnorderedIterableEquality<List>(new ListEquality());

main() {
  group("add geometries:", () {
    GeometryFactory geomFactory = new GeometryFactory();
    test("should be able to add an empty point to a geometry graph", () {

      var p1 = geomFactory.createEmptyPoint();
      GeometryGraph graph = new GeometryGraph(p1, p1);
      graph.addPoint(p1);
      expect(graph.nodes, isEmpty);
      expect(graph.edges, isEmpty);

      var p2 = geomFactory.fromWkt("POINT(0 0)");
      expect(() => graph.addPoint(p2), throws,
             reason: "p2 is not one of the geometries of the graph");
    });

    test("should be able to add non-empty points to a geometry graph", () {
      var p1 = geomFactory.fromWkt("Point(0 0)");
      var p2 = geomFactory.fromWkt("Point(1 1)");

      GeometryGraph graph = new GeometryGraph(p1, p2);
      graph.addPoint(p1);
      expect(graph.nodes.first.coordinate, new Coordinate(0.0,0.0));
      expect(graph.nodes.first.locations,
             new Tuple( new Location(p1, on: loc.INTERIOR),
                        new Location(p2, on: loc.EXTERIOR)));
      graph.addPoint(p2);
      expect((graph.nodes.map((n) => n.coordinate)),
             unorderedEquals(
                 [ new Coordinate(0.0,0.0),
                   new Coordinate(1.0, 1.0)
                 ]));
    });

    test("should be able to add an empty linestring to the graph", () {
      var lstr = geomFactory.createEmptyLinestring();
      GeometryGraph g = new GeometryGraph(lstr, null);
      g.addLinestring(lstr);
      expect(g.nodes, isEmpty);
      expect(g.edges, isEmpty);

      var lstr2 = geomFactory.fromWkt("Linestring ( 0 0, 0 0 )");
      expect(() => g.addLinestring(lstr2), throws,
             reason: "lstr2 is not one of the graph geometries");
    });
    test("should be able to add a non-empty linestring to the graph", () {
      var lstr1 = geomFactory.fromWkt("Linestring ( 0 0, 1 1, 1 0)");
      var lstr2 = geomFactory.fromWkt("Linestring ( 0 0, -1 -1, 0 -1)");
      GeometryGraph g = new GeometryGraph(lstr1, lstr2);
      g.addLinestring(lstr1);
      expect(g.edges.first.coordinates,
             unorderedEquals(
                 [ new Coordinate(0,0),
                   new Coordinate(1,1),
                   new Coordinate(1,0)
                 ]));

      //The location datas are correct.
      expect(g.nodes.map((n) => n.locations),
             unorderedEquals([
                new Tuple(new Location(lstr1, on: loc.BOUNDARY),
                          new Location(lstr2, on: loc.BOUNDARY)),
                new Tuple(new Location(lstr1, on: loc.BOUNDARY),
                          new Location(lstr2, on: loc.EXTERIOR))]));
      g.addLinestring(lstr2);
      expect(g.nodes.map((n) => n.coordinate),
             unorderedEquals([new Coordinate(0.0, 0.0),
                              new Coordinate(1.0, 0.0),
                              new Coordinate(0.0, -1.0)]));
    });

    test("should be able to add an empty polygon to the graph", () {
      var poly = geomFactory.createEmptyPolygon();
      GeometryGraph g = new GeometryGraph(poly, null);
      g.addPolygon(poly);

      expect(g.nodes, isEmpty);
      expect(g.edges, isEmpty);

      var poly2 = geomFactory.fromWkt("Polygon((0 0, 1 1, 1 0, 0 0))");
      expect(() => g.addPolygon(poly2), throws,
             reason: "Not a graph geometry");
    });

    test("should be able to add a non-empty polygon to the graph", () {
      var poly1 = geomFactory.fromWkt("Polygon( (0 0, 1 1, 1 0, 0 0) )");
      var poly2 = geomFactory.fromWkt("Polygon( (1 1, 2 2, 2 4, 1 1),(2 2, 2 4, 6 6, 2 2) )");

      GeometryGraph g1 = new GeometryGraph(poly1, poly2);
        g1.addPolygon(poly1);
      expect(g1.nodes.map((n) => n.coordinate), [new Coordinate(0.0, 0.0)]);
      var nodeLabel = g1.nodes.first;
      expect(nodeLabel.locations,
            new Tuple(new Location(poly1, on: loc.BOUNDARY),
            new Location(poly2, on: loc.EXTERIOR)));

      expect(g1.edges.map((e) => e.coordinates),
             [ [ new Coordinate(0.0, 0.0),
                 new Coordinate(1.0, 1.0),
                 new Coordinate(1.0, 0.0),
                 new Coordinate(0.0, 0.0)
             ] ]);

      var edge = g1.edges.first;
      expect(edge.locations,
             new Tuple(new Location(poly1, on: loc.BOUNDARY, left: loc.INTERIOR, right: loc.EXTERIOR),
                       new Location(poly2, on: loc.NONE)));

      g1.addPolygon(poly2);
      expect(g1.nodes.map((n) => n.coordinate),
          unorderedEquals([new Coordinate(0.0, 0.0), new Coordinate(1.0, 1.0), new Coordinate(2.0, 2.0)]));

      expect(
          g1.edges.map((e) => e.coordinates),
          unorderedEquals(
          [ [ new Coordinate(0, 0), new Coordinate(1, 1), new Coordinate(1, 0), new Coordinate(0, 0)],
            [ new Coordinate(1, 1), new Coordinate(2, 2), new Coordinate(2, 4), new Coordinate(1, 1)],
            [ new Coordinate(2, 2), new Coordinate(2, 4), new Coordinate(6, 6), new Coordinate(2, 2)]
          ]));

    });

    test("should be able to add a geometrylist", () {
      var geom1 = geomFactory.fromWkt(
          """ GEOMETRYCOLLECTION (POLYGON ((0 40, 40 40, 40 0, 0 0, 0 40)),
                                  LINESTRING (80 0, 80 80, 120 40))
          """);
      var geom2 = geomFactory.createEmptyPoint();
      var g = new GeometryGraph(geom1, geom2);
      g.addGeometry(geom1);
      expect(g.nodes.map((n) => n.coordinate),
             unorderedEquals([ new Coordinate(0, 40),
                               new Coordinate(80, 0),
                               new Coordinate(120, 40) ]));
      expect(g.edges.map((e) => e.coordinates),
          unorderedEquals(
            [ [ new Coordinate(0, 40), new Coordinate(40, 40), new Coordinate(40, 0), new Coordinate(0, 0), new Coordinate(0,40)],
              [ new Coordinate(80, 0), new Coordinate(80, 80), new Coordinate(120, 40)
            ] ]));
    });

    test("should be able to add multiple geometries between the same coordinates which follow different paths", () {
      var lstr1 = geomFactory.fromWkt("LINESTRING(0 0, 1 0, 1 1)");
      var lstr2 = geomFactory.fromWkt("LINESTRING(0 0, 0 1, 1 1)");
      var g = new GeometryGraph(lstr1, lstr2);
      g.addLinestring(lstr1);
      g.addLinestring(lstr2);
      expect(g.nodes.map((n) => n.coordinate),
             unorderedEquals([new Coordinate(0,0), new Coordinate(1,1), new Coordinate(0,1)]));
      expect(g.edges.map((e) => e.coordinates),
             unorderedEquals([ [ new Coordinate(0,0), new Coordinate(1,0), new Coordinate(1,1)],
                               [ new Coordinate(0,0), new Coordinate(0,1)],
                               [ new Coordinate(0,1), new Coordinate(1,1)]
                             ]));

    });
  });
}