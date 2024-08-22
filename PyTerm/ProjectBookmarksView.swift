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
                Section {
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
                } header: {
                    LabeledContent {
                        HStack {
                            Text("Projects")
                            Spacer()
                        }
                    } label: {
                        Image(systemName: "folder")
                            .fontWeight(.light)
                    }
                    .padding(4)
                    .tint(.secondary)
                }
            }
        }
        .onDrop(of: [.url], isTargeted: nil) { providers in
            Task {
                let urls = try await withThrowingTaskGroup(of: URL.self, returning: [URL].self) { taskGroup in
                    for item in providers {
                        taskGroup.addTask {
                            try await loadURL(item)
                        }
                    }
                    
                    var urls: [URL] = []
                    for try await url in taskGroup {
                        urls.append(url)
                    }
                    return urls
                }
               
                for url in urls {
                    do {
                        try await addBookmark(url: url)
                    } catch {
                        print(error)
                    }
                }
                
                try await saveContext()
            }
            
            return true
        }
    }
    
    
    nonisolated private func loadURL(_ item: NSItemProvider) async throws -> URL {
        guard item.canLoadObject(ofClass: URL.self) else {
            throw NSError(domain: "", code: 0)
        }
        return try await withCheckedThrowingContinuation { continuation in
            let _ = item.loadObject(ofClass: URL.self) { url, error in
                if let url {
                    continuation.resume(returning: url)
                } else {
                    if let error {
                        print(error)
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: NSError(domain: "", code: 0))
                    }
                }
            }
        }
    }
    
    @MainActor
    private func addBookmark(url: URL) async throws {
        guard url.hasDirectoryPath else {
            throw URLError(.unsupportedURL)
        }
        let bookmark = ProjectBookmark(url: url)
        modelContext.insert(bookmark)
    }
    
    @MainActor
    private func saveContext() async throws {
        try modelContext.save()
    }
}

#Preview {
    ProjectBookmarksView(selectedBookmarks: .constant([]))
}
