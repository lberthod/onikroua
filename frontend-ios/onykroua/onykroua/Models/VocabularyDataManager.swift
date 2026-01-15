import Foundation

// MARK: - VocabularyDataManager (matching Android VocabularyData.kt)

public class VocabularyDataManager: ObservableObject {
    @Published private var italianVocabulary: [VocabCategory] = []
    @Published private var spanishVocabulary: [VocabCategory] = []
    @Published public var isLoading: Bool = false
    @Published public var loadingError: Error?
    
    // Cache pour les requêtes fréquentes
    private var sortedWordsCache: [String: [Character: [VocabWord]]] = [:]
    private var allWordsCache: [String: [VocabWord]] = [:]
    private var mainCategoriesCache: [String: [String]] = [:]
    
    // Track loaded languages
    private var loadedLanguages: Set<String> = []
    
    public static let shared = VocabularyDataManager()
    
    private init() {
        // Ne charge rien au démarrage - lazy loading
    }
    
    // Ensure language is loaded
    public func ensureLoaded(language: String) {
        guard !loadedLanguages.contains(language) else { return }
        loadVocabularyAsync(language: language)
    }
    
    public func loadVocabularyAsync(language: String) {
        guard !loadedLanguages.contains(language) else { return }
        
        Task { @MainActor in
            isLoading = true
            loadingError = nil
            
            do {
                let categories = try await loadVocabularyFromBundle(language: language)
                
                if language == "it" {
                    italianVocabulary = categories
                } else {
                    spanishVocabulary = categories
                }
                
                loadedLanguages.insert(language)
                invalidateCache(for: language)
                
                print("✅ Chargé \(categories.count) catégories (\(language)) avec \(categories.reduce(0) { $0 + $1.words.count }) mots")
            } catch {
                loadingError = error
                print("❌ Erreur de chargement: \(error)")
            }
            
            isLoading = false
        }
    }
    
    private func loadVocabularyFromBundle(language: String) async throws -> [VocabCategory] {
        let filename = language == "it" ? "vocabulary_it" : "vocabulary_es"
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw AppError.fileNotFound("\(filename).json")
        }
        
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw AppError.jsonLoadFailed(filename)
        }
        
        let decoder = JSONDecoder()
        
        // Decode raw categories
        var categories: [VocabCategory]
        do {
            categories = try decoder.decode([VocabCategory].self, from: data)
            
            // AUTOMATION: Trier les catégories par nom
            categories.sort { $0.name.lowercased() < $1.name.lowercased() }
            
            // Les mots seront triés ci-dessous lors de la reconstruction des catégories
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
        
        // Update each word with its category info AND sort words
        categories = categories.map { category in
            // Trier les mots de la catégorie avant de créer les nouveaux VocabWord
            let sortedRawWords = category.words.sorted { $0.word.lowercased() < $1.word.lowercased() }
            
            let updatedWords = sortedRawWords.map { word in
                VocabWord(
                    word: word.word,
                    translation: word.translation,
                    gender: word.gender,
                    example: word.example,
                    exampleTranslation: word.exampleTranslation,
                    category: word.category ?? category.name,
                    categoryIcon: word.categoryIcon ?? category.icon,
                    mainCategory: word.mainCategory ?? category.mainCategory,
                    subCategory: word.subCategory ?? category.subCategory
                )
            }
            return VocabCategory(
                name: category.name,
                icon: category.icon,
                words: updatedWords,
                mainCategory: category.mainCategory,
                subCategory: category.subCategory
            )
        }
        
        return categories
    }
    
    // MARK: - Public Methods (matching Android VocabularyData)
    
    public func getVocabularyByLanguage(_ language: String) -> [VocabCategory] {
        return language == "it" ? italianVocabulary : spanishVocabulary
    }
    
    public func getAllWords(language: String) -> [VocabWord] {
        // Vérifier le cache
        if let cached = allWordsCache[language] {
            return cached
        }
        
        // Calculer et mettre en cache
        let words = getVocabularyByLanguage(language)
            .flatMap { $0.words }
            .uniqueByWord()
        allWordsCache[language] = words
        return words
    }
    
    public func getCategories(language: String) -> [VocabCategory] {
        return getVocabularyByLanguage(language)
    }
    
    public func getWordsByCategory(language: String, categoryName: String) -> [VocabWord] {
        return getVocabularyByLanguage(language)
            .first { $0.name == categoryName }?
            .words ?? []
    }
    
    public func getWordsSortedAlphabetically(language: String) -> [Character: [VocabWord]] {
        // Vérifier le cache
        if let cached = sortedWordsCache[language] {
            return cached
        }
        
        // Calculer et mettre en cache
        let sorted = Dictionary(grouping: getAllWords(language: language).sorted { $0.word.lowercased() < $1.word.lowercased() }) { word in
            word.word.first?.uppercased().first ?? "?"
        }
        sortedWordsCache[language] = sorted
        return sorted
    }
    
    public func getMainCategories(language: String) -> [String] {
        // Vérifier le cache
        if let cached = mainCategoriesCache[language] {
            return cached
        }
        
        // Calculer et mettre en cache
        let categories = getVocabularyByLanguage(language)
            .compactMap { $0.mainCategory }
            .unique()
            .sorted()
        mainCategoriesCache[language] = categories
        return categories
    }
    
    public func getSubCategoriesByMainCategory(language: String, mainCategory: String) -> [VocabCategory] {
        return getVocabularyByLanguage(language)
            .filter { $0.mainCategory == mainCategory }
    }
    
    public func getCategoriesGroupedByMain(language: String) -> [String: [VocabCategory]] {
        return Dictionary(grouping: getVocabularyByLanguage(language).filter { $0.mainCategory != nil }) { category in
            category.mainCategory!
        }
    }
    
    // MARK: - Cache Management
    
    private func invalidateCache(for language: String) {
        sortedWordsCache.removeValue(forKey: language)
        allWordsCache.removeValue(forKey: language)
        mainCategoriesCache.removeValue(forKey: language)
    }
    
    public func clearAllCache() {
        sortedWordsCache.removeAll()
        allWordsCache.removeAll()
        mainCategoriesCache.removeAll()
    }
}

// MARK: - Legacy Support

public class VocabularyLoader {
    public static func loadVocabulary() -> [VocabularyCategory] {
        return VocabularyDataManager.shared.getVocabularyByLanguage("it")
    }
    
    public static func getAllWords() -> [VocabularyWord] {
        return VocabularyDataManager.shared.getAllWords(language: "it")
    }
    
    public static func getWords(forCategory category: String) -> [VocabularyWord] {
        return VocabularyDataManager.shared.getWordsByCategory(language: "it", categoryName: category)
    }
}
