//
//  PyTermApp.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI
import SwiftData
import Sparkle

private struct AutoUpdateEnvironmentKey : EnvironmentKey {
    static let defaultValue: SPUStandardUpdaterController? = nil
}

extension EnvironmentValues {
    var autoUpdater: SPUStandardUpdaterController? {
        get { self[AutoUpdateEnvironmentKey.self] }
        set { self[AutoUpdateEnvironmentKey.self] = newValue }
    }
}

@main
struct PyTermApp: App {
    private let updaterController: SPUStandardUpdaterController
    
    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [ProjectBookmark.self, PyPIFeedItem.self])
        .windowResizability(.contentMinSize)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultPosition(.center)
        .defaultSize(width: 1080, height: 720)
        .commands {
            CommandGroup(after: .appInfo) {
                AutoUpdaterView(updater: updaterController.updater)
            }
        }
        
        Settings {
            SettingsView()
                .frame(minWidth: 420, minHeight: 144)
        }
        .environment(\.autoUpdater, updaterController)
        .windowResizability(.contentMinSize)
        .defaultPosition(.topTrailing)
        .defaultSize(width: 420, height: 144)
    }
}
