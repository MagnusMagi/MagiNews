//
//  LanguageManager.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftUI

@MainActor
class LanguageManager: ObservableObject {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    @AppStorage("useSystemLanguage") private var useSystemLanguage: Bool = true
    
    @Published var currentLanguage: SupportedLanguage = .english
    
    init() {
        updateCurrentLanguage()
    }
    
    // MARK: - Public Methods
    
    func setLanguage(_ language: SupportedLanguage) {
        selectedLanguage = language.rawValue
        useSystemLanguage = false
        updateCurrentLanguage()
    }
    
    func enableSystemLanguage() {
        useSystemLanguage = true
        updateCurrentLanguage()
    }
    
    func getCurrentLanguage() -> SupportedLanguage {
        if useSystemLanguage {
            return getSystemLanguage()
        } else {
            return SupportedLanguage(rawValue: selectedLanguage) ?? .english
        }
    }
    
    func getDisplayLanguage() -> String {
        let language = getCurrentLanguage()
        return language.displayName
    }
    
    // MARK: - Private Methods
    
    private func updateCurrentLanguage() {
        currentLanguage = getCurrentLanguage()
    }
    
    private func getSystemLanguage() -> SupportedLanguage {
        let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        return SupportedLanguage(rawValue: systemLanguage) ?? .english
    }
}

// MARK: - Language Extensions

extension View {
    func localizedText(_ key: String, comment: String = "") -> some View {
        let language = LanguageManager().getCurrentLanguage()
        let localizedString = NSLocalizedString(key, comment: comment)
        return self.environment(\.locale, Locale(identifier: language.rawValue))
    }
}

// MARK: - Localization Keys

struct LocalizationKeys {
    static let searchPlaceholder = "search_placeholder"
    static let dailyDigest = "daily_digest"
    static let noNewsAvailable = "no_news_available"
    static let tryRefreshing = "try_refreshing"
    static let refresh = "refresh"
    static let loadingNews = "loading_news"
    static let all = "all"
    static let politics = "politics"
    static let technology = "technology"
    static let business = "business"
    static let culture = "culture"
    static let sports = "sports"
}
