//
//  OfflineCache.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import Combine

// MARK: - Cache Models
struct CachedArticle: Codable, Identifiable {
    var id = UUID()
    let rssItem: RSSItem
    let summary: String?
    let translatedTitle: String?
    let translatedSummary: String?
    let cachedAt: Date
    let source: String
    let region: String
    let language: String
    
    init(id: UUID = UUID(), rssItem: RSSItem, summary: String?, translatedTitle: String?, translatedSummary: String?, cachedAt: Date, source: String, region: String, language: String) {
        self.id = id
        self.rssItem = rssItem
        self.summary = summary
        self.translatedTitle = translatedTitle
        self.translatedSummary = translatedSummary
        self.cachedAt = cachedAt
        self.source = source
        self.region = region
        self.language = language
    }
    
    var isExpired: Bool {
        // Cache expires after 24 hours
        return Date().timeIntervalSince(cachedAt) > 24 * 60 * 60
    }
}

struct CacheMetadata: Codable {
    let lastUpdated: Date
    let totalArticles: Int
    let regions: [String]
    let languages: [String]
}

// MARK: - Offline Cache Service
class OfflineCache: ObservableObject {
    @Published var cachedArticles: [CachedArticle] = []
    @Published var cacheMetadata: CacheMetadata?
    @Published var isUpdating = false
    
    private let cacheDirectory: URL
    private let articlesFile = "cached_articles.json"
    private let metadataFile = "cache_metadata.json"
    
    init() {
        // Get cache directory in app's documents folder
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("MagiNewsCache")
        
        createCacheDirectoryIfNeeded()
        loadCachedData()
    }
    
    // MARK: - Cache Management
    func cacheArticles(_ articles: [RSSItem], from source: RSSFeedSource) {
        isUpdating = true
        
        let newCachedArticles = articles.map { rssItem in
            CachedArticle(
                rssItem: rssItem,
                summary: nil,
                translatedTitle: nil,
                translatedSummary: nil,
                cachedAt: Date(),
                source: source.rawValue,
                region: source.region,
                language: source.language
            )
        }
        
        // Remove expired articles
        let validArticles = cachedArticles.filter { !$0.isExpired }
        
        // Add new articles, avoiding duplicates
        let existingIds = Set(validArticles.map { $0.rssItem.id })
        let uniqueNewArticles = newCachedArticles.filter { !existingIds.contains($0.rssItem.id) }
        
        cachedArticles = validArticles + uniqueNewArticles
        
        updateCacheMetadata()
        saveCachedData()
        
        isUpdating = false
    }
    
    func updateArticleSummary(_ articleId: UUID, summary: String) {
        if let index = cachedArticles.firstIndex(where: { $0.rssItem.id == articleId }) {
            // Create a new instance with updated summary
            let currentArticle = cachedArticles[index]
            let updatedArticle = CachedArticle(
                id: currentArticle.id,
                rssItem: currentArticle.rssItem,
                summary: summary,
                translatedTitle: currentArticle.translatedTitle,
                translatedSummary: currentArticle.translatedSummary,
                cachedAt: currentArticle.cachedAt,
                source: currentArticle.source,
                region: currentArticle.region,
                language: currentArticle.language
            )
            cachedArticles[index] = updatedArticle
            saveCachedData()
        }
    }
    
    func clearExpiredCache() {
        cachedArticles = cachedArticles.filter { !$0.isExpired }
        updateCacheMetadata()
        saveCachedData()
    }
    
    func clearAllCache() {
        cachedArticles.removeAll()
        cacheMetadata = nil
        saveCachedData()
    }
    
    func cacheArticle(_ article: CachedArticle) {
        // Check if article already exists
        if let existingIndex = cachedArticles.firstIndex(where: { $0.id == article.id }) {
            cachedArticles[existingIndex] = article
        } else {
            cachedArticles.append(article)
        }
        
        updateCacheMetadata()
        saveCachedData()
    }
    
    // MARK: - Cache Queries
    func getArticles(for category: FeedCategory?) -> [CachedArticle] {
        if let category = category {
            return cachedArticles.filter { article in
                article.rssItem.category?.lowercased().contains(category.rawValue.lowercased()) == true
            }
        }
        return cachedArticles
    }
    
    func getArticles(forRegion region: String) -> [CachedArticle] {
        return cachedArticles.filter { $0.region == region }
    }
    
    func getArticles(forLanguage language: String) -> [CachedArticle] {
        return cachedArticles.filter { $0.language == language }
    }
    
    func searchArticles(query: String) -> [CachedArticle] {
        let lowercasedQuery = query.lowercased()
        return cachedArticles.filter { article in
            article.rssItem.title.lowercased().contains(lowercasedQuery) ||
            article.rssItem.description.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getTopArticles(limit: Int = 10) -> [CachedArticle] {
        // Sort by cache date (newest first) and return top articles
        return Array(cachedArticles.sorted { $0.cachedAt > $1.cachedAt }.prefix(limit))
    }
    
    // MARK: - Private Methods
    private func createCacheDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func loadCachedData() {
        loadCachedArticles()
        loadCacheMetadata()
    }
    
    private func loadCachedArticles() {
        let fileURL = cacheDirectory.appendingPathComponent(articlesFile)
        
        guard let data = try? Data(contentsOf: fileURL) else { return }
        
        do {
            let articles = try JSONDecoder().decode([CachedArticle].self, from: data)
            cachedArticles = articles.filter { !$0.isExpired }
        } catch {
            print("Error loading cached articles: \(error)")
        }
    }
    
    private func loadCacheMetadata() {
        let fileURL = cacheDirectory.appendingPathComponent(metadataFile)
        
        guard let data = try? Data(contentsOf: fileURL) else { return }
        
        do {
            cacheMetadata = try JSONDecoder().decode(CacheMetadata.self, from: data)
        } catch {
            print("Error loading cache metadata: \(error)")
        }
    }
    
    private func saveCachedData() {
        saveCachedArticles()
        saveCacheMetadata()
    }
    
    private func saveCachedArticles() {
        let fileURL = cacheDirectory.appendingPathComponent(articlesFile)
        
        do {
            let data = try JSONEncoder().encode(cachedArticles)
            try data.write(to: fileURL)
        } catch {
            print("Error saving cached articles: \(error)")
        }
    }
    
    private func saveCacheMetadata() {
        let fileURL = cacheDirectory.appendingPathComponent(metadataFile)
        
        do {
            let data = try JSONEncoder().encode(cacheMetadata)
            try data.write(to: fileURL)
        } catch {
            print("Error saving cache metadata: \(error)")
        }
    }
    
    private func updateCacheMetadata() {
        let regions = Array(Set(cachedArticles.map { $0.region }))
        let languages = Array(Set(cachedArticles.map { $0.language }))
        
        cacheMetadata = CacheMetadata(
            lastUpdated: Date(),
            totalArticles: cachedArticles.count,
            regions: regions,
            languages: languages
        )
    }
}

// MARK: - Cache Statistics
extension OfflineCache {
    var cacheSize: String {
        let fileURL = cacheDirectory.appendingPathComponent(articlesFile)
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let fileSize = attributes[.size] as? Int64 else {
            return "Unknown"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var cacheAge: String {
        guard let metadata = cacheMetadata else { return "Never" }
        
        let timeInterval = Date().timeIntervalSince(metadata.lastUpdated)
        
        if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minutes ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hours ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days) days ago"
        }
    }
    
    var regionDistribution: [String: Int] {
        var distribution: [String: Int] = [:]
        for article in cachedArticles {
            distribution[article.region, default: 0] += 1
        }
        return distribution
    }
    
    var languageDistribution: [String: Int] {
        var distribution: [String: Int] = [:]
        for article in cachedArticles {
            distribution[article.language, default: 0] += 1
        }
        return distribution
    }
}
