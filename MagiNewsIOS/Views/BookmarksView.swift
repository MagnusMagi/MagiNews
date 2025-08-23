//
//  BookmarksView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct BookmarksView: View {
    @StateObject private var bookmarkManager = BookmarkManager()
    @StateObject private var newsRepository = NewsRepository()
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showingDeleteConfirmation = false
    @State private var articleToDelete: Article?
    
    private let categories = ["All", "Politics", "Technology", "Economy", "Culture", "Sports", "General"]
    
    var bookmarkedArticles: [Article] {
        let allBookmarkedIds = bookmarkManager.bookmarkedArticles
        var articles = newsRepository.articles.filter { allBookmarkedIds.contains($0.id) }
        
        // Filter by search text
        if !searchText.isEmpty {
            articles = articles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.summary.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if selectedCategory != "All" {
            articles = articles.filter { $0.category.lowercased().contains(selectedCategory.lowercased()) }
        }
        
        // Sort by most recently bookmarked (newest first)
        return articles.sorted { 
            parseDate(from: $0.publishedAt) ?? Date.distantPast > 
            parseDate(from: $1.publishedAt) ?? Date.distantPast 
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if bookmarkManager.bookmarkedArticles.isEmpty {
                    emptyStateView
                } else {
                    // Search and filters
                    headerSection
                    
                    // Bookmarked articles list
                    bookmarksList
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !bookmarkManager.bookmarkedArticles.isEmpty {
                        Menu {
                            Button("Clear All Bookmarks", role: .destructive) {
                                showingDeleteConfirmation = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Clear All Bookmarks", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    bookmarkManager.clearAllBookmarks()
                }
            } message: {
                Text("Are you sure you want to remove all bookmarked articles? This action cannot be undone.")
            }
            .task {
                await newsRepository.loadArticles()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search bookmarks...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        FilterButton(
                            title: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Stats
            HStack {
                Text("\(bookmarkedArticles.count) bookmarked articles")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !bookmarkedArticles.isEmpty {
                    Text("Swipe to remove")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Bookmarks List
    
    private var bookmarksList: some View {
        List {
            ForEach(bookmarkedArticles) { article in
                NavigationLink(destination: ArticleDetailView(article: convertToCache(article))) {
                    BookmarkRowView(article: article) {
                        bookmarkManager.removeBookmark(for: article.id)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Remove", role: .destructive) {
                        bookmarkManager.removeBookmark(for: article.id)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "bookmark")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("No Bookmarks Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Start bookmarking articles you want to read later. Tap the bookmark icon on any article to save it here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Tips section
            VStack(alignment: .leading, spacing: 12) {
                Text("Tips:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Image(systemName: "bookmark.circle")
                            .foregroundColor(.blue)
                        Text("Tap the bookmark icon on articles to save them")
                            .font(.subheadline)
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.blue)
                        Text("Bookmarked articles are available offline")
                            .font(.subheadline)
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "arrow.left.and.right")
                            .foregroundColor(.blue)
                        Text("Swipe articles here to remove bookmarks")
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemGroupedBackground))
            .cornerRadius(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Helper Methods
    
    private func convertToCache(_ article: Article) -> CachedArticle {
        CachedArticle(
            id: article.id,
            rssItem: RSSItem(
                title: article.title,
                link: article.link,
                description: article.content,
                pubDate: article.publishedAt,
                category: article.category,
                imageURL: article.imageURL
            ),
            summary: article.summary,
            translatedTitle: nil,
            translatedSummary: nil,
            cachedAt: Date(),
            source: article.source,
            region: article.region,
            language: article.language
        )
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
}

// MARK: - Bookmark Row View

struct BookmarkRowView: View {
    let article: Article
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Article Image
                if let imageURL = article.imageURL, !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "newspaper")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(article.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    // Summary
                    Text(article.summary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Footer
                    HStack {
                        // Source
                        Text(article.source)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        
                        // Region
                        Text(article.region)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Time
                        Text(article.timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Bookmarked indicator
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    BookmarksView()
}
