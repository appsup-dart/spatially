library test_geom;

import 'package:test/test.dart';

import 'package:spatially/geom/intersection_matrix.dart';
import 'package:spatially/geom/dimension.dart' as dim;

void main() {
  testIntersectionMatrix();
}

void testIntersectionMatrix() {
  group("Intersection matrix", () {
    final intersectionMatrix = new IntersectionMatrix();
    intersectionMatrix[0][0] = dim.LINE;
    intersectionMatrix[1][0] = dim.AREA;
    test("Matrix rows", () {
      final rows = new List<List<int>>.from([new List<int>.from([dim.LINE, dim.EMPTY, dim.EMPTY]),
                                               new List<int>.from([dim.AREA, dim.EMPTY, dim.EMPTY]),
                                               new List<int>.from([dim.EMPTY, dim.EMPTY, dim.EMPTY])]);
      expect(intersectionMatrix.rows, equals(rows));
    });
    test("Matrix columns", () {
      final cols = new List<List<int>>.from([new List<int>.from([dim.LINE, dim.AREA, dim.EMPTY]),
                                               new List<int>.from([dim.EMPTY, dim.EMPTY, dim.EMPTY]),
                                               new List<int>.from([dim.EMPTY, dim.EMPTY, dim.EMPTY])]);
      expect(intersectionMatrix.columns, equals(cols));
    });
  });
  test("Matrix from pattern", () {
    final fromPattern = new IntersectionMatrix.fromPattern("11F222012");
    final expectMatrix = new IntersectionMatrix();
    expectMatrix.rows = new List<List<int>>.from([new List<int>.from([dim.LINE, dim.LINE, dim.EMPTY]),
                                                    new List<int>.from([dim.AREA, dim.AREA, dim.AREA]),
                                                    new List<int>.from([dim.POINT, dim.LINE, dim.AREA])]);
    expect(fromPattern, equals(expectMatrix));
  });
  test("Matrix matches", () {
    final dimPattern = new IntersectionMatrix.fromPattern("11F222012");
    final matchPattern = "1TF**2012";
    expect(dimPattern.matches(matchPattern), isTrue);
  });
}