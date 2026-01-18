import Foundation
import SwiftData
import FirebaseAuth
import FirebaseDatabase

@MainActor
class AchievementRepository: ObservableObject {
    private let modelContainer: ModelContainer
    private let database = Database.database().reference()
    
    init(container: ModelContainer) {
        self.modelContainer = container
    }
    
    // CloudSync models not included in project - commenting out methods
    /*
    func getAchievement(achievementId: String) -> CachedAchievement? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        
        let context = ModelContext(modelContainer)
        let id = "\(userId)_\(achievementId)"
        let descriptor = FetchDescriptor<CachedAchievement>(
            predicate: #Predicate { $0.id == id }
        )
        
        return try? context.fetch(descriptor).first
    }
    
    func getAllAchievements() -> [CachedAchievement] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedAchievement>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getUnlockedAchievements() -> [CachedAchievement] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedAchievement>(
            predicate: #Predicate { $0.userId == userId && $0.unlocked == true }
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func unlockAchievement(achievementId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let safeId = safeFirebaseKey(achievementId)
        let context = modelContainer.mainContext
        let id = "\(userId)_\(safeId)"
        let descriptor = FetchDescriptor<CachedAchievement>(
            predicate: #Predicate { $0.id == id }
        )
        
        let nowMs = TimestampMapper.currentDateMilliseconds()
        
        if let cached = try context.fetch(descriptor).first {
            if !cached.unlocked {
                cached.unlocked = true
                cached.unlockedAt = nowMs
                cached.progress = 100
                cached.updatedAt = nowMs
                try context.save()
                
                try await pushAchievementToCloud(userId: userId, cached: cached)
                print("🏆 Achievement unlocked: \(achievementId)")
            }
        } else {
            let dto = AchievementDTO(
                achievementId: safeId,
                unlocked: true,
                unlockedAt: nowMs,
                progress: 100,
                updatedAt: nowMs
            )
            let newCache = CachedAchievement(userId: userId, dto: dto)
            context.insert(newCache)
            try context.save()
            
            try await pushAchievementToCloud(userId: userId, cached: newCache)
            print("🏆 Achievement unlocked: \(achievementId)")
        }
    }
    
    func updateProgress(achievementId: String, progress: Int) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let safeId = safeFirebaseKey(achievementId)
        let context = modelContainer.mainContext
        let id = "\(userId)_\(safeId)"
        let descriptor = FetchDescriptor<CachedAchievement>(
            predicate: #Predicate { $0.id == id }
        )
        
        let nowMs = TimestampMapper.currentDateMilliseconds()
        let clampedProgress = min(100, max(0, progress))
        
        if let cached = try context.fetch(descriptor).first {
            if !cached.unlocked {
                cached.progress = clampedProgress
                cached.updatedAt = nowMs
                
                if clampedProgress >= 100 {
                    cached.unlocked = true
                    cached.unlockedAt = nowMs
                    print("🏆 Achievement unlocked: \(achievementId)")
                }
                
                try context.save()
                try await pushAchievementToCloud(userId: userId, cached: cached)
            }
        } else {
            let unlocked = clampedProgress >= 100
            let dto = AchievementDTO(
                achievementId: achievementId,
                unlocked: unlocked,
                unlockedAt: unlocked ? nowMs : nil,
                progress: clampedProgress,
                updatedAt: nowMs
            )
            let newCache = CachedAchievement(userId: userId, dto: dto)
            context.insert(newCache)
            try context.save()
            
            try await pushAchievementToCloud(userId: userId, cached: newCache)
            
            if unlocked {
                print("🏆 Achievement unlocked: \(achievementId)")
            }
        }
    }
    
    func checkAndUnlockAchievements(progress: CachedUserProgress, vocabRepo: VocabRepository) async {
        let knownWords = vocabRepo.getKnownWordsCount()
        
        if knownWords >= 1 {
            try? await unlockAchievement(achievementId: "first_word")
        }
        if knownWords >= 100 {
            try? await unlockAchievement(achievementId: "words_100")
        }
        if knownWords >= 500 {
            try? await unlockAchievement(achievementId: "words_500")
        }
        if knownWords >= 1000 {
            try? await unlockAchievement(achievementId: "words_1000")
        }
        
        if progress.streakDays >= 7 {
            try? await unlockAchievement(achievementId: "streak_7")
        }
        if progress.streakDays >= 30 {
            try? await unlockAchievement(achievementId: "streak_30")
        }
        if progress.streakDays >= 100 {
            try? await unlockAchievement(achievementId: "streak_100")
        }
        
        if progress.conversationsCompleted >= 10 {
            try? await unlockAchievement(achievementId: "conversations_10")
        }
        
        if progress.grammarRulesLearned >= 20 {
            try? await unlockAchievement(achievementId: "grammar_20")
        }
        
        if progress.sessionsCompleted >= 50 {
            try? await unlockAchievement(achievementId: "dedicated_50")
        }
        if progress.sessionsCompleted >= 100 {
            try? await unlockAchievement(achievementId: "dedicated_100")
        }
    }
    
    private func pushAchievementToCloud(userId: String, cached: CachedAchievement) async throws {
        let dto = cached.toDTO()
        let path = "users/\(userId)/achievements/\(dto.achievementId)"
        
        let context = modelContainer.mainContext
        try await enqueueWrite(userId: userId, path: path, payload: dto.toDictionary(), context: context)
    }
    
    private func enqueueWrite(userId: String, path: String, payload: [String: Any], context: ModelContext) async throws {
        do {
            try await database.child(path).setValue(payload)
            print("✅ AchievementRepository: Direct write succeeded - \(path)")
        } catch {
            print("⚠️ AchievementRepository: Direct write failed, enqueueing - \(error)")
            let updatedAt = payload["updatedAt"] as? Int64 ?? TimestampMapper.currentDateMilliseconds()
            let outboxItem = SyncOutboxItemCacheModel(
                userId: userId,
                path: path,
                payload: payload,
                updatedAt: updatedAt
            )
            context.insert(outboxItem)
            try context.save()
        }
    }
    */
}
