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

abstract class GraphLabel {}

abstract class GraphEdgeLabel extends GraphLabel {

  /**
   * Represents an edge label of a directed edge which is travelling in
   * the reverse direction (from the [:endNode:] of the edge it is attached to
   * to the [:startNode:].
   */
  GraphEdgeLabel get reversed;

  /**
   * Merges two [GraphEdgeLabel]s together to form a new label.
   * This is called when adding an edge to the graph when an existing edge
   * already exists between the start and end nodes of the edge.
   *
   * A [Graph] can only possess one edge between any two nodes, so this method is to
   * provide a method of multiplexing edges. If the multiplicity of edges
   * is not important, then the method should return `this`.
   */
  GraphEdgeLabel merge(covariant GraphEdgeLabel label);

  /**
   * Used to order the graph edges around the terminating node.
   * [node] will always be one of the terminating node of the edge
   * labelled by `this` and [other] will always be an edge which
   * also terminates at the node.
   *
   * If the [Graph] is not created with [:starAtNode:] set to `true`, then the
   * method is ignored.
   *
   * The method should return
   * `1` if `this` should appear after [other] in the [List] of terminating
   * edges at the node.
   * `0` if the order of the edges when fetched from [node] doesn't matter.
   * `-1` if `other` should appear before `this` in the [List] of the terminating
   * edges at the node.
   */
  int compareOrientation(covariant GraphNodeLabel node, covariant GraphEdgeLabel other) {
    throw new UnimplementedError("EdgeLabel.compareOrientation");
  }

}

abstract class GraphNodeLabel extends GraphLabel {

}