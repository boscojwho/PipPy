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
    
    var body: some View {
        NavigationSplitView {
            PipsView(selectedInstallation: $selectedPip)
        } content: {
            if let selectedPip {
                PipView(
                    pipInstallation: selectedPip,
                    isProjectInstallation: isProjectInstallation(),
                    selectedPackage: $selectedPackage
                )
                .id(selectedPip)
            } else {
                Text("Select an installation")
            }
        } detail: {
            if let selectedPackage, let selectedPip {
                PipPackageView(
                    pipInstallation: selectedPip,
                    isProjectInstallation: isProjectInstallation(),
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
    
    private func isProjectInstallation() -> Bool {
        guard let selectedPip else { return false }
        return !selectedPip.lastPathComponent.hasPrefix("pip")
    }
}

#Preview {
    ContentView()
}
