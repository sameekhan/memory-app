//
//  MemoryAppApp.swift
//  MemoryApp
//
//  Created by Home on 1/19/23.
//

import SwiftUI

@main
struct MemoryAppApp: App {
    var miscellaneousStateManager = MiscellaneousStateManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(miscellaneousStateManager)
        }
    }
}
