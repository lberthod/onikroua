import SwiftUI

struct FillInTheBlankView: View {
    let exercises: [FillInTheBlankExercise]
    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var showFeedback = false
    @State private var session = ExerciseSession(type: .fillInTheBlank)
    @State private var showResults = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if showResults {
                    ExerciseResultsView(session: session, totalExercises: exercises.count) {
                        dismiss()
                    }
                } else {
                    exerciseContent
                }
            }
            .navigationTitle("📝 Texte à trous")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(currentIndex + 1)/\(exercises.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var exerciseContent: some View {
        VStack(spacing: 0) {
            progressHeader
            
            ScrollView {
                VStack(spacing: 24) {
                    instructionCard
                    
                    sentenceCard
                    
                    optionsGrid
                    
                    if showFeedback {
                        feedbackCard
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
                Text("Progression")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(session.correctCount) ✓ / \(session.incorrectCount) ✗")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            ProgressView(value: Double(currentIndex), total: Double(exercises.count))
                .tint(.green)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var instructionCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text("Choisis le mot qui complète la phrase")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    private var sentenceCard: some View {
        VStack(spacing: 16) {
            Text(currentExercise?.sentenceWithBlank ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            if let translation = currentExercise?.translation {
                Divider()
                    .padding(.vertical, 8)
                
                HStack(spacing: 8) {
                    Image(systemName: "flag.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(translation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var optionsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(currentExercise?.options ?? [], id: \.self) { option in
                OptionButton(
                    text: option,
                    isSelected: selectedAnswer == option,
                    isCorrect: showFeedback && option == currentExercise?.missingWord,
                    isWrong: showFeedback && selectedAnswer == option && option != currentExercise?.missingWord,
                    action: { selectAnswer(option) }
                )
            }
        }
    }
    
    private var feedbackCard: some View {
        HStack(spacing: 12) {
            Image(systemName: selectedAnswer == currentExercise?.missingWord ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title)
                .foregroundColor(selectedAnswer == currentExercise?.missingWord ? .green : .red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedAnswer == currentExercise?.missingWord ? "Correct !" : "Incorrect")
                    .font(.headline)
                    .foregroundColor(selectedAnswer == currentExercise?.missingWord ? .green : .red)
                
                if selectedAnswer != currentExercise?.missingWord {
                    Text("La bonne réponse est : \(currentExercise?.missingWord ?? "")")
                        .font(.subheadline)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill((selectedAnswer == currentExercise?.missingWord ? Color.green : Color.red).opacity(0.1))
        )
    }
    
    private var navigationButtons: some View {
        Button(action: nextExercise) {
            HStack {
                Text(currentIndex < exercises.count - 1 ? "Suivant" : "Terminer")
                    .fontWeight(.semibold)
                Image(systemName: "chevron.right")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(selectedAnswer == nil)
        .opacity(selectedAnswer == nil ? 0.5 : 1)
    }
    
    private var currentExercise: FillInTheBlankExercise? {
        guard currentIndex < exercises.count else { return nil }
        return exercises[currentIndex]
    }
    
    private func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil else { return }
        
        selectedAnswer = answer
        let isCorrect = answer == currentExercise?.missingWord
        session.recordAnswer(isCorrect: isCorrect)
        
        withAnimation {
            showFeedback = true
        }
    }
    
    private func nextExercise() {
        currentIndex += 1
        selectedAnswer = nil
        showFeedback = false
        
        if currentIndex >= exercises.count {
            session.complete()
            withAnimation {
                showResults = true
            }
        }
    }
}

struct OptionButton: View {
    let text: String
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
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                
                Text(text)
                    .font(.body)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
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

struct ExerciseResultsView: View {
    let session: ExerciseSession
    let totalExercises: Int
    let onDismiss: () -> Void
    
    var successRate: Int {
        Int(session.successRate)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text(successRate >= 80 ? "🏆" : successRate >= 60 ? "⭐" : "💪")
                        .font(.system(size: 80))
                    
                    Text(successRate >= 80 ? "Excellent travail !" : successRate >= 60 ? "Bien joué !" : "Continue tes efforts !")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(session.correctCount) / \(totalExercises) réponses correctes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                
                HStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                        
                        Text("\(session.correctCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Correctes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                    
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                        
                        Text("+\(session.xpEarned)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("XP")
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
                
                Button(action: onDismiss) {
                    Text("Terminer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
