part of geomgraph.index;

/**
 * Find all intersections in a set of edges
 * using the straightforward method of comparing
 * all segments
 */
List<IntersectionInfo> _simpleEdgeSetIntersector(
      List<Edge> edges,
    { bool testAll: false }) {
  int nOverlaps = 0;
  List<IntersectionInfo> infos = [];
  for (var e1 in edges) {
    for (var e2 in edges) {
      if (testAll || e1 != e2) {
        infos.addAll(_simpleIntersect(e1, e2));
      }
    }
  }
}

List<IntersectionInfo> _simpleIntersect(Edge e1, Edge e2) {
  List<IntersectionInfo> infos = [];
  for (var i in range(e1.segments.length)) {
    for (var j in range(e2.segments.length)) {
      var info = _getIntersectionInfo(e1, i, e2, j);
      if (info.isPresent) {
        infos.add(info);
      }
    }
  }
  return infos;
}