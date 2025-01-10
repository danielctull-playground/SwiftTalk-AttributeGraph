import SwiftUI

typealias LayoutProxy = LayoutComputer

protocol MyLayout {
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
