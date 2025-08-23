//
//  NewsRepository.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import Combine

@MainActor
class NewsRepository: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdateTime: Date?
    
    private let rssService = RSSService()
    private let offlineCache = OfflineCache()
    private let localSummarizer = LocalSummarizer()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load cached articles on startup
        loadCachedArticles()
    }
    
    // MARK: - Public Methods
    
    func loadArticles(source: RSSFeedSource? = nil, forceRefresh: Bool = false) async {
        if forceRefresh || articles.isEmpty {
            await fetchFreshArticles(source: source)
        } else {
            loadCachedArticles()
        }
    }
    
    func refreshAllFeeds() async {
        await fetchFreshArticles(source: nil)
    }
    
    func getDailyDigest() -> [Article] {
        let today = Calendar.current.startOfDay(for: Date())
        let todaysArticles = articles.filter { article in
            if let date = parseDate(from: article.publishedAt) {
                return Calendar.current.isDate(date, inSameDayAs: today)
            }
            return false
        }
        
        // Return top 5 articles sorted by publication date
        return Array(todaysArticles.sorted { 
            parseDate(from: $0.publishedAt) ?? Date.distantPast > 
            parseDate(from: $1.publishedAt) ?? Date.distantPast 
        }.prefix(5))
    }
    
    func getArticles(forRegion region: String) -> [Article] {
        articles.filter { $0.region == region }
    }
    
    func getArticles(forCategory category: String) -> [Article] {
        articles.filter { $0.category.lowercased().contains(category.lowercased()) }
    }
    
    // MARK: - Private Methods
    
    private func fetchFreshArticles(source: RSSFeedSource?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let feeds: [RSSFeed]
            
            if let specificSource = source {
                // Fetch specific source
                if let feed = try await rssService.fetchFeed(from: specificSource) {
                    feeds = [feed]
                } else {
                    feeds = []
                }
            } else {
                // Fetch all sources
                feeds = await fetchAllFeeds()
            }
            
            let newArticles = feeds.flatMap { feed in
                feed.items.map { item in
                    convertToArticle(item: item, feed: feed)
                }
            }
            
            // Update articles and cache
            articles = newArticles
            cacheArticles(newArticles)
            lastUpdateTime = Date()
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching articles: \(error)")
            
            // Fall back to cached articles if available
            if articles.isEmpty {
                loadCachedArticles()
            }
        }
        
        isLoading = false
    }
    
    private func fetchAllFeeds() async -> [RSSFeed] {
        await withTaskGroup(of: RSSFeed?.self) { group in
            var feeds: [RSSFeed] = []
            
            for source in RSSFeedSource.allCases {
                group.addTask {
                    try? await self.rssService.fetchFeed(from: source)
                }
            }
            
            for await feed in group {
                if let feed = feed {
                    feeds.append(feed)
                }
            }
            
            return feeds
        }
    }
    
    private func convertToArticle(item: RSSItem, feed: RSSFeed) -> Article {
        let source = determineSource(from: feed.link)
        let region = determineRegion(from: source)
        let language = determineLanguage(from: source)
        
        // Generate local summary
        let summary = localSummarizer.generateSummary(from: item.description)
        
        return Article(
            id: UUID(),
            title: item.title,
            content: item.description,
            summary: summary,
            author: extractAuthor(from: item.description),
            publishedAt: item.pubDate,
            imageURL: item.imageURL,
            category: item.category ?? "General",
            source: source,
            region: region,
            language: language,
            link: item.link
        )
    }
    
    private func determineSource(from feedLink: String) -> String {
        if feedLink.contains("err.ee") { return "ERR.ee" }
        if feedLink.contains("postimees.ee") { return "Postimees.ee" }
        if feedLink.contains("delfi.ee") { return "Delfi.ee" }
        if feedLink.contains("lsm.lv") { return "LSM.lv" }
        if feedLink.contains("lrt.lt") { return "LRT.lt" }
        if feedLink.contains("yle.fi") { return "Yle.fi" }
        return "Unknown"
    }
    
    private func determineRegion(from source: String) -> String {
        switch source {
        case "ERR.ee", "Postimees.ee", "Delfi.ee":
            return "Estonia"
        case "LSM.lv":
            return "Latvia"
        case "LRT.lt":
            return "Lithuania"
        case "Yle.fi":
            return "Finland"
        default:
            return "Unknown"
        }
    }
    
    private func determineLanguage(from source: String) -> String {
        switch source {
        case "ERR.ee", "Postimees.ee", "Delfi.ee":
            return "Estonian"
        case "LSM.lv":
            return "Latvian"
        case "LRT.lt":
            return "Lithuanian"
        case "Yle.fi":
            return "Finnish"
        default:
            return "English"
        }
    }
    
    private func extractAuthor(from content: String) -> String {
        // Simple author extraction - can be improved
        return "News Reporter"
    }
    
    private func parseDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        
        // Try common RSS date formats
        let formats = [
            "EEE, dd MMM yyyy HH:mm:ss Z",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "dd MMM yyyy HH:mm:ss Z"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    // MARK: - Caching
    
    private func loadCachedArticles() {
        let cachedArticles = offlineCache.cachedArticles.map { cachedArticle in
            Article(
                id: cachedArticle.id,
                title: cachedArticle.rssItem.title,
                content: cachedArticle.rssItem.description,
                summary: cachedArticle.summary ?? localSummarizer.generateSummary(from: cachedArticle.rssItem.description),
                author: "News Reporter",
                publishedAt: cachedArticle.rssItem.pubDate,
                imageURL: cachedArticle.rssItem.imageURL,
                category: cachedArticle.rssItem.category ?? "General",
                source: cachedArticle.source,
                region: cachedArticle.region,
                language: cachedArticle.language,
                link: cachedArticle.rssItem.link
            )
        }
        
        if !cachedArticles.isEmpty {
            articles = cachedArticles
        }
    }
    
    private func cacheArticles(_ articles: [Article]) {
        // Convert articles back to cached format
        for article in articles {
            let rssItem = RSSItem(
                title: article.title,
                link: article.link,
                description: article.content,
                pubDate: article.publishedAt,
                category: article.category,
                imageURL: article.imageURL
            )
            
            let cachedArticle = CachedArticle(
                id: article.id,
                rssItem: rssItem,
                summary: article.summary,
                translatedTitle: nil,
                translatedSummary: nil,
                cachedAt: Date(),
                source: article.source,
                region: article.region,
                language: article.language
            )
            
            offlineCache.cacheArticle(cachedArticle)
        }
    }
}

// MARK: - Article Model
struct Article: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let summary: String
    let author: String
    let publishedAt: String
    let imageURL: String?
    let category: String
    let source: String
    let region: String
    let language: String
    let link: String
    
    var publishedDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.date(from: publishedAt)
    }
    
    var timeAgo: String {
        guard let date = publishedDate else { return "Unknown" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Local Summarizer
class LocalSummarizer {
    func generateSummary(from content: String) -> String {
        // Remove HTML tags
        let cleanContent = content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Split into sentences
        let sentences = cleanContent.components(separatedBy: ". ")
        
        // Take first 2-3 sentences or first 300 characters
        if sentences.count >= 2 {
            let summary = sentences.prefix(2).joined(separator: ". ")
            return summary.count > 300 ? String(summary.prefix(300)) + "..." : summary + "."
        } else {
            return cleanContent.count > 300 ? String(cleanContent.prefix(300)) + "..." : cleanContent
        }
    }
}
