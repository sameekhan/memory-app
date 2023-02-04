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
    
    var is_first_time_user: Bool = false
    
    override init() {
        super.init()
        
        self.setupAudioRecordingDateMetadata()
        self.setupInvertedIndexFile()
        self.is_first_time_user = self.setFirstTimeUser()
    }
    
    func setupAudioRecordingDateMetadata() {
        print("setting up audio recording metadata")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("audioRecordingDateMetadata.json")

        let fileManager = FileManager.default
//        printDocuments()
        if !fileManager.fileExists(atPath: filePath.path) {
            let data = Data()
            do {
                try data.write(to: filePath)
            } catch {
                print(error)
            }
        } else {
            if let data = FileManager.default.contents(atPath: filePath.path),
               let recordingsArray = try? JSONDecoder().decode([Recording].self, from: data) {
                    print(recordingsArray)
            }
        }
    }
    
    func setupInvertedIndexFile() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("invertedIndex.json")

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath.path) {
            let data = Data()
            do {
                try data.write(to: filePath)
            } catch {
                print(error)
            }
        }
    }
    
    func setFirstTimeUser() -> Bool {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            return true
            // First launch code here
        } else {
            return false
        }
    }
    
}
