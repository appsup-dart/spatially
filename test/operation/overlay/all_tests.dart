library spatially.operation.overlay.all_tests;

import 'package:test/test.dart';

import 'linestring_test.dart' as linestring;
import 'point_test.dart' as point;
import 'polygon_test.dart' as polygon;

main() {
  group("overlay", () {
    point.main();
    linestring.main();
    polygon.main();
  });

}