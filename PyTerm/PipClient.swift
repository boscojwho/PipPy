//
//  PipClient.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import Foundation

struct PipListResponse: Codable, Hashable, Identifiable {
    let name: String
    let version: String
    let editableProjectLocation: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case version
        case editableProjectLocation = "editable_project_location"
    }
    
    var id: String { name }
}

@Observable
final class PipClient {
    let installationPath: URL
    private var shellClient: ShellClient
    init(installationPath: URL, shellClient: ShellClient) {
        self.installationPath = installationPath
        self.shellClient = shellClient
    }
    
    var shellOutput: String = ""
    
    func list() async throws -> [PipListResponse] {
        let responseData = try await shellClient.executeCommand(
            PipCommand.generate(.list, installationPath.path())
        )
        let output = String(decoding: responseData, as: UTF8.self)
        shellOutput = output
        
        if let json = output.split(separator: "\n").first, let jsonData = json.data(using: .utf8) {
            let jsonDecoder = JSONDecoder()            
            let response = try jsonDecoder.decode([PipListResponse].self, from: jsonData)
            return response
        } else {
            return []
        }
    }
}
