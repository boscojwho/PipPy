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
    @Binding var selectedPackage: String?
    init(pipInstallation: URL, selectedPackage: Binding<String?>) {
        self.pipInstallation = pipInstallation
        _pipClient = .init(
            wrappedValue: .init(
                installationPath: pipInstallation,
                shellClient: .init(currentDirectoryPath: pipInstallation.deletingLastPathComponent().path())
            )
        )
        _selectedPackage = selectedPackage
    }
    
    var body: some View {
        ScrollView {
            Text(pipInstallation.absoluteString)
                .onTapGesture {
                    selectedPackage = pipInstallation.lastPathComponent
                }
            VStack {
                if pipClient.shellOutput.isEmpty {
                    ProgressView()
                } else {
                    Text(pipClient.shellOutput)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(Color.black)
                        .foregroundColor(.green)
                }
            }
        }
        .task {
            await pipClient.list()
        }
    }
}

#Preview {
    PipView(
        pipInstallation: .init(filePath: "/usr/bin/pip"),
        selectedPackage: .constant(nil)
    )
}
