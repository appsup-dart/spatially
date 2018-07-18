library spatially.geomgraph.geometry_graph.noding_test;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/base/tuple.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/geomgraph/geometry_graph.dart';
import 'package:spatially/geomgraph/location.dart';

void main() {
  group("edge noding:", () {
    GeometryFactory geomFactory = new GeometryFactory();
    test("should be able to node a graph of two points", () {
      var p1 = geomFactory.fromWkt("POINT(0 0)");
      var p2 = geomFactory.fromWkt("POINT(1 1)");
      GeometryGraph g = new GeometryGraph(p1, p2);
      g.addPoint(p1);
      g.addPoint(p2);
      g.nodeGraph();

      expect(g.nodeByCoordinate(new Coordinate(0,0)).locations,
             new Tuple(new Location(p1, on: loc.INTERIOR),
                       new Location(p2, on: loc.EXTERIOR)));

      expect(g.nodeByCoordinate(new Coordinate(1,1)).locations,
             new Tuple(new Location(p1, on: loc.EXTERIOR),
                       new Location(p2, on: loc.INTERIOR)));
      expect(g.edges, isEmpty);
    });

    test("should be able to node a graph of two linestrings", () {
      var lstr1 = geomFactory.fromWkt("LINESTRING(0 0, 1 1, 1 0, 0 1)");
      var lstr2 = geomFactory.fromWkt("Linestring(0.5 1, 1 0.5)");

      GeometryGraph g = new GeometryGraph(lstr1, lstr2);
      g.addLinestring(lstr1);
      g.addLinestring(lstr2);
      g.nodeGraph();

      //The nodes that should have been there originally
      var c1 = new Coordinate(0,0);
      expect(g.nodeByCoordinate(c1).locations,
             new Tuple(new Location(lstr1, on: loc.BOUNDARY),
                       new Location(lstr2, on: loc.EXTERIOR)),
             reason: "Existing ($c1)");

      var c2 = new Coordinate(0,1);
      expect(g.nodeByCoordinate(c2).locations,
             new Tuple(new Location(lstr1, on: loc.BOUNDARY),
                       new Location(lstr2, on: loc.EXTERIOR)),
             reason: "Existing ($c2)");

      var c3 = new Coordinate(0.5,1);
      expect(g.nodeByCoordinate(c3).locations,
             new Tuple(new Location(lstr1, on: loc.EXTERIOR),
                       new Location(lstr2, on: loc.BOUNDARY)),
             reason: "Existing ($c3)");

      var c4 = new Coordinate(1,0.5);
      expect(g.nodeByCoordinate(c4).locations,
             new Tuple(new Location(lstr1, on: loc.INTERIOR),
                       new Location(lstr2, on: loc.BOUNDARY)),
              reason: "Existing ($c4)");

      //The nodes which should have been added during noding
      var c5 = new Coordinate(0.5, 0.5);
      expect(g.nodeByCoordinate(c5).locations,
             new Tuple(new Location(lstr1, on: loc.INTERIOR),
                       new Location(lstr2, on: loc.EXTERIOR)),
            reason: "Added ($c5)");

      var c6 = new Coordinate(0.75, 0.75);
      expect(g.nodeByCoordinate(c6).locations,
             new Tuple(new Location(lstr1, on: loc.INTERIOR),
                       new Location(lstr2, on: loc.INTERIOR)),
            reason: "Added ($c6)");
;
      expect(g.edges.map((e) => e.locations),
             everyElement(isIn(
                 [ new Tuple(new Location(lstr1, on: loc.INTERIOR), new Location(lstr2, on: loc.NONE)),
                   new Tuple(new Location(lstr1, on: loc.NONE),     new Location(lstr2, on: loc.INTERIOR))
                 ])));
    });

    test("should be able to node a graph of two polygons", () {
      var poly1 = geomFactory.fromWkt("POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))");
      var poly2 = geomFactory.fromWkt("POLYGON((5 5, 15 5, 15 15, 5 15, 5 5))");
      GeometryGraph geomGraph = new GeometryGraph(poly1, poly2);
      geomGraph.addPolygon(poly1);
      geomGraph.addPolygon(poly2);
      geomGraph.nodeGraph();

      var nodes = geomGraph.nodes.toList();
      expect(nodes.singleWhere((n) => n.coordinate == new Coordinate(0,0)).locations,
          new Tuple(new Location(poly1, on: loc.BOUNDARY),
                    new Location(poly2, on: loc.EXTERIOR)),
          reason: "Poly1 boundary");
      expect(nodes.singleWhere((n) => n.coordinate == new Coordinate(5,5)).locations,
          new Tuple(new Location(poly1, on: loc.INTERIOR),
                    new Location(poly2, on: loc.BOUNDARY)),
          reason: "Poly2 boundary");
      expect(nodes.singleWhere((n) => n.coordinate == new Coordinate(10,5)).locations,
          new Tuple(new Location(poly1, on: loc.BOUNDARY),
                    new Location(poly2, on: loc.BOUNDARY)),
          reason: "Poly1 poly2 intersection");
      expect(nodes.singleWhere((n) => n.coordinate == new Coordinate(10,5)).locations,
          new Tuple(new Location(poly1, on: loc.BOUNDARY),
                    new Location(poly2, on: loc.BOUNDARY)),
          reason: "Poly1 poly2 intersection point (2)");


      expect(geomGraph.edges.map((e) => e.locations),
             everyElement(isIn(
                 [ new Tuple(new Location(poly1, on: loc.BOUNDARY, left: loc.EXTERIOR, right: loc.INTERIOR),
                             new Location(poly2, on: loc.NONE)),
                   new Tuple(new Location(poly1, on: loc.NONE),
                             new Location(poly2, on: loc.BOUNDARY, left: loc.EXTERIOR, right: loc.INTERIOR))
                 ])));
    });
  });
}