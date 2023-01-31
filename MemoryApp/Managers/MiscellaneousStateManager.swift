//
//  MiscellaneousStateManager.swift
//  MemoryApp
//
//  Created by Home on 1/30/23.
//

import Foundation
import SwiftUI


// purpose is to make sure the basic files needed to run the app are present
class MiscellaneousStateManager: NSObject, ObservableObject {
    
    var is_first_time_user: Bool
    
    override init() {
        super.init()
        
        self.setupAudioRecordingDateMetadata()
        self.setFirstTimeUser()
    }
    
    func setupAudioRecordingDateMetadata() {
        let filePath = Bundle.main.path(forResource: "audioRecordingDateMetadata", ofType: "json")!

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            let data = Data()
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }
    }
    
    func setFirstTimeUser() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            self.is_first_time_user = true
            // First launch code here
        } else {
            self.is_first_time_user = false
        }
    }
    
}
