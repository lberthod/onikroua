import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var analyticsService: AdvancedAnalyticsService?
    @State private var gamificationManager: GamificationManager?
    @State private var insights: [AdvancedAnalyticsService.LearningInsight] = []
    @State private var recommendations: [AdvancedAnalyticsService.Recommendation] = []
    @State private var strengths: [AdvancedAnalyticsService.SkillArea] = []
    @State private var weaknesses: [AdvancedAnalyticsService.SkillArea] = []
    @State private var selectedTab: InsightTab = .overview
    
    enum InsightTab: String, CaseIterable {
        case overview = "Vue d'ensemble"
        case skills = "Compétences"
        case recommendations = "Recommandations"
        
        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .skills: return "star.fill"
            case .recommendations: return "lightbulb.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabSelector
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case .overview:
                            overviewContent
                        case .skills:
                            skillsContent
                        case .recommendations:
                            recommendationsContent
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("📊 Analyses")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadData()
            }
        }
    }
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(InsightTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        HStack(spacing: 8) {
                            Image(systemName: tab.icon)
                            Text(tab.rawValue)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color.blue : Color(.systemGray6))
                        )
                        .foregroundColor(selectedTab == tab ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    private var overviewContent: some View {
        VStack(spacing: 24) {
            if let progress = gamificationManager?.currentProgress {
                milestoneCard(progress: progress)
                
                studyPatternCard(progress: progress)
            }
            
            insightsSection
        }
    }
    
    private var skillsContent: some View {
        VStack(spacing: 24) {
            if !strengths.isEmpty {
                strengthsSection
            }
            
            if !weaknesses.isEmpty {
                weaknessesSection
            }
            
            if strengths.isEmpty && weaknesses.isEmpty {
                emptyStateView(
                    icon: "chart.bar",
                    title: "Pas encore de données",
                    message: "Continue à pratiquer pour voir tes compétences"
                )
            }
        }
    }
    
    private var recommendationsContent: some View {
        VStack(spacing: 24) {
            if !recommendations.isEmpty {
                ForEach(recommendations) { recommendation in
                    RecommendationCard(recommendation: recommendation)
                }
            } else {
                emptyStateView(
                    icon: "checkmark.circle",
                    title: "Aucune recommandation",
                    message: "Tu es sur la bonne voie !"
                )
            }
        }
    }
    
    private func milestoneCard(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("🎯 Prochain Objectif")
                    .font(.headline)
                Spacer()
            }
            
            if let prediction = analyticsService?.predictNextMilestone(progress: progress) {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prediction.milestone)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Dans \(prediction.daysRemaining) jours")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(prediction.estimatedDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(prediction.confidenceLabel)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    ProgressView(value: Double(progress.currentXP), total: Double(progress.currentXP + progress.xpToNextLevel))
                        .tint(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func studyPatternCard(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("📈 Habitudes d'Étude")
                    .font(.headline)
                Spacer()
            }
            
            if let pattern = analyticsService?.analyzeStudyPatterns(progress: progress) {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        PatternMetric(
                            icon: "clock.fill",
                            value: "\(pattern.totalStudyTime) min",
                            label: "Total",
                            color: .blue
                        )
                        
                        PatternMetric(
                            icon: "calendar",
                            value: "\(pattern.averageSessionTime) min",
                            label: "Moyenne",
                            color: .green
                        )
                        
                        PatternMetric(
                            icon: "chart.line.uptrend.xyaxis",
                            value: "\(Int(pattern.consistency * 100))%",
                            label: "Régularité",
                            color: .orange
                        )
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        
                        Text(pattern.intensity.recommendation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var insightsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("💡 Insights")
                    .font(.headline)
                Spacer()
            }
            
            if insights.isEmpty {
                emptyStateView(
                    icon: "lightbulb",
                    title: "Pas encore d'insights",
                    message: "Pratique régulièrement pour obtenir des analyses"
                )
            } else {
                ForEach(insights) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
    }
    
    private var strengthsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("💪 Points Forts")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(strengths) { skill in
                SkillCard(skill: skill, isStrength: true)
            }
        }
    }
    
    private var weaknessesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🎯 À Améliorer")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(weaknesses) { skill in
                SkillCard(skill: skill, isStrength: false)
            }
        }
    }
    
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func loadData() {
        guard analyticsService == nil else { return }
        
        analyticsService = AdvancedAnalyticsService(modelContext: modelContext)
        gamificationManager = GamificationManager(modelContext: modelContext)
        
        if let progress = gamificationManager?.currentProgress {
            insights = analyticsService?.analyzeProgress(progress: progress) ?? []
            recommendations = analyticsService?.generateRecommendations(progress: progress) ?? []
            
            let skillAnalysis = analyticsService?.analyzeSkillAreas(progress: progress)
            strengths = skillAnalysis?.0 ?? []
            weaknesses = skillAnalysis?.1 ?? []
        }
    }
}

struct InsightCard: View {
    let insight: AdvancedAnalyticsService.LearningInsight
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundColor(color(for: insight.color))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color(for: insight.color).opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.headline)
                
                Text(insight.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: insight.trend.icon)
                .foregroundColor(color(for: insight.trend.color))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private func color(for name: String) -> Color {
        switch name {
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        default: return .gray
        }
    }
}

struct SkillCard: View {
    let skill: AdvancedAnalyticsService.SkillArea
    let isStrength: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(skill.level.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.name)
                        .font(.headline)
                    
                    Text(skill.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(skill.score))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isStrength ? .green : .orange)
                    
                    Text(skill.level.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: skill.score / 100)
                .tint(isStrength ? .green : .orange)
            
            HStack {
                Text("\(skill.reviewCount) révisions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let lastPracticed = skill.lastPracticed {
                    Text(lastPracticed.relativeDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct RecommendationCard: View {
    let recommendation: AdvancedAnalyticsService.Recommendation
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(recommendation.icon)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(recommendation.title)
                            .font(.headline)
                        
                        Text(recommendation.priority.label)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(priorityColor.opacity(0.2))
                            )
                            .foregroundColor(priorityColor)
                    }
                    
                    Text(recommendation.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text("\(recommendation.estimatedTime) min")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("+\(recommendation.potentialXP) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.yellow)
            }
            
            Button(action: {}) {
                Text(recommendation.actionText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(priorityColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(priorityColor.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct PatternMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
