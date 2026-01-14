import Foundation

// MARK: - Vocabulary Models (matching Android VocabularyModels.kt)

public struct VocabWord: Codable, Identifiable {
    public let id = UUID()
    public let word: String
    public let translation: String
    public let gender: String?
    public let example: String?
    public let exampleTranslation: String?
    public let category: String?
    public let categoryIcon: String?
    public let mainCategory: String?
    public let subCategory: String?
    
    enum CodingKeys: String, CodingKey {
        case word, translation, gender, example, exampleTranslation
        case category, categoryIcon, mainCategory = "main_category", subCategory = "sub_category"
    }
    
    public init(word: String, translation: String, gender: String? = nil, example: String? = nil, 
                exampleTranslation: String? = nil, category: String? = nil, categoryIcon: String? = nil,
                mainCategory: String? = nil, subCategory: String? = nil) {
        self.word = word
        self.translation = translation
        self.gender = gender
        self.example = example
        self.exampleTranslation = exampleTranslation
        self.category = category
        self.categoryIcon = categoryIcon
        self.mainCategory = mainCategory
        self.subCategory = subCategory
    }
}

public struct VocabCategory: Codable, Identifiable {
    public let id = UUID()
    public let name: String
    public let icon: String
    public let words: [VocabWord]
    public let mainCategory: String?
    public let subCategory: String?
    
    enum CodingKeys: String, CodingKey {
        case name, icon, words
        case mainCategory = "main_category"
        case subCategory = "sub_category"
    }
    
    public init(name: String, icon: String, words: [VocabWord], mainCategory: String? = nil, subCategory: String? = nil) {
        self.name = name
        self.icon = icon
        self.words = words
        self.mainCategory = mainCategory
        self.subCategory = subCategory
    }
}

// Legacy support for old VocabularyWord name
public typealias VocabularyWord = VocabWord
public typealias VocabularyCategory = VocabCategory

