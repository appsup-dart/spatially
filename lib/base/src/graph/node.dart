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

class GraphNode<N extends GraphNodeLabel> {
  final Graph<N,GraphEdgeLabel> graph;
  final GraphNodeLabel label;

  Set<GraphEdge> _outgoingEdges;
  Set<GraphEdge> _incomingEdges;

  GraphNode(Graph<N,GraphEdgeLabel> this.graph, GraphNodeLabel this.label) {
    _outgoingEdges = (graph.starAtNode ? new SplayTreeSet(_compareEdges) : new Set());
    _incomingEdges = (graph.starAtNode ? new SplayTreeSet(_compareEdges) : new Set());
  }

  UnmodifiableSetView<GraphEdge> get outgoingEdges =>
      new UnmodifiableSetView(_outgoingEdges);
  UnmodifiableSetView<GraphEdge> get incomingEdges =>
      new UnmodifiableSetView(_incomingEdges);

  UnmodifiableSetView<GraphEdge> get terminatingEdges =>
      new UnmodifiableSetView(_outgoingEdges.union(_incomingEdges));

  /**
   * Returns all edges which run between `this` and [node]
   */
  GraphEdge connection(GraphNode node) {
    var commonEdges;
    if (node == this) {
      //If we're looking for loops, don't take the intersection, because
      //that will return all edges at this node.
      commonEdges = terminatingEdges
          .where((e) => e.startNode == this && e.endNode == this);
    } else {
      commonEdges =
          new HashSet.from(node.terminatingEdges)
          .intersection(new HashSet.from(terminatingEdges));
    }
    if (commonEdges.isEmpty)
      return null;
    return commonEdges.single;
  }

  /**
   * A [GraphNode] is isolated if no edges in the graph terminate at the node.
   */
  bool get isIsolated => terminatingEdges.isEmpty;

  bool operator ==(Object other) =>
      other is GraphNode<N> && other.label == label;

  int get hashCode => label.hashCode;

  String toString() => "node: $label";

  int _compareEdges(GraphEdge edge1, GraphEdge edge2) =>
      edge1.label.compareOrientation(this.label, edge2.label);

}