//
//  ContentView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            PipsView()
                .navigationDestination(for: URL.self) { value in
                    PipView(pipInstallation: value)
                        .id(value.hashValue)
                }
        } detail: {
            Text("Select an installation")
        }
    }
}

#Preview {
    ContentView()
}
