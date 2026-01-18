import Foundation

public enum VocabWordMapper {
    
    public static func toDTO(_ domain: VocabWord, status: String = "new", strength: Int = 0, lastSeenAt: Int64 = 0, reviewCount: Int = 0, correctCount: Int = 0) -> VocabWordDTO {
        return VocabWordDTO(
            wordId: domain.id,
            status: status,
            strength: strength,
            lastSeenAt: lastSeenAt,
            reviewCount: reviewCount,
            correctCount: correctCount,
            updatedAt: TimestampMapper.currentDateMilliseconds()
        )
    }
    
    public static func fromDTO(_ dto: VocabWordDTO, word: VocabWord) -> VocabWord {
        return word
    }
    
    public static func toCache(_ domain: VocabWord, userId: String, status: String = "new", strength: Int = 0, lastSeenAt: Int64 = 0, reviewCount: Int = 0, correctCount: Int = 0, into cache: VocabWordCacheModel? = nil) -> VocabWordCacheModel {
        let model = cache ?? VocabWordCacheModel(
            id: "\(userId)_\(domain.id)",
            userId: userId,
            wordId: domain.id
        )
        
        model.id = "\(userId)_\(domain.id)"
        model.userId = userId
        model.wordId = domain.id
        model.status = status
        model.strength = strength
        model.lastSeenAt = lastSeenAt
        model.reviewCount = reviewCount
        model.correctCount = correctCount
        model.updatedAt = TimestampMapper.currentDateMilliseconds()
        model.lastSyncedAt = TimestampMapper.currentDateMilliseconds()
        model.dirty = false
        model.pendingSync = false
        
        return model
    }
    
    public static func fromCache(_ cache: VocabWordCacheModel, word: VocabWord) -> VocabWord {
        return word
    }
}
