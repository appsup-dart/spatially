library spatially.base.graph.graph_test;

import 'package:test/test.dart';

import 'package:spatially/base/graph.dart';


class MockNodeLabel implements GraphNodeLabel {
  int id;

  MockNodeLabel(int this.id);

  bool operator ==(Object other) =>
      other is MockNodeLabel && id == other.id;
  int get hashCode => id;

  String toString() => "$id";
}

class MockEdgeLabel implements GraphEdgeLabel {
  int id1;
  int id2;
  bool isMerged = false;

  MockEdgeLabel(this.id1, this.id2);

  MockEdgeLabel get reversed => new MockEdgeLabel(id2, id1);

  MockEdgeLabel merge(MockEdgeLabel label) {
    isMerged = true;
    return this;
  }

  bool operator ==(Object other) =>
      other is MockEdgeLabel && id1 == other.id1 && id2 == other.id2;

  int get hashCode =>
      17 * id1 + id2;

  String toString() => "$id1 -> $id2";

  int compareOrientation(MockNodeLabel nodeLabel, MockEdgeLabel edgeLabel) {
    if (nodeLabel.id == id1) {
      return edgeLabel.id1 == nodeLabel.id
          ? id2.compareTo(edgeLabel.id2)
          : id2.compareTo(edgeLabel.id1);
    } else if (nodeLabel.id == id2) {
      return edgeLabel.id1 == nodeLabel.id
          ? id1.compareTo(edgeLabel.id2)
          : id1.compareTo(edgeLabel.id1);
    } else {
      assert(false);
    }
  }
}

void main() {
  group("graph", () {
    test("should be able to add a node to the graph", () {
      Graph<MockNodeLabel,MockEdgeLabel> graph = new Graph();
      var n1 = graph.addNode(new MockNodeLabel(1));
      expect(n1.label, new MockNodeLabel(1));
      expect(graph.nodes, [n1]);

      var n2 = graph.addNode(new MockNodeLabel(2));
      expect(graph.nodes, unorderedEquals([n1, n2]));
    });

    //TODO: remove node.

    Graph<MockNodeLabel,MockEdgeLabel> graph = new Graph();
    var n1 = graph.addNode(new MockNodeLabel(1));
    var n2 = graph.addNode(new MockNodeLabel(2));
    var n3 = graph.addNode(new MockNodeLabel(3));

    test("should be able to add a directed edge to the graph", () {
      var e12 = graph.addDirectedEdge(new MockEdgeLabel(1,2), n1, n2);
      expect(e12.startNode, n1);
      expect(e12.endNode, n2);
      expect(e12.label, new MockEdgeLabel(1,2));
      expect(graph.edges, [e12]);
      expect(n1.outgoingEdges, [e12], reason: "start outgoing edges");
      expect(n1.incomingEdges, [], reason: "start incoming edges");
      expect(n2.incomingEdges, [e12], reason: "end incoming edges");
      expect(n2.outgoingEdges, [], reason: "end outgoing edges");
    });

    test("should throw if trying to add a directed edge with the same label but different start and end nodes", () {
      expect(() => graph.addDirectedEdge(new MockEdgeLabel(1,2), n1, n2), returnsNormally, reason: "edge already in graph");
      expect(() => graph.addDirectedEdge(new MockEdgeLabel(1,2), n1, n3), throws, reason: "bad end");
      expect(() => graph.addDirectedEdge(new MockEdgeLabel(1,2), n3, n1), throws, reason: "bad start");
      expect(() => graph.addDirectedEdge(new MockEdgeLabel(2,1), n2, n1), throws, reason: "reverse label");
    });

    test("should merge the edges when adding a label between the same start and end nodes", () {
      var e = graph.addDirectedEdge(new MockEdgeLabel(2,4), n1, n2);
      expect(e.label, new MockEdgeLabel(1,2));
      expect(e.label.isMerged, isTrue);
      expect(graph.edges, [e]);
    });

    test("should be able to remove an edge from the graph", () {
      var r = graph.removeEdge(graph.edges.single.label);
      expect(r.label, new MockEdgeLabel(1,2));
      expect(graph.edges, []);
      expect(n1.terminatingEdges, []);
      expect(n2.terminatingEdges, []);

      var r2 = graph.removeEdge(new MockEdgeLabel(2,3));
      expect(r2, isNull, reason: "no existing edge with label");
    });

    test("should be able to add an undirected edge to the graph", () {
      var e12 = graph.addUndirectedEdge(new MockEdgeLabel(1,2), n1, n2);
      expect(e12.label, new MockEdgeLabel(1,2));
      expect(e12.terminatingNodes, unorderedEquals([n1,n2]));
      expect(e12.isDirected, isFalse);
      expect(n1.outgoingEdges, [e12], reason: "start outgoing edges");
      expect(n1.incomingEdges, [e12], reason: "start incoming edges");
      expect(n2.incomingEdges, [e12], reason: "end outgoing edges");
      expect(n2.outgoingEdges, [e12], reason: "end incoming edges");
    });

    test("should throw when trying to add an edge with the same label but different terminating nodes", () {
      expect(() => graph.addUndirectedEdge(new MockEdgeLabel(1,2), n1, n2), returnsNormally, reason: "same undirected edge");
      expect(() => graph.addUndirectedEdge(new MockEdgeLabel(2,1), n2, n1), returnsNormally, reason: "reverse undirected edge");
      expect(() => graph.addUndirectedEdge(new MockEdgeLabel(1,2), n1, n3), throws, reason: "bad start");
      expect(() => graph.addUndirectedEdge(new MockEdgeLabel(1,2), n3, n2), throws, reason: "bad start");
      expect(graph.edges.map((e) => e.label), [new MockEdgeLabel(1,2)]);
    });

    test("adding an edge between the same start and end nodes should merge the nodes", () {
      var e23 = graph.addUndirectedEdge(new MockEdgeLabel(2,3), n2, n3);
      var e46 = graph.addUndirectedEdge(new MockEdgeLabel(4,6), n2, n3);
      expect(e46.label.isMerged, isTrue);
      expect(graph.edges.map((e) => e.label),
             unorderedEquals([new MockEdgeLabel(1,2),
                              new MockEdgeLabel(2,3)
                             ]));
    });

    test("should be able to replace an undirected edge by a directed edge", () {
      var e23u = graph.edgeByLabel(new MockEdgeLabel(2,3));
      expect(e23u.isDirected, isFalse);
      var e23 = graph.replaceEdge(e23u.label, e23u.asDirectedEdge(asForward: true));
      expect(e23.label, new MockEdgeLabel(2,3));
      expect(e23.isDirected, isTrue);
      expect(graph.edges.map((e) => e.label),
             unorderedEquals([new MockEdgeLabel(2,3),
                              new MockEdgeLabel(1,2)]));
      graph.removeEdge(e23.label);

      //Replace by backward edge.
      var e32u = graph.addUndirectedEdge(new MockEdgeLabel(3,2), n3, n2);
      e23 = graph.replaceEdge(e32u.label, e32u.asDirectedEdge(asForward: false));
      expect(e23.label, new MockEdgeLabel(2,3));
      expect(e23.startNode, n2);
      expect(e23.endNode, n3);
    });

    test("a graph without orderedEdges will not order the edges", () {
      Graph<MockNodeLabel,MockEdgeLabel> graph = new Graph();
      var n0 = graph.addNode(new MockNodeLabel(0));
      var n1 = graph.addNode(new MockNodeLabel(1));
      var n2 = graph.addNode(new MockNodeLabel(2));
      var n3 = graph.addNode(new MockNodeLabel(3));
      var n4 = graph.addNode(new MockNodeLabel(4));

      var e01 = graph.addUndirectedEdge(new MockEdgeLabel(0,1), n0, n1);
      var e30 = graph.addDirectedEdge(new MockEdgeLabel(3,0), n3, n0);
      var e05 = graph.addUndirectedEdge(new MockEdgeLabel(0,4), n0, n4);
      var e02 = graph.addDirectedEdge(new MockEdgeLabel(0,2), n0, n2);
      var e60 = graph.addDirectedEdge(new MockEdgeLabel(0,0), n0, n0);
      var node = graph.nodeByLabel(new MockNodeLabel(0));

      expect(node.terminatingEdges.map((e) => e.label),
            unorderedEquals(
                [ new MockEdgeLabel(0,0),
                  new MockEdgeLabel(0,1),
                  new MockEdgeLabel(0,2),
                  new MockEdgeLabel(3,0),
                  new MockEdgeLabel(0,4)]));


      expect(node.terminatingEdges.map((e) => e.label),
            isNot(
                [ new MockEdgeLabel(0,0),
                  new MockEdgeLabel(0,1),
                  new MockEdgeLabel(0,2),
                  new MockEdgeLabel(3,0),
                  new MockEdgeLabel(0,4)]),
             reason: "the edges should not be ordered at n0");


    });

    test("a graph with orderedEdges will order the edges around the node", () {
      Graph<MockNodeLabel,MockEdgeLabel> graph = new Graph(starAtNode: true);
      var n0 = graph.addNode(new MockNodeLabel(0));
      var n1 = graph.addNode(new MockNodeLabel(1));
      var n2 = graph.addNode(new MockNodeLabel(2));
      var n3 = graph.addNode(new MockNodeLabel(3));
      var n4 = graph.addNode(new MockNodeLabel(4));

      var e01 = graph.addUndirectedEdge(new MockEdgeLabel(0,1), n0, n1);
      var e30 = graph.addDirectedEdge(new MockEdgeLabel(3,0), n3, n0);
      var e05 = graph.addUndirectedEdge(new MockEdgeLabel(0,4), n0, n4);
      var e02 = graph.addDirectedEdge(new MockEdgeLabel(0,2), n0, n2);
      var e60 = graph.addDirectedEdge(new MockEdgeLabel(0,0), n0, n0);
      var node = graph.nodeByLabel(new MockNodeLabel(0));

      expect(node.terminatingEdges.map((e) => e.label),
            [ new MockEdgeLabel(0,0),
              new MockEdgeLabel(0,1),
              new MockEdgeLabel(0,2),
              new MockEdgeLabel(3,0),
              new MockEdgeLabel(0,4)]);


    });


  });

  group("node", () {

    group("isolated", () {
      var graph = new Graph();
      var n0 = graph.addNode(new MockNodeLabel(0));
      test("a node with no terminating edges should be isolated", () {
        expect(n0.isIsolated, isTrue);
      });
      test("a graph with terminating edges should not be isolated", () {
        graph.addUndirectedEdge(new MockEdgeLabel(0,0), n0, n0);
        expect(n0.isIsolated, isFalse);
      });
    });

    group("connection", () {
      var graph = new Graph();
      var n0 = graph.addNode(new MockNodeLabel(0));
      var n1 = graph.addNode(new MockNodeLabel(1));
      var n2 = graph.addNode(new MockNodeLabel(2));
      test("adding an edge should connect two nodes", () {
        var e01 = graph.addUndirectedEdge(new MockEdgeLabel(0,1), n0, n1);
        expect(n0.connection(n1), e01);
        var e02 = graph.addUndirectedEdge(new MockEdgeLabel(0,2), n0, n2);
        expect(n0.connection(n2), e02);
      });

      test("removing an edge should remove the connection between two nodes", () {
        graph.removeEdge(new MockEdgeLabel(0,1));
        expect(n0.connection(n1), null);
        expect(n0.connection(n2).label, new MockEdgeLabel(0,2));
      });
    });
  });


}