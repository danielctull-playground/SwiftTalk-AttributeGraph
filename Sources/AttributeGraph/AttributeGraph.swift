
final class AttributeGraph {
  var nodes: [AnyNode] = []

  func input<Value>(_ value: Value) -> Node<Value> {
    let node = Node(wrappedValue: value)
    nodes.append(node)
    return node
  }

  func rule<Value>(_ rule: @escaping () -> Value) -> Node<Value> {
    let node = Node(rule: rule)
    nodes.append(node)
    return node
  }
}

protocol AnyNode: AnyObject {}

final class Node<Value>: AnyNode {
  var rule: (() -> Value)?
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


  init(wrappedValue: Value) {
    self.wrappedValue = wrappedValue
  }

  init(rule: @escaping () -> Value) {
    self.rule = rule
  }
}
