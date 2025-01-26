import AttributeGraph
import SwiftUI

protocol MyLayout {

  static var name: String { get } 

  func sizeThatFits(
    proposedSize: ProposedViewSize,
    subviews: [LayoutProxy]
  ) -> CGSize

  func place(in rect: CGRect, subviews: [LayoutProxy])
}

extension MyLayout {

  func layoutComputer(computers: [LayoutComputer]) -> LayoutComputer {
    var rects = Array(repeating: CGRect.zero, count: computers.count)
    let proxies = computers.enumerated().map { (index, computer) in
      LayoutProxy(computer: computer) { rect in
        rects[index] = rect
      }
    }
    return LayoutComputer { proposal in
      sizeThatFits(proposedSize: proposal, subviews: proxies)
    } childGeometries: { rect in
      place(in: rect, subviews: proxies)
      return rects
    }
  }
}

struct LayoutModifier<Layout: MyLayout, Content: MyView>: MyView {
  let layout: Layout
  let content: Content

  static func makeView(
    node: Node<LayoutModifier<Layout, Content>>,
    inputs: ViewInputs
  ) -> ViewOutputs {

    let graph = node.graph

    let contentNode = graph.rule(name: "content") { node.wrappedValue.content }

    var layoutComputer: Node<LayoutComputer>!

    let contentFrame = graph.rule(name: "child geometry") {
      layoutComputer.wrappedValue.childGeometries(inputs.frame.wrappedValue)
        .reduce(CGRect.null) { $0.union($1) }
    }
    let inputs = ViewInputs(frame: contentFrame)
    let outputs = Content.makeView(node: contentNode, inputs: inputs)

    layoutComputer = graph.rule(name: "layout computer \(Layout.name)") {
      let layout = node.wrappedValue.layout
      let computers = [outputs.layoutComputer.wrappedValue]
      return layout.layoutComputer(computers: computers)
    }

    return ViewOutputs(
      layoutComputer: layoutComputer,
      displayList: outputs.displayList)
  }
}
