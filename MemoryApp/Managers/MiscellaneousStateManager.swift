//
//  MiscellaneousStateManager.swift
//  MemoryApp
//
//  Created by Home on 1/30/23.
//

import Foundation


// purpose is to make sure the basic files needed to run the app are present
class MiscellaneousStateManager: NSObject {
    
    override init() {
        super.init()
        
        setupAudioRecordingDateMetadata()
    }
    
    func setupAudioRecordingDateMetadata() {
        let filePath = Bundle.main.path(forResource: "audioRecordingDateMetadata", ofType: "json")!

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            let data = Data()
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }
    }
    
}
