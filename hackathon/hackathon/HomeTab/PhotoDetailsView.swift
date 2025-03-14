import AVFoundation
import SwiftUI

struct SpeakingSentence: Hashable {
  let item: Sentence
  let score: String?
  let feedback: String?
}

struct PhotoDetailsView: View {

  private let fileUploadService = FileUploadService()
  @StateObject private var audioRecorder = AudioRecorder()
  @State private var canEdit = false
  @State private var isLoading = true
  @State private var isMakeSentenece = false
  @State private var isAnalyzeAudio = false
  @State private var isHovering: Bool = false
  @State private var showDescription = false
  @State private var contextText: String = ""
  @State private var contextTextScore: String?
  @State private var contextTextFeedback: String?
  @State private var vocabulary: [Vocabulary] = []
  @State private var usedVocabulary: [String: Bool] = [:]
  @State private var sentenceContext: String = ""
  @State private var speakingSentences: [SpeakingSentence] = []
  @State private var currentWord: Vocabulary?
  private let speechSynthesizer = AVSpeechSynthesizer()

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
                : "Snap-And-Learn lets you snap a photo and instantly learn from it using AI-powered insights. Simply take a picture of text, objects, or equations, and get quick explanations and learning resources!"
            )
            .foregroundColor(.black)
            .multilineTextAlignment(.leading)  // Toggle visibility
            Spacer()
          }
          .padding(.horizontal)

          // PhotoView
          ZStack {
            VStack(alignment: .center, spacing: 10) {
              if let currentWord {
                VStack(alignment: .center) {
                  Text(currentWord.word)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                  Text(currentWord.definition)
                    .font(.body)
                    .foregroundStyle(.black)
                  Text("Example: \(currentWord.example)")
                    .font(.caption)
                    .foregroundStyle(.black)
                }
                .padding()
              }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(Color.blue)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#00004B"), lineWidth: 3))
            .padding(.horizontal)
            .modifier(FlipOpacity(pct: isHovering ? 1 : 0))
            .rotation3DEffect(Angle.degrees(isHovering ? 0 : 180), axis: (0, 1, 0))

            Image(uiImage: selectedImage ?? UIImage())
              .resizable()
              .scaledToFit()
              .frame(maxWidth: .infinity)
              .frame(height: 300)
              .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#00004B"), lineWidth: 3))
              .padding(.horizontal)
              .modifier(FlipOpacity(pct: isHovering ? 0 : 1))
              .rotation3DEffect(Angle.degrees(isHovering ? 180 : 360), axis: (0, 1, 0))
          }

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
            .simultaneousGesture(
              DragGesture(minimumDistance: 0)
                .onChanged { _ in
                  currentWord = item
                  withAnimation(Animation.linear(duration: 0.4)) {
                    isHovering = true
                  }
                }
                .onEnded { _ in
                  currentWord = nil
                  withAnimation(Animation.linear(duration: 0.4)) {
                    isHovering = false
                  }
                }
            )
          }
          .frame(maxWidth: .infinity)

          HStack(spacing: 8) {
            Spacer()
            Image(systemName: showDescription ? "info.circle.fill" : "info.circle")
              .foregroundColor(.blue)
            .padding(.top, 8)
            Text("Hold to Speak")
              .foregroundColor(.black)
              .multilineTextAlignment(.leading)
          }
          .padding(.horizontal)

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
              .disabled(!canEdit)
              .padding(.top, 20)
            VStack(spacing: 10) {
              Button(action: {
                print("Microphone button tapped for sentence: \(contextText)")
              }) {
                if isAnalyzeAudio {
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(.lightGray)))
                } else {
                  Image(systemName: "mic.fill")
                    .foregroundColor(.black)
                    .padding()
                }
              }
              .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                  .onChanged { _ in
                    audioRecorder.startRecording()
                    audioRecorder.playMicStart()
                  }
                  .onEnded { _ in
                    audioRecorder.stopRecording()
                    audioRecorder.playMicStop()
                    analyzeAudio(
                      for: .init(sentence: contextText, usedVocabulary: []) ,
                      url: audioRecorder.getAudioFileURL(),
                      isContext: true
                    )
                  }
              )
              .frame(width: 50)
              Button(action: {
                speak(sentence: contextText)
              }) {
                Image(systemName: "speaker.fill")
                  .foregroundColor(.black)
              }
              .frame(width: 50)
            }
            .frame(width: 40)
          }
          .padding(.horizontal)

          VStack(alignment: .center, spacing: 8) {
            if let score = contextTextScore {
              HStack {
                Spacer()
                VStack {
                  Text("Score: \(score)%")
                    .foregroundColor(Color(hex: "#00004B"))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                }
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#00004B"), lineWidth: 3))
                Spacer()
              }
            }
            if let feedback = contextTextFeedback {
              Text(feedback)
                .foregroundColor(.green)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            }
          }
          .padding()

          Button(action: {
            isMakeSentenece.toggle()
            var words: [String] = usedVocabulary.filter { $1 }.keys.sorted()
            if usedVocabulary.keys.contains("group") {
              words.append("ELSA Hackathon event")
            }
            if usedVocabulary.keys.contains("flower") || usedVocabulary.keys.contains("roses") || usedVocabulary.keys.contains("rose") {
              words.append("Happy International Women Day")
            }
            generateSentence(words: words, context: contextText)
          }) {
            if isMakeSentenece {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(.lightGray)))
                .scaleEffect(2)
            } else {
              Text("Practice More")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
          }
          .padding()

          VStack {
            ForEach(speakingSentences, id: \.self) { speakingSentence in
              HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                  Text(speakingSentence.item.sentence)
                    .foregroundColor(.cyan)
                    .multilineTextAlignment(.leading)
                  if let score = speakingSentence.score {
                    HStack {
                      Spacer()
                      VStack {
                        Text("Score: \(score)%")
                          .foregroundColor(Color(hex: "#00004B"))
                          .fontWeight(.bold)
                          .multilineTextAlignment(.center)
                          .padding()
                      }
                      .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#00004B"), lineWidth: 3))
                      Spacer()
                    }
                  }
                  if let feedback = speakingSentence.feedback {
                    Text(feedback)
                      .foregroundColor(.green)
                      .fontWeight(.semibold)
                      .multilineTextAlignment(.leading)
                  }
                }
                .padding()
                Spacer()
                VStack(spacing: 10) {
                  Button(action: {
                    print("Microphone button tapped for sentence: \(speakingSentence.item.sentence)")
                  }) {
                    if isAnalyzeAudio {
                      ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(.lightGray)))
                    } else {
                      Image(systemName: "mic.fill")
                        .foregroundColor(.black)
                        .padding()
                    }
                  }
                  .frame(width: 50)
                  .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                      .onChanged { _ in
                        audioRecorder.startRecording()
                        audioRecorder.playMicStart()
                      }
                      .onEnded { _ in
                        audioRecorder.stopRecording()
                        audioRecorder.playMicStop()
                        analyzeAudio(for: speakingSentence.item , url: audioRecorder.getAudioFileURL())
                      }
                  )
                  Button(action: {
                    speak(sentence: speakingSentence.item.sentence)
                  }) {
                    Image(systemName: "speaker.fill")
                      .foregroundColor(.black)
                  }
                  .frame(width: 50)
                }
                .frame(width: 40)
              }
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.cyan.opacity(0.8), lineWidth: 0.5)
              )
              .onTapGesture {
                speakingSentence.item.usedVocabulary.forEach { self.usedVocabulary[$0] = true }
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
              speakingSentences.append(.init(
                item: bestSentence,
                score: nil,
                feedback: nil
              ))
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
  
  private func analyzeAudio(for sentence: Sentence, url: URL, isContext: Bool = false) {
    isAnalyzeAudio = true
    fileUploadService.uploadAudio(filePath: url) { (score, feedback) in
      isAnalyzeAudio = false
      if let score, let feedback {
        if isContext {
          contextTextScore = score
          contextTextFeedback = feedback
        }
        if let index = speakingSentences.firstIndex(where: { $0.item.sentence == sentence.sentence }) {
          speakingSentences.remove(at: index)
          speakingSentences.insert(.init(item: sentence, score: score, feedback: feedback), at: index)
        }
      }
    }
  }
  
  func speak(sentence: String) {
      let speechUtterance = AVSpeechUtterance(string: sentence)
      
      speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Change language if needed
      speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate // Adjust speed if necessary
      
      speechSynthesizer.speak(speechUtterance)
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
