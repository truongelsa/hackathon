import PhotosUI
import SwiftUI

struct HomeTab: View {
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    @State private var selectedImage: Image? = nil
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
                    imageSection(title: "Recently")
                    Spacer()
                    imageSection(title: "Trending Now")
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
                        print("#> call_debug handle navigation from \(title) \(selectedImage)")
                        selectedImage = selectedImages[i]
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

#Preview {
    HomeTab()
}

