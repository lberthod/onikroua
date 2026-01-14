import Foundation
import SwiftData

// MARK: - SwiftData Model for Vocabulary Word

@Model
final class VocabularyWordModel {
    @Attribute(.unique) var id: String
    var word: String
    var translation: String
    var language: String
    var category: String?
    var subCategory: String?
    var mainCategory: String?
    var gender: String?
    var example: String?
    var exampleTranslation: String?
    var categoryIcon: String?
    var dateAdded: Date
    var lastModified: Date
    
    init(
        id: String = UUID().uuidString,
        word: String,
        translation: String,
        language: String,
        category: String? = nil,
        subCategory: String? = nil,
        mainCategory: String? = nil,
        gender: String? = nil,
        example: String? = nil,
        exampleTranslation: String? = nil,
        categoryIcon: String? = nil,
        dateAdded: Date = Date(),
        lastModified: Date = Date()
    ) {
        self.id = id
        self.word = word
        self.translation = translation
        self.language = language
        self.category = category
        self.subCategory = subCategory
        self.mainCategory = mainCategory
        self.gender = gender
        self.example = example
        self.exampleTranslation = exampleTranslation
        self.categoryIcon = categoryIcon
        self.dateAdded = dateAdded
        self.lastModified = lastModified
    }
    
    // Convert from VocabWord to VocabularyWordModel
    static func from(_ vocabWord: VocabWord, language: String) -> VocabularyWordModel {
        return VocabularyWordModel(
            id: "\(language)_\(vocabWord.word)",
            word: vocabWord.word,
            translation: vocabWord.translation,
            language: language,
            category: vocabWord.category,
            subCategory: vocabWord.subCategory,
            mainCategory: vocabWord.mainCategory,
            gender: vocabWord.gender,
            example: vocabWord.example,
            exampleTranslation: vocabWord.exampleTranslation,
            categoryIcon: vocabWord.categoryIcon
        )
    }
    
    // Convert to VocabWord
    func toVocabWord() -> VocabWord {
        return VocabWord(
            word: word,
            translation: translation,
            gender: gender,
            example: example,
            exampleTranslation: exampleTranslation,
            category: category,
            categoryIcon: categoryIcon,
            mainCategory: mainCategory,
            subCategory: subCategory
        )
    }
}

// MARK: - SwiftData Model for Vocabulary Category

@Model
final class VocabCategoryModel {
    @Attribute(.unique) var id: String
    var name: String
    var language: String
    var icon: String
    var mainCategory: String?
    var subCategory: String?
    var dateAdded: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        language: String,
        icon: String = "📚",
        mainCategory: String? = nil,
        subCategory: String? = nil,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.language = language
        self.icon = icon
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.dateAdded = dateAdded
    }
    
    // Convert from VocabCategory
    static func from(_ category: VocabCategory, language: String) -> VocabCategoryModel {
        return VocabCategoryModel(
            id: "\(language)_\(category.name)",
            name: category.name,
            language: language,
            icon: category.icon,
            mainCategory: category.mainCategory,
            subCategory: category.subCategory
        )
    }
    
    // Convert to VocabCategory
    func toVocabCategory() -> VocabCategory {
        return VocabCategory(
            name: name,
            icon: icon,
            words: [],
            mainCategory: mainCategory,
            subCategory: subCategory
        )
    }
}
