import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      HomeTab()
        .tabItem {
          Label("Home", systemImage: "house")
        }

      CaptureTab()
        .tabItem {
          Label("Capture", systemImage: "camera")
        }
    }
  }
}

struct FocusView: View {
  @Binding var position: CGPoint

  var body: some View {
    Circle()
      .frame(width: 70, height: 70)
      .foregroundColor(.clear)
      .border(Color.yellow, width: 1.5)
      .position(x: position.x, y: position.y)
  }
}

#Preview {
  ContentView()
}
