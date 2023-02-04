//
//  TranscriptionManager.swift
//  MemoryApp
//
//  Created by Home on 1/26/23.
//

import Foundation
import AudioKit
import Speech

class TranscriptionManager: NSObject, ObservableObject {
    @Published var isProcessing: Bool = false
    @Published var textFileUrls: [URL] = []
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    func recognizeSpeech(from wavFileUrl: URL, metadataIdentifier: UUID) {
        print("starting apple ASR transcription")
        let request = SFSpeechURLRecognitionRequest(url: wavFileUrl)
        request.shouldReportPartialResults = false
        
        self.isProcessing.toggle()
        recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
            guard let result = result else {
                print("Error recognizing speech from wav file: \(error!)")
                return
            }
            print("Recognized speech: \(result.bestTranscription.formattedString)")
            self.saveTranscriptionToFile(
                transcription: result.bestTranscription.formattedString,
                audioRecordingUrl: wavFileUrl,
                metadataIdentifier: metadataIdentifier
            )
        }
        self.isProcessing.toggle()
    }
    
    func saveTranscriptionToFile(transcription: String, audioRecordingUrl: URL, metadataIdentifier: UUID) {
        let fileName = "transcription_\(metadataIdentifier).txt"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try transcription.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Transcription saved to \(fileURL.path)")
        } catch {
            print("Error saving transcription to file: \(error.localizedDescription)")
        }
        self.saveTranscriptionMetadata(
            transcriptionFileName: fileName,
            metadataIdentifier: metadataIdentifier)
        self.textFileUrls = self.getTextTranscriptionDocuments()
    }
    
    func getTextTranscriptionDocuments() -> [URL] {
        var textFiles = [URL]()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            for file in files {
                if file.pathExtension == "txt" {
                    textFiles.append(file)
                }
            }
        } catch {
            print("Error listing files in documents directory: \(error.localizedDescription)")
        }
        return textFiles
    }
    
    func saveTranscriptionMetadata(transcriptionFileName: String, metadataIdentifier: UUID) {
        var recordings = getRecordingsFromMetadataFile()
        
        // modify record to include transcription file name
        for i in 0..<recordings.count {
            if recordings[i].identifier == metadataIdentifier {
                recordings[i].transcriptionFileName = transcriptionFileName
                break
            }
        }

        // Encode the updated array of Recordings objects and write it to the JSON file
        let updatedData = try? JSONEncoder().encode(recordings)
        do {
            try updatedData?.write(to: getMetadataFilePath())
        } catch {
            print(error)
        }
        
    }

}
