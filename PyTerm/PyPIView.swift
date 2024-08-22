//
//  PyPIView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-17.
//

import SwiftUI

enum PyPIFeed: Int, Identifiable, CustomStringConvertible {
    case newestPackages
    case latestUpdates
    case savedPackages
    
    var id: Int { rawValue }
    var description: String {
        switch self {
        case .newestPackages:
            "Newest Packages"
        case .latestUpdates:
            "Latest Updates"
        case .savedPackages:
            "Saved Packages"
        }
    }
    var url: URL {
        switch self {
        case .newestPackages:
            URL(string: "https://pypi.org/rss/packages.xml")!
        case .latestUpdates:
            URL(string: "https://pypi.org/rss/updates.xml")!
        case .savedPackages:
            URL(fileURLWithPath: "")
        }
    }
}

struct PyPIView: View {
    @Binding var selectedFeed: PyPIFeed
    var body: some View {
        List(selection: $selectedFeed) {
            Section("Browse") {
                NavigationLink(value: PyPIFeed.newestPackages) {
                    Label("Newest Packages", systemImage: "fireworks")
                }
                NavigationLink(value: PyPIFeed.latestUpdates) {
                    Label("Latest Updates", systemImage: "wand.and.stars")
                }
            }
            Section("Collections") {
                NavigationLink(value: PyPIFeed.savedPackages) {
                    Label("Saved Packages", systemImage: "star")
                }
            }
        }
    }
}
