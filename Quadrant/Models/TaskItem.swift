import Foundation

enum QuadrantType: Int, Codable, CaseIterable, Identifiable {
    case urgentImportant = 0
    case importantNotUrgent = 1
    case urgentNotImportant = 2
    case notUrgentNotImportant = 3
    
    var id: Int { rawValue }
    
    var color: String {
        switch self {
        case .urgentImportant: return "quadrantRed"
        case .importantNotUrgent: return "quadrantOrange"
        case .urgentNotImportant: return "quadrantGreen"
        case .notUrgentNotImportant: return "quadrantPurple"
        }
    }
    
    func localizedName(language: AppLanguage) -> String {
        switch self {
        case .urgentImportant:
            return language == .chinese ? "重要且紧急" : "Important & Urgent"
        case .importantNotUrgent:
            return language == .chinese ? "重要不紧急" : "Important Not Urgent"
        case .urgentNotImportant:
            return language == .chinese ? "紧急不重要" : "Urgent Not Important"
        case .notUrgentNotImportant:
            return language == .chinese ? "不重要不紧急" : "Not Important Not Urgent"
        }
    }
}

struct TaskItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var quadrant: QuadrantType
    var createdAt: Date
    var completedAt: Date?
    
    init(id: UUID = UUID(), title: String, quadrant: QuadrantType, isCompleted: Bool = false, createdAt: Date = Date(), completedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.quadrant = quadrant
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
