//
//  AppVersionService.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import UIKit

struct AppVersionService {
    static let shared = AppVersionService()
    
    private init() {}
    
    // MARK: - App Information
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
    
    var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? 
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "MagiNews"
    }
    
    var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "com.magilabs.maginews"
    }
    
    // MARK: - Platform Information
    var platform: String {
        "iOS \(UIDevice.current.systemVersion)"
    }
    
    var deviceModel: String {
        UIDevice.current.model
    }
    
    var deviceName: String {
        UIDevice.current.name
    }
    
    // MARK: - Build Information
    var buildDate: Date? {
        guard let buildDateString = Bundle.main.infoDictionary?["CFBuildDate"] as? String else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: buildDateString)
    }
    
    var buildDateString: String {
        if let buildDate = buildDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: buildDate)
        }
        return "Unknown"
    }
    
    // MARK: - App Store Information
    var appStoreURL: URL? {
        URL(string: "https://apps.apple.com/app/id1234567890")
    }
    
    var appStoreReviewURL: URL? {
        URL(string: "https://apps.apple.com/app/id1234567890?action=write-review")
    }
    
    // MARK: - Support Information
    var supportEmail: String {
        "support@magilabs.com"
    }
    
    var supportWebsite: URL? {
        URL(string: "https://magilabs.com/support")
    }
    
    var privacyPolicyURL: URL? {
        URL(string: "https://magilabs.com/privacy")
    }
    
    var termsOfServiceURL: URL? {
        URL(string: "https://magilabs.com/terms")
    }
    
    // MARK: - Update Check
    func checkForUpdates() async -> UpdateStatus {
        // This would implement actual update checking logic
        // For now, return a placeholder status
        return UpdateStatus(
            isAvailable: false,
            currentVersion: appVersion,
            latestVersion: appVersion,
            updateURL: nil,
            releaseNotes: nil
        )
    }
}

// MARK: - Update Status
struct UpdateStatus {
    let isAvailable: Bool
    let currentVersion: String
    let latestVersion: String
    let updateURL: URL?
    let releaseNotes: String?
}
