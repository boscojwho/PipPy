//
//  PipView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import SwiftUI

struct PipView: View {
    let pipInstallation: URL
    init(pipInstallation: URL) {
        self.pipInstallation = pipInstallation
        _pipClient = .init(
            wrappedValue: .init(
                installationPath: pipInstallation,
                shellClient: .init(currentDirectoryPath: pipInstallation.path())
            )
        )
    }
        
    @State private var pipClient: PipClient
    
    var body: some View {
        ScrollView {
            Text(pipInstallation.absoluteString)
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
    PipView(pipInstallation: .init(filePath: "/usr/bin/pip"))
}
