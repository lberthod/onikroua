import Foundation
import SwiftData

@Model
final class SyncOutboxItemCacheModel {
    @Attribute(.unique) var id: String
    var userId: String
    var path: String
    var payloadJSON: String
    var updatedAt: Int64
    var attempts: Int
    var lastError: String?
    var createdAt: Int64
    var lastAttemptAt: Int64?
    
    init(userId: String, path: String, payload: [String: Any], updatedAt: Int64? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.path = path
        self.updatedAt = updatedAt ?? TimestampMapper.currentDateMilliseconds()
        self.attempts = 0
        self.createdAt = TimestampMapper.currentDateMilliseconds()
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            self.payloadJSON = jsonString
        } else {
            self.payloadJSON = "{}"
        }
    }
    
    func getPayload() -> [String: Any]? {
        guard let data = payloadJSON.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dict
    }
    
    func recordAttempt(error: String? = nil) {
        self.attempts += 1
        self.lastAttemptAt = TimestampMapper.currentDateMilliseconds()
        self.lastError = error
    }
}
