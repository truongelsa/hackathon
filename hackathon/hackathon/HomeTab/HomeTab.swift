import PhotosUI
import SwiftUI

struct HomeTab: View {
  @State private var selectedItems = [PhotosPickerItem]()
  @State private var selectedImages = [Image]()
  @State private var selectedImage: Image? = nil // Ảnh đang chọn để hiển thị trong màn hình chi tiết

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          VStack(alignment: .leading) {
            Text("Recently")
              .font(.headline)
              .foregroundStyle(.black)

            LazyVGrid(
              columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
              spacing: 16
            ) {
              ForEach(0..<selectedImages.count, id: \.self) { i in
                Button(action: {
                  selectedImage = selectedImages[i] // Cập nhật ảnh được chọn
                }) {
                  selectedImages[i]
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 80)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .clipped()
                }
              }
            }
          }
          Spacer()
          VStack(alignment: .leading) {
            Text("Trending Now")
              .font(.headline)
              .foregroundStyle(.black)

            LazyVGrid(
              columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
              spacing: 16
            ) {
              ForEach(0..<selectedImages.count, id: \.self) { i in
                Button(action: {
                  selectedImage = selectedImages[i] // Cập nhật ảnh được chọn
                }) {
                  selectedImages[i]
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 80)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .clipped()
                }
              }
            }
          }
        }
        .padding(.horizontal)
        .toolbar {
          PhotosPicker("Select Images", selection: $selectedItems, matching: .images)
        }
        .onChange(of: selectedItems) { _ in
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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.white))
    .ignoresSafeArea()
  }
}
#Preview {
  HomeTab()
}
