import Foundation
import SwiftData

// MARK: - SwiftData Model for Grammar Rule

@Model
final class GrammarRuleModel {
    @Attribute(.unique) var id: String
    var ruleId: String
    var title: String
    var ruleDescription: String
    var language: String
    var category: String
    var difficulty: String
    var examples: [String]
    var exceptions: [String]
    var relatedRules: [String]
    var dateAdded: Date
    var lastModified: Date
    
    init(
        id: String = UUID().uuidString,
        ruleId: String,
        title: String,
        ruleDescription: String,
        language: String,
        category: String,
        difficulty: String = "beginner",
        examples: [String] = [],
        exceptions: [String] = [],
        relatedRules: [String] = [],
        dateAdded: Date = Date(),
        lastModified: Date = Date()
    ) {
        self.id = id
        self.ruleId = ruleId
        self.title = title
        self.ruleDescription = ruleDescription
        self.language = language
        self.category = category
        self.difficulty = difficulty
        self.examples = examples
        self.exceptions = exceptions
        self.relatedRules = relatedRules
        self.dateAdded = dateAdded
        self.lastModified = lastModified
    }
}

// MARK: - SwiftData Model for Conjugation

@Model
final class ConjugationModel {
    @Attribute(.unique) var id: String
    var verb: String
    var language: String
    var infinitive: String
    var tense: String
    var forms: [String: String]
    var isRegular: Bool
    var conjugationType: String
    var dateAdded: Date
    
    init(
        id: String = UUID().uuidString,
        verb: String,
        language: String,
        infinitive: String,
        tense: String,
        forms: [String: String] = [:],
        isRegular: Bool = true,
        conjugationType: String = "regular",
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.verb = verb
        self.language = language
        self.infinitive = infinitive
        self.tense = tense
        self.forms = forms
        self.isRegular = isRegular
        self.conjugationType = conjugationType
        self.dateAdded = dateAdded
    }
}

// MARK: - SwiftData Model for Cached Feed Item

@Model
final class FeedItemModel {
    @Attribute(.unique) var id: String
    var type: String
    var title: String
    var contentDescription: String
    var language: String
    var difficulty: String
    var estimatedTime: Int
    var isBookmarked: Bool
    var isCompleted: Bool
    var dateAdded: Date
    var lastAccessed: Date?
    var metadata: String?
    
    init(
        id: String = UUID().uuidString,
        type: String,
        title: String,
        contentDescription: String,
        language: String,
        difficulty: String = "beginner",
        estimatedTime: Int = 5,
        isBookmarked: Bool = false,
        isCompleted: Bool = false,
        dateAdded: Date = Date(),
        lastAccessed: Date? = nil,
        metadata: String? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.contentDescription = contentDescription
        self.language = language
        self.difficulty = difficulty
        self.estimatedTime = estimatedTime
        self.isBookmarked = isBookmarked
        self.isCompleted = isCompleted
        self.dateAdded = dateAdded
        self.lastAccessed = lastAccessed
        self.metadata = metadata
    }
}
