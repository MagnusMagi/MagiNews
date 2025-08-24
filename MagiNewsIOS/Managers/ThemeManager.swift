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
    @AppStorage("theme") private var theme: AppTheme = .system
    
    @Published var currentColorScheme: ColorScheme?
    
    init() {
        updateColorScheme()
    }
    
    // MARK: - Public Methods
    
    func setTheme(_ newTheme: AppTheme) {
        theme = newTheme
        updateColorScheme()
    }
    
    func getCurrentTheme() -> AppTheme {
        return theme
    }
    
    // MARK: - Private Methods
    
    private func updateColorScheme() {
        switch theme {
        case .system:
            currentColorScheme = nil // Use system default
        case .light:
            currentColorScheme = .light
        case .dark:
            currentColorScheme = .dark
        }
    }
}

// MARK: - Theme Extensions

extension View {
    func preferredTheme(_ themeManager: ThemeManager) -> some View {
        self.preferredColorScheme(themeManager.currentColorScheme)
    }
}
