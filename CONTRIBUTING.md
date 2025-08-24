# 🤝 Contributing to MagiNews iOS

Thank you for your interest in contributing to MagiNews iOS! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Code Style](#code-style)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)
- [Feature Requests](#feature-requests)

## 📜 Code of Conduct

This project and its participants are governed by our Code of Conduct. By participating, you are expected to uphold this code.

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ Simulator or device
- macOS 14.0+
- Git
- Basic knowledge of SwiftUI and iOS development

### Fork and Clone
1. Fork the repository on GitHub
2. Clone your fork locally:
```bash
git clone https://github.com/YOUR_USERNAME/MagiNews.git
cd MagiNews
```

3. Add the upstream remote:
```bash
git remote add upstream https://github.com/MagnusMagi/MagiNews.git
```

## 🔧 Development Setup

### 1. Open the Project
```bash
open MagiNewsIOS.xcodeproj
```

### 2. Configure API Keys
- Add your OpenAI API key in `APIKeyConfigView`
- Configure RSS feed sources if needed

### 3. Build and Test
- Select target device/simulator
- Build the project (⌘+B)
- Run on simulator/device (⌘+R)

## 📝 Contributing Guidelines

### Types of Contributions
We welcome various types of contributions:

- **Bug Reports** - Report bugs and issues
- **Feature Requests** - Suggest new features
- **Code Contributions** - Submit code improvements
- **Documentation** - Improve documentation
- **Testing** - Add or improve tests
- **UI/UX Improvements** - Enhance user experience

### Before You Start
1. Check existing issues and pull requests
2. Discuss major changes in an issue first
3. Ensure your contribution aligns with project goals
4. Follow the established code style and architecture

## 🎨 Code Style

### SwiftUI Guidelines
- Use modern SwiftUI patterns and modifiers
- Prefer declarative over imperative code
- Use proper state management (@State, @StateObject, @EnvironmentObject)
- Follow SwiftUI lifecycle best practices

### Architecture Guidelines
- Follow MVVM pattern with ObservableObject
- Keep views focused and single-purpose
- Use dependency injection where appropriate
- Maintain clean separation of concerns

### Naming Conventions
- Use descriptive, clear names
- Follow Swift naming conventions
- Use camelCase for variables and functions
- Use PascalCase for types and protocols

### Code Organization
```swift
// MARK: - Properties
@State private var isLoading = false

// MARK: - Computed Properties
var formattedDate: String {
    // Implementation
}

// MARK: - Methods
func loadData() {
    // Implementation
}

// MARK: - Private Methods
private func setupUI() {
    // Implementation
}
```

## 🧪 Testing

### Unit Tests
- Write tests for new features
- Ensure existing tests pass
- Aim for good test coverage
- Use descriptive test names

### UI Tests
- Test critical user flows
- Verify accessibility features
- Test on different device sizes

### Running Tests
```bash
# Run all tests
xcodebuild test -project MagiNewsIOS.xcodeproj -scheme MagiNewsIOS -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test target
xcodebuild test -project MagiNewsIOS.xcodeproj -scheme MagiNewsIOS -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MagiNewsIOSTests
```

## 🔄 Pull Request Process

### 1. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 2. Make Your Changes
- Implement your feature or fix
- Follow code style guidelines
- Add appropriate tests
- Update documentation if needed

### 3. Commit Your Changes
Use conventional commit format:
```bash
git commit -m "feat: add new feature description"
git commit -m "fix: resolve issue description"
git commit -m "docs: update documentation"
git commit -m "refactor: improve code structure"
```

### 4. Push and Create PR
```bash
git push origin feature/your-feature-name
```

### 5. Pull Request Guidelines
- Provide clear description of changes
- Include screenshots for UI changes
- Reference related issues
- Ensure all tests pass
- Request review from maintainers

## 🐛 Reporting Issues

### Bug Report Template
```markdown
**Bug Description**
Clear description of the bug

**Steps to Reproduce**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- iOS Version: [e.g., 17.0]
- Device: [e.g., iPhone 16]
- App Version: [e.g., 1.0.0]

**Additional Information**
Screenshots, logs, etc.
```

### Issue Labels
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed

## 💡 Feature Requests

### Feature Request Template
```markdown
**Feature Description**
Clear description of the feature

**Use Case**
Why this feature would be useful

**Proposed Solution**
How you think it should work

**Alternatives Considered**
Other solutions you've considered

**Additional Information**
Screenshots, mockups, etc.
```

## 📚 Documentation

### Updating Documentation
- Keep README.md current
- Update VERSIONING.md for new features
- Add inline code documentation
- Update setup instructions if needed

### Documentation Standards
- Use clear, concise language
- Include code examples
- Add screenshots for UI features
- Keep information up-to-date

## 🏷️ Version Management

### Version Bumping
- **Patch** (0.0.X) - Bug fixes and minor improvements
- **Minor** (0.X.0) - New features, backward compatible
- **Major** (X.0.0) - Breaking changes

### Release Process
1. Update version numbers
2. Create git tag
3. Push tag to remote
4. Create GitHub release
5. Update documentation

## 🤝 Community

### Communication
- Be respectful and inclusive
- Use clear, constructive language
- Help other contributors
- Share knowledge and best practices

### Recognition
- Contributors will be credited in releases
- Significant contributions may earn maintainer status
- All contributions are appreciated and valued

## 📞 Getting Help

### Resources
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [iOS Development Guide](https://developer.apple.com/ios/)
- [GitHub Issues](https://github.com/MagnusMagi/MagiNews/issues)
- [Project Discussions](https://github.com/MagnusMagi/MagiNews/discussions)

### Contact
- Create an issue for questions
- Use discussions for general topics
- Tag maintainers for urgent issues

---

Thank you for contributing to MagiNews iOS! 🎉

Your contributions help make this project better for everyone.
