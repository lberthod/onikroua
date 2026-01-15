import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gamificationManager: GamificationManager?
    @State private var selectedFilter: AchievementFilter = .all
    
    enum AchievementFilter: String, CaseIterable {
        case all = "Tous"
        case unlocked = "Débloqués"
        case locked = "Verrouillés"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let manager = gamificationManager, let progress = manager.currentProgress {
                        statsHeader(progress: progress)
                    }
                    
                    filterSegment
                    
                    achievementsGrid
                }
                .padding()
            }
            .navigationTitle("🏆 Badges")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if gamificationManager == nil {
                gamificationManager = GamificationManager(modelContext: modelContext)
            }
        }
    }
    
    private func statsHeader(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                AchievementStatCard(
                    icon: "trophy.fill",
                    value: "\(unlockedCount)",
                    label: "Débloqués",
                    color: .orange
                )
                
                AchievementStatCard(
                    icon: "lock.fill",
                    value: "\(lockedCount)",
                    label: "Restants",
                    color: .gray
                )
                
                AchievementStatCard(
                    icon: "star.fill",
                    value: "\(totalXPFromAchievements)",
                    label: "XP Bonus",
                    color: .yellow
                )
            }
            
            ProgressView(value: Double(unlockedCount), total: Double(totalAchievements))
                .tint(.blue)
            
            Text("\(unlockedCount) / \(totalAchievements) badges débloqués (\(completionPercentage)%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var filterSegment: some View {
        Picker("Filtre", selection: $selectedFilter) {
            ForEach(AchievementFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var achievementsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(filteredAchievements) { achievement in
                AchievementCard(
                    achievement: achievement,
                    progress: gamificationManager?.getAchievementProgress(for: achievement.achievementType) ?? 0
                )
            }
        }
    }
    
    private var filteredAchievements: [Achievement] {
        guard let achievements = gamificationManager?.achievements else { return [] }
        
        switch selectedFilter {
        case .all:
            return achievements.sorted { $0.isUnlocked && !$1.isUnlocked }
        case .unlocked:
            return achievements.filter { $0.isUnlocked }
        case .locked:
            return achievements.filter { !$0.isUnlocked }
        }
    }
    
    private var unlockedCount: Int {
        gamificationManager?.getUnlockedAchievements().count ?? 0
    }
    
    private var lockedCount: Int {
        gamificationManager?.getLockedAchievements().count ?? 0
    }
    
    private var totalAchievements: Int {
        gamificationManager?.achievements.count ?? 0
    }
    
    private var totalXPFromAchievements: Int {
        gamificationManager?.getUnlockedAchievements().reduce(0) { $0 + $1.achievementType.xpReward } ?? 0
    }
    
    private var completionPercentage: Int {
        guard totalAchievements > 0 else { return 0 }
        return (unlockedCount * 100) / totalAchievements
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.achievementType.rarity.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Text(achievement.achievementType.icon)
                    .font(.system(size: 40))
                    .grayscale(achievement.isUnlocked ? 0 : 1)
                    .opacity(achievement.isUnlocked ? 1.0 : 0.3)
                
                if !achievement.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .offset(x: 20, y: -20)
                }
            }
            
            VStack(spacing: 4) {
                Text(achievement.achievementType.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.achievementType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            if achievement.isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text("+\(achievement.achievementType.xpReward) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                if let date = achievement.unlockedDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                if progress > 0 {
                    VStack(spacing: 4) {
                        ProgressView(value: progress)
                            .tint(.blue)
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct AchievementStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
