//
//  FindPipGlobal.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import Foundation
import AppKit

struct PipFinder {
    private static let usr = "usr/bin"
    private static let local = "usr/local/bin"
    
    static func findGlobal() -> [[URL]] {
        [usr, local].map { findGlobal(in: $0) }
    }
    
    private static func findGlobal(in path: String) -> [URL] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: .init(filePath: path, directoryHint: .isDirectory), includingPropertiesForKeys: nil, options: [])
            let pips = contents.filter {
                $0.lastPathComponent.hasPrefix("pip")
            }
            return pips
        } catch {
            print(error)
            return []
        }
    }
}
