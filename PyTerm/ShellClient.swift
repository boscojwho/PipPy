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
    func executeCommand(_ command: String) throws -> Data {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.currentDirectoryPath = currentDirectoryPath
        
        print("\(task.executableURL!.path()) ~> \(task.currentDirectoryPath): \(task.arguments!.joined(separator: " "))")
        
        try task.run()
        
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }
}
