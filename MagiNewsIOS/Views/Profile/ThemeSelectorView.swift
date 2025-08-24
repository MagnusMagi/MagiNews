//
//  ThemeSelectorView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct ThemeSelectorView: View {
    @Binding var selectedTheme: AppTheme
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Theme Segmented Control
            Picker("Theme", selection: $selectedTheme) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    HStack(spacing: 6) {
                        Image(systemName: theme.icon)
                            .foregroundColor(theme.color)
                            .font(.caption)
                        Text(theme.displayName)
                            .font(.caption)
                    }
                    .tag(theme)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - Appearance Settings Section
struct AppearanceSettingsSection: View {
    @Binding var selectedTheme: AppTheme
    @Binding var accentColor: String
    
    private let accentColors = [
        ("blue", "Blue", Color.blue),
        ("purple", "Purple", Color.purple),
        ("green", "Green", Color.green),
        ("orange", "Orange", Color.orange),
        ("red", "Red", Color.red),
        ("pink", "Pink", Color.pink)
    ]
    
    var body: some View {
        CardSection(title: "Appearance", icon: "paintbrush", iconColor: .purple) {
            VStack(spacing: 20) {
                // Theme Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Theme")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ThemeSelectorView(selectedTheme: $selectedTheme)
                }
                
                Divider()
                
                // Accent Color
                VStack(alignment: .leading, spacing: 12) {
                    Text("Accent Color")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(accentColors, id: \.0) { color in
                            Button(action: {
                                accentColor = color.0
                            }) {
                                Circle()
                                    .fill(color.2)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: accentColor == color.0 ? 3 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ThemeSelectorView(selectedTheme: .constant(.system))
        
        AppearanceSettingsSection(
            selectedTheme: .constant(.system),
            accentColor: .constant("blue")
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
