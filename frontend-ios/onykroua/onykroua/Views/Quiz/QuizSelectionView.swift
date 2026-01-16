import SwiftUI

public struct QuizSelectionView: View {
    @State private var selectedType: QuizType = .vocabulary
    @State private var selectedDifficulty: QuizDifficulty = .beginner
    @State private var showQuizView = false
    @State private var currentSession: QuizSession?
    
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
                    
                    difficultySelectionSection
                    
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
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🎯")
                .font(.system(size: 60))
            
            Text("Teste tes connaissances")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choisis un type de quiz et un niveau de difficulté")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
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
    
    private var difficultySelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Niveau de Difficulté")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach(QuizDifficulty.allCases, id: \.self) { difficulty in
                    DifficultyCard(
                        difficulty: difficulty,
                        isSelected: selectedDifficulty == difficulty,
                        action: { selectedDifficulty = difficulty }
                    )
                }
            }
        }
    }
    
    private var startButton: some View {
        Button(action: startQuiz) {
            HStack {
                Text(selectedType.icon)
                    .font(.title2)
                
                Text("Commencer le Quiz")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedType.color)
            )
            .foregroundColor(.white)
        }
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 Mes Statistiques")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                StatItem(icon: "star.fill", value: "0", label: "Quiz complétés", color: .yellow)
                StatItem(icon: "percent", value: "0%", label: "Taux de réussite", color: .green)
                StatItem(icon: "flame.fill", value: "0", label: "Série", color: .orange)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func startQuiz() {
        let questions: [QuizQuestion]
        
        switch selectedType {
        case .vocabulary:
            questions = QuizDataManager.shared.generateVocabularyQuiz(difficulty: selectedDifficulty, language: language)
        case .conjugation:
            questions = QuizDataManager.shared.generateConjugationQuiz(difficulty: selectedDifficulty, language: language)
        case .grammar:
            questions = QuizDataManager.shared.generateGrammarQuiz(difficulty: selectedDifficulty, language: language)
        case .translation:
            questions = QuizDataManager.shared.generateTranslationQuiz(difficulty: selectedDifficulty, language: language)
        case .conversation:
            questions = QuizDataManager.shared.generateConversationQuiz(difficulty: selectedDifficulty, language: language)
        case .listening:
            questions = QuizDataManager.shared.generateMixedQuiz(difficulty: selectedDifficulty, language: language)
        case .mixed:
            questions = QuizDataManager.shared.generateMixedQuiz(difficulty: selectedDifficulty, language: language)
        }
        
        currentSession = QuizSession(type: selectedType, difficulty: selectedDifficulty, questions: questions)
        showQuizView = true
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
                Text(type.icon)
                    .font(.system(size: 40))
                
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

public struct DifficultyCard: View {
    public let difficulty: QuizDifficulty
    public let isSelected: Bool
    public let action: () -> Void
    
    public init(difficulty: QuizDifficulty, isSelected: Bool, action: @escaping () -> Void) {
        self.difficulty = difficulty
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(difficulty.icon)
                    .font(.title2)
                
                Text(difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
