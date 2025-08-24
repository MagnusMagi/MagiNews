//
//  ProfileView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI
import LocalAuthentication

struct ProfileView: View {
    // MARK: - State Objects
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var cacheManager: CacheManager
    @StateObject private var bookmarkManager = BookmarkManager()
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    
    // MARK: - State
    @State private var showingBiometricSetup = false
    @State private var showingCacheAlert = false
    @State private var showingResetAlert = false
    @State private var showingDeleteAlert = false
    @State private var isUpdatingCache = false
    
    // MARK: - Initialization
    init() {
        let offlineCache = OfflineCache()
        let bookmarkManager = BookmarkManager()
        self._cacheManager = StateObject(wrappedValue: CacheManager(offlineCache: offlineCache, bookmarkManager: bookmarkManager))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Profile Header
                    ProfileHeaderView(
                        userName: $settingsStore.userName,
                        avatarData: $settingsStore.userAvatarData,
                        userRegion: settingsStore.userRegion,
                        onAvatarTap: handleAvatarUpdate,
                        onNameEdit: { newName in
                            settingsStore.userName = newName
                        }
                    )
                    
                    // Appearance Settings
                    AppearanceSettingsSection(
                        selectedTheme: $settingsStore.theme,
                        accentColor: $settingsStore.accentColor
                    )
                    
                    // AI Preferences
                    AIPreferencesSection(
                        summaryStyle: $settingsStore.summaryStyle,
                        aiLanguage: $settingsStore.aiLanguage,
                        dailyDigestNotifications: $settingsStore.dailyDigestNotifications,
                        wifiOnlyFetch: $settingsStore.wifiOnlyFetch
                    )
                    
                    // App Information
                    appInfoSection
                    
                    // Cache & Actions
                    cacheAndActionsSection
                    
                    // Security Settings
                    securitySection
                    
                    // Support & Feedback
                    SupportActionsView(
                        onExportBookmarks: { cacheManager.exportBookmarks() },
                        onDeleteData: handleDeleteAllData
                    )
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
            .refreshable {
                await refreshCacheInfo()
            }
            .onAppear {
                Task {
                    await refreshCacheInfo()
                }
            }
            .preferredColorScheme(preferredColorScheme)
        }
        .alert("Clear Cache", isPresented: $showingCacheAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                Task {
                    await clearAllCache()
                }
            }
        } message: {
            Text("This will remove all cached articles and bookmarks. This action cannot be undone.")
        }
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllSettings()
            }
        } message: {
            Text("This will reset all app settings to their default values. Your bookmarks and cached articles will be preserved.")
        }
        .alert("Delete All Data", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                handleDeleteAllData()
            }
        } message: {
            Text("This will permanently delete all your data including bookmarks, preferences, and cached articles. This action cannot be undone.")
        }
    }
    
    // MARK: - Computed Properties
    
    private var preferredColorScheme: ColorScheme? {
        switch settingsStore.theme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        CardSection(title: "App Information", icon: "info.circle", iconColor: .blue) {
            VStack(spacing: 12) {
                InfoRow(
                    icon: "app",
                    iconColor: .blue,
                    title: "Version",
                    value: AppVersionService.shared.fullVersion
                )
                
                InfoRow(
                    icon: "hammer",
                    iconColor: .orange,
                    title: "Build Date",
                    value: AppVersionService.shared.buildDateString
                )
                
                InfoRow(
                    icon: "iphone",
                    iconColor: .green,
                    title: "Platform",
                    value: AppVersionService.shared.platform
                )
                
                Button(action: checkForUpdates) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                        Text("Check for Updates")
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
    
    // MARK: - Cache & Actions Section
    
    private var cacheAndActionsSection: some View {
        CardSection(title: "Cache & Actions", icon: "externaldrive", iconColor: .orange) {
            VStack(spacing: 16) {
                // Cache Information
                VStack(spacing: 12) {
                    InfoRow(
                        icon: "externaldrive",
                        iconColor: .blue,
                        title: "Cache Size",
                        value: cacheManager.cacheSize
                    )
                    
                    InfoRow(
                        icon: "doc.text",
                        iconColor: .green,
                        title: "Articles Cached",
                        value: "\(cacheManager.articleCount)"
                    )
                    
                    InfoRow(
                        icon: "clock",
                        iconColor: .purple,
                        title: "Last Updated",
                        value: cacheManager.cacheAge
                    )
                }
                
                Divider()
                
                // Actions
                VStack(spacing: 12) {
                    SectionRow(
                        icon: "trash",
                        iconColor: .red,
                        title: "Clear All Cache",
                        subtitle: "Free up storage space",
                        action: { showingCacheAlert = true }
                    )
                    
                    SectionRow(
                        icon: "arrow.clockwise",
                        iconColor: .orange,
                        title: "Reset Settings",
                        subtitle: "Restore default preferences",
                        action: { showingResetAlert = true }
                    )
                    
                    SectionRow(
                        icon: "square.and.arrow.up",
                        iconColor: .green,
                        title: "Export Bookmarks",
                        subtitle: "Save your bookmarks",
                        action: exportBookmarks
                    )
                }
            }
        }
    }
    
    // MARK: - Security Section
    
    private var securitySection: some View {
        CardSection(title: "Security", icon: "lock.shield", iconColor: .red) {
            VStack(spacing: 16) {
                ToggleRow(
                    icon: "faceid",
                    iconColor: .blue,
                    title: "Biometric Lock",
                    subtitle: "Use Face ID or Touch ID to secure the app",
                    isOn: $settingsStore.biometricLockEnabled
                )
                .onChange(of: settingsStore.biometricLockEnabled) { oldValue, newValue in
                    if newValue {
                        setupBiometricAuthentication()
                    }
                }
                
                if settingsStore.biometricLockEnabled {
                    InfoRow(
                        icon: "checkmark.shield",
                        iconColor: .green,
                        title: "Status",
                        value: "Secured with biometrics"
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleAvatarUpdate() {
        // Avatar update logic would be implemented here
        print("Avatar update requested")
    }
    
    private func refreshCacheInfo() async {
        await cacheManager.updateCacheInfo()
    }
    
    private func clearAllCache() async {
        isUpdatingCache = true
        await cacheManager.clearAllCache()
        isUpdatingCache = false
    }
    
    private func resetAllSettings() {
        settingsStore.resetToDefaults()
        // Note: Don't reset cache or bookmarks here
    }
    
    private func handleDeleteAllData() {
        // Clear all data including cache, bookmarks, and settings
        Task {
            await cacheManager.clearAllCache()
        }
        settingsStore.resetToDefaults()
        showingDeleteAlert = false
    }
    
    private func checkForUpdates() {
        Task {
            let updateStatus = await AppVersionService.shared.checkForUpdates()
            // Handle update status
            print("Update check completed: \(updateStatus.isAvailable)")
        }
    }
    
    private func exportBookmarks() {
        if let exportURL = cacheManager.exportBookmarks() {
            // Share the export URL
            let activityVC = UIActivityViewController(activityItems: [exportURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true)
            }
        }
    }
    
    private func setupBiometricAuthentication() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable biometric authentication for MagiNews") { success, error in
                DispatchQueue.main.async {
                    if success {
                        settingsStore.biometricLockEnabled = true
                    } else {
                        settingsStore.biometricLockEnabled = false
                        if let error = error {
                            print("Biometric authentication failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } else {
            settingsStore.biometricLockEnabled = false
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}

#Preview {
    ProfileView()
        .environment(\.colorScheme, .light)
}

#Preview("Dark Mode") {
    ProfileView()
        .environment(\.colorScheme, .dark)
}
