//
//  AudioRecorderView.swift
//  MemoryApp
//
//  Created by Home on 1/20/23.
//

import SwiftUI
import AVFoundation

struct AudioRecorderView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var transcriptionManager: TranscriptionManager
    
    var body: some View {
        VStack {
            if audioManager.isRecording {
                Text("Recording...")
                Button("Stop recording") {
                    audioManager.stopRecording()
                    DispatchQueue.main.async {
                        transcriptionManager.transcribe(audioRecordingUrl: audioManager.audioRecordingUrl)
                        transcriptionManager.recognizeSpeech(from: audioManager.audioRecordingUrl)
                    }
                }
            } else {
                Text("Tap to Record")
                Button("Start Recording") {
                    audioManager.startRecording()
                }
            }
            Button("Play Recording") {
                audioManager.playRecording()
            }
            .padding()
            if transcriptionManager.isProcessing {
                Text("transcription in progress...")
                    .padding()
            } else {
                Text("No transcription in progress.")
                    .padding()
            }
        }
    }
}

struct AudioRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRecorderView()
    }
}
