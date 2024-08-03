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
    @Binding var selectedBookmarks: Set<ProjectBookmark>
    init(selectedBookmarks: Binding<Set<ProjectBookmark>>) {
        _selectedBookmarks = selectedBookmarks
    }
    
    @Query private var bookmarks: [ProjectBookmark]
    
    var body: some View {
        List(selection: $selectedBookmarks) {
            if bookmarks.isEmpty {
                ContentUnavailableView(
                    "Add Projects Here",
                    systemImage: "square.and.arrow.down",
                    description: Text("Drag and drop Python project directories here.")
                )
                .lineLimit(3)
            } else {
                ForEach(bookmarks) { bookmark in
                    ProjectBookmarkView(bookmark: bookmark)
                }
                .contextMenu {
                    let buttonText = selectedBookmarks.count > 1 ? "Remove Bookmarks (\(selectedBookmarks.count))" : "Remove Bookmark"
                    Button(buttonText, systemImage: "minus.circle", role: .destructive) {
                        for bookmark in selectedBookmarks {
                            modelContext.delete(bookmark)
                        }
                    }
                }
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
    ProjectBookmarksView(selectedBookmarks: .constant([]))
}
