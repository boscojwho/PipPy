//
//  SettingsView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.autoUpdater) private var autoUpdater
    @State private var automaticallyChecksForUpdates: Bool = false
    @State private var automaticallyDownloadsUpdates: Bool = false
    
    var body: some View {
        Form {
            GroupBox {
                if let updater = autoUpdater?.updater {
                    Section {
                        VStack(alignment: .leading) {
                            HStack {
                                Toggle("Automatically check for updates", isOn: $automaticallyChecksForUpdates)
                                    .onChange(of: automaticallyChecksForUpdates) { _ , newValue in
                                        updater.automaticallyChecksForUpdates = newValue
                                    }
                                Spacer()
                            }
                            
                            HStack {
                                Toggle("Automatically download updates", isOn: $automaticallyDownloadsUpdates)
                                    .disabled(!automaticallyChecksForUpdates)
                                    .onChange(of: automaticallyDownloadsUpdates) { _, newValue in
                                        updater.automaticallyDownloadsUpdates = newValue
                                    }
                                Spacer()
                            }
                        }
                    } header: {
                        HStack {
                            Text("Auto Update")
                                .font(.title3)
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
                if let homepage = URL(string: "https://github.com/boscojwho/PipPy") {
                    GroupBox {
                        HStack {
                            Link(destination: homepage) {
                                Label("PipPy Homepage", systemImage: "network")
                            }
                            Spacer()
                        }
                    }
                }
            }
            .padding(8)
            
            Spacer()
        }
        .onAppear {
            self.automaticallyChecksForUpdates = autoUpdater?.updater.automaticallyChecksForUpdates ?? false
            self.automaticallyDownloadsUpdates = autoUpdater?.updater.automaticallyDownloadsUpdates ?? false
        }
    }
}
