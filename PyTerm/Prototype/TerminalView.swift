//
//  TerminalView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI

class TerminalInterface: ObservableObject {
    @MainActor
    @Published var output: String = ""
    @Published var currentDirectory: String = FileManager.default.currentDirectoryPath
    
    private var process: Process?
    
    @discardableResult
    func executeCommand(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.currentDirectoryPath = currentDirectory
        
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: data, as: UTF8.self)
        DispatchQueue.main.async {
            self.output = output
        }
        return output
    }
    
    func changeDirectory(_ path: String) {
        let fullPath: String
        if path.starts(with: "/") {
            fullPath = path
        } else {
            fullPath = (currentDirectory as NSString).appendingPathComponent(path)
        }
        
        if FileManager.default.changeCurrentDirectoryPath(fullPath) {
            DispatchQueue.main.async {
                self.currentDirectory = fullPath
                self.output = "Changed directory to: \(fullPath)"
            }
        } else {
            DispatchQueue.main.async {
                self.output = "Failed to change directory to: \(fullPath)"
            }
        }
    }
}

struct TerminalView: View {
    @StateObject private var terminal = TerminalInterface()
    @State private var command: String = ""
    @State private var newDirectory: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter command", text: $command)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Execute") {
                try! terminal.executeCommand(command)
            }
            
            TextField("Change directory", text: $newDirectory)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Change Directory") {
                terminal.changeDirectory(newDirectory)
            }
            
            Text("Current Directory: \(terminal.currentDirectory)")
                .padding()
            
            ScrollView {
                Text(terminal.output)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color.black)
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}
