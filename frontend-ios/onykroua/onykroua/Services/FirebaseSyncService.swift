import Foundation
import FirebaseDatabase
import FirebaseAuth
import SwiftData

@MainActor
class FirebaseSyncService: ObservableObject {
    static let shared = FirebaseSyncService()
    
    private let database = Database.database().reference()
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    
    private var userProgressObserver: DatabaseHandle?
    
    private init() {
        setupRealtimeSync()
        
        // Listen for auth changes to re-setup sync
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                Task { @MainActor in
                    self?.setupRealtimeSync()
                }
            }
        }
    }
    
    deinit {
        if let handle = userProgressObserver {
            database.child("userProgress").removeObserver(withHandle: handle)
        }
    }
    
    // MARK: - Real-time Sync Setup
    
    private func setupRealtimeSync() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ Firebase Sync: No user authenticated")
            return
        }
        
        let userRef = database.child("userProgress").child(userId)
        
        userProgressObserver = userRef.observe(.value) { [weak self] snapshot in
            Task { @MainActor in
                self?.handleRemoteUpdate(snapshot: snapshot)
            }
        }
        
        print("✅ Firebase Sync: Real-time observer setup for user \(userId)")
    }
    
    private func handleRemoteUpdate(snapshot: DataSnapshot) {
        guard snapshot.exists() else { return }
        
        if snapshot.value is [String: Any] {
            print("📥 Firebase Sync: Received remote update")
            lastSyncDate = Date()
        }
    }
    
    // MARK: - Upload User Progress
    
    func syncUserProgress(_ progress: UserProgress) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        let progressData = try encodeUserProgress(progress)
        let userRef = database.child("userProgress").child(userId)
        
        try await userRef.setValue(progressData)
        
        lastSyncDate = Date()
        print("✅ Firebase Sync: User progress uploaded")
    }
    
    // MARK: - Download User Progress
    
    func fetchUserProgress() async throws -> UserProgress? {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        let userRef = database.child("userProgress").child(userId)
        let snapshot = try await userRef.getData()
        
        guard snapshot.exists(), let data = snapshot.value as? [String: Any] else {
            print("ℹ️ Firebase Sync: No remote data found")
            return nil
        }
        
        let progress = try decodeUserProgress(from: data)
        lastSyncDate = Date()
        print("📥 Firebase Sync: User progress downloaded")
        
        return progress
    }
    
    // MARK: - Sync Achievements
    
    func syncAchievement(_ achievementId: String, unlockedAt: Date) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let achievementRef = database.child("achievements").child(userId).child(achievementId)
        
        let data: [String: Any] = [
            "unlockedAt": unlockedAt.timeIntervalSince1970,
            "timestamp": ServerValue.timestamp()
        ]
        
        try await achievementRef.setValue(data)
        print("✅ Firebase Sync: Achievement \(achievementId) synced")
    }
    
    func fetchAchievements() async throws -> [String: Date] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let achievementsRef = database.child("achievements").child(userId)
        let snapshot = try await achievementsRef.getData()
        
        guard snapshot.exists(), let data = snapshot.value as? [String: [String: Any]] else {
            return [:]
        }
        
        var achievements: [String: Date] = [:]
        for (achievementId, achievementData) in data {
            if let timestamp = achievementData["unlockedAt"] as? TimeInterval {
                achievements[achievementId] = Date(timeIntervalSince1970: timestamp)
            }
        }
        
        print("📥 Firebase Sync: \(achievements.count) achievements downloaded")
        return achievements
    }
    
    // MARK: - Sync Study Session
    
    func logStudySession(duration: Int, xpGained: Int, activityType: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let sessionId = UUID().uuidString
        let sessionRef = database.child("studySessions").child(userId).child(sessionId)
        
        let data: [String: Any] = [
            "duration": duration,
            "xpGained": xpGained,
            "activityType": activityType,
            "timestamp": ServerValue.timestamp(),
            "date": Date().ISO8601Format()
        ]
        
        try await sessionRef.setValue(data)
        print("✅ Firebase Sync: Study session logged")
    }
    
    func fetchStudySessions(limit: Int = 30) async throws -> [[String: Any]] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let sessionsRef = database.child("studySessions").child(userId)
        let query = sessionsRef.queryLimited(toLast: UInt(limit))
        let snapshot = try await query.getData()
        
        guard snapshot.exists(), let data = snapshot.value as? [String: [String: Any]] else {
            return []
        }
        
        let sessions = Array(data.values)
        print("📥 Firebase Sync: \(sessions.count) study sessions downloaded")
        return sessions
    }
    
    // MARK: - Sync Quiz Results
    
    func syncQuizResult(quizType: String, score: Int, totalQuestions: Int, difficulty: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let resultId = UUID().uuidString
        let resultRef = database.child("quizResults").child(userId).child(resultId)
        
        let data: [String: Any] = [
            "quizType": quizType,
            "score": score,
            "totalQuestions": totalQuestions,
            "difficulty": difficulty,
            "percentage": Double(score) / Double(totalQuestions) * 100,
            "timestamp": ServerValue.timestamp(),
            "date": Date().ISO8601Format()
        ]
        
        try await resultRef.setValue(data)
        print("✅ Firebase Sync: Quiz result synced")
    }
    
    // MARK: - Sync Review Items
    
    func syncReviewItem(itemId: String, itemType: String, easeFactor: Double, interval: Int, nextReviewDate: Date, reviewCount: Int) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let itemRef = database.child("reviewItems").child(userId).child(itemId)
        
        let data: [String: Any] = [
            "itemType": itemType,
            "easeFactor": easeFactor,
            "interval": interval,
            "nextReviewDate": nextReviewDate.timeIntervalSince1970,
            "reviewCount": reviewCount,
            "lastUpdated": ServerValue.timestamp()
        ]
        
        try await itemRef.setValue(data)
        print("✅ Firebase Sync: Review item \(itemId) synced")
    }
    
    func fetchReviewItems() async throws -> [[String: Any]] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let itemsRef = database.child("reviewItems").child(userId)
        let snapshot = try await itemsRef.getData()
        
        guard snapshot.exists(), let data = snapshot.value as? [String: [String: Any]] else {
            return []
        }
        
        let items = Array(data.values)
        print("📥 Firebase Sync: \(items.count) review items downloaded")
        return items
    }
    
    // MARK: - Sync Vocabulary Progress
    
    func syncVocabularyWord(wordId: String, status: String, reviewCount: Int, lastReviewDate: Date) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        // Nettoyage manuel du chemin si safeFirebasePath n'est pas encore propagé
        let safePath = wordId
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "$", with: "_")
            .replacingOccurrences(of: "#", with: "_")
            .replacingOccurrences(of: "[", with: "_")
            .replacingOccurrences(of: "]", with: "_")
            .replacingOccurrences(of: "/", with: "_")
        
        let wordRef = database.child("vocabulary").child(userId).child(safePath)
        
        let data: [String: Any] = [
            "status": status, // "learned" ou "learning"
            "reviewCount": reviewCount,
            "lastReviewDate": lastReviewDate.timeIntervalSince1970,
            "lastUpdated": ServerValue.timestamp()
        ]
        
        try await wordRef.setValue(data)
    }
    
    func fetchVocabularyStatus() async throws -> [String: [String: Any]] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let vocabRef = database.child("vocabulary").child(userId)
        let snapshot = try await vocabRef.getData()
        
        guard snapshot.exists(), let data = snapshot.value as? [String: [String: Any]] else {
            return [:]
        }
        
        return data
    }
    
    // MARK: - Sync User Settings
    
    func syncUserSettings(_ settings: [String: Any]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let settingsRef = database.child("userSettings").child(userId)
        try await settingsRef.setValue(settings)
        print("✅ Firebase Sync: User settings synced")
    }
    
    func fetchUserSettings() async throws -> [String: Any]? {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let settingsRef = database.child("userSettings").child(userId)
        let snapshot = try await settingsRef.getData()
        
        guard snapshot.exists(), let data = snapshot.value as? [String: Any] else {
            return nil
        }
        
        print("📥 Firebase Sync: User settings downloaded")
        return data
    }
    
    // MARK: - Leaderboard
    
    func updateLeaderboard(username: String, totalXP: Int, level: String, streak: Int) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseSyncError.userNotAuthenticated
        }
        
        let leaderboardRef = database.child("leaderboard").child(userId)
        
        let data: [String: Any] = [
            "username": username,
            "totalXP": totalXP,
            "level": level,
            "streak": streak,
            "lastUpdated": ServerValue.timestamp()
        ]
        
        try await leaderboardRef.setValue(data)
        print("✅ Firebase Sync: Leaderboard updated")
    }
    
    func fetchLeaderboard(limit: Int = 50) async throws -> [[String: Any]] {
        let leaderboardRef = database.child("leaderboard")
        let query = leaderboardRef.queryOrdered(byChild: "totalXP").queryLimited(toLast: UInt(limit))
        let snapshot = try await query.getData()
        
        guard snapshot.exists(), let data = snapshot.value as? [String: [String: Any]] else {
            return []
        }
        
        let leaderboard = Array(data.values).sorted { (a, b) in
            let xpA = a["totalXP"] as? Int ?? 0
            let xpB = b["totalXP"] as? Int ?? 0
            return xpA > xpB
        }
        
        print("📥 Firebase Sync: \(leaderboard.count) leaderboard entries downloaded")
        return leaderboard
    }
    
    // MARK: - Full Sync
    
    func performFullSync(progress: UserProgress) async throws {
        print("🔄 Firebase Sync: Starting full sync...")
        
        try await syncUserProgress(progress)
        
        try await updateLeaderboard(
            username: "User",
            totalXP: progress.totalXP,
            level: progress.level.rawValue,
            streak: progress.streak
        )
        
        lastSyncDate = Date()
        print("✅ Firebase Sync: Full sync completed")
    }
    
    // MARK: - Encoding/Decoding Helpers
    
    private func encodeUserProgress(_ progress: UserProgress) throws -> [String: Any] {
        return [
            "currentXP": progress.currentXP,
            "totalXP": progress.totalXP,
            "level": progress.level.rawValue,
            "streak": progress.streak,
            "longestStreak": progress.longestStreak,
            "lastStudyDate": progress.lastStudyDate?.timeIntervalSince1970 ?? 0,
            "wordsLearned": progress.wordsLearned,
            "wordsReviewed": progress.wordsReviewed,
            "lessonsCompleted": progress.lessonsCompleted,
            "verbsLearned": progress.verbsLearned,
            "grammarRulesLearned": progress.grammarRulesLearned,
            "conversationsCompleted": progress.conversationsCompleted,
            "quizzesCompleted": progress.quizzesCompleted,
            "quizzesCorrect": progress.quizzesCorrect,
            "quizSuccessRate": progress.quizSuccessRate,
            "updatedAt": ServerValue.timestamp()
        ]
    }
    
    private func decodeUserProgress(from data: [String: Any]) throws -> UserProgress {
        let progress = UserProgress()
        
        progress.currentXP = data["currentXP"] as? Int ?? 0
        progress.totalXP = data["totalXP"] as? Int ?? 0
        
        if let levelString = data["level"] as? String {
            progress.currentLevel = levelString
        }
        
        progress.streak = data["streak"] as? Int ?? 0
        progress.longestStreak = data["longestStreak"] as? Int ?? 0
        
        if let timestamp = data["lastStudyDate"] as? TimeInterval {
            progress.lastStudyDate = Date(timeIntervalSince1970: timestamp)
        }
        
        progress.wordsLearned = data["wordsLearned"] as? Int ?? 0
        progress.wordsReviewed = data["wordsReviewed"] as? Int ?? 0
        progress.lessonsCompleted = data["lessonsCompleted"] as? Int ?? 0
        progress.verbsLearned = data["verbsLearned"] as? Int ?? 0
        progress.grammarRulesLearned = data["grammarRulesLearned"] as? Int ?? 0
        progress.conversationsCompleted = data["conversationsCompleted"] as? Int ?? 0
        progress.quizzesCompleted = data["quizzesCompleted"] as? Int ?? 0
        progress.quizzesCorrect = data["quizzesCorrect"] as? Int ?? 0
        
        return progress
    }
    
    // MARK: - Connection Status
    
    func checkConnection() async -> Bool {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        do {
            let snapshot = try await connectedRef.getData()
            if let connected = snapshot.value as? Bool {
                return connected
            }
        } catch {
            print("❌ Firebase Sync: Connection check failed - \(error.localizedDescription)")
        }
        
        return false
    }
}

// MARK: - Errors

enum FirebaseSyncError: LocalizedError {
    case userNotAuthenticated
    case encodingFailed
    case decodingFailed
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "L'utilisateur n'est pas authentifié"
        case .encodingFailed:
            return "Échec de l'encodage des données"
        case .decodingFailed:
            return "Échec du décodage des données"
        case .networkError(let message):
            return "Erreur réseau: \(message)"
        }
    }
}
