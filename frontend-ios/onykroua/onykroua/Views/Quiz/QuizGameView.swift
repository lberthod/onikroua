import SwiftUI
import SwiftData

public struct QuizGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var session: QuizSession
    @State private var selectedAnswer: Int?
    @State private var showExplanation = false
    @State private var showResults = false
    @State private var showHint = false
    @State private var gamificationManager: GamificationManager?
    @State private var showCorrectAnimation = false
    @State private var showWrongAnimation = false
    
    public let language: String
    
    public init(session: QuizSession, language: String) {
        _session = State(initialValue: session)
        self.language = language
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if showResults {
                    QuizResultsView(session: session, onDismiss: {
                        dismiss()
                    })
                } else {
                    quizContent
                }
            }
            .navigationTitle("\(session.type.icon) Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Quitter") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if gamificationManager == nil {
                    gamificationManager = GamificationManager(modelContext: modelContext)
                }
            }
        }
    }
    
    private var quizContent: some View {
        VStack(spacing: 0) {
            progressHeader
            
            ScrollView {
                VStack(spacing: 24) {
                    questionCard
                    
                    answersSection
                    
                    if showExplanation, let explanation = currentQuestion?.explanation {
                        explanationCard(explanation: explanation)
                    }
                    
                    navigationButtons
                }
                .padding()
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(session.currentQuestionIndex + 1) / \(session.questions.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(session.currentQuestionIndex), total: Double(session.questions.count))
                .tint(session.type.color)
        }
        .padding()
    }
    
    private var questionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: session.type.icon)
                    .font(.title)
                    .foregroundColor(session.type.color)
                
                Text(session.type.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(session.type.color.opacity(0.2))
                    )
                    .foregroundColor(session.type.color)
                
                Spacer()
                
                if selectedAnswer == nil && !showHint {
                    Button(action: { 
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showHint = true
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "lightbulb.fill")
                            Text("Indice")
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.15))
                        )
                    }
                }
            }
            
            Text(currentQuestion?.question ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if showHint && selectedAnswer == nil {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.orange)
                    Text("Prends ton temps et réfléchis bien à la bonne réponse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            Group {
                if showCorrectAnimation {
                    VStack {
                        Text("✅")
                            .font(.system(size: 80))
                        Text("Bravo !")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else if showWrongAnimation {
                    VStack {
                        Text("❌")
                            .font(.system(size: 80))
                        Text("Oups !")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
    
    private var answersSection: some View {
        VStack(spacing: 12) {
            ForEach(Array((currentQuestion?.options ?? []).enumerated()), id: \.offset) { index, option in
                AnswerButton(
                    text: option,
                    index: index,
                    isSelected: selectedAnswer == index,
                    isCorrect: showExplanation && index == currentQuestion?.correctAnswerIndex,
                    isWrong: showExplanation && selectedAnswer == index && index != currentQuestion?.correctAnswerIndex,
                    action: {
                        guard selectedAnswer == nil else { return }
                        selectAnswer(index)
                    }
                )
            }
        }
    }
    
    private func explanationCard(explanation: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Explication")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(explanation)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if session.currentQuestionIndex > 0 {
                Button(action: previousQuestion) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Précédent")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            
            if selectedAnswer != nil {
                Button(action: nextQuestion) {
                    HStack {
                        Text(session.currentQuestionIndex < session.questions.count - 1 ? "Suivant" : "Terminer")
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(session.type.color)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var currentQuestion: QuizQuestion? {
        guard session.currentQuestionIndex < session.questions.count else { return nil }
        return session.questions[session.currentQuestionIndex]
    }
    
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        session.answerQuestion(answerIndex: index)
        
        let isCorrect = index == currentQuestion?.correctAnswerIndex
        
        if isCorrect {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCorrectAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    showCorrectAnimation = false
                    showExplanation = true
                }
            }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showWrongAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    showWrongAnimation = false
                    showExplanation = true
                }
            }
        }
    }
    
    private func nextQuestion() {
        if session.isCompleted {
            saveQuizResults()
            awardXP()
            showResults = true
        } else {
            selectedAnswer = nil
            showExplanation = false
            showHint = false
        }
    }
    
    private func previousQuestion() {
        guard session.currentQuestionIndex > 0 else { return }
        session.currentQuestionIndex -= 1
        selectedAnswer = session.answers[session.currentQuestionIndex]
        showExplanation = selectedAnswer != nil
        showHint = false
    }
    
    private func saveQuizResults() {
        let userId = firebaseManager.userId ?? "guest"
        QuizStatsManager.saveQuizResult(session: session, userId: userId, modelContext: modelContext)
    }
    
    private func awardXP() {
        gamificationManager?.awardXP(session.xpEarned, for: "Quiz \(session.type.rawValue)")
    }
}

struct AnswerButton: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.2)
        } else if isWrong {
            return Color.red.opacity(0.2)
        } else if isSelected {
            return Color.blue.opacity(0.2)
        } else {
            return Color(.systemBackground)
        }
    }
    
    var borderColor: Color {
        if isCorrect {
            return Color.green
        } else if isWrong {
            return Color.red
        } else if isSelected {
            return Color.blue
        } else {
            return Color(.systemGray4)
        }
    }
    
    var icon: String? {
        if isCorrect {
            return "checkmark.circle.fill"
        } else if isWrong {
            return "xmark.circle.fill"
        }
        return nil
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(["A", "B", "C", "D"][index])")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(borderColor))
                
                Text(text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isCorrect || isWrong)
    }
}

struct QuizResultsView: View {
    let session: QuizSession
    let onDismiss: () -> Void
    
    private var scorePercentage: Int {
        Int(session.score)
    }
    
    private var scoreEmoji: String {
        switch scorePercentage {
        case 90...100: return "🏆"
        case 75..<90: return "🌟"
        case 60..<75: return "👏"
        case 40..<60: return "💪"
        default: return "📚"
        }
    }
    
    private var scoreMessage: String {
        switch scorePercentage {
        case 90...100: return "Exceptionnel !"
        case 75..<90: return "Très bien !"
        case 60..<75: return "Bien joué !"
        case 40..<60: return "Pas mal !"
        default: return "Continue tes efforts !"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                scoreHeader
                
                statsCards
                
                questionBreakdown
                
                actionButtons
            }
            .padding()
        }
    }
    
    private var scoreHeader: some View {
        VStack(spacing: 16) {
            Text(scoreEmoji)
                .font(.system(size: 80))
            
            Text(scoreMessage)
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(scorePercentage)%")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(session.type.color)
            
            Text("\(session.correctAnswersCount) / \(session.questions.count) réponses correctes")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var statsCards: some View {
        HStack(spacing: 12) {
            StatBox(
                icon: "star.fill",
                value: "+\(session.xpEarned)",
                label: "XP gagnés",
                color: .yellow
            )
            
            StatBox(
                icon: "clock.fill",
                value: timeSpent,
                label: "Temps",
                color: .blue
            )
            
            StatBox(
                icon: "chart.bar.fill",
                value: "\(session.difficulty.rawValue)",
                label: "Niveau",
                color: .purple
            )
        }
    }
    
    private var questionBreakdown: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📋 Récapitulatif")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(Array(session.questions.enumerated()), id: \.offset) { index, question in
                QuestionResultRow(
                    questionNumber: index + 1,
                    question: question,
                    userAnswer: session.answers[index],
                    isCorrect: session.answers[index] == question.correctAnswerIndex
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if session.score < 70 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                        Text("Conseils pour progresser")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RecommendationRow(
                            icon: "book.fill",
                            text: "Révise le contenu de \(session.type.rawValue) avant de recommencer"
                        )
                        
                        RecommendationRow(
                            icon: "clock.fill",
                            text: "Prends plus de temps pour réfléchir à chaque réponse"
                        )
                        
                        if session.difficulty != .beginner {
                            RecommendationRow(
                                icon: "chart.bar.fill",
                                text: "Essaie un niveau plus facile pour consolider tes bases"
                            )
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
            }
            
            Button(action: onDismiss) {
                Text("Terminer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(session.type.color)
                    .cornerRadius(12)
            }
        }
    }
    
    private var timeSpent: String {
        guard let endDate = session.endDate else { return "0:00" }
        let interval = endDate.timeIntervalSince(session.startDate)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct QuestionResultRow: View {
    let questionNumber: Int
    let question: QuizQuestion
    let userAnswer: Int?
    let isCorrect: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)
                .foregroundColor(isCorrect ? .green : .red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Question \(questionNumber)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(question.question)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct RecommendationRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.orange)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
