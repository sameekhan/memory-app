//
//  RequestPermissionsView.swift
//  MemoryApp
//
//  Created by Home on 1/20/23.
//

import SwiftUI

struct RequestPermissionsView: View {
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        
        switch audioManager.permission {
        case .denied:
            Text("Microphone permission denied :(")
            Button("Grant microphone permissions.") {
                audioManager.redirectToAppSettings()
            }
        case .undetermined:
            Button("Grant microphone permissions.") {
                audioManager.requestAudioPermission()
            }
        case .none:
            Text("Unfamiliar error.")
        @unknown default:
            Text("Unfamiliar error.")
        }
    }
}

struct RequestPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        RequestPermissionsView()
    }
}
