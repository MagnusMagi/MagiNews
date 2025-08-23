//
//  SummarizationService.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import Combine

// MARK: - OpenAI API Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages
        case maxTokens = "max_tokens"
        case temperature
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
    let finishReason: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Summarization Service
class SummarizationService: ObservableObject {
    @Published var isSummarizing = false
    @Published var errorMessage: String?
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        // In production, load from secure storage
        self.apiKey = "your-openai-api-key-here"
    }
    
    func summarizeArticle(_ content: String, language: String = "English") async throws -> String {
        isSummarizing = true
        errorMessage = nil
        
        defer { isSummarizing = false }
        
        let prompt = createSummarizationPrompt(content: content, language: language)
        let request = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [OpenAIMessage(role: "user", content: prompt)],
            maxTokens: 150,
            temperature: 0.7
        )
        
        return try await performOpenAIRequest(request)
    }
    
    func translateArticle(_ content: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        isSummarizing = true
        errorMessage = nil
        
        defer { isSummarizing = false }
        
        let prompt = createTranslationPrompt(content: content, from: sourceLanguage, to: targetLanguage)
        let request = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [OpenAIMessage(role: "user", content: prompt)],
            maxTokens: 500,
            temperature: 0.3
        )
        
        return try await performOpenAIRequest(request)
    }
    
    func generateDailyDigest(_ articles: [RSSItem]) async throws -> String {
        isSummarizing = true
        errorMessage = nil
        
        defer { isSummarizing = false }
        
        let prompt = createDigestPrompt(articles: articles)
        let request = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [OpenAIMessage(role: "user", content: prompt)],
            maxTokens: 300,
            temperature: 0.7
        )
        
        return try await performOpenAIRequest(request)
    }
    
    private func performOpenAIRequest(_ request: OpenAIRequest) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw SummarizationError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SummarizationError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                throw SummarizationError.apiError(statusCode: httpResponse.statusCode)
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let firstChoice = openAIResponse.choices.first else {
                throw SummarizationError.noContent
            }
            
            return firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            if let openAIError = error as? SummarizationError {
                throw openAIError
            }
            throw SummarizationError.networkError(error.localizedDescription)
        }
    }
    
    private func createSummarizationPrompt(content: String, language: String) -> String {
        return """
        Summarize the following news article in \(language). 
        Provide a concise, informative summary in 2-3 sentences.
        Focus on the key facts and main points.
        
        Article content:
        \(content)
        
        Summary:
        """
    }
    
    private func createTranslationPrompt(content: String, from sourceLanguage: String, to targetLanguage: String) -> String {
        return """
        Translate the following text from \(sourceLanguage) to \(targetLanguage).
        Maintain the original meaning and tone.
        If this is a news article, ensure journalistic style is preserved.
        
        Text to translate:
        \(content)
        
        Translation:
        """
    }
    
    private func createDigestPrompt(articles: [RSSItem]) -> String {
        let articleTitles = articles.prefix(5).map { "- \($0.title)" }.joined(separator: "\n")
        
        return """
        Create a daily news digest summary based on these article titles.
        Provide a brief overview of the main stories in 3-4 sentences.
        Focus on the most important developments and trends.
        
        Articles:
        \(articleTitles)
        
        Daily Digest Summary:
        """
    }
}

// MARK: - Summarization Errors
enum SummarizationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int)
    case noContent
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .apiError(let statusCode):
            return "API error with status code: \(statusCode)"
        case .noContent:
            return "No content received from API"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Language Support
enum SupportedLanguage: String, CaseIterable {
    case english = "en"
    case estonian = "et"
    case latvian = "lv"
    case lithuanian = "lt"
    case finnish = "fi"
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .estonian:
            return "Eesti"
        case .latvian:
            return "Latviešu"
        case .lithuanian:
            return "Lietuvių"
        case .finnish:
            return "Suomi"
        }
    }
    
    var flag: String {
        switch self {
        case .english:
            return "🇺🇸"
        case .estonian:
            return "🇪🇪"
        case .latvian:
            return "🇱🇻"
        case .lithuanian:
            return "🇱🇹"
        case .finnish:
            return "🇫🇮"
        }
    }
}
