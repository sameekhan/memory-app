//
//  SearchBarView.swift
//  MemoryApp
//
//  Created by Home on 2/6/23.
//

import SwiftUI

struct SearchBarView: View {
    @State private var searchTerm: String = ""

    var body: some View {
        VStack {
            SearchBar(text: $searchTerm)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search",
                      text: $text,
                      onCommit: {
                            // Trigger search action here
                            print("Searching for: \(self.text)")
                            print(SearchManager.search(query: self.text))
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
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
