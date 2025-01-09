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
}

extension LayoutComputer: CustomStringConvertible {
  var description: String { "" }
}

func layout() -> [Snapshot] {

  var snapshots: [Snapshot] = []

  let graph = AttributeGraph()
  let toggle = graph.input(name: "toggle", false)
  let proposal = graph.input(name: "size", ProposedViewSize(width: 200, height: 100))

  let redLayoutComputer = graph.rule(name: "red layout computer") {
    LayoutComputer { $0.replacingUnspecifiedDimensions() }
  }

  let nestedLayoutComputer = graph.rule(name: "nested layout computer") {
    let toggle = toggle.wrappedValue
    return LayoutComputer { proposal in
      CGSize(
        width: toggle ? 50 : 100,
        height: proposal.height ?? 10
      )
    }
  }

  let hstackLayoutComputer = graph.rule(name: "hstack layout computer") {

    let nestedLayoutComputer = nestedLayoutComputer.wrappedValue
    let redLayoutComputer = redLayoutComputer.wrappedValue

    return LayoutComputer { proposal in
      var remainder = proposal.width!

      let nestedSize = nestedLayoutComputer
        .sizeThatFits(ProposedViewSize(width: remainder/2, height: proposal.height))
      remainder -= nestedSize.width

      let redSize = redLayoutComputer
        .sizeThatFits(ProposedViewSize(width: remainder, height: proposal.height))

      let result = CGSize(
        width: redSize.width + nestedSize.width,
        height: max(redSize.height, nestedSize.height)
      )

      return result
    }
  }

  let size = graph.rule(name: "hstack size") {
    hstackLayoutComputer.wrappedValue.sizeThatFits(proposal.wrappedValue)
  }

  snapshots.append(Snapshot(graph: graph))

  _ = size.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  toggle.wrappedValue.toggle()
  snapshots.append(Snapshot(graph: graph))

  _ = size.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  proposal.wrappedValue.width = 300
  snapshots.append(Snapshot(graph: graph))

  _ = size.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  return snapshots
}
