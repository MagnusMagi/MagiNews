//
//  CacheManager.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftUI

@MainActor
class CacheManager: ObservableObject {
    @Published var isClearing = false
    @Published var cacheSize: String = "0 MB"
    @Published var articleCount: Int = 0
    @Published var lastCleared: Date?
    
    private let offlineCache: OfflineCache
    private let bookmarkManager: BookmarkManager
    
    init(offlineCache: OfflineCache, bookmarkManager: BookmarkManager) {
        self.offlineCache = offlineCache
        self.bookmarkManager = bookmarkManager
        updateCacheInfo()
    }
    
    // MARK: - Cache Information
    func updateCacheInfo() {
        Task {
            await refreshCacheStats()
        }
    }
    
    private func refreshCacheStats() async {
        // Get cache size from OfflineCache
        cacheSize = offlineCache.cacheSize
        articleCount = offlineCache.cachedArticles.count
    }
    
    // MARK: - Cache Operations
    func clearAllCache() async {
        isClearing = true
        
        do {
            // Clear offline cache
            offlineCache.clearAllCache()
            
            // Clear bookmarks
            bookmarkManager.clearAllBookmarks()
            
            // Clear UserDefaults cache-related data
            UserDefaults.standard.removeObject(forKey: "lastUpdateTime")
            UserDefaults.standard.removeObject(forKey: "cacheMetadata")
            
            // Update cache info
            await refreshCacheStats()
            lastCleared = Date()
            
        } catch {
            print("Error clearing cache: \(error)")
        }
        
        isClearing = false
    }
    
    func clearExpiredCache() async {
        isClearing = true
        
        do {
            offlineCache.clearExpiredCache()
            await refreshCacheStats()
        } catch {
            print("Error clearing expired cache: \(error)")
        }
        
        isClearing = false
    }
    
    // MARK: - Export Functions
    func exportBookmarks() -> URL? {
        let bookmarks = bookmarkManager.bookmarkedArticles
        
        // Convert to exportable format
        let exportData = ExportData(
            exportedAt: Date(),
            bookmarksCount: bookmarks.count,
            version: "1.0"
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(exportData)
            
            // Create temporary file
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("MagiNews_Bookmarks")
                .appendingPathExtension("json")
            
            try data.write(to: tempURL)
            return tempURL
            
        } catch {
            print("Error exporting bookmarks: \(error)")
            return nil
        }
    }
    
    // MARK: - Cache Health
    var isCacheHealthy: Bool {
        // Check if cache is not too old and has reasonable size
        guard let lastUpdate = offlineCache.cacheMetadata?.lastUpdated else {
            return false
        }
        
        let age = Date().timeIntervalSince(lastUpdate)
        let maxAge: TimeInterval = 24 * 60 * 60 // 24 hours
        
        return age < maxAge && articleCount > 0
    }
    
    var cacheAge: String {
        guard let lastUpdate = offlineCache.cacheMetadata?.lastUpdated else {
            return "Never"
        }
        
        let timeInterval = Date().timeIntervalSince(lastUpdate)
        
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
}

// MARK: - Export Data Model
struct ExportData: Codable {
    let exportedAt: Date
    let bookmarksCount: Int
    let version: String
}
