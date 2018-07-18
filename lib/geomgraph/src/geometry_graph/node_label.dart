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


part of spatially.geomgraph.geometry_graph;

class Node implements GraphNodeLabel {
  final GeometryGraph graph;
  final Coordinate coordinate;
  final Tuple<Location,Location> locations;

  GraphNode<Node> get _delegate => graph._delegate.nodeByLabel(this);

  Iterable<Edge> get terminatingEdges =>
      _delegate.terminatingEdges.map((e) => e.label);

  Node._(this.graph, this.coordinate, this.locations);

  bool get isIsolated => _delegate.isIsolated;

  bool operator ==(Object other) =>
      other is Node && other.coordinate == coordinate;

  int get hashCode => coordinate.hashCode;

  String toString() => "node: $coordinate";


}