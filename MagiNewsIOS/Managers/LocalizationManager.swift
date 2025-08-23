//
//  LocalizationManager.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
            updateLocale()
        }
    }
    
    @Published var currentLocale: Locale
    
    private let supportedLanguages = [
        "en": "English",
        "et": "Eesti",
        "lv": "Latviešu", 
        "lt": "Lietuvių",
        "fi": "Suomi"
    ]
    
    private let languageFlags = [
        "en": "🇺🇸",
        "et": "🇪🇪",
        "lv": "🇱🇻",
        "lt": "🇱🇹",
        "fi": "🇫🇮"
    ]
    
    init() {
        // Load saved language or use system language
        let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage")
        let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        let initialLanguage = savedLanguage ?? systemLanguage
        
        // Ensure the language is supported
        let finalLanguage = supportedLanguages.keys.contains(initialLanguage) ? initialLanguage : "en"
        
        self.currentLanguage = finalLanguage
        self.currentLocale = Locale(identifier: finalLanguage)
    }
    
    // MARK: - Language Management
    
    func setLanguage(_ languageCode: String) {
        guard supportedLanguages.keys.contains(languageCode) else { return }
        currentLanguage = languageCode
    }
    
    func getDisplayName(for languageCode: String) -> String {
        return supportedLanguages[languageCode] ?? languageCode
    }
    
    func getFlag(for languageCode: String) -> String {
        return languageFlags[languageCode] ?? "🌐"
    }
    
    func getAllLanguages() -> [(code: String, name: String, flag: String)] {
        return supportedLanguages.map { (code: $0.key, name: $0.value, flag: languageFlags[$0.key] ?? "🌐") }
            .sorted { $0.name < $1.name }
    }
    
    // MARK: - Localization
    
    func localizedString(_ key: String, comment: String = "") -> String {
        let bundle = Bundle.main
        let languagePath = bundle.path(forResource: currentLanguage, ofType: "lproj")
        
        if let languagePath = languagePath,
           let languageBundle = Bundle(path: languagePath) {
            return NSLocalizedString(key, bundle: languageBundle, comment: comment)
        }
        
        // Fallback to main bundle
        return NSLocalizedString(key, bundle: bundle, comment: comment)
    }
    
    func localizedString(_ key: String, arguments: CVarArg..., comment: String = "") -> String {
        let bundle = Bundle.main
        let languagePath = bundle.path(forResource: currentLanguage, ofType: "lproj")
        
        if let languagePath = languagePath,
           let languageBundle = Bundle(path: languagePath) {
            return String(format: NSLocalizedString(key, bundle: languageBundle, comment: comment), arguments: arguments)
        }
        
        // Fallback to main bundle
        return String(format: NSLocalizedString(key, bundle: bundle, comment: comment), arguments: arguments)
    }
    
    // MARK: - Date and Number Formatting
    
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = style
        return formatter.string(from: date)
    }
    
    func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func formatNumber(_ number: NSNumber, style: NumberFormatter.Style = .decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = style
        return formatter.string(from: number) ?? number.stringValue
    }
    
    // MARK: - Private Methods
    
    private func updateLocale() {
        currentLocale = Locale(identifier: currentLanguage)
    }
}

// MARK: - LocalizedStringKey Extension

// Note: LocalizedStringKey extension removed to avoid infinite recursion

// MARK: - View Extension for Localization

extension View {
    func localized(_ key: String, comment: String = "") -> some View {
        _ = LocalizationManager().localizedString(key, comment: comment)
        return self.environment(\.locale, Locale(identifier: LocalizationManager().currentLanguage))
    }
}

// MARK: - Localization Keys
// Note: LocalizationKeys struct is defined in LanguageManager.swift to avoid duplication
