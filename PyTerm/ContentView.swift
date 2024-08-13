//
//  ContentView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {    
    @State private var sidebarFilter: SidebarFilter = .system
    @State private var selectedPip: URL?
    @State private var selectedPackage: PipListResponse?
    @State private var selectedBookmarks = Set<ProjectBookmark>()
    @State private var projectPipInstallations: [URL] = []
    
    var body: some View {
        NavigationSplitView {
            SidebarView(
                filter: $sidebarFilter,
                selectedPip: $selectedPip,
                selectedBookmarks: $selectedBookmarks
            )
        } content: {
            Group {
                if let selectedPip {
                    PipView(
                        pipInstallation: selectedPip,
                        isProjectInstallation: hasVenv(),
                        selectedPackage: $selectedPackage
                    )
                    .id(selectedPip)
                    .toolbar {
                        if hasVenv(), projectPipInstallations.isEmpty == false {
                            Picker("Pick a Pip Installation", selection: $selectedPip) {
                                ForEach(projectPipInstallations, id: \.self) { pip in
                                    Text(pip.lastPathComponent)
                                        .tag(Optional(pip))
                                }
                            }
                        }
                    }
                } else {
                    switch sidebarFilter {
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
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 320, ideal: 360)
        } detail: {
            if let selectedPackage, let selectedPip {
                PipPackageView(
                    pipInstallation: selectedPip,
                    isProjectInstallation: hasVenv(),
                    package: selectedPackage
                )
                .id(selectedPackage)
                .navigationSplitViewColumnWidth(min: 320, ideal: 480)
            } else {
                Text("Select a package")
                    .navigationSplitViewColumnWidth(min: 240, ideal: 320)
            }
        }
        .onChange(of: selectedPip) {
            selectedPackage = nil
        }
        .onChange(of: selectedBookmarks.first) { _, newValue in
            if let bookmark = newValue {
                let venvFinder = VenvFinder(projectUrl: bookmark.url)
                let pipInstallations = venvFinder.findPipInstallations(assumesVenvName: false)
                self.projectPipInstallations = pipInstallations
                self.selectedPip = pipInstallations.first
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
                                    self.selectedPip = pipInstallations.first
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
        guard let selectedPip else { return false }
        return selectedPip.pathComponents.first { $0 == ".venv" } != nil
    }
}

#Preview {
    ContentView()
}
