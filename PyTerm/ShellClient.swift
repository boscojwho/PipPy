//
//  ShellClient.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import Foundation

actor ShellClient {
    var currentDirectoryPath: String
    init(currentDirectoryPath: String) {
        self.currentDirectoryPath = currentDirectoryPath
    }
    
    @discardableResult
    func executeCommand(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.currentDirectoryPath = currentDirectoryPath
        
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(decoding: data, as: UTF8.self)
    }
}
