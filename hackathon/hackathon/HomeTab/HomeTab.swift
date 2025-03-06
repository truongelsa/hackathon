import PhotosUI
import SwiftUI

struct HomeTab: View {
  @State private var selectedItems = [PhotosPickerItem]()
  @State private var selectedImages = [Image]()

  var body: some View {
    NavigationView {
      VStack(spacing: 16) {
        NavigationStack {
          ScrollView {
            LazyVStack {
              ForEach(0..<selectedImages.count, id: \.self) { i in
                selectedImages[i]
                  .resizable()
                  .scaledToFit()
                  .frame(width: 300, height: 300)
              }
            }
          }
          .toolbar {
            // Button Row
            NavigationLink(destination: PhotoDetailsView(selectedImage: nil)) {
              Text("Dummy Image")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.black)
                .cornerRadius(8)
            }
            PhotosPicker("Select images", selection: $selectedItems, matching: .images)
          }
          .onChange(of: selectedItems) {
            Task {
              selectedImages.removeAll()

              for item in selectedItems {
                if let image = try? await item.loadTransferable(type: Image.self) {
                  selectedImages.append(image)
                }
              }
            }
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.white))
    .ignoresSafeArea()
  }
}

#Preview {
  HomeTab()
}
