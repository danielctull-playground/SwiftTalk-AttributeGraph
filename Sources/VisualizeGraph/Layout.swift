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

    let contentNode = graph.rule(name: "content") { node.wrappedValue.content }
    let inputs = ViewInputs(frame: inputs.frame) // TODO
    let outputs = Content.makeView(node: contentNode, inputs: inputs)

    let layoutComputer: Node<LayoutComputer> = graph.rule(name: "layout computer \(Layout.name)") {
      let layout = node.wrappedValue.layout
      let subviews = [outputs.layoutComputer.wrappedValue]
      return LayoutComputer { proposal in
        layout.sizeThatFits(proposedSize: proposal, subviews: subviews)
      } place: { rect in
        fatalError()
      }
    }

    return ViewOutputs(
      layoutComputer: layoutComputer,
      displayList: outputs.displayList)
  }
}
