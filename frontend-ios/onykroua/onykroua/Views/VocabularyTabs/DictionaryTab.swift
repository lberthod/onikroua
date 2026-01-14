import SwiftUI

// MARK: - DictionaryTab (matching Android DictionaryFragment.kt)

public struct DictionaryTab: View {
    let language: String
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""

    public init(language: String) {
        self.language = language
    }

    private var allWords: [Character: [VocabWord]] {
        env.vocabularyManager.getWordsSortedAlphabetically(language: language)
    }

    private var filteredWords: [VocabWord] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return []
        }

        return env.vocabularyManager.getAllWords(language: language).filter { word in
            word.word.lowercased().contains(searchText.lowercased()) ||
            word.translation.lowercased().contains(searchText.lowercased())
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Rechercher...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))

            Divider()

            // Content
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if searchText.isEmpty {
                        // Display alphabetically with letter headers
                        ForEach(allWords.keys.sorted(), id: \.self) { letter in
                            if let words = allWords[letter], !words.isEmpty {
                                Section {
                                    ForEach(words) { word in
                                        WordCard(word: word, speechService: env.speechService, language: language)
                                    }
                                } header: {
                                    LetterHeader(letter: letter)
                                }
                            }
                        }
                    } else {
                        // Display filtered results
                        if filteredWords.isEmpty {
                            VStack(spacing: 8) {
                                Text("Aucun résultat trouvé")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(32)
                            }
                        } else {
                            ForEach(filteredWords) { word in
                                WordCard(word: word, speechService: env.speechService, language: language)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Letter Header

struct LetterHeader: View {
    let letter: Character

    var body: some View {
        HStack {
            Text(String(letter))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.blue.opacity(0.1))
    }
}

// MARK: - Word Card

struct WordCard: View {
    let word: VocabWord
    @ObservedObject var speechService: SpeechService
    let language: String

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                // Word + Icon + Speaker
                HStack(alignment: .top) {
                    HStack(spacing: 4) {
                        if let icon = word.categoryIcon, !icon.isEmpty {
                            Text(icon)
                                .font(.body)
                        }

                        Text(word.word)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Button(action: {
                        let lang = language == "it" ? "it-IT" : "es-ES"
                        speechService.speak(word.word, language: lang)
                    }) {
                        Text("🔊")
                            .font(.body)
                    }
                }

                // Translation
                Text(word.translation)
                    .font(.body)
                    .foregroundColor(.secondary)

                // Example
                if let example = word.example, !example.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("💡 \(example)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .italic()

                            Spacer()

                            Button(action: {
                                let lang = language == "it" ? "it-IT" : "es-ES"
                                speechService.speak(example, language: lang)
                            }) {
                                Text("🔊")
                                    .font(.caption)
                            }
                        }

                        if let exampleTranslation = word.exampleTranslation, !exampleTranslation.isEmpty {
                            Text(exampleTranslation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
            .onTapGesture {
                let lang = language == "it" ? "it-IT" : "es-ES"
                speechService.speak(word.word, language: lang)
            }

            // Separator
            Divider()
                .background(Color.black.opacity(0.05))
        }
    }
}
