import SwiftUI

struct CaptureButton: View {
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Circle()
        .frame(width: 70, height: 70, alignment: .center)
        .overlay(
          Circle()
            .stroke(Color.white.opacity(0.8), lineWidth: 2)
            .frame(width: 59, height: 59, alignment: .center)
        )
    }
  }
}
