//
//  DailyDigestView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct DailyDigestView: View {
    let articles: [CachedArticle]
    @StateObject private var summarizationService = SummarizationService()
    @State private var digestSummary: String = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isGenerating {
                    loadingView
                } else if !digestSummary.isEmpty {
                    digestContentView
                } else {
                    initialView
                }
            }
            .navigationTitle("Daily Digest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !digestSummary.isEmpty {
                        Button(action: shareDigest) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .onAppear {
                if digestSummary.isEmpty && !articles.isEmpty {
                    generateDigest()
                }
            }
        }
    }
    
    // MARK: - Initial View
    private var initialView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Daily News Digest")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("AI-powered summary of today's top stories")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Articles preview
            VStack(alignment: .leading, spacing: 16) {
                Text("Top Stories")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ForEach(articles.prefix(5)) { article in
                    HStack {
                        Text("•")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                        
                        Text(article.rssItem.title)
                            .font(.subheadline)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Text(article.source)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Generate button
            Button(action: generateDigest) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate AI Summary")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            }
            .disabled(articles.isEmpty)
            
            Spacer()
        }
        .padding(24)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Generating your daily digest...")
                .font(.headline)
                .fontWeight(.medium)
            
            Text("Our AI is analyzing the top stories and creating a comprehensive summary")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Progress animation
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: index
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Digest Content View
    private var digestContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("AI Generated Summary")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Here's what's happening in the Baltic and Nordic regions today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Summary content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Overview")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(digestSummary)
                        .font(.body)
                        .lineSpacing(4)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Key stories
                VStack(alignment: .leading, spacing: 16) {
                    Text("Key Stories")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    ForEach(articles.prefix(5)) { article in
                        HStack(alignment: .top, spacing: 12) {
                            // Story number
                            Text("\(articles.firstIndex(of: article)! + 1)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .frame(width: 30, height: 30)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(article.rssItem.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(3)
                                
                                HStack {
                                    Text(article.source)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    
                                    Text(article.region)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: regenerateDigest) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Regenerate Summary")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(25)
                    }
                    
                    Button(action: shareDigest) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Digest")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                }
                .padding(.top, 16)
            }
            .padding(24)
        }
    }
    
    // MARK: - Actions
    private func generateDigest() {
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                let rssItems = articles.map { $0.rssItem }
                let summary = try await summarizationService.generateDailyDigest(rssItems)
                
                await MainActor.run {
                    digestSummary = summary
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGenerating = false
                }
            }
        }
    }
    
    private func regenerateDigest() {
        digestSummary = ""
        generateDigest()
    }
    
    private func shareDigest() {
        let shareText = """
        📰 MagiNews Daily Digest
        
        \(digestSummary)
        
        Read the full stories in MagiNews app!
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    let sampleArticles = [
        CachedArticle(
            rssItem: RSSItem(
                title: "Sample Article 1",
                link: "https://example.com",
                description: "Sample description",
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
    ]
    
    return DailyDigestView(articles: sampleArticles)
}
