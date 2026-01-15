import SwiftUI
import AVFoundation

// MARK: - VocabularyView (matching Android VocabularyActivity)

struct VocabularyView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0
    @State private var currentLanguage = "it"
    @State private var showAdvancedSearch = false
    
    private var totalWords: Int {
        env.vocabularyManager.getAllWords(language: currentLanguage).count
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
            // Tab Picker
            Picker("", selection: $selectedTab) {
                Text("📖 Dictionnaire").tag(0)
                Text("🗂️ Catégories").tag(1)
                Text("🎯 Pratique").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab Content
            TabView(selection: $selectedTab) {
                DictionaryTab(language: currentLanguage)
                    .tag(0)
                
                CategoriesTab(language: currentLanguage)
                    .tag(1)
                
                VocabularyPracticeTab(language: currentLanguage)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("📚 Vocabulaire (\(totalWords))")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { currentLanguage = "it" }) {
                        Label("Italien", systemImage: currentLanguage == "it" ? "checkmark" : "")
                    }
                    Button(action: { currentLanguage = "es" }) {
                        Label("Espagnol", systemImage: currentLanguage == "es" ? "checkmark" : "")
                    }
                } label: {
                    Text(currentLanguage == "it" ? "🇮🇹" : "🇪🇸")
                        .font(.title2)
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAdvancedSearch = true }) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAdvancedSearch) {
            AdvancedSearchView()
        }
            
            LoadingOverlay(isLoading: env.vocabularyManager.isLoading, message: "Chargement du vocabulaire...")
            
            ErrorOverlay(errorManager: env.errorManager)
        }
        .onAppear {
            env.vocabularyManager.ensureLoaded(language: currentLanguage)
        }
        .onChange(of: currentLanguage) { _, newLanguage in
            env.vocabularyManager.ensureLoaded(language: newLanguage)
        }
        .onChange(of: env.vocabularyManager.loadingError != nil) { _, hasError in
            if hasError, let error = env.vocabularyManager.loadingError {
                env.errorManager.handle(error) {
                    env.vocabularyManager.loadVocabularyAsync(language: currentLanguage)
                }
            }
        }
    }
}

// MARK: - Legacy Components (kept for backward compatibility)

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
            
            Button(action: { speechService.speak(item.word, language: "it-IT") }) {
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
            VStack(spacing: 16) {
                Text(item.word)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                
                Button(action: { speechService.speak(item.word, language: "it-IT") }) {
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
            
            VStack(spacing: 12) {
                Text(item.translation)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.blue)
                
                if let example = item.example, !example.isEmpty {
                    Text(example)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        if let icon = item.categoryIcon {
                            Text(icon)
                                .font(.body)
                        }
                        if let category = item.category {
                            Text(category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(item.word)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(item.translation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { speechService.speak(item.word, language: "it-IT") }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            if let example = item.example, !example.isEmpty {
                Text(example)
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

struct CategoryButton: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(icon)
                    .font(.title2)
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationView {
        VocabularyView()
    }
}
