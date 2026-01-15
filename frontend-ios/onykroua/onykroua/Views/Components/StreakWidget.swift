import SwiftUI

struct StreakWidget: View {
    let streak: Int
    let longestStreak: Int
    let last7Days: [Bool]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("🔥")
                            .font(.title)
                        
                        Text("\(streak)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("jours")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Streak actuel")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("\(longestStreak)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Text("Record")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 4) {
                Text("7 derniers jours")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(0..<7) { index in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(last7Days[index] ? Color.orange : Color.gray.opacity(0.2))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text(last7Days[index] ? "✓" : "")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            )
                        
                        Text(dayName(for: index))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if streak >= 7 {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Incroyable ! Continue comme ça !")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.2))
                )
            } else if streak > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "hand.thumbsup.fill")
                        .foregroundColor(.blue)
                    Text("Bon début ! Vise 7 jours d'affilée")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.2))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func dayName(for index: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        guard let date = calendar.date(byAdding: .day, value: index - 6, to: today) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).prefix(1).uppercased()
    }
}

struct StreakCalendarView: View {
    let streak: Int
    let last7Days: [Bool]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Calendrier de Streak")
                    .font(.headline)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<7) { index in
                    VStack(spacing: 4) {
                        Text(dayName(for: index))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(last7Days[index] ? Color.orange : Color.gray.opacity(0.2))
                            .frame(height: 40)
                            .overlay(
                                Text(last7Days[index] ? "✓" : "")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func dayName(for index: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        guard let date = calendar.date(byAdding: .day, value: index - 6, to: today) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct XPProgressBar: View {
    let currentXP: Int
    let xpRequired: Int
    let level: CEFRLevel
    
    private var progress: Double {
        min(Double(currentXP) / Double(xpRequired), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(level.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.headline)
                    
                    Text("\(currentXP) / \(xpRequired) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let nextLevel = level.nextLevel {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(progress * 100))%")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("vers \(nextLevel.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: level.gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 20)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}
