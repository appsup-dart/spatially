library geomgraph.test_intersector;

import 'package:collection/wrappers.dart';
import 'package:test/test.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/geomgraph/intersector.dart';

import 'mock_graph.dart';

void main() {
  testSimpleIntersector();
  testMonotoneChain();
  testSweeplineIntersector();
}

testSimpleIntersector() {
  group("simple intersector", () {
    GeometryFactory geomFactory = new GeometryFactory();
    EdgeSetIntersector intersector = SIMPLE_EDGE_SET_INTERSECTOR;
    test("closed linestring", () {
      var lstr_closed = geomFactory.fromWkt("LINESTRING(0 0, 10 0, 10 10, 0 10, 0 0)");
      var edge = new MockEdge(0, lstr_closed);
      //All the intersections should be trivial
      expect(intersector([edge]), unorderedEquals([]));
    });
    test("self intersecting linestring", () {
      var self_intersecting = geomFactory.fromWkt(
          "LINESTRING(0 0, 10 0, 0 10, 10 10, 0 0)");
      var edge = new MockEdge(0, self_intersecting);

      var intersections = intersector([edge]);
      print(intersections.toSet());
      print(intersections.map((i) => i.hashCode));
      print(intersections.first == intersections.last);

      expect(intersections.first.edge0, edge);
      expect(intersections.first.segIndex0, 1);
      expect(intersections.first.edgeDist0, 50.0);

      expect(intersections.first.edge1, edge);
      expect(intersections.first.segIndex1, 3);
      expect(intersections.first.edgeDist1, 50.0);

      expect(intersections.first.coordinates, [new Coordinate(5.0,5.0)]);
    });

    test("Intesections from different segments", () {
      var edge1 = new MockEdge(1, geomFactory.fromWkt("LINESTRING(0 0, 10 10)"));
      var edge2 = new MockEdge(2, geomFactory.fromWkt("LINESTRING(10 0, 0 10)"));
      var intersection = intersector([edge1,edge2]).first;
      expect(intersection.edge0, edge1);
      expect(intersection.segIndex0, 0);

      expect(intersection.edge1, edge2);
      expect(intersection.segIndex1, 0);

      expect(intersection.coordinates, [new Coordinate(5.0, 5.0)]);
    });

    test("long chains", () {
      var edge1 = new MockEdge(1, geomFactory.fromWkt(
      "LINESTRING(0 0, 10 0, 20 5, 30 10, 40 20, 40 30, 40 40, 30 30, 30 20, 10 10, 0 0)"));
      var edge2 = new MockEdge(2, geomFactory.fromWkt(
      "LINESTRING(0 0, 0 10, 5 20, 10 30, 20 40, 30 40, 40 40, 30 30, 20 30, 10 10, 0 0)"));
      var edge3 = new MockEdge(3, geomFactory.fromWkt(
      "LINESTRING(20 0, 20 40)"));
      expect(intersector([edge1,edge2, edge3]).length, 21);
    });
  });
}

testMonotoneChain() {
  group("monotone chain", () {
  GeometryFactory geomFactory = new GeometryFactory();
  test("monotone partition", () {
    MockEdge edge = new MockEdge(0, geomFactory.fromWkt("LINESTRING(0 0, 10 10, 10 15, 20 20, 20 0, 20 -20))"));
    MonotoneChainPartition partition = new MonotoneChainPartition(edge);
    expect(partition.length, equals(2));
    expect(partition.first, equals([new Coordinate(0.0, 0.0),
                                    new Coordinate(10.0, 10.0),
                                    new Coordinate(10.0, 15.0),
                                    new Coordinate(20.0, 20.0)])
                         , reason: "first partition element does not match");
    expect(partition.last, equals([ new Coordinate(20.0, 20.0),
                                    new Coordinate(20.0, 0.0),
                                    new Coordinate(20.0, -20.0)])
                         , reason: "last partition element does not match");
  });
  });
}

testSweeplineIntersector() {
  group("sweep line intersector", () {
  GeometryFactory geomFactory = new GeometryFactory();
  EdgeSetIntersector intersector = MONOTONE_CHAIN_SWEEP_LINE_INTERSECTOR;
  test("closed linestring", () {
    var lstr_closed = geomFactory.fromWkt("LINESTRING(0 0, 10 0, 10 10, 0 10, 0 0)");
    var edge = new MockEdge(0, lstr_closed);
    //All the intersections should be trivial
    expect(intersector([edge]), unorderedEquals([]));
  });
  test("self intersecting linestring", () {
    var self_intersecting = geomFactory.fromWkt(
        "LINESTRING(0 0, 10 0, 0 10, 10 10, 0 0)");
    var edge = new MockEdge(0, self_intersecting);
    var intersection = intersector([edge], testAll: true).first;
    expect(intersection.edge0, edge);
    expect(intersection.segIndex0, 1);
    expect(intersection.segIndex1, 3);
    expect(intersection.coordinates, [new Coordinate(5,5)]);
    expect(intersection.edgeDist0, 50.0);
  });
  test("Intesections from different segments", () {
    var edge1 = new MockEdge(1, geomFactory.fromWkt("LINESTRING(0 0, 10 10)"));
    var edge2 = new MockEdge(2, geomFactory.fromWkt("LINESTRING(10 0, 0 10)"));
    var intersection = intersector([edge1,edge2]).first;
    expect(intersection.edge0, edge1);
    expect(intersection.edge1, edge2);
    expect(intersection.coordinates, [new Coordinate(5,5)]);
  });
  test("long chains", () {
    var edge1 = new MockEdge(1, geomFactory.fromWkt(
        "LINESTRING(0 0, 10 0, 20 5, 30 10, 40 20, 40 30, 40 40, 30 30, 30 20, 10 10, 0 0)"));
    var edge2 = new MockEdge(2, geomFactory.fromWkt(
        "LINESTRING(0 0, 0 10, 5 20, 10 30, 20 40, 30 40, 40 40, 30 30, 20 30, 10 10, 0 0)"));
    var edge3 = new MockEdge(3, geomFactory.fromWkt(
        "LINESTRING(20 0, 20 40)"));

    expect(intersector([edge1,edge2, edge3]).length, 21);
  });
  });
}

