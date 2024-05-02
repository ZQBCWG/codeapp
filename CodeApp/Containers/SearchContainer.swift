//
//  search.swift
//  Code App
//
//  Created by Ken Chung on 5/12/2020.
//

import SwiftUI
import ios_system

struct SearchContainer: View {
    @EnvironmentObject var App: MainApp

    func onTapSearchResult(result: SearchResult, fileURL: URL) {
        App.openFile(url: fileURL)
        Task {
            await App.monacoInstance.focus()
            await App.monacoInstance.searchTermInEditor(term: App.textSearchManager.searchTerm)
            await App.monacoInstance.scrollToLine(line: result.line_num)
        }
    }

    func onSearch() {
        guard
            let path = URL(string: App.workSpaceStorage.currentDirectory.url)?
                .path
        else {
            return
        }
        App.textSearchManager.search(str: App.textSearchManager.searchTerm, path: path)
    }

    func onClearSearchResults() {
        App.textSearchManager.removeAllResults()
    }

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Group {
                    if App.workSpaceStorage.remoteConnected {
                        SearchUnsupportedSection()
                    } else {
                        SearchSection(
                            onSearch: onSearch, onClearSearchResults: onClearSearchResults)
                        SearchResultsSection(onTapSearchResult: onTapSearchResult)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding(.horizontal, 10)
                .scrollIndicators(.hidden)
            }
            .listStyle(.grouped)
        }
    }
}
