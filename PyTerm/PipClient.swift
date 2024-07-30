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

extension PipListResponse {
    static func mock() -> PipListResponse {
        .init(name: "pip", version: "1.0.0", editableProjectLocation: nil)
    }
}

@Observable
final class PipClient {
    let installationPath: URL
    let isProjectInstallation: Bool
    let pipExecutable: String?
    private var shellClient: ShellClient
    init(
        installationPath: URL,
        isProjectInstallation: Bool,
        pipExecutable: String?,
        shellClient: ShellClient
    ) {
        self.installationPath = installationPath
        self.isProjectInstallation = isProjectInstallation
        self.pipExecutable = pipExecutable
        self.shellClient = shellClient
    }
    
    private var pipName: String {
        pipExecutable ?? "pip"
    }
    
    var shellOutput: String = ""
    
    func list() async throws -> [PipListResponse] {
        let responseData = try await shellClient.executeCommand(
            PipCommand.generate(
                .list,
                arguments: ["--format=json"],
                installationPath.path()
            )
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
    
    func show(_ packageName: String) async throws -> String {
        let responseData = try await shellClient.executeCommand(
            PipCommand.generate(
                .show,
                arguments: [packageName],
                installationPath.path()
            )
        )
        let output = String(decoding: responseData, as: UTF8.self)
        shellOutput = output
        return output
    }
}
