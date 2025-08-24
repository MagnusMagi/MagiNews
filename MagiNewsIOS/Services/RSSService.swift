//
//  RSSService.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import Combine

// MARK: - RSS Feed Sources
enum RSSFeedSource: String, CaseIterable {
    case errEe = "ERR.ee"
    case postimeesEe = "Postimees.ee"
    case delfiEe = "Delfi.ee"
    case lsmLv = "LSM.lv"
    case lrtLt = "LRT.lt"
    case yleFi = "Yle.fi"
    
    var url: String {
        switch self {
        case .errEe:
            return "https://news.err.ee/rss"
        case .postimeesEe:
            return "https://news.postimees.ee/rss"
        case .delfiEe:
            return "https://www.delfi.ee/rss"
        case .lsmLv:
            return "https://www.lsm.lv/rss/"
        case .lrtLt:
            return "https://www.lrt.lt/static/rss/eng.rss"
        case .yleFi:
            return "https://yle.fi/uutiset/osasto/news/rss"
        }
    }
    
    var region: String {
        switch self {
        case .errEe, .postimeesEe, .delfiEe:
            return "Estonia"
        case .lsmLv:
            return "Latvia"
        case .lrtLt:
            return "Lithuania"
        case .yleFi:
            return "Finland"
        }
    }
    
    var language: String {
        switch self {
        case .errEe, .postimeesEe, .delfiEe:
            return "Estonian"
        case .lsmLv:
            return "Latvian"
        case .lrtLt:
            return "Lithuanian"
        case .yleFi:
            return "Finnish"
        }
    }
}

// MARK: - RSS Feed Models
struct RSSFeed: Codable, Identifiable {
    let id = UUID()
    let title: String
    let link: String
    let description: String
    let language: String
    let lastBuildDate: String
    let items: [RSSItem]
    
    enum CodingKeys: String, CodingKey {
        case title, link, description, language
        case lastBuildDate = "lastBuildDate"
        case items = "item"
    }
}

struct RSSItem: Codable, Identifiable, Hashable {
    let id: String // Using link as stable identifier
    let title: String
    let link: String
    let description: String
    let pubDate: String
    let category: String?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case title, link, description, pubDate, category
        case imageURL = "enclosure"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Clean CDATA and HTML entities from RSS content
        let rawTitle = try container.decode(String.self, forKey: .title)
        title = rawTitle.cleanedRSSContent
        
        link = try container.decode(String.self, forKey: .link)
        self.id = link // Set ID to link for stable identity
        
        let rawDescription = try container.decode(String.self, forKey: .description)
        description = rawDescription.cleanedRSSContent
        
        pubDate = try container.decode(String.self, forKey: .pubDate)
        
        if let rawCategory = try container.decodeIfPresent(String.self, forKey: .category) {
            category = rawCategory.cleanedRSSContent
        } else {
            category = nil
        }
        
        // Handle image URL from enclosure
        if let enclosure = try container.decodeIfPresent(Enclosure.self, forKey: .imageURL) {
            imageURL = enclosure.url
        } else {
            imageURL = nil
        }
    }
    
    // Manual initializer for creating RSSItem instances
    init(title: String, link: String, description: String, pubDate: String, category: String?, imageURL: String?) {
        self.id = link // Set ID to link for stable identity
        self.title = title
        self.link = link
        self.description = description
        self.pubDate = pubDate
        self.category = category
        self.imageURL = imageURL
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(link)
    }
    
    static func == (lhs: RSSItem, rhs: RSSItem) -> Bool {
        lhs.link == rhs.link
    }
}

struct Enclosure: Codable {
    let url: String
    let type: String
    let length: String?
}

// MARK: - RSS Service
class RSSService: ObservableObject {
    @Published var feeds: [RSSFeed] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchAllFeeds() {
        isLoading = true
        errorMessage = nil
        
        let feedPublishers = RSSFeedSource.allCases.map { source in
            fetchFeed(from: source)
        }
        
        Publishers.MergeMany(feedPublishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] feeds in
                    self?.feeds = feeds.compactMap { $0 }
                }
            )
            .store(in: &cancellables)
    }
    
    private func fetchFeed(from source: RSSFeedSource) -> AnyPublisher<RSSFeed?, Error> {
        // First try direct RSS parsing, fallback to RSS2JSON proxy
        return fetchDirectRSS(from: source)
            .catch { _ in
                self.fetchViaProxy(from: source)
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchDirectRSS(from source: RSSFeedSource) -> AnyPublisher<RSSFeed?, Error> {
        guard let url = URL(string: source.url) else {
            return Fail(error: RSSError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                try self.parseRSSFeed(from: data, source: source)
            }
            .catch { error -> AnyPublisher<RSSFeed?, Error> in
                print("Direct RSS failed for \(source.url): \(error)")
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchViaProxy(from source: RSSFeedSource) -> AnyPublisher<RSSFeed?, Error> {
        let encodedURL = source.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let proxyURL = "https://api.rss2json.com/v1/api.json?rss_url=\(encodedURL)"
        
        guard let url = URL(string: proxyURL) else {
            return Fail(error: RSSError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data in
                try self.parseProxyResponse(from: data, source: source)
            }
            .catch { error -> AnyPublisher<RSSFeed?, Error> in
                print("Proxy RSS failed for \(source.url): \(error)")
                return Just(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchFeed(from source: RSSFeedSource) async throws -> RSSFeed? {
        guard let url = URL(string: source.url) else {
            throw RSSError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try parseRSSFeed(from: data, source: source)
    }
    
    // MARK: - RSS Parsing
    private func parseRSSFeed(from data: Data, source: RSSFeedSource) throws -> RSSFeed {
        let xmlString = String(data: data, encoding: .utf8) ?? ""
        
        // Simple XML parsing for RSS feeds
        let title = extractValue(from: xmlString, tag: "title")
        let link = extractValue(from: xmlString, tag: "link")
        let description = extractValue(from: xmlString, tag: "description")
        let language = extractOptionalValue(from: xmlString, tag: "language") ?? "en"
        let lastBuildDate = extractOptionalValue(from: xmlString, tag: "lastBuildDate") ?? ""
        
        let items = parseRSSItems(from: xmlString)
        
        return RSSFeed(
            title: title,
            link: link,
            description: description,
            language: language,
            lastBuildDate: lastBuildDate,
            items: items
        )
    }
    
    private func parseRSSItems(from xmlString: String) -> [RSSItem] {
        var items: [RSSItem] = []
        let itemPattern = "<item>(.*?)</item>"
        let regex = try? NSRegularExpression(pattern: itemPattern, options: [.dotMatchesLineSeparators])
        
        let matches = regex?.matches(in: xmlString, options: [], range: NSRange(xmlString.startIndex..., in: xmlString)) ?? []
        
        for match in matches {
            if let range = Range(match.range, in: xmlString) {
                let itemString = String(xmlString[range])
                if let item = parseRSSItem(from: itemString) {
                    items.append(item)
                }
            }
        }
        
        return items
    }
    
    private func parseRSSItem(from itemString: String) -> RSSItem? {
        let title = extractValue(from: itemString, tag: "title")
        let link = extractValue(from: itemString, tag: "link")
        let description = extractValue(from: itemString, tag: "description")
        let pubDate = extractValue(from: itemString, tag: "pubDate")
        let category = extractValue(from: itemString, tag: "category")
        
        // Extract image URL from enclosure
        let imageURL = extractEnclosureURL(from: itemString)
        
        return RSSItem(
            title: title,
            link: link,
            description: description,
            pubDate: pubDate,
            category: category,
            imageURL: imageURL
        )
    }
    
    private func extractValue(from xmlString: String, tag: String) -> String {
        let pattern = "<\(tag)>(.*?)</\(tag)>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        
        if let match = regex?.firstMatch(in: xmlString, options: [], range: NSRange(xmlString.startIndex..., in: xmlString)),
           let range = Range(match.range(at: 1), in: xmlString) {
            return String(xmlString[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return ""
    }
    
    private func extractOptionalValue(from xmlString: String, tag: String) -> String? {
        let pattern = "<\(tag)>(.*?)</\(tag)>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        
        if let match = regex?.firstMatch(in: xmlString, options: [], range: NSRange(xmlString.startIndex..., in: xmlString)),
           let range = Range(match.range(at: 1), in: xmlString) {
            let value = String(xmlString[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? nil : value
        }
        
        return nil
    }
    
    private func extractEnclosureURL(from itemString: String) -> String? {
        let pattern = "<enclosure url=\"(.*?)\""
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let match = regex?.firstMatch(in: itemString, options: [], range: NSRange(itemString.startIndex..., in: itemString)),
           let range = Range(match.range(at: 1), in: itemString) {
            return String(itemString[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
    
    // MARK: - RSS2JSON Proxy Response Parser
    private func parseProxyResponse(from data: Data, source: RSSFeedSource) throws -> RSSFeed {
        let decoder = JSONDecoder()
        let proxyResponse = try decoder.decode(RSS2JSONResponse.self, from: data)
        
        guard proxyResponse.status == "ok" else {
            throw RSSError.parsingError
        }
        
        let items = proxyResponse.items.map { item in
            RSSItem(
                title: item.title,
                link: item.link,
                description: item.description,
                pubDate: item.pubDate,
                category: item.categories.first,
                imageURL: item.enclosure?.link
            )
        }
        
        return RSSFeed(
            title: proxyResponse.feed.title,
            link: proxyResponse.feed.url,
            description: proxyResponse.feed.description,
            language: source.language,
            lastBuildDate: "",
            items: items
        )
    }
}

// MARK: - RSS2JSON Response Models
struct RSS2JSONResponse: Codable {
    let status: String
    let feed: RSS2JSONFeed
    let items: [RSS2JSONItem]
}

struct RSS2JSONFeed: Codable {
    let url: String
    let title: String
    let link: String
    let author: String
    let description: String
    let image: String
}

struct RSS2JSONItem: Codable {
    let title: String
    let pubDate: String
    let link: String
    let guid: String
    let author: String
    let thumbnail: String
    let description: String
    let content: String
    let enclosure: RSS2JSONEnclosure?
    let categories: [String]
}

struct RSS2JSONEnclosure: Codable {
    let link: String
    let type: String
    let length: String?
}

// MARK: - RSS Errors
enum RSSError: LocalizedError {
    case invalidURL
    case parsingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid RSS feed URL"
        case .parsingError:
            return "Error parsing RSS feed"
        case .networkError:
            return "Network error while fetching RSS feed"
        }
    }
}

// MARK: - Feed Categories
enum FeedCategory: String, CaseIterable {
    case politics = "Politics"
    case economy = "Economy"
    case culture = "Culture"
    case technology = "Technology"
    case sports = "Sports"
    case general = "General"
    
    var icon: String {
        switch self {
        case .politics:
            return "building.2"
        case .economy:
            return "chart.line.uptrend.xyaxis"
        case .culture:
            return "theatermasks"
        case .technology:
            return "laptopcomputer"
        case .sports:
            return "sportscourt"
        case .general:
            return "newspaper"
        }
    }
    
    var color: String {
        switch self {
        case .politics:
            return "#FF6B6B"
        case .economy:
            return "#4ECDC4"
        case .culture:
            return "#45B7D1"
        case .technology:
            return "#96CEB4"
        case .sports:
            return "#FFEAA7"
        case .general:
            return "#A29BFE"
        }
    }
}
