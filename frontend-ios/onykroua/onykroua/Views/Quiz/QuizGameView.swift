import SwiftUI
import SwiftData

struct QuizGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var session: QuizSession
    @State private var selectedAnswer: Int?
    @State private var showExplanation = false
    @State private var showResults = false
    @State private var gamificationManager: GamificationManager?
    
    let language: String
    
    init(session: QuizSession, language: String) {
        _session = State(initialValue: session)
        self.language = language
    }
    
    var body: some View {
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
        VStack(spacing: 8) {
            HStack {
                Text("Question \(session.currentQuestionIndex + 1)/\(session.questions.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(session.difficulty.icon)
                    .font(.title3)
            }
            
            ProgressView(value: Double(session.currentQuestionIndex), total: Double(session.questions.count))
                .tint(session.type.color)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var questionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(session.type.icon)
                    .font(.title)
                
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
            }
            
            Text(currentQuestion?.question ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showExplanation = true
        }
    }
    
    private func nextQuestion() {
        if session.isCompleted {
            awardXP()
            showResults = true
        } else {
            selectedAnswer = nil
            showExplanation = false
        }
    }
    
    private func previousQuestion() {
        guard session.currentQuestionIndex > 0 else { return }
        session.currentQuestionIndex -= 1
        selectedAnswer = session.answers[session.currentQuestionIndex]
        showExplanation = selectedAnswer != nil
    }
    
    private func awardXP() {
        gamificationManager?.addXP(session.xpEarned, source: "Quiz \(session.type.rawValue)")
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
            StatCard(
                icon: "star.fill",
                value: "+\(session.xpEarned)",
                label: "XP gagnés",
                color: .yellow
            )
            
            StatCard(
                icon: "clock.fill",
                value: timeSpent,
                label: "Temps",
                color: .blue
            )
            
            StatCard(
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
