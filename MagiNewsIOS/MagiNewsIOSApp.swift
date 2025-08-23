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
                HomeView()
                    .tabItem {
                        Image(systemName: "newspaper")
                        Text("News")
                    }
                
                BookmarksView()
                    .tabItem {
                        Image(systemName: "bookmark.fill")
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

// MARK: - Settings View

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
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Previews
#Preview("Main App") {
    ContentView()
        .modelContainer(previewContainer)
}

#Preview("TabView") {
    TabView {
        MainFeedView()
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

#Preview("Bookmarks") {
    BookmarksView()
}

#Preview("Settings") {
    SettingsView()
}

#Preview("Settings - Dark Mode") {
    SettingsView()
        .preferredColorScheme(.dark)
}

// MARK: - Preview Helper
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
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
}

// Preview data container
private var previewContainer: ModelContainer = {
    let schema = Schema([
        NewsArticle.self,
        NewsCategory.self,
        UserPreferences.self
    ])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(for: schema, configurations: [configuration])
        
        // Add sample data for preview
        let context = ModelContext(container)
        
        // Sample categories
        let techCategory = NewsCategory(name: "Technology", color: "#96CEB4", icon: "laptopcomputer")
        let politicsCategory = NewsCategory(name: "Politics", color: "#FF6B6B", icon: "building.2")
        
        context.insert(techCategory)
        context.insert(politicsCategory)
        
        // Sample articles
        let article1 = NewsArticle(
            title: "Estonia Leads Digital Innovation in Baltics",
            content: "Estonia continues to be a pioneer in digital transformation...",
            summary: "Estonia's digital leadership in the Baltic region continues to grow.",
            author: "Tech Reporter",
            publishedAt: Date(),
            imageURL: nil,
            category: "Technology"
        )
        
        let article2 = NewsArticle(
            title: "Nordic Council Meeting Discusses Climate Policy",
            content: "The Nordic Council held an important meeting about climate...",
            summary: "Nordic countries align on new climate initiatives.",
            author: "Political Correspondent",
            publishedAt: Date().addingTimeInterval(-3600),
            imageURL: nil,
            category: "Politics"
        )
        
        context.insert(article1)
        context.insert(article2)
        
        try context.save()
        return container
    } catch {
        fatalError("Failed to create preview container: \(error)")
    }
}()
