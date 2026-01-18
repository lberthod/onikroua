import Foundation

public enum UserProgressMapper {
    
    public static func toDTO(_ domain: UserProgress) -> UserProgressDTO {
        return UserProgressDTO(
            level: domain.levelNumber,
            xp: domain.currentXP,
            streakDays: domain.streak,
            longestStreak: domain.longestStreak,
            lastStudyAt: TimestampMapper.toMilliseconds(domain.lastStudyDate) ?? 0,
            wordsLearned: domain.wordsLearned,
            wordsReviewed: domain.wordsReviewed,
            lessonsCompleted: domain.lessonsCompleted,
            quizzesCompleted: domain.quizzesCompleted,
            quizzesCorrect: domain.quizzesCorrect,
            conversationsCompleted: domain.conversationsCompleted,
            grammarRulesLearned: domain.grammarRulesLearned,
            verbsLearned: domain.verbsLearned,
            studyTimeMinutes: domain.studyTimeMinutes,
            sessionsCompleted: domain.sessionsCompleted,
            updatedAt: TimestampMapper.toMilliseconds(domain.updatedAt)
        )
    }
    
    public static func fromDTO(_ dto: UserProgressDTO, userId: String) -> UserProgress {
        return UserProgress(
            id: UUID().uuidString,
            userId: userId,
            currentLevel: CEFRLevel.fromLevelNumber(dto.level).rawValue,
            currentXP: dto.xp,
            totalXP: dto.xp,
            wordsLearned: dto.wordsLearned,
            wordsReviewed: dto.wordsReviewed,
            lessonsCompleted: dto.lessonsCompleted,
            lastStudyDate: TimestampMapper.fromMilliseconds(dto.lastStudyAt),
            streak: dto.streakDays,
            longestStreak: dto.longestStreak,
            quizzesCompleted: dto.quizzesCompleted,
            quizzesCorrect: dto.quizzesCorrect,
            conversationsCompleted: dto.conversationsCompleted,
            grammarRulesLearned: dto.grammarRulesLearned,
            verbsLearned: dto.verbsLearned,
            studyTimeMinutes: dto.studyTimeMinutes,
            sessionsCompleted: dto.sessionsCompleted,
            createdAt: Date(),
            updatedAt: TimestampMapper.fromMilliseconds(dto.updatedAt)
        )
    }
    
    public static func toCache(_ domain: UserProgress, into cache: UserProgressCacheModel? = nil) -> UserProgressCacheModel {
        let model = cache ?? UserProgressCacheModel(userId: domain.userId)
        
        model.userId = domain.userId
        model.level = domain.levelNumber
        model.xp = domain.currentXP
        model.streakDays = domain.streak
        model.longestStreak = domain.longestStreak
        model.lastStudyAt = TimestampMapper.toMilliseconds(domain.lastStudyDate) ?? 0
        model.wordsLearned = domain.wordsLearned
        model.wordsReviewed = domain.wordsReviewed
        model.lessonsCompleted = domain.lessonsCompleted
        model.quizzesCompleted = domain.quizzesCompleted
        model.quizzesCorrect = domain.quizzesCorrect
        model.conversationsCompleted = domain.conversationsCompleted
        model.grammarRulesLearned = domain.grammarRulesLearned
        model.verbsLearned = domain.verbsLearned
        model.studyTimeMinutes = domain.studyTimeMinutes
        model.sessionsCompleted = domain.sessionsCompleted
        model.updatedAt = TimestampMapper.toMilliseconds(domain.updatedAt)
        model.lastSyncedAt = TimestampMapper.currentDateMilliseconds()
        model.dirty = false
        model.pendingSync = false
        
        return model
    }
    
    public static func fromCache(_ cache: UserProgressCacheModel) -> UserProgress {
        return UserProgress(
            id: UUID().uuidString,
            userId: cache.userId,
            currentLevel: CEFRLevel.fromLevelNumber(cache.level).rawValue,
            currentXP: cache.xp,
            totalXP: cache.xp,
            wordsLearned: cache.wordsLearned,
            wordsReviewed: cache.wordsReviewed,
            lessonsCompleted: cache.lessonsCompleted,
            lastStudyDate: TimestampMapper.fromMilliseconds(cache.lastStudyAt),
            streak: cache.streakDays,
            longestStreak: cache.longestStreak,
            quizzesCompleted: cache.quizzesCompleted,
            quizzesCorrect: cache.quizzesCorrect,
            conversationsCompleted: cache.conversationsCompleted,
            grammarRulesLearned: cache.grammarRulesLearned,
            verbsLearned: cache.verbsLearned,
            studyTimeMinutes: cache.studyTimeMinutes,
            sessionsCompleted: cache.sessionsCompleted,
            createdAt: Date(),
            updatedAt: TimestampMapper.fromMilliseconds(cache.updatedAt)
        )
    }
}
