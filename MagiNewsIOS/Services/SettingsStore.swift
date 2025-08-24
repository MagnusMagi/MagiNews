//
//  SettingsStore.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftUI

@MainActor
class SettingsStore: ObservableObject {
    // MARK: - User Profile
    @AppStorage("userName") var userName: String = "News Reader"
    @AppStorage("userRegion") var userRegion: String = "Estonia"
    @AppStorage("userAvatarData") var userAvatarData: Data = Data()
    
    // MARK: - Appearance
    @AppStorage("theme") var theme: AppTheme = .system
    @AppStorage("accentColor") var accentColor: String = "blue"
    
    // MARK: - AI Preferences
    @AppStorage("summaryStyle") var summaryStyle: SummaryStyle = .medium
    @AppStorage("aiLanguage") var aiLanguage: String = "en"
    
    // MARK: - Notifications
    @AppStorage("dailyDigestNotifications") var dailyDigestNotifications: Bool = true
    @AppStorage("wifiOnlyFetch") var wifiOnlyFetch: Bool = false
    
    // MARK: - Security
    @AppStorage("biometricLockEnabled") var biometricLockEnabled: Bool = false
    
    // MARK: - Cache Settings
    @AppStorage("autoClearCache") var autoClearCache: Bool = true
    @AppStorage("cacheRetentionDays") var cacheRetentionDays: Int = 7
    
    // MARK: - App Settings
    @AppStorage("appLanguage") var appLanguage: String = "en"
    @AppStorage("firstLaunchDate") var firstLaunchDate: Date = Date()
    
    // MARK: - Computed Properties
    var isFirstLaunch: Bool {
        get {
            let calendar = Calendar.current
            return calendar.isDate(firstLaunchDate, inSameDayAs: Date())
        }
    }
    
    // MARK: - Reset Methods
    func resetToDefaults() {
        userName = "News Reader"
        userRegion = "Estonia"
        userAvatarData = Data()
        theme = .system
        accentColor = "blue"
        summaryStyle = .medium
        aiLanguage = "en"
        dailyDigestNotifications = true
        wifiOnlyFetch = false
        biometricLockEnabled = false
        autoClearCache = true
        cacheRetentionDays = 7
        appLanguage = "en"
        firstLaunchDate = Date()
    }
    
    func clearUserData() {
        userName = "News Reader"
        userAvatarData = Data()
        // Note: Don't reset region as it's app-specific
    }
}

// MARK: - Enums
enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "gear"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .system: return .blue
        case .light: return .orange
        case .dark: return .purple
        }
    }
}

enum SummaryStyle: String, CaseIterable {
    case short = "short"
    case medium = "medium"
    case detailed = "detailed"
    
    var displayName: String {
        switch self {
        case .short: return "Short"
        case .medium: return "Medium"
        case .detailed: return "Detailed"
        }
    }
    
    var description: String {
        switch self {
        case .short: return "1-2 sentences"
        case .medium: return "2-3 sentences"
        case .detailed: return "3-4 sentences"
        }
    }
    
    var maxTokens: Int {
        switch self {
        case .short: return 100
        case .medium: return 200
        case .detailed: return 300
        }
    }
}
