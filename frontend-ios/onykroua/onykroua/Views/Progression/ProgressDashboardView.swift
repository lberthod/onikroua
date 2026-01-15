import SwiftUI
import SwiftData
import Charts

struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gamificationManager: GamificationManager?
    @State private var analyticsService: AnalyticsService?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let manager = gamificationManager,
                   let progress = manager.currentProgress,
                   let analytics = analyticsService {
                    VStack(spacing: 20) {
                        levelProgressCard(progress: progress)
                        
                        streakCard(progress: progress, analytics: analytics)
                        
                        weeklyStatsCard(progress: progress, analytics: analytics)
                        
                        xpChartCard(progress: progress, analytics: analytics)
                        
                        performanceCard(progress: progress)
                        
                        recommendationsCard(progress: progress, analytics: analytics)
                    }
                    .padding()
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("📊 Progression")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if gamificationManager == nil {
                gamificationManager = GamificationManager(modelContext: modelContext)
                analyticsService = AnalyticsService(modelContext: modelContext)
            }
        }
    }
    
    private func levelProgressCard(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(progress.level.icon)
                    .font(.system(size: 50))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(progress.level.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(progress.currentXP) / \(progress.level.xpRequired) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(progress.progressPercentage * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    if let nextLevel = progress.level.nextLevel {
                        Text("→ \(nextLevel.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            ProgressView(value: progress.progressPercentage)
                .tint(LinearGradient(colors: progress.level.gradientColors, startPoint: .leading, endPoint: .trailing))
                .frame(height: 12)
            
            if let nextLevel = progress.level.nextLevel {
                Text("Encore \(progress.xpToNextLevel) XP pour atteindre \(nextLevel.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func streakCard(progress: UserProgress, analytics: AnalyticsService) -> some View {
        StreakWidget(
            streak: progress.streak,
            longestStreak: progress.longestStreak,
            last7Days: analytics.calculateStudyStreak(progress: progress)
        )
    }
    
    private func weeklyStatsCard(progress: UserProgress, analytics: AnalyticsService) -> some View {
        let stats = analytics.getWeeklyStats(progress: progress)
        
        return VStack(spacing: 16) {
            HStack {
                Text("📈 Cette Semaine")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DashboardWeeklyStatItem(
                    icon: "star.fill",
                    value: "\(stats.xpGained)",
                    label: "XP gagnés",
                    color: .yellow
                )
                
                DashboardWeeklyStatItem(
                    icon: "clock.fill",
                    value: "\(stats.studyTimeMinutes) min",
                    label: "Temps d'étude",
                    color: .blue
                )
                
                DashboardWeeklyStatItem(
                    icon: "book.fill",
                    value: "\(stats.wordsLearned)",
                    label: "Mots appris",
                    color: .green
                )
                
                DashboardWeeklyStatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(stats.lessonsCompleted)",
                    label: "Leçons",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func xpChartCard(progress: UserProgress, analytics: AnalyticsService) -> some View {
        let data = analytics.getLast7DaysXP(progress: progress)
        
        return VStack(spacing: 16) {
            HStack {
                Text("📊 XP des 7 derniers jours")
                    .font(.headline)
                Spacer()
            }
            
            Chart(data) { item in
                BarMark(
                    x: .value("Jour", item.dayName),
                    y: .value("XP", item.xp)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func performanceCard(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("🎯 Performance")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                DashboardPerformanceRow(
                    label: "Mots appris",
                    value: progress.wordsLearned,
                    target: progress.level.estimatedWordsToKnow,
                    icon: "book.fill",
                    color: .blue
                )
                
                DashboardPerformanceRow(
                    label: "Taux de réussite quiz",
                    value: Int(progress.quizSuccessRate * 100),
                    target: 100,
                    icon: "checkmark.circle.fill",
                    color: .green,
                    suffix: "%"
                )
                
                DashboardPerformanceRow(
                    label: "Conversations complétées",
                    value: progress.conversationsCompleted,
                    target: 10,
                    icon: "bubble.left.and.bubble.right.fill",
                    color: .purple
                )
                
                DashboardPerformanceRow(
                    label: "Règles de grammaire",
                    value: progress.grammarRulesLearned,
                    target: 20,
                    icon: "text.book.closed.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func recommendationsCard(progress: UserProgress, analytics: AnalyticsService) -> some View {
        let recommendations = analytics.generatePersonalizedRecommendations(progress: progress)
        
        return VStack(spacing: 16) {
            HStack {
                Text("💡 Recommandations")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(recommendations, id: \.self) { recommendation in
                    HStack {
                        Text(recommendation)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct DashboardWeeklyStatItem: View {
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
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct DashboardPerformanceRow: View {
    let label: String
    let value: Int
    let target: Int
    let icon: String
    let color: Color
    var suffix: String = ""
    
    private var progress: Double {
        min(Double(value) / Double(target), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(label)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(value)\(suffix) / \(target)\(suffix)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            ProgressView(value: progress)
                .tint(color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
