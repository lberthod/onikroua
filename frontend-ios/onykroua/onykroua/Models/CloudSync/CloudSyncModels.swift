import Foundation
import SwiftData

@Model
final class CachedAchievement {
    @Attribute(.unique) var id: String
    var userId: String
    var achievementId: String
    var unlocked: Bool
    var unlockedAt: Int64?
    var progress: Double
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
        self.lastSyncAt = TimestampMapper.currentDateMilliseconds()
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
        self.lastSyncAt = TimestampMapper.currentDateMilliseconds()
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
    
    init(userId: String, dto: StudySessionDTO) {
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
        self.lastSyncAt = TimestampMapper.currentDateMilliseconds()
    }
    
    func toDTO() -> StudySessionDTO {
        return StudySessionDTO(
            sessionId: sessionId,
            startedAt: startedAt,
            endedAt: endedAt,
            itemsCount: itemsCount,
            correctCount: correctCount,
            xpGained: xpGained,
            activityType: activityType,
            updatedAt: updatedAt
        )
    }
    
    func updateFrom(dto: StudySessionDTO) {
        self.startedAt = dto.startedAt
        self.endedAt = dto.endedAt
        self.itemsCount = dto.itemsCount
        self.correctCount = dto.correctCount
        self.xpGained = dto.xpGained
        self.activityType = dto.activityType
        self.updatedAt = dto.updatedAt
        self.lastSyncAt = TimestampMapper.currentDateMilliseconds()
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
    var updatedAt: Int64
    
    init(userId: String) {
        self.userId = userId
        self.updatedAt = TimestampMapper.currentDateMilliseconds()
    }
    
    func updateProgressSync() {
        self.lastProgressSyncAt = TimestampMapper.currentDateMilliseconds()
        self.updatedAt = TimestampMapper.currentDateMilliseconds()
    }
    
    func updateVocabSync() {
        self.lastVocabSyncAt = TimestampMapper.currentDateMilliseconds()
        self.updatedAt = TimestampMapper.currentDateMilliseconds()
    }
    
    func updateAchievementsSync() {
        self.lastAchievementsSyncAt = TimestampMapper.currentDateMilliseconds()
        self.updatedAt = TimestampMapper.currentDateMilliseconds()
    }
    
    func updateSessionsSync() {
        self.lastSessionsSyncAt = TimestampMapper.currentDateMilliseconds()
        self.updatedAt = TimestampMapper.currentDateMilliseconds()
    }
    
    func updateFullSync() {
        self.lastFullSyncAt = TimestampMapper.currentDateMilliseconds()
        self.updatedAt = TimestampMapper.currentDateMilliseconds()
    }
}
