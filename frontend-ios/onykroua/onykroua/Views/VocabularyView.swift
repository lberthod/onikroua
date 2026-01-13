import SwiftUI
import AVFoundation

struct VocabularyView: View {
    @StateObject private var speechService = SpeechService()
    @StateObject private var progressTracker = ProgressTracker.shared
    @State private var selectedTab = 0
    @State private var selectedCategory = "Tous"
    @State private var searchText = ""
    
    let vocabularyCategories: [VocabularyCategory] = VocabularyLoader.loadVocabulary()
    
    var allWords: [VocabularyWord] {
        vocabularyCategories.flatMap { $0.words }
    }
    
    var filteredWords: [VocabularyWord] {
        let words = selectedCategory == "Tous" ? allWords : vocabularyCategories.first { $0.name == selectedCategory }?.words ?? []
        if searchText.isEmpty {
            return words
        }
        return words.filter { $0.word.localizedCaseInsensitiveContains(searchText) || $0.translation.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("📖 Dictionnaire").tag(0)
                Text("🗂️ Catégories").tag(1)
                Text("🎯 Pratique").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                dictionaryTab
            } else if selectedTab == 1 {
                categoriesTab
            } else {
                practiceTab
            }
        }
        .navigationTitle("📚 Vocabulaire (\(allWords.count))")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    var dictionaryTab: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Rechercher...", text: $searchText)
            }
            .padding()
            .background(Color(.systemBackground))
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredWords) { item in
                        DictionaryRow(item: item, speechService: speechService)
                    }
                }
                .padding()
            }
        }
    }
    
    var categoriesTab: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryButton(name: "Tous", icon: "🌍", isSelected: selectedCategory == "Tous") {
                        withAnimation { selectedCategory = "Tous" }
                    }
                    
                    ForEach(vocabularyCategories) { category in
                        CategoryButton(name: category.name, icon: category.icon, isSelected: selectedCategory == category.name) {
                            withAnimation { selectedCategory = category.name }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredWords) { item in
                        VocabularyCard(item: item, speechService: speechService)
                    }
                }
                .padding()
            }
        }
    }
    
    var practiceTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("🎯 Mode Pratique")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Flashcards pour mémoriser")
                    .foregroundColor(.secondary)
                
                LazyVStack(spacing: 16) {
                    ForEach(allWords.shuffled().prefix(10)) { item in
                        FlashCard(item: item, speechService: speechService)
                    }
                }
            }
            .padding()
        }
    }
    
    func getCategoryIcon(_ name: String) -> String {
        ""
    }
}

struct DictionaryRow: View {
    let item: VocabularyWord
    @ObservedObject var speechService: SpeechService
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.word)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(item.translation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { speechService.speak(item.word) }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct FlashCard: View {
    let item: VocabularyWord
    @ObservedObject var speechService: SpeechService
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            // Face avant
            VStack(spacing: 16) {
                Text(item.word)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                
                Button(action: { speechService.speak(item.word) }) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Text("Tap pour voir la traduction")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            
            // Face arrière (avec rotation inverse pour corriger le miroir)
            VStack(spacing: 12) {
                Text(item.translation)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text(item.example)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : -180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
}

struct VocabularyCard: View {
    let item: VocabularyWord
    @ObservedObject var speechService: SpeechService
    @State private var isFlipped = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.word)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(item.translation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { speechService.speak(item.word) }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            if !item.example.isEmpty {
                Text(item.example)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        VocabularyView()
    }
}
