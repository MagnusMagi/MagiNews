//
//  ArticleDetailView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: CachedArticle
    @StateObject private var summarizationService = SummarizationService()
    @State private var aiSummary: String = ""
    @State private var isGeneratingSummary = false
    @State private var showingTranslation = false
    @State private var translatedContent: String = ""
    @State private var isTranslating = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                headerImage
                
                VStack(alignment: .leading, spacing: 16) {
                    // Article Meta
                    articleMeta
                    
                    // Title
                    Text(article.rssItem.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(nil)
                        .dynamicTypeSize(.large)
                    
                    // AI Summary
                    if !aiSummary.isEmpty {
                        aiSummarySection
                    }
                    
                    // Content
                    Text(article.rssItem.description)
                        .font(.body)
                        .lineLimit(nil)
                        .dynamicTypeSize(.large)
                        .lineSpacing(4)
                    
                    // Source Information
                    sourceInfo
                    
                    // Action Buttons
                    actionButtons
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: generateAISummary) {
                        Image(systemName: isGeneratingSummary ? "sparkles" : "sparkles")
                            .foregroundColor(isGeneratingSummary ? .orange : .blue)
                    }
                    .disabled(isGeneratingSummary)
                    
                    Button(action: { showingTranslation = true }) {
                        Image(systemName: "translate")
                    }
                }
            }
        }
        .sheet(isPresented: $showingTranslation) {
            TranslationView(
                content: article.rssItem.description,
                sourceLanguage: article.language,
                targetLanguage: "English"
            )
        }
        .onAppear {
            if aiSummary.isEmpty {
                generateAISummary()
            }
        }
    }
    
    // MARK: - Header Image
    private var headerImage: some View {
        Group {
            if let imageURL = article.rssItem.imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 250)
                .clipped()
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 250)
                    .overlay(
                        VStack {
                            Image(systemName: "newspaper")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No Image Available")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
        }
    }
    
    // MARK: - Article Meta
    private var articleMeta: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Category Badge
                if let category = article.rssItem.category {
                    Text(category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(categoryColor(for: category))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                
                Spacer()
                
                // Published Date
                Text(publishedDateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - AI Summary Section
    private var aiSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("AI Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(aiSummary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(16)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Source Info
    private var sourceInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Source")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(article.source)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Region")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(article.region)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Language")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(article.language)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Published")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(timeAgoString)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: bookmarkArticle) {
                HStack {
                    Image(systemName: "bookmark")
                    Text("Bookmark")
                }
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
            }
            
            Button(action: shareArticle) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
            }
            
            Button(action: openInBrowser) {
                HStack {
                    Image(systemName: "safari")
                    Text("Open")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Methods
    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case let cat where cat.contains("politics"):
            return Color(hex: "#FF6B6B")
        case let cat where cat.contains("economy") || cat.contains("business"):
            return Color(hex: "#4ECDC4")
        case let cat where cat.contains("culture"):
            return Color(hex: "#45B7D1")
        case let cat where cat.contains("technology"):
            return Color(hex: "#96CEB4")
        case let cat where cat.contains("sports"):
            return Color(hex: "#FFEAA7")
        default:
            return Color.blue
        }
    }
    
    private var publishedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: article.cachedAt)
    }
    
    private var timeAgoString: String {
        let timeInterval = Date().timeIntervalSince(article.cachedAt)
        
        if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minutes ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hours ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days) days ago"
        }
    }
    
    // MARK: - Actions
    private func generateAISummary() {
        isGeneratingSummary = true
        
        Task {
            do {
                let summary = try await summarizationService.summarizeArticle(
                    article.rssItem.description,
                    language: "English"
                )
                
                await MainActor.run {
                    aiSummary = summary
                    isGeneratingSummary = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGeneratingSummary = false
                }
            }
        }
    }
    
    private func bookmarkArticle() {
        // TODO: Implement bookmark functionality
        print("Bookmarking article: \(article.rssItem.title)")
    }
    
    private func shareArticle() {
        let shareText = """
        \(article.rssItem.title)
        
        \(article.rssItem.description)
        
        Read more in MagiNews app!
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func openInBrowser() {
        if let url = URL(string: article.rssItem.link) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Translation View
struct TranslationView: View {
    let content: String
    let sourceLanguage: String
    let targetLanguage: String
    
    @StateObject private var summarizationService = SummarizationService()
    @State private var translatedText = ""
    @State private var isTranslating = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isTranslating {
                    loadingView
                } else if !translatedText.isEmpty {
                    translationResult
                } else {
                    initialView
                }
            }
            .navigationTitle("Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !translatedText.isEmpty {
                        Button(action: shareTranslation) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .onAppear {
                if translatedText.isEmpty {
                    translateContent()
                }
            }
        }
    }
    
    private var initialView: some View {
        VStack(spacing: 24) {
            Image(systemName: "translate")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Translating to \(targetLanguage)")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Please wait while we translate the content...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Translating...")
                .font(.headline)
                .fontWeight(.medium)
            
            Text("Converting from \(sourceLanguage) to \(targetLanguage)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var translationResult: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Original text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Original (\(sourceLanguage))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(content)
                        .font(.body)
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Translated text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Translation (\(targetLanguage))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(translatedText)
                        .font(.body)
                        .padding(16)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: translateContent) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Retranslate")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(25)
                    }
                    
                    Button(action: shareTranslation) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                }
            }
            .padding(24)
        }
    }
    
    private func translateContent() {
        isTranslating = true
        
        Task {
            do {
                let translation = try await summarizationService.translateArticle(
                    content,
                    from: sourceLanguage,
                    to: targetLanguage
                )
                
                await MainActor.run {
                    translatedText = translation
                    isTranslating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isTranslating = false
                }
            }
        }
    }
    
    private func shareTranslation() {
        let shareText = """
        Translation from \(sourceLanguage) to \(targetLanguage):
        
        Original:
        \(content)
        
        Translation:
        \(translatedText)
        
        Translated with MagiNews app!
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    let sampleArticle = CachedArticle(
        rssItem: RSSItem(
            title: "Sample Article Title",
            link: "https://example.com",
            description: "This is a sample article description for testing purposes.",
            pubDate: "2025-08-24",
            category: "Technology",
            imageURL: nil
        ),
        summary: nil,
        translatedTitle: nil,
        translatedSummary: nil,
        cachedAt: Date(),
        source: "ERR.ee",
        region: "Estonia",
        language: "Estonian"
    )
    
    return NavigationView {
        ArticleDetailView(article: sampleArticle)
    }
}
