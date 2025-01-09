
public struct Snapshot {
  let nodes: [Node]
  let edges: [Edge]
}

extension Snapshot {

  struct Node {
    let id: NodeID
    let name: String
    let potentiallyDirty: Bool
    let value: String
  }


  struct Edge {
    let from: NodeID
    let to: NodeID
    let pending: Bool
  }
}

extension Snapshot {

  public init(graph: AttributeGraph) {
    self.init(
      nodes: graph.nodes.map {
        Node(
          id: $0.id,
          name: $0.name,
          potentiallyDirty: $0.potentiallyDirty,
          value: $0.value.map { String(describing: $0) } ?? "<nil>"
        )
      },
      edges: graph.nodes.flatMap { node in
        node.outgoingEdges.map {
          Edge(
            from: $0.from.id,
            to: $0.to.id,
            pending: $0.pending)
        }
      }
    )
  }
}

// MARK: - Graphviz

extension Snapshot {
  public var dot: String {
    let value = """
    digraph {
    \(nodes.map(\.dot).map { "  " + $0 }.joined(separator: "\n"))
    \(edges.map(\.dot).map { "  " + $0 }.joined(separator: "\n"))
    }
    """
    return value
  }
}

extension String {
  var escaped: String {
    replacing("\"", with: "\\\"")
  }
}

extension Snapshot.Node {
  fileprivate var dot: String {
    #"\#(id) [label="\#(name) (\#(value.escaped))", style=\#(potentiallyDirty ? "filled" : "solid") shape=rect]"#
  }
}

extension Snapshot.Edge {
  fileprivate var dot: String {
    "\(from) -> \(to) [style=\(pending ? "dashed" : "solid")]"
  }
}
