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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ProjectBookmark.self)
    }
}
