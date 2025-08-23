//
//  NewsDetailView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct NewsDetailView: View {
    let article: NewsArticle
    @State private var isBookmarked: Bool
    @State private var fontSize: Double = 16.0
    @Environment(\.dismiss) private var dismiss
    
    init(article: NewsArticle) {
        self.article = article
        self._isBookmarked = State(initialValue: article.isBookmarked)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                headerImage
                
                VStack(alignment: .leading, spacing: 16) {
                    // Article Meta
                    articleMeta
                    
                    // Title
                    Text(article.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(nil)
                        .dynamicTypeSize(.large)
                    
                    // Summary
                    Text(article.summary)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                    
                    // Content
                    Text(article.content)
                        .font(.body)
                        .lineLimit(nil)
                        .dynamicTypeSize(.large)
                    
                    // Author Info
                    authorInfo
                    
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
                    Button(action: toggleBookmark) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isBookmarked ? .blue : .gray)
                    }
                    
                    Button(action: shareArticle) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            markAsRead()
        }
    }
    
    private var headerImage: some View {
        Group {
            if let imageURL = article.imageURL, !imageURL.isEmpty {
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
    
    private var articleMeta: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Category Badge
                Text(article.category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(categoryColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                
                Spacer()
                
                // Published Date
                Text(publishedDateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var authorInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            HStack {
                Image(systemName: "person.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("By \(article.author)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Published \(timeAgoString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.top, 20)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: toggleBookmark) {
                HStack {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    Text(isBookmarked ? "Bookmarked" : "Bookmark")
                }
                .font(.headline)
                .foregroundColor(isBookmarked ? .blue : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(isBookmarked ? Color.blue : Color(.systemGray4), lineWidth: 2)
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
        }
        .padding(.top, 20)
    }
    
    private var categoryColor: Color {
        switch article.category {
        case "Technology":
            return .red
        case "Business":
            return .green
        case "Sports":
            return .blue
        case "Entertainment":
            return .purple
        case "Science":
            return .orange
        default:
            return .gray
        }
    }
    
    private var publishedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: article.publishedAt)
    }
    
    private var timeAgoString: String {
        let timeInterval = Date().timeIntervalSince(article.publishedAt)
        
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
    
    private func toggleBookmark() {
        isBookmarked.toggle()
        // TODO: Update article bookmark status in database
    }
    
    private func shareArticle() {
        let shareText = "\(article.title)\n\n\(article.summary)\n\nRead more in MagiNews app!"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func markAsRead() {
        // TODO: Mark article as read in database
        print("Article marked as read: \(article.title)")
    }
}

#Preview {
    let sampleArticle = NewsArticle(
        title: "iOS 18 Features Announced: Revolutionary AI Integration and Enhanced Privacy",
        content: "Apple has announced the latest iOS 18 with groundbreaking features that will transform how users interact with their devices. The new update introduces advanced AI capabilities, enhanced privacy features, and a completely redesigned user interface.\n\nKey features include:\n• Siri with advanced AI understanding\n• Enhanced privacy controls\n• Redesigned home screen\n• Improved performance and battery life\n\nThis update represents Apple's most significant iOS release in years, focusing on user experience and security.",
        summary: "Apple's latest iOS 18 brings revolutionary AI capabilities and enhanced privacy features, marking the most significant update in years.",
        author: "Sarah Johnson",
        publishedAt: Date().addingTimeInterval(-7200),
        category: "Technology"
    )
    
    return NavigationView {
        NewsDetailView(article: sampleArticle)
    }
}
