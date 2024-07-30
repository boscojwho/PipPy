//
//  FindVenv.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-29.
//

import Foundation

struct VenvFinder {
    /// The root directory in a Python project.
    /// This is the expected location of the `.venv` directory.
    let projectUrl: URL
    
    func findVenv() -> [URL] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: projectUrl,
                includingPropertiesForKeys: nil,
                options: []
            )
            let venvs = contents.filter { $0.hasDirectoryPath && $0.lastPathComponent == ".venv" }
            print(venvs)
            return venvs
        } catch {
            print(error)
            return []
        }
    }
    
    func findPipInstallations() -> [URL] {
        let venvs = findVenv()
        let bins = venvs.map { $0.appending(path: "bin", directoryHint: .isDirectory) }
        var pips: [URL] = []
        for bin in bins {
            do {
                let contents = try FileManager.default.contentsOfDirectory(
                    at: bin,
                    includingPropertiesForKeys: nil,
                    options: []
                )
                let p = contents.filter { $0.lastPathComponent.hasPrefix("pip") }
                pips.append(contentsOf: p)
            } catch {
                print(error)
            }
        }
       return pips
    }
}
