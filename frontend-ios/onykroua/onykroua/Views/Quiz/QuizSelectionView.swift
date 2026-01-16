import SwiftUI
import SwiftData

public struct QuizSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var selectedType: QuizType = .vocabulary
    @State private var showQuizView = false
    @State private var currentSession: QuizSession?
    @State private var quizStats: [QuizStatistics] = []
    @State private var showingInfo = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let language: String
    
    public init(language: String) {
        self.language = language
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    typeSelectionSection
                    
                    startButton
                    
                    statisticsSection
                }
                .padding()
            }
            .navigationTitle("📝 Quiz")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showQuizView) {
                if let session = currentSession {
                    QuizGameView(session: session, language: language)
                        .onDisappear {
                            loadStats()
                        }
                }
            }
            .sheet(isPresented: $showingInfo) {
                QuizInfoSheet()
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadStats()
                VocabularyDataManager.shared.ensureLoaded(language: language)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("🎯")
                            .font(.system(size: 40))
                        
                        Text("Quiz Interactif")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("Teste tes connaissances et progresse rapidement")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingInfo = true }) {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            if !quizStats.isEmpty {
                HStack(spacing: 12) {
                    QuickStatBadge(
                        icon: "checkmark.circle.fill",
                        value: "\(quizStats.count)",
                        label: "Quiz",
                        color: .green
                    )
                    
                    QuickStatBadge(
                        icon: "star.fill",
                        value: "\(Int(averageScore))%",
                        label: "Moyenne",
                        color: .yellow
                    )
                    
                    QuickStatBadge(
                        icon: "flame.fill",
                        value: "\(currentStreak)",
                        label: "Série",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var typeSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Type de Quiz")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(QuizType.allCases, id: \.self) { type in
                    QuizTypeCard(
                        type: type,
                        isSelected: selectedType == type,
                        action: { selectedType = type }
                    )
                }
            }
        }
    }
    
    private var startButton: some View {
        Button(action: startQuiz) {
            HStack {
                Image(systemName: selectedType.icon)
                    .font(.title2)
                
                Text("Commencer le Quiz")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedType.color)
            )
        }
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 Historique récent")
                    .font(.headline)
                Spacer()
                
                if !quizStats.isEmpty {
                    Text("\(quizStats.count) quiz")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if quizStats.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Aucune statistique")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Commence ton premier quiz pour voir tes progrès!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(quizStats.prefix(3), id: \.id) { stat in
                        RecentQuizRow(stat: stat)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var averageScore: Double {
        guard !quizStats.isEmpty else { return 0 }
        let total = quizStats.reduce(0.0) { $0 + $1.score }
        return total / Double(quizStats.count)
    }
    
    private var currentStreak: Int {
        guard !quizStats.isEmpty else { return 0 }
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        for stat in quizStats {
            if calendar.isDate(stat.date, inSameDayAs: currentDate) || 
               calendar.isDate(stat.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate)!) {
                streak += 1
                if !calendar.isDate(stat.date, inSameDayAs: currentDate) {
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                }
            } else {
                break
            }
        }
        
        return min(streak, quizStats.count)
    }
    
    private func loadStats() {
        let userId = firebaseManager.userId ?? "guest"
        quizStats = QuizStatsManager.getQuizStats(userId: userId, modelContext: modelContext)
    }
    
    private func startQuiz() {
        let difficulty: QuizDifficulty = .intermediate
        let questions: [QuizQuestion]
        
        switch selectedType {
        case .vocabulary:
            questions = QuizDataManager.shared.generateVocabularyQuiz(difficulty: difficulty, language: language)
        case .conjugation:
            questions = QuizDataManager.shared.generateConjugationQuiz(difficulty: difficulty, language: language)
        case .grammar:
            questions = QuizDataManager.shared.generateGrammarQuiz(difficulty: difficulty, language: language)
        case .translation:
            questions = QuizDataManager.shared.generateTranslationQuiz(difficulty: difficulty, language: language)
        case .conversation:
            questions = QuizDataManager.shared.generateConversationQuiz(difficulty: difficulty, language: language)
        case .listening:
            questions = QuizDataManager.shared.generateListeningQuiz(difficulty: difficulty, language: language)
        case .mixed:
            questions = QuizDataManager.shared.generateMixedQuiz(difficulty: difficulty, language: language)
        }
        
        print("DEBUG: Generated \(questions.count) questions for \(selectedType.rawValue)")
        
        guard !questions.isEmpty else {
            errorMessage = "Impossible de générer des questions pour ce quiz. Essaie un autre type ou vérifie que du contenu est disponible."
            showError = true
            return
        }
        
        currentSession = QuizSession(type: selectedType, difficulty: difficulty, questions: questions)
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showQuizView = true
        }
    }
}

public struct QuizTypeCard: View {
    public let type: QuizType
    public let isSelected: Bool
    public let action: () -> Void
    
    public init(type: QuizType, isSelected: Bool, action: @escaping () -> Void) {
        self.type = type
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? type.color : .primary)
                
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? type.color.opacity(0.2) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuickStatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct RecentQuizRow: View {
    let stat: QuizStatistics
    
    private var scoreColor: Color {
        switch stat.score {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(stat.quizType)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(stat.difficulty)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
                
                Text(stat.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(stat.score))%")
                    .font(.headline)
                    .foregroundColor(scoreColor)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text("+\(stat.xpEarned)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct QuizInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎯 Comment fonctionnent les Quiz ?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Les quiz sont conçus pour tester et renforcer tes connaissances de manière interactive et ludique.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    InfoSection(
                        icon: "book.fill",
                        title: "Types de Quiz",
                        description: "Choisis parmi 7 types de quiz : Vocabulaire, Conjugaison, Grammaire, Traduction, Conversation, Écoute et Mixte."
                    )
                    
                    InfoSection(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Niveaux de Difficulté",
                        description: "3 niveaux disponibles : Débutant (A1-A2), Intermédiaire (B1-B2) et Avancé (C1-C2)."
                    )
                    
                    InfoSection(
                        icon: "star.fill",
                        title: "Système de Points",
                        description: "Gagne des XP en fonction de tes résultats. Plus tu réussis, plus tu gagnes de points pour débloquer de nouveaux contenus."
                    )
                    
                    InfoSection(
                        icon: "lightbulb.fill",
                        title: "Explications Pédagogiques",
                        description: "Après chaque réponse, tu reçois une explication détaillée pour comprendre tes erreurs et progresser."
                    )
                    
                    InfoSection(
                        icon: "flame.fill",
                        title: "Séries Quotidiennes",
                        description: "Fais au moins un quiz par jour pour maintenir ta série et rester motivé dans ton apprentissage."
                    )
                }
                .padding()
            }
            .navigationTitle("À propos des Quiz")
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
}

struct InfoSection: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
