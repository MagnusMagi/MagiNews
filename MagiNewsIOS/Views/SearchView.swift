//
//  SearchView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct SearchView: View {
    let articles: [Article]
    let bookmarkManager: BookmarkManager
    
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    @State private var selectedCountry: String = "All"
    @Environment(\.dismiss) private var dismiss
    
    private let categories = ["All", "Politics", "Technology", "Economy", "Culture", "Sports", "General"]
    private let countries = ["All", "Estonia", "Latvia", "Lithuania", "Finland"]
    
    var filteredArticles: [Article] {
        var filtered = articles
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.content.localizedCaseInsensitiveContains(searchText) ||
                article.summary.localizedCaseInsensitiveContains(searchText) ||
                article.source.localizedCaseInsensitiveContains(searchText) ||
                article.region.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category.lowercased().contains(selectedCategory.lowercased()) }
        }
        
        // Filter by country
        if selectedCountry != "All" {
            filtered = filtered.filter { $0.region == selectedCountry }
        }
        
        return filtered.sorted { 
            parseDate(from: $0.publishedAt) ?? Date.distantPast > 
            parseDate(from: $1.publishedAt) ?? Date.distantPast 
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                searchHeader
                
                // Filters
                filterSection
                
                // Results
                resultsSection
            }
            .navigationTitle("Search News")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Search Header
    
    private var searchHeader: some View {
        VStack(spacing: 16) {
            // Search TextField
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search articles, sources, regions...", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                
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
            
            // Search Stats
            HStack {
                Text("\(filteredArticles.count) articles found")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !searchText.isEmpty {
                    Text("Searching: \"\(searchText)\"")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        FilterChip(
                            title: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Country Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(countries, id: \.self) { country in
                        FilterChip(
                            title: country,
                            isSelected: selectedCountry == country
                        ) {
                            selectedCountry = country
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Results Section
    
    private var resultsSection: some View {
        Group {
            if searchText.isEmpty && selectedCategory == "All" && selectedCountry == "All" {
                searchSuggestionsView
            } else if filteredArticles.isEmpty {
                noResultsView
            } else {
                searchResultsList
            }
        }
    }
    
    private var searchSuggestionsView: some View {
        VStack(spacing: 24) {
            // Recent Searches
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Searches")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(["Technology", "Politics", "Estonia", "Finland"], id: \.self) { suggestion in
                        Button(action: {
                            searchText = suggestion
                        }) {
                            Text(suggestion)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Popular Categories
            VStack(alignment: .leading, spacing: 12) {
                Text("Popular Categories")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(["Technology", "Politics", "Economy", "Culture"], id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack {
                                Image(systemName: categoryIcon(for: category))
                                    .foregroundColor(.blue)
                                Text(category)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No articles found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search terms or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Clear Filters") {
                searchText = ""
                selectedCategory = "All"
                selectedCountry = "All"
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    private var searchResultsList: some View {
        List {
            ForEach(filteredArticles) { article in
                NavigationLink(destination: ArticleDetailView(article: convertToCache(article))) {
                    SearchResultRow(
                        article: article,
                        isBookmarked: bookmarkManager.isBookmarked(article.id)
                    ) {
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
    
    // MARK: - Helper Methods
    
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "technology":
            return "laptopcomputer"
        case "politics":
            return "building.2"
        case "economy":
            return "chart.line.uptrend.xyaxis"
        case "culture":
            return "theatermasks"
        case "sports":
            return "sportscourt"
        default:
            return "newspaper"
        }
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

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let article: Article
    let isBookmarked: Bool
    let onBookmarkToggle: () -> Void
    
    var body: some View {
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
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "newspaper")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                // Source & Region
                HStack {
                    Text(article.source)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(article.region)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Bookmark Button
                    Button(action: onBookmarkToggle) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isBookmarked ? .orange : .secondary)
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView(
        articles: [],
        bookmarkManager: BookmarkManager()
    )
}
