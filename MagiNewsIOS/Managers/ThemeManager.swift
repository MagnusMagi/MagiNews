//
//  ThemeManager.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled: Bool = false
    @AppStorage("useSystemTheme") private var useSystemTheme: Bool = true
    
    @Published var currentColorScheme: ColorScheme?
    
    init() {
        updateColorScheme()
    }
    
    // MARK: - Public Methods
    
    func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        useSystemTheme = false
        updateColorScheme()
    }
    
    func enableSystemTheme() {
        useSystemTheme = true
        updateColorScheme()
    }
    
    func setDarkMode(_ enabled: Bool) {
        isDarkModeEnabled = enabled
        useSystemTheme = false
        updateColorScheme()
    }
    
    func getCurrentTheme() -> ThemePreference {
        if useSystemTheme {
            return .system
        } else {
            return isDarkModeEnabled ? .dark : .light
        }
    }
    
    // MARK: - Private Methods
    
    private func updateColorScheme() {
        if useSystemTheme {
            currentColorScheme = nil // Use system default
        } else {
            currentColorScheme = isDarkModeEnabled ? .dark : .light
        }
    }
}

// MARK: - Theme Preference Enum

enum ThemePreference: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var icon: String {
        switch self {
        case .system:
            return "gear"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

// MARK: - Theme Extensions

extension View {
    func preferredTheme(_ themeManager: ThemeManager) -> some View {
        self.preferredColorScheme(themeManager.currentColorScheme)
    }
}
