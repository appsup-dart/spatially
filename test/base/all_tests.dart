library spatially.base.all_tests;

import 'package:test/test.dart';

import 'iterables/all_tests.dart' as iterables;
import 'coordinate_test.dart' as coordinate;
import 'graph_test.dart' as graph;
import 'line_segment_test.dart' as line_segment;
import 'linkedlist_test.dart' as linkedlist;
import 'tuple_tests.dart' as tuple;

void main() {
  group("base: ", () {
    coordinate.main();
    graph.main();
    line_segment.main();
    linkedlist.main();
    tuple.main();
    iterables.main();
  });
}