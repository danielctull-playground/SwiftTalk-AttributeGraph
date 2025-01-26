import SwiftUI

extension MyView {
  func padding(amount: CGFloat? = nil) -> some MyView {
    LayoutModifier(
      layout: PaddingLayout(amount: amount),
      content: self)
  }
}

struct PaddingLayout: MyLayout {
  static let name = "Padding"

  let _amount: CGFloat?
  var amount: CGFloat { _amount ?? 16 }

  init(amount: CGFloat?) {
    _amount = amount
  }

  func sizeThatFits(proposedSize: ProposedViewSize, subviews: [LayoutProxy]) -> CGSize {

    assert(subviews.count == 1)

    let proposal = ProposedViewSize(
      width: proposedSize.width.map { $0 - 2 * amount },
      height: proposedSize.height.map { $0 - 2 * amount })

    let size = subviews[0].sizeThatFits(proposedSize: proposal)
    return CGSize(
      width: size.width + 2 * amount,
      height: size.height + 2 * amount)
  }

  func place(in rect: CGRect, subviews: [LayoutProxy]) {
    assert(subviews.count == 1)
    subviews[0].place(rect.insetBy(dx: amount, dy: amount))
  }
}
