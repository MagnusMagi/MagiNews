import Foundation
import SwiftUI

// MARK: - Translation Service
@MainActor
class TranslationService: ObservableObject {
    @Published var isTranslating = false
    @Published var errorMessage: String?
    
    private let summarizationService: SummarizationService
    
    init(summarizationService: SummarizationService) {
        self.summarizationService = summarizationService
    }
    
    // MARK: - Main Translation Method
    func translateArticle(_ content: String, to targetLanguage: String) async -> String? {
        isTranslating = true
        errorMessage = nil
        
        defer { isTranslating = false }
        
        let translation = await summarizationService.translateArticle(content, to: targetLanguage)
        return translation
    }
    
    // MARK: - Batch Translation
    func translateMultipleArticles(_ articles: [Article], to targetLanguage: String) async -> [String?] {
        var translations: [String?] = []
        
        for article in articles {
            let content = "\(article.title)\n\n\(article.summary)"
            let translation = await translateArticle(content, to: targetLanguage)
            translations.append(translation)
        }
        
        return translations
    }
    
    // MARK: - Language Detection
    func detectLanguage(of text: String) async -> String? {
        // Simple language detection based on common words
        // In production, you might want to use a more sophisticated approach
        
        let estonianWords = ["on", "ja", "et", "kui", "mis", "see", "ta", "olema"]
        let latvianWords = ["ir", "un", "ka", "ja", "kas", "tas", "viņš", "būt"]
        let lithuanianWords = ["yra", "ir", "kad", "jei", "kas", "tai", "jis", "būti"]
        let finnishWords = ["on", "ja", "että", "jos", "mikä", "se", "hän", "olla"]
        
        let lowercasedText = text.lowercased()
        
        let estonianCount = estonianWords.filter { lowercasedText.contains($0) }.count
        let latvianCount = latvianWords.filter { lowercasedText.contains($0) }.count
        let lithuanianCount = lithuanianWords.filter { lowercasedText.contains($0) }.count
        let finnishCount = finnishWords.filter { lowercasedText.contains($0) }.count
        
        let maxCount = max(estonianCount, latvianCount, lithuanianCount, finnishCount)
        
        if maxCount == 0 { return "en" } // Default to English
        
        if estonianCount == maxCount { return "et" }
        if latvianCount == maxCount { return "lv" }
        if lithuanianCount == maxCount { return "lt" }
        if finnishCount == maxCount { return "fi" }
        
        return "en"
    }
    
    // MARK: - Translation Quality Check
    func validateTranslation(_ original: String, _ translation: String, targetLanguage: String) async -> Bool {
        // Basic validation - check if translation is not empty and has reasonable length
        guard !translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        // Check if translation is not too short compared to original
        let originalWords = original.components(separatedBy: .whitespaces).count
        let translationWords = translation.components(separatedBy: .whitespaces).count
        
        // Translation should be at least 50% of original length
        let minRatio: Double = 0.5
        let ratio = Double(translationWords) / Double(originalWords)
        
        return ratio >= minRatio
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
        case .english: return "English"
        case .estonian: return "Eesti"
        case .latvian: return "Latviešu"
        case .lithuanian: return "Lietuvių"
        case .finnish: return "Suomi"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .estonian: return "🇪🇪"
        case .latvian: return "🇱🇻"
        case .lithuanian: return "🇱🇹"
        case .finnish: return "🇫🇮"
        }
    }
    
    var nativeName: String {
        switch self {
        case .english: return "English"
        case .estonian: return "Eesti keel"
        case .latvian: return "Latviešu valoda"
        case .lithuanian: return "Lietuvių kalba"
        case .finnish: return "Suomen kieli"
        }
    }
}
