import Foundation
import SwiftData
import onykroua

@Model
public final class UserProgressCacheModel {
    @Attribute(.unique) public var userId: String
    public var level: Int
    public var xp: Int
    public var streakDays: Int
    public var longestStreak: Int
    public var lastStudyAt: Int64
    public var wordsLearned: Int
    public var wordsReviewed: Int
    public var lessonsCompleted: Int
    public var quizzesCompleted: Int
    public var quizzesCorrect: Int
    public var conversationsCompleted: Int
    public var grammarRulesLearned: Int
    public var verbsLearned: Int
    public var studyTimeMinutes: Int
    public var sessionsCompleted: Int
    public var updatedAt: Int64
    public var lastSyncedAt: Int64
    public var dirty: Bool
    public var pendingSync: Bool
    
    public init(
        userId: String,
        level: Int = 1,
        xp: Int = 0,
        streakDays: Int = 0,
        longestStreak: Int = 0,
        lastStudyAt: Int64 = 0,
        wordsLearned: Int = 0,
        wordsReviewed: Int = 0,
        lessonsCompleted: Int = 0,
        quizzesCompleted: Int = 0,
        quizzesCorrect: Int = 0,
        conversationsCompleted: Int = 0,
        grammarRulesLearned: Int = 0,
        verbsLearned: Int = 0,
        studyTimeMinutes: Int = 0,
        sessionsCompleted: Int = 0,
        updatedAt: Int64 = TimestampMapper.currentDateMilliseconds(),
        lastSyncedAt: Int64 = 0,
        dirty: Bool = false,
        pendingSync: Bool = false
    ) {
        self.userId = userId
        self.level = level
        self.xp = xp
        self.streakDays = streakDays
        self.longestStreak = longestStreak
        self.lastStudyAt = lastStudyAt
        self.wordsLearned = wordsLearned
        self.wordsReviewed = wordsReviewed
        self.lessonsCompleted = lessonsCompleted
        self.quizzesCompleted = quizzesCompleted
        self.quizzesCorrect = quizzesCorrect
        self.conversationsCompleted = conversationsCompleted
        self.grammarRulesLearned = grammarRulesLearned
        self.verbsLearned = verbsLearned
        self.studyTimeMinutes = studyTimeMinutes
        self.sessionsCompleted = sessionsCompleted
        self.updatedAt = updatedAt
        self.lastSyncedAt = lastSyncedAt
        self.dirty = dirty
        self.pendingSync = pendingSync
    }
}
