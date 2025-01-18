import SwiftUI

extension MyView {
  func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> some MyView {
    LayoutModifier(
      layout: FixedFrameLayout(width: width, height: height),
      content: self)
  }
}

struct FixedFrameLayout: MyLayout {

  static let name = "FixedFrame"

  let width: CGFloat?
  let height: CGFloat?

  func sizeThatFits(
    proposedSize: ProposedViewSize,
    subviews: [LayoutProxy]
  ) -> CGSize {
    assert(subviews.count == 1, "TODO")
    var contentProposal = proposedSize
    contentProposal.width = width ?? contentProposal.width
    contentProposal.height = height ?? contentProposal.height
    let result = subviews[0].sizeThatFits(contentProposal)
    return CGSize(width: width ?? result.width, height: height ?? result.height)
  }

  func place(in rect: CGRect, subviews: [LayoutProxy]) {
    let size = subviews[0].sizeThatFits(ProposedViewSize(rect.size))
    let origin = CGPoint(
      x: (rect.width - size.width)/2,
      y: (rect.height - size.height)/2)
    subviews[0].place(CGRect(origin: origin, size: size))
  }
}
