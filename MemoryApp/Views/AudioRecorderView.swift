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
            if !audioManager.isRecording {
                // TODO: update this with its own view
                Text("Tap to Record")
                Button("Start Recording") {
                    audioManager.startRecording()
                }
            }
        }
    }
}

struct AudioRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRecorderView()
    }
}
