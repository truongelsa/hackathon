//
//  AudioRecorder.swift
//  hackathon
//
//  Created by Truong Nguyen on 5/3/25.
//

import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
  private var audioRecorder: AVAudioRecorder?
  private let audioSession = AVAudioSession.sharedInstance()
  private var audioPlayer: AVAudioPlayer?
  
  @Published var isRecordingPublished = false
  
  override init() {
    super.init()
    setupAudioSession()
  }
  
  private func setupAudioSession() {
    do {
      try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      print("❌ Failed to set up audio session: \(error.localizedDescription)")
    }
  }
  
  func startRecording() {
    guard audioRecorder == nil else { return }
    
    let fileURL = getAudioFileURL()
    let settings: [String: Any] = [
      AVFormatIDKey: kAudioFormatLinearPCM,  // ✅ WAV format
      AVSampleRateKey: 44100,                // Standard sample rate
      AVNumberOfChannelsKey: 1,              // Mono channel
      AVLinearPCMBitDepthKey: 16,            // 16-bit depth (CD quality)
      AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsFloatKey: false
    ]
    
    do {
      audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
      audioRecorder?.delegate = self
      audioRecorder?.prepareToRecord()
      audioRecorder?.record()
      
      isRecordingPublished = true
      print("🎙 Recording started at: \(fileURL.path)")
    } catch {
      print("❌ Error starting recording: \(error.localizedDescription)")
    }
  }
  
  func stopRecording() {
    guard let audioRecorder = audioRecorder else { return }
    audioRecorder.stop()
    self.audioRecorder = nil
    isRecordingPublished = false
    
    print("✅ Recording stopped. File saved at: \(getAudioFileURL().path)")
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
  
  func playMicStart() {
    guard let micStartSoundURL = Bundle.main.url(forResource: "mic_start_sound", withExtension: "mp3") else {
      print("❌ mic_start_sound.mp3 file not found")
      return
    }
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: micStartSoundURL)
      audioPlayer?.prepareToPlay()
      audioPlayer?.play()
      print("🎵 Playing mic start sound...")
    } catch {
      print("❌ Failed to play mic start sound: \(error.localizedDescription)")
    }
  }

  func playMicStop() {
    guard let micStartSoundURL = Bundle.main.url(forResource: "mic_stop_sound", withExtension: "mp3") else {
      print("❌ mic_start_sound.mp3 file not found")
      return
    }
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: micStartSoundURL)
      audioPlayer?.prepareToPlay()
      audioPlayer?.play()
      print("🎵 Playing mic start sound...")
    } catch {
      print("❌ Failed to play mic start sound: \(error.localizedDescription)")
    }
  }
  
  func getAudioFileURL() -> URL {
    let fileName = "recording.wav"  // ✅ Saved as WAV format
    return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
  }
}

extension AudioRecorder: AVAudioRecorderDelegate {
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    if flag {
      print("✅ Recording finished successfully")
    } else {
      print("❌ Recording failed")
    }
  }
}
