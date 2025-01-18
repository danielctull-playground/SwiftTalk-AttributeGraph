import AttributeGraph
import SwiftUI

struct Sample: View {

  @State private var snapshots: [Snapshot] = []
  @State private var index = 0

  var body: some View {
    VStack {
      if index >= 0, index < snapshots.count {
        Graphviz(dot: snapshots[index].dot)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        Stepper(value: $index, in: 0...(snapshots.count - 1)) {
          Text("step \(index + 1) / \(snapshots.count)")
        }
        .padding()
      }
    }
    .onAppear {
      snapshots = layout()
    }
  }
}

func hstack() -> [Snapshot] {

  var snapshots: [Snapshot] = []

//  var toggle = false
//  var proposedWidth = 200
//  var remainder = proposedWidth
//  var nestedWidth = toggle ? 50 : 100
//  remainder -= nestedWidth
//  let redWidth = remainder

  let graph = AttributeGraph()
  let toggle = graph.input(name: "toggle", false)
  let width = graph.input(name: "proposedWidth", 200.0)

  let nested = graph.rule(name: "Nested") { toggle.wrappedValue ? 50.0 : 100.0 }

  let hstack = graph.rule(name: "HStack") {
    var remainder = width.wrappedValue
    let nestedWidth = nested.wrappedValue
    remainder -= nestedWidth
    let red = remainder
    return [red, nestedWidth]
  }

  snapshots.append(Snapshot(graph: graph))

  let _ = hstack.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  toggle.wrappedValue.toggle()
  snapshots.append(Snapshot(graph: graph))

  let _ = hstack.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  return snapshots
}

struct LayoutComputer {
  let sizeThatFits: (ProposedViewSize) -> CGSize
  let place: (CGRect) -> Void
}

extension LayoutComputer: CustomStringConvertible {
  var description: String { "" }
}

struct DisplayList {
  var items: [Item]

  struct Item {
    let name: String
    let frame: CGRect
  }
}

extension DisplayList: CustomStringConvertible {
  var description: String {
    items.description
  }
}

extension DisplayList.Item: CustomStringConvertible {
  var description: String {
    "\(name): \(frame)"
  }
}

func run<View: MyView>(_ view: View, size: Node<CGSize>) -> ViewOutputs {
  let graph = size.graph
  let viewNode = graph.rule(name: "root node") { view }
  let frame = graph.rule(name: "root frame") {
    CGRect(origin: .zero, size: size.wrappedValue)
  }
  let inputs = ViewInputs(frame: frame)
  return View.makeView(node: viewNode, inputs: inputs)
}

func layout() -> [Snapshot] {

  var snapshots: [Snapshot] = []

  let graph = AttributeGraph()
  let size = graph.input(name: "size", CGSize(width: 200, height: 100))
  let color = MyColor(name: "blue")
    .frame(width: 60, height: 60)
  let outputs = run(color, size: size)
  let displayList = outputs.displayList

  snapshots.append(Snapshot(graph: graph))

  _ = displayList.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  size.wrappedValue.width = 300
  snapshots.append(Snapshot(graph: graph))

  _ = displayList.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  return snapshots
}
