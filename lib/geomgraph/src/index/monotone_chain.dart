part of geomgraph.index;

/**
 * A more efficient implmentation of an edgeset intersector,
 * using [MonotoneChain]s and a sweep line algorithm.
 * Although having the same worst case complexity of the simple intersector,
 * the average case should perform a lot faster.
 */
List<IntersectionInfo> _monotoneChainSweepLineIntersector(
    List<Edge> edges, 
    { bool testAll: false }) {
  /* FIXME: currently the testAll argument is ignored */
  List<SweeplineEvent> events = [];
  Iterable<MonotoneChainPartition> edgePartitions = 
      edges.map((e) => new MonotoneChainPartition(e));
  for (var monotoneChainPartition in edgePartitions) {
    for (var chain in monotoneChainPartition) {
      var insertEvent = 
          new SweeplineEvent.insertEvent(chain.envelope.minx, edges, chain);
      var deleteEvent =
          new SweeplineEvent.deleteEvent(chain.envelope.maxx, insertEvent);
      
      events.add(insertEvent);
      events.add(deleteEvent);
    }
  }
  //Sort the events as a sweep line.
  events.sort((evt1, evt2) => evt1.compareTo(evt2));
  int overlapCount = 0;
  
  Iterable<int> insertEvtIdxs =
      range(events.length).where((i) => events[i].evtType == SweeplineEvent.INSERT_EVT);
  var deleteEvtIdxs =
      range(events.length).where((i) => events[i].evtType == SweeplineEvent.DELETE_EVT);
  
  Set<IntersectionInfo> intersections = new Set();
  for (var i in insertEvtIdxs) {
    var insertEvent = events[i];
    //drop all delete events before i. We're not interested in them any more
    deleteEvtIdxs = deleteEvtIdxs.skipWhile((j) => j < i);
    //find the delete event associated with this insert event
    var deleteEvtIdx = 
        deleteEvtIdxs.firstWhere((j) => events[j].mchain == events[i].mchain);
    intersections.addAll(_intersectionsBetween(events, insertEvent, i, deleteEvtIdx));
  }
  return intersections.toList();
}

Set<IntersectionInfo> _intersectionsBetween(List<SweeplineEvent> events, 
                                            SweeplineEvent insertEvent, 
                                            int start, 
                                            int end) {
  var mchain0 = insertEvent.mchain;
  var intersections = new List();
  for (var i in range(start, end)
                .where((i) => events[i].evtType == SweeplineEvent.INSERT_EVT)) {
    var mchain1 = events[i].mchain;
    intersections.addAll(mchain0.intersectionsWith(mchain1));
  }
  return intersections;
}

/**
 * A [MonotoneChain] is a view onto the coordinates of an edge.
 * Each chain satisfies the requirements that:
 *  -- The segments in a chain are all directed towards the same
 *     quadrant, thus can never intersect each other
 *  -- The envelope of the chain is equal to the envelope generated
 *     from the first and last coordinates of the chain.
 */
class MonotoneChain extends Object with IterableMixin<Coordinate> {
  final MonotoneChainPartition _mchains;
  /**
   * The index into the list of edge coordinates.
   * The current chain is a view onto the sublist 
   * `edge.coordinates.sublist(start, end)`
   */
  final int start;
  /**
   * The index into the list of edge coordinates,
   * or `null` if this is the last chain in the partition
   * The current chain is a view onto the sublist
   * `edge.coordinates.sublist(start, end)
   */
  final int end;
  
  MonotoneChain._(this._mchains, this.start, this.end);
  
  /**
   * The parent edge of `this`.
   */
  Edge get edge => _mchains.edge;
  
  Iterator<Coordinate> get iterator => 
      edge.coordinates.getRange(start,end).iterator;
  
  Iterable<LineSegment> get segments =>
      coordinateSegments(edge.coordinates.sublist(start, end));
  
  /**
   * The envelope of the current chain.
   */
  Envelope get envelope => new Envelope.fromCoordinates(first, last);
  
  Set<IntersectionInfo> intersectionsWith(MonotoneChain mc1) {
    //No intersections with self.
    if (this == mc1) return new Set();
    //If the envelopes don't intersect, the chains can't intersect.
    if (!envelope.intersectsEnvelope(mc1.envelope)) return new Set();
    return _searchSubchains(edge, start, end, mc1.edge, mc1.start, mc1.end)
           .where((info) => info.isPresent)
           .map((info) => info.value);
  }
  
  Set<Optional<IntersectionInfo>> _searchSubchains(Edge e0, int start0, int end0, 
                                                   Edge e1, int start1, int end1) {
    if (end0 - start0 == 1 && end1 - start1 == 1) {
      Set infos = new Set();
      infos.add(_getIntersectionInfo(e0, start0, e1, start1));
    }
    var subchain1 = new MonotoneChain._(_mchains, start0, end0);
    var subchain2 = new MonotoneChain._(_mchains, start0, end0);
    
    if (!subchain1.envelope.intersectsEnvelope(subchain2)) {
      return new Set();
    }
    var mid0 = (start0 + end0) / 2;
    var mid1 = (start1 + end1) / 2;
    
    var infos = new Set();
    if (mid0 > start0) infos.addAll(_searchSubchains(e0, start0, mid0, e1, start1, end1));
    if (mid0 < end0)   infos.addAll(_searchSubchains(e0, mid0,   end0, e1, start1, end1));
    if (mid1 > start1) infos.addAll(_searchSubchains(e0, start0, end0, e1, start1, mid1));
    if (mid1 > start1) infos.addAll(_searchSubchains(e0, start0, end0, e1, mid1,   end1));
    return infos;
  }
  
  bool operator ==(Object other) {
    if (other is MonotoneChain && other.length == length) {
      Iterator<Coordinate> otherIter = other.iterator;
      for (var coord in this) {
        bool hasNext = otherIter.moveNext();
        assert(hasNext); //Lengths are identical
        if (coord != otherIter.current) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
}

/**
 * A partitioning of the coordinates of a given [Edge] into [MonotoneChain]s
 * Each element of the partition satisfies the requirements for being
 * a [MonotoneChain]
 */
class MonotoneChainPartition extends Object with IterableMixin<MonotoneChain> {
  /**
   * The edge which was used to generate the [MonotoneChainPartition]
   */
  final Edge edge;
  /**
   * A list of indices into the edge coordinate array.
   * Each index represents the start of a monotone chain
   * in the coordinate array
   */
  final UnmodifiableListView<int> _chainStarts;
  
  /**
   * Returns a list of indexes into the coordinate list marking
   * each index where a segment between two adjacent coordinates
   * changes quadrant.
   * 
   * The resulting collection of sublists of coordinates satisfy
   * the requirements for being monotone chains.
   */
  static UnmodifiableListView<int> _indexChainStarts(List<Coordinate> coordinates) {
    assert(coordinates.length >= 2);
    List<int> chainStarts = [];
    var coordSegs = coordinateSegments(coordinates).toList();
    var chainQuadrant = null;
    for (var i in range(coordSegs.length)) {
      var q = coordSegs[i].quadrant;
      if (q != chainQuadrant) {
        chainStarts.add(i);
        chainQuadrant = q;
      }
    }
    return new UnmodifiableListView<int>(chainStarts);
  }
  
  MonotoneChainPartition(Edge edge) :
    this.edge = edge,
    _chainStarts = _indexChainStarts(edge.coordinates);
  
  UnmodifiableListView<Coordinate> get _coordinates => 
      edge.coordinates;
  
  int _chainStart(int i) => _chainStarts[i];
  int _chainEnd(int i) {
    if (i >= _chainStarts.length - 2) {
      return null;
    }
    return _chainStarts[i + 1];
  }
  
  Iterator<MonotoneChain> get iterator =>
      range(_chainStarts.length)
      .map((i) => new MonotoneChain._(this, _chainStart(i), _chainEnd(i))).iterator;
}

