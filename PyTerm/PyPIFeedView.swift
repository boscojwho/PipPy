//
//  PyPIFeedView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-17.
//

import SwiftUI
import FeedKit

extension RSSFeedItem: Identifiable, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(guid?.value ?? "")
        hasher.combine(title ?? "")
        hasher.combine(description ?? "")
        hasher.combine(author ?? "")
        hasher.combine(link ?? "")
        hasher.combine(pubDate ?? nil)
    }
}

@Observable
final class PyPIFeedViewModel {
    var feed: RSSFeed?
}

struct PyPIFeedView: View {
    
    let feedURL: URL
    let feedType: PyPIFeed
    
    @State private var viewModel: PyPIFeedViewModel
    
    init(feedURL: URL, feedType: PyPIFeed) {
        /// BUG: Whenever parameters change, SwiftUI evaluates grid's content closure first, then runs the .task(id:) modifier, causing the view to render incorrect content between animations. [2024.08]
        _viewModel = .init(wrappedValue: .init())
        self.feedURL = feedURL
        self.feedType = feedType
    }
    
    @Namespace private var feedNamespace

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 240))],
                alignment: .center,
                spacing: 12,
                pinnedViews: []
            ) {
                Group {
                    if let items = viewModel.feed?.items {
                        ForEach(Array(items.enumerated()), id: \.element.hashValue) {
                            offset,
                            item in
                            itemView(item, offset: offset)
                                .matchedGeometryEffect(
                                    id: offset,
                                    in: feedNamespace,
                                    properties: .position
                                )
                        }
                    } else {
                        ForEach(0..<30) { offset in
                            GroupBox {
                                HStack(alignment: .top) {
                                    VStack {
                                        Text("Description")
                                        Text("Link")
                                        Text("Author")
                                        Text("Published Date")
                                    }
                                    Spacer()
                                }
                                .padding(4)
                            } label: {
                                Text("Package")
                            }
                            .padding(6)
                            .redacted(reason: .placeholder)
                            .matchedGeometryEffect(
                                id: offset,
                                in: feedNamespace,
                                properties: .position
                            )
                        }
                    }
                }
            }
        }
        /// Animation modifier needs to be here. Applying it to Grid or child views causes weird animation artifacts or no animations at all. [2024.08]
        .animation(.default, value: viewModel.feed)
        .contentMargins(12, for: .scrollContent)
        .task(id: feedURL) {
            self.viewModel.feed = nil
            self.viewModel.feed = await parseFeed()
        }
    }

    private func itemView(_ item: RSSFeedItem, offset: Int) -> some View {
        GroupBox {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    if let description = item.description {
                        Label(description, systemImage: "text.justifyleft")
                            .lineLimit(nil)
                    }
                    if let link = item.link {
                        Link(destination: URL(string: link)!) {
                            Label(link, systemImage: "link")
                                .truncationMode(.head)
                        }
                    }
                    if let author = item.author {
                        Label(author, systemImage: "person")
                    }
                    Spacer()
                    
                    if let date = item.pubDate?.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated)) {
                        HStack {
                            Spacer()
                            Label(date, systemImage: "calendar")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .monospaced()
                        }
                    }
                }
                .font(.body)

                Spacer()
            }
            .padding(4)
            .frame(height: 144)
            .fixedSize(horizontal: false, vertical: true)
        } label: {
            Text(itemTitle(item))
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(6)
        .textSelection(.enabled)
    }
    
    private func itemTitle(_ item: RSSFeedItem) -> String {
        switch feedType {
        case .newestPackages:
            if let title = item.title {
                let packageName = title.split(separator: " ", maxSplits: 1).first
                return String(packageName ?? "")
            } else {
                return ""
            }
        case .latestUpdates:
            return item.title ?? ""
        }
    }
    
    nonisolated private func parseFeed() async -> RSSFeed? {
        let parser = FeedParser(URL: feedURL)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            return feed.rssFeed
        case .failure(let error):
            print(error)
            return nil
        }
    }
}
