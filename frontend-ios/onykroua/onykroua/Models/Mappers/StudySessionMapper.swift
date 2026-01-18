import Foundation

public enum StudySessionMapper {
    
    public static func toDTO(_ domain: StudySession) -> StudySessionDTO {
        return StudySessionDTO(
            sessionId: domain.id,
            startedAt: TimestampMapper.toMilliseconds(domain.date),
            endedAt: TimestampMapper.toMilliseconds(domain.date),
            itemsCount: domain.reviewsDue + domain.lessonsCompleted,
            correctCount: domain.reviewsCompleted,
            xpGained: domain.xpEarned,
            activityType: domain.missionType.rawValue,
            updatedAt: TimestampMapper.toMilliseconds(domain.updatedAt)
        )
    }
    
    public static func fromDTO(_ dto: StudySessionDTO, userId: String) -> StudySession {
        return StudySession(
            id: dto.sessionId,
            userId: userId,
            date: TimestampMapper.fromMilliseconds(dto.startedAt),
            missionType: StudySession.MissionType(rawValue: dto.activityType) ?? .review,
            missionCompleted: true,
            reviewsDue: dto.itemsCount,
            reviewsCompleted: dto.correctCount,
            lessonsCompleted: 0,
            xpEarned: dto.xpGained,
            timeSpent: Int((dto.endedAt - dto.startedAt) / 1000),
            streakMaintained: false,
            createdAt: TimestampMapper.fromMilliseconds(dto.startedAt),
            updatedAt: TimestampMapper.fromMilliseconds(dto.updatedAt)
        )
    }
    
    public static func toCache(_ domain: StudySession, into cache: StudySessionCacheModel? = nil) -> StudySessionCacheModel {
        let model = cache ?? StudySessionCacheModel(
            id: "\(domain.userId)_\(domain.id)",
            userId: domain.userId,
            sessionId: domain.id,
            startedAt: TimestampMapper.toMilliseconds(domain.date),
            endedAt: TimestampMapper.toMilliseconds(domain.date),
            activityType: domain.missionType.rawValue
        )
        
        model.id = "\(domain.userId)_\(domain.id)"
        model.userId = domain.userId
        model.sessionId = domain.id
        model.startedAt = TimestampMapper.toMilliseconds(domain.date)
        model.endedAt = TimestampMapper.toMilliseconds(domain.date)
        model.itemsCount = domain.reviewsDue + domain.lessonsCompleted
        model.correctCount = domain.reviewsCompleted
        model.xpGained = domain.xpEarned
        model.activityType = domain.missionType.rawValue
        model.updatedAt = TimestampMapper.toMilliseconds(domain.updatedAt)
        model.lastSyncedAt = TimestampMapper.currentDateMilliseconds()
        model.dirty = false
        model.pendingSync = false
        
        return model
    }
    
    public static func fromCache(_ cache: StudySessionCacheModel) -> StudySession {
        return StudySession(
            id: cache.sessionId,
            userId: cache.userId,
            date: TimestampMapper.fromMilliseconds(cache.startedAt),
            missionType: StudySession.MissionType(rawValue: cache.activityType) ?? .review,
            missionCompleted: true,
            reviewsDue: cache.itemsCount,
            reviewsCompleted: cache.correctCount,
            lessonsCompleted: 0,
            xpEarned: cache.xpGained,
            timeSpent: Int((cache.endedAt - cache.startedAt) / 1000),
            streakMaintained: false,
            createdAt: TimestampMapper.fromMilliseconds(cache.startedAt),
            updatedAt: TimestampMapper.fromMilliseconds(cache.updatedAt)
        )
    }
}
