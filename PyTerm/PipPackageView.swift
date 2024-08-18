//
//  PipPackageView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-29.
//

import SwiftUI

struct PipPackage: Codable, Hashable, Identifiable {
    let name: String
    let version: String
    let summary: String
    let homepage: String
    let author: String
    let authorEmail: String
    let license: String
    let location: URL
    let requires: String
    let requiredBy: String
    
    var id: String { name + version }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case name = "Name"
        case version = "Version"
        case summary = "Summary"
        case homepage = "Home-page"
        case author = "Author"
        case authorEmail = "Author-email"
        case license = "License"
        case location = "Location"
        case requires = "Requires"
        case requiredBy = "Required-by"
        
        var keyPath: PartialKeyPath<PipPackage> {
            switch self {
            case .name:
                return \.name
            case .version:
                return \.version
            case .summary:
                return \.summary
            case .homepage:
                return \.homepage
            case .author:
                return \.author
            case .authorEmail:
                return \.authorEmail
            case .license:
                return \.license
            case .location:
                return \.location
            case .requires:
                return \.requires
            case .requiredBy:
                return \.requiredBy
            }
        }
    }
}

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

    @State private var packageInfo: PipPackage?
    
    var body: some View {
        List {
            Section {
                if let packageInfo {
                    ForEach(PipPackage.CodingKeys.allCases, id: \.self) { codingKey in
                        LabeledContent {
                            HStack {
                                Spacer()
                                Text("\(packageInfo[keyPath: codingKey.keyPath])")
                                    .multilineTextAlignment(.trailing)
                            }
                        } label: {
                            Text(codingKey.rawValue)
                        }
                    }
                } else {
                    ProgressView()
                }
            } header: {
                HStack {
                    Text(package.name)
                    Spacer()
                    Text(package.version)
                        .monospaced()
                }
                .font(.title)
                .padding()
            }
        }
        .contentMargins(12)
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
