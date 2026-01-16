import SwiftUI

public struct HeroMissionCard: View {
    public let mission: Mission
    public let onStart: () -> Void
    
    public init(mission: Mission, onStart: @escaping () -> Void) {
        self.mission = mission
        self.onStart = onStart
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(mission.type.icon)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title)
                        .font(.title3.bold())
                    Text(mission.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            ProgressView(value: mission.progress)
                .tint(.blue)
            
            HStack {
                Label("\(mission.estimatedTime) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label("\(mission.xpReward) XP", systemImage: "star.fill")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
            }
            
            Button(action: onStart) {
                Text("Commencer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

public struct HeroActionCard: View {
    public let action: RecommendedAction
    public let onStart: () -> Void
    
    public init(action: RecommendedAction, onStart: @escaping () -> Void) {
        self.action = action
        self.onStart = onStart
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: action.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.title)
                        .font(.title3.bold())
                    Text(action.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            HStack {
                Label("\(action.estimatedTime) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<action.priority, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Button(action: onStart) {
                Text("Démarrer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

public struct CompactProgressSection: View {
    public let progress: UserProgress
    
    public init(progress: UserProgress) {
        self.progress = progress
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Progression")
                    .font(.headline)
                Spacer()
                Text(progress.level.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(progress.level.color.opacity(0.2))
                    .foregroundColor(progress.level.color)
                    .cornerRadius(8)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("\(progress.currentXP) / \(progress.level.xpRequired) XP")
                        .font(.caption.bold())
                    Spacer()
                    Text("\(Int(progress.progressPercentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progress.progressPercentage)
                    .tint(progress.level.color)
            }
            
            HStack(spacing: 20) {
                StatItem(icon: "flame.fill", value: "\(progress.streak)", label: "Jours", color: .orange)
                StatItem(icon: "book.fill", value: "\(progress.lessonsCompleted)", label: "Leçons", color: .blue)
                StatItem(icon: "text.book.closed", value: "\(progress.wordsLearned)", label: "Mots", color: .green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

public struct StatItem: View {
    public let icon: String
    public let value: String
    public let label: String
    public let color: Color
    
    public init(icon: String, value: String, label: String, color: Color) {
        self.icon = icon
        self.value = value
        self.label = label
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

public struct ReviewReminderCard: View {
    public let dueCount: Int
    public let onTap: () -> Void
    
    public init(dueCount: Int, onTap: @escaping () -> Void) {
        self.dueCount = dueCount
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(dueCount) révisions en attente")
                        .font(.headline)
                    Text("Maintiens ta mémoire active")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
}

public struct QuickAccessCarousel: View {
    public var onLearningPath: () -> Void = {}
    public var onVocabulary: () -> Void = {}
    public var onConjugation: () -> Void = {}
    
    public init(onLearningPath: @escaping () -> Void = {}, onVocabulary: @escaping () -> Void = {}, onConjugation: @escaping () -> Void = {}) {
        self.onLearningPath = onLearningPath
        self.onVocabulary = onVocabulary
        self.onConjugation = onConjugation
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accès rapide")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: onLearningPath) {
                        QuickAccessItem(icon: "target", title: "Mon Parcours", color: .red)
                    }
                    Button(action: onVocabulary) {
                        QuickAccessItem(icon: "book.fill", title: "Vocabulaire", color: .green)
                    }
                    Button(action: onConjugation) {
                        QuickAccessItem(icon: "book.closed.fill", title: "Conjugaison", color: .blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .buttonStyle(.plain)
            }
        }
    }
}

public struct QuickAccessItem: View {
    public let icon: String
    public let title: String
    public let color: Color
    
    public init(icon: String, title: String, color: Color) {
        self.icon = icon
        self.title = title
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .cornerRadius(12)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(width: 80)
    }
}

public struct MotivationSection: View {
    public let progress: UserProgress
    
    public init(progress: UserProgress) {
        self.progress = progress
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text(motivationalMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
    
    private var motivationalMessage: String {
        if progress.streak >= 7 {
            return "Incroyable! \(progress.streak) jours d'affilée! 🔥"
        } else if progress.streak >= 3 {
            return "Continue comme ça! \(progress.streak) jours de suite!"
        } else if progress.wordsLearned >= 100 {
            return "Tu as appris \(progress.wordsLearned) mots. Bravo!"
        } else {
            return "Chaque jour compte. Continue ton excellent travail!"
        }
    }
}
