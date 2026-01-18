import SwiftUI

// MARK: - Enums

enum VocabPracticeMode {
    case choice, write, listen
}

enum VocabPracticeDirection {
    case toFrench, fromFrench
}

// Aliases for backward compatibility
typealias PracticeMode = VocabPracticeMode
typealias PracticeDirection = VocabPracticeDirection

// MARK: - VocabularyPracticeTab (matching Android VocabularyPracticeFragment.kt)

public struct VocabularyPracticeTab: View {
    
    // MARK: - Inputs
    let language: String
    @EnvironmentObject var env: AppEnvironment
    
    public init(language: String) {
        self.language = language
    }
    
    // MARK: - State
    @State private var practiceMode: PracticeMode = .choice
    @State private var practiceDirection: PracticeDirection = .toFrench
    @State private var score = 0
    @State private var total = 0
    @State private var streak = 0
    @State private var currentWord: VocabWord?
    @State private var choices: [String] = []
    @State private var userAnswer = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showStatsOverlay = false
    
    // MARK: - View
    public var body: some View {
        VStack(spacing: 0) {
            // Stats Header (integrated and discreet)
            HStack(spacing: 20) {
                StatItem(icon: "✅", value: "\(score)/\(total)", label: "Score")
                StatItem(icon: "🔥", value: "\(streak)", label: "Série")
                StatItem(icon: "📊", value: total > 0 ? "\(Int(Double(score) / Double(total) * 100))%" : "0%", label: "Réussite")
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color(.systemBackground))
            .overlay(Divider(), alignment: .bottom)

            VStack(spacing: 0) {
                // Contrôles compacts en une seule ligne
                HStack(spacing: 8) {
                    // Mode
                    HStack(spacing: 4) {
                        VocabModeButtonCompact(icon: "🎯", isSelected: practiceMode == .choice) {
                            practiceMode = .choice
                            generateQuestion()
                        }
                        VocabModeButtonCompact(icon: "✍️", isSelected: practiceMode == .write) {
                            practiceMode = .write
                            generateQuestion()
                        }
                        VocabModeButtonCompact(icon: "👂", isSelected: practiceMode == .listen) {
                            practiceMode = .listen
                            generateQuestion()
                        }
                    }
                    
                    Spacer()
                    
                    // Direction
                    HStack(spacing: 4) {
                        VocabDirectionButtonCompact(title: "🇮🇹→🇫🇷", isSelected: practiceDirection == .toFrench) {
                            practiceDirection = .toFrench
                            generateQuestion()
                        }
                        VocabDirectionButtonCompact(title: "🇫🇷→🇮🇹", isSelected: practiceDirection == .fromFrench) {
                            practiceDirection = .fromFrench
                            generateQuestion()
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                Divider()
                
                // Question area
                ScrollView {
                    VStack(spacing: 12) {
                        if let word = currentWord {
                            
                            // Question
                            VStack(spacing: 16) {
                                if practiceMode == .choice || practiceMode == .listen {
                                    // Mode quiz ou écoute: affichage optimisé
                                    VStack(spacing: 8) {
                                        if practiceMode == .listen {
                                            Text("Écoutez et choisissez la traduction :")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            
                                            // MOT AFFICHÉ
                                            Text(formatWordWithDeterminant(word.word))
                                                .font(.system(size: 36, weight: .bold))
                                                .foregroundColor(.purple)
                                                .multilineTextAlignment(.center)
                                                .padding(.vertical, 4)
                                            
                                            if let gender = word.gender, !gender.isEmpty {
                                                Text("(\(gender))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            // Bouton d'écoute
                                            Button(action: {
                                                let lang = language == "it" ? "it-IT" : "es-ES"
                                                let wordToSpeak = formatWordWithDeterminant(word.word)
                                                env.speechService.speak(wordToSpeak, language: lang)
                                            }) {
                                                HStack(spacing: 8) {
                                                    Image(systemName: env.speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(env.speechService.isSpeaking ? .yellow : .purple)
                                                    
                                                    Text("🎧 Écouter")
                                                        .font(.subheadline)
                                                        .fontWeight(.semibold)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(Color.purple.opacity(0.1))
                                                .cornerRadius(10)
                                            }
                                            .onAppear {
                                                // Auto-play au chargement
                                                let lang = language == "it" ? "it-IT" : "es-ES"
                                                let wordToSpeak = formatWordWithDeterminant(word.word)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    env.speechService.speak(wordToSpeak, language: lang)
                                                }
                                            }
                                        } else {
                                            Text("Quelle est la traduction de :")
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            
                                            Text(getQuestionText(word: word))
                                                .font(.system(size: 36, weight: .bold))
                                                .foregroundColor(.blue)
                                                .multilineTextAlignment(.center)
                                                .padding(.vertical, 4)
                                            
                                            if let gender = word.gender, !gender.isEmpty {
                                                Text("(\(gender))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                } else {
                                    Text(getQuestionText(word: word))
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            // Answer area
                            if practiceMode == .choice || practiceMode == .listen {
                                VStack(spacing: 8) {
                                    VStack(spacing: 8) {
                                        ForEach(Array(choices.enumerated()), id: \.element) { index, choice in
                                            VocabChoiceButton(
                                                number: index + 1,
                                                text: choice,
                                                isCorrect: showResult && choice == getCorrectAnswer(word: word),
                                                isWrong: showResult && choice == userAnswer && !isCorrect,
                                                isDisabled: showResult
                                            ) {
                                                if !showResult {
                                                    checkAnswer(choice, word: word)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            } else if practiceMode == .write {
                                
                                VStack(spacing: 16) {
                                    TextField("Votre réponse...", text: $userAnswer)
                                        .textFieldStyle(.roundedBorder)
                                        .font(.title3)
                                        .padding(.horizontal)
                                        .disabled(showResult)
                                    
                                    if !showResult {
                                        Button(action: { checkAnswer(userAnswer, word: word) }) {
                                            Text("Vérifier")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.blue)
                                                .cornerRadius(12)
                                        }
                                        .disabled(userAnswer.isEmpty)
                                    }
                                }
                            }
                            
                            // Result feedback - COMPACT
                            if showResult {
                                VStack(spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(isCorrect ? .green : .red)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(isCorrect ? "Correct ! 🎉" : "Incorrect")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(isCorrect ? .green : .red)
                                            
                                            if !isCorrect {
                                                Text("\(getCorrectAnswer(word: word))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                    
                                    Button(action: { generateQuestion() }) {
                                        Text("→ Suivant")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(Color.green)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .onAppear {
            generateQuestion()
        }
    }
    
    // Supporting Stat Item
    struct StatItem: View {
        let icon: String
        let value: String
        let label: String
        
        var body: some View {
            HStack(spacing: 6) {
                Text(icon)
                VStack(alignment: .leading, spacing: 0) {
                    Text(value)
                        .font(.subheadline.bold())
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
        
        // MARK: - Logic
        
        func formatWordWithDeterminant(_ text: String) -> String {
            // Transformer "limone (il)" → "il limone"
            // Pattern: "mot (déterminant)"
            let pattern = "^(.+?)\\s*\\((il|la|lo|l'|i|le|gli)\\)$"
            
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                
                if let motRange = Range(match.range(at: 1), in: text),
                   let detRange = Range(match.range(at: 2), in: text) {
                    let mot = String(text[motRange]).trimmingCharacters(in: .whitespaces)
                    let determinant = String(text[detRange])
                    return "\(determinant) \(mot)"
                }
            }
            
            return text
        }
        
        func getQuestionText(word: VocabWord) -> String {
            if practiceMode == .listen {
                return "Écoutez et écrivez le mot"
            }
            let text = practiceDirection == .toFrench ? word.word : word.translation
            return formatWordWithDeterminant(text)
        }
        
        func getCorrectAnswer(word: VocabWord) -> String {
            // Mode listen: TOUJOURS italien → français
            if practiceMode == .listen {
                return word.translation
            }
            let text = practiceDirection == .toFrench ? word.translation : word.word
            return formatWordWithDeterminant(text)
        }
        
        func generateQuestion() {
            let allWords = env.vocabularyManager.getAllWords(language: language)
            guard !allWords.isEmpty else { return }
            
            currentWord = allWords.randomElement()
            userAnswer = ""
            showResult = false
            
            // Générer les 4 choix (3 faux + 1 correct) pour mode choice ET listen
            if practiceMode == .choice || practiceMode == .listen {
                guard let word = currentWord else { return }
                
                // Mode listen: TOUJOURS traductions françaises
                let correct: String
                let wrongChoices: [String]
                
                if practiceMode == .listen {
                    // Mot IT → choix FR
                    correct = word.translation
                    wrongChoices = allWords
                        .filter { $0.translation != correct }
                        .map { $0.translation }
                        .shuffled()
                        .prefix(3)
                        .map { String($0) }
                } else {
                    // Mode choice: selon direction
                    correct = getCorrectAnswer(word: word)
                    wrongChoices = allWords
                        .filter { getCorrectAnswer(word: $0) != correct }
                        .map { getCorrectAnswer(word: $0) }
                        .shuffled()
                        .prefix(3)
                        .map { String($0) }
                }
                
                choices = (wrongChoices + [correct]).shuffled()
            }
        }
        
        func checkAnswer(_ answer: String, word: VocabWord) {
            let correct = getCorrectAnswer(word: word)
            
            isCorrect =
            answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
            correct.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            total += 1
            if isCorrect {
                score += 1
                streak += 1
            } else {
                streak = 0
            }
            
            userAnswer = answer
            showResult = true
        }
    }
    
    // MARK: - Supporting Views
    
    struct VocabStatBadge: View {
        let icon: String
        let label: String
        let value: String
        
        var body: some View {
            VStack(spacing: 4) {
                Text(icon)
                    .font(.title2)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // COMPACT version for better space optimization
    struct VocabStatBadgeCompact: View {
        let icon: String
        let value: String
        
        var body: some View {
            HStack(spacing: 4) {
                Text(icon)
                    .font(.body)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    struct VocabModeButton: View {
        let icon: String
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Text(icon)
                        .font(.title2)
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
            }
        }
    }
    
    // COMPACT version
    struct VocabModeButtonCompact: View {
        let icon: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(icon)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isSelected ? .white : .primary)
                    .cornerRadius(8)
            }
        }
    }
    
    struct VocabDirectionButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isSelected ? .white : .primary)
                    .cornerRadius(10)
            }
        }
    }
    
    // COMPACT version
    struct VocabDirectionButtonCompact: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isSelected ? .white : .primary)
                    .cornerRadius(6)
            }
        }
    }
    
    struct VocabChoiceButton: View {
        let number: Int
        let text: String
        let isCorrect: Bool
        let isWrong: Bool
        let isDisabled: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 10) {
                    Text("\(number)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(isCorrect ? .white : (isWrong ? .white : .blue))
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(isCorrect ? Color.green : (isWrong ? Color.red : Color.blue.opacity(0.1)))
                        )
                    
                    Text(text)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isCorrect ? .white : (isWrong ? .white : .primary))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(isCorrect ? Color.green : (isWrong ? Color.red : Color(.systemBackground)))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isCorrect ? Color.green : (isWrong ? Color.red : Color(.systemGray4)), lineWidth: 2)
                )
                .cornerRadius(10)
            }
            .disabled(isDisabled)
        }
    }

