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
    @Published var lastUpdateTime: Date = Date()
    
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
        lastUpdateTime = Date()
    }
    
    func isBookmarked(_ articleId: UUID) -> Bool {
        bookmarkedArticles.contains(articleId)
    }
    
    func removeBookmark(for articleId: UUID) {
        bookmarkedArticles.remove(articleId)
        saveBookmarks()
        objectWillChange.send() // Ensure UI updates
    }
    
    func clearAllBookmarks() {
        bookmarkedArticles.removeAll()
        saveBookmarks()
        lastUpdateTime = Date()
        objectWillChange.send() // Ensure UI updates
    }
    
    func addBookmark(for articleId: UUID) {
        bookmarkedArticles.insert(articleId)
        saveBookmarks()
        objectWillChange.send() // Ensure UI updates
    }
    
    func getBookmarkedCount() -> Int {
        return bookmarkedArticles.count
    }
    
    func hasBookmarks() -> Bool {
        return !bookmarkedArticles.isEmpty
    }
    
    // MARK: - Private Methods
    
    private func loadBookmarks() {
        do {
            let decoder = JSONDecoder()
            let articleIds = try decoder.decode([UUID].self, from: bookmarkedArticlesData)
            bookmarkedArticles = Set(articleIds)
            lastUpdateTime = Date()
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
