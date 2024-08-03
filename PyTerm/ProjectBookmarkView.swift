//
//  ProjectBookmarkView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-02.
//

import SwiftUI

struct ProjectBookmarkView: View {
    @Environment(\.modelContext) private var modelContext
    let bookmark: ProjectBookmark
    var body: some View {
        NavigationLink(value: bookmark) {
            Text(bookmark.url.lastPathComponent)
        }
    }
}

#Preview {
    ProjectBookmarkView(bookmark: .mock())
}
