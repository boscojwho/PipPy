//
//  ContentView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            FileSystemAccessView()
            TerminalView()
        }
    }
}

#Preview {
    ContentView()
}
