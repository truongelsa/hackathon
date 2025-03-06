//
//  CaptureTab.swift
//  hackathon
//
//  Created by Nhat T. Nguyen on 6/3/25.
//

import SwiftUI

struct CaptureTab: View {
  @ObservedObject var viewModel = CameraViewModel()
  
  @State private var isFocused = false
  @State private var isScaled = false
  @State private var focusLocation: CGPoint = .zero
  @State private var currentZoomFactor: CGFloat = 1.0
  
  var body: some View {
    NavigationView {
      VStack {
        GeometryReader { geometry in
          ZStack {
            VStack(spacing: 0) {
              ZStack {
                CameraPreview(session: viewModel.session) { tapPoint in
                  isFocused = true
                  focusLocation = tapPoint
                  viewModel.setFocus(point: tapPoint)
                  UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                .gesture(MagnificationGesture()
                  .onChanged { value in
                    self.currentZoomFactor += value - 1.0 // Calculate the zoom factor change
                    self.currentZoomFactor = min(max(self.currentZoomFactor, 0.5), 10)
                    self.viewModel.zoom(with: currentZoomFactor)
                  })
                
                if isFocused {
                  FocusView(position: $focusLocation)
                    .scaleEffect(isScaled ? 0.8 : 1)
                    .onAppear {
                      withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                        self.isScaled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                          self.isFocused = false
                          self.isScaled = false
                        }
                      }
                    }
                }
              }
              
              
              ZStack {
                HStack(alignment: .center) {
                  if let image = viewModel.capturedImage {
                    NavigationLink(
                      destination:
                        PhotoDetailsView(selectedImage: image)
                    ) {
                      PhotoThumbnail(image: viewModel.capturedImage)
                    }
                  }
                  Spacer()
                  CameraSwitchButton { viewModel.switchCamera() }
                }
                HStack {
                  Spacer()
                  CaptureButton { viewModel.captureImage() }
                  Spacer()
                }
              }
              .padding(20)
            }
          }
          .alert(isPresented: $viewModel.showAlertError) {
            Alert(title: Text(viewModel.alertError.title), message: Text(viewModel.alertError.message), dismissButton: .default(Text(viewModel.alertError.primaryButtonTitle), action: {
              viewModel.alertError.primaryAction?()
            }))
          }
          .alert(isPresented: $viewModel.showSettingAlert) {
            Alert(
              title: Text("Warning"),
              message: Text("Application doesn't have all permissions to use camera and microphone, please change privacy settings."),
              dismissButton: .default(
                Text(
                  "Go to settings"),
                action: {
                  self.openSettings()
                }
              )
            )
          }
          .onAppear {
            viewModel.setupBindings()
            viewModel.requestCameraPermission()
          }
        }
        .padding(.vertical, 100)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.white))
      .ignoresSafeArea()
    }
  }
  
  func openSettings() {
    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
    if let url = settingsUrl {
      UIApplication.shared.open(url, options: [:])
    }
  }
}
