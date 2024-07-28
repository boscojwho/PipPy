//
//  PipView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import SwiftUI

struct PipView: View {
    let path: URL
    @State private var pipClient: PipClient
    init(path: URL) {
        self.path = path
        let curDir = path.deletingLastPathComponent().absoluteString.replacingOccurrences(of: "file://", with: "")
        _pipClient = .init(
            wrappedValue: .init(
                installationPath: path,
                shellClient: .init(currentDirectoryPath: curDir)
            )
        )
    }
        
    var body: some View {
        ScrollView {
            Text(path.absoluteString)
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
    PipView(path: .init(filePath: "usr/bin/pip"))
}
