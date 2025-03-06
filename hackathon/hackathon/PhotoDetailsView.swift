import SwiftUI
import AVFoundation

struct PhotoDetailsView: View {
  @StateObject private var audioRecorder = AudioRecorder()
  
  var body: some View {
    VStack(spacing: 16) {
      // PhotoView
      if let image = UIImage(named: "your_image_name") {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(width: 150, height: 150)
          .overlay(
            RoundedRectangle(cornerRadius: 8) // Add a rounded rectangle border
              .stroke(Color.blue, lineWidth: 3) // Blue border with 3pt width
          )
      } else {
        Image(systemName: "flag.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 150, height: 150)
          .overlay(
            RoundedRectangle(cornerRadius: 8) // Add a rounded rectangle border
              .stroke(Color.blue, lineWidth: 3) // Blue border with 3pt width
          )
          .foregroundColor(.gray)
      }
      
      // Scroll View
      ScrollView {
        Rectangle()
          .fill(Color.blue)
          .frame(height: 200)
          .overlay(Text("Scroll view").foregroundColor(.black).bold())
      }
      .frame(height: 200)
      
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
            .background(audioRecorder.isRecordingPublished ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        Button(action: {
          audioRecorder.playRecording()
        }) {
          Text("Play")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.black)
            .cornerRadius(8)
        }
        Button(action: {}) {
          Text("Photo")
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

#Preview {
  PhotoDetailsView()
}
