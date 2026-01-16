import Foundation
import SwiftData

@Model
public final class DailySession {
    public var date: Date
    public var missionType: String
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
        date: Date = Date(),
        missionType: MissionType = .review,
        missionCompleted: Bool = false,
        reviewsDue: Int = 0,
        reviewsCompleted: Int = 0,
        lessonsCompleted: Int = 0,
        xpEarned: Int = 0,
        timeSpent: Int = 0,
        streakMaintained: Bool = false
    ) {
        self.date = date
        self.missionType = missionType.rawValue
        self.missionCompleted = missionCompleted
        self.reviewsDue = reviewsDue
        self.reviewsCompleted = reviewsCompleted
        self.lessonsCompleted = lessonsCompleted
        self.xpEarned = xpEarned
        self.timeSpent = timeSpent
        self.streakMaintained = streakMaintained
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public var type: MissionType {
        get { MissionType(rawValue: missionType) ?? .review }
        set { missionType = newValue.rawValue }
    }
    
    public func completeMission(xp: Int = 0) {
        missionCompleted = true
        xpEarned += xp
        updatedAt = Date()
    }
    
    public func addTimeSpent(seconds: Int) {
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

public struct Mission: Identifiable {
    public let id: UUID
    public let type: DailySession.MissionType
    public let title: String
    public let description: String
    public let estimatedTime: Int
    public let xpReward: Int
    public let targetCount: Int
    public var currentCount: Int
    public let contentIds: [String]
    
    public init(
        type: DailySession.MissionType,
        title: String,
        description: String,
        estimatedTime: Int,
        xpReward: Int,
        targetCount: Int,
        currentCount: Int = 0,
        contentIds: [String] = []
    ) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.description = description
        self.estimatedTime = estimatedTime
        self.xpReward = xpReward
        self.targetCount = targetCount
        self.currentCount = currentCount
        self.contentIds = contentIds
    }
    
    public var progress: Double {
        guard targetCount > 0 else { return 0 }
        return Double(currentCount) / Double(targetCount)
    }
    
    public var isCompleted: Bool {
        return currentCount >= targetCount
    }
    
    public mutating func incrementProgress(by amount: Int = 1) {
        currentCount = min(currentCount + amount, targetCount)
    }
}
