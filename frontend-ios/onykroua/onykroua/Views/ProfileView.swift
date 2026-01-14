import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var env: AppEnvironment
    
    private var progressTracker: ProgressTracker {
        env.progressTracker
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 100, height: 100)
                            
                            Text("🎓")
                                .font(.system(size: 50))
                        }
                        
                        Text("utilisateur@onykroua.com")
                            .font(.headline)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Niveau \(progressTracker.getUserLevel())")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(20)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progression")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Niveau \(progressTracker.getUserLevel())")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(progressTracker.totalXP) XP")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            
                            ProgressView(value: progressTracker.getProgressToNextLevel())
                                .tint(.blue)
                            
                            Text("Niveau \(progressTracker.getUserLevel() + 1) dans \(100 - (progressTracker.totalXP % 100)) XP")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(icon: "book.fill", title: "Mots appris", value: "\(progressTracker.wordsLearned.count)", color: .blue)
                        StatCard(icon: "flame.fill", title: "Streak", value: "\(progressTracker.dailyStreak) j", color: .orange)
                        StatCard(icon: "star.fill", title: "XP Total", value: "\(progressTracker.totalXP)", color: .yellow)
                        StatCard(icon: "heart.fill", title: "Favoris", value: "\(progressTracker.favorites.count)", color: .red)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🏆 Succès")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            BadgeCard(emoji: "👋", title: "Débutant", unlocked: true)
                            BadgeCard(emoji: "💪", title: "Motivé", unlocked: progressTracker.dailyStreak >= 3)
                            BadgeCard(emoji: "🔥", title: "En feu", unlocked: progressTracker.dailyStreak >= 7)
                            BadgeCard(emoji: "📚", title: "Lecteur", unlocked: progressTracker.wordsLearned.count >= 20)
                            BadgeCard(emoji: "⭐", title: "Expert", unlocked: progressTracker.totalXP >= 500)
                            BadgeCard(emoji: "🏆", title: "Champion", unlocked: progressTracker.totalXP >= 1000)
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 0) {
                        ProfileRow(icon: "chart.bar.fill", title: "Statistiques détaillées", color: .green)
                        Divider().padding(.leading, 60)
                        ProfileRow(icon: "gear", title: "Paramètres", color: .gray)
                        Divider().padding(.leading, 60)
                        ProfileRow(icon: "info.circle.fill", title: "À propos", color: .blue)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    if let lastActivity = progressTracker.lastActivityDate {
                        Text("Dernière activité: \(formattedDate(lastActivity))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Déconnexion")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct BadgeCard: View {
    let emoji: String
    let title: String
    let unlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 40))
                .opacity(unlocked ? 1.0 : 0.3)
            
            Text(title)
                .font(.caption2)
                .fontWeight(unlocked ? .semibold : .regular)
                .foregroundColor(unlocked ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(unlocked ? Color.green.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(unlocked ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileView()
}
