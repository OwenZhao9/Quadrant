import Foundation
import SwiftUI

@Observable
class SettingsStore {
    var theme: AppTheme {
        didSet { save() }
    }
    var language: AppLanguage {
        didSet { save() }
    }
    var hideCompleted: Bool {
        didSet { save() }
    }
    
    let contactEmail = "zhaoningup@gmail.com"
    let appVersion = "v1.0.0"
    let buildNumber = "1"
    
    init() {
        let defaults = UserDefaults.standard
        if let themeRaw = defaults.string(forKey: "app_theme"),
           let theme = AppTheme(rawValue: themeRaw) {
            self.theme = theme
        } else {
            self.theme = .light
        }
        if let langRaw = defaults.string(forKey: "app_language"),
           let lang = AppLanguage(rawValue: langRaw) {
            self.language = lang
        } else {
            self.language = .chinese
        }
        self.hideCompleted = defaults.bool(forKey: "hide_completed")
    }
    
    var colorScheme: ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(theme.rawValue, forKey: "app_theme")
        defaults.set(language.rawValue, forKey: "app_language")
        defaults.set(hideCompleted, forKey: "hide_completed")
    }
}
