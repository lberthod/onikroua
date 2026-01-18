import Foundation

public struct StudySessionDTO: Codable {
    public let sessionId: String
    public let startedAt: Int64
    public let endedAt: Int64
    public let itemsCount: Int
    public let correctCount: Int
    public let xpGained: Int
    public let activityType: String
    public let updatedAt: Int64
    
    public init(
        sessionId: String,
        startedAt: Int64,
        endedAt: Int64,
        itemsCount: Int,
        correctCount: Int,
        xpGained: Int,
        activityType: String,
        updatedAt: Int64
    ) {
        self.sessionId = sessionId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.itemsCount = itemsCount
        self.correctCount = correctCount
        self.xpGained = xpGained
        self.activityType = activityType
        self.updatedAt = updatedAt
    }
    
    public func toDictionary() -> [String: Any] {
        return [
            "startedAt": startedAt,
            "endedAt": endedAt,
            "itemsCount": itemsCount,
            "correctCount": correctCount,
            "xpGained": xpGained,
            "activityType": activityType,
            "updatedAt": updatedAt
        ]
    }
    
    public static func fromDictionary(sessionId: String, _ dict: [String: Any]) -> StudySessionDTO? {
        let startedAtValue = toInt64(dict["startedAt"])
        let endedAtValue = toInt64(dict["endedAt"])
        let itemsCountValue = dict["itemsCount"] as? Int
        let correctCountValue = dict["correctCount"] as? Int
        let xpGainedValue = dict["xpGained"] as? Int
        let activityTypeValue = dict["activityType"] as? String
        let updatedAtValue = toInt64(dict["updatedAt"])
        
        guard let startedAt = startedAtValue,
              let endedAt = endedAtValue,
              let itemsCount = itemsCountValue,
              let correctCount = correctCountValue,
              let xpGained = xpGainedValue,
              let activityType = activityTypeValue,
              let updatedAt = updatedAtValue else {
            return nil
        }
        return StudySessionDTO(
            sessionId: sessionId,
            startedAt: startedAt,
            endedAt: endedAt,
            itemsCount: itemsCount,
            correctCount: correctCount,
            xpGained: xpGained,
            activityType: activityType,
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
