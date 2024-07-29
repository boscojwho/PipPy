//
//  FileSystemAccess.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-26.
//

import SwiftUI
import UniformTypeIdentifiers

class FileSystemAccess: ObservableObject {
    @Published var selectedURL: URL?
    @Published var canAccessURL: Bool = false
    
    func selectDirectory(initialUrl: URL? = nil, selection: Binding<URL?> = .constant(nil)) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if let initialUrl {
            panel.directoryURL = initialUrl
        }
        
        if panel.runModal() == .OK {
            self.selectedURL = panel.url
            self.canAccessURL = panel.url?.startAccessingSecurityScopedResource() ?? false
            selection.wrappedValue = panel.url
        }
    }
    
    func releaseAccess() {
        selectedURL?.stopAccessingSecurityScopedResource()
        canAccessURL = false
    }
}

struct FileSystemAccessView: View {
    @StateObject private var fileAccess = FileSystemAccess()
    
    var body: some View {
        VStack {
            Button("Select Directory") {
                fileAccess.selectDirectory()
            }
            
            if let url = fileAccess.selectedURL {
                Text("Selected: \(url.path)")
                if fileAccess.canAccessURL {
                    Text("Access granted")
                        .foregroundColor(.green)
                } else {
                    Text("No access")
                        .foregroundColor(.red)
                }
            }
        }
    }
}
