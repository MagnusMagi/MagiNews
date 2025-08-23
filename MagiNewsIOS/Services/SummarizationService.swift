//
//  SummarizationService.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftUI

// MARK: - OpenAI API Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

struct OpenAIUsage: Codable {
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case totalTokens = "total_tokens"
    }
}

// MARK: - Summarization Service
@MainActor
class SummarizationService: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4"
    private let temperature = 0.7
    private let maxTokens = 150
    
    // Cache for AI responses to reduce API usage
    private let cache = NSCache<NSString, NSString>()
    
    init() {
        // Set cache limits
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Article Summarization
    func summarizeArticle(_ content: String, language: String = "en") async -> String? {
        let cacheKey = "summary_\(content.hash)_\(language)" as NSString
        
        // Check cache first
        if let cachedSummary = cache.object(forKey: cacheKey) {
            return cachedSummary as String
        }
        
        isProcessing = true
        errorMessage = nil
        
        defer { isProcessing = false }
        
        do {
            let prompt = createSummaryPrompt(content: content, language: language)
            let summary = try await makeOpenAIRequest(prompt: prompt)
            
            // Cache the result
            if let summary = summary {
                cache.setObject(summary as NSString, forKey: cacheKey)
            }
            
            return summary
        } catch {
            errorMessage = "Summarization failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Daily Digest Generation
    func generateDailyDigest(from articles: [Article], language: String = "en") async -> String? {
        let cacheKey = "digest_\(articles.map { $0.title }.joined().hash)_\(language)" as NSString
        
        // Check cache first
        if let cachedDigest = cache.object(forKey: cacheKey) {
            return cachedDigest as String
        }
        
        isProcessing = true
        errorMessage = nil
        
        defer { isProcessing = false }
        
        do {
            let prompt = createDigestPrompt(articles: articles, language: language)
            let digest = try await makeOpenAIRequest(prompt: prompt)
            
            // Cache the result
            if let digest = digest {
                cache.setObject(digest as NSString, forKey: cacheKey)
            }
            
            return digest
        } catch {
            errorMessage = "Daily digest generation failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Translation
    func translateArticle(_ content: String, to targetLanguage: String) async -> String? {
        let cacheKey = "translation_\(content.hash)_\(targetLanguage)" as NSString
        
        // Check cache first
        if let cachedTranslation = cache.object(forKey: cacheKey) {
            return cachedTranslation as String
        }
        
        isProcessing = true
        errorMessage = nil
        
        defer { isProcessing = false }
        
        do {
            let prompt = createTranslationPrompt(content: content, targetLanguage: targetLanguage)
            let translation = try await makeOpenAIRequest(prompt: prompt)
            
            // Cache the result
            if let translation = translation {
                cache.setObject(translation as NSString, forKey: cacheKey)
            }
            
            return translation
        } catch {
            errorMessage = "Translation failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Sentiment Analysis
    func analyzeSentiment(title: String, summary: String) async -> SentimentResult? {
        let cacheKey = "sentiment_\(title.hash)_\(summary.hash)" as NSString
        
        // Check cache first
        if let cachedResult = cache.object(forKey: cacheKey) {
            return SentimentResult(rawValue: cachedResult as String) ?? .neutral
        }
        
        isProcessing = true
        errorMessage = nil
        
        defer { isProcessing = false }
        
        do {
            let prompt = createSentimentPrompt(title: title, summary: summary)
            let result = try await makeOpenAIRequest(prompt: prompt)
            
            if let result = result {
                let sentiment = parseSentimentResult(result)
                // Cache the result
                cache.setObject(sentiment.rawValue as NSString, forKey: cacheKey)
                return sentiment
            }
            
            return nil
        } catch {
            errorMessage = "Sentiment analysis failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Private Methods
    private func makeOpenAIRequest(prompt: String) async throws -> String? {
        guard let apiKey = getOpenAIAPIKey() else {
            throw SummarizationError.missingAPIKey
        }
        
        let request = OpenAIRequest(
            model: model,
            messages: [OpenAIMessage(role: "user", content: prompt)],
            temperature: temperature,
            maxTokens: maxTokens
        )
        
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SummarizationError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw SummarizationError.apiError(statusCode: httpResponse.statusCode)
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return openAIResponse.choices.first?.message.content
    }
    
    private func createSummaryPrompt(content: String, language: String) -> String {
        let languageName = getLanguageDisplayName(language)
        return """
        Summarize the following news article in \(languageName). 
        Provide a concise, informative summary in 1-2 sentences (maximum 100 words).
        Focus on the key facts and main points.
        
        Article content:
        \(content)
        
        Summary in \(languageName):
        """
    }
    
    private func createDigestPrompt(articles: [Article], language: String) -> String {
        let languageName = getLanguageDisplayName(language)
        let articleTitles = articles.prefix(5).map { "- \($0.title)" }.joined(separator: "\n")
        
        return """
        Create a daily news digest in \(languageName) based on these top headlines.
        Provide a brief overview of each story in 1 sentence, then a 2-3 sentence summary of the most important story.
        Keep the total digest under 200 words.
        
        Headlines:
        \(articleTitles)
        
        Daily Digest in \(languageName):
        """
    }
    
    private func createTranslationPrompt(content: String, targetLanguage: String) -> String {
        let languageName = getLanguageDisplayName(targetLanguage)
        return """
        Translate the following text to \(languageName). 
        Maintain the original meaning and tone. If this is news content, ensure proper journalistic language.
        
        Text to translate:
        \(content)
        
        Translation in \(languageName):
        """
    }
    
    private func createSentimentPrompt(title: String, summary: String) -> String {
        return """
        Analyze the sentiment of this news article. 
        Respond with ONLY one word: "positive", "negative", or "neutral".
        
        Title: \(title)
        Summary: \(summary)
        
        Sentiment:
        """
    }
    
    private func parseSentimentResult(_ result: String) -> SentimentResult {
        let cleanResult = result.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if cleanResult.contains("positive") {
            return .positive
        } else if cleanResult.contains("negative") {
            return .negative
        } else {
            return .neutral
        }
    }
    
    private func getLanguageDisplayName(_ languageCode: String) -> String {
        switch languageCode {
        case "et": return "Estonian"
        case "lv": return "Latvian"
        case "lt": return "Lithuanian"
        case "fi": return "Finnish"
        default: return "English"
        }
    }
    
    private func getOpenAIAPIKey() -> String? {
        // In production, load from secure storage or environment variables
        // For development, check if user has set their API key
        let userDefaultsKey = "openai_api_key"
        let savedKey = UserDefaults.standard.string(forKey: userDefaultsKey)
        
        if let savedKey = savedKey, !savedKey.isEmpty {
            return savedKey
        }
        
        // Fallback to placeholder (user needs to set this)
        return nil
    }
    
    // MARK: - Cache Management
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func getCacheSize() -> Int {
        return cache.totalCostLimit
    }
    
    func getCacheCount() -> Int {
        return cache.countLimit
    }
}

// MARK: - Supporting Types
enum SentimentResult: String, CaseIterable {
    case positive = "positive"
    case negative = "negative"
    case neutral = "neutral"
    
    var emoji: String {
        switch self {
        case .positive: return "😊"
        case .negative: return "😔"
        case .neutral: return "😐"
        }
    }
    
    var color: Color {
        switch self {
        case .positive: return .green
        case .negative: return .red
        case .neutral: return .gray
        }
    }
}

enum SummarizationError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key not configured. Please set your API key in the app settings."
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .apiError(let statusCode):
            return "API error with status code: \(statusCode)"
        }
    }
}
