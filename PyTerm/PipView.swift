//
//  PipView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import SwiftUI

struct PipView: View {
    @StateObject private var terminal: TerminalInterface = .init()
    let path: URL
    var body: some View {
        ScrollView {
            Text(path.absoluteString)
            VStack {
                Text(terminal.output)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color.black)
                    .foregroundColor(.green)
            }
        }
        .onAppear {
            let curDir = path.deletingLastPathComponent().absoluteString.replacingOccurrences(of: "file://", with: "")
            terminal.currentDirectory = curDir
            let command = "\(path.absoluteString.replacingOccurrences(of: "file://", with: "")) list"
            terminal.executeCommand(command)
        }
        .onChange(of: terminal.output, perform: { value in
            
        })
    }
}

#Preview {
    PipView(path: .init(filePath: "usr/bin/pip"))
}
