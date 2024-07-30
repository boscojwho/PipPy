//
//  PipPackageView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-29.
//

import SwiftUI

struct PipPackageView: View {
    let package: PipListResponse
    @State private var pipClient: PipClient
    init(
        pipInstallation: URL,
        isProjectInstallation: Bool,
        package: PipListResponse
    ) {
        self.package = package
        _pipClient = .init(
            wrappedValue: .init(
                installationPath: pipInstallation,
                isProjectInstallation: isProjectInstallation, 
                pipExecutable: pipInstallation.lastPathComponent,
                shellClient: .init(currentDirectoryPath: pipInstallation.deletingLastPathComponent().path())
            )
        )
    }

    @State private var packageInfo: String?
    
    var body: some View {
        ScrollView {
            VStack {
                Text(package.name)
                if let packageInfo {
                    Text(packageInfo)
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            do {
                packageInfo = try await pipClient.show(package.name)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    PipPackageView(
        pipInstallation: .init(filePath: "/usr/bin/pip"),
        isProjectInstallation: false,
        package: .mock()
    )
}
