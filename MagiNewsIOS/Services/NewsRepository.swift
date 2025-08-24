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
    @Published var isShowingCachedData = false
    
    private let rssService = RSSService()
    private let offlineCache = OfflineCache()
    private let localSummarizer = LocalSummarizer()
    private let newsCacheManager = NewsCacheManager()
    private var cancellables = Set<AnyCancellable>()
    
    // Cache expiry settings
    private let cacheExpiryHours: TimeInterval = 6 * 3600 // 6 hours (matching NewsCacheManager)
    
    init() {
        // Load cached articles on startup
        loadCachedArticles()
    }
    
    // MARK: - Cache Management
    
    private func loadCachedArticles() {
        // Use NewsCacheManager for better cache handling
        let allCachedArticles = newsCacheManager.getAllCachedArticles()
        if !allCachedArticles.isEmpty {
            articles = allCachedArticles
            isShowingCachedData = true
            lastUpdateTime = newsCacheManager.getLatestCacheTimestamp()
        } else {
            // Fallback to OfflineCache for backward compatibility
            let cachedArticles = offlineCache.getArticles(for: nil)
            if !cachedArticles.isEmpty {
                articles = cachedArticles.map { cachedArticle in
                    Article(
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
                isShowingCachedData = true
                lastUpdateTime = Date()
            }
        }
    }
    
    private func cacheArticles(_ articles: [Article]) {
        // Use NewsCacheManager for better cache management
        let articlesByRegion = Dictionary(grouping: articles) { $0.region }
        
        for (region, regionArticles) in articlesByRegion {
            newsCacheManager.updateCache(articles: regionArticles, for: region)
        }
        
        // Also update OfflineCache for backward compatibility
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
        isShowingCachedData = false
    }
    
    private func isCacheExpired() -> Bool {
        guard let lastUpdate = lastUpdateTime else { return true }
        let expiryDate = lastUpdate.addingTimeInterval(cacheExpiryHours)
        return Date() > expiryDate
    }
    
    private func getCacheAgeMessage() -> String? {
        guard let lastUpdate = lastUpdateTime else { return nil }
        
        let timeInterval = Date().timeIntervalSince(lastUpdate)
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "You're viewing saved news from \(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if minutes > 0 {
            return "You're viewing saved news from \(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            return "You're viewing the latest news"
        }
    }
    
    // MARK: - Public Methods
    
    func loadArticles(source: RSSFeedSource? = nil, forceRefresh: Bool = false) async {
        if forceRefresh || articles.isEmpty || isCacheExpired() {
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
        // Use NewsCacheManager for region-specific articles
        if newsCacheManager.isCacheValid(for: region) {
            return newsCacheManager.getCachedArticles(for: region)
        }
        return articles.filter { $0.region == region }
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
            
            // Deduplicate articles using NewsCacheManager
            let deduplicatedArticles = deduplicateArticles(newArticles)
            
            // Update articles and cache
            articles = deduplicatedArticles
            cacheArticles(deduplicatedArticles)
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
    
    private func deduplicateArticles(_ articles: [Article]) -> [Article] {
        // Use NewsCacheManager's deduplication logic
        let articlesByLink = Dictionary(grouping: articles) { $0.link }
        let uniqueArticles = articlesByLink.compactMap { $0.value.first }
        
        // Sort by publication date (newest first)
        return uniqueArticles.sorted { 
            parseDate(from: $0.publishedAt) ?? Date.distantPast > 
            parseDate(from: $1.publishedAt) ?? Date.distantPast 
        }
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
        let region = determineRegion(from: feed.link)
        let language = determineLanguage(from: feed.link)
        
        return Article(
            title: item.title,
            content: item.description.cleanedRSSContent,
            summary: localSummarizer.generateSummary(from: item.description.cleanedRSSContent),
            author: "News Reporter",
            publishedAt: item.pubDate,
            imageURL: item.imageURL,
            category: item.category ?? "General",
            source: source,
            region: region,
            language: language,
            link: item.link
        )
    }
    
    private func determineSource(from link: String) -> String {
        if link.contains("err.ee") { return "ERR" }
        if link.contains("postimees.ee") { return "Postimees" }
        if link.contains("delfi.ee") { return "Delfi" }
        if link.contains("lrt.lt") { return "LRT" }
        if link.contains("delfi.lt") { return "Delfi Lithuania" }
        if link.contains("lsm.lv") { return "LSM" }
        if link.contains("delfi.lv") { return "Delfi Latvia" }
        if link.contains("yle.fi") { return "Yle" }
        if link.contains("hs.fi") { return "Helsingin Sanomat" }
        return "Unknown"
    }
    
    private func determineRegion(from link: String) -> String {
        if link.contains(".ee") { return "Estonia" }
        if link.contains(".lt") { return "Lithuania" }
        if link.contains(".lv") { return "Latvia" }
        if link.contains(".fi") { return "Finland" }
        return "Unknown"
    }
    
    private func determineLanguage(from link: String) -> String {
        if link.contains("en.") || link.contains("/en/") { return "en" }
        if link.contains("et.") || link.contains("/et/") { return "et" }
        if link.contains("lt.") || link.contains("/lt/") { return "lt" }
        if link.contains("lv.") || link.contains("/lv/") { return "lv" }
        if link.contains("fi.") || link.contains("/fi/") { return "fi" }
        return "en"
    }
    
    private func parseDate(from dateString: String) -> Date? {
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "EEE, dd MMM yyyy HH:mm:ss Z",
            "EEE, dd MMM yyyy HH:mm:ss zzz",
            "dd MMM yyyy HH:mm:ss Z"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
}

// MARK: - Article Model
struct Article: Identifiable, Codable, Hashable {
    let id: String // Using link as stable identifier
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
    
    init(title: String, content: String, summary: String, author: String, publishedAt: String, imageURL: String?, category: String, source: String, region: String, language: String, link: String) {
        self.id = link // Use link as stable ID
        self.title = title
        self.content = content
        self.summary = summary
        self.author = author
        self.publishedAt = publishedAt
        self.imageURL = imageURL
        self.category = category
        self.source = source
        self.region = region
        self.language = language
        self.link = link
    }
    
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
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(link)
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.link == rhs.link
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
