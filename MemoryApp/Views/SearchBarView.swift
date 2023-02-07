//
//  SearchBarView.swift
//  MemoryApp
//
//  Created by Home on 2/6/23.
//

import SwiftUI

struct SearchBarView: View {
    @State private var searchTerm: String = ""
    @State private var files: [String] = []

    var body: some View {
        VStack {
            SearchBar(text: $searchTerm, files: $files)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var files: [String]

    var body: some View {
        HStack {
            TextField(
                "Search",
                text: $text,
                onCommit: {
                    // Trigger search action here
                    print("Searching for: \(self.text)")
                    self.files = SearchManager.search(query: self.text)
                    print("Retuning files: \(self.files)")
                })
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Button(action: {
                self.text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal, 8)
        
        VStack {
            ForEach(files, id: \.self) { file in
                Text(self.getTextFromFile(file))
                    .lineLimit(5, reservesSpace: true)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.bottom, 8)
                Text("Transcribed at \(self.getModifiedDateForFile(file))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
    }
    
    func getTextFromFile(_ file: String) -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentsDirectory.appendingPathComponent(file)
        do {
            let fileContents = try String(contentsOf: fileUrl, encoding: .utf8)
            return fileContents
        } catch {
            return "Error reading file"
        }
    }
    func getModifiedDateForFile(_ file: String) -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentsDirectory.appendingPathComponent(file)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileUrl.path)
            let modificationDate = attributes[FileAttributeKey.modificationDate] as! Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            return dateFormatter.string(from: modificationDate)
        } catch {
            return "Error reading file modification date"
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
