//
//  PyPISavedItemsView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-22.
//

import SwiftUI
import SwiftData

struct PyPISavedItemsView: View {
    @Query private var items: [PyPIFeedItem] = []
    var body: some View {
        List(items) { item in
            Text(item.title ?? "")
        }
    }
}
