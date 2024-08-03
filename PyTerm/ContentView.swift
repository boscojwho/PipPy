//
//  ContentView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    private enum SidebarFilter: Int, Identifiable, CaseIterable, CustomStringConvertible {
        case system
        case projects
        
        var id: Int { rawValue }
        var description: String {
            switch self {
            case .system:
                "System"
            case .projects:
                "Projects"
            }
        }
    }
    
    @State private var sidebarFilter: SidebarFilter = .system
    @State private var selectedPip: URL?
    @State private var selectedPackage: PipListResponse?
    @State private var projectPipInstallations: [URL] = []
    
    var body: some View {
        NavigationSplitView {
            Group {
                switch sidebarFilter {
                case .system:
                    PipsView(selectedInstallation: $selectedPip)
                case .projects:
                    ProjectBookmarksView()
                }
            }
            .overlay(alignment: .bottom) {
                Picker("", selection: $sidebarFilter) {
                    ForEach(SidebarFilter.allCases) { filter in
                        Text(filter.description)
                            .tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background()
            }
        } content: {
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
                Text("Select an installation")
            }
        } detail: {
            if let selectedPackage, let selectedPip {
                PipPackageView(
                    pipInstallation: selectedPip,
                    isProjectInstallation: hasVenv(),
                    package: selectedPackage
                )
                .id(selectedPackage)
            } else {
                Text("Select a package")
            }
        }
        .onChange(of: selectedPip) {
            selectedPackage = nil
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
