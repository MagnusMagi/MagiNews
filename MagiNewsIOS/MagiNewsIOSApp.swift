//
//  MagiNewsIOSApp.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI
import SwiftData

@main
struct MagiNewsIOSApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            NewsArticle.self,
            NewsCategory.self,
            UserPreferences.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                FeedView()
                    .tabItem {
                        Image(systemName: "newspaper")
                        Text("News")
                    }
                
                BookmarksView()
                    .tabItem {
                        Image(systemName: "bookmark")
                        Text("Bookmarks")
                    }
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
            .accentColor(.blue)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Placeholder Views (to be implemented)
struct BookmarksView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "bookmark")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Bookmarks")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your saved articles will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("Bookmarks")
        }
    }
}

struct SettingsView: View {
    @AppStorage("language") private var selectedLanguage = "en"
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section("Language") {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(SupportedLanguage.allCases, id: \.rawValue) { language in
                            HStack {
                                Text(language.flag)
                                Text(language.displayName)
                            }
                            .tag(language.rawValue)
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("0.2.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
