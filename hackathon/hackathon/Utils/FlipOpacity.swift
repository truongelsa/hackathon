import SwiftUI

public struct FlipOpacity: AnimatableModifier {
  var pct: CGFloat = 0

  public init(pct: CGFloat) {
    self.pct = pct
  }

  public var animatableData: CGFloat {
    get { pct }
    set { pct = newValue }
  }

  public func body(content: Content) -> some View {
    content.opacity(Double(pct.rounded()))
  }
}
