import SwiftUI

struct PracticeHubView: View {
    let language: String
    @State private var showQuizSelection = false
    @State private var showFlashcards = false
    @State private var showFillInBlank = false
    @State private var showMatching = false
    @State private var selectedFlashcardDeck: FlashcardDeck?
    @State private var fillInBlankExercises: [FillInTheBlankExercise] = []
    @State private var matchingExercise: MatchingExercise?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    dailyGoalSection
                    
                    quickPracticeSection
                    
                    exerciseTypesSection
                    
                    statsSection
                }
                .padding()
            }
            .navigationTitle("🎯 Pratique")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showQuizSelection) {
                QuizSelectionView(language: language)
            }
            .sheet(isPresented: $showFlashcards) {
                if let deck = selectedFlashcardDeck {
                    FlashcardView(deck: deck)
                }
            }
            .sheet(isPresented: $showFillInBlank) {
                if !fillInBlankExercises.isEmpty {
                    FillInTheBlankView(exercises: fillInBlankExercises)
                }
            }
            .sheet(isPresented: $showMatching) {
                if let exercise = matchingExercise {
                    MatchingExerciseView(exercise: exercise)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("💪")
                .font(.system(size: 60))
            
            Text("Pratique quotidienne")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choisis un exercice pour améliorer ton italien")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var dailyGoalSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Objectif du jour")
                        .font(.headline)
                    
                    Text("5 exercices à compléter")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("0/5")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: 0, total: 5)
                .tint(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var quickPracticeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("⚡ Pratique Rapide")
                    .font(.headline)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickPracticeCard(
                        title: "5 min",
                        subtitle: "Vocabulaire",
                        icon: "📚",
                        color: .blue,
                        action: startQuickVocabulary
                    )
                    
                    QuickPracticeCard(
                        title: "5 min",
                        subtitle: "Conjugaison",
                        icon: "✏️",
                        color: .green,
                        action: startQuickConjugation
                    )
                    
                    QuickPracticeCard(
                        title: "10 min",
                        subtitle: "Quiz Mixte",
                        icon: "🎯",
                        color: .purple,
                        action: { showQuizSelection = true }
                    )
                }
            }
        }
    }
    
    private var exerciseTypesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📝 Types d'Exercices")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ExerciseTypeRow(
                    type: .flashcard,
                    count: "50+ cartes",
                    action: startFlashcards
                )
                
                ExerciseTypeRow(
                    type: .fillInTheBlank,
                    count: "30+ exercices",
                    action: startFillInBlank
                )
                
                ExerciseTypeRow(
                    type: .matching,
                    count: "20+ associations",
                    action: startMatching
                )
                
            }
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊 Cette Semaine")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                StatBox(
                    icon: "checkmark.circle.fill",
                    value: "0",
                    label: "Exercices",
                    color: .green
                )
                
                StatBox(
                    icon: "flame.fill",
                    value: "0",
                    label: "Jours",
                    color: .orange
                )
                
                StatBox(
                    icon: "star.fill",
                    value: "0",
                    label: "XP",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func startQuickVocabulary() {
        selectedFlashcardDeck = ExerciseDataManager.shared.generateVocabularyFlashcards(language: language, limit: 10)
        showFlashcards = true
    }
    
    private func startQuickConjugation() {
        selectedFlashcardDeck = ExerciseDataManager.shared.generateConjugationFlashcards(language: language, limit: 10)
        showFlashcards = true
    }
    
    private func startFlashcards() {
        selectedFlashcardDeck = ExerciseDataManager.shared.generateVocabularyFlashcards(language: language, limit: 20)
        showFlashcards = true
    }
    
    private func startFillInBlank() {
        fillInBlankExercises = ExerciseDataManager.shared.generateFillInTheBlankExercises(language: language, count: 10)
        showFillInBlank = true
    }
    
    private func startMatching() {
        matchingExercise = ExerciseDataManager.shared.generateMatchingExercise(language: language, count: 8)
        showMatching = true
    }
}

struct QuickPracticeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 40))
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ExerciseTypeRow: View {
    let type: ExerciseType
    let count: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(type.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.title3)
                        .foregroundColor(type.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.headline)
                    
                    Text(count)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
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
