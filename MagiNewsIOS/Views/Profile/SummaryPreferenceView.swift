//
//  SummaryPreferenceView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct SummaryPreferenceView: View {
    @Binding var selectedStyle: SummaryStyle
    @Binding var aiLanguage: String
    
    private let languages = [
        ("en", "🇺🇸", "English"),
        ("et", "🇪🇪", "Eesti"),
        ("lv", "🇱🇻", "Latviešu"),
        ("lt", "🇱🇹", "Lietuvių"),
        ("fi", "🇫🇮", "Suomi")
    ]
    
    var body: some View {
        CardSection(title: "AI Personalization", icon: "brain.head.profile", iconColor: .purple) {
            VStack(spacing: 20) {
                // Summary Style
                VStack(alignment: .leading, spacing: 12) {
                    Text("Summary Style")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 8) {
                        ForEach(SummaryStyle.allCases, id: \.self) { style in
                            Button(action: {
                                selectedStyle = style
                            }) {
                                VStack(spacing: 4) {
                                    Text(style.displayName)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text(style.description)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedStyle == style ? Color.blue : Color(.systemGray6))
                                .foregroundColor(selectedStyle == style ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Divider()
                
                // AI Language
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Language")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("AI Language", selection: $aiLanguage) {
                        ForEach(languages, id: \.0) { code, flag, name in
                            HStack {
                                Text(flag)
                                Text(name)
                            }
                            .tag(code)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Summary Preview
                summaryPreview
            }
        }
    }
    
    private var summaryPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Sample Article Summary")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(sampleSummary)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private var sampleSummary: String {
        switch selectedStyle {
        case .short:
            return "Estonia leads digital innovation in the Baltic region with new e-government initiatives."
        case .medium:
            return "Estonia continues to be a pioneer in digital transformation, launching new e-government services that streamline citizen interactions. The country's advanced digital infrastructure sets an example for other Baltic nations."
        case .detailed:
            return "Estonia has reaffirmed its position as a digital innovation leader in the Baltic region by introducing comprehensive new e-government initiatives. These services include streamlined citizen portals, enhanced digital identity systems, and improved public service delivery. The country's commitment to technological advancement continues to serve as a model for neighboring nations seeking to modernize their digital infrastructure."
        }
    }
}

// MARK: - AI Preferences Section
struct AIPreferencesSection: View {
    @Binding var summaryStyle: SummaryStyle
    @Binding var aiLanguage: String
    @Binding var dailyDigestNotifications: Bool
    @Binding var wifiOnlyFetch: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // AI Personalization
            SummaryPreferenceView(
                selectedStyle: $summaryStyle,
                aiLanguage: $aiLanguage
            )
            
            // AI Behavior
            CardSection(title: "AI Behavior", icon: "gear", iconColor: .orange) {
                VStack(spacing: 16) {
                    ToggleRow(
                        icon: "bell",
                        iconColor: .green,
                        title: "Daily Digest Notifications",
                        subtitle: "Get AI-generated summaries daily",
                        isOn: $dailyDigestNotifications
                    )
                    
                    ToggleRow(
                        icon: "wifi",
                        iconColor: .blue,
                        title: "WiFi Only Fetch",
                        subtitle: "Fetch news only on WiFi to save data",
                        isOn: $wifiOnlyFetch
                    )
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SummaryPreferenceView(
            selectedStyle: .constant(.medium),
            aiLanguage: .constant("en")
        )
        
        AIPreferencesSection(
            summaryStyle: .constant(.medium),
            aiLanguage: .constant("en"),
            dailyDigestNotifications: .constant(true),
            wifiOnlyFetch: .constant(false)
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
