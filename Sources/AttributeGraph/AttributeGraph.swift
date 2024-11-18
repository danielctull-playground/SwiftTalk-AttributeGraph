
final class AttributeGraph {
  var nodes: [AnyNode] = []

  func input<Value>(name: String, _ value: Value) -> Node<Value> {
    let node = Node(name: name, wrappedValue: value)
    nodes.append(node)
    return node
  }

  func rule<Value>(name: String, _ rule: @escaping () -> Value) -> Node<Value> {
    let node = Node(name: name, rule: rule)
    nodes.append(node)
    return node
  }

  var graphViz: String {
    let nodes = nodes
      .map(\.name)
      .joined(separator: "\n")

    let edges = ""

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
}

final class Node<Value>: AnyNode {
  let name: String
  var rule: (() -> Value)?
  var incomingEdges: [Edge] = []
  var outgoingEdges: [Edge] = []

  private var cachedValue: Value?

  var wrappedValue: Value {
    get {
      if cachedValue == nil, let rule {
        cachedValue = rule()
      }
      return cachedValue!
    }
    set {
      assert(rule == nil)
      cachedValue = newValue
    }
  }


  init(name: String, wrappedValue: Value) {
    self.name = name
    self.cachedValue = wrappedValue
  }

  init(name: String, rule: @escaping () -> Value) {
    self.name = name
    self.rule = rule
  }
}
