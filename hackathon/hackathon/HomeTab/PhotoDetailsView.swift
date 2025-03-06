import AVFoundation
import SwiftUI

struct PhotoDetailsView: View {

  private let fileUploadService = FileUploadService()
  @StateObject private var audioRecorder = AudioRecorder()
  @State private var isLoading = true
  @State private var isMakeSentenece = false
  @State private var showDescription = false
  @State private var contextText: String = ""
  @State private var vocabulary: [Vocabulary] = []
  @State private var usedVocabulary: [String: Bool] = [:]
  @State private var sentenceContext: String = ""
  @State private var speakingSentences: [Sentence] = []

  let selectedImage: UIImage?
  var wordListResponse: WordListResponse? = nil

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
        // Using to mock UI
        if selectedImage == nil {
          isLoading = false
          return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          if let selectedImage {
            uploadPhoto(image: selectedImage)
          }
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
            .multilineTextAlignment(.leading)  // Toggle visibility
            Spacer()
          }
          .padding(.horizontal)

          // PhotoView
          Image(uiImage: selectedImage ?? UIImage())
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#00004B"), lineWidth: 3))
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
              usedVocabulary[item.word] = !(usedVocabulary[item.word] ?? true)
            }) {
              Text(item.word)
                .padding()
                .foregroundColor(.white)
                .background(
                  (usedVocabulary[item.word] ?? false)
                    ? Color(hex: "#00004B") : Color(hex: "#00004B").opacity(0.3)
                )
                .clipShape(Capsule())
            }
          }
          .frame(maxWidth: .infinity)

          // Context Input UI (Newly Added)
          HStack {
            TextEditor(text: $contextText)
              .frame(height: 100)
              .padding(2)
              .foregroundColor(Color.black)
              .cornerRadius(8)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.blue.opacity(0.8), lineWidth: 0.5)
              )
          }
          .padding(.horizontal)

          Button(action: {
            isMakeSentenece.toggle()
            let words: [String] = usedVocabulary.filter { $1 }.keys.sorted()
            generateSentence(words: words, context: contextText)
          }) {
            if isMakeSentenece {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(.lightGray)))
                .scaleEffect(2)
            } else {
              Text("Make a scentence")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
          }
          .padding()

          VStack {
            ForEach(speakingSentences, id: \.self) { item in
              HStack {
                VStack {
                  Text(item.sentence)
                    .foregroundColor(.cyan)
                    .padding()
                    .multilineTextAlignment(.leading)
                }
                Spacer()
                Button(action: {
                  print("Microphone button tapped for sentence: \(item.sentence)")
                }) {
                  Image(systemName: "mic.fill")
                    .foregroundColor(.black)
                    .padding(8)
                }
              }
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.cyan.opacity(0.8), lineWidth: 0.5)
              )
              .onTapGesture {
                item.usedVocabulary.forEach { self.usedVocabulary[$0] = true }
              }
            }
          }
          .padding(.horizontal)
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
            wordListResponse.vocabulary.forEach { item in
              self.usedVocabulary[item.word] = false
            }
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

  private func generateSentence(words: [String], context: String) {
    fileUploadService.generateSentenceFromWord(words, context: context) { result in
      isMakeSentenece.toggle()
      switch result {
      case .success(let response):
        if let responseData = response.1 {
          do {
            let sentenceResponse = try JSONDecoder().decode(
              SentenceResponse.self, from: responseData)
            if let bestSentence = sentenceResponse.sentences.first {
              sentenceContext = bestSentence.sentence
              speakingSentences.append(bestSentence)
            }
          } catch {
            print("Failed to decode sentenceResponse: \(error.localizedDescription)")
          }
        }
      case .failure(let error):
        print("Failed to generate sentence: \(error.localizedDescription)")
      }
    }

  }

}

#Preview {
  PhotoDetailsView(selectedImage: UIImage(systemName: "flag.fill")!, wordListResponse: nil)
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
