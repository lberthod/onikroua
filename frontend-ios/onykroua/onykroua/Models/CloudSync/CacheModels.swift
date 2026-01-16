import Foundation
import SwiftData

@Model
final class CachedUserProgress {
    @Attribute(.unique) var userId: String
    var level: Int
    var xp: Int
    var streakDays: Int
    var longestStreak: Int
    var lastStudyAt: Int64
    var wordsLearned: Int
    var wordsReviewed: Int
    var lessonsCompleted: Int
    var quizzesCompleted: Int
    var quizzesCorrect: Int
    var conversationsCompleted: Int
    var grammarRulesLearned: Int
    var verbsLearned: Int
    var studyTimeMinutes: Int
    var sessionsCompleted: Int
    var updatedAt: Int64
    var lastSyncAt: Int64
    
    init(userId: String, dto: UserProgressDTO) {
        self.userId = userId
        self.level = dto.level
        self.xp = dto.xp
        self.streakDays = dto.streakDays
        self.longestStreak = dto.longestStreak
        self.lastStudyAt = dto.lastStudyAt
        self.wordsLearned = dto.wordsLearned
        self.wordsReviewed = dto.wordsReviewed
        self.lessonsCompleted = dto.lessonsCompleted
        self.quizzesCompleted = dto.quizzesCompleted
        self.quizzesCorrect = dto.quizzesCorrect
        self.conversationsCompleted = dto.conversationsCompleted
        self.grammarRulesLearned = dto.grammarRulesLearned
        self.verbsLearned = dto.verbsLearned
        self.studyTimeMinutes = dto.studyTimeMinutes
        self.sessionsCompleted = dto.sessionsCompleted
        self.updatedAt = dto.updatedAt
        self.lastSyncAt = Date().toMilliseconds()
    }
    
    func toDTO() -> UserProgressDTO {
        return UserProgressDTO(
            level: level,
            xp: xp,
            streakDays: streakDays,
            longestStreak: longestStreak,
            lastStudyAt: lastStudyAt,
            wordsLearned: wordsLearned,
            wordsReviewed: wordsReviewed,
            lessonsCompleted: lessonsCompleted,
            quizzesCompleted: quizzesCompleted,
            quizzesCorrect: quizzesCorrect,
            conversationsCompleted: conversationsCompleted,
            grammarRulesLearned: grammarRulesLearned,
            verbsLearned: verbsLearned,
            studyTimeMinutes: studyTimeMinutes,
            sessionsCompleted: sessionsCompleted,
            updatedAt: updatedAt
        )
    }
    
    func updateFrom(dto: UserProgressDTO) {
        self.level = dto.level
        self.xp = dto.xp
        self.streakDays = dto.streakDays
        self.longestStreak = dto.longestStreak
        self.lastStudyAt = dto.lastStudyAt
        self.wordsLearned = dto.wordsLearned
        self.wordsReviewed = dto.wordsReviewed
        self.lessonsCompleted = dto.lessonsCompleted
        self.quizzesCompleted = dto.quizzesCompleted
        self.quizzesCorrect = dto.quizzesCorrect
        self.conversationsCompleted = dto.conversationsCompleted
        self.grammarRulesLearned = dto.grammarRulesLearned
        self.verbsLearned = dto.verbsLearned
        self.studyTimeMinutes = dto.studyTimeMinutes
        self.sessionsCompleted = dto.sessionsCompleted
        self.updatedAt = dto.updatedAt
        self.lastSyncAt = Date().toMilliseconds()
    }
}

@Model
final class CachedVocabWord {
    @Attribute(.unique) var id: String
    var userId: String
    var wordId: String
    var status: String
    var strength: Int
    var lastSeenAt: Int64
    var reviewCount: Int
    var correctCount: Int
    var updatedAt: Int64
    var lastSyncAt: Int64
    
    init(userId: String, dto: VocabWordDTO) {
        self.id = "\(userId)_\(dto.wordId)"
        self.userId = userId
        self.wordId = dto.wordId
        self.status = dto.status
        self.strength = dto.strength
        self.lastSeenAt = dto.lastSeenAt
        self.reviewCount = dto.reviewCount
        self.correctCount = dto.correctCount
        self.updatedAt = dto.updatedAt
        self.lastSyncAt = Date().toMilliseconds()
    }
    
    func toDTO() -> VocabWordDTO {
        return VocabWordDTO(
            wordId: wordId,
            status: status,
            strength: strength,
            lastSeenAt: lastSeenAt,
            reviewCount: reviewCount,
            correctCount: correctCount,
            updatedAt: updatedAt
        )
    }
    
    func updateFrom(dto: VocabWordDTO) {
        self.status = dto.status
        self.strength = dto.strength
        self.lastSeenAt = dto.lastSeenAt
        self.reviewCount = dto.reviewCount
        self.correctCount = dto.correctCount
        self.updatedAt = dto.updatedAt
        self.lastSyncAt = Date().toMilliseconds()
    }
}

@Model
final class CachedAchievement {
    @Attribute(.unique) var id: String
    var userId: String
    var achievementId: String
    var unlocked: Bool
    var unlockedAt: Int64?
    var progress: Int
    var updatedAt: Int64
    var lastSyncAt: Int64
    
    init(userId: String, dto: AchievementDTO) {
        self.id = "\(userId)_\(dto.achievementId)"
        self.userId = userId
        self.achievementId = dto.achievementId
        self.unlocked = dto.unlocked
        self.unlockedAt = dto.unlockedAt
        self.progress = dto.progress
        self.updatedAt = dto.updatedAt
        self.lastSyncAt = Date().toMilliseconds()
    }
    
    func toDTO() -> AchievementDTO {
        return AchievementDTO(
            achievementId: achievementId,
            unlocked: unlocked,
            unlockedAt: unlockedAt,
            progress: progress,
            updatedAt: updatedAt
        )
    }
    
    func updateFrom(dto: AchievementDTO) {
        self.unlocked = dto.unlocked
        self.unlockedAt = dto.unlockedAt
        self.progress = dto.progress
        self.updatedAt = dto.updatedAt
        self.lastSyncAt = Date().toMilliseconds()
    }
}

@Model
final class CachedSession {
    @Attribute(.unique) var id: String
    var userId: String
    var sessionId: String
    var startedAt: Int64
    var endedAt: Int64
    var itemsCount: Int
    var correctCount: Int
    var xpGained: Int
    var activityType: String
    var updatedAt: Int64
    var lastSyncAt: Int64
    
    init(userId: String, dto: SessionDTO) {
        self.id = "\(userId)_\(dto.sessionId)"
        self.userId = userId
        self.sessionId = dto.sessionId
        self.startedAt = dto.startedAt
        self.endedAt = dto.endedAt
        self.itemsCount = dto.itemsCount
        self.correctCount = dto.correctCount
        self.xpGained = dto.xpGained
        self.activityType = dto.activityType
        self.updatedAt = dto.updatedAt
        self.lastSyncAt = Date().toMilliseconds()
    }
    
    func updateFrom(dto: SessionDTO) {
        self.startedAt = dto.startedAt
        self.endedAt = dto.endedAt
        self.itemsCount = dto.itemsCount
        self.correctCount = dto.correctCount
        self.xpGained = dto.xpGained
        self.activityType = dto.activityType
        self.updatedAt = dto.updatedAt
        self.lastSyncAt = Date().toMilliseconds()
    }
}

@Model
final class SyncOutboxItem {
    @Attribute(.unique) var id: String
    var userId: String
    var path: String
    var payloadJSON: String
    var updatedAt: Int64
    var attempts: Int
    var lastError: String?
    var createdAt: Int64
    var lastAttemptAt: Int64?
    
    init(userId: String, path: String, payload: [String: Any], updatedAt: Int64? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.path = path
        self.updatedAt = updatedAt ?? Date().toMilliseconds()
        self.attempts = 0
        self.createdAt = Date().toMilliseconds()
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            self.payloadJSON = jsonString
        } else {
            self.payloadJSON = "{}"
        }
    }
    
    func getPayload() -> [String: Any]? {
        guard let data = payloadJSON.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dict
    }
    
    func recordAttempt(error: String? = nil) {
        self.attempts += 1
        self.lastAttemptAt = Date().toMilliseconds()
        self.lastError = error
    }
}

@Model
final class SyncMetadata {
    @Attribute(.unique) var userId: String
    var lastFullSyncAt: Int64?
    var lastProgressSyncAt: Int64?
    var lastVocabSyncAt: Int64?
    var lastAchievementsSyncAt: Int64?
    var lastSessionsSyncAt: Int64?
    
    init(userId: String) {
        self.userId = userId
    }
}
