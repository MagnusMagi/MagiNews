# MagiNews iOS App Setup Guide

## OpenAI API Configuration

To use AI-powered features like article summarization and translation, you need to configure your OpenAI API key:

1. **Get an OpenAI API Key:**
   - Visit [OpenAI Platform](https://platform.openai.com/api-keys)
   - Create a new API key
   - Copy the key (starts with `sk-`)

2. **Configure the API Key:**
   - Open `MagiNewsIOS/Services/SummarizationService.swift`
   - Find line 70: `self.apiKey = "YOUR_OPENAI_API_KEY_HERE"`
   - Replace `"YOUR_OPENAI_API_KEY_HERE"` with your actual API key
   - Example: `self.apiKey = "sk-your-actual-api-key-here"`

3. **Security Note:**
   - Never commit your API key to version control
   - In production, use secure storage or environment variables
   - The current setup is for development purposes only

## Localization Setup

The app supports multiple languages:
- 🇺🇸 English (en)
- 🇪🇪 Estonian (et)
- 🇱🇻 Latvian (lv)
- 🇱🇹 Lithuanian (lt)
- 🇫🇮 Finnish (fi)

Localization files are located in `MagiNewsIOS/Resources/[language].lproj/`

## Build and Run

1. Open `MagiNewsIOS.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project (⌘+R)

## Features

- **RSS Feed Integration:** Fetches news from Baltic and Nordic region sources
- **AI Summarization:** Uses OpenAI GPT for article summaries
- **Multi-language Support:** Localized UI and content
- **Offline Caching:** Stores articles locally for offline reading
- **Bookmarking:** Save articles for later reading
- **Dark Mode:** Automatic theme switching
- **Responsive Design:** Optimized for iPhone and iPad

## Troubleshooting

- **Build Errors:** Ensure all dependencies are properly linked
- **API Errors:** Verify your OpenAI API key is correct and has sufficient credits
- **Localization Issues:** Check that all `.lproj` folders are included in the build target
