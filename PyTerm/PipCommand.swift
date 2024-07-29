//
//  PipCommand.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import Foundation

enum PipCommand: String {
    case install
    case download
    case uninstall
    case freeze
    case inspect
    case list
    case show
    case check
    case config
    case search
    case cache
    case index
    case wheel
    case hash
    case completion
    case debug
    case help
    
    static func generate(_ command: PipCommand, _ pipPath: String) -> String {
        "\(pipPath) \(command.rawValue) --format=json"
    }
}
