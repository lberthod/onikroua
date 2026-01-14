import Foundation
import SwiftData

// MARK: - Vocabulary Persistence Manager

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
                VocabularyWordModel.self,
                VocabCategoryModel.self,
                LearnedWordModel.self,
                UserProgressModel.self,
                StudySessionModel.self,
                GrammarRuleModel.self,
                ConjugationModel.self,
                FeedItemModel.self
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
            for (_, cats) in categories {
                totalItems += cats.count
            }
            
            print("🔄 Starting migration of \(totalItems) items...")
            
            // Migrate vocabulary words
            for (language, words) in vocabularyData {
                for word in words {
                    let model = VocabularyWordModel.from(word, language: language)
                    context.insert(model)
                    
                    processedItems += 1
                    migrationProgress = Double(processedItems) / Double(totalItems)
                    
                    // Batch save every 100 items
                    if processedItems % 100 == 0 {
                        try context.save()
                        print("💾 Saved batch: \(processedItems)/\(totalItems)")
                    }
                }
            }
            
            // Migrate categories
            for (language, cats) in categories {
                for category in cats {
                    let model = VocabCategoryModel.from(category, language: language)
                    context.insert(model)
                    
                    processedItems += 1
                    migrationProgress = Double(processedItems) / Double(totalItems)
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
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return []
        }
        
        let predicate = #Predicate<VocabularyWordModel> { word in
            word.language == language
        }
        
        let descriptor = FetchDescriptor<VocabularyWordModel>(predicate: predicate)
        
        do {
            let models = try context.fetch(descriptor)
            print("✅ Fetched \(models.count) words for language: \(language)")
            return models.map { $0.toVocabWord() }
        } catch {
            print("❌ Failed to fetch vocabulary: \(error)")
            return []
        }
    }
    
    func fetchCategories(language: String) -> [VocabCategory] {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return []
        }
        
        let predicate = #Predicate<VocabCategoryModel> { category in
            category.language == language
        }
        
        let descriptor = FetchDescriptor<VocabCategoryModel>(predicate: predicate)
        
        do {
            let models = try context.fetch(descriptor)
            print("✅ Fetched \(models.count) categories for language: \(language)")
            return models.map { $0.toVocabCategory() }
        } catch {
            print("❌ Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func fetchWordsByCategory(language: String, category: String) -> [VocabWord] {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return []
        }
        
        let predicate = #Predicate<VocabularyWordModel> { word in
            word.language == language && word.category == category
        }
        
        let descriptor = FetchDescriptor<VocabularyWordModel>(predicate: predicate)
        
        do {
            let models = try context.fetch(descriptor)
            return models.map { $0.toVocabWord() }
        } catch {
            print("❌ Failed to fetch words by category: \(error)")
            return []
        }
    }
    
    func searchWords(language: String, query: String) -> [VocabWord] {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return []
        }
        
        // SwiftData predicates don't support .lowercased(), do filtering in memory
        let predicate = #Predicate<VocabularyWordModel> { word in
            word.language == language
        }
        
        let descriptor = FetchDescriptor<VocabularyWordModel>(predicate: predicate)
        
        do {
            let models = try context.fetch(descriptor)
            
            // Filter in memory for case-insensitive search
            let lowercaseQuery = query.lowercased()
            let filtered = models.filter { model in
                model.word.lowercased().contains(lowercaseQuery) ||
                model.translation.lowercased().contains(lowercaseQuery)
            }
            
            print("🔍 Found \(filtered.count) words matching '\(query)'")
            return filtered.map { $0.toVocabWord() }
        } catch {
            print("❌ Failed to search words: \(error)")
            return []
        }
    }
    
    // MARK: - Insert/Update Operations
    
    func saveWord(_ word: VocabWord, language: String) {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        let model = VocabularyWordModel.from(word, language: language)
        context.insert(model)
        
        do {
            try context.save()
            print("✅ Saved word: \(word.word)")
        } catch {
            print("❌ Failed to save word: \(error)")
        }
    }
    
    func deleteWord(id: String) {
        guard let context = modelContext else {
            print("❌ ModelContext not available")
            return
        }
        
        let predicate = #Predicate<VocabularyWordModel> { word in
            word.id == id
        }
        
        let descriptor = FetchDescriptor<VocabularyWordModel>(predicate: predicate)
        
        do {
            let models = try context.fetch(descriptor)
            if let model = models.first {
                context.delete(model)
                try context.save()
                print("✅ Deleted word with id: \(id)")
            }
        } catch {
            print("❌ Failed to delete word: \(error)")
        }
    }
    
    // MARK: - Statistics
    
    func getWordCount(language: String) -> Int {
        guard let context = modelContext else {
            return 0
        }
        
        let predicate = #Predicate<VocabularyWordModel> { word in
            word.language == language
        }
        
        let descriptor = FetchDescriptor<VocabularyWordModel>(predicate: predicate)
        
        do {
            let count = try context.fetchCount(descriptor)
            return count
        } catch {
            print("❌ Failed to get word count: \(error)")
            return 0
        }
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
            try context.delete(model: VocabularyWordModel.self)
            try context.delete(model: VocabCategoryModel.self)
            try context.save()
            
            resetMigration()
            print("✅ All vocabulary data cleared")
        } catch {
            print("❌ Failed to clear data: \(error)")
        }
    }
}
