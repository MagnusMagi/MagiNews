# 📱 MagiNews iOS

A modern, feature-rich iOS news application built with SwiftUI and Swift 5.9+. MagiNews provides real-time news from RSS feeds with advanced features like AI summarization, smart caching, and personalized reading experience.

## ✨ Features

### 🗞️ Core News Features
- 📰 **Real-time RSS Feed Integration** - Multiple Baltic/Nordic news sources
- 🔍 **Advanced Search & Filtering** - Search across all articles with category filtering
- 💾 **Smart Offline Caching** - Intelligent cache management with 6-hour expiry
- 🔖 **Bookmark Management** - Centralized bookmark system with cross-view synchronization
- 📱 **Responsive Grid Layout** - Modern card-based design with consistent aspect ratios

### 🎨 User Experience
- 🌙 **Dark Mode Support** - Custom color assets with light/dark variants
- 🎯 **Personalized Interface** - Customizable themes and accent colors
- 📱 **Modern SwiftUI Design** - Clean, intuitive interface following iOS design guidelines
- 🔄 **Pull-to-Refresh** - Seamless content updates with visual feedback

### 🤖 AI & Intelligence
- 🧠 **AI Article Summarization** - OpenAI-powered content summarization
- 🌍 **Multi-language Translation** - Translate articles between multiple languages
- 📊 **Smart Content Analysis** - Intelligent article categorization and relevance scoring
- 🎯 **Personalized Recommendations** - AI-driven content suggestions

### 📚 Content Management
- 📖 **Related Articles** - "You May Also Like" section with smart relevance scoring
- 🕒 **Recently Viewed History** - Track last 5 opened articles with persistent storage
- 📅 **Daily Digest** - Curated daily news summaries
- 🏷️ **Category Management** - Organized content with regional and topic filtering

### ⚙️ Advanced Features
- 🔐 **Secure API Management** - Protected API key configuration
- 📊 **Cache Analytics** - Detailed cache statistics and management
- 🌐 **Multi-region Support** - Baltic and Nordic news coverage
- 📱 **Voice Reading** - Text-to-speech functionality for articles

## 🏗️ Technical Architecture

### **Platform & Requirements**
- **Platform**: iOS 17.0+
- **Framework**: SwiftUI
- **Language**: Swift 5.9+
- **Architecture**: MVVM with ObservableObject
- **Data Storage**: UserDefaults, AppStorage, Core Data
- **Minimum iOS**: 17.0

### **Core Components**
- **Services Layer**: RSS parsing, AI integration, caching, translation
- **Managers**: Bookmark management, theme management, language management
- **Views**: Modular SwiftUI components with reusable design patterns
- **Models**: Clean data models with Codable conformance

## 🚀 Installation & Setup

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ Simulator or device
- macOS 14.0+
- OpenAI API key (for AI features)

### Quick Start
1. **Clone the repository:**
```bash
git clone https://github.com/MagnusMagi/MagiNews.git
cd MagiNews
```

2. **Open in Xcode:**
```bash
open MagiNewsIOS.xcodeproj
```

3. **Configure API Keys:**
   - Add your OpenAI API key in `APIKeyConfigView`
   - Configure RSS feed sources if needed

4. **Build and Run:**
   - Select target device/simulator
   - Press ⌘+R to build and run

## 📁 Project Structure

```
MagiNewsIOS/
├── 📱 App/
│   ├── MagiNewsIOSApp.swift          # Main app entry point
│   ├── Info.plist                    # App configuration
│   └── MagiNewsIOS.entitlements     # App capabilities
├── 🏗️ Models/
│   └── NewsModels.swift              # Data models and structures
├── 🎨 Views/
│   ├── MainGridView.swift            # Primary news grid
│   ├── ArticleDetailView.swift       # Article reading view
│   ├── ProfileView.swift             # User settings & preferences
│   ├── SearchView.swift              # Search functionality
│   ├── BookmarksView.swift           # Saved articles
│   └── Profile/                      # Profile-related components
├── 🔧 Services/
│   ├── RSSService.swift              # RSS feed parsing
│   ├── NewsRepository.swift          # Data management
│   ├── NewsCacheManager.swift        # Smart caching
│   ├── SummarizationService.swift    # AI summarization
│   ├── TranslationService.swift      # Multi-language support
│   └── RecentlyViewedService.swift   # Reading history
├── 🎛️ Managers/
│   ├── BookmarkManager.swift         # Bookmark management
│   ├── ThemeManager.swift            # Theme & appearance
│   └── LanguageManager.swift         # Localization
├── 🧩 Components/
│   ├── NewsCardView.swift            # Article card component
│   ├── CardSection.swift             # Reusable section wrapper
│   └── AvatarView.swift              # Profile avatar component
├── 🚀 Features/
│   ├── VoiceReader.swift             # Text-to-speech
│   └── BookmarkAIHandler.swift      # AI bookmark features
├── 🎨 Assets/
│   └── Assets.xcassets/              # Images, colors, icons
└── 📚 Documentation/
    ├── README.md                     # This file
    ├── VERSIONING.md                 # Version history
    └── SETUP.md                      # Setup guide
```

## 🔧 Development

### Adding New Features
1. **Create feature branch:**
```bash
git checkout -b feature/new-feature-name
```

2. **Implement your changes**
3. **Test thoroughly**
4. **Commit with clear message:**
```bash
git commit -m "feat: add new feature description"
```

5. **Push and create Pull Request:**
```bash
git push origin feature/new-feature-name
```

### Code Style Guidelines
- **SwiftUI**: Use modern SwiftUI patterns and modifiers
- **Architecture**: Follow MVVM with ObservableObject
- **Naming**: Use descriptive names and clear documentation
- **Testing**: Include unit tests for new features

## 📱 Screenshots

*Screenshots will be added here*

## 🗺️ Roadmap

### ✅ Completed Features (v1.0.0)
- [x] Core RSS feed integration
- [x] AI-powered summarization
- [x] Dark mode with custom colors
- [x] Smart caching system
- [x] Bookmark management
- [x] Multi-language support
- [x] Related articles
- [x] Recently viewed history
- [x] Modern SwiftUI interface

### 🚧 In Development (v1.1.0)
- [ ] Push notifications
- [ ] Social media sharing
- [ ] Advanced search algorithms
- [ ] User profiles and preferences

### 🔮 Future Plans (v1.2.0+)
- [ ] App Store optimization
- [ ] Analytics integration
- [ ] Performance monitoring
- [ ] Advanced AI features
- [ ] Podcast integration
- [ ] Video news support

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Contribution Process
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

**Magnus Magi** - [GitHub](https://github.com/MagnusMagi)

## 🙏 Acknowledgments

- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - Modern UI framework
- [OpenAI](https://openai.com/) - AI services integration
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Icon system
- [RSS](https://en.wikipedia.org/wiki/RSS) - News feed standard

---

⭐ If you find this project useful, please give it a star!