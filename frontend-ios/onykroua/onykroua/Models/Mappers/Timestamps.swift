import Foundation

public enum TimestampMapper {
    
    public static func toMilliseconds(_ date: Date) -> Int64 {
        return Int64(date.timeIntervalSince1970 * 1000)
    }
    
    public static func toMilliseconds(_ date: Date?) -> Int64? {
        guard let date = date else { return nil }
        return toMilliseconds(date)
    }
    
    public static func fromMilliseconds(_ ms: Int64) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
    }
    
    public static func currentDateMilliseconds() -> Int64 {
        return toMilliseconds(Date())
    }
}
