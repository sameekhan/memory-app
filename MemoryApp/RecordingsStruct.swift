//
//  RecordingsStruct.swift
//  MemoryApp
//
//  Created by Home on 2/1/23.
//

import Foundation

// Define the Recordings struct for decoding and encoding the JSON data
struct Recording: Codable {
    let identifier: UUID
    let recordingStartTime: Date?
    let recordingFileName: String
    let recordingDuration: Int
    var transcriptionFileName: String
    var isIndexed: Bool
}
func getMetadataFilePath() -> String {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let filePath = documentsDirectory.appendingPathComponent("audioRecordingDateMetadata.json")
    return filePath.absoluteString
}

func getRecordingsFromMetadataFile() -> [Recording] {
    // Read the JSON file and decode the data into an array of Recordings objects
    if let data = FileManager.default.contents(atPath: getMetadataFilePath()),
       let recordingsArray = try? JSONDecoder().decode([Recording].self, from: data) {
        return recordingsArray
    }
    return []
}
