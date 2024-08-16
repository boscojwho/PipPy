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
            Section {
                ForEach(usr, id: \.self) { value in
                    NavigationLink(value: value) {
                        LabeledContent {
                            HStack {
                                Text(value.lastPathComponent)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        } label: {
                            Image(systemName: "globe")
                                .fontWeight(.light)
                        }
                        .padding(4)
                        .foregroundStyle(.primary)
                    }
                }
            } header: {
                Text("System (Global)")
            }
            Section {
                ForEach(local, id: \.self) { value in
                    NavigationLink(value: value) {
                        LabeledContent {
                            HStack {
                                Text(value.lastPathComponent)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        } label: {
                            Image(systemName: "internaldrive")
                                .fontWeight(.light)
                        }
                        .padding(4)
                        .foregroundStyle(.primary)
                    }
                }
            } header: {
                Text("User (Local)")
            }
            Section {
                ForEach(python, id: \.self) { value in
                    NavigationLink(value: value) {
                        LabeledContent {
                            HStack {
                                Text(value.lastPathComponent)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        } label: {
                            Image(systemName: "gearshape")
                                .fontWeight(.light)
                        }
                        .padding(4)
                        .foregroundStyle(.primary)
                    }
                }
            } header: {
                Text("Python Installations")
            }
        }
        .onAppear {
            let pips = PipFinder.findGlobal()
            usr = pips[0]
            local = pips[1]
            python = Array(Set(pips[2..<pips.endIndex].flatMap { $0 }))
        }
    }
}

#Preview {
    PipsView(selectedInstallation: .constant(nil))
}
