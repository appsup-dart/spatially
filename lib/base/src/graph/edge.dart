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


part of spatially.base.graph;

abstract class GraphEdge<E extends GraphEdgeLabel> {
  final Graph<GraphNodeLabel,E> graph;
  final E label;
  final GraphNode startNode;
  final GraphNode endNode;

  Iterable<GraphNode> get terminatingNodes => [startNode, endNode];

  GraphEdge(this.graph, this.label, this.startNode, this.endNode);

  bool get isDirected;

  /*
   * Returns a copy of this edge as an undirected edge without modifying the graph.
   *
   * In order to replace the existing edge by the returned copy, call `replace` on the result.
   */
  UndirectedEdge<E> asUndirectedEdge();
  /**
   * Returns a copy of this edge as a directed edge without modifying the graph.
   * If [:asForward:] is `true`, the copy returned will have the roles of [:startNode:]
   * and [:endNode:] reversed and the label reversed.
   *
   * In order to replace the edge by the returned copy, call `replace` on the result.
   */
  DirectedEdge<E> asDirectedEdge({bool asForward});
}

class UndirectedEdge<E extends GraphEdgeLabel> extends GraphEdge<E> {

  UndirectedEdge._(Graph<GraphNodeLabel,E> graph,
                   GraphEdgeLabel label,
                   GraphNode startNode,
                   GraphNode endNode) : super(graph, label, startNode, endNode);

  bool get isDirected => false;

  UndirectedEdge<E> asUndirectedEdge() => this;

  DirectedEdge<E> asDirectedEdge({bool asForward: true}) {
    if (asForward) {
      return new DirectedEdge._(graph, label, startNode, endNode);
    } else {
      return new DirectedEdge._(graph, label.reversed, endNode, startNode);
    }
  }


  /**
   * Equality between undirected edges is based of their start and end nodes,
   * since a label is guaranteed to be unique for any edge with specified
   * terminating nodes
   */
  bool operator ==(Object other) {
    if (other is UndirectedEdge) {
      if (other.startNode == startNode)
        return other.endNode == endNode;
      if (other.endNode == startNode)
        return other.startNode == endNode;
    }
    return false;
  }

  int get hashCode {
    int hash = 0;
    hash += (startNode.hashCode + endNode.hashCode) * 39;
    return hash;
  }

  String toString() => "undirected ($label)";

}

class DirectedEdge<E extends GraphEdgeLabel> extends GraphEdge<E> {

  DirectedEdge._(Graph<GraphNodeLabel,E> graph,
                 GraphEdgeLabel label,
                 GraphNode startNode,
                 GraphNode endNode) : super(graph, label, startNode, endNode);

  bool get isDirected => true;

  /**
   * Returns an [UndirectedEdge] with the same values as `this`.
   * The graph is unchanged and the returned edge will not exist as an edge
   * in the map.
   */
  UndirectedEdge<E> asUndirectedEdge() =>
      new UndirectedEdge._(graph, label, startNode, endNode);

  /**
   * Returns a [DirectedEdge] with the same label as `this`.
   * If `asForward` is `false`, the returned edge will have a reversed label
   * and the start and end nodes will swap their roles.
   */
  DirectedEdge<E> asDirectedEdge({bool asForward: true}) {
    if (asForward) return this;
    return new DirectedEdge._(graph, label.reversed, endNode, startNode);
  }

  bool operator ==(Object other) =>
      other is DirectedEdge
      //Need to test the label on a directed edge to deal with the case of a
      //backward edge with the same start and end nodes.
      && other.label == label
      && other.startNode == startNode
      && other.endNode == endNode;

  int get hashCode {
    int hash = 0;
    hash += label.hashCode * 37;
    hash += startNode.hashCode * 37;
    hash += endNode.hashCode * 37;
    return hash;
  }

  String toString() => "directed ($label)";
}

