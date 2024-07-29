//
//  PipClient.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import Foundation

@Observable
final class PipClient {
    let installationPath: URL
    private var shellClient: ShellClient
    init(installationPath: URL, shellClient: ShellClient) {
        self.installationPath = installationPath
        self.shellClient = shellClient
    }
    
    var shellOutput: String = ""
    
    func list() async {
        let pipCommand = PipCommand.generate(.list, installationPath.path())
        shellOutput = try! await shellClient.executeCommand(pipCommand)
    }
}
