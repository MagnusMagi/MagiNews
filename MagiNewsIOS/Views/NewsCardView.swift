//
//  NewsCardView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct NewsCardView: View {
    let article: CachedArticle
    @Binding var isBookmarked: Bool
    let onTap: () -> Void
    let onBookmarkToggle: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
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
                                .font(.title2)
                                .foregroundColor(.secondary)
                        )
                }
                .frame(height: horizontalSizeClass == .compact ? 200 : 240)
                .clipped()
            }
            
            // Content Section
            VStack(alignment: .leading, spacing: 16) {
                // Header with Category and Bookmark
                HStack {
                    CategoryBadge(category: article.rssItem.category ?? "General")
                    Spacer()
                    BookmarkButton(
                        isBookmarked: $isBookmarked,
                        onToggle: onBookmarkToggle
                    )
                }
                
                // Title
                Text(article.rssItem.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .foregroundColor(primaryTextColor)
                
                // Summary
                if let summary = article.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.subheadline)
                        .lineLimit(3)
                        .foregroundColor(secondaryTextColor)
                } else {
                    Text(article.rssItem.description)
                        .font(.subheadline)
                        .lineLimit(3)
                        .foregroundColor(secondaryTextColor)
                }
                
                // Footer with Source and Time
                HStack {
                    Text(article.source)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(timeAgoString)
                        .font(.caption)
                        .foregroundColor(tertiaryTextColor)
                }
            }
            .padding(20)
        }
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: shadowColor,
            radius: 8,
            x: 0,
            y: 4
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
            }
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - Computed Properties
    
    private var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        
        if let date = parseDate(from: article.rssItem.pubDate) {
            return formatter.localizedString(for: date, relativeTo: Date())
        }
        return "Just now"
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? .gray : .secondary
    }
    
    private var tertiaryTextColor: Color {
        colorScheme == .dark ? .gray.opacity(0.7) : .secondary.opacity(0.7)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : .white
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.1)
    }
    
    // MARK: - Helper Methods
    
    private func parseDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.date(from: dateString)
    }
}

// MARK: - Category Badge Component

struct CategoryBadge: View {
    let category: String
    
    var body: some View {
        Text(category)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var categoryColor: Color {
        switch category.lowercased() {
        case let cat where cat.contains("politics"):
            return .red
        case let cat where cat.contains("economy") || cat.contains("business"):
            return .green
        case let cat where cat.contains("culture"):
            return .blue
        case let cat where cat.contains("technology"):
            return .purple
        case let cat where cat.contains("sports"):
            return .orange
        default:
            return .gray
        }
    }
}

// MARK: - Bookmark Button Component

struct BookmarkButton: View {
    @Binding var isBookmarked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isBookmarked.toggle()
                onToggle()
            }
        }) {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.title3)
                .foregroundColor(isBookmarked ? .blue : .secondary)
                .scaleEffect(isBookmarked ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    ScrollView {
        LazyVStack(spacing: 20) {
            NewsCardView(
                article: CachedArticle(
                    rssItem: RSSItem(
                        title: "Estonia Leads Digital Innovation in Baltics",
                        link: "https://example.com",
                        description: "Estonia continues to be a pioneer in digital transformation, setting new standards for e-governance and digital services across the Baltic region.",
                        pubDate: "Mon, 24 Aug 2025 10:00:00 +0000",
                        category: "Technology",
                        imageURL: nil
                    ),
                    summary: "Estonia's digital leadership in the Baltic region continues to grow with new initiatives in e-governance and digital services.",
                    translatedTitle: nil,
                    translatedSummary: nil,
                    cachedAt: Date(),
                    source: "ERR.ee",
                    region: "Estonia",
                    language: "Estonian"
                ),
                isBookmarked: .constant(false),
                onTap: {},
                onBookmarkToggle: {}
            )
            .padding(.horizontal, 20)
        }
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Dark Mode") {
    ScrollView {
        LazyVStack(spacing: 20) {
            NewsCardView(
                article: CachedArticle(
                    rssItem: RSSItem(
                        title: "Nordic Council Meeting Discusses Climate Policy",
                        link: "https://example.com",
                        description: "The Nordic Council held an important meeting about climate change policies and sustainable development goals for the region.",
                        pubDate: "Mon, 24 Aug 2025 09:30:00 +0000",
                        category: "Politics",
                        imageURL: nil
                    ),
                    summary: "Nordic countries align on new climate initiatives and sustainable development goals.",
                    translatedTitle: nil,
                    translatedSummary: nil,
                    cachedAt: Date(),
                    source: "Postimees.ee",
                    region: "Estonia",
                    language: "Estonian"
                ),
                isBookmarked: .constant(true),
                onTap: {},
                onBookmarkToggle: {}
            )
            .padding(.horizontal, 20)
        }
    }
    .background(Color(.systemGroupedBackground))
    .preferredColorScheme(.dark)
}
