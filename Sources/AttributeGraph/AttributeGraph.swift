
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
      .map(\.name)
      .joined(separator: "\n")

    let edges = self.nodes
      .flatMap(\.outgoingEdges)
      .map { "\($0.from.name) -> \($0.to.name)" }
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

  init(from: AnyNode, to: AnyNode) {
    self.from = from
    self.to = to
  }
}

protocol AnyNode: AnyObject {
  var name: String { get }
  var outgoingEdges: [Edge] { get }
  var incomingEdges: [Edge] { get set }
}

final class Node<Value>: AnyNode {
  unowned var graph: AttributeGraph
  let name: String
  var rule: (() -> Value)?
  var incomingEdges: [Edge] = []
  var outgoingEdges: [Edge] = []

  private var cachedValue: Value?

  var wrappedValue: Value {
    get {
      recomputeIfNeeded()
      return cachedValue!
    }
    set {
      assert(rule == nil)
      cachedValue = newValue
    }
  }

  func recomputeIfNeeded() {
    if let node = graph.currentNode {
      let edge = Edge(from: self, to: node)
      outgoingEdges.append(edge)
      node.incomingEdges.append(edge)
    }
    if cachedValue == nil, let rule {
      let previousNode = graph.currentNode
      defer { graph.currentNode = previousNode }
      graph.currentNode = self
      cachedValue = rule()
    }
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
