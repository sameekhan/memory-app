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

    func createInvertedIndex(documents: [[String]]) -> [String: [Int]] {
        // Create a set of all unique tokens from all documents
        let uniqueTokens = Set(documents.flatMap { $0 })

        // Initialize an empty dictionary to store the inverted index
        var invertedIndex: [String: [Int]] = [:]

        // Iterate over all unique tokens
        for token in uniqueTokens {
            // Initialize an empty array to store the document IDs for the current token
            var documentIDs: [Int] = []

            // Iterate over all documents
            for (documentID, document) in documents.enumerated() {
                // Check if the current token appears in the current document
                if document.contains(token) {
                    // If it does, add the document ID to the document IDs array
                    documentIDs.append(documentID)
                }
            }

            // Add the current token and its corresponding document IDs to the inverted index
            invertedIndex[token] = documentIDs
        }

        // Return the inverted index
        return invertedIndex
    }
    
    // This function takes an inverted index stored as a dictionary and a search query as input
    func search(invertedIndex: [String: [Int]], query: String) -> [Int] {
        // Split the search query into individual terms
        let terms = query.split(separator: " ")
        
        // Initialize a set to store the document IDs that match the search query
        var matchingDocumentIds = Set<Int>()
        
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

