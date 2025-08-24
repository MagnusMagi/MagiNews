//
//  NewsCardView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct NewsCardView: View {
    let article: Article
    @Binding var isBookmarked: Bool
    let onTap: () -> Void
    let onBookmarkToggle: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section with consistent aspect ratio
            imageSection
            
            // Content Section
            VStack(alignment: .leading, spacing: 12) {
                // Header with Category and Bookmark
                HStack {
                    CategoryBadge(category: article.category)
                    
                    Spacer()
                    
                    BookmarkButton(
                        isBookmarked: $isBookmarked,
                        onToggle: onBookmarkToggle
                    )
                }
                
                // Title
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(3)
                    .foregroundColor(primaryTextColor)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Summary (only for larger cards)
                if horizontalSizeClass == .regular {
                    Text(article.summary)
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
                
                // Footer with Source and Time
                HStack {
                    Text(article.source)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(timeAgoString)
                        .font(.caption2)
                        .foregroundColor(tertiaryTextColor)
                }
            }
            .padding(16)
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
    
    private var imageSection: some View {
        ZStack {
            if let imageURL = article.imageURL, !imageURL.isEmpty, imageURL != "null", imageURL.isValidURL {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .clipped()
                            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    case .failure(_):
                        defaultThumbnail
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemGray6))
                    @unknown default:
                        defaultThumbnail
                    }
                }
            } else {
                defaultThumbnail
            }
        }
        .frame(height: 120)
        .aspectRatio(16/9, contentMode: .fit)
        .clipped()
    }
    
    private var defaultThumbnail: some View {
        Rectangle()
            .fill(Color(.systemGray6))
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "newspaper")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text(article.category.prefix(1).uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            )
    }
    
    private var timeAgoString: String {
        return article.timeAgo
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
                article: Article(
                    title: "Estonia Leads Digital Innovation in Baltics",
                    content: "Estonia continues to be a pioneer in digital transformation, setting new standards for e-governance and digital services across the Baltic region.",
                    summary: "Estonia's digital leadership in the Baltic region continues to grow with new initiatives in e-governance and digital services.",
                    author: "Tech Reporter",
                    publishedAt: "Mon, 24 Aug 2025 10:00:00 +0000",
                    imageURL: nil,
                    category: "Technology",
                    source: "ERR.ee",
                    region: "Estonia",
                    language: "en",
                    link: "https://example.com"
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
                article: Article(
                    title: "Nordic Council Meeting Discusses Climate Policy",
                    content: "The Nordic Council held an important meeting about climate change policies and sustainable development goals for the region.",
                    summary: "Nordic countries align on new climate initiatives and sustainable development goals.",
                    author: "Political Correspondent",
                    publishedAt: "Mon, 24 Aug 2025 10:00:00 +0000",
                    imageURL: nil,
                    category: "Politics",
                    source: "Postimees.ee",
                    region: "Estonia",
                    language: "en",
                    link: "https://example.com"
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
