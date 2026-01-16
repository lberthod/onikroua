import Foundation

public enum RecommendedAction {
    case urgentReview(count: Int)
    case dailyMission(Mission)
    case continueLesson(Lesson)
    case reinforceArea(ContentArea)
    case explore
    
    public var title: String {
        switch self {
        case .urgentReview(let count):
            return "Révisions urgentes"
        case .dailyMission(let mission):
            return mission.title
        case .continueLesson(let lesson):
            return lesson.title
        case .reinforceArea(let area):
            return "Renforcer: \(area.displayName)"
        case .explore:
            return "Explorer le contenu"
        }
    }
    
    public var description: String {
        switch self {
        case .urgentReview(let count):
            return "Tu as \(count) révisions en retard. Commence maintenant!"
        case .dailyMission(let mission):
            return mission.description
        case .continueLesson(let lesson):
            return "Continue ton parcours: \(lesson.description)"
        case .reinforceArea(let area):
            return "Pratique \(area.displayName) pour améliorer tes compétences"
        case .explore:
            return "Découvre du nouveau contenu à ton rythme"
        }
    }
    
    public var icon: String {
        switch self {
        case .urgentReview:
            return "exclamationmark.triangle.fill"
        case .dailyMission:
            return "target"
        case .continueLesson:
            return "book.fill"
        case .reinforceArea:
            return "arrow.up.circle.fill"
        case .explore:
            return "safari.fill"
        }
    }
    
    public var estimatedTime: Int {
        switch self {
        case .urgentReview(let count):
            return min(count * 30 / 60, 30)
        case .dailyMission(let mission):
            return mission.estimatedTime
        case .continueLesson(let lesson):
            return lesson.estimatedDuration
        case .reinforceArea:
            return 15
        case .explore:
            return 10
        }
    }
    
    public var priority: Int {
        switch self {
        case .urgentReview: return 5
        case .dailyMission: return 4
        case .continueLesson: return 3
        case .reinforceArea: return 2
        case .explore: return 1
        }
    }
}

public enum ContentArea: String, CaseIterable {
    case vocabulary
    case grammar
    case conjugation
    case conversation
    case listening
    case general
    
    public var displayName: String {
        switch self {
        case .vocabulary: return "le vocabulaire"
        case .grammar: return "la grammaire"
        case .conjugation: return "la conjugaison"
        case .conversation: return "la conversation"
        case .listening: return "la compréhension orale"
        case .general: return "tous les domaines"
        }
    }
    
    public var icon: String {
        switch self {
        case .vocabulary: return "text.book.closed.fill"
        case .grammar: return "text.alignleft"
        case .conjugation: return "book.fill"
        case .conversation: return "message.fill"
        case .listening: return "ear.fill"
        case .general: return "star.fill"
        }
    }
}

public struct RecommendedContent: Identifiable {
    public let id: String
    public let type: ContentType
    public let title: String
    public let difficulty: CEFRLevel
    public let reason: String
    public let estimatedTime: Int
    public let relevanceScore: Double
    
    public init(id: String, type: ContentType, title: String, difficulty: CEFRLevel, reason: String, estimatedTime: Int, relevanceScore: Double) {
        self.id = id
        self.type = type
        self.title = title
        self.difficulty = difficulty
        self.reason = reason
        self.estimatedTime = estimatedTime
        self.relevanceScore = relevanceScore
    }
    
    public enum ContentType: String {
        case vocabulary
        case grammar
        case conjugation
        case conversation
        case exercise
        case lesson
    }
}
