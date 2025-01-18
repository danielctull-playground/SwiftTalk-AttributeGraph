import SwiftUI

struct HStackLayout: MyLayout {

  static let name = "HStack"

  func frames(
    proposedSize proposal: ProposedViewSize,
    subviews: [LayoutProxy]
  ) -> [CGRect] {

    let flexibilities = subviews.map { subview in
      let min = ProposedViewSize(width: 0, height: proposal.height)
      let max = ProposedViewSize(width: .infinity, height: proposal.height)
      let smallest = subview.sizeThatFits(proposedSize: min)
      let largest = subview.sizeThatFits(proposedSize: max)
      return largest.width - smallest.width
    }

    let subviews = zip(flexibilities, zip(subviews.indices, subviews))
      .sorted(by: \.0)
      .map(\.1)

    var sizes: [CGSize] = Array(repeating: .zero, count: subviews.count)
    var remainingWidth = proposal.replacingUnspecifiedDimensions().width
    var remainingSubviews = subviews.count

    for (index, subview) in subviews {

      let proposal = ProposedViewSize(
        width: remainingWidth / CGFloat(remainingSubviews),
        height: proposal.height)

      let size = subview.sizeThatFits(proposedSize: proposal)

      sizes[index] = size
      remainingSubviews -= 1
      remainingWidth -= size.width
    }

    var x: CGFloat = 0
    var rects: [CGRect] = []
    for size in sizes {
      rects.append(CGRect(origin: CGPoint(x: x, y: 0), size: size))
      x += size.width
    }

    return rects
  }

  func sizeThatFits(
    proposedSize: ProposedViewSize,
    subviews: [LayoutProxy]
  ) -> CGSize {
    frames(proposedSize: proposedSize, subviews: subviews)
      .reduce(CGRect.null) { $0.union($1) }
      .size
  }

  func place(in rect: CGRect, subviews: [LayoutProxy]) {
    let frames = frames(
      proposedSize: ProposedViewSize(rect.size),
      subviews: subviews
    )
    for (index, frame) in frames.enumerated() {
      subviews[index].place(frame.offsetBy(dx: rect.minX, dy: rect.minY))
    }
  }
}

extension Sequence {
  func sorted<Value: Comparable>(
    by keyPath: KeyPath<Element, Value>
  ) -> [Element] {
    sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
  }
}
