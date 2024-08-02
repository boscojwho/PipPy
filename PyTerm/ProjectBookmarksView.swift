//
//  ProjectBookmarksView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-02.
//

import SwiftUI
import SwiftData

struct ProjectBookmarksView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var bookmarks: [ProjectBookmark]
    @State private var selectedBookmark: ProjectBookmark?
    
    var body: some View {
        List(selection: $selectedBookmark) {
            ForEach(bookmarks) { bookmark in
                ProjectBookmarkView(bookmark: bookmark)
            }
        }
        .onDrop(of: [.url], isTargeted: nil) { providers in
            for item in providers {
                if item.canLoadObject(ofClass: URL.self) {
                    let _ = item.loadObject(ofClass: URL.self) { url, error in
                        if let url {
                            do {
                                try addBookmark(url: url)
                            } catch {
                                print(error)
                            }
                        } else {
                            if let error {
                                print(error)
                            }
                        }
                    }
                }
            }
            do {
                try modelContext.save()
            } catch {
                print(error)
            }
            return true
        }
    }
    
    private func addBookmark(url: URL) throws {
        guard url.hasDirectoryPath else {
            throw URLError(.unsupportedURL)
        }
        let bookmark = ProjectBookmark(url: url)
        modelContext.insert(bookmark)
    }
}

#Preview {
    ProjectBookmarksView()
}
