import SwiftUI
import AVFoundation

struct FeedView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var currentIndex = 0
    @State private var selectedLanguage = "it"
    @State private var isLoadingMore = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showAdvancedSearch = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ErrorOverlay(errorManager: env.errorManager)
            
            VStack(spacing: 0) {
                // Language selector
                languageSelector
                
                if env.feedService.items.isEmpty {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Vertical scroll feed with snap paging
                    GeometryReader { geometry in
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVStack(spacing: 0) {
                                    ForEach(Array(env.feedService.items.enumerated()), id: \.element.id) { index, item in
                                        FeedCardView(
                                            item: item,
                                            language: selectedLanguage,
                                            speechService: env.speechService,
                                            onLike: { env.feedService.toggleLike(itemId: item.id) },
                                            onBookmark: { env.feedService.toggleBookmark(itemId: item.id) }
                                        )
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .id(index)
                                        .onAppear {
                                            if index == currentIndex {
                                                // Stop speech when changing item
                                                env.speechService.stop()
                                            }
                                            // Load more items 5 before the end
                                            if index >= env.feedService.items.count - 5 && env.feedService.hasMore() && !isLoadingMore {
                                                loadMoreItems()
                                            }
                                        }
                                    }
                                    
                                    if isLoadingMore {
                                        ProgressView()
                                            .tint(.white)
                                            .frame(height: 100)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("📱 Feed")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            env.vocabularyManager.ensureLoaded(language: selectedLanguage)
            if env.feedService.items.isEmpty {
                loadInitialFeed()
            }
        }
        .onChange(of: selectedLanguage) { newLanguage in
            env.vocabularyManager.ensureLoaded(language: newLanguage)
        }
        .onChange(of: env.vocabularyManager.loadingError != nil) { hasError in
            if hasError, let error = env.vocabularyManager.loadingError {
                env.errorManager.handle(error) {
                    env.vocabularyManager.loadVocabularyAsync(language: selectedLanguage)
                }
            }
        }
    }
    
    var languageSelector: some View {
        HStack(spacing: 12) {
            LanguageSelectorButton(flag: "🇮🇹", name: "Italien", isSelected: selectedLanguage == "it") {
                selectedLanguage = "it"
                reloadFeed()
            }
            
            LanguageSelectorButton(flag: "🇪🇸", name: "Espagnol", isSelected: selectedLanguage == "es") {
                selectedLanguage = "es"
                reloadFeed()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.7))
    }
    
    private func loadInitialFeed() {
        // Load 2 pages initially for smooth experience (like Android)
        _ = env.feedService.loadNextPage()
        _ = env.feedService.loadNextPage()
    }
    
    private func loadMoreItems() {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            _ = env.feedService.loadNextPage()
            isLoadingMore = false
        }
    }
    
    private func reloadFeed() {
        currentIndex = 0
        env.feedService.reset()
        loadInitialFeed()
    }
}

struct LanguageSelectorButton: View {
    let flag: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(flag)
                    .font(.title3)
                if isSelected {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(20)
        }
    }
}

struct FeedCardView: View {
    let item: FeedItem
    let language: String
    @ObservedObject var speechService: SpeechService
    let onLike: () -> Void
    let onBookmark: () -> Void
    
    @State private var showTranslation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                gradientBackground
                
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(item.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            typeIcon
                        }
                        
                        Text(item.content)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(3)
                        
                        if showTranslation {
                            Text(item.translation)
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                                .transition(.opacity)
                        }
                        
                        if let example = item.example {
                            Text(example)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .italic()
                        }
                        
                        HStack(spacing: 20) {
                            Button(action: { withAnimation { showTranslation.toggle() } }) {
                                Image(systemName: showTranslation ? "eye.slash.fill" : "eye.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            if let audioText = item.audioText {
                                Button(action: { 
                                    let lang = language == "it" ? "it-IT" : "es-ES"
                                    speechService.speak(audioText, language: lang) 
                                }) {
                                    Image(systemName: speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                        .font(.title2)
                                        .foregroundColor(speechService.isSpeaking ? .yellow : .white)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
                VStack(spacing: 16) {
                    ActionButton(
                        icon: item.liked ? "heart.fill" : "heart",
                        text: "\(item.likeCount)",
                        color: item.liked ? .red : .white,
                        action: onLike
                    )
                    
                    ActionButton(
                        icon: item.bookmarked ? "bookmark.fill" : "bookmark",
                        text: "",
                        color: item.bookmarked ? .yellow : .white,
                        action: onBookmark
                    )
                    
                    ActionButton(
                        icon: "square.and.arrow.up",
                        text: "",
                        color: .white,
                        action: {}
                    )
                }
                .padding(.trailing, 16)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    var gradientBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var gradientColors: [Color] {
        switch item.type {
        case .vocabulary:
            return [Color.blue, Color.purple]
        case .conjugation:
            return [Color.green, Color.teal]
        case .expression:
            return [Color.orange, Color.pink]
        case .culture:
            return [Color.red, Color.orange]
        case .quiz:
            return [Color.indigo, Color.blue]
        }
    }
    
    var typeIcon: some View {
        Group {
            switch item.type {
            case .vocabulary:
                Text("📚")
            case .conjugation:
                Text("📖")
            case .expression:
                Text("💬")
            case .culture:
                Text("🇮🇹")
            case .quiz:
                Text("🎯")
            }
        }
        .font(.title)
    }
}

struct ActionButton: View {
    let icon: String
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                if !text.isEmpty {
                    Text(text)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        FeedView()
    }
}
