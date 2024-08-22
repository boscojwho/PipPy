//
//  SidebarView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-12.
//

import SwiftUI

struct SidebarView: View {
    @Environment(SidebarPreferences.self) private var sidebarPreferences
    @Environment(ContentSelectionPreferences.self) private var contentSelectionPreferences
    
    var body: some View {
        Group {
            @Bindable var prefs = contentSelectionPreferences
            switch sidebarPreferences.sidebarFilter {
            case .browse:
                PyPIView(selectedFeed: $prefs.selectedFeed)
            case .system:
                PipsView(selectedInstallation: $prefs.selectedPip)
            case .projects:
                ProjectBookmarksView(selectedBookmarks: $prefs.selectedBookmarks)
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
