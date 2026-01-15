    import Foundation
import SwiftUI

@MainActor
class LearnedWordsManager: ObservableObject {
    static let shared = LearnedWordsManager()
    
    @Published var learnedWordIds: Set<String> = []
    @Published var learnedWordsData: [String: [String: Any]] = [:]
    @Published var isLoading = false
    
    private init() {
        Task {
            await fetchLearnedWords()
        }
    }
    
    // MARK: - Fetch Learned Words
    
    func fetchLearnedWords() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try await FirebaseSyncService.shared.fetchVocabularyStatus()
            
            learnedWordsData = data
            learnedWordIds = Set(data.keys.filter { wordId in
                if let wordData = data[wordId],
                   let status = wordData["status"] as? String {
                    return status == "learned"
                }
                return false
            })
            
            print("✅ LearnedWordsManager: Fetched \(learnedWordIds.count) learned words")
        } catch {
            print("❌ LearnedWordsManager: Error fetching learned words - \(error)")
        }
    }
    
    // MARK: - Mark Word as Learned
    
    func markWordAsLearned(wordId: String, word: String, translation: String) async {
        // Optimistic update
        learnedWordIds.insert(wordId)
        
        do {
            try await FirebaseSyncService.shared.syncVocabularyWord(
                wordId: wordId,
                status: "learned",
                reviewCount: 1,
                lastReviewDate: Date()
            )
            print("✅ LearnedWordsManager: Marked '\(word)' as learned")
            
            // Refresh to get latest data
            await fetchLearnedWords()
        } catch {
            // Rollback on error
            learnedWordIds.remove(wordId)
            print("❌ LearnedWordsManager: Error marking word as learned - \(error)")
        }
    }
    
    // MARK: - Unmark Word as Learned
    
    func unmarkWordAsLearned(wordId: String, word: String) async {
        // Optimistic update
        learnedWordIds.remove(wordId)
        
        do {
            try await FirebaseSyncService.shared.syncVocabularyWord(
                wordId: wordId,
                status: "learning",
                reviewCount: 0,
                lastReviewDate: Date()
            )
            print("✅ LearnedWordsManager: Unmarked '\(word)' as learned")
            
            // Refresh to get latest data
            await fetchLearnedWords()
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
        return "\(word)_\(translation)"
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "$", with: "_")
            .replacingOccurrences(of: "#", with: "_")
            .replacingOccurrences(of: "[", with: "_")
            .replacingOccurrences(of: "]", with: "_")
            .replacingOccurrences(of: "/", with: "_")
    }
}
