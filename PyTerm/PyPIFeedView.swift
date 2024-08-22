//
//  PyPIFeedView.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-17.
//

import SwiftUI
import SwiftData
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
    init(feed: RSSFeed? = nil) {
        self.feed = feed
    }
}

struct PyPIFeedView: View {
    @Environment(\.modelContext) private var viewContext
    let feedURL: URL
    let feedType: PyPIFeed
    
    @State private var viewModel: PyPIFeedViewModel
    @Query var savedItems: [PyPIFeedItem]
    
    @State private var confirmUnsave = false
    @State private var unsaveItem: RSSFeedItem?
    
    init(
        feedURL: URL,
        feedType: PyPIFeed
    ) {
        self.feedURL = feedURL
        self.feedType = feedType
        _viewModel = .init(wrappedValue: .init())
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
                        if items.isEmpty {
                            GroupBox {
                                ContentUnavailableView(
                                    "Saved Packages",
                                    systemImage: "star",
                                    description: Text("Packages saved in Newest/Latest appear here.")
                                )
                            }
                        } else {
                            ForEach(Array(items.enumerated()), id: \.element.hashValue) {
                                offset,
                                item in
                                itemView(item, offset: offset)
                            }
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
                        }
                    }
                }
            }
        }
        /// Animation modifier needs to be here. Applying it to Grid or child views causes weird animation artifacts or no animations at all. [2024.08]
        .animation(.default, value: viewModel.feed)
        .contentMargins(12, for: .scrollContent)
        .task(id: feedURL) {
            /// Use SwiftData query for `.savedPackages`.
            guard feedType != .savedPackages else {
                self.viewModel.feed = {
                    let feed = RSSFeed()
                    feed.items = savedItems.map { $0.rssFeedItem() }
                    return feed
                }()
                return
            }
            self.viewModel.feed = nil
            self.viewModel.feed = await parseFeed()
        }
        /// We need to monitor `@Query var savedItems` to trigger view updates because we don't use it directly in the view body.
        .onChange(of: savedItems.count, initial: true) {
            guard feedType == .savedPackages else {
                return
            }
            self.viewModel.feed = {
                let feed = RSSFeed()
                feed.items = savedItems.map { $0.rssFeedItem() }
                return feed
            }()
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
                            let saved = isSaved(item)
                            Button("", systemImage: saved ? "star.fill" : "star") {
                                if saved {
                                    confirmUnsave = true
                                    unsaveItem = item
                                } else {
                                    let item = PyPIFeedItem(item)
                                    viewContext.insert(item)
                                    if viewContext.hasChanges {
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            }
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
        .transition(
            .asymmetric(
                insertion: .push(from: .top).combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            )
        )
        .textSelection(.enabled)
        .alert(
            "Are you sure?",
            isPresented: $confirmUnsave,
            presenting: unsaveItem
        ) { item in
            Button("Remove", systemImage: "star.slash", role: .destructive) {
                do {
                    let matches = try viewContext.fetch(feedItemFetchDescriptor(item))
                    for match in matches {
                        viewContext.delete(match)
                    }
                    if viewContext.hasChanges {
                        try viewContext.save()
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private func feedItemFetchDescriptor(_ item: RSSFeedItem) -> FetchDescriptor<PyPIFeedItem> {
        /// Can't directly capture `item` inside predicate, otherwise Swift macro error.
//        let rhs = String(item.title?.split(separator: " ", maxSplits: 1).first ?? "")
        let rhs = item.title ?? ""
        let descriptor = FetchDescriptor<PyPIFeedItem>(
            predicate: #Predicate { $0.title == rhs }
        )
        return descriptor
    }
    
    private func isSaved(_ item: RSSFeedItem) -> Bool {
        let descriptor = feedItemFetchDescriptor(item)
        do {
            let count = try viewContext.fetchCount(descriptor)
            return count != 0
        } catch {
            return false
        }
    }
    
    private func itemTitle(_ item: RSSFeedItem) -> String {
        switch feedType {
        case .newestPackages, .savedPackages:
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
