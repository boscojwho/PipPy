//
//  ProjectBookmark.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-02.
//

import Foundation
import SwiftData

@Model
final class ProjectBookmark: Hashable {
    let url: URL
    init(url: URL) {
        self.url = url
    }
}

extension ProjectBookmark {
    static func mock() -> Self {
        .init(url: .init(filePath: "example_python_project"))
    }
}
