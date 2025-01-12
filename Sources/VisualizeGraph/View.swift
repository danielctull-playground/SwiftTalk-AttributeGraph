import AttributeGraph
import SwiftUI

protocol MyView {
  static func makeView(node: Node<Self>, inputs: ViewInputs) -> ViewOutputs
}

struct ViewInputs {
  let frame: Node<CGRect>
}

struct ViewOutputs {
  let layoutComputer: Node<LayoutComputer>
  let displayList: Node<DisplayList>
}
