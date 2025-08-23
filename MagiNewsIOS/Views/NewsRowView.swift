//
//  NewsRowView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct NewsRowView: View {
    let article: NewsArticle
    @State private var isBookmarked: Bool
    
    init(article: NewsArticle) {
        self.article = article
        self._isBookmarked = State(initialValue: article.isBookmarked)
    }
    
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
                    // Category Badge
                    HStack {
                        Text(article.category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(categoryColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        
                        Spacer()
                        
                        Button(action: toggleBookmark) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .foregroundColor(isBookmarked ? .blue : .gray)
                        }
                    }
                    
                    // Title
                    Text(article.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    // Summary
                    Text(article.summary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Meta Information
                    HStack {
                        Text(article.author)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        switch article.category {
        case "Technology":
            return Color(hex: "#FF6B6B")
        case "Business":
            return Color(hex: "#4ECDC4")
        case "Sports":
            return Color(hex: "#45B7D1")
        case "Entertainment":
            return Color(hex: "#96CEB4")
        case "Science":
            return Color(hex: "#FFEAA7")
        default:
            return Color.blue
        }
    }
    
    private var timeAgoString: String {
        let timeInterval = Date().timeIntervalSince(article.publishedAt)
        
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
    
    private func toggleBookmark() {
        isBookmarked.toggle()
        // TODO: Update article bookmark status in database
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    let sampleArticle = NewsArticle(
        title: "iOS 18 Features Announced",
        content: "Apple has announced the latest iOS 18 with groundbreaking features...",
        summary: "New AI capabilities and enhanced privacy features",
        author: "Tech Reporter",
        publishedAt: Date(),
        category: "Technology"
    )
    
    return NewsRowView(article: sampleArticle)
        .padding()
        .background(Color(.systemGray6))
}
