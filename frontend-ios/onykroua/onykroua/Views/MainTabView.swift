import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Tab = .home
    @State private var gamificationManager: GamificationManager?
    
    enum Tab {
        case home
        case practice
        case vocabulary
        case progress
        case profile
        
        var title: String {
            switch self {
            case .home: return "Accueil"
            case .practice: return "Pratique"
            case .vocabulary: return "Vocabulaire"
            case .progress: return "Progression"
            case .profile: return "Profil"
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .practice: return "dumbbell.fill"
            case .vocabulary: return "book.fill"
            case .progress: return "chart.bar.fill"
            case .profile: return "person.fill"
            }
        }
        
        var inactiveIcon: String {
            switch self {
            case .home: return "house"
            case .practice: return "dumbbell"
            case .vocabulary: return "book"
            case .progress: return "chart.bar"
            case .profile: return "person"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.title, systemImage: selectedTab == .home ? Tab.home.icon : Tab.home.inactiveIcon)
                }
                .tag(Tab.home)
            
            PracticeHubView(language: "it")
                .tabItem {
                    Label(Tab.practice.title, systemImage: selectedTab == .practice ? Tab.practice.icon : Tab.practice.inactiveIcon)
                }
                .tag(Tab.practice)
            
            VocabularyView_Enhanced()
                .tabItem {
                    Label(Tab.vocabulary.title, systemImage: selectedTab == .vocabulary ? Tab.vocabulary.icon : Tab.vocabulary.inactiveIcon)
                }
                .tag(Tab.vocabulary)
            
            ProgressDashboardView()
                .tabItem {
                    Label(Tab.progress.title, systemImage: selectedTab == .progress ? Tab.progress.icon : Tab.progress.inactiveIcon)
                }
                .tag(Tab.progress)
            
            ProfileView()
                .tabItem {
                    Label(Tab.profile.title, systemImage: selectedTab == .profile ? Tab.profile.icon : Tab.profile.inactiveIcon)
                }
                .tag(Tab.profile)
        }
        .tint(.blue)
        .onAppear {
            setupGamification()
        }
    }
    
    private func setupGamification() {
        if gamificationManager == nil {
            gamificationManager = GamificationManager(modelContext: modelContext)
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gamificationManager: GamificationManager?
    @State private var showQuizSelection = false
    @State private var showReviewSession = false
    @State private var showInsights = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let progress = gamificationManager?.currentProgress {
                        welcomeSection(progress: progress)
                        streakSection(progress: progress)
                        quickActionsSection
                        todayGoalSection(progress: progress)
                        recentActivitySection
                    } else {
                        loadingView
                    }
                }
                .padding()
            }
            .navigationTitle("Onikroua")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showInsights = true }) {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showQuizSelection) {
                QuizSelectionView(language: "it")
            }
            .sheet(isPresented: $showReviewSession) {
                ReviewSessionView()
            }
            .sheet(isPresented: $showInsights) {
                InsightsView()
            }
            .onAppear {
                setupManagers()
            }
        }
    }
    
    private func welcomeSection(progress: UserProgress) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ciao! 👋")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Prêt à apprendre l'italien?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(progress.level.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                        .foregroundColor(.blue)
                    
                    Text("Niveau \(progress.levelNumber)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                StatCard(
                    icon: "star.fill",
                    value: "\(progress.currentXP)",
                    label: "XP",
                    color: .yellow
                )
                
                StatCard(
                    icon: "flame.fill",
                    value: "\(progress.streak)",
                    label: "Série",
                    color: .orange
                )
                
                StatCard(
                    icon: "book.fill",
                    value: "\(progress.wordsLearned)",
                    label: "Mots",
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
    
    private func streakSection(progress: UserProgress) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Série de \(progress.streak) jours")
                        .font(.headline)
                    
                    if progress.streak > 0 {
                        Text("Continue comme ça! 🎯")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Commence aujourd'hui!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if progress.streak >= progress.longestStreak {
                    Text("🏆")
                        .font(.title)
                }
            }
            
            ProgressView(value: progress.streak > 0 ? 1.0 : 0.0)
                .tint(.orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("⚡ Actions Rapides")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    icon: "pencil.circle.fill",
                    title: "Quiz",
                    subtitle: "10 questions",
                    color: .blue,
                    action: { showQuizSelection = true }
                )
                
                QuickActionCard(
                    icon: "arrow.clockwise.circle.fill",
                    title: "Révision",
                    subtitle: "SRS adaptatif",
                    color: .purple,
                    action: { showReviewSession = true }
                )
                
                QuickActionCard(
                    icon: "rectangle.stack.fill",
                    title: "Flashcards",
                    subtitle: "Vocabulaire",
                    color: .green,
                    action: {}
                )
                
                QuickActionCard(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Conversation",
                    subtitle: "24 scénarios",
                    color: .orange,
                    action: {}
                )
            }
        }
    }
    
    private func todayGoalSection(progress: UserProgress) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("🎯 Objectif du Jour")
                    .font(.headline)
                Spacer()
                Text("0/5")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: 0.0, total: 5.0)
                .tint(.blue)
            
            Text("Complete 5 activités pour atteindre ton objectif")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var recentActivitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 Activité Récente")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ActivityRow(
                    icon: "checkmark.circle.fill",
                    title: "Quiz de vocabulaire complété",
                    subtitle: "Il y a 2 heures",
                    color: .green
                )
                
                ActivityRow(
                    icon: "star.fill",
                    title: "50 XP gagnés",
                    subtitle: "Aujourd'hui",
                    color: .yellow
                )
                
                ActivityRow(
                    icon: "trophy.fill",
                    title: "Badge 'Débutant' débloqué",
                    subtitle: "Hier",
                    color: .orange
                )
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Chargement...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func setupManagers() {
        if gamificationManager == nil {
            gamificationManager = GamificationManager(modelContext: modelContext)
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
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
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}
