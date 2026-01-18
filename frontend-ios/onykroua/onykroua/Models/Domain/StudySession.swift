import Foundation

public struct StudySession: Equatable, Identifiable, Codable {
    public let id: String
    public let userId: String
    public var date: Date
    public var missionType: MissionType
    public var missionCompleted: Bool
    public var reviewsDue: Int
    public var reviewsCompleted: Int
    public var lessonsCompleted: Int
    public var xpEarned: Int
    public var timeSpent: Int
    public var streakMaintained: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        userId: String,
        date: Date = Date(),
        missionType: MissionType = .review,
        missionCompleted: Bool = false,
        reviewsDue: Int = 0,
        reviewsCompleted: Int = 0,
        lessonsCompleted: Int = 0,
        xpEarned: Int = 0,
        timeSpent: Int = 0,
        streakMaintained: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.missionType = missionType
        self.missionCompleted = missionCompleted
        self.reviewsDue = reviewsDue
        self.reviewsCompleted = reviewsCompleted
        self.lessonsCompleted = lessonsCompleted
        self.xpEarned = xpEarned
        self.timeSpent = timeSpent
        self.streakMaintained = streakMaintained
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public mutating func completeMission(xp: Int = 0) {
        missionCompleted = true
        xpEarned += xp
        updatedAt = Date()
    }
    
    public mutating func addTimeSpent(seconds: Int) {
        timeSpent += seconds
        updatedAt = Date()
    }
    
    public enum MissionType: String, Codable, CaseIterable {
        case review
        case newLesson
        case practice
        case assessment
        case custom
        
        public var displayName: String {
            switch self {
            case .review: return "Révision"
            case .newLesson: return "Nouvelle leçon"
            case .practice: return "Pratique"
            case .assessment: return "Évaluation"
            case .custom: return "Mission personnalisée"
            }
        }
        
        public var icon: String {
            switch self {
            case .review: return "arrow.clockwise"
            case .newLesson: return "book.fill"
            case .practice: return "gamecontroller.fill"
            case .assessment: return "checkmark.seal.fill"
            case .custom: return "star.fill"
            }
        }
    }
}
