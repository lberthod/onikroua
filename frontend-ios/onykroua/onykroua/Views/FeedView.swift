import SwiftUI
import AVFoundation

struct FeedView: View {
    @StateObject private var feedService = FeedService()
    @StateObject private var speechService = SpeechService()
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if feedService.items.isEmpty {
                ProgressView()
                    .tint(.white)
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(feedService.items.enumerated()), id: \.element.id) { index, item in
                        FeedCardView(
                            item: item,
                            speechService: speechService,
                            onLike: { feedService.toggleLike(itemId: item.id) },
                            onBookmark: { feedService.toggleBookmark(itemId: item.id) }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .onChange(of: currentIndex) { _, newValue in
                    if newValue >= feedService.items.count - 3 && feedService.hasMore() {
                        _ = feedService.loadNextPage()
                    }
                }
            }
        }
        .navigationTitle("📱 Feed")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if feedService.items.isEmpty {
                _ = feedService.loadNextPage()
            }
        }
    }
}

struct FeedCardView: View {
    let item: FeedItem
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
                                Button(action: { speechService.speak(audioText) }) {
                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
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
