import SwiftUI

// MARK: - CategoriesTab (matching Android CategoriesFragment.kt)

public struct CategoriesTab: View {

    // MARK: - Inputs
    let language: String
    @EnvironmentObject var env: AppEnvironment

    // MARK: - State
    @State private var expandedMainCategories = Set<String>()
    @State private var selectedSubCategory: String? = nil

    public init(language: String) {
        self.language = language
    }

    // MARK: - Computed

    private var categoriesGrouped: [String: [VocabCategory]] {
        env.vocabularyManager.getCategoriesGroupedByMain(language: language)
    }

    private var categoriesWithoutMain: [VocabCategory] {
        env.vocabularyManager.getCategories(language: language).filter { $0.mainCategory == nil }
    }

    // MARK: - View
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {

                // Categories without main_category first
                if !categoriesWithoutMain.isEmpty {
                    ForEach(categoriesWithoutMain) { category in
                        LegacyCategoryCard(
                            category: category,
                            selectedSubCategory: $selectedSubCategory,
                            speechService: env.speechService,
                            language: language
                        )
                    }
                }

                // Categories grouped by main_category
                ForEach(categoriesGrouped.keys.sorted(), id: \.self) { mainCategory in
                    if let subCategories = categoriesGrouped[mainCategory] {
                        MainCategoryCard(
                            mainCategory: mainCategory,
                            subCategories: subCategories,
                            isExpanded: expandedMainCategories.contains(mainCategory),
                            selectedSubCategory: $selectedSubCategory,
                            speechService: env.speechService,
                            language: language,
                            onToggle: {
                                if expandedMainCategories.contains(mainCategory) {
                                    expandedMainCategories.remove(mainCategory)
                                } else {
                                    expandedMainCategories.insert(mainCategory)
                                }
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Main Category Card (Expandable)

struct MainCategoryCard: View {
    let mainCategory: String
    let subCategories: [VocabCategory]
    let isExpanded: Bool
    @Binding var selectedSubCategory: String?
    @ObservedObject var speechService: SpeechService
    let language: String
    let onToggle: () -> Void

    private var totalWords: Int {
        subCategories.reduce(0) { $0 + $1.words.count }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Header
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    Text(isExpanded ? "▼" : "▶")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(mainCategory)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(subCategories.count) catégories · \(totalWords) mots")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(20)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            // Sub-categories
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(subCategories) { subCategory in
                        SubCategoryCard(
                            category: subCategory,
                            isSelected: selectedSubCategory == subCategory.name,
                            selectedSubCategory: $selectedSubCategory,
                            speechService: speechService,
                            language: language
                        )
                    }
                }
                .padding(12)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Sub Category Card

struct SubCategoryCard: View {
    let category: VocabCategory
    let isSelected: Bool
    @Binding var selectedSubCategory: String?
    @ObservedObject var speechService: SpeechService
    let language: String
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                    selectedSubCategory = isExpanded ? category.name : nil
                }
            }) {
                HStack(spacing: 12) {
                    Text(category.icon)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("\(category.words.count) mots")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
                .cornerRadius(12)
            }
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

            // Words list when expanded
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(category.words) { word in
                        CategoryWordRow(
                            word: word,
                            speechService: speechService,
                            language: language
                        )
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Legacy Category Card (for categories without main_category)

struct LegacyCategoryCard: View {
    let category: VocabCategory
    @Binding var selectedSubCategory: String?
    @ObservedObject var speechService: SpeechService
    let language: String
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                    selectedSubCategory = isExpanded ? category.name : nil
                }
            }) {
                HStack(spacing: 12) {
                    Text(category.icon)
                        .font(.largeTitle)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text("\(category.words.count) mots")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            // Words list when expanded
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(category.words) { word in
                        CategoryWordRow(
                            word: word,
                            speechService: speechService,
                            language: language
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
    }
}

// MARK: - Category Word Row

struct CategoryWordRow: View {
    let word: VocabWord
    @ObservedObject var speechService: SpeechService
    let language: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(word.translation)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let example = word.example, !example.isEmpty {
                    Text(example)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .italic()
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(action: {
                let lang = language == "it" ? "it-IT" : "es-ES"
                speechService.speak(word.word, language: lang)
            }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.body)
                    .foregroundColor(.blue)
            }
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}
