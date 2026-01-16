import Foundation
import SwiftUI

// MARK: - Array Extensions

extension Array where Element: Hashable {
    func uniqueByWord() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
    
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - String Extensions

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var safeFirebasePath: String {
        return self.replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "$", with: "_")
            .replacingOccurrences(of: "#", with: "_")
            .replacingOccurrences(of: "[", with: "_")
            .replacingOccurrences(of: "]", with: "_")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    var withoutEmojis: String {
        return String(self.filter { !$0.isEmoji })
    }
    
    func removingAccents() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func levenshteinDistance(to other: String) -> Int {
        let m = self.count
        let n = other.count
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            matrix[i][0] = i
        }
        
        for j in 0...n {
            matrix[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                let cost = self[self.index(self.startIndex, offsetBy: i-1)] == other[other.index(other.startIndex, offsetBy: j-1)] ? 0 : 1
                matrix[i][j] = Swift.min(
                    matrix[i-1][j] + 1,
                    matrix[i][j-1] + 1,
                    matrix[i-1][j-1] + cost
                )
            }
        }
        
        return matrix[m][n]
    }
    
    func similarityScore(to other: String) -> Double {
        let distance = Double(self.levenshteinDistance(to: other))
        let maxLength = Double(max(self.count, other.count))
        guard maxLength > 0 else { return 1.0 }
        return 1.0 - (distance / maxLength)
    }
}

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

// MARK: - Date Extensions

extension Date {
    func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: self)
        return components.day ?? 0
    }
    
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay()) ?? self
    }
    
    func add(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func formatted(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    public var relativeDescription: String {
        if isToday {
            return "Aujourd'hui"
        } else if isYesterday {
            return "Hier"
        } else {
            let days = Date().daysSince(self)
            if days < 7 {
                return "Il y a \(days) jours"
            } else if days < 30 {
                let weeks = days / 7
                return "Il y a \(weeks) semaine\(weeks > 1 ? "s" : "")"
            } else {
                return formatted(dateStyle: .short)
            }
        }
    }
}

// MARK: - Color Extensions

extension Color {
    static let appPrimary = Color.blue
    static let appSecondary = Color.purple
    static let appAccent = Color.orange
    static let appSuccess = Color.green
    static let appError = Color.red
    static let appWarning = Color.yellow
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Int Extensions

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Double Extensions

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var asPercentage: String {
        return String(format: "%.0f%%", self)
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedLanguage = "selectedLanguage"
        static let userLevel = "userLevel"
        static let dailyGoal = "dailyGoal"
        static let notificationsEnabled = "notificationsEnabled"
        static let lastOpenDate = "lastOpenDate"
        static let appLaunchCount = "appLaunchCount"
    }
    
    func setObject<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            set(encoded, forKey: key)
        }
    }
    
    func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
}

// MARK: - Collection Extensions

extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

// MARK: - VocabWord Extensions

extension VocabWord {
    var firebaseId: String {
        return "\(word)_\(translation)".safeFirebasePath
    }
}

// MARK: - Optional Extensions

extension Optional where Wrapped == String {
    var orEmpty: String {
        return self ?? ""
    }
}

extension Optional where Wrapped == Int {
    var orZero: Int {
        return self ?? 0
    }
}

// MARK: - Binding Extensions

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
