import Foundation

public struct VocabWordDTO: Codable {
    public let wordId: String
    public let status: String
    public let strength: Int
    public let lastSeenAt: Int64
    public let reviewCount: Int
    public let correctCount: Int
    public let updatedAt: Int64
    
    public init(
        wordId: String,
        status: String,
        strength: Int,
        lastSeenAt: Int64,
        reviewCount: Int,
        correctCount: Int,
        updatedAt: Int64
    ) {
        self.wordId = wordId
        self.status = status
        self.strength = strength
        self.lastSeenAt = lastSeenAt
        self.reviewCount = reviewCount
        self.correctCount = correctCount
        self.updatedAt = updatedAt
    }
    
    public func toDictionary() -> [String: Any] {
        return [
            "status": status,
            "strength": strength,
            "lastSeenAt": lastSeenAt,
            "reviewCount": reviewCount,
            "correctCount": correctCount,
            "updatedAt": updatedAt
        ]
    }
    
    public static func fromDictionary(wordId: String, _ dict: [String: Any]) -> VocabWordDTO? {
        let statusValue = dict["status"] as? String
        let strengthValue = dict["strength"] as? Int
        let lastSeenAtValue = toInt64(dict["lastSeenAt"])
        let reviewCountValue = dict["reviewCount"] as? Int
        let correctCountValue = dict["correctCount"] as? Int
        let updatedAtValue = toInt64(dict["updatedAt"])
        
        guard let status = statusValue,
              let strength = strengthValue,
              let lastSeenAt = lastSeenAtValue,
              let reviewCount = reviewCountValue,
              let correctCount = correctCountValue,
              let updatedAt = updatedAtValue else {
            return nil
        }
        return VocabWordDTO(
            wordId: wordId,
            status: status,
            strength: strength,
            lastSeenAt: lastSeenAt,
            reviewCount: reviewCount,
            correctCount: correctCount,
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
