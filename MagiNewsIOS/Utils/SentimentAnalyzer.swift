import Foundation
import SwiftUI

// MARK: - Sentiment Analyzer
@MainActor
class SentimentAnalyzer: ObservableObject {
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    
    private let summarizationService: SummarizationService
    
    init(summarizationService: SummarizationService) {
        self.summarizationService = summarizationService
    }
    
    // MARK: - Main Sentiment Analysis
    func analyzeSentiment(title: String, summary: String) async -> SentimentResult? {
        isAnalyzing = true
        errorMessage = nil
        
        defer { isAnalyzing = false }
        
        let sentiment = await summarizationService.analyzeSentiment(title: title, summary: summary)
        return sentiment
    }
    
    // MARK: - Batch Sentiment Analysis
    func analyzeMultipleArticles(_ articles: [Article]) async -> [SentimentResult?] {
        var sentiments: [SentimentResult?] = []
        
        for article in articles {
            let sentiment = await analyzeSentiment(title: article.title, summary: article.summary)
            sentiments.append(sentiment)
        }
        
        return sentiments
    }
    
    // MARK: - Sentiment Trends
    func analyzeSentimentTrends(_ articles: [Article]) async -> SentimentTrends {
        let sentiments = await analyzeMultipleArticles(articles)
        
        var positiveCount = 0
        var negativeCount = 0
        var neutralCount = 0
        
        for sentiment in sentiments {
            switch sentiment {
            case .positive:
                positiveCount += 1
            case .negative:
                negativeCount += 1
            case .neutral:
                neutralCount += 1
            case .none:
                neutralCount += 1
            }
        }
        
        let total = sentiments.count
        let positivePercentage = total > 0 ? Double(positiveCount) / Double(total) * 100 : 0
        let negativePercentage = total > 0 ? Double(negativeCount) / Double(total) * 100 : 0
        let neutralPercentage = total > 0 ? Double(neutralCount) / Double(total) * 100 : 0
        
        return SentimentTrends(
            positiveCount: positiveCount,
            negativeCount: negativeCount,
            neutralCount: neutralCount,
            positivePercentage: positivePercentage,
            negativePercentage: negativePercentage,
            neutralPercentage: neutralPercentage,
            overallMood: determineOverallMood(positive: positivePercentage, negative: negativePercentage)
        )
    }
    
    // MARK: - Sentiment Categories
    func categorizeArticlesBySentiment(_ articles: [Article]) async -> [SentimentResult: [Article]] {
        var categorized: [SentimentResult: [Article]] = [:]
        
        for article in articles {
            let sentiment = await analyzeSentiment(title: article.title, summary: article.summary) ?? .neutral
            
            if categorized[sentiment] == nil {
                categorized[sentiment] = []
            }
            categorized[sentiment]?.append(article)
        }
        
        return categorized
    }
    
    // MARK: - Private Methods
    private func determineOverallMood(positive: Double, negative: Double) -> OverallMood {
        if positive > 60 {
            return .veryPositive
        } else if positive > 40 {
            return .positive
        } else if negative > 60 {
            return .veryNegative
        } else if negative > 40 {
            return .negative
        } else {
            return .neutral
        }
    }
}

// MARK: - Supporting Types
struct SentimentTrends {
    let positiveCount: Int
    let negativeCount: Int
    let neutralCount: Int
    let positivePercentage: Double
    let negativePercentage: Double
    let neutralPercentage: Double
    let overallMood: OverallMood
    
    var dominantSentiment: SentimentResult {
        if positivePercentage > negativePercentage && positivePercentage > neutralPercentage {
            return .positive
        } else if negativePercentage > positivePercentage && negativePercentage > neutralPercentage {
            return .negative
        } else {
            return .neutral
        }
    }
}

enum OverallMood: String, CaseIterable {
    case veryPositive = "very_positive"
    case positive = "positive"
    case neutral = "neutral"
    case negative = "negative"
    case veryNegative = "very_negative"
    
    var displayName: String {
        switch self {
        case .veryPositive: return "Very Positive"
        case .positive: return "Positive"
        case .neutral: return "Neutral"
        case .negative: return "Negative"
        case .veryNegative: return "Very Negative"
        }
    }
    
    var emoji: String {
        switch self {
        case .veryPositive: return "😄"
        case .positive: return "🙂"
        case .neutral: return "😐"
        case .negative: return "😔"
        case .veryNegative: return "😢"
        }
    }
    
    var color: Color {
        switch self {
        case .veryPositive: return .green
        case .positive: return .mint
        case .neutral: return .gray
        case .negative: return .orange
        case .veryNegative: return .red
        }
    }
}

// MARK: - Sentiment Result Extension
extension SentimentResult {
    var intensity: SentimentIntensity {
        switch self {
        case .positive: return .medium
        case .negative: return .medium
        case .neutral: return .low
        }
    }
    
    var description: String {
        switch self {
        case .positive: return "Positive news"
        case .negative: return "Negative news"
        case .neutral: return "Neutral news"
        }
    }
}

enum SentimentIntensity: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var opacity: Double {
        switch self {
        case .low: return 0.3
        case .medium: return 0.6
        case .high: return 1.0
        }
    }
}
