//
//  ProfileView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("userName") private var userName = "News Reader"
    @AppStorage("userRegion") private var userRegion = "Estonia"
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    
    private let languages = [
        ("en", "🇺🇸", "English"),
        ("et", "🇪🇪", "Eesti"),
        ("lv", "🇱🇻", "Latviešu"),
        ("lt", "🇱🇹", "Lietuvių"),
        ("fi", "🇫🇮", "Suomi")
    ]
    
    private let regions = [
        ("Estonia", "🇪🇪"),
        ("Latvia", "🇱🇻"),
        ("Lithuania", "🇱🇹"),
        ("Finland", "🇫🇮"),
        ("Nordic", "🌍")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader
                    
                    // Language & Region Settings - Temporarily disabled
                    // languageRegionSection
                    
                    // Appearance Settings
                    appearanceSection
                    
                    // App Information
                    appInfoSection
                    
                    // Actions
                    actionsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Avatar
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )
            
            // User Info
            VStack(spacing: 8) {
                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Text(regions.first { $0.0 == userRegion }?.1 ?? "🌍")
                    Text(userRegion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Language & Region Section
    
    private var languageRegionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Language & Region")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Language Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("App Language")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Language", selection: $appLanguage) {
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
                
                // Region Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred Region")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Region", selection: $userRegion) {
                        ForEach(regions, id: \.0) { region, flag in
                            HStack {
                                Text(flag)
                                Text(region)
                            }
                            .tag(region)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appearance")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // System Theme Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Use System Theme")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Automatically follow system appearance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $useSystemTheme)
                        .onChange(of: useSystemTheme) { newValue in
                            if newValue {
                                isDarkMode = systemColorScheme == .dark
                            }
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Dark Mode Toggle (only when not using system theme)
                if !useSystemTheme {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dark Mode")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Switch between light and dark themes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isDarkMode)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // App Version
                HStack {
                    Text("Version")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Build Number
                HStack {
                    Text("Build")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("2025.08.24")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Platform
                HStack {
                    Text("Platform")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("iOS \(UIDevice.current.systemVersion)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Clear Cache
                Button(action: clearCache) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Clear Cache")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                
                // Reset Settings
                Button(action: resetSettings) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.orange)
                        Text("Reset to Defaults")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                
                // About
                Button(action: showAbout) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("About MagiNews")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func clearCache() {
        // Clear app cache logic
        print("Clearing app cache...")
    }
    
    private func resetSettings() {
        // Reset to default settings
        appLanguage = "en"
        userRegion = "Estonia"
        isDarkMode = false
        useSystemTheme = true
        print("Settings reset to defaults")
    }
    
    private func showAbout() {
        // Show about information
        print("Showing about information...")
    }
}

#Preview {
    ProfileView()
}
