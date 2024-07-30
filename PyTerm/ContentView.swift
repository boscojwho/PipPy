//
//  ContentView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedPip: URL?
    @State private var selectedPackage: PipListResponse?
    @State private var projectPipInstallations: [URL] = []
    
    var body: some View {
        NavigationSplitView {
            PipsView(selectedInstallation: $selectedPip)
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
                                let pipInstallations = venvFinder.findPipInstallations()
                                self.projectPipInstallations = pipInstallations
                                self.selectedPip = pipInstallations.first
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
