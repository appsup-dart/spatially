library spatially.geomgraph.intersection_test;

import 'package:test/test.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/geomgraph/intersector.dart';

import 'mock_graph.dart';

main() {
  group("intersection", () {
    simpleTests();
    equalityTests();
  });
}

void simpleTests() {
  GeometryFactory geomFactory = new GeometryFactory();
    var e1 = new MockEdge(1, geomFactory.fromWkt("LINESTRING(0 0, 1 1, 0 1)"));
    var e2 = new MockEdge(2, geomFactory.fromWkt("LINESTRING(1 0, 0 1, 1 1)"));

    test("should be able to intersect two segments which intersect at a coordinate", () {
      IntersectionInfo intersection =
          new IntersectionInfo(e1, 0, e2, 0);
      expect(intersection, isNotNull);
      expect(intersection.coordinates, [new Coordinate(0.5,0.5)]);
      expect(intersection.isCoordinateIntersection, isTrue);
      expect(intersection.isLineIntersection, isFalse);
    });

    test("should be able to intersect two segments which intersect in a line segment", () {
      IntersectionInfo intersection =
          new IntersectionInfo(e1, 1, e2, 1);
      expect(intersection, isNotNull);
      expect(intersection.coordinates, unorderedEquals([new Coordinate(0,1), new Coordinate(1,1)]));
    });

    var isect = new IntersectionInfo(e1, 1, e2, 1);

    test("should be able to get a symmetric intersection", () {
      var sym = isect.symmetric;
      expect(sym.edge0, e2);
      expect(sym.edge1, e1);
      expect(sym.coordinates, isect.coordinates);
    });

    test("should be able to reverse an intersection", () {
      var rev = isect.reversed;
      expect(rev.edge0, e1);
      expect(rev.edge1, e2);
      expect(rev.coordinates, isect.coordinates.reversed);
    });
}

void equalityTests() {
  GeometryFactory geomFactory = new GeometryFactory();
  test("should test equal", () {
    var e1 = new MockEdge(1, geomFactory.fromWkt("LINESTRING(0 0, 1 1, 1 0)"));
    var e2 = new MockEdge(2, geomFactory.fromWkt("LINESTRING(1 0, 1 1)"));
    var isect = new IntersectionInfo(e1, 1, e2, 0);
    expect(isect, equals(isect.symmetric), reason: "symmetric");
    expect(isect.symmetric.hashCode, isect.hashCode);
  });

  test('edge intersects self', () {
      var self_intersecting = geomFactory.fromWkt(
      "LINESTRING(0 0, 10 0, 0 10, 10 10, 0 0)");
      var edge = new MockEdge(0, self_intersecting);
      var isect = new IntersectionInfo(edge, 3, edge, 1);
      expect(isect, equals(isect.symmetric), reason: "symmetric");
      expect(isect.symmetric.hashCode, isect.hashCode);
  });
}
