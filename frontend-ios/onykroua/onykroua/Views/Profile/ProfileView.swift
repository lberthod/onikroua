import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gamificationManager: GamificationManager?
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showInsights = false
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let progress = gamificationManager?.currentProgress {
                        profileHeader(progress: progress)
                        statsSection(progress: progress)
                        achievementsPreview
                        learningSection(progress: progress)
                        settingsSection
                    } else {
                        ProgressView()
                    }
                }
                .padding()
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
            .sheet(isPresented: $showInsights) {
                InsightsView()
            }
            .onAppear {
                setupManagers()
            }
        }
    }
    
    private func profileHeader(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text("👤")
                    .font(.system(size: 50))
            }
            
            VStack(spacing: 8) {
                Text("Apprenant")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 16) {
                    Label(progress.level.displayName, systemImage: "star.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                        .foregroundColor(.blue)
                    
                    Label("Italien", systemImage: "globe")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.2))
                        )
                        .foregroundColor(.green)
                }
            }
            
            Button(action: { showEditProfile = true }) {
                Text("Modifier le profil")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
    
    private func statsSection(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 Statistiques")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatsCard(
                    icon: "star.fill",
                    value: "\(progress.currentXP)",
                    label: "XP Total",
                    color: .yellow
                )
                
                StatsCard(
                    icon: "flame.fill",
                    value: "\(progress.streak)",
                    label: "Série Actuelle",
                    color: .orange
                )
                
                StatsCard(
                    icon: "calendar",
                    value: "\(progress.longestStreak)",
                    label: "Record Série",
                    color: .red
                )
                
                StatsCard(
                    icon: "trophy.fill",
                    value: "\(progress.achievementsUnlocked.count)",
                    label: "Badges",
                    color: .purple
                )
                
                StatsCard(
                    icon: "book.fill",
                    value: "\(progress.wordsLearned)",
                    label: "Mots Appris",
                    color: .blue
                )
                
                StatsCard(
                    icon: "checkmark.circle.fill",
                    value: "\(progress.quizzesCompleted)",
                    label: "Quiz Complétés",
                    color: .green
                )
            }
        }
    }
    
    private var achievementsPreview: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🏆 Badges")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showAchievements = true }) {
                    Text("Voir tout")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<5) { index in
                        BadgePreviewCard(
                            icon: "star.fill",
                            title: "Badge \(index + 1)",
                            isUnlocked: index < 2
                        )
                    }
                }
            }
        }
    }
    
    private func learningSection(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("📚 Apprentissage")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                LearningRow(
                    icon: "book.fill",
                    title: "Vocabulaire",
                    value: "\(progress.wordsLearned) mots",
                    progress: Double(progress.wordsLearned) / Double(progress.level.estimatedWordsToKnow),
                    color: .blue
                )
                
                LearningRow(
                    icon: "text.book.closed.fill",
                    title: "Grammaire",
                    value: "\(progress.grammarRulesLearned) règles",
                    progress: Double(progress.grammarRulesLearned) / 50.0,
                    color: .purple
                )
                
                LearningRow(
                    icon: "pencil.circle.fill",
                    title: "Conjugaison",
                    value: "\(progress.verbsLearned) verbes",
                    progress: Double(progress.verbsLearned) / 80.0,
                    color: .green
                )
                
                LearningRow(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Conversation",
                    value: "\(progress.conversationsCompleted) scénarios",
                    progress: Double(progress.conversationsCompleted) / 24.0,
                    color: .orange
                )
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 12) {
            SettingsButton(
                icon: "chart.bar.fill",
                title: "Analyses & Insights",
                color: .blue,
                action: { showInsights = true }
            )
            
            SettingsButton(
                icon: "bell.fill",
                title: "Notifications",
                color: .orange,
                action: { showSettings = true }
            )
            
            SettingsButton(
                icon: "gearshape.fill",
                title: "Paramètres",
                color: .gray,
                action: { showSettings = true }
            )
            
            SettingsButton(
                icon: "questionmark.circle.fill",
                title: "Aide & Support",
                color: .purple,
                action: {}
            )
        }
    }
    
    private func setupManagers() {
        if gamificationManager == nil {
            gamificationManager = GamificationManager(modelContext: modelContext)
        }
    }
}

struct StatsCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
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
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct BadgePreviewCard: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.2) : Color(.systemGray5))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? .yellow : .gray)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(isUnlocked ? .primary : .secondary)
        }
        .opacity(isUnlocked ? 1.0 : 0.5)
    }
}

struct LearningRow: View {
    let icon: String
    let title: String
    let value: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: min(1.0, progress))
                .tint(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(UserDefaults.Keys.notificationsEnabled) private var notificationsEnabled = true
    @AppStorage(UserDefaults.Keys.dailyGoal) private var dailyGoal = 5
    @State private var selectedLanguage = "Italiano"
    @State private var showDeleteAccount = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Apprentissage") {
                    HStack {
                        Text("Langue d'apprentissage")
                        Spacer()
                        Text(selectedLanguage)
                            .foregroundColor(.secondary)
                    }
                    
                    Stepper("Objectif quotidien: \(dailyGoal)", value: $dailyGoal, in: 1...20)
                }
                
                Section("Notifications") {
                    Toggle("Activer les notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        HStack {
                            Text("Rappel quotidien")
                            Spacer()
                            Text("20:00")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Apparence") {
                    HStack {
                        Text("Thème")
                        Spacer()
                        Text("Système")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Compte") {
                    Button("Se déconnecter") {
                        // Logout
                    }
                    .foregroundColor(.blue)
                    
                    Button("Supprimer le compte") {
                        showDeleteAccount = true
                    }
                    .foregroundColor(.red)
                }
                
                Section("À propos") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Politique de confidentialité") {}
                    Button("Conditions d'utilisation") {}
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .alert("Supprimer le compte", isPresented: $showDeleteAccount) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    // Delete account
                }
            } message: {
                Text("Cette action est irréversible. Toutes tes données seront supprimées.")
            }
        }
    }
}
