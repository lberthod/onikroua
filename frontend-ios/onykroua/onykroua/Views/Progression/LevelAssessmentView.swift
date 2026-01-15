import SwiftUI

struct LevelAssessmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLevel: String
    
    @State private var assessmentService = LevelAssessmentService()
    @State private var showResults = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !showResults {
                    questionView
                } else {
                    resultsView
                }
            }
            .navigationTitle("Test de Niveau")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var questionView: some View {
        VStack(spacing: 20) {
            ProgressView(
                value: Double(assessmentService.currentQuestionIndex + 1),
                total: Double(assessmentService.questions.count)
            )
            .tint(.blue)
            .padding(.horizontal)
            
            Text("Question \(assessmentService.currentQuestionIndex + 1) / \(assessmentService.questions.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if assessmentService.currentQuestionIndex < assessmentService.questions.count {
                let question = assessmentService.questions[assessmentService.currentQuestionIndex]
                
                VStack(spacing: 30) {
                    HStack {
                        Text(question.level.icon)
                            .font(.title)
                        Text("Niveau \(question.level.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(question.question)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                submitAnswer(index, for: question)
                            }) {
                                HStack {
                                    Text(option)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(assessmentService.assessedLevel.icon)
                .font(.system(size: 100))
            
            VStack(spacing: 12) {
                Text("Résultat du Test")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(assessmentService.assessedLevel.displayName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.blue)
                
                Text(assessmentService.assessedLevel.detailedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Score: \(assessmentService.getCorrectCount()) / \(assessmentService.questions.count)")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(.blue)
                    Text("Mots à apprendre: ~\(assessmentService.assessedLevel.estimatedWordsToKnow)")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                selectedLevel = assessmentService.assessedLevel.rawValue
                dismiss()
            }) {
                Text("Commencer avec ce niveau")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button(action: {
                assessmentService.reset()
                showResults = false
            }) {
                Text("Refaire le test")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private func submitAnswer(_ answer: Int, for question: AssessmentQuestion) {
        assessmentService.submitAnswer(answer)
        
        if assessmentService.currentQuestionIndex >= assessmentService.questions.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                _ = assessmentService.evaluateLevel()
                withAnimation {
                    showResults = true
                }
            }
        }
    }
}
