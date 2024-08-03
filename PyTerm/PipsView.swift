//
//  PipsView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import SwiftUI
import SwiftData

struct PipsView: View {
    @Binding var selectedInstallation: URL?
    @State private var usr: [URL] = []
    @State private var local: [URL] = []
    @State private var python: [URL] = []
    @Query private var projectBookmarks: [ProjectBookmark]
    
    var body: some View {
        List(selection: $selectedInstallation) {
            Section("System (Global)") {
                ForEach(usr, id: \.self) { value in
                    NavigationLink(value: value) {
                        Text(value.lastPathComponent)
                    }
                }
            }
            Section("User (Local)") {
                ForEach(local, id: \.self) { value in
                    NavigationLink(value: value) {
                        Text(value.lastPathComponent)
                    }
                }
            }
            Section("Python Installations") {
                ForEach(python, id: \.self) { value in
                    NavigationLink(value: value) {
                        Text(value.lastPathComponent)
                    }
                }
            }
        }
        .onAppear {
            let pips = PipFinder.findGlobal()
            usr = pips[0]
            local = pips[1]
            python = pips[2..<pips.endIndex].flatMap { $0 }
        }
    }
}

#Preview {
    PipsView(selectedInstallation: .constant(nil))
}
