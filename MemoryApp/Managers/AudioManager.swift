//
//  AudioManager.swift
//  MemoryApp
//
//  Created by Home on 1/20/23.
//

import Foundation
import SwiftUI
import AVFoundation

protocol AudioManagerDelegate: AnyObject {
    func didFinishRecording()
}

class AudioManager: NSObject, ObservableObject {
    
    var audioSession: AVAudioSession!
    var permission: AVAudioSession.RecordPermission!
    var audioRecorder : AVAudioRecorder?
    private weak var delegate: AudioManagerDelegate?
    
    var audioRecordingUrl: URL!
    
    var audioPlayer: AVAudioPlayer?
    
    @Published var isRecording = false
    
    static let settings: [String: Any] = [
         AVFormatIDKey: kAudioFormatLinearPCM, // PCM but really for WAV
         AVLinearPCMBitDepthKey: 16, // 16 bit
         AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
         AVNumberOfChannelsKey: 1, // 1 channel
         AVSampleRateKey: 16000 // 16khz
     ]
    
    override init() {
        super.init()
        
        self.audioSession = AVAudioSession.sharedInstance()
        self.permission = self.audioSession.recordPermission
        
        // audio recorder set up
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentsDirectory.appendingPathComponent("recordedVoice_\(UUID()).wav")
        self.audioRecordingUrl = fileUrl
    }
    
    
    func requestAudioPermission() {
        // Request permission to record user's voice
        self.audioSession.requestRecordPermission() { allowed in }
    }
    
    // Needed when user grants access then revokes in the privacy & security settings menu
    func redirectToAppSettings() {
        // Create the URL that deep links to your app's custom settings.
        if let url = URL(string: UIApplication.openSettingsURLString) {
            // Ask the system to open that URL.
            UIApplication.shared.open(url)
        }
    }
    
    func deactivateAudioSession() {
        do {
            try self.audioSession.setActive(false)
        } catch {
            print("error setting audio session to false", error)
        }
    }
    
    func activateAudioSession() {
        do {
            try self.audioSession.setActive(true)
        } catch {
            print("error setting audio session to true", error)
        }
    }

    // all audio recorder related code
    
    func startRecording() {
        self.initializeAudioRecorder()
        self.activateAudioSession()
        self.audioRecorder?.record()
        self.isRecording.toggle()
    }
    
    func stopRecording() {
        self.audioRecorder?.stop()
        self.audioRecorder = nil
        self.isRecording.toggle()
        self.deactivateAudioSession()
    }
    
    func initializeAudioRecorder() {
        do {
            self.audioRecorder = try AVAudioRecorder(url: self.audioRecordingUrl, settings: AudioManager.settings)
        } catch {
            print("failed setting up audio recorder X(", error)
        }
        
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
        
        do {
            // Set audio session category to record and play back audio
            try self.audioSession.setCategory(.record, mode: .default)
        } catch {
            print("Setting category or activating session failed")
        }
    }
    
    // All audio player related code
    
    func initializeAudioPlayer() {
        do {
            print(self.audioRecordingUrl)
            try self.audioSession.setCategory(.playback)
            try self.audioSession.setActive(true)
            self.audioPlayer = try AVAudioPlayer(contentsOf: self.audioRecordingUrl)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.enableRate = true    // Enable playing rate change
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.volume = 10
        } catch {
            print("Error from initializing audio player: \(error)")
        }
    }

    
    func playRecording() {
        self.initializeAudioPlayer()
        self.audioPlayer?.play()
    }
    
    func stopPlayingRecording() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        self.deactivateAudioSession()
    }
    
    
    func printDocuments() {
        // Get the document directory url
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }
        let documentDirectory = getDocumentsDirectory()
        print("documentDirectory", documentDirectory.path)
        // Get the directory contents urls (including subfolders urls)
        let directoryContents = try! FileManager.default.contentsOfDirectory(
           at: documentDirectory,
           includingPropertiesForKeys: nil
        )
        print("directoryContents:", directoryContents.map { $0.lastPathComponent })
    }
}

extension AudioManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("recording finished with result: \(flag)")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
}
