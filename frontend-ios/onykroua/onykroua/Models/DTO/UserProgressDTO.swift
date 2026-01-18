import Foundation

public struct UserProgressDTO: Codable {
    public let level: Int
    public let xp: Int
    public let streakDays: Int
    public let longestStreak: Int
    public let lastStudyAt: Int64
    public let wordsLearned: Int
    public let wordsReviewed: Int
    public let lessonsCompleted: Int
    public let quizzesCompleted: Int
    public let quizzesCorrect: Int
    public let conversationsCompleted: Int
    public let grammarRulesLearned: Int
    public let verbsLearned: Int
    public let studyTimeMinutes: Int
    public let sessionsCompleted: Int
    public let updatedAt: Int64
    
    public init(
        level: Int,
        xp: Int,
        streakDays: Int,
        longestStreak: Int,
        lastStudyAt: Int64,
        wordsLearned: Int,
        wordsReviewed: Int,
        lessonsCompleted: Int,
        quizzesCompleted: Int,
        quizzesCorrect: Int,
        conversationsCompleted: Int,
        grammarRulesLearned: Int,
        verbsLearned: Int,
        studyTimeMinutes: Int,
        sessionsCompleted: Int,
        updatedAt: Int64
    ) {
        self.level = level
        self.xp = xp
        self.streakDays = streakDays
        self.longestStreak = longestStreak
        self.lastStudyAt = lastStudyAt
        self.wordsLearned = wordsLearned
        self.wordsReviewed = wordsReviewed
        self.lessonsCompleted = lessonsCompleted
        self.quizzesCompleted = quizzesCompleted
        self.quizzesCorrect = quizzesCorrect
        self.conversationsCompleted = conversationsCompleted
        self.grammarRulesLearned = grammarRulesLearned
        self.verbsLearned = verbsLearned
        self.studyTimeMinutes = studyTimeMinutes
        self.sessionsCompleted = sessionsCompleted
        self.updatedAt = updatedAt
    }
    
    public func toDictionary() -> [String: Any] {
        return [
            "level": level,
            "xp": xp,
            "streakDays": streakDays,
            "longestStreak": longestStreak,
            "lastStudyAt": lastStudyAt,
            "wordsLearned": wordsLearned,
            "wordsReviewed": wordsReviewed,
            "lessonsCompleted": lessonsCompleted,
            "quizzesCompleted": quizzesCompleted,
            "quizzesCorrect": quizzesCorrect,
            "conversationsCompleted": conversationsCompleted,
            "grammarRulesLearned": grammarRulesLearned,
            "verbsLearned": verbsLearned,
            "studyTimeMinutes": studyTimeMinutes,
            "sessionsCompleted": sessionsCompleted,
            "updatedAt": updatedAt
        ]
    }
    
    public static func fromDictionary(_ dict: [String: Any]) -> UserProgressDTO? {
        let levelValue = dict["level"] as? Int
        let xpValue = dict["xp"] as? Int
        let streakDaysValue = dict["streakDays"] as? Int
        let longestStreakValue = dict["longestStreak"] as? Int
        let lastStudyAtValue = toInt64(dict["lastStudyAt"])
        let wordsLearnedValue = dict["wordsLearned"] as? Int
        let wordsReviewedValue = dict["wordsReviewed"] as? Int
        let lessonsCompletedValue = dict["lessonsCompleted"] as? Int
        let quizzesCompletedValue = dict["quizzesCompleted"] as? Int
        let quizzesCorrectValue = dict["quizzesCorrect"] as? Int
        let conversationsCompletedValue = dict["conversationsCompleted"] as? Int
        let grammarRulesLearnedValue = dict["grammarRulesLearned"] as? Int
        let verbsLearnedValue = dict["verbsLearned"] as? Int
        let studyTimeMinutesValue = dict["studyTimeMinutes"] as? Int
        let sessionsCompletedValue = dict["sessionsCompleted"] as? Int
        let updatedAtValue = toInt64(dict["updatedAt"])
        
        guard let level = levelValue,
              let xp = xpValue,
              let streakDays = streakDaysValue,
              let longestStreak = longestStreakValue,
              let lastStudyAt = lastStudyAtValue,
              let wordsLearned = wordsLearnedValue,
              let wordsReviewed = wordsReviewedValue,
              let lessonsCompleted = lessonsCompletedValue,
              let quizzesCompleted = quizzesCompletedValue,
              let quizzesCorrect = quizzesCorrectValue,
              let conversationsCompleted = conversationsCompletedValue,
              let grammarRulesLearned = grammarRulesLearnedValue,
              let verbsLearned = verbsLearnedValue,
              let studyTimeMinutes = studyTimeMinutesValue,
              let sessionsCompleted = sessionsCompletedValue,
              let updatedAt = updatedAtValue else {
            return nil
        }
        
        return UserProgressDTO(
            level: level,
            xp: xp,
            streakDays: streakDays,
            longestStreak: longestStreak,
            lastStudyAt: lastStudyAt,
            wordsLearned: wordsLearned,
            wordsReviewed: wordsReviewed,
            lessonsCompleted: lessonsCompleted,
            quizzesCompleted: quizzesCompleted,
            quizzesCorrect: quizzesCorrect,
            conversationsCompleted: conversationsCompleted,
            grammarRulesLearned: grammarRulesLearned,
            verbsLearned: verbsLearned,
            studyTimeMinutes: studyTimeMinutes,
            sessionsCompleted: sessionsCompleted,
            updatedAt: updatedAt
        )
    }
}

private func toInt64(_ value: Any?) -> Int64? {
    if let int64 = value as? Int64 { return int64 }
    if let int = value as? Int { return Int64(int) }
    if let double = value as? Double { return Int64(double) }
    if let string = value as? String, let parsed = Int64(string) { return parsed }
    return nil
}
