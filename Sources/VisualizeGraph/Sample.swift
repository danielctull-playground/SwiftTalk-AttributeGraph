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
        Stepper(value: $index) {
          Text("step \(index + 1) / \(snapshots.count)")
        }
        .padding()
      }
    }
    .onAppear {
      let graph = AttributeGraph()
      let a = graph.input(name: "A", 10)
      let b = graph.input(name: "B", 20)
      let c = graph.rule(name: "C") { a.wrappedValue + b.wrappedValue }
      let d = graph.rule(name: "D") { c.wrappedValue * 2 }
      let e = graph.rule(name: "E") { a.wrappedValue * 2 }
      snapshots.append(Snapshot(graph: graph))
      _ = e.wrappedValue
      snapshots.append(Snapshot(graph: graph))
      _ = d.wrappedValue
      snapshots.append(Snapshot(graph: graph))
      b.wrappedValue += 1
      snapshots.append(Snapshot(graph: graph))
      a.wrappedValue += 1
      snapshots.append(Snapshot(graph: graph))
      _ = d.wrappedValue
      snapshots.append(Snapshot(graph: graph))
      _ = e.wrappedValue
      snapshots.append(Snapshot(graph: graph))
    }
  }
}
