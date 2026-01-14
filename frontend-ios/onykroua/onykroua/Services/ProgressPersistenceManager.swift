import Foundation
import SwiftData

// MARK: - Progress Persistence Manager

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
    
    func getUserProgress(userId: String = "default_user") -> UserProgressModel? {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return nil
        }
        
        let predicate = #Predicate<UserProgressModel> { progress in
            progress.userId == userId
        }
        
        let descriptor = FetchDescriptor<UserProgressModel>(predicate: predicate)
        
        do {
            let models = try context.fetch(descriptor)
            return models.first
        } catch {
            print("❌ Failed to fetch user progress: \(error)")
            return nil
        }
    }
    
    func saveUserProgress(_ progress: UserProgressModel) {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        context.insert(progress)
        
        do {
            try context.save()
            print("✅ Saved user progress: XP=\(progress.totalXP), Level=\(progress.currentLevel)")
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
                existingProgress.totalWordsLearned = words
            }
            if let xp = totalXP {
                existingProgress.totalXP = xp
            }
            if let level = currentLevel {
                existingProgress.currentLevel = level
            }
            if let streak = dailyStreak {
                existingProgress.dailyStreak = streak
            }
            if let longest = longestStreak {
                existingProgress.longestStreak = longest
            }
            
            existingProgress.lastModified = Date()
            
            do {
                try context.save()
                print("✅ Updated user progress")
            } catch {
                print("❌ Failed to update user progress: \(error)")
            }
        } else {
            let newProgress = UserProgressModel(
                userId: userId,
                totalWordsLearned: totalWordsLearned ?? 0,
                totalXP: totalXP ?? 0,
                currentLevel: currentLevel ?? 1,
                dailyStreak: dailyStreak ?? 0,
                longestStreak: longestStreak ?? 0
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
        
        let learnedWord = LearnedWordModel(
            userId: userId,
            wordId: wordId,
            word: word,
            translation: translation,
            language: language,
            category: category
        )
        
        context.insert(learnedWord)
        
        do {
            try context.save()
            print("✅ Marked word as learned: \(word)")
            
            // Update user progress
            if let progress = getUserProgress(userId: userId) {
                progress.totalWordsLearned += 1
                progress.totalXP += 10
                
                if !progress.learnedWordsIds.contains(wordId) {
                    progress.learnedWordsIds.append(wordId)
                }
                
                progress.lastModified = Date()
                try context.save()
            }
        } catch {
            print("❌ Failed to mark word as learned: \(error)")
        }
    }
    
    func getLearnedWords(userId: String = "default_user", language: String? = nil) -> [LearnedWordModel] {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return []
        }
        
        let predicate: Predicate<LearnedWordModel>
        
        if let lang = language {
            predicate = #Predicate<LearnedWordModel> { word in
                word.userId == userId && word.language == lang
            }
        } else {
            predicate = #Predicate<LearnedWordModel> { word in
                word.userId == userId
            }
        }
        
        let descriptor = FetchDescriptor<LearnedWordModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.dateLearned, order: .reverse)]
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
        guard let progress = getUserProgress(userId: userId) else {
            return false
        }
        
        return progress.learnedWordsIds.contains(wordId)
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
        
        let session = StudySessionModel(
            userId: userId,
            durationMinutes: durationMinutes,
            wordsLearned: wordsLearned,
            wordsReviewed: wordsReviewed,
            xpEarned: xpEarned,
            language: language,
            activityType: activityType
        )
        
        context.insert(session)
        
        do {
            try context.save()
            print("✅ Recorded study session: \(durationMinutes)min, +\(xpEarned)XP")
            
            // Update user progress
            if let progress = getUserProgress(userId: userId) {
                progress.totalStudyTimeMinutes += durationMinutes
                progress.lastStudyDate = Date()
                progress.lastModified = Date()
                try context.save()
            }
        } catch {
            print("❌ Failed to record study session: \(error)")
        }
    }
    
    func getStudySessions(userId: String = "default_user", limit: Int = 30) -> [StudySessionModel] {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return []
        }
        
        let predicate = #Predicate<StudySessionModel> { session in
            session.userId == userId
        }
        
        let descriptor = FetchDescriptor<StudySessionModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.sessionDate, order: .reverse)]
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
        
        let todaySessions = sessions.filter { session in
            calendar.isDate(session.sessionDate, inSameDayAs: today)
        }
        
        return todaySessions.reduce(0) { $0 + $1.durationMinutes }
    }
    
    // MARK: - Favorites Operations
    
    func toggleFavorite(wordId: String, userId: String = "default_user") {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        if let progress = getUserProgress(userId: userId) {
            if progress.favoriteWords.contains(wordId) {
                progress.favoriteWords.removeAll { $0 == wordId }
                print("💔 Removed from favorites: \(wordId)")
            } else {
                progress.favoriteWords.append(wordId)
                print("❤️ Added to favorites: \(wordId)")
            }
            
            progress.lastModified = Date()
            
            do {
                try context.save()
            } catch {
                print("❌ Failed to toggle favorite: \(error)")
            }
        }
    }
    
    func isFavorite(wordId: String, userId: String = "default_user") -> Bool {
        guard let progress = getUserProgress(userId: userId) else {
            return false
        }
        
        return progress.favoriteWords.contains(wordId)
    }
    
    // MARK: - Achievements Operations
    
    func unlockAchievement(achievementId: String, userId: String = "default_user") {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        if let progress = getUserProgress(userId: userId) {
            if !progress.achievements.contains(achievementId) {
                progress.achievements.append(achievementId)
                progress.lastModified = Date()
                
                do {
                    try context.save()
                    print("🏆 Achievement unlocked: \(achievementId)")
                } catch {
                    print("❌ Failed to unlock achievement: \(error)")
                }
            }
        }
    }
    
    func getAchievements(userId: String = "default_user") -> [String] {
        guard let progress = getUserProgress(userId: userId) else {
            return []
        }
        
        return progress.achievements
    }
    
    // MARK: - Statistics
    
    func getStatistics(userId: String = "default_user") -> [String: Any] {
        guard let progress = getUserProgress(userId: userId) else {
            return [:]
        }
        
        let learnedWords = getLearnedWords(userId: userId)
        let sessions = getStudySessions(userId: userId)
        
        return [
            "totalWordsLearned": progress.totalWordsLearned,
            "totalXP": progress.totalXP,
            "currentLevel": progress.currentLevel,
            "dailyStreak": progress.dailyStreak,
            "longestStreak": progress.longestStreak,
            "totalStudyTime": progress.totalStudyTimeMinutes,
            "todayStudyTime": getTodayStudyTime(userId: userId),
            "favoritesCount": progress.favoriteWords.count,
            "achievementsCount": progress.achievements.count,
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
            // Delete learned words
            let learnedPredicate = #Predicate<LearnedWordModel> { word in
                word.userId == userId
            }
            try context.delete(model: LearnedWordModel.self, where: learnedPredicate)
            
            // Delete study sessions
            let sessionPredicate = #Predicate<StudySessionModel> { session in
                session.userId == userId
            }
            try context.delete(model: StudySessionModel.self, where: sessionPredicate)
            
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
