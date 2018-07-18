library spatially.algorithm.coordinate_locator_test;

import 'package:test/test.dart';

import 'package:spatially/spatially.dart';
import 'package:spatially/algorithm/coordinate_locator.dart';
import 'package:spatially/geom/location.dart' as loc;


main() {
  group("coordinate locator", () {
    test("should locate a coordinate outside a line", () {
      var c = new Coordinate(0.5, 0.5);
      var lstr = new GeometryFactory().fromWkt("Linestring(0.5 1, 1 0.5)");
      expect(locateCoordinateIn(c, lstr), loc.EXTERIOR);
    });
  });

}