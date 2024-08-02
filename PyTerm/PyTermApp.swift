//
//  PyTermApp.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI
import SwiftData

@main
struct PyTermApp: App {
    @Environment(\.openWindow) private var openWindow
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    openWindow(id: "project-bookmarks")
                }
        }
        .modelContainer(for: ProjectBookmark.self)
        
        WindowGroup(id: "project-bookmarks") {
            ProjectBookmarksView()
        }
        .modelContainer(for: ProjectBookmark.self)
    }
}
