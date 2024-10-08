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
        selectedPackage: Binding<PipListResponse?>
    ) {
        self.pipInstallation = pipInstallation
        _pipClient = .init(
            wrappedValue: .init(
                installationPath: pipInstallation,
                pipExecutable: pipInstallation.lastPathComponent,
                shellClient: .init(currentDirectoryPath: pipInstallation.deletingLastPathComponent().path())
            )
        )
        _selectedPackage = selectedPackage
    }
    
    @State private var packages: [PipListResponse]?
    @State private var filteredPackages: [PipListResponse] = []
    @State private var isSearching = false
    @State private var searchText: String = ""
    
    var body: some View {
        List(selection: $selectedPackage) {
            Section {
                if packages == nil {
                    ProgressView()
                } else {
                    ForEach(listData()) { package in
                        NavigationLink(value: package) {
                            HStack {
                                Text(package.name)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(package.version)
                                    .monospaced()
                            }
                        }
                    }
                }
            } header: {
                GroupBox {
                    Text(pipInstallation.path())
                        .truncationMode(.head)
                        .font(.title3)
                        .lineLimit(nil)
                }
            }
        }
        .padding(.bottom, 60)
        .overlay(alignment: .bottom) {
            if let packages {
                GroupBox {
                    HStack {
                        Spacer()
                        Text("^[\(packages.count) packages](inflected: true) installed")
                        Spacer()
                    }
                }
                .padding()
                .background()
            }
        }
        .task {
            do {
                packages = try await pipClient.list()
            } catch {
                print(error)
            }
        }
        .searchable(text: $searchText, isPresented: $isSearching, prompt: "Filter by package name...")
        .onChange(of: searchText) { _, newValue in
            filteredPackages = packages?.filter { $0.name.contains(newValue) } ?? []
        }
    }
    
    private func listData() -> [PipListResponse] {
        if isSearching, searchText.isEmpty == false, filteredPackages.isEmpty == false {
            return filteredPackages
        } else {
            return packages ?? []
        }
    }
}

#Preview {
    PipView(
        pipInstallation: .init(filePath: "/usr/bin/pip"),
        selectedPackage: .constant(nil)
    )
}
