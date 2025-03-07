import PhotosUI
import SwiftUI

struct HomeTab: View {
  @State private var selectedItems = [PhotosPickerItem]()
  @State private var selectedImages = [Image]()
  @State private var navigateToDetails = false
  @State private var selectedData: Data? = nil

  var selectedUIImage: UIImage? {
    if let data = selectedData {
      return UIImage(data: data)
    }
    return nil
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          VStack(alignment: .leading) {
            Text("Trending")
              .font(.headline)
              .foregroundStyle(.black)
            LazyVGrid(
              columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
              spacing: 16
            ) {
              Button(action: {
                let size = CGSize(width: 1024, height: 1024)
                selectedData = Image("Hackathon").getUIImage(newSize: size)?.pngData() ?? Data()
                navigateToDetails = true
              }) {
                Image("Hackathon")
                  .resizable()
                  .scaledToFill()
                  .frame(width: 120, height: 80)
                  .background(Color.gray.opacity(0.2))
                  .cornerRadius(8)
                  .clipped()
                  .overlay {
                    VStack() {
                      Spacer()
                      HStack(alignment: .bottom, spacing: 4) {
                        Spacer()
                        Text("999+")
                          .foregroundStyle(.white)
                          .fontWeight(.bold)
                        Image(systemName: "heart.fill")
                          .foregroundStyle(.pink)
                          .padding(.trailing, 4)
                      }
                    }
                    .padding(.bottom, 4)
                  }
              }
              Button(action: {
                let size = CGSize(width: 1024, height: 1024)
                selectedData = Image("DiepAndAmbuth").getUIImage(newSize: size)?.pngData() ?? Data()
                navigateToDetails = true
              }) {
                Image("DiepAndAmbuth")
                  .resizable()
                  .scaledToFill()
                  .frame(width: 120, height: 80)
                  .background(Color.gray.opacity(0.2))
                  .cornerRadius(8)
                  .clipped()
                  .overlay {
                    VStack() {
                      Spacer()
                      HStack(alignment: .bottom, spacing: 4) {
                        Spacer()
                        Text("999+")
                          .foregroundStyle(.white)
                          .fontWeight(.bold)
                        Image(systemName: "heart.fill")
                          .foregroundStyle(.pink)
                          .padding(.trailing, 4)
                      }
                    }
                    .padding(.bottom, 4)
                  }
              }
            }
          }
          imageSection(title: "Recently")
          Spacer()
          imageSection(title: "Hackathon ELSA Event")
        }
        .padding(.horizontal)
        .toolbar {
          PhotosPicker("Select Images", selection: $selectedItems, matching: .images)
        }
        .onChange(of: selectedItems) { _ in
          loadImages()
        }
      }
      .background(navigationLink)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.white))
    .ignoresSafeArea()
  }

  private func imageSection(title: String) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.headline)
        .foregroundStyle(.black)
      LazyVGrid(
        columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
        spacing: 16
      ) {
        ForEach(0..<selectedImages.count, id: \.self) { i in
          Button(action: {
            let size = CGSize(width: 1024, height: 1024)
            selectedData = selectedImages[i].getUIImage(newSize: size)?.pngData() ?? Data()
            navigateToDetails = true
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

  private func loadImages() {
    Task {
      selectedImages.removeAll()
      for item in selectedItems {
        if let image = try? await item.loadTransferable(type: Image.self) {
          selectedImages.append(image)
          self.selectedData = await item.makeData()
        }
      }
    }
  }

  private var navigationLink: some View {
    NavigationLink(
      destination: PhotoDetailsView(
        selectedImage: selectedUIImage,
        wordListResponse: nil
      ),
      isActive: $navigateToDetails
    ) {
      EmptyView()
    }
  }
}

extension PhotosPickerItem {
  func makeData() async -> Data? {
    return try? await loadTransferable(type: Data.self)
  }
}

extension Image {
  @MainActor
  func getUIImage(newSize: CGSize) -> UIImage? {
    let image = resizable()
      .scaledToFill()
      .frame(width: newSize.width, height: newSize.height)
      .clipped()
    return ImageRenderer(content: image).uiImage
  }
}

#Preview {
  HomeTab()
}
