//
//  SupportActionsView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI
import MessageUI

struct SupportActionsView: View {
    @State private var showingEmailComposer = false
    @State private var showingDeleteConfirmation = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    
    let onExportBookmarks: () -> URL?
    let onDeleteData: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Support & Feedback
            CardSection(title: "Support & Feedback", icon: "questionmark.circle", iconColor: .blue) {
                VStack(spacing: 16) {
                    SectionRow(
                        icon: "envelope",
                        iconColor: .blue,
                        title: "Send Feedback",
                        subtitle: "Help us improve MagiNews",
                        action: { showingEmailComposer = true }
                    )
                    
                    SectionRow(
                        icon: "star",
                        iconColor: .yellow,
                        title: "Rate on App Store",
                        subtitle: "Share your experience",
                        action: rateOnAppStore
                    )
                    
                    SectionRow(
                        icon: "globe",
                        iconColor: .green,
                        title: "Visit Website",
                        subtitle: "Learn more about MagiNews",
                        action: visitWebsite
                    )
                }
            }
            
            // Legal & Privacy
            CardSection(title: "Legal & Privacy", icon: "doc.text", iconColor: .gray) {
                VStack(spacing: 16) {
                    SectionRow(
                        icon: "hand.raised",
                        iconColor: .blue,
                        title: "Privacy Policy",
                        subtitle: "How we protect your data",
                        action: showPrivacyPolicy
                    )
                    
                    SectionRow(
                        icon: "doc.plaintext",
                        iconColor: .orange,
                        title: "Terms of Service",
                        subtitle: "App usage terms",
                        action: showTermsOfService
                    )
                }
            }
            
            // Data Management
            CardSection(title: "Data Management", icon: "externaldrive", iconColor: .purple) {
                VStack(spacing: 16) {
                    SectionRow(
                        icon: "square.and.arrow.up",
                        iconColor: .green,
                        title: "Export Bookmarks",
                        subtitle: "Save your bookmarks",
                        action: exportBookmarks
                    )
                    
                    SectionRow(
                        icon: "trash",
                        iconColor: .red,
                        title: "Delete My Data",
                        subtitle: "Remove all personal data",
                        action: { showingDeleteConfirmation = true }
                    )
                }
            }
        }
        .sheet(isPresented: $showingEmailComposer) {
            EmailComposerView()
        }
        .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDeleteData()
            }
        } message: {
            Text("This will permanently delete all your bookmarks, preferences, and cached data. This action cannot be undone.")
        }
        .sheet(isPresented: $showingExportSheet) {
            if let exportURL = exportURL {
                ShareSheet(activityItems: [exportURL])
            }
        }
    }
    
    // MARK: - Actions
    
    private func rateOnAppStore() {
        if let url = AppVersionService.shared.appStoreReviewURL {
            UIApplication.shared.open(url)
        }
    }
    
    private func visitWebsite() {
        if let url = AppVersionService.shared.supportWebsite {
            UIApplication.shared.open(url)
        }
    }
    
    private func showPrivacyPolicy() {
        if let url = AppVersionService.shared.privacyPolicyURL {
            UIApplication.shared.open(url)
        }
    }
    
    private func showTermsOfService() {
        if let url = AppVersionService.shared.termsOfServiceURL {
            UIApplication.shared.open(url)
        }
    }
    
    private func exportBookmarks() {
        if let url = onExportBookmarks() {
            exportURL = url
            showingExportSheet = true
        }
    }
}

// MARK: - Email Composer View
struct EmailComposerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        
        composer.setToRecipients([AppVersionService.shared.supportEmail])
        composer.setSubject("MagiNews Feedback - \(AppVersionService.shared.fullVersion)")
        composer.setMessageBody(emailTemplate, isHTML: false)
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private var emailTemplate: String {
        """
        
        ---
        Device: \(AppVersionService.shared.deviceModel)
        iOS Version: \(AppVersionService.shared.platform)
        App Version: \(AppVersionService.shared.fullVersion)
        ---
        
        Please describe your feedback or issue below:
        
        """
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SupportActionsView(
        onExportBookmarks: { nil },
        onDeleteData: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
