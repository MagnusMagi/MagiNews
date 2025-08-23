//
//  HomeView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var articles: [NewsArticle]
    @Query private var categories: [NewsCategory]
    @State private var selectedCategory: String = "All"
    @State private var searchText = ""
    
    var filteredArticles: [NewsArticle] {
        if selectedCategory == "All" {
            return articles.filter { article in
                searchText.isEmpty || article.title.localizedCaseInsensitiveContains(searchText)
            }
        } else {
            return articles.filter { article in
                article.category == selectedCategory &&
                (searchText.isEmpty || article.title.localizedCaseInsensitiveContains(searchText))
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Category Picker
                categoryPicker
                
                // News List
                newsList
            }
            .navigationTitle("MagiNews")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshNews) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            setupInitialData()
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search news...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(["All"] + categories.map { $0.name }, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.blue : Color(.systemGray5))
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
    }
    
    private var newsList: some View {
        List {
            ForEach(filteredArticles) { article in
                NavigationLink(destination: NewsDetailView(article: article)) {
                    NewsRowView(article: article)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            refreshNews()
        }
    }
    
    private func setupInitialData() {
        if categories.isEmpty {
            let defaultCategories = [
                NewsCategory(name: "Technology", color: "#FF6B6B", icon: "laptopcomputer"),
                NewsCategory(name: "Business", color: "#4ECDC4", icon: "chart.line.uptrend.xyaxis"),
                NewsCategory(name: "Sports", color: "#45B7D1", icon: "sportscourt"),
                NewsCategory(name: "Entertainment", color: "#96CEB4", icon: "tv"),
                NewsCategory(name: "Science", color: "#FFEAA7", icon: "atom")
            ]
            
            for category in defaultCategories {
                modelContext.insert(category)
            }
        }
        
        if articles.isEmpty {
            let sampleArticles = [
                NewsArticle(
                    title: "iOS 18 Features Announced",
                    content: "Apple has announced the latest iOS 18 with groundbreaking features...",
                    summary: "New AI capabilities and enhanced privacy features",
                    author: "Tech Reporter",
                    publishedAt: Date(),
                    category: "Technology"
                ),
                NewsArticle(
                    title: "Global Markets Update",
                    content: "Major indices show positive momentum as investors...",
                    summary: "Positive trends in global financial markets",
                    author: "Business Analyst",
                    publishedAt: Date().addingTimeInterval(-3600),
                    category: "Business"
                )
            ]
            
            for article in sampleArticles {
                modelContext.insert(article)
            }
        }
    }
    
    private func refreshNews() {
        // TODO: Implement API refresh
        print("Refreshing news...")
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [NewsArticle.self, NewsCategory.self], inMemory: true)
}
