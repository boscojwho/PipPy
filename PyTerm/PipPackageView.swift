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

extension PipPackage {
    
    struct Author: Identifiable {
        let label: String
        let email: String
        
        var id: String { label }
        
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    }
    
    var authors: [Author] {
        do {
            let authors = try parseAuthorEmails()
#if DEBUG
            print(authors)
#endif
            return authors
        } catch {
            print(error)
            return []
        }
    }
    
    private func parseAuthorEmails() throws -> [Author] {
        try authorEmail.split(separator: ",").map { author in
            let text = String(author)
            let regex = try NSRegularExpression(pattern: Author.emailRegex, options: [])
            let matches = regex.matches(
                in: text,
                options: [],
                range: NSRange(
                    location: 0,
                    length: text.utf16.count
                )
            )
            if let match = matches.first {
                let start = text.index(text.startIndex, offsetBy: match.range.location)
                let end = text.index(start, offsetBy: match.range.length)
                let email = text[start..<end]
                return Author(label: text, email: String(email))
            } else {
                return Author(label: text, email: "")
            }
        }
    }
}

@MainActor
extension PipPackage {
    @ViewBuilder
    func makeView(codingKey: CodingKeys) -> some View {
        Group {
            let labelText = "\(self[keyPath: codingKey.keyPath])"
            switch codingKey {
            case .summary:
                GroupBox {
                    Text(labelText)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 4)
            case .homepage:
                if let string = self[keyPath: codingKey.keyPath] as? String,
                   let url = URL(string: string) {
                    Link(labelText, destination: url)
                } else {
                    Text(labelText)
                }
            case .authorEmail:
                VStack {
                    ForEach(authors) { author in
                        HStack {
                            Spacer()
                            Text("\(author.label)")
                                .foregroundStyle(.link)
                                .onTapGesture {
                                    let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                                    service?.recipients = [author.email]
                                    service?.subject = "\(name) [\(version)]"
                                    service?.perform(withItems: [""])
                                }
                        }
                    }
                }
            case .location:
                let filePath = URL(filePath: labelText)
                /// Pip package directories and package names don't necessarily always match (e.g.`charset_normalizer`).
                /// `Package.location` only returns path to parent directory containing the package.
//                    .appending(path: self.name)
                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([filePath])
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "arrowshape.forward.circle")
                        Text(labelText)
                    }
                }
                .buttonStyle(.plain)
            default:
                Text(labelText)
            }
        }
        .multilineTextAlignment(.trailing)
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
                        if codingKey == .name || codingKey == .version {
                            EmptyView()
                        } else if codingKey == .summary {
                            packageInfo.makeView(codingKey: codingKey)
                        } else {
                            LabeledContent {
                                HStack {
                                    Spacer()
                                    packageInfo.makeView(codingKey: codingKey)
                                }
                            } label: {
                                Text(codingKey.rawValue)
                            }
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
