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
            return "https://feeds.err.ee/rss/err_news"
        case .postimeesEe:
            return "https://feeds.postimees.ee/rss/pealinn"
        case .delfiEe:
            return "https://feeds.delfi.ee/rss/delfi_news"
        case .lsmLv:
            return "https://feeds.lsm.lv/rss/latvia"
        case .lrtLt:
            return "https://feeds.lrt.lt/rss/lithuania"
        case .yleFi:
            return "https://feeds.yle.fi/rss/yle_news"
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

struct RSSItem: Codable, Identifiable {
    let id = UUID()
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
        title = try container.decode(String.self, forKey: .title)
        link = try container.decode(String.self, forKey: .link)
        description = try container.decode(String.self, forKey: .description)
        pubDate = try container.decode(String.self, forKey: .pubDate)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        
        // Handle image URL from enclosure
        if let enclosure = try container.decodeIfPresent(Enclosure.self, forKey: .imageURL) {
            imageURL = enclosure.url
        } else {
            imageURL = nil
        }
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
        guard let url = URL(string: source.url) else {
            return Fail(error: RSSError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: RSSFeed.self, decoder: RSSDecoder())
            .map { feed in
                // Enrich feed with source information
                var enrichedFeed = feed
                // Note: In a real implementation, you'd need to modify the RSSFeed struct
                // to include source information, or create a wrapper
                return enrichedFeed
            }
            .catch { error -> AnyPublisher<RSSFeed?, Error> in
                print("Error fetching feed from \(source.url): \(error)")
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
        let feed = try RSSDecoder().decode(RSSFeed.self, from: data)
        return feed
    }
}

// MARK: - RSS Decoder
class RSSDecoder: XMLDecoder {
    override init() {
        super.init()
        self.keyDecodingStrategy = .useDefaultKeys
    }
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
