//
//  ProjectBookmarkView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-02.
//

import SwiftUI

struct ProjectBookmarkView: View {
    let bookmark: ProjectBookmark
    var body: some View {
        GroupBox {
            Text(bookmark.url.lastPathComponent)
        }
    }
}

#Preview {
    ProjectBookmarkView(bookmark: .mock())
}
