//
//  AudioRecorder.swift
//  hackathon
//
//  Created by Truong Nguyen on 5/3/25.
//

import AVFoundation
import Combine

class AudioRecorder: ObservableObject {
  private var audioEngine = AVAudioEngine()
  private var audioFile: AVAudioFile?
  private var audioFormat: AVAudioFormat?
  private var isRecording = false
  private let audioSession = AVAudioSession.sharedInstance()
  private var audioPlayer: AVAudioPlayer?
  
  @Published var isRecordingPublished = false
  
  init() {
    setupAudioSession()
  }
  
  private func setupAudioSession() {
    do {
      try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      print("Failed to set up audio session: \(error.localizedDescription)")
    }
  }
  
  func startRecording() {
    guard !isRecording else { return }
    
    let audioNode = audioEngine.inputNode
    let inputFormat = audioNode.outputFormat(forBus: 0)
    self.audioFormat = inputFormat
    
    let fileURL = getAudioFileURL()
    
    do {
      // Use the inputFormat's settings for consistency.
      audioFile = try AVAudioFile(forWriting: fileURL, settings: inputFormat.settings)
    } catch {
      print("Failed to create audio file: \(error.localizedDescription)")
      return
    }
    
    audioNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] (buffer, _) in
      guard let self = self else { return }
      do {
        try self.audioFile?.write(from: buffer)
      } catch {
        print("Error writing audio buffer: \(error.localizedDescription)")
      }
    }
    
    do {
      audioEngine.prepare()
      try audioEngine.start()
      isRecording = true
      isRecordingPublished = true
    } catch {
      print("Error starting audio engine: \(error.localizedDescription)")
    }
  }
  
  func stopRecording() {
    guard isRecording else { return }
    
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.stop()
    do {
      try audioFile?.close()
    } catch {
      print("❌ Error closing audio file: \(error.localizedDescription)")
    }
    isRecording = false
    isRecordingPublished = false
    print("Recording stopped. File saved at: \(getAudioFileURL().path)")
  }
  
  func playRecording() {
    let fileURL = getAudioFileURL()
    
    if !FileManager.default.fileExists(atPath: fileURL.path) {
      print("❌ File does not exist at path: \(fileURL.path)")
      return
    }
    
    print("✅ Attempting to play file at: \(fileURL.path)")
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
      audioPlayer?.prepareToPlay()
      audioPlayer?.play()
      print("🎵 Playing recording...")
    } catch {
      print("❌ Failed to play audio file: \(error.localizedDescription)")
    }
  }
  
  private func getAudioFileURL() -> URL {
    let fileName = "recording.m4a"
    let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    return filePath
  }
}
