import Foundation
import SwiftUI
import SwiftData

@MainActor
class LearnedWordsManager: ObservableObject {
    static let shared = LearnedWordsManager()
    
    private var vocabRepo: VocabRepository?
    
    @Published var learnedWordIds: Set<String> = []
    @Published var isLoading = false
    
    private init() {}
    
    /// Configure the manager with a ModelContainer
    func configure(with container: ModelContainer) {
        self.vocabRepo = VocabRepository(container: container)
        Task {
            await fetchLearnedWords()
        }
    }
    
    // MARK: - Fetch Learned Words
    
    func fetchLearnedWords() async {
        guard let repo = vocabRepo else { return }
        isLoading = true
        defer { isLoading = false }
        
        let words = repo.getWordsByStatus("known")
        learnedWordIds = Set(words.map { $0.wordId })
        print("✅ LearnedWordsManager: Loaded \(learnedWordIds.count) learned words from cache")
    }
    
    // MARK: - Mark Word as Learned
    
    func markWordAsLearned(wordId: String, word: String, translation: String) async {
        guard let repo = vocabRepo else { return }
        
        // Optimistic update
        learnedWordIds.insert(wordId)
        
        do {
            try await repo.markWordAsKnown(wordId: wordId)
            print("✅ LearnedWordsManager: Marked '\(word)' as learned")
        } catch {
            // Rollback on error
            learnedWordIds.remove(wordId)
            print("❌ LearnedWordsManager: Error marking word as learned - \(error)")
        }
    }
    
    // MARK: - Unmark Word as Learned
    
    func unmarkWordAsLearned(wordId: String, word: String) async {
        guard let repo = vocabRepo else { return }
        
        // Optimistic update
        learnedWordIds.remove(wordId)
        
        do {
            try await repo.markWordAsLearning(wordId: wordId)
            print("✅ LearnedWordsManager: Unmarked '\(word)' as learned")
        } catch {
            // Rollback on error
            learnedWordIds.insert(wordId)
            print("❌ LearnedWordsManager: Error unmarking word - \(error)")
        }
    }
    
    // MARK: - Check if Word is Learned
    
    func isWordLearned(wordId: String) -> Bool {
        return learnedWordIds.contains(wordId)
    }
    
    // MARK: - Get Learned Words for Language
    
    func getLearnedWords(from allWords: [VocabWord]) -> [VocabWord] {
        return allWords.filter { word in
            let wordId = createWordId(word: word.word, translation: word.translation)
            return learnedWordIds.contains(wordId)
        }
    }
    
    // MARK: - Helper
    
    private func createWordId(word: String, translation: String) -> String {
        return safeFirebaseKey("\(word)_\(translation)")
    }
}
