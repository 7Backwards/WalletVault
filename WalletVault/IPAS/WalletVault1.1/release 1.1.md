WalletVault Release 1.1 - What's New

🎨 Rebranding & UI Modernization
* Renamed App: Officially renamed the project from SafeWallet to WalletVault.
* iOS 18+ Aesthetics: Applied extensive UI modernization features including glassmorphism effects.
* Polish: Updated the navigation bar to use large titles and improved the empty state layout to be perfectly centered.

✨ New Features
* Enhanced Security: Implemented `KeychainService` for secure storage of card data.
* Smart Card Detection: Added detection and validation rules for American Express and Discover cards.
* Better Defaults: New cards now assign the first available default color instead of a hardcoded grey.
* Card Sharing: Added a fallback mechanism to support previous app versions when sharing cards.

🛠️ Core & Infrastructure
* Min iOS Version: Bumped the minimum iOS deployment target to iOS 16.
* Data Model: Added the SafeWallet Core Data model alongside the new WalletVault model to support migration.
* Localization: Fully localized alert and error messages across the application.

✅ Testing & Quality
* UI Tests: Implemented comprehensive UI tests for card management and search functionality.
* Unit Tests: Added extensive unit tests for ViewModels and expanded existing test suites.

📄 Documentation
* README: Streamlined the documentation, updated App Store information, and refreshed screenshots.
