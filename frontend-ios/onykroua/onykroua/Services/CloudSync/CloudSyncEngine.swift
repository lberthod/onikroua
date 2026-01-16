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
    
    private var vocabAddedObserver: DatabaseHandle?
    private var vocabChangedObserver: DatabaseHandle?
    private var vocabRemovedObserver: DatabaseHandle?
    
    private var achievementsAddedObserver: DatabaseHandle?
    private var achievementsChangedObserver: DatabaseHandle?
    private var achievementsRemovedObserver: DatabaseHandle?
    
    private var sessionsAddedObserver: DatabaseHandle?
    private var sessionsChangedObserver: DatabaseHandle?
    private var sessionsRemovedObserver: DatabaseHandle?
    
    private var userRef: DatabaseReference?
    private var vocabRef: DatabaseReference?
    private var achievementsRef: DatabaseReference?
    private var sessionsRef: DatabaseReference?

    private init() {
        setupAuthListener()
    }

    deinit {
        // Observers must be removed on MainActor, but deinit is nonisolated.
        // We use Task to hop to MainActor for cleanup.
        let vRef = vocabRef
        let aRef = achievementsRef
        let sRef = sessionsRef
        let uRef = userRef

        let progress = progressObserver
        let vocabAdded = vocabAddedObserver
        let vocabChanged = vocabChangedObserver
        let vocabRemoved = vocabRemovedObserver
        let achievAdded = achievementsAddedObserver
        let achievChanged = achievementsChangedObserver
        let achievRemoved = achievementsRemovedObserver
        let sessAdded = sessionsAddedObserver
        let sessChanged = sessionsChangedObserver
        let sessRemoved = sessionsRemovedObserver

        Task { @MainActor in
            if let handle = progress { uRef?.child("progress").removeObserver(withHandle: handle) }
            if let handle = vocabAdded { vRef?.removeObserver(withHandle: handle) }
            if let handle = vocabChanged { vRef?.removeObserver(withHandle: handle) }
            if let handle = vocabRemoved { vRef?.removeObserver(withHandle: handle) }
            if let handle = achievAdded { aRef?.removeObserver(withHandle: handle) }
            if let handle = achievChanged { aRef?.removeObserver(withHandle: handle) }
            if let handle = achievRemoved { aRef?.removeObserver(withHandle: handle) }
            if let handle = sessAdded { sRef?.removeObserver(withHandle: handle) }
            if let handle = sessChanged { sRef?.removeObserver(withHandle: handle) }
            if let handle = sessRemoved { sRef?.removeObserver(withHandle: handle) }
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
        
        let context = container.mainContext
        
        do {
            _ = try await fetchUserMeta(userId: userId)
            let cloudProgress = try await fetchUserProgress(userId: userId)
            
            if cloudProgress == nil {
                print("📝 CloudSync: No cloud data found - initializing new user")
                try await initializeNewUser(userId: userId, context: context)
                await bootstrap(userId: userId)
                return
            }
            
            if let progressDTO = cloudProgress {
                try await syncProgressToLocal(userId: userId, dto: progressDTO, context: context)
            }
            
            let vocabData = try await fetchAllVocab(userId: userId)
            for (_, dto) in vocabData {
                try await syncVocabToLocal(userId: userId, dto: dto, context: context)
            }
            
            let achievementsData = try await fetchAllAchievements(userId: userId)
            for (_, dto) in achievementsData {
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
        
        userRef = database.child("users").child(userId)
        guard let userRef = userRef else { return }
        
        // Progress: .value observer (entire progress object)
        progressObserver = userRef.child("progress").observe(.value) { [weak self] snapshot in
            Task { @MainActor in
                await self?.handleProgressUpdate(userId: userId, snapshot: snapshot)
            }
        }
        
        // Vocab: .childAdded, .childChanged, .childRemoved
        vocabRef = userRef.child("vocab")
        if let vocabRef = vocabRef {
            vocabAddedObserver = vocabRef.observe(.childAdded) { [weak self] snapshot in
                Task { @MainActor in
                    await self?.handleVocabAdded(userId: userId, snapshot: snapshot)
                }
            }
            vocabChangedObserver = vocabRef.observe(.childChanged) { [weak self] snapshot in
                Task { @MainActor in
                    await self?.handleVocabChanged(userId: userId, snapshot: snapshot)
                }
            }
            vocabRemovedObserver = vocabRef.observe(.childRemoved) { [weak self] snapshot in
                Task { @MainActor in
                    await self?.handleVocabRemoved(userId: userId, snapshot: snapshot)
                }
            }
        }
        
        // Achievements: .childAdded, .childChanged, .childRemoved
        achievementsRef = userRef.child("achievements")
        if let achievementsRef = achievementsRef {
            achievementsAddedObserver = achievementsRef.observe(.childAdded) { [weak self] snapshot in
                Task { @MainActor in
                    await self?.handleAchievementAdded(userId: userId, snapshot: snapshot)
                }
            }
            achievementsChangedObserver = achievementsRef.observe(.childChanged) { [weak self] snapshot in
                Task { @MainActor in
                    await self?.handleAchievementChanged(userId: userId, snapshot: snapshot)
                }
            }
            achievementsRemovedObserver = achievementsRef.observe(.childRemoved) { [weak self] snapshot in
                Task { @MainActor in
                    await self?.handleAchievementRemoved(userId: userId, snapshot: snapshot)
                }
            }
        }
        
        // Sessions: .childAdded, .childChanged, .childRemoved
        sessionsRef = userRef.child("sessions")
        if let sessionsRef = sessionsRef {
            sessionsAddedObserver = sessionsRef.observe(.childAdded) { [weak self] snapshot in
                Task { @MainActor in
                    await self?.handleSessionAdded(userId: userId, snapshot: snapshot)
                }
            }
            sessionsChangedObserver = sessionsRef.observe(.childChanged) { [weak self] snapshot in
                Task { @MainActor in
                    await self?.handleSessionChanged(userId: userId, snapshot: snapshot)
                }
            }
            sessionsRemovedObserver = sessionsRef.observe(.childRemoved) { [weak self] snapshot in
                Task { @MainActor in
                    await self?.handleSessionRemoved(userId: userId, snapshot: snapshot)
                }
            }
        }
        
        print("✅ CloudSync: Realtime observers setup for user \(userId) (all event types)")
    }
    
    private func removeObservers() {
        if let handle = progressObserver {
            userRef?.child("progress").removeObserver(withHandle: handle)
        }
        
        if let handle = vocabAddedObserver {
            vocabRef?.removeObserver(withHandle: handle)
        }
        if let handle = vocabChangedObserver {
            vocabRef?.removeObserver(withHandle: handle)
        }
        if let handle = vocabRemovedObserver {
            vocabRef?.removeObserver(withHandle: handle)
        }
        
        if let handle = achievementsAddedObserver {
            achievementsRef?.removeObserver(withHandle: handle)
        }
        if let handle = achievementsChangedObserver {
            achievementsRef?.removeObserver(withHandle: handle)
        }
        if let handle = achievementsRemovedObserver {
            achievementsRef?.removeObserver(withHandle: handle)
        }
        
        if let handle = sessionsAddedObserver {
            sessionsRef?.removeObserver(withHandle: handle)
        }
        if let handle = sessionsChangedObserver {
            sessionsRef?.removeObserver(withHandle: handle)
        }
        if let handle = sessionsRemovedObserver {
            sessionsRef?.removeObserver(withHandle: handle)
        }
        
        progressObserver = nil
        vocabAddedObserver = nil
        vocabChangedObserver = nil
        vocabRemovedObserver = nil
        achievementsAddedObserver = nil
        achievementsChangedObserver = nil
        achievementsRemovedObserver = nil
        sessionsAddedObserver = nil
        sessionsChangedObserver = nil
        sessionsRemovedObserver = nil
        
        userRef = nil
        vocabRef = nil
        achievementsRef = nil
        sessionsRef = nil
        
        print("🧹 CloudSync: All observers removed")
    }
    
    private func handleProgressUpdate(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = UserProgressDTO.fromDictionary(dict),
              let container = modelContainer else {
            return
        }
        
        let context = container.mainContext
        do {
            try await syncProgressToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Progress updated from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync progress - \(error)")
        }
    }
    
    // MARK: - Vocab Handlers
    
    private func handleVocabAdded(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = VocabWordDTO.fromDictionary(wordId: snapshot.key, dict),
              let container = modelContainer else {
            return
        }
        
        let context = container.mainContext
        do {
            try await syncVocabToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Vocab word '\(snapshot.key)' added from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync vocab add - \(error)")
        }
    }
    
    private func handleVocabChanged(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = VocabWordDTO.fromDictionary(wordId: snapshot.key, dict),
              let container = modelContainer else {
            return
        }
        
        let context = container.mainContext
        do {
            try await syncVocabToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Vocab word '\(snapshot.key)' changed from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync vocab change - \(error)")
        }
    }
    
    private func handleVocabRemoved(userId: String, snapshot: DataSnapshot) async {
        guard let container = modelContainer else { return }
        
        let wordId = snapshot.key
        let id = "\(userId)_\(wordId)"
        let context = container.mainContext
        
        do {
            let descriptor = FetchDescriptor<CachedVocabWord>(
                predicate: #Predicate { $0.id == id }
            )
            if let cached = try context.fetch(descriptor).first {
                context.delete(cached)
                try context.save()
                print("🗑️ CloudSync: Vocab word '\(wordId)' removed from local cache")
            }
        } catch {
            print("❌ CloudSync: Failed to remove vocab - \(error)")
        }
    }
    
    // MARK: - Achievement Handlers
    
    private func handleAchievementAdded(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = AchievementDTO.fromDictionary(achievementId: snapshot.key, dict),
              let container = modelContainer else {
            return
        }
        
        let context = container.mainContext
        do {
            try await syncAchievementToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Achievement '\(snapshot.key)' added from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync achievement add - \(error)")
        }
    }
    
    private func handleAchievementChanged(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = AchievementDTO.fromDictionary(achievementId: snapshot.key, dict),
              let container = modelContainer else {
            return
        }
        
        let context = container.mainContext
        do {
            try await syncAchievementToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Achievement '\(snapshot.key)' changed from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync achievement change - \(error)")
        }
    }
    
    private func handleAchievementRemoved(userId: String, snapshot: DataSnapshot) async {
        guard let container = modelContainer else { return }
        
        let achievementId = snapshot.key
        let id = "\(userId)_\(achievementId)"
        let context = container.mainContext
        
        do {
            let descriptor = FetchDescriptor<CachedAchievement>(
                predicate: #Predicate { $0.id == id }
            )
            if let cached = try context.fetch(descriptor).first {
                context.delete(cached)
                try context.save()
                print("🗑️ CloudSync: Achievement '\(achievementId)' removed from local cache")
            }
        } catch {
            print("❌ CloudSync: Failed to remove achievement - \(error)")
        }
    }
    
    // MARK: - Session Handlers
    
    private func handleSessionAdded(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = SessionDTO.fromDictionary(sessionId: snapshot.key, dict),
              let container = modelContainer else {
            return
        }
        
        let context = container.mainContext
        do {
            try await syncSessionToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Session '\(snapshot.key)' added from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync session add - \(error)")
        }
    }
    
    private func handleSessionChanged(userId: String, snapshot: DataSnapshot) async {
        guard snapshot.exists(), let dict = snapshot.value as? [String: Any],
              let dto = SessionDTO.fromDictionary(sessionId: snapshot.key, dict),
              let container = modelContainer else {
            return
        }
        
        let context = container.mainContext
        do {
            try await syncSessionToLocal(userId: userId, dto: dto, context: context)
            try context.save()
            print("📥 CloudSync: Session '\(snapshot.key)' changed from cloud")
        } catch {
            print("❌ CloudSync: Failed to sync session change - \(error)")
        }
    }
    
    private func handleSessionRemoved(userId: String, snapshot: DataSnapshot) async {
        guard let container = modelContainer else { return }
        
        let sessionId = snapshot.key
        let id = "\(userId)_\(sessionId)"
        let context = container.mainContext
        
        do {
            let descriptor = FetchDescriptor<CachedSession>(
                predicate: #Predicate { $0.id == id }
            )
            if let cached = try context.fetch(descriptor).first {
                context.delete(cached)
                try context.save()
                print("🗑️ CloudSync: Session '\(sessionId)' removed from local cache")
            }
        } catch {
            print("❌ CloudSync: Failed to remove session - \(error)")
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
                // Local is newer - ensure it's queued to push
                print("⚠️ CloudSync: Local progress is newer (\(cached.updatedAt) > \(dto.updatedAt)), ensuring push queued")
                try await ensureProgressInOutbox(userId: userId, cached: cached, context: context)
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
            } else {
                // Local is newer - ensure push queued
                print("⚠️ CloudSync: Local vocab '\(dto.wordId)' is newer, ensuring push queued")
                try await ensureVocabInOutbox(userId: userId, cached: cached, context: context)
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
            } else {
                // Local is newer - ensure push queued
                print("⚠️ CloudSync: Local achievement '\(dto.achievementId)' is newer, ensuring push queued")
                try await ensureAchievementInOutbox(userId: userId, cached: cached, context: context)
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
        
        if let cached = existing {
            if dto.updatedAt >= cached.updatedAt {
                cached.updateFrom(dto: dto)
                print("🔄 CloudSync: Session '\(dto.sessionId)' updated (cloud wins)")
            }
        } else {
            let newCache = CachedSession(userId: userId, dto: dto)
            context.insert(newCache)
            print("📝 CloudSync: Session '\(dto.sessionId)' cached locally")
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
    
    // MARK: - Outbox Helpers
    
    private func ensureProgressInOutbox(userId: String, cached: CachedUserProgress, context: ModelContext) async throws {
        let path = "users/\(userId)/progress"
        
        // Check if already in outbox
        let descriptor = FetchDescriptor<SyncOutboxItem>(
            predicate: #Predicate { $0.userId == userId && $0.path == path }
        )
        let existing = try context.fetch(descriptor).first
        
        if existing == nil {
            let dto = cached.toDTO()
            let outboxItem = SyncOutboxItem(
                userId: userId,
                path: path,
                payload: dto.toDictionary(),
                updatedAt: cached.updatedAt
            )
            context.insert(outboxItem)
            print("📤 CloudSync: Progress queued to outbox for push")
        }
    }
    
    private func ensureVocabInOutbox(userId: String, cached: CachedVocabWord, context: ModelContext) async throws {
        let path = "users/\(userId)/vocab/\(cached.wordId)"
        
        // Check if already in outbox
        let descriptor = FetchDescriptor<SyncOutboxItem>(
            predicate: #Predicate { $0.userId == userId && $0.path == path }
        )
        let existing = try context.fetch(descriptor).first
        
        if existing == nil {
            let dto = cached.toDTO()
            let outboxItem = SyncOutboxItem(
                userId: userId,
                path: path,
                payload: dto.toDictionary(),
                updatedAt: cached.updatedAt
            )
            context.insert(outboxItem)
            print("📤 CloudSync: Vocab '\(cached.wordId)' queued to outbox for push")
        }
    }
    
    private func ensureAchievementInOutbox(userId: String, cached: CachedAchievement, context: ModelContext) async throws {
        let path = "users/\(userId)/achievements/\(cached.achievementId)"
        
        // Check if already in outbox
        let descriptor = FetchDescriptor<SyncOutboxItem>(
            predicate: #Predicate { $0.userId == userId && $0.path == path }
        )
        let existing = try context.fetch(descriptor).first
        
        if existing == nil {
            let dto = cached.toDTO()
            let outboxItem = SyncOutboxItem(
                userId: userId,
                path: path,
                payload: dto.toDictionary(),
                updatedAt: cached.updatedAt
            )
            context.insert(outboxItem)
            print("📤 CloudSync: Achievement '\(cached.achievementId)' queued to outbox for push")
        }
    }
    
    func flushOutbox() async {
        guard let container = modelContainer,
              let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let context = container.mainContext
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
