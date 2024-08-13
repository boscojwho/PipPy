//
//  SidebarView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-12.
//

import SwiftUI

struct SidebarView: View {
    @Binding var filter: SidebarFilter
    @Binding var selectedPip: URL?
    @Binding var selectedBookmarks: Set<ProjectBookmark>
    
    var body: some View {
        Group {
            switch filter {
            case .system:
                PipsView(selectedInstallation: $selectedPip)
            case .projects:
                ProjectBookmarksView(selectedBookmarks: $selectedBookmarks)
            }
        }
        .listStyle(.sidebar)
        .overlay(alignment: .bottom) {
            sidebarFilterPicker
        }
        .navigationSplitViewColumnWidth(min: 240, ideal: 280)
    }
    
    private var sidebarFilterPicker: some View {
        Picker("", selection: $filter) {
            ForEach(SidebarFilter.allCases) { filter in
                Text(filter.description)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background()
    }
}
