//
//  FeedView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI
import Combine

struct FeedView: View {
    @StateObject private var rssService = RSSService()
    @StateObject private var offlineCache = OfflineCache()
    @StateObject private var summarizationService = SummarizationService()
    
    @State private var selectedCategory: FeedCategory?
    @State private var selectedRegion: String = "All"
    @State private var searchText = ""
    @State private var showingDailyDigest = false
    @State private var isRefreshing = false
    
    @Environment(\.colorScheme) var colorScheme
    
    private var filteredArticles: [CachedArticle] {
        var articles = offlineCache.cachedArticles
        
        // Filter by category
        if let category = selectedCategory {
            articles = articles.filter { article in
                article.rssItem.category?.lowercased().contains(category.rawValue.lowercased()) == true
            }
        }
        
        // Filter by region
        if selectedRegion != "All" {
            articles = articles.filter { $0.region == selectedRegion }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            articles = articles.filter { article in
                article.rssItem.title.localizedCaseInsensitiveContains(searchText) ||
                article.rssItem.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return articles.sorted { $0.cachedAt > $1.cachedAt }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with search and filters
                headerSection
                
                // Category and region filters
                filterSection
                
                // Articles list
                articlesList
            }
            .navigationTitle("MagiNews")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDailyDigest = true }) {
                        Image(systemName: "newspaper.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .refreshable {
                await refreshFeeds()
            }
            .sheet(isPresented: $showingDailyDigest) {
                DailyDigestView(articles: Array(offlineCache.getTopArticles(limit: 5)))
            }
            .onAppear {
                if offlineCache.cachedArticles.isEmpty {
                    Task {
                        await refreshFeeds()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search articles...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            
            // Stats bar
            HStack {
                Label("\(offlineCache.cachedArticles.count) articles", systemImage: "doc.text")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(offlineCache.cacheAge, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(offlineCache.cacheSize, systemImage: "internaldrive")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FeedCategory.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: {
                                if selectedCategory == category {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Region filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(["All"] + Array(Set(offlineCache.cachedArticles.map { $0.region })), id: \.self) { region in
                        RegionFilterButton(
                            region: region,
                            isSelected: selectedRegion == region,
                            action: { selectedRegion = region }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Articles List
    private var articlesList: some View {
        List {
            if filteredArticles.isEmpty {
                emptyStateView
            } else {
                ForEach(filteredArticles) { article in
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        ArticleCardView(article: article)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }
        }
        .listStyle(PlainListStyle())
        .overlay(
            Group {
                if rssService.isLoading && offlineCache.cachedArticles.isEmpty {
                    loadingView
                }
            }
        )
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No articles found")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Try adjusting your filters or refresh to get the latest news")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Refresh Feeds") {
                Task {
                    await refreshFeeds()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading latest news...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Actions
    private func refreshFeeds() async {
        isRefreshing = true
        
        // Fetch RSS feeds
        rssService.fetchAllFeeds()
        
        // Wait for feeds to load
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = rssService.$feeds
                .dropFirst()
                .sink { feeds in
                    // Cache articles from each feed
                    for feed in feeds {
                        if let source = RSSFeedSource.allCases.first(where: { $0.rawValue == feed.title }) {
                            offlineCache.cacheArticles(feed.items, from: source)
                        }
                    }
                    cancellable?.cancel()
                    continuation.resume()
                }
        }
        
        isRefreshing = false
    }
}

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let category: FeedCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? .blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Region Filter Button
struct RegionFilterButton: View {
    let region: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(region)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Article Card View
struct ArticleCardView: View {
    let article: CachedArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Article Image
                if let imageURL = article.rssItem.imageURL, !imageURL.isEmpty {
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
                    // Source and region
                    HStack {
                        Text(article.source)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        
                        Text(article.region)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    // Title
                    Text(article.rssItem.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    // Description
                    Text(article.rssItem.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Meta information
                    HStack {
                        Text(article.language)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(timeAgoString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var timeAgoString: String {
        let timeInterval = Date().timeIntervalSince(article.cachedAt)
        
        if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
    }
}

#Preview {
    FeedView()
}
