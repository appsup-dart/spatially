library spatially.geomgraph.all_tests;

import 'package:test/test.dart';

import 'geometry_graph/all_tests.dart' as geometry_graph;
import 'intersection_info_test.dart' as intersection_info;
import 'intersector_tests.dart' as intersector;
import 'location_tests.dart' as location;

main() {
  group("geomgraph", () {
    geometry_graph.main();
    intersection_info.main();
    intersector.main();
    location.main();
  });
}