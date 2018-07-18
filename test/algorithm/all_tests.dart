library spatially.algorithm.all_tests;

import 'package:test/test.dart';
import 'cg_algorithm_test.dart' as cg_algorithm;
import 'line_intersector_tests.dart' as line_intersector;
import 'coordinate_locator_test.dart' as coordinate_locator;

main() {
  group("algorithm: ", () {
    cg_algorithm.main();
    line_intersector.main();
    coordinate_locator.main();

  });
}