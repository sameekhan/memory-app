import Foundation
import NaturalLanguage

struct SearchManager {
    
    // Declare a function named `tokenize` that takes a single argument `text` of type `String`
    static func tokenize(text: String) -> [String] {
        
        // Define a regular expression pattern that matches words composed of one or more alphabetic characters
        let pattern = "\\b[a-zA-Z]+\\b"
        
        // Create a regular expression object using the pattern
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        // Create a range that covers the entire input text
        let range = NSRange(location: 0, length: text.utf16.count)
        
        // Find all matches of the regular expression in the input text
        let tokens = regex.matches(in: text, options: [], range: range)
        
        // Return an array of strings, where each string is a matched word from the input text
        return tokens.map { String(text[Range($0.range, in: text)!]) }
    }
    
    static func processTokens(tokens: [String]) -> [String] {
        // Load a list of stop words
        let stopWords = Set(["and", "the", "a", "an", "in", "of", "to", "with", "for", "on", "at", "by", "from", "up", "down", "out", "about", "into", "over", "after", "above", "below", "beneath", "under", "beside", "around", "among", "within", "through", "during", "before", "after", "behind", "above", "across", "beyond", "along", "onto", "towards", "into", "amongst", "among", "beside", "between", "beyond", "outside", "inside", "inside of", "within", "amongst", "amidst", "among", "betwixt", "between", "midst", "throughout", "thru", "till", "until", "to", "toward", "towards", "unto", "upon", "vs", "versus", "vs."])
        
        // Use NaturalLanguage framework to perform stemming or lemmatization
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = tokens.joined(separator: " ")
        var lemmatizedTokens: [String] = []
        let range = tagger.string!.startIndex ..< tagger.string!.endIndex
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma) { (tag, range) -> Bool in
            lemmatizedTokens.append(tag?.rawValue.lowercased() ?? "")
            return true
        }
        
        // Remove stop words from the list of lemmatized tokens
        return lemmatizedTokens.filter { !stopWords.contains($0) && $0.count > 0 }
    }
    
    static func createUniqueTokenList(tokens: [String]) -> [String] {
        return Array(Set(tokens))
    }
    
    static func getInvertedIndexPath() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("invertedIndex.json")
    }
    
    static func updateInvertedIndex(uniqueTokens: [String], documentID: String) {
        print("Unique tokens: \(uniqueTokens) \nDocument ID: \(documentID)")
        // Initialize an empty dictionary to store the inverted index
        var invertedIndex: [String: [String]] = [:]
        
        // read in existing index from file
        invertedIndex = SearchManager.getInvertedIndex()
        
        // Iterate over all unique tokens
        for token in uniqueTokens {
            var documentIDs = invertedIndex[token] ?? []
            // Add the current token and its corresponding document IDs to the inverted index
            documentIDs.append(documentID)
            invertedIndex[token] = Array(Set(documentIDs))
        }
        
        // update the inverted index
        // Encode the updated array of Recordings objects and write it to the JSON file
        let updatedData = try? JSONEncoder().encode(invertedIndex)
        do {
            try updatedData?.write(to: SearchManager.getInvertedIndexPath())
        } catch {
            print(error)
        }
    }
    
    static func getInvertedIndex() -> [String: [String]] {
        // Initialize an empty dictionary to store the inverted index
        var invertedIndex: [String: [String]] = [:]
        
        // read in existing index from file
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("invertedIndex.json")
        // Read the JSON file and decode the data into an array of Recordings objects
        if let data = FileManager.default.contents(atPath: filePath.path),
           let invertedIndexData = try? JSONDecoder().decode([String: [String]].self, from: data) {
            invertedIndex = invertedIndexData
        }
//        print("Inverted index returned: \(invertedIndex)")
        return invertedIndex
    }
    
    // This function takes an inverted index stored as a dictionary and a search query as input
    static func search(query: String) -> [String] {
        let invertedIndex = SearchManager.getInvertedIndex()
        // Split the search query into individual terms
        let terms = query.split(separator: " ")
        
        // Initialize a set to store the document IDs that match the search query
        var matchingDocumentIds = Set<String>()
        
        // Loop through each term in the search query
        for term in terms {
            // Check if the term is present in the inverted index
            if let postingList = invertedIndex[String(term)] {
                // If the set is empty, add all the documents from the posting list
                if matchingDocumentIds.isEmpty {
                    matchingDocumentIds.formUnion(postingList)
                } else {
                    // Intersect the set with the documents from the posting list to find documents that contain all the terms
                    matchingDocumentIds.formIntersection(postingList)
                }
            } else {
                // If the term is not present in the inverted index, return an empty array
                return []
            }
        }
        
        // Return the array of document IDs that match the search query
        return Array(matchingDocumentIds)
    }
    
    static func getTranscriptionFilePath(fileName: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent(fileName)
        return filePath
    }
    
    static func constructIndex(metadataIdentifier: UUID) {
        print("beginning indexing")
        // get metadata record
        let record = getRecordingsFromMetadataFile().filter {
            return $0.identifier == metadataIdentifier
        }.first!
        
        var transcriptionText: String = ""
        // get transcription file
        if let data = try? Data(contentsOf: getTranscriptionFilePath(fileName: record.transcriptionFileName)) {
            transcriptionText = String(data: data, encoding: .utf8)!
        }
        
        // Tokenize the document
        let transcriptionTokens = SearchManager.tokenize(text: transcriptionText)

        // Process the tokens
        let processedTranscriptionTokens = SearchManager.processTokens(tokens: transcriptionTokens)

        // Create a list of unique tokens
        let uniqueTokens = SearchManager.createUniqueTokenList(tokens: processedTranscriptionTokens)
        
        // Update inverted index
        SearchManager.updateInvertedIndex(uniqueTokens:uniqueTokens, documentID: record.transcriptionFileName)
        
        // update metadata file
        SearchManager.updateAudioRecordingMetadataForIndex(identifier: metadataIdentifier)
        
        print("finished indexing")
    }
    
    static func updateAudioRecordingMetadataForIndex(identifier: UUID) {
        
        var recordings = getRecordingsFromMetadataFile()
        
        // modify record to include transcription file name
        for i in 0..<recordings.count {
            if recordings[i].identifier == identifier {
                recordings[i].isIndexed = true
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
 
