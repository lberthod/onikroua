import SwiftUI
import AVFoundation

struct EmojiView: View {
    @StateObject private var speechService = SpeechService()
    @State private var selectedCategory: String = "Tous"
    
    let emojiCategories: [EmojiCategoryModel] = EmojiDataSource.getAllCategories()
    
    var filteredEmojis: [EmojiWordModel] {
        if selectedCategory == "Tous" {
            return emojiCategories.flatMap { $0.items }
        }
        return emojiCategories.first { $0.name == selectedCategory }?.items ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryButton(name: "Tous", icon: "🌍", isSelected: selectedCategory == "Tous") {
                        withAnimation { selectedCategory = "Tous" }
                    }
                    
                    ForEach(emojiCategories) { category in
                        CategoryButton(name: category.name, icon: category.icon, isSelected: selectedCategory == category.name) {
                            withAnimation { selectedCategory = category.name }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredEmojis) { data in
                        EmojiCard(data: data, speechService: speechService)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("😊 Emoji (\(filteredEmojis.count))")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct CategoryButton: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(icon)
                Text(name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct EmojiCard: View {
    let data: EmojiWordModel
    @ObservedObject var speechService: SpeechService
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text(data.emoji)
                .font(.system(size: 48))
            
            Text(data.italian)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Text(data.french)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            Image(systemName: "speaker.wave.2.fill")
                .font(.caption2)
                .foregroundColor(.blue.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            isPressed = true
            speechService.speak(data.italian)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }
    }
}

#Preview {
    NavigationView {
        EmojiView()
    }
}
