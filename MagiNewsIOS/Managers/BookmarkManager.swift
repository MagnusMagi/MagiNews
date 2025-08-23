//
//  BookmarkManager.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftUI

@MainActor
class BookmarkManager: ObservableObject {
    @AppStorage("bookmarkedArticles") private var bookmarkedArticlesData: Data = Data()
    
    @Published var bookmarkedArticles: Set<UUID> = []
    
    init() {
        loadBookmarks()
    }
    
    // MARK: - Public Methods
    
    func toggleBookmark(for articleId: UUID) {
        if bookmarkedArticles.contains(articleId) {
            removeBookmark(for: articleId)
        } else {
            addBookmark(for: articleId)
        }
    }
    
    func isBookmarked(_ articleId: UUID) -> Bool {
        bookmarkedArticles.contains(articleId)
    }
    
    func removeBookmark(for articleId: UUID) {
        bookmarkedArticles.remove(articleId)
        saveBookmarks()
    }
    
    func clearAllBookmarks() {
        bookmarkedArticles.removeAll()
        saveBookmarks()
    }
    
    func addBookmark(for articleId: UUID) {
        bookmarkedArticles.insert(articleId)
        saveBookmarks()
    }
    
    // MARK: - Private Methods
    
    private func loadBookmarks() {
        do {
            let decoder = JSONDecoder()
            let articleIds = try decoder.decode([UUID].self, from: bookmarkedArticlesData)
            bookmarkedArticles = Set(articleIds)
        } catch {
            print("Failed to load bookmarks: \(error)")
            bookmarkedArticles = []
        }
    }
    
    private func saveBookmarks() {
        do {
            let encoder = JSONEncoder()
            let articleIds = Array(bookmarkedArticles)
            bookmarkedArticlesData = try encoder.encode(articleIds)
        } catch {
            print("Failed to save bookmarks: \(error)")
        }
    }
}

// MARK: - Bookmark Extensions

extension CachedArticle {
    var isBookmarked: Bool {
        // This would be used in views to check bookmark status
        // Implementation depends on how BookmarkManager is injected
        false
    }
}
