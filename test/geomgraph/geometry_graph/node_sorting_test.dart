library spatially.geomgraph.geometry_graph.node_sorting;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/geomgraph/geometry_graph.dart';

main() {
  group("edge sorting: ", () {
    GeometryFactory geomFactory = new GeometryFactory();
    test("edges with the same length should be ordered around the common node", () {
      var g1 = geomFactory.fromWkt("LINeSTRING(0 0, 1 1)");
      var g2 = geomFactory.fromWkt("LINeSTRING(0 0, 1 0)");
      GeometryGraph geomGraph = new GeometryGraph(g1, g2);
      geomGraph.addLinestring(g1);
      geomGraph.addLinestring(g2);

      var n = geomGraph.nodeByCoordinate(new Coordinate(0,0));
      var e1 = geomGraph.edgeByCoordinates([new Coordinate(0,0), new Coordinate(1,1)]);
      var e2 = geomGraph.edgeByCoordinates([new Coordinate(0,0), new Coordinate(1,0)]);
      expect(e1.compareOrientation(n, e2), 1);
    });

    test("should order edges around nodes", () {
      var g1 = geomFactory.fromWkt("LINESTRING(0 0, 1 1, -1 1, 0 0)");
      var g2 = geomFactory.fromWkt("LINESTRING(0 0, 1 -1, -1 -1, 0 0)");
      GeometryGraph geomGraph = new GeometryGraph(g1, g2);
      geomGraph.addGeometry(g1);
      geomGraph.addGeometry(g2);
      var node = geomGraph.nodeByCoordinate(new Coordinate(0,0));

      expect(node.terminatingEdges.map((e) => e.coordinates),
             [  [ new Coordinate(-1,-1), new Coordinate(0,0)],
               [ new Coordinate(0, 0), new Coordinate(1,-1), new Coordinate(0,-1)],
               [ new Coordinate(0, 0), new Coordinate(1,1), new Coordinate(-1,1), new Coordinate(0,0)]
             ]);
    });
  });
}