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
    
    @Published var bookmarkedArticles: Set<String> = [] // Using article.link as stable ID
    @Published var lastUpdateTime: Date = Date()
    
    init() {
        loadBookmarks()
    }
    
    // MARK: - Public Methods
    
    func toggleBookmark(for article: Article) {
        let articleId = article.link // Use link as stable identifier
        if bookmarkedArticles.contains(articleId) {
            removeBookmark(for: article)
        } else {
            addBookmark(for: article)
        }
        lastUpdateTime = Date()
    }
    
    func toggleBookmark(for articleLink: String) {
        if bookmarkedArticles.contains(articleLink) {
            removeBookmark(for: articleLink)
        } else {
            addBookmark(for: articleLink)
        }
        lastUpdateTime = Date()
    }
    
    func isBookmarked(_ article: Article) -> Bool {
        bookmarkedArticles.contains(article.link)
    }
    
    func isBookmarked(_ articleLink: String) -> Bool {
        bookmarkedArticles.contains(articleLink)
    }
    
    func removeBookmark(for article: Article) {
        bookmarkedArticles.remove(article.link)
        saveBookmarks()
        objectWillChange.send()
    }
    
    func removeBookmark(for articleLink: String) {
        bookmarkedArticles.remove(articleLink)
        saveBookmarks()
        objectWillChange.send()
    }
    
    func clearAllBookmarks() {
        bookmarkedArticles.removeAll()
        saveBookmarks()
        lastUpdateTime = Date()
        objectWillChange.send()
    }
    
    func addBookmark(for article: Article) {
        bookmarkedArticles.insert(article.link)
        saveBookmarks()
        objectWillChange.send()
    }
    
    func addBookmark(for articleLink: String) {
        bookmarkedArticles.insert(articleLink)
        saveBookmarks()
        objectWillChange.send()
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
            let articleIds = try decoder.decode([String].self, from: bookmarkedArticlesData)
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

extension Article {
    var isBookmarked: Bool {
        // This will be used in views to check bookmark status
        // The actual implementation will be provided by the view's environment
        false
    }
}
