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
                    PipView(path: value)
                        .id(value.hashValue)
                }
        } detail: {
            Text("Select an installation")
        }

//        VStack {
//            Picker("Pick an option", selection: .constant(0)) {
//                Section {
//                    Text("Option 1").tag(0)
//                } header: {
//                    Text("System")
//                }
//                Divider().padding(.leading)
//                Section {
//                    Text("Option 2").tag(1)
//                    Text("Option 3").tag(2)
//                } header: {
//                    Text("User")
//                }
//       
//            }
//            PipsView()
//            FileSystemAccessView()
//            TerminalView()
//        }
    }
}

#Preview {
    ContentView()
}
