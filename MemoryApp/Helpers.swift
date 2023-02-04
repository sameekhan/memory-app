//
//  Helpers.swift
//  MemoryApp
//
//  Created by Home on 2/3/23.
//

import Foundation

func printDocuments() {
    // Get the document directory url
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    let documentDirectory = getDocumentsDirectory()
    print("documentDirectory", documentDirectory.path)
    // Get the directory contents urls (including subfolders urls)
    let directoryContents = try! FileManager.default.contentsOfDirectory(
       at: documentDirectory,
       includingPropertiesForKeys: nil
    )
    let file_names = directoryContents.map { $0.lastPathComponent }
    print("directoryContents:", directoryContents.map { $0.lastPathComponent })
}
