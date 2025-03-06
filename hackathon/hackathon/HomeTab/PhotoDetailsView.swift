import AVFoundation
import SwiftUI

struct PhotoDetailsView: View {

  private let fileUploadService = FileUploadService()
  @StateObject private var audioRecorder = AudioRecorder()
  @State private var isLoading = true
  @State private var showDescription = false
  @State private var contextText: String = "In the image, people are gathered in a casual setting, engaged in a tech or coding activity. Laptops with code displayed on the screens are on a table, and there are snacks and water bottles around."
  @State private var vocabulary: [Vocabulary] = [
    .init(
      definition: "the process of assigning a code to something for the purposes of classification or identification", 
      example: "Coding expertise is essential for developers attending this event.",
      word: "coding"
    ),
    .init(
      definition: "relating to or using technology, in particular computing",
      example: "This is a tech event, focusing on coding and programming.",
      word: "tech"
    ),
  ]

  let selectedImage: UIImage

  var body: some View {
    if isLoading {
      VStack(alignment: .center) {
        Spacer()
        VStack {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color(.lightGray)))
            .scaleEffect(2)
          Text("Analyzing your photo...")
            .foregroundColor(.black)
            .font(.headline)
            .padding(.top, 8)
          Text("This might take a few seconds. Please wait!")
            .foregroundColor(.black)
            .font(.subheadline)
            .padding(.top, 4)
        }
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.white)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          uploadPhoto(image: selectedImage)
        }
      }
    } else {
      ScrollView {
        VStack(spacing: 8) {
          // Info Button and Description Text
          HStack {
            VStack {
              Button(action: {
                withAnimation {
                  showDescription.toggle()
                }
              }) {
                Image(systemName: showDescription ? "info.circle.fill" : "info.circle")
                  .foregroundColor(.blue)
              }
              .padding(.top, 8)
              Spacer()
            }
            Text(
              !showDescription
                ? "Show instruction"
                : "PicLearn lets you snap a photo and instantly learn from it using AI-powered insights. Simply take a picture of text, objects, or equations, and get quick explanations and learning resources!"
            )
            .foregroundColor(.black)
            .multilineTextAlignment(.leading) // Toggle visibility
            Spacer()
          }
          .padding(.horizontal)

          // PhotoView
          Image(uiImage: selectedImage)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 3))
            .padding(.horizontal)

          HStack(spacing: 16) {
//            Button(action: {
//              if audioRecorder.isRecordingPublished {
//                audioRecorder.stopRecording()
//              } else {
//                audioRecorder.startRecording()
//              }
//            }) {
//              Text(audioRecorder.isRecordingPublished ? "Stop Recording" : "Record")
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(audioRecorder.isRecordingPublished ? Color.red : Color(hex: "#00004B"))
//                .foregroundColor(.white)
//                .cornerRadius(8)
//            }
//            Button(action: {
//              audioRecorder.playRecording()
//            }) {
//              Text("Play")
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color(hex: "#00004B"))
//                .foregroundColor(.white)
//                .cornerRadius(8)
//            }
          }
          .padding(.horizontal)

          TagsView(items: vocabulary, lineLimit: 2) { item in
            Button(action: {

            }) {
              Text(item.word)
                .padding()
                .foregroundColor(.white)
                .background(Color(hex: "#00004B"))
                .clipShape(Capsule())
            }
          }
          .frame(maxWidth: .infinity)

          // Context Input UI (Newly Added)
          HStack {
            TextEditor(text: $contextText)
              .frame(height: 100)
              .padding(2)
              .foregroundColor(Color(.lightGray))
              .cornerRadius(8)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.gray, lineWidth: 0.5)
              )

            Button(action: {
              print("Microphone button tapped")
            }) {
              Image(systemName: "mic.fill")
                .foregroundColor(.black)
                .padding(8)
            }
          }
          .padding(.horizontal)

          Text(
            "Feedback: Great effort! You scored 70% on pronunciation. Focus on improving a few sounds for better clarity keep practicing, and you'll get"
          )
          .foregroundColor(.black)
          .padding()
          .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.white))
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.white))
    }
  }

  private func uploadPhoto(image: UIImage) {
    guard let imageData = image.jpegData(compressionQuality: 0.3) else {
      print("Failed to get JPEG data from image")
      return
    }

    fileUploadService.uploadPhoto(data: imageData) { result in
      switch result {
      case .success(let response):
        isLoading = false
        print("Upload successful: \(response)")
        if let responseData = response.1 {
          do {
            let wordListResponse = try JSONDecoder().decode(
              WordListResponse.self, from: responseData)
            self.vocabulary = wordListResponse.vocabulary
            self.contextText = wordListResponse.context
          } catch {
            print("Failed to decode WordListResponse: \(error.localizedDescription)")
          }
        }
      case .failure(let error):
        print("Upload failed: \(error.localizedDescription)")
      }
    }
  }
}

#Preview {
  PhotoDetailsView(selectedImage: UIImage(systemName: "flag.fill")!)
}

extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)
    let red = Double((rgbValue >> 16) & 0xFF) / 255.0
    let green = Double((rgbValue >> 8) & 0xFF) / 255.0
    let blue = Double(rgbValue & 0xFF) / 255.0
    self.init(red: red, green: green, blue: blue)
  }
}
