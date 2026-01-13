import Foundation

// MARK: - Vocabulary JSON Models

struct VocabularyCategory: Codable, Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let words: [VocabularyWord]
    
    enum CodingKeys: String, CodingKey {
        case name, icon, words
    }
}

struct VocabularyWord: Codable, Identifiable {
    let id = UUID()
    let word: String
    let translation: String
    let example: String
    let exampleTranslation: String
    
    enum CodingKeys: String, CodingKey {
        case word, translation, example, exampleTranslation
    }
}

// MARK: - Vocabulary Loader

class VocabularyLoader {
    static func loadVocabulary() -> [VocabularyCategory] {
        guard let url = Bundle.main.url(forResource: "vocabulary_it", withExtension: "json") else {
            print("❌ Fichier vocabulary_it.json introuvable")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let categories = try decoder.decode([VocabularyCategory].self, from: data)
            print("✅ Chargé \(categories.count) catégories avec \(categories.reduce(0) { $0 + $1.words.count }) mots")
            return categories
        } catch {
            print("❌ Erreur de chargement: \(error)")
            return []
        }
    }
    
    static func getAllWords() -> [VocabularyWord] {
        return loadVocabulary().flatMap { $0.words }
    }
    
    static func getWords(forCategory category: String) -> [VocabularyWord] {
        return loadVocabulary()
            .first { $0.name == category }?
            .words ?? []
    }
}
