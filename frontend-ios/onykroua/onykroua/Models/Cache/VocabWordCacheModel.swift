import Foundation
import SwiftData
import onykroua

@Model
public final class VocabWordCacheModel {
    @Attribute(.unique) public var id: String
    public var userId: String
    public var wordId: String
    public var status: String
    public var strength: Int
    public var lastSeenAt: Int64
    public var reviewCount: Int
    public var correctCount: Int
    public var updatedAt: Int64
    public var lastSyncedAt: Int64
    public var dirty: Bool
    public var pendingSync: Bool
    
    public init(
        id: String,
        userId: String,
        wordId: String,
        status: String = "new",
        strength: Int = 0,
        lastSeenAt: Int64 = 0,
        reviewCount: Int = 0,
        correctCount: Int = 0,
        updatedAt: Int64 = TimestampMapper.currentDateMilliseconds(),
        lastSyncedAt: Int64 = 0,
        dirty: Bool = false,
        pendingSync: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.wordId = wordId
        self.status = status
        self.strength = strength
        self.lastSeenAt = lastSeenAt
        self.reviewCount = reviewCount
        self.correctCount = correctCount
        self.updatedAt = updatedAt
        self.lastSyncedAt = lastSyncedAt
        self.dirty = dirty
        self.pendingSync = pendingSync
    }
}
