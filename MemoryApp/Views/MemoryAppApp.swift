//
//  MemoryAppApp.swift
//  MemoryApp
//
//  Created by Home on 1/19/23.
//

import SwiftUI

@main
struct MemoryAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    MiscellaneousStateManager()
                }
        }
    }
}
