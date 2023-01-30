//
//  ContentView.swift
//  MemoryApp
//
//  Created by Home on 1/19/23.
//

import Foundation
import SwiftUI
import AVFoundation


struct ContentView: View {
    @StateObject var audioManager = AudioManager()
    @StateObject var transcriptionManager = TranscriptionManager()

    var body: some View {
        VStack {
            Text("Memory")
                .font(.largeTitle)
                .foregroundColor(Color.purple)
                .padding(.bottom)
            
            if audioManager.permission != .granted {
                RequestPermissionsView()
                    .environmentObject(audioManager)
            } else {
                AudioRecorderView()
                    .environmentObject(audioManager)
                    .environmentObject(transcriptionManager)
            }
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            maxHeight: 50,
            alignment: .center)
        .position(x:195, y:100)
        
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
