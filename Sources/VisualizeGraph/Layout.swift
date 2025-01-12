import AttributeGraph
import SwiftUI

typealias LayoutProxy = LayoutComputer

protocol MyLayout {

  static var name: String { get } 

  func sizeThatFits(
    proposedSize: ProposedViewSize,
    subviews: [LayoutProxy]
  ) -> CGSize

  func place(in rect: CGRect, subviews: [LayoutProxy])
}

extension MyLayout {

  func layoutComputer(subviews: [LayoutProxy]) -> LayoutComputer {
    LayoutComputer { proposal in
      sizeThatFits(proposedSize: proposal, subviews: subviews)
    } place: { rect in
      place(in: rect, subviews: subviews)
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

    let layoutComputer: Node<LayoutComputer> = graph.rule(name: "layout computer \(Layout.name)") {
      fatalError()
    }

    let displayList: Node<DisplayList> = graph.rule(name: "display list \(Layout.name)") {
      fatalError()
    }

    return ViewOutputs(layoutComputer: layoutComputer, displayList: displayList)
  }
}
