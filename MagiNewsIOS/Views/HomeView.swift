//
//  HomeView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var newsRepository = NewsRepository()
    @StateObject private var bookmarkManager = BookmarkManager()
    @State private var searchText = ""
    @State private var selectedRegion: String = "All"
    @State private var selectedCategory: String = "All"
    @State private var showingDailyDigest = false
    @State private var refreshTrigger = UUID()
    
    private let regions = ["All", "Estonia", "Latvia", "Lithuania", "Finland"]
    private let categories = ["All", "Politics", "Technology", "Economy", "Culture", "Sports", "General"]
    
    var filteredArticles: [Article] {
        var articles = newsRepository.articles
        
        // Filter by search text
        if !searchText.isEmpty {
            articles = articles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.content.localizedCaseInsensitiveContains(searchText) ||
                article.summary.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by region
        if selectedRegion != "All" {
            articles = articles.filter { $0.region == selectedRegion }
        }
        
        // Filter by category
        if selectedCategory != "All" {
            articles = articles.filter { $0.category.lowercased().contains(selectedCategory.lowercased()) }
        }
        
        // Sort by publication date
        return articles.sorted { 
            parseDate(from: $0.publishedAt) ?? Date.distantPast > 
            parseDate(from: $1.publishedAt) ?? Date.distantPast 
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with search and digest
                headerSection
                
                // Filters
                filtersSection
                
                // Content
                contentSection
            }
            .navigationTitle("MagiNews")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshContent()
            }
            .sheet(isPresented: $showingDailyDigest) {
                DailyDigestView(articles: newsRepository.getDailyDigest().map { article in
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
                })
            }
            .task {
                await loadInitialContent()
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
                
                TextField("Search news...", text: $searchText)
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
            
            // Daily Digest Button & Status
            VStack(spacing: 8) {
                Button(action: {
                    showingDailyDigest = true
                }) {
                    HStack {
                        Image(systemName: "newspaper.fill")
                            .foregroundColor(.white)
                        Text("Daily Digest")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        if newsRepository.getDailyDigest().count > 0 {
                            Text("(\(newsRepository.getDailyDigest().count))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                // Status info
                if let lastUpdate = newsRepository.lastUpdateTime {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("Last updated: \(lastUpdate, style: .time)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                } else if newsRepository.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading...")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Filters Section
    
    private var filtersSection: some View {
        VStack(spacing: 12) {
            // Region Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(regions, id: \.self) { region in
                        FilterButton(
                            title: region,
                            isSelected: selectedRegion == region,
                            action: { selectedRegion = region }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
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
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        Group {
            if newsRepository.isLoading && newsRepository.articles.isEmpty {
                loadingView
            } else if filteredArticles.isEmpty {
                emptyStateView
            } else {
                articlesList
            }
        }
        .id(refreshTrigger)
    }
    
    private var articlesList: some View {
        List {
            ForEach(filteredArticles) { article in
                NavigationLink(destination: ArticleDetailView(article: convertToCache(article))) {
                    ArticleRowView(article: article, isBookmarked: bookmarkManager.isBookmarked(article.id)) {
                        bookmarkManager.toggleBookmark(for: article.id)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading latest news...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Fetching from Baltic news sources...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No articles found")
                .font(.title2)
                .fontWeight(.semibold)
            
            if newsRepository.errorMessage != nil {
                Text("Unable to load news feeds")
                    .font(.subheadline)
                    .foregroundColor(.red)
                
                Text("Check your internet connection and try again")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Try adjusting your filters or refresh to get the latest news")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Refresh") {
                Task {
                    await refreshContent()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Helper Methods
    
    private func loadInitialContent() async {
        await newsRepository.loadArticles()
    }
    
    private func refreshContent() async {
        await newsRepository.refreshAllFeeds()
        refreshTrigger = UUID()
    }
    
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

// MARK: - Filter Button Component

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : backgroundColor)
                .foregroundColor(isSelected ? .white : textColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .primary
    }
}

// MARK: - Article Row View

struct ArticleRowView: View {
    let article: Article
    let isBookmarked: Bool
    let onBookmarkToggle: () -> Void
    
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
                        
                        // Bookmark button
                        Button(action: onBookmarkToggle) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .foregroundColor(isBookmarked ? .blue : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HomeView()
}
