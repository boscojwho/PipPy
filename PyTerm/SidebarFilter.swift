//
//  SidebarFilter.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-12.
//

import Foundation

enum SidebarFilter: Int, Identifiable, CaseIterable, CustomStringConvertible {
    case browse
    case system
    case projects
    
    var id: Int { rawValue }
    var description: String {
        switch self {
        case .browse:
            "Browse"
        case .system:
            "System"
        case .projects:
            "Projects"
        }
    }
}
