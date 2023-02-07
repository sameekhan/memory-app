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
                Image("microphoneicon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        audioManager.startRecording()
                    }

                Text("Start Recording")
            }
        }
    }
}

struct AudioRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRecorderView()
    }
}
