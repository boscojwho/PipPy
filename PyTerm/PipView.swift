//
//  PipView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import SwiftUI

struct PipView: View {
    let pipInstallation: URL
    @State private var pipClient: PipClient
    @Binding var selectedPackage: PipListResponse?
    init(
        pipInstallation: URL,
        isProjectInstallation: Bool,
        selectedPackage: Binding<PipListResponse?>
    ) {
        self.pipInstallation = pipInstallation
        _pipClient = .init(
            wrappedValue: .init(
                installationPath: pipInstallation,
                isProjectInstallation: isProjectInstallation,
                pipExecutable: pipInstallation.lastPathComponent,
                shellClient: .init(currentDirectoryPath: pipInstallation.deletingLastPathComponent().path())
            )
        )
        _selectedPackage = selectedPackage
    }
    
    @State private var packages: [PipListResponse] = []
    
    var body: some View {
        ScrollView {
            Text(pipInstallation.absoluteString)
            LazyVStack {
                if packages.isEmpty {
                    ProgressView()
                } else {
                    ForEach(packages) { package in
                        Text(package.name)
                            .onTapGesture {
                                selectedPackage = package
                            }
                    }
                }
            }
        }
        .task {
            do {
                packages = try await pipClient.list()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    PipView(
        pipInstallation: .init(filePath: "/usr/bin/pip"),
        isProjectInstallation: false,
        selectedPackage: .constant(nil)
    )
}
