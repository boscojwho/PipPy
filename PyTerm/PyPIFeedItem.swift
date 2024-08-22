//
//  PyPIFeedItem.swift
//  PyTerm
//
//  Created by Bosco Ho on 2024-08-21.
//

import Foundation
import SwiftData

@Model
final class PyPIFeedItem {
    let title: String?
    @Attribute(originalName: "description")
    let desc: String?
    let author: String?
    let link: String?
    let guid: String?
    let pubDate: Date?
    
    init(
        title: String?,
        desc: String?,
        author: String?,
        link: String?,
        guid: String?,
        pubDate: Date?
    ) {
        self.title = title
        self.desc = desc
        self.author = author
        self.link = link
        self.guid = guid
        self.pubDate = pubDate
    }
}

import FeedKit
extension PyPIFeedItem {
    convenience init(_ item: RSSFeedItem) {
        self.init(
            title: String(
                item.title?.split(separator: " ", maxSplits: 1).first
                ?? ""
            ),
            desc: item.description,
            author: item.author,
            link: item.link,
            guid: item.guid?.value,
            pubDate: item.pubDate
        )
    }
    
    func rssFeedItem() -> RSSFeedItem {
        let item = RSSFeedItem()
        item.title = title
        item.description = desc
        item.author = author
        item.link = link
        item.guid = {
            let guid = RSSFeedItemGUID()
            guid.value = self.guid
            return guid
        }()
        item.pubDate = pubDate
        return item
    }
}
