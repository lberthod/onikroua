import Foundation
import SwiftData
import FirebaseAuth
import FirebaseDatabase
import onykroua

@MainActor
class ProgressRepository: ObservableObject {
    private let modelContainer: ModelContainer
    private let database = Database.database().reference()
    
    init(container: ModelContainer) {
        self.modelContainer = container
    }
    
    // CloudSync models not included in project - commenting out methods
    /*
    func getProgress() -> CachedUserProgress? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedUserProgress>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        return try? context.fetch(descriptor).first
    }
    
    func addXP(_ amount: Int) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedUserProgress>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        guard let cached = try context.fetch(descriptor).first else {
            throw RepositoryError.dataNotFound
        }
        
        cached.xp += amount
        cached.updatedAt = TimestampMapper.currentDateMilliseconds()
        
        try context.save()
        
        try await pushProgressToCloud(userId: userId, cached: cached)
    }
    
    func incrementStreak() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedUserProgress>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        guard let cached = try context.fetch(descriptor).first else {
            throw RepositoryError.dataNotFound
        }
        
        cached.streakDays += 1
        if cached.streakDays > cached.longestStreak {
            cached.longestStreak = cached.streakDays
        }
        cached.lastStudyAt = TimestampMapper.currentDateMilliseconds()
        cached.updatedAt = TimestampMapper.currentDateMilliseconds()
        
        try context.save()
        
        try await pushProgressToCloud(userId: userId, cached: cached)
    }
    
    func recordWordLearned() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedUserProgress>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        guard let cached = try context.fetch(descriptor).first else {
            throw RepositoryError.dataNotFound
        }
        
        cached.wordsLearned += 1
        cached.updatedAt = TimestampMapper.currentDateMilliseconds()
        
        try context.save()
        
        try await pushProgressToCloud(userId: userId, cached: cached)
    }
    
    func recordWordReviewed() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedUserProgress>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        guard let cached = try context.fetch(descriptor).first else {
            throw RepositoryError.dataNotFound
        }
        
        cached.wordsReviewed += 1
        cached.updatedAt = TimestampMapper.currentDateMilliseconds()
        
        try context.save()
        
        try await pushProgressToCloud(userId: userId, cached: cached)
    }
    
    func recordSessionCompleted(xpGained: Int, activityType: String, itemsCount: Int, correctCount: Int, durationSeconds: Int) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedUserProgress>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        guard let cached = try context.fetch(descriptor).first else {
            throw RepositoryError.dataNotFound
        }
        
        cached.xp += xpGained
        cached.sessionsCompleted += 1
        cached.studyTimeMinutes += durationSeconds / 60
        cached.lastStudyAt = TimestampMapper.currentDateMilliseconds()
        cached.updatedAt = TimestampMapper.currentDateMilliseconds()
        
        try context.save()
        
        try await pushProgressToCloud(userId: userId, cached: cached)
        
        let nowMs = TimestampMapper.currentDateMilliseconds()
        let sessionDTO = StudySessionDTO(
            sessionId: database.child("users").child(userId).child("sessions").childByAutoId().key ?? UUID().uuidString,
            startedAt: nowMs - Int64(durationSeconds * 1000),
            endedAt: nowMs,
            itemsCount: itemsCount,
            correctCount: correctCount,
            xpGained: xpGained,
            activityType: activityType,
            updatedAt: nowMs
        )
        
        let sessionCache = CachedSession(userId: userId, dto: sessionDTO)
        context.insert(sessionCache)
        try context.save()
        
        let path = "users/\(userId)/sessions/\(sessionDTO.sessionId)"
        try await enqueueWrite(userId: userId, path: path, payload: sessionDTO.toDictionary(), context: context)
    }
    
    func pushToLeaderboard(username: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedUserProgress>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        guard let cached = try context.fetch(descriptor).first else {
            throw RepositoryError.dataNotFound
        }
        
        let nowMs = TimestampMapper.currentDateMilliseconds()
        let leaderboardDTO = LeaderboardEntryDTO(
            uid: userId,
            xp: cached.xp,
            level: cached.level,
            username: username,
            updatedAt: nowMs
        )
        
        let path = "leaderboards/global/\(userId)"
        try await enqueueWrite(userId: userId, path: path, payload: leaderboardDTO.toDictionary(), context: context)
    }
    
    private func pushProgressToCloud(userId: String, cached: CachedUserProgress) async throws {
        let dto = cached.toDTO()
        let path = "users/\(userId)/progress"
        
        let context = modelContainer.mainContext
        try await enqueueWrite(userId: userId, path: path, payload: dto.toDictionary(), context: context)
    }
    
    private func enqueueWrite(userId: String, path: String, payload: [String: Any], context: ModelContext) async throws {
        do {
            try await database.child(path).setValue(payload)
            print("✅ ProgressRepository: Direct write succeeded - \(path)")
        } catch {
            print("⚠️ ProgressRepository: Direct write failed, enqueueing - \(error)")
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
