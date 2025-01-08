import AttributeGraph
import SwiftUI

struct Sample: View {

  @State private var snapshots: [Snapshot] = []
  @State private var index = 0

  var body: some View {
    VStack {
      if index >= 0, index < snapshots.count {
        Graphviz(dot: snapshots[index].dot)
      }
    }
    .onAppear {
      let graph = AttributeGraph()
      let a = graph.input(name: "A", 100)
      graph.rule(name: "B") { a.wrappedValue * 2 }
      snapshots.append(Snapshot(graph: graph))
    }
  }
}
