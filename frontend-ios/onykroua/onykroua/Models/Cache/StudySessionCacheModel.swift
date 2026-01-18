import Foundation
import SwiftData
import onykroua

@Model
public final class StudySessionCacheModel {
    @Attribute(.unique) public var id: String
    public var userId: String
    public var sessionId: String
    public var startedAt: Int64
    public var endedAt: Int64
    public var itemsCount: Int
    public var correctCount: Int
    public var xpGained: Int
    public var activityType: String
    public var updatedAt: Int64
    public var lastSyncedAt: Int64
    public var dirty: Bool
    public var pendingSync: Bool
    
    public init(
        id: String,
        userId: String,
        sessionId: String,
        startedAt: Int64,
        endedAt: Int64,
        itemsCount: Int = 0,
        correctCount: Int = 0,
        xpGained: Int = 0,
        activityType: String,
        updatedAt: Int64 = TimestampMapper.currentDateMilliseconds(),
        lastSyncedAt: Int64 = 0,
        dirty: Bool = false,
        pendingSync: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.sessionId = sessionId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.itemsCount = itemsCount
        self.correctCount = correctCount
        self.xpGained = xpGained
        self.activityType = activityType
        self.updatedAt = updatedAt
        self.lastSyncedAt = lastSyncedAt
        self.dirty = dirty
        self.pendingSync = pendingSync
    }
}
