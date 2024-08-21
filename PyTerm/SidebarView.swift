//
//  SidebarView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-12.
//

import SwiftUI

struct SidebarView: View {
    @Environment(SidebarPreferences.self) private var sidebarPreferences
    @Binding var selectedFeed: PyPIFeed
    @Binding var selectedPip: URL?
    @Binding var selectedBookmarks: Set<ProjectBookmark>
    
    var body: some View {
        Group {
            switch sidebarPreferences.sidebarFilter {
            case .browse:
                PyPIView(selectedFeed: $selectedFeed)
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
    
    @ViewBuilder
    private var sidebarFilterPicker: some View {
        @Bindable var sidebarPreferences = sidebarPreferences
        Picker("", selection: $sidebarPreferences.sidebarFilter) {
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
