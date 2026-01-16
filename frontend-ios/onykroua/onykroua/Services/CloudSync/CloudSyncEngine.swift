import Foundation
import FirebaseDatabase
import FirebaseAuth
import SwiftData
import UIKit

@MainActor
class CloudSyncEngine: ObservableObject {
    static let shared = CloudSyncEngine()
    
    private let database = Database.database().reference()
    private var modelContainer: ModelContainer?
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    private var progressObserver: DatabaseHandle?
    private var vocabObserver: DatabaseHandle?
    private var achievementsObserver: DatabaseHandle?
    private var sessionsObserver: DatabaseHandle?
    
    private let syncQueue = DispatchQueue(label: "com.onykroua.sync", qos: .utility)
    
    private init() {
        setupAuthListener()
    }
    
    deinit {
        // Observers must be removed on MainActor, but deinit is nonisolated.
        // We use Task to hop to MainActor for cleanup.
        let progress = progressObserver
        let vocab = vocabObserver
        let achievements = achievementsObserver
        let sessions = sessionsObserver
        
        Task { @MainActor in
            let database = Database.database().reference()
            if let handle = progress { database.removeObserver(withHandle: handle) }
            if let handle = vocab { database.removeObserver(withHandle: handle) }
            if let handle = achievements { database.removeObserver(withHandle: handle) }
            if let handle = sessions { database.removeObserver(withHandle: handle) }
        }
    }
    
    func configure(with container: ModelContainer) {
        self.modelContainer = container
    }
    
    private func setupAuthListener() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.onUserSignedIn(userId: user.uid)
                } else {
                    await self?.onUserSignedOut()
                }
            }
        }
    }
    
    private func onUserSignedIn(userId: String) async {
        print("🔄 CloudSync: User signed in - \(userId)")
        await bootstrap(userId: userId)
        setupRealtimeObservers(userId: userId)
        await flushOutbox()
    }
    
    private func onUserSignedOut() async {
        print("🔄 CloudSync: User signed out")
        Task { @MainActor in
            removeObservers()
        }
    }
    
    func bootstrap(userId: String) async {
        guard let container = modelContainer else {
            print("❌ CloudSync: ModelContainer not configured")
            return
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        print("🔄 CloudSync: Starting bootstrap for user \(userId)")
        
        let context = ModelContext(container)
        
        do {
            let cloudMeta = try await fetchUserMeta(userId: userId)
            let cloudProgress = try await fetchUserProgress(userId: userId)
            
            if cloudProgress == nil {
                print("📝 CloudSync: No cloud data found - initializing new user")
                try await initializeNewUser(userId: userId, context: context)
                try await bootstrap(userId: userId)
                return
            }
            
            if let progressDTO = cloudProgress {
                try await syncProgressToLocal(userId: userId, dto: progressDTO, context: context)
            }
            
            let vocabData = try await fetchAllVocab(userId: userId)
            for (wordId, dto) in vocabData {
                try await syncVocabToLocal(userId: userId, dto: dto, context: context)
            }
            
            let achievementsData = try await fetchAllAchievements(userId: userId)
            for (achievementId, dto) in achievementsData {
                try await syncAchievementToLocal(userId: userId, dto: dto, context: context)
            }
            
            let sessionsData = try await fetchRecentSessions(userId: userId, limit: 50)
            for dto in sessionsData {
                try await syncSessionToLocal(userId: userId, dto: dto, context: context)
            }
            
            try context.save()
            lastSyncDate = Date()
            
            print("✅ CloudSync: Bootstrap completed successfully")
            
        } catch {
            print("❌ CloudSync: Bootstrap failed - \(error.localizedDescription)")
            syncError = error.localizedDescription
        }
    }
    
    private func initializeNewUser(userId: String, context: ModelContext) async throws {
        let nowMs = Date().toMilliseconds()
        
        let metaDTO = UserMetaDTO(
            schemaVersion: 1,
            createdAt: nowMs,
            lastLoginAt: nowMs,
            activeDeviceId: await getDeviceId(),
            updatedAt: nowMs
        )
        
        let progressDTO = UserProgressDTO(
            level: 1,
            xp: 0,
            streakDays: 0,
            longestStreak: 0,
            lastStudyAt: nowMs,
            wordsLearned: 0,
            wordsReviewed: 0,
            lessonsCompleted: 0,
            quizzesCompleted: 0,
            quizzesCorrect: 0,
            conversationsCompleted: 0,
            grammarRulesLearned: 0,
            verbsLearned: 0,
            studyTimeMinutes: 0,
            sessionsCompleted: 0,
            updatedAt: nowMs
        )
        
        try await database.child("users").child(userId).child("meta").setValue(metaDTO.toDictionary())
        try await database.child("users").child(userId).child("progress").setValue(progressDTO.toDictionary())
        
        print("✅ CloudSync: New user initialized in cloud")
    }
    
    private func setupRealtimeObservers(userId: String) {
        removeObservers()
        
        let userRef = database.child("users").child(userId)
        
        progressObserver = userRef.child("progress").observe(.value) { [weak self] snapshot in
            Task { @MainActor in
                await self?.handleProgressUpdate(userId: userId, snapshot: snapshot)
            }
        }
        
        vocabObserver = userRef.child("vocab").observe(.childChanged) { [weak self] snapshot in
            Task { @MainActor in
                await self?.handleVocabUpdate(userId: userId, snapshot: snapshot)
            }
        }
        
        achievementsObserver = userRef.child("achievements").observe(.childChanged) { [weak self] snapshot in
            Task { @MainActor in
                await self?.handleAchievementUpdate(userId: userId, snapshot: snapshot)
            }
        }
        
        sessionsObserver = userRef.child("sessions").observe(.childAdded) { [weak self] snapshot in
            Task { @MainActor in
                await self?.handleSessionAdded(userId: userId, snapshot: snapshot)
            }
        }
        
        print("✅ CloudSync: Realtime observers setup for user \(userId)")
    }
    
    private func removeObservers() {
        if let handle = progressObserver {
            database.removeObserver(withHandle: handle)
        }
        if let handle = vocabObserver {
            database.removeObserver(withHandle: handle)
        }
        if let handle = achievementsObserver {
            database.removeObserver(withHandle: handle)
        }
        if let handle = sessionsObserver {
            database.removeObserver(withHandle: handle)
        }
        
        progressObserver = nil
        vocabObserver = nil
        achievementsObserver = nil
        sessionsObserver = nil
    }
    
    private func handleProgressUpdate(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = UserProgressDTO.fromDictionary(dict),
              let container = modelContainer else {
            return
        }
        
        let context = ModelContext(container)
        do {
            try await syncProgressToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Progress updated from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync progress - \(error)")
        }
    }
    
    private func handleVocabUpdate(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = VocabWordDTO.fromDictionary(wordId: snapshot.key, dict),
              let container = modelContainer else {
            return
        }
        
        let context = ModelContext(container)
        do {
            try await syncVocabToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Vocab word '\(snapshot.key)' updated from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync vocab - \(error)")
        }
    }
    
    private func handleAchievementUpdate(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = AchievementDTO.fromDictionary(achievementId: snapshot.key, dict),
              let container = modelContainer else {
            return
        }
        
        let context = ModelContext(container)
        do {
            try await syncAchievementToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Achievement '\(snapshot.key)' updated from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync achievement - \(error)")
        }
    }
    
    private func handleSessionAdded(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = SessionDTO.fromDictionary(sessionId: snapshot.key, dict),
              let container = modelContainer else {
            return
        }
        
        let context = ModelContext(container)
        do {
            try await syncSessionToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Session '\(snapshot.key)' added from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync session - \(error)")
        }
    }
    
    private func syncProgressToLocal(userId: String, dto: UserProgressDTO, context: ModelContext) async throws {
        let descriptor = FetchDescriptor<CachedUserProgress>(
            predicate: #Predicate { $0.userId == userId }
        )
        let existing = try context.fetch(descriptor).first
        
        if let cached = existing {
            if dto.updatedAt >= cached.updatedAt {
                cached.updateFrom(dto: dto)
                print("🔄 CloudSync: Progress updated (cloud wins)")
            } else {
                print("⏭️ CloudSync: Local progress is newer, skipping")
            }
        } else {
            let newCache = CachedUserProgress(userId: userId, dto: dto)
            context.insert(newCache)
            print("📝 CloudSync: Progress cached locally")
        }
    }
    
    private func syncVocabToLocal(userId: String, dto: VocabWordDTO, context: ModelContext) async throws {
        let id = "\(userId)_\(dto.wordId)"
        let descriptor = FetchDescriptor<CachedVocabWord>(
            predicate: #Predicate { $0.id == id }
        )
        let existing = try context.fetch(descriptor).first
        
        if let cached = existing {
            if dto.updatedAt >= cached.updatedAt {
                cached.updateFrom(dto: dto)
            }
        } else {
            let newCache = CachedVocabWord(userId: userId, dto: dto)
            context.insert(newCache)
        }
    }
    
    private func syncAchievementToLocal(userId: String, dto: AchievementDTO, context: ModelContext) async throws {
        let id = "\(userId)_\(dto.achievementId)"
        let descriptor = FetchDescriptor<CachedAchievement>(
            predicate: #Predicate { $0.id == id }
        )
        let existing = try context.fetch(descriptor).first
        
        if let cached = existing {
            if dto.updatedAt >= cached.updatedAt {
                cached.updateFrom(dto: dto)
            }
        } else {
            let newCache = CachedAchievement(userId: userId, dto: dto)
            context.insert(newCache)
        }
    }
    
    private func syncSessionToLocal(userId: String, dto: SessionDTO, context: ModelContext) async throws {
        let id = "\(userId)_\(dto.sessionId)"
        let descriptor = FetchDescriptor<CachedSession>(
            predicate: #Predicate { $0.id == id }
        )
        let existing = try context.fetch(descriptor).first
        
        if existing == nil {
            let newCache = CachedSession(userId: userId, dto: dto)
            context.insert(newCache)
        }
    }
    
    private func fetchUserMeta(userId: String) async throws -> UserMetaDTO? {
        let snapshot = try await database.child("users").child(userId).child("meta").getData()
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any] else {
            return nil
        }
        return UserMetaDTO.fromDictionary(dict)
    }
    
    private func fetchUserProgress(userId: String) async throws -> UserProgressDTO? {
        let snapshot = try await database.child("users").child(userId).child("progress").getData()
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any] else {
            return nil
        }
        return UserProgressDTO.fromDictionary(dict)
    }
    
    private func fetchAllVocab(userId: String) async throws -> [String: VocabWordDTO] {
        let snapshot = try await database.child("users").child(userId).child("vocab").getData()
        guard snapshot.exists(), let data = snapshot.value as? [String: [String: Any]] else {
            return [:]
        }
        
        var result: [String: VocabWordDTO] = [:]
        for (wordId, dict) in data {
            if let dto = VocabWordDTO.fromDictionary(wordId: wordId, dict) {
                result[wordId] = dto
            }
        }
        return result
    }
    
    private func fetchAllAchievements(userId: String) async throws -> [String: AchievementDTO] {
        let snapshot = try await database.child("users").child(userId).child("achievements").getData()
        guard snapshot.exists(), let data = snapshot.value as? [String: [String: Any]] else {
            return [:]
        }
        
        var result: [String: AchievementDTO] = [:]
        for (achievementId, dict) in data {
            if let dto = AchievementDTO.fromDictionary(achievementId: achievementId, dict) {
                result[achievementId] = dto
            }
        }
        return result
    }
    
    private func fetchRecentSessions(userId: String, limit: Int) async throws -> [SessionDTO] {
        let query = database.child("users").child(userId).child("sessions").queryLimited(toLast: UInt(limit))
        let snapshot = try await query.getData()
        
        guard snapshot.exists(), let data = snapshot.value as? [String: [String: Any]] else {
            return []
        }
        
        var result: [SessionDTO] = []
        for (sessionId, dict) in data {
            if let dto = SessionDTO.fromDictionary(sessionId: sessionId, dict) {
                result.append(dto)
            }
        }
        return result
    }
    
    func flushOutbox() async {
        guard let container = modelContainer,
              let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<SyncOutboxItem>(
            predicate: #Predicate { $0.userId == userId && $0.attempts < 10 },
            sortBy: [SortDescriptor(\SyncOutboxItem.createdAt)]
        )
        
        do {
            let items = try context.fetch(descriptor)
            print("🔄 CloudSync: Flushing \(items.count) outbox items")
            
            for item in items {
                guard let payload = item.getPayload() else {
                    context.delete(item)
                    continue
                }
                
                do {
                    try await database.child(item.path).setValue(payload)
                    context.delete(item)
                    print("✅ CloudSync: Outbox item synced - \(item.path)")
                } catch {
                    item.recordAttempt(error: error.localizedDescription)
                    print("⚠️ CloudSync: Outbox item failed (attempt \(item.attempts)) - \(error)")
                    
                    if item.attempts >= 10 {
                        print("❌ CloudSync: Outbox item exceeded max attempts, marking for review")
                    }
                }
                
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            
            try context.save()
            
        } catch {
            print("❌ CloudSync: Failed to flush outbox - \(error)")
        }
    }
    
    private func getDeviceId() async -> String {
        return await UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }
}
