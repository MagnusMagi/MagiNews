//
//  MainGridView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct MainGridView: View {
    @StateObject private var newsRepository = NewsRepository()
    @StateObject private var bookmarkManager = BookmarkManager()
    @StateObject private var summarizationService = SummarizationService()
    
    @State private var selectedCategory: String = "All"
    @State private var selectedCountry: String = "All"
    @State private var showingDailyDigest = false
    @State private var showingSearch = false
    @State private var showingProfile = false
    @State private var searchText = ""
    @State private var refreshTrigger = UUID()
    
    private let categories = ["All", "Politics", "Technology", "Economy", "Culture", "Sports", "General"]
    private let countries = [
        ("All", "🌍"),
        ("Estonia", "🇪🇪"),
        ("Latvia", "🇱🇻"),
        ("Lithuania", "🇱🇹"),
        ("Finland", "🇫🇮")
    ]
    
    var filteredArticles: [Article] {
        var articles = newsRepository.articles
        
        // Filter by category
        if selectedCategory != "All" {
            articles = articles.filter { $0.category.lowercased().contains(selectedCategory.lowercased()) }
        }
        
        // Filter by country - Temporarily disabled
        // if selectedCountry != "All" {
        //     articles = articles.filter { $0.region == selectedCountry }
        // }
        
        // Filter by search text
        if !searchText.isEmpty {
            articles = articles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.content.localizedCaseInsensitiveContains(searchText) ||
                article.summary.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return articles.sorted { 
            parseDate(from: $0.publishedAt) ?? Date.distantPast > 
            parseDate(from: $1.publishedAt) ?? Date.distantPast 
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Category Tabs
                categoryTabsSection
                
                // Main Content
                contentSection
                
                // Bottom Navigation Bar
                bottomNavigationBar
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .refreshable {
                await refreshContent()
            }
            .sheet(isPresented: $showingDailyDigest) {
                DailyDigestView(articles: newsRepository.getDailyDigest())
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(
                    articles: newsRepository.articles,
                    bookmarkManager: bookmarkManager
                )
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .task {
                await loadInitialContent()
            }
        }
    }
    
    // MARK: - Category Tabs Section
    
    private var categoryTabsSection: some View {
        VStack(spacing: 0) {
            // Category Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(categories, id: \.self) { category in
                        CategoryTabButton(
                            title: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            Divider()
        }
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        Group {
            if newsRepository.isLoading && newsRepository.articles.isEmpty {
                loadingView
            } else if filteredArticles.isEmpty {
                emptyStateView
            } else {
                articlesGrid
            }
        }
        .id(refreshTrigger)
    }
    
    private var articlesGrid: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(
                    columns: adaptiveGridColumns(for: geometry.size.width),
                    spacing: 12,
                    content: {
                        ForEach(filteredArticles) { article in
                            NavigationLink(destination: ArticleDetailView(article: convertToCache(article))) {
                                NewsCardView(
                                    article: article,
                                    isBookmarked: .constant(bookmarkManager.isBookmarked(article.id)),
                                    onTap: {},
                                    onBookmarkToggle: {
                                        bookmarkManager.toggleBookmark(for: article.id)
                                    }
                                )
                                .frame(maxWidth: .infinity)
                                .aspectRatio(0.75, contentMode: .fit) // Consistent aspect ratio
                            }
                            .buttonStyle(.plain)
                        }
                    }
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 100) // Bottom bar space
            }
        }
    }
    
    private func adaptiveGridColumns(for width: CGFloat) -> [GridItem] {
        let minCardWidth: CGFloat = 160
        let spacing: CGFloat = 12
        let horizontalPadding: CGFloat = 24
        
        let availableWidth = width - horizontalPadding
        let columns = max(1, Int(availableWidth / (minCardWidth + spacing)))
        
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
    }
    
    // MARK: - Bottom Navigation Bar
    
    private var bottomNavigationBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 30) {
                // Country Selector - Temporarily disabled
                // countrySelector
                
                Spacer()
                
                // Search Button
                Button(action: { showingSearch = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                        Text("Search")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                
                // Daily Digest AI+ Button
                Button(action: { showingDailyDigest = true }) {
                    VStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                        Text("AI+")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.purple)
                }
                
                // Bookmarks Button
                NavigationLink(destination: BookmarksView()) {
                    VStack(spacing: 4) {
                        Image(systemName: "bookmark.fill")
                            .font(.title2)
                        Text("Saved")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }
    
    private var countrySelector: some View {
        Menu {
            ForEach(countries, id: \.0) { country, flag in
                Button(action: {
                    selectedCountry = country
                }) {
                    HStack {
                        Text(flag)
                        Text(country)
                        if selectedCountry == country {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(countries.first { $0.0 == selectedCountry }?.1 ?? "🌍")
                    .font(.title2)
                Text(selectedCountry)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.primary)
        }
    }
    
    // MARK: - Loading & Empty States
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading latest news...")
                .font(.subheadline)
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

// MARK: - Category Tab Button

struct CategoryTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isSelected ? Color.blue : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainGridView()
}
