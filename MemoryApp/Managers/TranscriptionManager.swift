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
    var modelName: String = "ggml-tiny.en"
    var modelFileType: String = "bin"
    
    @Published var isProcessing: Bool = false
    @Published var textFileUrls: [URL] = []
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    func recognizeSpeech(from wavFileUrl: URL) {
        let request = SFSpeechURLRecognitionRequest(url: wavFileUrl)
        request.shouldReportPartialResults = false
        
        self.isProcessing.toggle()
        recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
            guard let result = result else {
                print("Error recognizing speech from wav file: \(error!)")
                return
            }
            print("Recognized speech: \(result.bestTranscription.formattedString)")
            self.saveTranscriptionToFile(transcription: result.bestTranscription.formattedString)
        }
        self.isProcessing.toggle()
    }
    
    func transcribe(audioRecordingUrl: URL) {
        func cb(_ progress: UnsafePointer<Int8>?) -> Int32 {
            let str = String(cString: progress!)
            print(str)
            return 0
        }
        
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: self.modelFileType, subdirectory: "model-binaries")
        
        self.isProcessing.toggle()
        let startTime = CFAbsoluteTimeGetCurrent()
        read_wav(modelURL!.absoluteURL.path, audioRecordingUrl.absoluteURL.path, cb)
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        print("read_wav took these many seconds to execute: \(executionTime)")
        self.isProcessing.toggle()
        
    }
    
    func saveTranscriptionToFile(transcription: String) {
        let fileName = "transcription.txt"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try transcription.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Transcription saved to \(fileURL.path)")
        } catch {
            print("Error saving transcription to file: \(error.localizedDescription)")
        }
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

}
