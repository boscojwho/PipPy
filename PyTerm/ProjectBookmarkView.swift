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
            LabeledContent {
                HStack {
                    Text(bookmark.url.lastPathComponent)
                        .fontWeight(.medium)
                    Spacer()
                }
            } label: {
                Image(systemName: "chevron.left.slash.chevron.right")
                    .fontWeight(.light)
            }
            .padding(4)
            .foregroundStyle(.primary)
        }
    }
}

#Preview {
    ProjectBookmarkView(bookmark: .mock())
}
