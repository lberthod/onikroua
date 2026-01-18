import Foundation
import SwiftData
import FirebaseAuth
import FirebaseDatabase
import onykroua

@MainActor
class VocabRepository: ObservableObject {
    private let modelContainer: ModelContainer
    private let database = Database.database().reference()
    
    init(container: ModelContainer) {
        self.modelContainer = container
    }
    
    // CloudSync models not included in project - commenting out methods
    /*
    func getVocabWord(wordId: String) -> CachedVocabWord? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        
        let safeWordId = safeFirebaseKey(wordId)
        let context = modelContainer.mainContext
        let id = "\(userId)_\(safeWordId)"
        let descriptor = FetchDescriptor<CachedVocabWord>(
            predicate: #Predicate { $0.id == id }
        )
        
        return try? context.fetch(descriptor).first
    }
    
    func getAllVocabWords() -> [CachedVocabWord] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedVocabWord>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\CachedVocabWord.lastSeenAt, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getWordsByStatus(_ status: String) -> [CachedVocabWord] {
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<CachedVocabWord>(
            predicate: #Predicate { $0.userId == userId && $0.status == status }
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func markWordAsLearning(wordId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let safeWordId = safeFirebaseKey(wordId)
        let context = modelContainer.mainContext
        let id = "\(userId)_\(safeWordId)"
        let descriptor = FetchDescriptor<CachedVocabWord>(
            predicate: #Predicate { $0.id == id }
        )
        
        let nowMs = TimestampMapper.currentDateMilliseconds()
        
        if let cached = try context.fetch(descriptor).first {
            cached.status = "learning"
            cached.lastSeenAt = nowMs
            cached.reviewCount += 1
            cached.updatedAt = nowMs
            try context.save()
            
            try await pushVocabToCloud(userId: userId, cached: cached)
        } else {
            let dto = VocabWordDTO(
                wordId: safeWordId,
                status: "learning",
                strength: 25,
                lastSeenAt: nowMs,
                reviewCount: 1,
                correctCount: 0,
                updatedAt: nowMs
            )
            let newCache = CachedVocabWord(userId: userId, dto: dto)
            context.insert(newCache)
            try context.save()
            
            try await pushVocabToCloud(userId: userId, cached: newCache)
        }
    }
    
    func markWordAsKnown(wordId: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let safeWordId = safeFirebaseKey(wordId)
        let context = modelContainer.mainContext
        let id = "\(userId)_\(safeWordId)"
        let descriptor = FetchDescriptor<CachedVocabWord>(
            predicate: #Predicate { $0.id == id }
        )
        
        let nowMs = TimestampMapper.currentDateMilliseconds()
        
        if let cached = try context.fetch(descriptor).first {
            cached.status = "known"
            cached.strength = 100
            cached.lastSeenAt = nowMs
            cached.updatedAt = nowMs
            try context.save()
            
            try await pushVocabToCloud(userId: userId, cached: cached)
        } else {
            let dto = VocabWordDTO(
                wordId: safeWordId,
                status: "known",
                strength: 100,
                lastSeenAt: nowMs,
                reviewCount: 1,
                correctCount: 1,
                updatedAt: nowMs
            )
            let newCache = CachedVocabWord(userId: userId, dto: dto)
            context.insert(newCache)
            try context.save()
            
            try await pushVocabToCloud(userId: userId, cached: newCache)
        }
    }
    
    func recordReview(wordId: String, correct: Bool) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RepositoryError.userNotAuthenticated
        }
        
        let safeWordId = safeFirebaseKey(wordId)
        let context = modelContainer.mainContext
        let id = "\(userId)_\(safeWordId)"
        let descriptor = FetchDescriptor<CachedVocabWord>(
            predicate: #Predicate { $0.id == id }
        )
        
        let nowMs = TimestampMapper.currentDateMilliseconds()
        
        if let cached = try context.fetch(descriptor).first {
            cached.reviewCount += 1
            if correct {
                cached.correctCount += 1
                cached.strength = min(100, cached.strength + 15)
                
                if cached.strength >= 100 && cached.status == "learning" {
                    cached.status = "known"
                }
            } else {
                cached.strength = max(0, cached.strength - 20)
                
                if cached.strength < 80 && cached.status == "known" {
                    cached.status = "learning"
                }
            }
            
            cached.lastSeenAt = nowMs
            cached.updatedAt = nowMs
            try context.save()
            
            try await pushVocabToCloud(userId: userId, cached: cached)
        } else {
            let dto = VocabWordDTO(
                wordId: safeWordId,
                status: correct ? "learning" : "new",
                strength: correct ? 25 : 10,
                lastSeenAt: nowMs,
                reviewCount: 1,
                correctCount: correct ? 1 : 0,
                updatedAt: nowMs
            )
            let newCache = CachedVocabWord(userId: userId, dto: dto)
            context.insert(newCache)
            try context.save()
            
            try await pushVocabToCloud(userId: userId, cached: newCache)
        }
    }
    
    func getKnownWordsCount() -> Int {
        return getWordsByStatus("known").count
    }
    
    func getLearningWordsCount() -> Int {
        return getWordsByStatus("learning").count
    }
    
    private func pushVocabToCloud(userId: String, cached: CachedVocabWord) async throws {
        let dto = cached.toDTO()
        let path = "users/\(userId)/vocab/\(dto.wordId)"
        
        let context = modelContainer.mainContext
        try await enqueueWrite(userId: userId, path: path, payload: dto.toDictionary(), context: context)
    }
    
    private func enqueueWrite(userId: String, path: String, payload: [String: Any], context: ModelContext) async throws {
        do {
            try await database.child(path).setValue(payload)
            print("✅ VocabRepository: Direct write succeeded - \(path)")
        } catch {
            print("⚠️ VocabRepository: Direct write failed, enqueueing - \(error)")
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
    
    // MARK: - Stub Methods for LearnedWordsManager
    // CloudSync models not included in project - these are stub implementations
    
    func getWordsByStatus(_ status: String) -> [VocabWordDTO] {
        return []
    }
    
    func markWordAsKnown(wordId: String) async throws {
        // Stub implementation - CloudSync models not included
        print("⚠️ VocabRepository.markWordAsKnown called but CloudSync models not included")
    }
    
    func markWordAsLearning(wordId: String) async throws {
        // Stub implementation - CloudSync models not included
        print("⚠️ VocabRepository.markWordAsLearning called but CloudSync models not included")
    }
}
