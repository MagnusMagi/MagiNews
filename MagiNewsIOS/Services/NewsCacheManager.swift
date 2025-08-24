//
//  NewsCacheManager.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import Combine

@MainActor
class NewsCacheManager: ObservableObject {
    @Published var cachedArticles: [String: [Article]] = [:] // [Region: [Article]]
    @Published var cacheTimestamps: [String: Date] = [:] // [Region: Date]
    @Published var isRefreshing = false
    
    private let cacheExpiryInterval: TimeInterval = 6 * 60 * 60 // 6 hours
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadCacheFromDisk()
    }
    
    // MARK: - Public Methods
    
    /// Check if cache is valid for a specific region
    func isCacheValid(for region: String) -> Bool {
        guard let timestamp = cacheTimestamps[region] else { return false }
        let age = Date().timeIntervalSince(timestamp)
        return age < cacheExpiryInterval
    }
    
    /// Get cached articles for a region
    func getCachedArticles(for region: String) -> [Article] {
        return cachedArticles[region] ?? []
    }
    
    func getAllCachedArticles() -> [Article] {
        return Array(cachedArticles.values.flatMap { $0 })
    }
    
    func getLatestCacheTimestamp() -> Date? {
        return cacheTimestamps.values.max()
    }
    
    /// Update cache with new articles for a region
    func updateCache(articles: [Article], for region: String) {
        // Check if feed has changed significantly
        if hasFeedChanged(articles: articles, for: region) {
            // Clear old cache and add new articles
            cachedArticles[region] = articles
            cacheTimestamps[region] = Date()
        } else {
            // Merge new articles with existing cache, avoiding duplicates
            let existingArticles = cachedArticles[region] ?? []
            let newArticles = articles.filter { newArticle in
                !existingArticles.contains { $0.link == newArticle.link }
            }
            
            if !newArticles.isEmpty {
                cachedArticles[region] = existingArticles + newArticles
                cacheTimestamps[region] = Date()
            }
        }
        
        saveCacheToDisk()
    }
    
    /// Clear cache for a specific region
    func clearCache(for region: String) {
        cachedArticles.removeValue(forKey: region)
        cacheTimestamps.removeValue(forKey: region)
        saveCacheToDisk()
    }
    
    /// Clear all cache
    func clearAllCache() {
        cachedArticles.removeAll()
        cacheTimestamps.removeAll()
        saveCacheToDisk()
    }
    
    /// Get cache age for a region
    func getCacheAge(for region: String) -> TimeInterval? {
        guard let timestamp = cacheTimestamps[region] else { return nil }
        return Date().timeIntervalSince(timestamp)
    }
    
    /// Get cache age as human-readable string
    func getCacheAgeString(for region: String) -> String {
        guard let age = getCacheAge(for: region) else { return "Never" }
        
        if age < 3600 {
            let minutes = Int(age / 60)
            return "\(minutes) minutes ago"
        } else if age < 86400 {
            let hours = Int(age / 3600)
            return "\(hours) hours ago"
        } else {
            let days = Int(age / 86400)
            return "\(days) days ago"
        }
    }
    
    /// Check if feed has changed by comparing article counts
    func hasFeedChanged(articles: [Article], for region: String) -> Bool {
        let cachedCount = cachedArticles[region]?.count ?? 0
        let newCount = articles.count
        
        // Consider it changed if count difference is significant (>10%)
        let difference = abs(newCount - cachedCount)
        let threshold = Double(max(cachedCount, newCount)) * 0.1
        
        return Double(difference) > threshold
    }
    
    /// Get cache statistics
    func getCacheStats() -> CacheStats {
        let totalArticles = cachedArticles.values.flatMap { $0 }.count
        let totalRegions = cachedArticles.keys.count
        let oldestCache = cacheTimestamps.values.min()
        let newestCache = cacheTimestamps.values.max()
        
        return CacheStats(
            totalArticles: totalArticles,
            totalRegions: totalRegions,
            oldestCache: oldestCache,
            newestCache: newestCache
        )
    }
    
    // MARK: - Private Methods
    
    private func saveCacheToDisk() {
        do {
            let encoder = JSONEncoder()
            
            // Save articles
            let articlesData = try encoder.encode(cachedArticles)
            userDefaults.set(articlesData, forKey: "cachedArticles")
            
            // Save timestamps
            let timestampsData = try encoder.encode(cacheTimestamps)
            userDefaults.set(timestampsData, forKey: "cacheTimestamps")
            
        } catch {
            print("Failed to save cache to disk: \(error)")
        }
    }
    
    private func loadCacheFromDisk() {
        do {
            let decoder = JSONDecoder()
            
            // Load articles
            if let articlesData = userDefaults.data(forKey: "cachedArticles") {
                cachedArticles = try decoder.decode([String: [Article]].self, from: articlesData)
            }
            
            // Load timestamps
            if let timestampsData = userDefaults.data(forKey: "cacheTimestamps") {
                cacheTimestamps = try decoder.decode([String: Date].self, from: timestampsData)
            }
            
        } catch {
            print("Failed to load cache from disk: \(error)")
            // Reset cache on error
            cachedArticles.removeAll()
            cacheTimestamps.removeAll()
        }
    }
}

// MARK: - Cache Statistics

struct CacheStats {
    let totalArticles: Int
    let totalRegions: Int
    let oldestCache: Date?
    let newestCache: Date?
    
    var isHealthy: Bool {
        guard let oldest = oldestCache else { return false }
        let age = Date().timeIntervalSince(oldest)
        return age < 24 * 60 * 60 // 24 hours
    }
}
