//This file is part of Spatially.
//
//    Spatially is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Spatially is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with Spatially.  If not, see <http://www.gnu.org/licenses/>.


library spatially.geomgraph.geometry_graph;

import 'package:collection/collection.dart';
import 'package:quiver/iterables.dart' show concat;

import 'package:spatially/spatially.dart';
import 'package:spatially/base/graph.dart';
import 'package:spatially/base/linkedlist.dart';
import 'package:spatially/base/tuple.dart';
import 'package:spatially/base/iterables.dart' show slice;

import 'package:spatially/algorithm/cg_algorithms.dart' as cg_algorithms show isCounterClockwise;
import 'package:spatially/algorithm/coordinate_locator.dart' show locateCoordinateIn;

import 'package:spatially/geom/location.dart' as loc;

import 'location.dart';
import 'intersector.dart';
import '../algorithm/coordinate_arrays.dart';

part 'src/geometry_graph/edge_label.dart';
part 'src/geometry_graph/node_label.dart';

const ListEquality _listEq = const ListEquality();

// If in debug mode, use the simple intersector.
const bool __DEBUG__ = true;

const EdgeSetIntersector _edgeSetIntersector =
    __DEBUG__ ? SIMPLE_EDGE_SET_INTERSECTOR
              : MONOTONE_CHAIN_SWEEP_LINE_INTERSECTOR;

class GeometryGraph {
  Graph<Node,Edge> _delegate;
  final Tuple<Geometry,Geometry> geometries;

  GeometryGraph(Geometry geometry1, Geometry geometry2) :
    geometries = new Tuple(geometry1, geometry2),
    _delegate = new Graph<Node, Edge>(starAtNode:true);

  Iterable<Node> get nodes =>
      _delegate.nodes.map((n) => n.label);

  Iterable<Edge> get edges =>
      _delegate.edges.map((e) => e.label);

  Iterable<Node> get boundaryNodes =>
      nodes.where((n) => n.locations
                          .either((l) => l.on == loc.BOUNDARY));

  /**
   * Adds both geometries to the graph, then nodes and labels the graph.
   */
  void initialise() {
    addGeometry(geometries.$1);
    addGeometry(geometries.$2);
    nodeGraph();
    labelGraph();
  }

  /**
   * Retrieve the [Node] given the coordinate.
   * Return `null` if no edge is found with the given coordinate.
   */
  Node nodeByCoordinate(Coordinate c) {
     var graphNode = _delegate.nodeByLabel(new Node._(null, c, null));
     return graphNode != null ? graphNode.label : null;
  }

  /**
   * Retrieve the [Edge] given it's coordinates
   * Return `null` if no edge is found with the given coordinate list.
   */
  Edge edgeByCoordinates(List<Coordinate> coords) {
    var graphEdge = _delegate.edgeByLabel(new Edge._(null, coords, null));
    return graphEdge != null ? graphEdge.label : null;
  }

  void removeEdge(Edge edge) {
    _delegate.removeEdge(edge);
  }

  void removeNode(Node node) {
    _delegate.removeNode(node);
  }

  void removeIfIsolated(Node node) {
    if (node.isIsolated) {
      _delegate.removeNode(node);
    }
  }

  GraphNode<Node> _addCoordinate(int geomIdx, Coordinate c, {int on}) {
    var locations = new Tuple(
            geomIdx == 1 ? on : locateCoordinateIn(c, geometries.$1),
            geomIdx == 2 ? on : locateCoordinateIn(c, geometries.$2))
        .transform((on) => new Location(geometries.$1, on: on),
                   (on) => new Location(geometries.$2, on: on));
    var node = new Node._(this, c, locations);
    return _delegate.addNode(node);
  }


  /**
   * Adds a coordinate list as an undirected edge between startNode and endNode
   * to the graph.
   * If an existing, unequal connection is found between the start and edge of the edge,
   * the coordinates for the edge are split and a dummy node is placed in the graph
   * at the midpoint of the coordinate list.
   */
  void _addCoordinateList(int geomIdx, List<Coordinate> coords,
                                     GraphNode<Node> startNode, GraphNode<Node> endNode,
                                    {int on, int left, int right}) {
    var knownLocation   = new Location(geometries.project(geomIdx), on: on, left: left, right: right);
    var locations = new Tuple(
        geomIdx == 1 ? knownLocation : new Location.unknown(geometries.$1),
        geomIdx == 2 ? knownLocation : new Location.unknown(geometries.$2));
    var edge = new Edge._(this, coords, locations);
    //Test if there is an existing connection between the start and end nodes
    var connection = startNode.connection(endNode);
    if (connection != null) {
      if (!_listEq.equals((connection.label as Edge)._coordinates, coords)
          && !_listEq.equals((connection.label as Edge)._revCoordinates, coords)) {
        //Add a dummy node and two edges representing the split coordinates.
        var len = coords.length;
        var mid = (len % 2 == 0)
            ? new LineSegment(coords[len ~/ 2 - 1], coords[len ~/ 2]).midpoint
            : coords[len ~/ 2];
        var dummyNode = _addCoordinate(geomIdx, mid, on: on);
        var initCoords =
            concat([coords.take(len ~/ 2), [mid]])
            .toList(growable: false);
        _addCoordinateList(geomIdx,
            concat([coords.take(coords.length ~/ 2), [mid]]).toList(growable: false),
            startNode, dummyNode,
            on: on, left: left, right: right);
        var lastCoords =
            concat([(len % 2 == 0) ? [mid] : <Coordinate>[], coords.skip(len ~/ 2)])
            .toList(growable: false);
        _addCoordinateList(geomIdx,
            concat([(len % 2 == 0 ? [mid] : <Coordinate>[]), coords.skip(coords.length ~/ 2)]).toList(growable: false),
            dummyNode, endNode,
            on: on, left: left, right: right);
        return;
      }
    }
    _delegate.addUndirectedEdge(edge, startNode, endNode);
  }

  void labelGraph() {
    for (var geomIdx in [1,2]) {
      edges.where((e) => !e.locations.project(geomIdx).isKnown)
           .forEach((e) => e._fiinalizeLabel(geomIdx));
    }
  }

  /**
   * Calculates the intersections between edges of the graph and adds a node to
   * the graph at each intersection.
   *
   * Then splits the edges of the graph so that there is a unique edge between
   * every intersection point and every previously existing node of the graph.
   */
  void nodeGraph() {
    //copy of the edges
    var edges = this.edges.toList(growable: false);
    Iterable<IntersectionInfo> intersectionInfos = _edgeSetIntersector(edges);
    edges.forEach((e) => e._nodeEdge(intersectionInfos));
  }

  void addPoint(Point p) {
    int geomIdx = _geometryIndexOf(p);
    if (p.isEmptyGeometry) return;
    _addCoordinate(geomIdx, p.coordinate, on: loc.INTERIOR);
  }

  void addLinestring(Linestring lstr) {
    int geomIdx = _geometryIndexOf(lstr);
    if (lstr.isEmptyGeometry)
      return;
    _addCoordinateList(geomIdx,
                       lstr.coordinates.toList(growable: false),
                       _addCoordinate(geomIdx, lstr.coordinates.first, on: loc.BOUNDARY),
                       _addCoordinate(geomIdx, lstr.coordinates.last, on: loc.BOUNDARY),
                       on: loc.INTERIOR);
  }

  void addPolygon(Polygon poly) {
    int geomIdx = _geometryIndexOf(poly);
    if (poly.isEmptyGeometry)
      return;

    //The location indicies directly to the left and right of the shell
    //of the polygon (holes are reversed)
    Tuple<int,int> leftRightShellLocations(bool isCounterClockwise) {
      return new Tuple(isCounterClockwise ? loc.INTERIOR : loc.EXTERIOR,
                       isCounterClockwise ? loc.EXTERIOR : loc.INTERIOR);
    }

    void addRingEdge(Ring r, bool isHole) {
      if (r.isEmptyGeometry)
        throw new GeometryError("Empty ring in polygon");
      List<Coordinate> coords = removeRepeatedCoordinates(r.coordinates);
      if (coords.length < 4)
        throw new GeometryError("Too few coordinates in polygon ring: $r");
      bool isCCW = cg_algorithms.isCounterClockwise(coords);
      var lrlocs = leftRightShellLocations(isCCW);
      if (isHole) {
        //The orientation of exterior and interior is the reverse for a hole
        //as it is for the shell.
        lrlocs = new Tuple(lrlocs.$2, lrlocs.$1);
      }
      //Add a single node to represent the start of the ring.
      var start = _addCoordinate(geomIdx, coords.first, on: loc.BOUNDARY);

      _addCoordinateList(geomIdx, coords, start, start,
          on: loc.BOUNDARY,
          left: lrlocs.$1,
          right: lrlocs.$2);
    }
    //Add a ring for the shell
    addRingEdge(poly.exteriorRing, false);
    //Add a ring for each of the holes
    poly.interiorRings.forEach((r) => addRingEdge(r, true));
  }

  void addGeometry(Geometry geom) {
    Geometry.dispatchToType(geom,
        applyPoint: addPoint,
        applyLinestring: addLinestring,
        applyPolygon: addPolygon,
        applyGeometryList: (geom) => geom.forEach(addGeometry));
  }

  int _geometryIndexOf(Geometry g) {
    for (var i in [1,2]) {
      var geom = geometries.project(i);
      if (identical(g, geom))
        return i;
      if (geom is GeometryList && geom.hasComponent(g))
        return i;
    }
    throw new ArgumentError("$g is not a graph geometry");
  }
}