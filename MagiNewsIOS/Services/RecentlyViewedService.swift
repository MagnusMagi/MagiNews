//
//  RecentlyViewedService.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftUI

@MainActor
class RecentlyViewedService: ObservableObject {
    @Published var recentlyViewedArticles: [RecentlyViewedArticle] = []
    
    private let maxHistorySize = 5
    private let userDefaults = UserDefaults.standard
    private let recentlyViewedKey = "recentlyViewedArticles"
    
    init() {
        loadRecentlyViewed()
    }
    
    // MARK: - Public Methods
    
    func addArticle(_ article: Article) {
        // Remove if already exists
        recentlyViewedArticles.removeAll { $0.articleId == article.link }
        
        // Create new recently viewed article
        let recentlyViewed = RecentlyViewedArticle(
            articleId: article.link,
            title: article.title,
            summary: article.summary,
            imageURL: article.imageURL,
            source: article.source,
            region: article.region,
            category: article.category,
            viewedAt: Date()
        )
        
        // Add to beginning
        recentlyViewedArticles.insert(recentlyViewed, at: 0)
        
        // Keep only the last 5 articles
        if recentlyViewedArticles.count > maxHistorySize {
            recentlyViewedArticles = Array(recentlyViewedArticles.prefix(maxHistorySize))
        }
        
        saveRecentlyViewed()
    }
    
    func addCachedArticle(_ article: CachedArticle) {
        // Remove if already exists
        recentlyViewedArticles.removeAll { $0.articleId == article.rssItem.link }
        
        // Create new recently viewed article
        let recentlyViewed = RecentlyViewedArticle(
            articleId: article.rssItem.link,
            title: article.rssItem.title,
            summary: article.summary ?? "",
            imageURL: article.rssItem.imageURL,
            source: article.source,
            region: article.region,
            category: article.rssItem.category ?? "General",
            viewedAt: Date()
        )
        
        // Add to beginning
        recentlyViewedArticles.insert(recentlyViewed, at: 0)
        
        // Keep only the last 5 articles
        if recentlyViewedArticles.count > maxHistorySize {
            recentlyViewedArticles = Array(recentlyViewedArticles.prefix(maxHistorySize))
        }
        
        saveRecentlyViewed()
    }
    
    func clearHistory() {
        recentlyViewedArticles.removeAll()
        saveRecentlyViewed()
    }
    
    func removeArticle(_ articleId: String) {
        recentlyViewedArticles.removeAll { $0.articleId == articleId }
        saveRecentlyViewed()
    }
    
    // MARK: - Private Methods
    
    private func saveRecentlyViewed() {
        do {
            let data = try JSONEncoder().encode(recentlyViewedArticles)
            userDefaults.set(data, forKey: recentlyViewedKey)
        } catch {
            print("Error saving recently viewed articles: \(error)")
        }
    }
    
    private func loadRecentlyViewed() {
        guard let data = userDefaults.data(forKey: recentlyViewedKey) else { return }
        
        do {
            let articles = try JSONDecoder().decode([RecentlyViewedArticle].self, from: data)
            recentlyViewedArticles = articles
        } catch {
            print("Error loading recently viewed articles: \(error)")
            recentlyViewedArticles = []
        }
    }
}

// MARK: - Recently Viewed Article Model
struct RecentlyViewedArticle: Identifiable, Codable, Hashable {
    var id = UUID()
    let articleId: String
    let title: String
    let summary: String
    let imageURL: String?
    let source: String
    let region: String
    let category: String
    let viewedAt: Date
    
    // Computed properties
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: viewedAt, relativeTo: Date())
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: viewedAt)
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(articleId)
    }
    
    static func == (lhs: RecentlyViewedArticle, rhs: RecentlyViewedArticle) -> Bool {
        return lhs.articleId == rhs.articleId
    }
}
