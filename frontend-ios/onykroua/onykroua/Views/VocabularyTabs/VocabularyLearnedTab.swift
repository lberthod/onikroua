import SwiftUI

struct VocabularyLearnedTab: View {
    let language: String
    @EnvironmentObject var env: AppEnvironment
    @State private var learnedWords: [VocabWord] = []
    @State private var showPractice = false
    @State private var isRefreshing = false
    
    var body: some View {
        VStack(spacing: 0) {
            if env.learnedWordsManager.isLoading {
                ProgressView("Chargement...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if learnedWords.isEmpty {
                emptyState
            } else {
                VStack(spacing: UI.Spacing.md) {
                    // Bouton de pratique ciblée
                    Button(action: { showPractice = true }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Pratiquer mon Apprentissage (\(learnedWords.count))")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(UI.Spacing.md)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(UI.Radius.r12)
                        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, UI.Spacing.md)
                    .padding(.top, UI.Spacing.md)
                    
                    ScrollView {
                        LazyVStack(spacing: UI.Spacing.md) {
                            ForEach(learnedWords, id: \.word) { word in
                                LearnedWordRow(word: word)
                            }
                        }
                        .padding(UI.Spacing.md)
                    }
                    .refreshable {
                        await refreshLearnedWords()
                    }
                }
            }
        }
        .onAppear {
            loadLearnedWords()
        }
        .onChange(of: env.learnedWordsManager.learnedWordIds) { _, _ in
            loadLearnedWords()
        }
        .fullScreenCover(isPresented: $showPractice) {
            LearnedWordsPracticeView(language: language, words: learnedWords)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: UI.Spacing.xl) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Aucun mot appris")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Continuez à explorer le dictionnaire et marquez les mots que vous connaissez !")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, UI.Spacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadLearnedWords() {
        let allWords = env.vocabularyManager.getAllWords(language: language)
        learnedWords = env.learnedWordsManager.getLearnedWords(from: allWords)
        print("📚 VocabularyLearnedTab: Loaded \(learnedWords.count) learned words for \(language)")
    }
    
    private func refreshLearnedWords() async {
        isRefreshing = true
        await env.learnedWordsManager.fetchLearnedWords()
        loadLearnedWords()
        isRefreshing = false
    }
}

struct LearnedWordRow: View {
    let word: VocabWord
    @EnvironmentObject var env: AppEnvironment
    @State private var showDetail = false
    @State private var isLearned = true // Par définition dans cet onglet
    
    var body: some View {
        Button(action: { showDetail = true }) {
            HStack {
                VStack(alignment: .leading, spacing: UI.Spacing.xs) {
                    Text(word.word)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(word.translation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    let lang = word.category == "it" ? "it-IT" : "es-ES"
                    // Appliquer le formatage pour le TTS si c'est de l'italien
                    let speechText = formatForSpeech(word.word)
                    env.speechService.speak(speechText, language: lang)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(UI.Spacing.md)
            .background(UI.Surface.background)
            .cornerRadius(UI.Radius.r12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            WordDetailView(word: word, isLearned: $isLearned, gamificationManager: nil)
        }
    }
    
    private func formatForSpeech(_ text: String) -> String {
        let pattern = "^(.+?)\\s*\\((il|la|lo|l'|i|le|gli)\\)$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
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
}

struct LearnedWordsPracticeView: View {
    let language: String
    let words: [VocabWord]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VocabularyPracticeTab(language: language) // On réutilise le composant existant
                .navigationTitle("Révision Apprentissage")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Quitter") { dismiss() }
                    }
                }
        }
    }
}
