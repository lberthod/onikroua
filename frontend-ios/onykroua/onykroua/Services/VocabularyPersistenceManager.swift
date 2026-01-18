import Foundation
import SwiftData
import onykroua

// MARK: - Vocabulary Persistence Manager
// NOTE: This file now uses the new Cache models from Models/Cache/

@MainActor
class VocabularyPersistenceManager: ObservableObject {
    static let shared = VocabularyPersistenceManager()
    
    var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    @Published var isMigrated: Bool = false
    @Published var isLoading: Bool = false
    @Published var migrationProgress: Double = 0.0
    @Published var error: Error?
    
    private let userDefaultsKey = "vocabulary_migrated_to_swiftdata"
    
    private init() {
        setupModelContainer()
        checkMigrationStatus()
    }
    
    // MARK: - Setup
    
    private func setupModelContainer() {
        do {
            let schema = Schema([
                // New Cache models from PR#1
                UserProgressCacheModel.self,
                VocabWordCacheModel.self,
                StudySessionCacheModel.self,
                // Existing models (out of PR#1 scope)
                GrammarRuleModel.self,
                ConjugationModel.self,
                FeedItemModel.self
                // CloudSync models (not yet included in project)
                // CachedAchievement.self,
                // CachedSession.self,
                // SyncOutboxItemCacheModel.self,
                // SyncMetadata.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer!)
            
            print("✅ SwiftData ModelContainer configured successfully")
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            self.error = error
        }
    }
    
    private func checkMigrationStatus() {
        isMigrated = UserDefaults.standard.bool(forKey: userDefaultsKey)
        print("📦 Migration status: \(isMigrated ? "Completed" : "Pending")")
    }
    
    // MARK: - Migration
    
    func migrateFromJSON(vocabularyData: [String: [VocabWord]], categories: [String: [VocabCategory]]) async {
        guard !isMigrated else {
            print("⚠️ Migration already completed")
            return
        }
        
        isLoading = true
        migrationProgress = 0.0
        
        do {
            guard let context = modelContext else {
                throw AppError.dataCorrupted
            }
            
            var totalItems = 0
            var processedItems = 0
            
            // Count total items
            for (_, words) in vocabularyData {
                totalItems += words.count
            }
            
            print("🔄 Starting migration of \(totalItems) vocabulary items...")
            
            // Migrate vocabulary words to VocabWordCacheModel
            for (language, words) in vocabularyData {
                for word in words {
                    let safeWordId = safeFirebaseKey(word.word)
                    let cacheId = "system_\(safeWordId)"
                    
                    let cacheModel = VocabWordCacheModel(
                        id: cacheId,
                        userId: "system",
                        wordId: safeWordId,
                        status: "new",
                        strength: 0,
                        lastSeenAt: 0,
                        reviewCount: 0,
                        correctCount: 0
                    )
                    
                    context.insert(cacheModel)
                    
                    processedItems += 1
                    migrationProgress = Double(processedItems) / Double(totalItems)
                    
                    // Batch save every 100 items
                    if processedItems % 100 == 0 {
                        try context.save()
                        print("💾 Saved batch: \(processedItems)/\(totalItems)")
                    }
                }
            }
            
            // Final save
            try context.save()
            
            // Mark as migrated
            UserDefaults.standard.set(true, forKey: userDefaultsKey)
            isMigrated = true
            migrationProgress = 1.0
            
            print("✅ Migration completed successfully: \(totalItems) items")
            
        } catch {
            print("❌ Migration failed: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Operations
    
    func fetchVocabulary(language: String) -> [VocabWord] {
        // Note: Vocabulary words are now loaded from JSON files directly
        // This method returns an empty array as vocabulary is managed externally
        print("ℹ️ Vocabulary is now loaded from JSON files, not from Cache")
        return []
    }
    
    func fetchCategories(language: String) -> [VocabCategory] {
        // Note: Categories are now loaded from JSON files directly
        // This method returns an empty array as categories are managed externally
        print("ℹ️ Categories are now loaded from JSON files, not from Cache")
        return []
    }
    
    func fetchWordsByCategory(language: String, category: String) -> [VocabWord] {
        // Note: Words are now loaded from JSON files directly
        print("ℹ️ Words are now loaded from JSON files, not from Cache")
        return []
    }
    
    func searchWords(language: String, query: String) -> [VocabWord] {
        // Note: Words are now loaded from JSON files directly
        print("ℹ️ Words are now loaded from JSON files, not from Cache")
        return []
    }
    
    // MARK: - Insert/Update Operations
    
    func saveWord(_ word: VocabWord, language: String) {
        // Note: Words are now loaded from JSON files directly
        print("ℹ️ Words are now loaded from JSON files, not from Cache")
    }
    
    func deleteWord(id: String) {
        // Note: Words are now loaded from JSON files directly
        print("ℹ️ Words are now loaded from JSON files, not from Cache")
    }
    
    // MARK: - Statistics
    
    func getWordCount(language: String) -> Int {
        // Note: Words are now loaded from JSON files directly
        print("ℹ️ Words are now loaded from JSON files, not from Cache")
        return 0
    }
    
    // MARK: - Reset
    
    func resetMigration() {
        UserDefaults.standard.set(false, forKey: userDefaultsKey)
        isMigrated = false
        print("🔄 Migration status reset")
    }
    
    func clearAllData() {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        do {
            try context.delete(model: VocabWordCacheModel.self)
            try context.save()
            
            resetMigration()
            print("✅ All vocabulary data cleared")
        } catch {
            print("❌ Failed to clear data: \(error)")
        }
    }
}
