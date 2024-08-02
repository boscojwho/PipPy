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
    
    /// - Parameter assumesName: If `true`, assumes **venv** directory is conventionally-named (i.e. `.venv`).
    func findVenv(assumesName: Bool = true) -> [URL] {
        assumesName
        ? findVenv_assumingName()
        : findVenv_notAssumingName()
    }
    
    private func findVenv_assumingName() -> [URL] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: projectUrl,
                includingPropertiesForKeys: nil,
                options: []
            )
            let venvs = contents.filter { $0.hasDirectoryPath && $0.lastPathComponent == ".venv" }
            print(#function, venvs)
            return venvs
        } catch {
            print(error)
            return []
        }
    }
    
    private func findVenv_notAssumingName() -> [URL] {
        let findFilename = "pyvenv.cfg"
        do {
            let venvs = try FileManager.default
                .contentsOfDirectory(
                    at: projectUrl,
                    includingPropertiesForKeys: nil,
                    options: []
                )
                .filter { $0.hasDirectoryPath }
                .filter {
                    let contents = try FileManager.default.contentsOfDirectory(
                        at: $0,
                        includingPropertiesForKeys: nil,
                        options: []
                    )
                    let pyvenv_cfg = contents.filter { $0.lastPathComponent == findFilename }
                    return pyvenv_cfg.isEmpty == false
                }
            print(#function, venvs)
            return venvs
        } catch {
            print(error)
            return []
        }
    }
    
    func findPipInstallations(assumesVenvName: Bool = true) -> [URL] {
        let venvs = findVenv(assumesName: assumesVenvName)
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
