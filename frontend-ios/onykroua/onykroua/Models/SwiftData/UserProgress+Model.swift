import Foundation
import SwiftData

// MARK: - SwiftData Model for User Progress

@Model
final class UserProgressModel {
    @Attribute(.unique) var userId: String
    var totalWordsLearned: Int
    var totalXP: Int
    var currentLevel: Int
    var dailyStreak: Int
    var longestStreak: Int
    var lastStudyDate: Date?
    var learnedWordsIds: [String]
    var favoriteWords: [String]
    var achievements: [String]
    var studyGoalMinutes: Int
    var totalStudyTimeMinutes: Int
    var dateCreated: Date
    var lastModified: Date
    
    init(
        userId: String = "default_user",
        totalWordsLearned: Int = 0,
        totalXP: Int = 0,
        currentLevel: Int = 1,
        dailyStreak: Int = 0,
        longestStreak: Int = 0,
        lastStudyDate: Date? = nil,
        learnedWordsIds: [String] = [],
        favoriteWords: [String] = [],
        achievements: [String] = [],
        studyGoalMinutes: Int = 15,
        totalStudyTimeMinutes: Int = 0,
        dateCreated: Date = Date(),
        lastModified: Date = Date()
    ) {
        self.userId = userId
        self.totalWordsLearned = totalWordsLearned
        self.totalXP = totalXP
        self.currentLevel = currentLevel
        self.dailyStreak = dailyStreak
        self.longestStreak = longestStreak
        self.lastStudyDate = lastStudyDate
        self.learnedWordsIds = learnedWordsIds
        self.favoriteWords = favoriteWords
        self.achievements = achievements
        self.studyGoalMinutes = studyGoalMinutes
        self.totalStudyTimeMinutes = totalStudyTimeMinutes
        self.dateCreated = dateCreated
        self.lastModified = lastModified
    }
}

// MARK: - SwiftData Model for Learned Word Entry

@Model
final class LearnedWordModel {
    @Attribute(.unique) var id: String
    var userId: String
    var wordId: String
    var word: String
    var translation: String
    var language: String
    var category: String
    var dateLearned: Date
    var reviewCount: Int
    var lastReviewDate: Date?
    var masteryLevel: Int
    var xpEarned: Int
    
    init(
        id: String = UUID().uuidString,
        userId: String = "default_user",
        wordId: String,
        word: String,
        translation: String,
        language: String,
        category: String,
        dateLearned: Date = Date(),
        reviewCount: Int = 0,
        lastReviewDate: Date? = nil,
        masteryLevel: Int = 1,
        xpEarned: Int = 10
    ) {
        self.id = id
        self.userId = userId
        self.wordId = wordId
        self.word = word
        self.translation = translation
        self.language = language
        self.category = category
        self.dateLearned = dateLearned
        self.reviewCount = reviewCount
        self.lastReviewDate = lastReviewDate
        self.masteryLevel = masteryLevel
        self.xpEarned = xpEarned
    }
}

// MARK: - SwiftData Model for Study Session

@Model
final class StudySessionModel {
    @Attribute(.unique) var id: String
    var userId: String
    var sessionDate: Date
    var durationMinutes: Int
    var wordsLearned: Int
    var wordsReviewed: Int
    var xpEarned: Int
    var language: String
    var activityType: String
    
    init(
        id: String = UUID().uuidString,
        userId: String = "default_user",
        sessionDate: Date = Date(),
        durationMinutes: Int,
        wordsLearned: Int = 0,
        wordsReviewed: Int = 0,
        xpEarned: Int = 0,
        language: String,
        activityType: String = "vocabulary"
    ) {
        self.id = id
        self.userId = userId
        self.sessionDate = sessionDate
        self.durationMinutes = durationMinutes
        self.wordsLearned = wordsLearned
        self.wordsReviewed = wordsReviewed
        self.xpEarned = xpEarned
        self.language = language
        self.activityType = activityType
    }
}
