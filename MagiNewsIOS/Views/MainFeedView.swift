//
//  MainFeedView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct MainFeedView: View {
    @StateObject private var rssService = RSSService()
    @StateObject private var offlineCache = OfflineCache()
    @StateObject private var bookmarkManager = BookmarkManager()
    
    @State private var selectedCategory: String = "All"
    @State private var searchText = ""
    @State private var showingDailyDigest = false
    @State private var isLoading = false
    @State private var refreshTrigger = UUID()
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    private let categories = ["All", "Politics", "Technology", "Business", "Culture", "Sports"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Daily Digest Header
                headerSection
                
                // Category Filter Tabs
                categoryFilterSection
                
                // Main Content
                mainContentSection
            }
            .background(backgroundColor)
            .navigationTitle("MagiNews")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    languagePicker
                    themeToggle
                }
            }
        }
        .sheet(isPresented: $showingDailyDigest) {
            DailyDigestView(articles: offlineCache.cachedArticles)
        }
        .onAppear {
            loadInitialData()
        }
        .refreshable {
            await refreshData()
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
            .background(searchBarBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            
            // Daily Digest Button
            Button(action: {
                showingDailyDigest = true
            }) {
                HStack {
                    Image(systemName: "newspaper.fill")
                        .foregroundColor(.white)
                    Text("Daily Digest")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Category Filter Section
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryFilterButton(
                        title: category,
                        isSelected: selectedCategory == category,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Main Content Section
    
    private var mainContentSection: some View {
        Group {
            if isLoading {
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
        ScrollView {
            LazyVGrid(
                columns: gridColumns,
                spacing: 20,
                content: {
                    ForEach(filteredArticles) { article in
                        NewsCardView(
                            article: article,
                            isBookmarked: .constant(bookmarkManager.isBookmarked(article.id)),
                            onTap: {
                                // Navigate to article detail
                            },
                            onBookmarkToggle: {
                                bookmarkManager.toggleBookmark(for: article.id)
                            }
                        )
                        .padding(.horizontal, horizontalSizeClass == .compact ? 20 : 0)
                    }
                }
            )
            .padding(.horizontal, horizontalSizeClass == .compact ? 0 : 20)
            .padding(.bottom, 20)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading news...")
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
            
            Text("No news available")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try refreshing or check your internet connection")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Refresh") {
                Task {
                    await refreshData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Toolbar Items
    
    private var languagePicker: some View {
        Menu {
            ForEach(SupportedLanguage.allCases, id: \.rawValue) { language in
                Button(action: {
                    // Handle language change
                }) {
                    HStack {
                        Text(language.flag)
                        Text(language.displayName)
                        if language.rawValue == "en" {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "globe")
                .font(.title3)
        }
    }
    
    private var themeToggle: some View {
        Button(action: {
            // Handle theme toggle
        }) {
            Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                .font(.title3)
        }
    }
    
    // MARK: - Computed Properties
    
    private var gridColumns: [GridItem] {
        switch horizontalSizeClass {
        case .compact:
            return [GridItem(.flexible())]
        case .regular:
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        default:
            return [GridItem(.flexible())]
        }
    }
    
    private var filteredArticles: [CachedArticle] {
        var articles = offlineCache.cachedArticles
        
        // Filter by category
        if selectedCategory != "All" {
            articles = articles.filter { article in
                article.rssItem.category?.lowercased().contains(selectedCategory.lowercased()) == true
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            articles = articles.filter { article in
                article.rssItem.title.localizedCaseInsensitiveContains(searchText) ||
                article.rssItem.description.localizedCaseInsensitiveContains(searchText) ||
                (article.summary?.localizedCaseInsensitiveContains(searchText) == true)
            }
        }
        
        return articles
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground) : Color(.systemGroupedBackground)
    }
    
    private var searchBarBackground: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
    }
    
    // MARK: - Data Loading Methods
    
    private func loadInitialData() {
        isLoading = true
        
        Task {
            do {
                try await rssService.fetchAllFeeds()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func refreshData() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            try await rssService.fetchAllFeeds()
            await MainActor.run {
                isLoading = false
                refreshTrigger = UUID()
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// MARK: - Category Filter Button

struct CategoryFilterButton: View {
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
                .background(isSelected ? buttonSelectedBackground : buttonBackground)
                .foregroundColor(isSelected ? buttonSelectedText : buttonText)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
    
    private var buttonBackground: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
    }
    
    private var buttonSelectedBackground: Color {
        Color.blue
    }
    
    private var buttonText: Color {
        colorScheme == .dark ? .white : .primary
    }
    
    private var buttonSelectedText: Color {
        .white
    }
}

// MARK: - Preview

#Preview("iPhone") {
    MainFeedView()
        .preferredColorScheme(.light)
}

#Preview("iPad") {
    MainFeedView()
        .preferredColorScheme(.dark)
        .environment(\.horizontalSizeClass, .regular)
}
