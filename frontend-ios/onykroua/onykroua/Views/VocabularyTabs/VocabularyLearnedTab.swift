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
                VStack(spacing: 16) {
                    // Bouton de pratique ciblée
                    Button(action: { showPractice = true }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Pratiquer mon Apprentissage (\(learnedWords.count))")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(learnedWords, id: \.word) { word in
                                LearnedWordRow(word: word)
                            }
                        }
                        .padding()
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
        VStack(spacing: 20) {
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
                .padding(.horizontal, 40)
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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(.headline)
                Text(word.translation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                let lang = word.category == "it" ? "it-IT" : "es-ES"
                env.speechService.speak(word.word, language: lang)
            }) {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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
