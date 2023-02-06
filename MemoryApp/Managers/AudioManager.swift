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
    
    @Published var isRecording = false
    
    var recordingStartTime: Date?
    var recordingDuration: Int = 60
    
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
    }
    
    func makeAudioRecordingFile() {
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
        self.makeAudioRecordingFile()
        self.initializeAudioRecorder()
        self.activateAudioSession()
        // just for testing
//        self.audioRecorder?.record(forDuration: TimeInterval(self.recordingDuration * 60))
        print("started recording")
        self.audioRecorder?.record(forDuration: TimeInterval(self.recordingDuration))
        self.recordingStartTime = Date()
        self.isRecording.toggle()
    }
    
    func initializeAudioRecorder() {
        do {
            self.audioRecorder = try AVAudioRecorder(url: self.audioRecordingUrl, settings: AudioManager.settings)
            self.audioRecorder?.delegate = self
        } catch {
            print("failed setting up audio recorder X(", error)
        }
        
        self.audioRecorder?.isMeteringEnabled = true
        self.audioRecorder?.prepareToRecord()
        
        do {
            // Set audio session category to record audio
            try self.audioSession.setCategory(.record, mode: .default)
        } catch {
            print("Setting category or activating session failed")
        }
    }
    
    func saveAudioRecordingMetadata(identifier: UUID) {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("audioRecordingDateMetadata.json")

        var recordings = [Recording]()

        // Read the JSON file and decode the data into an array of Recordings objects
        if let data = FileManager.default.contents(atPath: filePath.path),
           let recordingsArray = try? JSONDecoder().decode([Recording].self, from: data) {
            recordings = recordingsArray
        }

        // Create a new Recordings object to insert into the array
        let newRecording = Recording(identifier: identifier,
                                      recordingStartTime: self.recordingStartTime,
                                      recordingFileName: self.audioRecordingUrl.path,
                                      recordingDuration: self.recordingDuration,
                                      transcriptionFileName: "",
                                      isIndexed: false)

        // Append the new object to the array
        recordings.append(newRecording)

        // Encode the updated array of Recordings objects and write it to the JSON file
        let updatedData = try? JSONEncoder().encode(recordings)
        do {
            try updatedData?.write(to: filePath)
//            self.printDocuments() for debugging
        } catch {
            print(error)
        }
    }
}

extension AudioManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("recording finished with result: \(flag)")
        if flag {
            self.isRecording.toggle()
            self.deactivateAudioSession()
            let recordingIdentifier = UUID()
            self.saveAudioRecordingMetadata(identifier: recordingIdentifier)
            let audioRecordingUrl = self.audioRecordingUrl
            self.startRecording()
            
            // perform transcription and indexing in the background
            DispatchQueue.global(qos: .background).async {
                print("background transcription and indexing")
                // Perform a long-running task in the background
                let transcriptionManager = TranscriptionManager()
                transcriptionManager.recognizeSpeech(
                    from: audioRecordingUrl!,
                    metadataIdentifier: recordingIdentifier
                )
            }
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
}
