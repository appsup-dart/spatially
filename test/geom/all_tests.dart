library spatially.geom.all_tests;

import 'package:test/test.dart';

import 'boundary_tests.dart' as boundary;
import 'centroid_tests.dart' as centroid;
import 'dispatch_test.dart' as dispatch;
import 'factory_test.dart' as fact;
import 'interior_point_tests.dart' as interior_point;
import 'intersection_matrix_tests.dart' as intersection_matrix;

main() {
  group("geom: ", () {
  boundary.main();
  centroid.main();
  dispatch.main();
  fact.main();
  interior_point.main();
  intersection_matrix.main();
  });
}