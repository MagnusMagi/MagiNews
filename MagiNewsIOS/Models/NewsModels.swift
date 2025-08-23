//
//  NewsModels.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import SwiftData

@Model
final class NewsArticle {
    var id: String
    var title: String
    var content: String
    var summary: String
    var author: String
    var publishedAt: Date
    var imageURL: String?
    var category: String
    var isBookmarked: Bool
    var isRead: Bool
    var createdAt: Date
    
    init(id: String = UUID().uuidString,
         title: String,
         content: String,
         summary: String,
         author: String,
         publishedAt: Date,
         imageURL: String? = nil,
         category: String = "General") {
        self.id = id
        self.title = title
        self.content = content
        self.summary = summary
        self.author = author
        self.publishedAt = publishedAt
        self.imageURL = imageURL
        self.category = category
        self.isBookmarked = false
        self.isRead = false
        self.createdAt = Date()
    }
}

@Model
final class NewsCategory {
    var id: String
    var name: String
    var color: String
    var icon: String
    var isActive: Bool
    var createdAt: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         color: String = "#007AFF",
         icon: String = "newspaper",
         isActive: Bool = true) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.isActive = isActive
        self.createdAt = Date()
    }
}

@Model
final class UserPreferences {
    var id: String
    var selectedCategories: [String]
    var darkModeEnabled: Bool
    var notificationsEnabled: Bool
    var fontSize: Double
    var lastSyncDate: Date?
    var createdAt: Date
    
    init(id: String = UUID().uuidString) {
        self.id = id
        self.selectedCategories = ["General", "Technology", "Business"]
        self.darkModeEnabled = false
        self.notificationsEnabled = true
        self.fontSize = 16.0
        self.lastSyncDate = nil
        self.createdAt = Date()
    }
}
