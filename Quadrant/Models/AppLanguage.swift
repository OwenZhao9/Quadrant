import Foundation

enum AppLanguage: String, Codable, CaseIterable {
    case chinese = "zh"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .chinese: return "中文"
        case .english: return "English"
        }
    }
}

enum AppTheme: String, Codable, CaseIterable {
    case light
    case dark
    case system
}
