
final class AttributeGraph {
  var nodes: [AnyNode] = []
  var currentNode: AnyNode?

  func input<Value>(name: String, _ value: Value) -> Node<Value> {
    let node = Node(name: name, graph: self, wrappedValue: value)
    nodes.append(node)
    return node
  }

  func rule<Value>(name: String, _ rule: @escaping () -> Value) -> Node<Value> {
    let node = Node(name: name, graph: self, rule: rule)
    nodes.append(node)
    return node
  }

  var graphViz: String {

    let nodes = self.nodes
      .map { "\($0.name)\($0.potentiallyDirty ? " [style=dashed]" : "")" }
      .joined(separator: "\n")

    let edges = self.nodes
      .flatMap(\.outgoingEdges)
      .map { "\($0.from.name) -> \($0.to.name)\($0.pending ? " [style=dashed]" : "")" }
      .joined(separator: "\n")

    return """
    digraph {
    \(nodes)
    \(edges)
    }
    """
  }
}

final class Edge {
  unowned let from: AnyNode
  unowned let to: AnyNode
  var pending = false

  init(from: AnyNode, to: AnyNode) {
    self.from = from
    self.to = to
  }
}

protocol AnyNode: AnyObject {
  var name: String { get }
  var outgoingEdges: [Edge] { get set }
  var incomingEdges: [Edge] { get set }
  var potentiallyDirty: Bool { get set }
  func recomputeIfNeeded()
}

final class Node<Value>: AnyNode {
  unowned var graph: AttributeGraph
  let name: String
  var rule: (() -> Value)?
  var incomingEdges: [Edge] = []
  var outgoingEdges: [Edge] = []
  var potentiallyDirty = false {
    didSet {
      guard potentiallyDirty, potentiallyDirty != oldValue else { return }
      for edge in outgoingEdges {
        edge.to.potentiallyDirty = true
      }
    }
  }

  private var cachedValue: Value?

  var wrappedValue: Value {
    get {
      recomputeIfNeeded()
      return cachedValue!
    }
    set {
      assert(rule == nil)
      cachedValue = newValue
      for edge in outgoingEdges {
        edge.pending = true
        edge.to.potentiallyDirty = true
      }
    }
  }

  func recomputeIfNeeded() {

    // Record dependency
    if let node = graph.currentNode {
      let edge = Edge(from: self, to: node)
      outgoingEdges.append(edge)
      node.incomingEdges.append(edge)
    }

    guard let rule else { return }

    if !potentiallyDirty && cachedValue != nil { return }

    for edge in incomingEdges {
      edge.from.recomputeIfNeeded()
    }

    let hasPendingIncomingEdge = incomingEdges.contains(where: \.pending)
    potentiallyDirty = false

    if hasPendingIncomingEdge || cachedValue == nil {
      let previousNode = graph.currentNode
      defer { graph.currentNode = previousNode }
      graph.currentNode = self
      let isInitial = cachedValue == nil
      removeIncomingEdges()
      cachedValue = rule()
      // TODO: Only if cachedValue has changed
      if !isInitial {
        for edge in outgoingEdges {
          edge.pending = true
        }
      }
    }
  }

  func removeIncomingEdges() {
    for edge in incomingEdges {
      edge.from.outgoingEdges.removeAll(where: { $0 === edge })
    }
    incomingEdges = []
  }

  init(name: String, graph: AttributeGraph, wrappedValue: Value) {
    self.name = name
    self.graph = graph
    self.cachedValue = wrappedValue
  }

  init(name: String, graph: AttributeGraph, rule: @escaping () -> Value) {
    self.name = name
    self.graph = graph
    self.rule = rule
  }
}
