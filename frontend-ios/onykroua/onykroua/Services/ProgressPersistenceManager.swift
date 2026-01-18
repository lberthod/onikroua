import Foundation
import SwiftData
import onykroua

// MARK: - Progress Persistence Manager
// NOTE: This file uses the new Cache models from Models/Cache/
// TODO: Consider migrating to use Domain models with Mappers

@MainActor
class ProgressPersistenceManager: ObservableObject {
    static let shared = ProgressPersistenceManager()
    
    private var modelContext: ModelContext?
    
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private init() {
        setupModelContext()
    }
    
    // MARK: - Setup
    
    func setupModelContext(_ context: ModelContext) {
        self.modelContext = context
        print("✅ ProgressPersistenceManager ModelContext configured")
    }
    
    private func setupModelContext() {
        if let container = VocabularyPersistenceManager.shared.modelContainer {
            self.modelContext = ModelContext(container)
        }
    }
    
    // MARK: - User Progress Operations
    
    func getUserProgress(userId: String = "default_user") -> UserProgressCacheModel? {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return nil
        }
        
        let predicate = #Predicate<UserProgressCacheModel> { progress in
            progress.userId == userId
        }
        
        let descriptor = FetchDescriptor<UserProgressCacheModel>(predicate: predicate)
        
        do {
            let models = try context.fetch(descriptor)
            return models.first
        } catch {
            print("❌ Failed to fetch user progress: \(error)")
            return nil
        }
    }
    
    func saveUserProgress(_ progress: UserProgressCacheModel) {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        context.insert(progress)
        
        do {
            try context.save()
            print("✅ Saved user progress: XP=\(progress.xp), Level=\(progress.level)")
        } catch {
            print("❌ Failed to save user progress: \(error)")
        }
    }
    
    func updateUserProgress(
        userId: String = "default_user",
        totalWordsLearned: Int? = nil,
        totalXP: Int? = nil,
        currentLevel: Int? = nil,
        dailyStreak: Int? = nil,
        longestStreak: Int? = nil
    ) {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        if let existingProgress = getUserProgress(userId: userId) {
            if let words = totalWordsLearned {
                existingProgress.wordsLearned = words
            }
            if let xp = totalXP {
                existingProgress.xp = xp
            }
            if let level = currentLevel {
                existingProgress.level = level
            }
            if let streak = dailyStreak {
                existingProgress.streakDays = streak
            }
            if let longest = longestStreak {
                existingProgress.longestStreak = longest
            }
            
            existingProgress.updatedAt = TimestampMapper.currentDateMilliseconds()
            
            do {
                try context.save()
                print("✅ Updated user progress")
            } catch {
                print("❌ Failed to update user progress: \(error)")
            }
        } else {
            let newProgress = UserProgressCacheModel(
                userId: userId,
                level: currentLevel ?? 1,
                xp: totalXP ?? 0,
                streakDays: dailyStreak ?? 0,
                longestStreak: longestStreak ?? 0,
                wordsLearned: totalWordsLearned ?? 0
            )
            saveUserProgress(newProgress)
        }
    }
    
    // MARK: - Learned Words Operations
    
    func markWordAsLearned(
        wordId: String,
        word: String,
        translation: String,
        language: String,
        category: String,
        userId: String = "default_user"
    ) {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        // Create or update VocabWordCacheModel
        let safeWordId = safeFirebaseKey(wordId)
        let vocabCacheId = "\(userId)_\(safeWordId)"
        
        let descriptor = FetchDescriptor<VocabWordCacheModel>(
            predicate: #Predicate { $0.id == vocabCacheId }
        )
        
        do {
            let existingVocab = try context.fetch(descriptor).first
            
            if let vocab = existingVocab {
                vocab.status = "learned"
                vocab.strength = 100
                vocab.lastSeenAt = TimestampMapper.currentDateMilliseconds()
                vocab.updatedAt = TimestampMapper.currentDateMilliseconds()
            } else {
                let newVocab = VocabWordCacheModel(
                    id: vocabCacheId,
                    userId: userId,
                    wordId: safeWordId,
                    status: "learned",
                    strength: 100,
                    lastSeenAt: TimestampMapper.currentDateMilliseconds(),
                    reviewCount: 1,
                    correctCount: 1
                )
                context.insert(newVocab)
            }
            
            // Update user progress
            if let progress = getUserProgress(userId: userId) {
                progress.wordsLearned += 1
                progress.xp += 10
                progress.updatedAt = TimestampMapper.currentDateMilliseconds()
                
                try context.save()
                print("✅ Marked word as learned: \(word)")
            }
        } catch {
            print("❌ Failed to mark word as learned: \(error)")
        }
    }
    
    func getLearnedWords(userId: String = "default_user", language: String? = nil) -> [VocabWordCacheModel] {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return []
        }
        
        let predicate: Predicate<VocabWordCacheModel>
        
        if let _ = language {
            predicate = #Predicate<VocabWordCacheModel> { word in
                word.userId == userId && word.status == "learned"
            }
        } else {
            predicate = #Predicate<VocabWordCacheModel> { word in
                word.userId == userId && word.status == "learned"
            }
        }
        
        let descriptor = FetchDescriptor<VocabWordCacheModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.lastSeenAt, order: .reverse)]
        )
        
        do {
            let models = try context.fetch(descriptor)
            print("✅ Fetched \(models.count) learned words")
            return models
        } catch {
            print("❌ Failed to fetch learned words: \(error)")
            return []
        }
    }
    
    func isWordLearned(wordId: String, userId: String = "default_user") -> Bool {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return false
        }
        
        let safeWordId = safeFirebaseKey(wordId)
        let vocabCacheId = "\(userId)_\(safeWordId)"
        
        let descriptor = FetchDescriptor<VocabWordCacheModel>(
            predicate: #Predicate { $0.id == vocabCacheId && $0.status == "learned" }
        )
        
        do {
            let result = try context.fetch(descriptor)
            return !result.isEmpty
        } catch {
            print("❌ Failed to check if word is learned: \(error)")
            return false
        }
    }
    
    // MARK: - Study Session Operations
    
    func recordStudySession(
        durationMinutes: Int,
        wordsLearned: Int,
        wordsReviewed: Int,
        xpEarned: Int,
        language: String,
        activityType: String = "vocabulary",
        userId: String = "default_user"
    ) {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        let sessionId = UUID().uuidString
        let nowMs = TimestampMapper.currentDateMilliseconds()
        
        let session = StudySessionCacheModel(
            id: "\(userId)_\(sessionId)",
            userId: userId,
            sessionId: sessionId,
            startedAt: nowMs,
            endedAt: nowMs + Int64(durationMinutes * 60 * 1000),
            itemsCount: wordsLearned + wordsReviewed,
            correctCount: wordsLearned,
            xpGained: xpEarned,
            activityType: activityType
        )
        
        context.insert(session)
        
        do {
            try context.save()
            print("✅ Recorded study session: \(durationMinutes)min, +\(xpEarned)XP")
            
            // Update user progress
            if let progress = getUserProgress(userId: userId) {
                progress.studyTimeMinutes += durationMinutes
                progress.sessionsCompleted += 1
                progress.lastStudyAt = nowMs
                progress.updatedAt = nowMs
                try context.save()
            }
        } catch {
            print("❌ Failed to record study session: \(error)")
        }
    }
    
    func getStudySessions(userId: String = "default_user", limit: Int = 30) -> [StudySessionCacheModel] {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return []
        }
        
        let predicate = #Predicate<StudySessionCacheModel> { session in
            session.userId == userId
        }
        
        let descriptor = FetchDescriptor<StudySessionCacheModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        
        do {
            let models = try context.fetch(descriptor)
            let limitedModels = Array(models.prefix(limit))
            print("✅ Fetched \(limitedModels.count) study sessions")
            return limitedModels
        } catch {
            print("❌ Failed to fetch study sessions: \(error)")
            return []
        }
    }
    
    func getTodayStudyTime(userId: String = "default_user") -> Int {
        let sessions = getStudySessions(userId: userId, limit: 100)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayMs = TimestampMapper.toMilliseconds(today)
        
        let todaySessions = sessions.filter { session in
            session.startedAt >= todayMs
        }
        
        return todaySessions.reduce(0) { $0 + Int(($1.endedAt - $1.startedAt) / 60000) }
    }
    
    // MARK: - Favorites Operations
    
    func toggleFavorite(wordId: String, userId: String = "default_user") {
        // Favorites are now tracked via VocabWordCacheModel status
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        let safeWordId = safeFirebaseKey(wordId)
        let vocabCacheId = "\(userId)_\(safeWordId)"
        
        let descriptor = FetchDescriptor<VocabWordCacheModel>(
            predicate: #Predicate { $0.id == vocabCacheId }
        )
        
        do {
            if let vocab = try context.fetch(descriptor).first {
                if vocab.status == "favorite" {
                    vocab.status = "learned"
                    print("💔 Removed from favorites: \(wordId)")
                } else {
                    vocab.status = "favorite"
                    print("❤️ Added to favorites: \(wordId)")
                }
                vocab.updatedAt = TimestampMapper.currentDateMilliseconds()
                try context.save()
            }
        } catch {
            print("❌ Failed to toggle favorite: \(error)")
        }
    }
    
    func isFavorite(wordId: String, userId: String = "default_user") -> Bool {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return false
        }
        
        let safeWordId = safeFirebaseKey(wordId)
        let vocabCacheId = "\(userId)_\(safeWordId)"
        
        let descriptor = FetchDescriptor<VocabWordCacheModel>(
            predicate: #Predicate { $0.id == vocabCacheId && $0.status == "favorite" }
        )
        
        do {
            let result = try context.fetch(descriptor)
            return !result.isEmpty
        } catch {
            print("❌ Failed to check favorite: \(error)")
            return false
        }
    }
    
    // MARK: - Achievements Operations
    
    func unlockAchievement(achievementId: String, userId: String = "default_user") {
        // Achievements are now tracked via CachedAchievement (out of PR#1 scope)
        print("🏆 Achievement tracking moved to CloudSync/AchievementRepository")
    }
    
    func getAchievements(userId: String = "default_user") -> [String] {
        print("🏆 Achievement tracking moved to CloudSync/AchievementRepository")
        return []
    }
    
    // MARK: - Statistics
    
    func getStatistics(userId: String = "default_user") -> [String: Any] {
        guard let progress = getUserProgress(userId: userId) else {
            return [:]
        }
        
        let _ = getLearnedWords(userId: userId)
        let sessions = getStudySessions(userId: userId)
        
        return [
            "totalWordsLearned": progress.wordsLearned,
            "totalXP": progress.xp,
            "currentLevel": progress.level,
            "dailyStreak": progress.streakDays,
            "longestStreak": progress.longestStreak,
            "totalStudyTime": progress.studyTimeMinutes,
            "todayStudyTime": getTodayStudyTime(userId: userId),
            "sessionsCount": sessions.count
        ]
    }
    
    // MARK: - Reset
    
    func resetProgress(userId: String = "default_user") {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        do {
            // Delete vocab words
            let vocabPredicate = #Predicate<VocabWordCacheModel> { word in
                word.userId == userId
            }
            try context.delete(model: VocabWordCacheModel.self, where: vocabPredicate)
            
            // Delete study sessions
            let sessionPredicate = #Predicate<StudySessionCacheModel> { session in
                session.userId == userId
            }
            try context.delete(model: StudySessionCacheModel.self, where: sessionPredicate)
            
            // Reset user progress
            if let progress = getUserProgress(userId: userId) {
                context.delete(progress)
            }
            
            try context.save()
            print("✅ Progress reset completed")
        } catch {
            print("❌ Failed to reset progress: \(error)")
        }
    }
}
