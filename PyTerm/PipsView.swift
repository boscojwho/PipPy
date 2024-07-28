//
//  PipsView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-07-28.
//

import SwiftUI

struct PipsView: View {
    @State private var usr: [URL] = []
    @State private var local: [URL] = []
    var body: some View {
        ScrollView {
            VStack {
                ForEach(usr, id: \.self) { value in
                    NavigationLink(value: value) {
                        Text(value.lastPathComponent)
                    }
                }
                Divider()
                ForEach(local, id: \.self) { value in
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
        }
    }
}

#Preview {
    PipsView()
}
