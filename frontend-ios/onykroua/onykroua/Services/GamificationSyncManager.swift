import Foundation
import SwiftData
import FirebaseAuth

@MainActor
final class GamificationSyncManager: ObservableObject {
    static let shared = GamificationSyncManager()
    
    private var progressRepo: ProgressRepository?
    private var achievementRepo: AchievementRepository?
    private var vocabRepo: VocabRepository?
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    private init() {}
    
    /// Configure the manager with a ModelContainer
    func configure(with container: ModelContainer) {
        self.progressRepo = ProgressRepository(container: container)
        self.achievementRepo = AchievementRepository(container: container)
        self.vocabRepo = VocabRepository(container: container)
    }
    
    // MARK: - Sync from Cloud (Legacy compatibility - now handled by CloudSyncEngine)
    
    func syncFromCloud() async {
        isSyncing = true
        defer { isSyncing = false }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        await CloudSyncEngine.shared.bootstrap(userId: userId)
        lastSyncDate = Date()
    }
    
    // MARK: - Sync to Cloud (Legacy compatibility - now handled by Repositories)
    
    func syncToCloud() async {
        // CloudSync models not included in project - flushOutbox is commented out
        // await CloudSyncEngine.shared.flushOutbox()
        print("⚠️ GamificationSyncManager.syncToCloud called but CloudSync models not included")
    }
    
    // MARK: - Activity Logging
    
    func logStudySession(duration: Int, xpGained: Int, activityType: String, itemsCount: Int = 0, correctCount: Int = 0) async {
        guard let repo = progressRepo else { return }
        
        // CloudSync models not included in project - recordSessionCompleted is commented out
        /*
        do {
            try await repo.recordSessionCompleted(
                xpGained: xpGained,
                activityType: activityType,
                itemsCount: itemsCount,
                correctCount: correctCount,
                durationSeconds: duration
            )
            print("✅ Sync: Study session logged")
        } catch {
            print("❌ Sync: Failed to log study session - \(error.localizedDescription)")
            syncError = error.localizedDescription
        }
        */
        print("⚠️ GamificationSyncManager.logStudySession called but CloudSync models not included")
    }
    
    func logQuizResult(quizType: String, score: Int, totalQuestions: Int, difficulty: String) async {
        guard let repo = progressRepo else { return }
        
        // CloudSync models not included in project - recordSessionCompleted is commented out
        /*
        do {
            // Mapping quiz results to session records for now
            try await repo.recordSessionCompleted(
                xpGained: score * 5, // Example multiplier
                activityType: "quiz_\(quizType)",
                itemsCount: totalQuestions,
                correctCount: score,
                durationSeconds: 0 // Duration not always available here
            )
            print("✅ Sync: Quiz result logged")
        } catch {
            print("❌ Sync: Failed to log quiz result - \(error.localizedDescription)")
            syncError = error.localizedDescription
        }
        */
        print("⚠️ GamificationSyncManager.logQuizResult called but CloudSync models not included")
    }
    
    func updateLeaderboard(username: String) async {
        guard let repo = progressRepo else { return }
        
        // CloudSync models not included in project - pushToLeaderboard is commented out
        /*
        do {
            try await repo.pushToLeaderboard(username: username)
            print("✅ Sync: Leaderboard updated")
        } catch {
            print("❌ Sync: Failed to update leaderboard - \(error.localizedDescription)")
            syncError = error.localizedDescription
        }
        */
        print("⚠️ GamificationSyncManager.updateLeaderboard called but CloudSync models not included")
    }
}
