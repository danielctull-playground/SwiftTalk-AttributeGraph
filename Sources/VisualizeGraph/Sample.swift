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
    let rect: CGRect
  }
}

extension DisplayList: CustomStringConvertible {
  var description: String {
    items.description
  }
}

extension DisplayList.Item: CustomStringConvertible {
  var description: String {
    "\(name): \(rect)"
  }
}

func layout() -> [Snapshot] {

  var snapshots: [Snapshot] = []

  let graph = AttributeGraph()
  let toggle = graph.input(name: "toggle", false)
  let proposal = graph.input(name: "size", ProposedViewSize(width: 200, height: 100))

  var frames: [CGRect] = [.null, .null]

  let redLayoutComputer = graph.rule(name: "red layout computer") {
    LayoutComputer {
      $0.replacingUnspecifiedDimensions()
    } place: { rect in
      frames[0] = rect
    }
  }

  let nestedLayoutComputer = graph.rule(name: "nested layout computer") {
    let toggle = toggle.wrappedValue
    return LayoutComputer { proposal in
      CGSize(
        width: toggle ? 50 : 100,
        height: proposal.height ?? 10
      )
    } place: { rect in
      frames[1] = rect
    }
  }

  let hstackLayoutComputer = graph.rule(name: "hstack layout computer") {
     HStackLayout().layoutComputer(subviews: [
      redLayoutComputer.wrappedValue,
      nestedLayoutComputer.wrappedValue,
    ])
  }

  let size = graph.rule(name: "hstack size") {
    hstackLayoutComputer.wrappedValue.sizeThatFits(proposal.wrappedValue)
  }

  let childGeometries = graph.rule(name: "child geometries") {
    let lc = hstackLayoutComputer.wrappedValue
    lc.place(CGRect(origin: .zero, size: size.wrappedValue))
    return frames
  }

  let redGeometry = graph.rule(name: "red geometry") {
    childGeometries.wrappedValue[0]
  }

  let nestedGeometry = graph.rule(name: "nested geometry") {
    childGeometries.wrappedValue[1]
  }

  let redDisplayList = graph.rule(name: "red display list") {
    DisplayList(items: [.init(name: "red", rect: redGeometry.wrappedValue)])
  }

  let nestedDisplayList = graph.rule(name: "nested display list") {
    DisplayList(items: [.init(name: "nested", rect: nestedGeometry.wrappedValue)])
  }

  let displayList = graph.rule(name: "display list") {
    DisplayList(items: redDisplayList.wrappedValue.items + nestedDisplayList.wrappedValue.items)
  }

  snapshots.append(Snapshot(graph: graph))

  _ = displayList.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  toggle.wrappedValue.toggle()
  snapshots.append(Snapshot(graph: graph))

  _ = displayList.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  proposal.wrappedValue.width = 300
  snapshots.append(Snapshot(graph: graph))

  _ = displayList.wrappedValue
  snapshots.append(Snapshot(graph: graph))

  return snapshots
}
