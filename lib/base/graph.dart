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


library spatially.base.graph;

import 'dart:collection';
import 'package:quiver/collection.dart';
import 'package:collection/collection.dart';
import 'package:collection/equality.dart';

part 'src/graph/edge.dart';
part 'src/graph/error.dart';
part 'src/graph/label.dart';
part 'src/graph/node.dart';

const UnorderedIterableEquality _setEq = const UnorderedIterableEquality();

/**
 * A [Graph] abstractly represents the connectivity between elements of a set of objects.
 *
 * Each of the elements is represented by a [GraphNode], and each connection,
 * which can be either directed or undirected, is represented by a [GraphEdge].
 * There can be at most one [GraphEdge] between any two [GraphNode]s in the graph.
 *
 * A strong seperation is preserved between the data underlying the connections
 * and the connectivity. Every node and edge is labelled by an [GraphNodeLabel] or
 * [GraphEdgeLabel] respectively.
 *
 * Every edge and node in the graph must be labelled, and this label is expected
 * to serve as a unique identifier for the graph element. This way the connectivity
 * by the elements of the graph can be analysed without requiring knowledge of the
 * implementation domain.
 *
 * Typically, when implementing a [Graph], the implementing class would identify
 * nodes and edges from the implementation domain and define node and edge labels
 * which inherit from [GraphNodeLabel] and [GraphEdgeLabel] respectively.
 *
 * Thus a user of the implementing class sees the edges and nodes as they appear
 * in the dataset, but the implementation can delegate all information about
 * connectivity to the underlying [Graph], exposing methods from the [Graph]
 * which are appropriate to the domain.
 */
class Graph<N extends GraphNodeLabel, E extends GraphEdgeLabel> {
  final BiMap<N,GraphNode<N>> _labelledNodes;
  final BiMap<E,GraphEdge<E>> _labelledEdges;

  /**
   * `true` if the edges have a natural ordering around a node.
   */
  final bool starAtNode;

  /**
   * Create a new [Graph].
   * If [:starAtNode:] is `true`, then the edge will be ordered by the result
   * of [GraphEdgeLabel].compareAtNode. Default is `false`.
   */
  Graph({this.starAtNode: false}) :
    _labelledNodes = new BiMap(),
    _labelledEdges = new BiMap();

  Iterable<GraphNode<N>> get nodes => _labelledNodes.values;
  Iterable<GraphEdge<E>> get edges => _labelledEdges.values;

  Iterable<DirectedEdge<E>> get directedEdge => edges.where((e) => !e.isDirected);
  Iterable<DirectedEdge<E>> get undirectedEdges => edges.where((e) => e.isDirected);

  /**
   * Return any undirected edge which is labelled with either the label or the
   * reversed label, or any directed edge which matches the label
   */
  GraphEdge<E> edgeByLabel(E label) {
    var samedir = _labelledEdges[label];
    if (samedir != null) return samedir;
    var oppdir = _labelledEdges[label.reversed];
    if (oppdir != null && !oppdir.isDirected)
      return oppdir;
  }

  DirectedEdge<E> directedEdgeByLabel(E label) {
    var edge = _labelledEdges[label];
    if (edge is DirectedEdge<E>)
      return edge;
    return null;
  }

  UndirectedEdge<E> undirectedEdgeByLabel(E label) {
    var edge = edgeByLabel(label);
    if (edge is UndirectedEdge)
      return edge;
  }

  /**
   * Returns the node with the given label, or `null` if no such node
   * exists in the graph.
   */
  GraphNode<N> nodeByLabel(N label) => _labelledNodes[label];

  /**
   * If a node with the given label exists in the graph, returns the node.
   * Otherwise adds a node with the specified label into the graph.
   */
  GraphNode<N> addNode(N label) {
    if (label == null) throw new ArgumentError("null label");
    //TODO (ovangle): BiMap incorrectly returns `null` from putIfAbsent
    //                Return the result when it's updated.
    _labelledNodes
        .putIfAbsent(label, () => new GraphNode(this, label));
    return _labelledNodes[label];
  }

  /**
   * Removes the node labelled by the specified label.
   * It is an error to add a node with any connected edges.
   */
  GraphNode<N> removeNode(N label) {
    var node = _labelledNodes[label];
    if (node == null) return null;
    if (node.terminatingEdges.isNotEmpty) {
      throw new GraphError("Node has connections");
    }
    return node;

  }


  /**
   * Adds a directed edge to the graph, travelling from the start node to the end node and
   * returns the returned [DirectedEdge]. If an edge already exists with the specified
   * label (or it's reverse), throws a [GraphError].
   *
   * If a connection already exists between [:start:] and [:end:], a new label created
   * by merging the connection's label and the argument label will be created
   * and the connection will be replaced by a connection with the merged label.
   */
  GraphEdge<E> addDirectedEdge(E label, GraphNode<N> start, GraphNode<N> end) {
    if (label == null) throw new ArgumentError("null label");
    if (start == null) throw new ArgumentError("null start");
    if (end == null) throw new ArgumentError("null end");
    if (_labelledEdges.containsKey(label)) {
      var existing = _labelledEdges[label];
      //Check whether the existing node is in the same direction as this.
      if (!existing.isDirected
          || existing.startNode != start
          || existing.endNode != end) {
        throw new GraphError("Graph contains edge with label $label");
      }
    }
    var rlabel = label.reversed;
    if (_labelledEdges.containsKey(rlabel)) {
      var existing = _labelledEdges[label];
      throw new GraphError("Graph contains edge with label $rlabel");
    }
    var mergedLabel = _mergeLabel(label, start, end);
    var edge = new DirectedEdge._(this, mergedLabel, start, end);
    return _addEdge(edge);
  }

  /**
   * Add an undirected edge to the graph between the given [:start:] and [:end:] nodes.
   *
   */
  GraphEdge<E> addUndirectedEdge(E label, GraphNode<N> start, GraphNode<N> end) {
    if (label == null) throw new ArgumentError("null label");
    if (start == null) throw new ArgumentError("null start");
    if (end == null) throw new ArgumentError("null end");
    if (_labelledEdges.containsKey(label)) {
      var existing = _labelledEdges[label];
      if (!existing.isDirected
          && !_setEq.equals([start,end], existing.terminatingNodes)) {
        throw new GraphError("Graph contains edge with label $label and different terminating nodes");
      }
    }
    var rlabel = label.reversed;
    if (_labelledEdges.containsKey(rlabel)) {
      var existing = _labelledEdges[rlabel];
      if (existing.isDirected
          && !_setEq.equals([start,end], existing.terminatingNodes)) {
        throw new GraphError("Graph contains edge with label $label and different terminating nodes");
      }
    }
    var mergedLabel = _mergeLabel(label, start, end);
    var edge = new UndirectedEdge._(this, mergedLabel, start, end);
    return _addEdge(edge);
  }

  E _mergeLabel(E label, GraphNode<N> start, GraphNode<N> end) {
    var connection = start.connection(end);
    if (connection != null) {
      //We'll add the connection back in _addEdge, but with a different label.
      _removeEdge(connection);
      return connection.label.merge(label);
    }
    return label;
  }

  _addEdge(GraphEdge<E> edge) {
    //Add the edge in first, because we might want to access it from the labels
    //delegate if we have ordered labels.
    _labelledEdges[edge.label] = edge;
    edge.startNode._outgoingEdges.add(edge);
    edge.endNode._incomingEdges.add(edge);
    if (!edge.isDirected) {
      edge.startNode._incomingEdges.add(edge);
      edge.endNode._outgoingEdges.add(edge);
    }
    return _labelledEdges[edge.label];
  }

  /**
   * Removes the [GraphEdge] labelled with [:label:] from the edge. Returns the removed edge, or `null`
   * if none was removed.
   */
  GraphEdge<E> removeEdge(E label) {
    var edge = edgeByLabel(label);
    return edge != null ? _removeEdge(edge) : null;
  }

  _removeEdge(GraphEdge<E> edge) {
    edge.startNode._outgoingEdges.remove(edge);
    edge.endNode._incomingEdges.remove(edge);
    if (!edge.isDirected) {
      edge.startNode._incomingEdges.remove(edge);
      edge.endNode._outgoingEdges.remove(edge);
    }
    _labelledEdges.inverse.remove(edge);
    return edge;
  }


  /**
   * Replace the existing edge with the given label with the specified edge.
   * Throws a [GraphError] if
   * * No edge with label [:label:] or [:label.reversed:] exists in the graph.
   * * The existing edge is undirected and the terminating nodes of the existing edge
   *   are not the same as the terminating nodes of the replacement
   * * A directed edge with the reversed label is found in the graph and the start node
   *   is not equal to the end node of the replacement
   * * A directed edge with the reversed label is found in the graph and the end node
   *   is not equal to the end node of the replacement
   * * The existing edge is directed and the start node of the existing edge is not
   *   equal to the start node of the replacement
   * * The existing edge is directed and the end node of the existing edge is not
   *   equal to the end node of the replacement
   */
  GraphEdge<E> replaceEdge(E label, GraphEdge<E> replacement) {
    var edge = edgeByLabel(label);
    if (edge != null) {
      if (edge.isDirected) {
        if (edge.startNode != replacement.startNode) {
          throw new GraphError('existing edge is directed and the start nodes are unequal');
        }
        if (edge.endNode != replacement.endNode) {
          throw new GraphError('existing edge is directed and the end nodes are unequal');
        }
        _removeEdge(edge);
        return _addEdge(replacement);
      } else {
        if (_setEq.equals(edge.terminatingNodes, replacement.terminatingNodes)) {
          _removeEdge(edge);
          return _addEdge(replacement);
        }
        throw new GraphError("existing edge was undirected and terminating nodes not setwise equal"
                             "with replacement");
      }
    }
    throw new GraphError("No label with label $label was found in graph");
  }

}