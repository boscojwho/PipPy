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
    private static let python = "/Library/Frameworks/Python.framework/Versions"
    
    static func findGlobal() -> [[URL]] {
        let pythonPaths = py()
        let paths = [usr, local] + pythonPaths
        return paths.map { findGlobal(in: $0) }
    }
    
    private static func findGlobal(in path: String) -> [URL] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: .init(filePath: path, directoryHint: .isDirectory),
                includingPropertiesForKeys: nil,
                options: []
            )
            let pips = contents.filter {
                $0.lastPathComponent.hasPrefix("pip")
            }
            return pips
        } catch {
            print(error)
            return []
        }
    }
    
    private static func py() -> [String] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: .init(filePath: python, directoryHint: .isDirectory),
                includingPropertiesForKeys: nil,
                options: []
            )
            let dirs = contents.map { $0.appending(path: "bin", directoryHint: .isDirectory).path() }
            return dirs
        } catch {
            print(error)
            return []
        }
    }
}
