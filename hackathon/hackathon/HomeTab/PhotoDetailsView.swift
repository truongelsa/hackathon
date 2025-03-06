import SwiftUI
import AVFoundation

struct PhotoDetailsView: View {
  @StateObject private var audioRecorder = AudioRecorder()
  @State private var contextText: String = "Context: A mountain is on the wall."

  private let fileUploadService = FileUploadService()
  let selectedImage: UIImage

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // Description Text
        Text("PicLearn lets you snap a photo and instantly learn from it using AI-powered insights. Simply take a picture of text, objects, or equations, and get quick explanations and learning resources!")
          .foregroundColor(.black)
          .padding()
          .multilineTextAlignment(.center)
        
        // PhotoView
        Image(uiImage: selectedImage)
          .resizable()
          .scaledToFit()
          .frame(width: 370, height: 150)
          .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 3))
                        
        
        // Button Row
        HStack(spacing: 16) {
          Button(action: {
            if audioRecorder.isRecordingPublished {
              audioRecorder.stopRecording()
            } else {
              audioRecorder.startRecording()
            }
          }) {
            Text(audioRecorder.isRecordingPublished ? "Stop Recording" : "Record")
              .frame(maxWidth: .infinity)
              .padding()
              .background(audioRecorder.isRecordingPublished ? Color.red : Color(hex: "#00004B"))
              .foregroundColor(.white)
              .cornerRadius(8)
          }
          Button(action: {
            audioRecorder.playRecording()
          }) {
            Text("Play")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color(hex: "#00004B"))
              .foregroundColor(.white)
              .cornerRadius(8)
          }
          Button(action: {
            if let image = UIImage(systemName: "flag.fill"),
               let imageData = image.jpegData(compressionQuality: 1.0) {
              fileUploadService.uploadPhoto(data: imageData) { result in
                switch result {
                case .success(let response):
                  print("Upload successful: \(response)")
                case .failure(let error):
                  print("Upload failed: \(error.localizedDescription)")
                }
              }
            }
          }) {
            Text("Photo")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color(hex: "#00004B"))
              .foregroundColor(.white)
              .cornerRadius(8)
          }
        }
        .padding(.horizontal)
        
        // Context Input UI (Newly Added)
        HStack {
          TextEditor(text: $contextText)
            .frame(height: 200)
            .padding(2)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 0.5)
            )
            .disabled(true) // Makes it uneditable like a label
          
          Button(action: {
            print("Microphone button tapped")
          }) {
            Image(systemName: "mic.fill")
              .foregroundColor(.black)
              .padding(8)
          }
        }
        .padding(.horizontal)
                        
        Text("Feedback: Great effort! You scored 70% on pronunciation. Focus on improving a few sounds for better clarity keep practicing, and you'll get")
          .foregroundColor(.black)
          .padding()
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.white))
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
