
struct Snapshot {
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

  init(graph: AttributeGraph) {
    self.init(
      nodes: graph.nodes.map {
        Node(
          id: $0.id,
          name: $0.name,
          potentiallyDirty: $0.potentiallyDirty,
          value: String(describing: $0.value)
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
