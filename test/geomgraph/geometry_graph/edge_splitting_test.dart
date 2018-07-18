library spatially.geomgraph.geometry_graph.edge_splitting_test;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/geomgraph/geometry_graph.dart';
import 'package:spatially/geomgraph/intersector.dart';

EdgeSetIntersector _edgeSetIntersector = SIMPLE_EDGE_SET_INTERSECTOR;

main() {
  group("edge splitting:", () {
    GeometryFactory geomFactory = new GeometryFactory();
    test("should be able to edge split two linestrings", () {
      var lstr1 = geomFactory.fromWkt("LINESTRING(0 0, 1 1, 1 0, 0 1)");
      var lstr2 = geomFactory.fromWkt("Linestring(0.5 1, 1 0.5)");

      GeometryGraph g = new GeometryGraph(lstr1, lstr2);
      g.addLinestring(lstr1);
      g.addLinestring(lstr2);

      Iterable<IntersectionInfo> infos = SIMPLE_EDGE_SET_INTERSECTOR(new List.from(g.edges));

      var testEdge1 =
          g.edgeByCoordinates([new Coordinate(0.5, 1), new Coordinate(1.0, 0.5)]);

      expect(
          testEdge1.splitCoordinates(infos),
          [  [ new Coordinate(0.5, 1), new Coordinate(0.75, 0.75) ],
             [ new Coordinate(0.75, 0.75), new Coordinate(1, 0.5) ]
          ]);
    });

    test("segment intersection at first segment of linestring", () {
      var lstr1 = geomFactory.fromWkt("Linestring(0 0, 1 0, 1 1, 0 1)");
      var lstr2 = geomFactory.fromWkt("Linestring(-1 0, 0.5 0, 1 1, 2 1)");

      var geomGraph = new GeometryGraph(lstr1, lstr2);
      geomGraph.addLinestring(lstr1);
      geomGraph.addLinestring(lstr2);

      Iterable<IntersectionInfo> infos = SIMPLE_EDGE_SET_INTERSECTOR(new List.from(geomGraph.edges));
      var testEdge1 = geomGraph
          .edgeByCoordinates([new Coordinate(0,0), new Coordinate(1,0), new Coordinate(1,1), new Coordinate(0,1)]);
      expect(testEdge1.splitCoordinates(infos),
             [ [ new Coordinate(0,0),  new Coordinate(0.5, 0) ],
               [ new Coordinate(0.5,0), new Coordinate(1,0), new Coordinate(1,1) ],
               [ new Coordinate(1,1),  new Coordinate(0,1) ]
             ],
             reason: "linestring 1");
      var testEdge2 = geomGraph
          .edgeByCoordinates([new Coordinate(-1,0), new Coordinate(0.5,0), new Coordinate(1,1), new Coordinate(2,1)]);
      expect(testEdge2.splitCoordinates(infos),
             [ [ new Coordinate(-1,0),  new Coordinate(0,0)    ],
               [ new Coordinate(0,0),   new Coordinate(0.5, 0) ],
               [ new Coordinate(0.5,0), new Coordinate(1,1)    ],
               [ new Coordinate(1,1),   new Coordinate(2,1)    ]
             ],
             reason: "linestring 2");

    });
    test("overlapping linestrings", () {
      var g1 = geomFactory.fromWkt("LINESTRING(0 0, 1 0, 1 1)");
      var g2 = geomFactory.fromWkt("LINESTRING(0.5 0, 1 0, 1 0.5)");

      var geomGraph = new GeometryGraph(g1,g2);
      geomGraph.addGeometry(g1);
      geomGraph.addGeometry(g2);

      Iterable infos = SIMPLE_EDGE_SET_INTERSECTOR(new List.from(geomGraph.edges));
      var e1 = geomGraph.edgeByCoordinates([new Coordinate(0,0), new Coordinate(1,0), new Coordinate(1,1)]);
      expect(e1.splitCoordinates(infos),
             [ [new Coordinate(0,0), new Coordinate(0.5, 0)],
               [new Coordinate(0.5, 0), new Coordinate(1, 0), new Coordinate(1, 0.5)],
               [new Coordinate(1, 0.5), new Coordinate(1,1)]
             ]);
    });

    test("linestrings intersect and end and strt", () {
      var g1 = geomFactory.fromWkt("LINESTRING(0 0, 1 0)");
      var g2 = geomFactory.fromWkt("LINESTRING(1 0, 0 1)");
      var graph = new GeometryGraph(g1, g2);
      graph.addLinestring(g1);
      graph.addLinestring(g2);

      Iterable<IntersectionInfo> infos = SIMPLE_EDGE_SET_INTERSECTOR(graph.edges.toList());

      var e1 = graph.edgeByCoordinates([new Coordinate(0,0), new Coordinate(1,0)]);
      expect(e1.splitCoordinates(infos),
             [[ new Coordinate(0,0), new Coordinate(1,0) ]]);

      var e2 = graph.edgeByCoordinates([new Coordinate(1,0), new Coordinate(0,1)]);
      expect(e2.splitCoordinates(infos),
             [[new Coordinate(1,0), new Coordinate(0,1)]]);
    });

    test("segment intersection as last segment of polygon", () {
      var poly1 = geomFactory.fromWkt("POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))");
      var poly2 = geomFactory.fromWkt("POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))");

      GeometryGraph geomGraph = new GeometryGraph(poly1, poly2);
      geomGraph.addPolygon(poly1);
      geomGraph.addPolygon(poly2);

      Iterable<IntersectionInfo> infos = SIMPLE_EDGE_SET_INTERSECTOR(new List.from(geomGraph.edges));
      var testEdge =
          geomGraph
          .edgeByCoordinates([new Coordinate(1,0), new Coordinate(2,0), new Coordinate(2,1), new Coordinate(1,1), new Coordinate(1,0)]);
      expect(testEdge.splitCoordinates(infos),
             [ [new Coordinate(1, 0), new Coordinate(2, 0), new Coordinate(2,1), new Coordinate(1,1)],
               [new Coordinate(1, 1), new Coordinate(1, 0)]
             ]);
      var testEdge2 =
          geomGraph
          .edgeByCoordinates([new Coordinate(0,0), new Coordinate(1,0), new Coordinate(1,1), new Coordinate(0,1), new Coordinate(0,0)]);
      expect(testEdge2.splitCoordinates(infos),
            [ [new Coordinate(0, 0), new Coordinate(1, 0)],
              [new Coordinate(1, 0), new Coordinate(1, 1)],
              [new Coordinate(1, 1), new Coordinate(0, 1), new Coordinate(0,0)]
            ], reason: "poly2 split coords");
    });

    test("partially overlapping polygons", () {
      var poly1 = geomFactory.fromWkt(
          """POLYGON( 
              (0 0, 3 0, 3 3, 0 3, 0 0),
              (1 1, 2 1, 2 2, 1 2, 1 1) )
          """);
      var poly2 = geomFactory.fromWkt(
          """POLYGON(
              (1.5 1.5, 4.5 1.5, 4.5 4.5, 1.5 4.5, 1.5 1.5),
              (2.5 2.5, 3.5 2.5, 3.5 3.5, 2.5 3.5, 2.5 2.5))
          """);
      var geomGraph = new GeometryGraph(poly1, poly2);
      geomGraph.addPolygon(poly1);
      geomGraph.addPolygon(poly2);

      Iterable<IntersectionInfo> infos = SIMPLE_EDGE_SET_INTERSECTOR(geomGraph.edges.toList());

      var e1 = geomGraph.edgeByCoordinates([new Coordinate(1,1), new Coordinate(2,1), new Coordinate(2,2), new Coordinate(1,2), new Coordinate(1,1)]);
      expect(e1.splitCoordinates(infos),
            [ [ new Coordinate(1, 1), new Coordinate(2,1), new Coordinate(2, 1.5)],
              [ new Coordinate(2, 1.5), new Coordinate(2,2), new Coordinate(1.5, 2)],
              [ new Coordinate(1.5, 2), new Coordinate(1, 2), new Coordinate(1,1)]
            ]);
    });
  });

}