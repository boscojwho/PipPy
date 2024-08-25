//
//  ContentView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI
import UniformTypeIdentifiers

@Observable
final class SidebarPreferences {
    var sidebarFilter: SidebarFilter = .system
}

@Observable
final class ContentSelectionPreferences {
    var selectedFeed: PyPIFeed = .newestPackages
    var selectedPip: URL?
    var selectedPackage: PipListResponse?
    var selectedBookmarks = Set<ProjectBookmark>()
}

struct ContentView: View {
    @State private var sidebarPreferences: SidebarPreferences = .init()
    @State private var contentSelectionPreferences: ContentSelectionPreferences = .init()
    @State private var projectPipInstallations: [URL] = []
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } content: {
            Group {
                @Bindable var contentSelection = contentSelectionPreferences
                switch sidebarPreferences.sidebarFilter {
                case .browse:
                    PyPIFeedView(
                        feedURL: contentSelectionPreferences.selectedFeed.url,
                        feedType: contentSelectionPreferences.selectedFeed
                    )
                    .toolbar {
                        Text(contentSelectionPreferences.selectedFeed.description)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .navigationSplitViewColumnWidth(min: 320, ideal: 720)
                case .system, .projects:
                    if let selectedPip = contentSelectionPreferences.selectedPip {
                        PipView(
                            pipInstallation: selectedPip,
                            isProjectInstallation: hasVenv(),
                            selectedPackage: $contentSelection.selectedPackage
                        )
                        .id(selectedPip)
                        .toolbar {
                            if sidebarPreferences.sidebarFilter == .projects, projectPipInstallations.isEmpty == false {
                                Picker("Pick a Pip Installation", selection: $contentSelection.selectedPip) {
                                    ForEach(projectPipInstallations, id: \.self) { pip in
                                        Text(pip.lastPathComponent)
                                            .tag(Optional(pip))
                                    }
                                }
                            }
                        }
                    } else {
                        switch sidebarPreferences.sidebarFilter {
                        case .system:
                            ContentUnavailableView(
                                "Select an Installation",
                                systemImage: "folder.badge.gearshape",
                                description: Text("Select a PIP installation from the sidebar to view its installed packages.")
                            )
                            .lineLimit(3)
                        case .projects:
                            ContentUnavailableView(
                                "Select a Project",
                                systemImage: "folder",
                                description: Text("Select a project from the sidebar to view its pip installations and installed packages.")
                            )
                            .lineLimit(3)
                        case .browse:
                            EmptyView()
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 320, ideal: 360)
        } detail: {
            if let selectedPip = contentSelectionPreferences.selectedPip {
                if let selectedPackage = contentSelectionPreferences.selectedPackage {
                    PipPackageView(
                        pipInstallation: selectedPip,
                        isProjectInstallation: hasVenv(),
                        package: selectedPackage
                    )
                    .id(selectedPackage)
                    .navigationSplitViewColumnWidth(min: 480, ideal: 480)
                } else {
                    GroupBox {
                        Text("Select a package")
                    }
                    .navigationSplitViewColumnWidth(min: 240, ideal: 320)
                }
            } else {
                /// `EmptyView` doesn't work for here some reason.
                Text("")
                    .hidden()
                    .navigationSplitViewColumnWidth(min: 0, ideal: 0, max: 0)
            }
        }
        .environment(sidebarPreferences)
        .environment(contentSelectionPreferences)
        .onChange(of: sidebarPreferences.sidebarFilter) {
            contentSelectionPreferences.selectedPip = nil
            contentSelectionPreferences.selectedPackage = nil
            contentSelectionPreferences.selectedBookmarks = .init()
        }
        .onChange(of: contentSelectionPreferences.selectedPip) {
            contentSelectionPreferences.selectedPackage = nil
        }
        .onChange(of: contentSelectionPreferences.selectedBookmarks.first) { _, newValue in
            if let bookmark = newValue {
                let venvFinder = VenvFinder(projectUrl: bookmark.url)
                let pipInstallations = venvFinder.findPipInstallations(assumesVenvName: false)
                self.projectPipInstallations = pipInstallations
                self.contentSelectionPreferences.selectedPip = pipInstallations.first
            }
        }
        .onDrop(of: [.url], isTargeted: nil) { providers in
            for item in providers {
                if item.canLoadObject(ofClass: URL.self) {
                    let _ = item.loadObject(ofClass: URL.self) { url, error in
                        if let url {
                            Task { @MainActor in
//                                self.selectedPip = url
                                let venvFinder = VenvFinder(projectUrl: url)
                                let pipInstallations = venvFinder.findPipInstallations(assumesVenvName: false)
                                if pipInstallations.isEmpty {
                                    let pythonProgram = "python3"
                                    let shellClient = ShellClient(currentDirectoryPath: url.path())
                                    let whichPython = try await shellClient.executeCommand("which \(pythonProgram)")
                                    let python = String(decoding: whichPython, as: UTF8.self)
                                    let pythonInterpreter = URL(filePath: python)
                                    print(pythonInterpreter.path(percentEncoded: false))
//                                    shellClient.executeCommand("which pip")
                                } else {
                                    self.projectPipInstallations = pipInstallations
                                    self.contentSelectionPreferences.selectedPip = pipInstallations.first
                                }
                            }
                        } else {
                            if let error {
                                print(error)
                            }
                        }
                    }
                }
            }
            return true
        }
    }
    
    private func hasVenv() -> Bool {
        guard let selectedPip = contentSelectionPreferences.selectedPip else { return false }
        return VenvFinder(projectUrl: selectedPip)
            .findVenv()
            .isEmpty == false
    }
}

#Preview {
    ContentView()
}
