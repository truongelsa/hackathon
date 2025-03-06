import SwiftUI

struct ContentView: View {
  
  var body: some View {
    NavigationView {
      VStack(spacing: 16) {
        // Button Row
        HStack(spacing: 16) {
          NavigationLink(destination: PhotoDetailsView()) {
            Text("Go to sample image")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .foregroundColor(.black)
              .cornerRadius(8)
          }
        }
        .padding(.horizontal)
      }
      .frame(maxHeight: .infinity) // Expands VStack to full screen height
      .background(Color(.lightGray))
      .ignoresSafeArea() // Ensures background fills the entire screen
    }
  }
}

#Preview {
  ContentView()
}
