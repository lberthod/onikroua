import SwiftUI

// MARK: - CategoriesTab (matching EmojiView_Enhanced design)

public struct CategoriesTab: View {

    // MARK: - Inputs
    let language: String
    @EnvironmentObject var env: AppEnvironment

    public init(language: String) {
        self.language = language
    }

    // MARK: - Computed

    private var allCategories: [VocabCategory] {
        env.vocabularyManager.getCategories(language: language)
    }

    // MARK: - View
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: UI.Spacing.lg) {
                ForEach(allCategories) { category in
                    NavigationLink(destination: VocabularyCategoryDetailView(category: category, language: language).environmentObject(env)) {
                        OnykrouaCategoryRow(
                            icon: .emoji(category.icon),
                            accent: .blue,
                            title: category.name,
                            subtitle: nil,
                            countText: "\(category.words.count) mots"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, UI.Spacing.lg)
            .padding(.top, UI.Spacing.md)
            .padding(.bottom, 96)
        }
        .background(UI.Surface.groupedBackground)
    }
}

// MARK: - Category Detail View (matching EmojiView_Enhanced EmojiCategoryDetailView)

struct VocabularyCategoryDetailView: View {
    @EnvironmentObject var env: AppEnvironment
    let category: VocabCategory
    let language: String

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: UI.Spacing.md) {
                ForEach(category.words) { word in
                    VocabularyCategoryCard(word: word, speechService: env.speechService, language: language)
                }
            }
            .padding(.horizontal, UI.Spacing.lg)
            .padding(.vertical, UI.Spacing.md)
        }
        .navigationTitle(category.name)
        .background(UI.Surface.groupedBackground)
    }
}

// MARK: - Vocabulary Category Card (matching EmojiView_Enhanced EmojiDictionaryCard)

struct VocabularyCategoryCard: View {
    let word: VocabWord
    @ObservedObject var speechService: SpeechService
    let language: String
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: UI.Spacing.sm) {
            Text(word.word)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(word.translation)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)

            Image(systemName: "speaker.wave.2.fill")
                .font(.caption2)
                .foregroundColor(.blue.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .frame(height: UI.Size.cardHeight)
        .background(UI.Surface.background)
        .cornerRadius(UI.Radius.r12)
        .shadow(color: UI.Shadow.card.color, radius: UI.Shadow.card.radius, x: UI.Shadow.card.x, y: UI.Shadow.card.y)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            isPressed = true
            let lang = language == "it" ? "it-IT" : "es-ES"
            speechService.speak(word.word, language: lang)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }
    }
}
