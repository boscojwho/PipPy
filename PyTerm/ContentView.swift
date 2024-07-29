//
//  ContentView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI

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
    }
}

#Preview {
    ContentView()
}
