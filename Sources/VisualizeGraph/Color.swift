import AttributeGraph

struct MyColor {
  let name: String
}

extension MyColor: MyView {
  static func makeView(node: Node<MyColor>, inputs: ViewInputs) -> ViewOutputs {
    let graph = node.graph

    let layoutComputer = graph.rule(name: "layout computer") {
      LayoutComputer { proposal in
        proposal.replacingUnspecifiedDimensions()
      } place: { rect in
        fatalError()
      }
    }

    let displayList = graph.rule(name: "display list") {
      DisplayList(items: [
        DisplayList.Item(
          name: node.wrappedValue.name,
          frame: inputs.frame.wrappedValue
        )
      ])
    }

    return ViewOutputs(
      layoutComputer: layoutComputer,
      displayList: displayList)
  }
}
