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


part of spatially.operation.overlay;

class _LinestringBuilder extends _OverlayBuilder {
  _LinestringBuilder(graph, overlayType) : super._(graph, overlayType);

  Geometry build() {

    for (var edge in graph.edges.toList(growable:false)) {
      var onLocations = edge.locations.map<int>((l) => l.on);
      if (!_inOverlay(onLocations)) {
        graph.removeEdge(edge);
      }
    }

    if (graph.edges.isEmpty)
      return geomFactory.createEmptyLinestring();

    List<Linestring> lstrs = [];
    while (!graph.edges.isEmpty) {
      var edge = graph.edges.first;
      lstrs.add(_buildLinestring(edge));
    }

    switch (lstrs.length) {
      case 0:
        return geomFactory.createEmptyLinestring();
      case 1:
        return lstrs.single;
      default:
        return geomFactory.createMultiLinestring(lstrs);
    }
  }

  Linestring _buildLinestring(Edge edge) {
    LinkedList<Coordinate> lstrCoords = new LinkedList.from(edge.coordinates);
    _extendStart(edge, edge.startNode, lstrCoords, false);
    _extendEnd(edge, edge.endNode, lstrCoords);
    return geomFactory.createLinestring(lstrCoords);
  }

  _extendStart(Edge edge, Node node, LinkedList<Coordinate> lstrCoords, [bool removeEdge=true]) {
    bool foundEdge = false;
    for (Edge e in node.terminatingEdges) {
      if (e == edge) {
        foundEdge = true;
        continue;
      }
      if (foundEdge) {
        var edgeBefore = e;
        if (edgeBefore.coordinates.first == lstrCoords.first) {
          edgeBefore.coordinates.skip(1).forEach(lstrCoords.addFirst);
        } else {
          edgeBefore.reversed.coordinates.skip(1).forEach(lstrCoords.addFirst);
        }
        if (node == edge.startNode) {
          _extendStart(edgeBefore, edgeBefore.endNode, lstrCoords);
        } else {
          _extendStart(edgeBefore, edgeBefore.startNode, lstrCoords);
        }
        if (removeEdge) {
          edge.graph.removeEdge(edge);
        }
      }
    }
    if (node.isIsolated) {
      print("removing: $node");
      graph.removeNode(node);
    }
  }

  _extendEnd(Edge edge, Node node, LinkedList<Coordinate> lstrCoords) {
    Edge prevEdge, edgeAfter;
    for (Edge e in node.terminatingEdges) {
      if (e == edge) {
        if (prevEdge == null) {
          edgeAfter = node.terminatingEdges.last;
          break;
        }
        edgeAfter = prevEdge;
      }
      prevEdge = e;
    }
    if (edgeAfter == edge) {
      edge.graph.removeEdge(edge);
      return;
    }
    if (edgeAfter.coordinates.first == lstrCoords.last) {
      lstrCoords.addAll(edgeAfter.coordinates.skip(1));
    } else {
      lstrCoords.addAll(edgeAfter.reversed.coordinates.skip(1));
    }
    if (edgeAfter.startNode == edgeAfter.endNode) {
      //Loop in graph.
      graph.removeEdge(edgeAfter);
    }
    if (edgeAfter.startNode == node) {
      _extendEnd(edgeAfter, edgeAfter.endNode, lstrCoords);
    } else {
      _extendEnd(edgeAfter, edgeAfter.startNode, lstrCoords);
    }
    graph.removeEdge(edgeAfter);
    if (node.isIsolated) {
      print("removing: $node");
      graph.removeNode(node);
    }
  }
}