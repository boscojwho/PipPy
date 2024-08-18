//
//  PyPIFeedView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-17.
//

import SwiftUI
import FeedKit

extension RSSFeedItem: Identifiable {}

struct PyPIFeedView: View {
    let feedURL: URL
    @State private var feed: RSSFeed?
    var body: some View {
        List {
            if let items = feed?.items {
                ForEach(items) { item in
                    GroupBox {
                        Text(item.title ?? "")
                        Text(item.link ?? "")
                        Text(item.description ?? "")
                        Text(item.author ?? "")
                    }
                }
            } else {
                ProgressView()
            }
        }
        .task(id: feedURL) {
            await parseFeed()
        }
    }
    
    nonisolated private func parseFeed() async {
        let parser = FeedParser(URL: feedURL)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            self.feed = feed.rssFeed
        case .failure(let error):
            print(error)
        }
    }
}
