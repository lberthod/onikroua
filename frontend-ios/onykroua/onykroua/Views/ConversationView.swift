import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ConversationExplorerTab()
                .environmentObject(env)
                .tabItem {
                    Label("Explorer", systemImage: "magnifyingglass")
                }
                .tag(0)

            Text("Catégories View") // TODO: Implement Categories Tab
                .tabItem {
                    Label("Catégories", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            ConversationPracticeTab()
                .tabItem {
                    Label("Pratiquer", systemImage: "gamecontroller")
                }
                .tag(2)
        }
        .navigationTitle("💬 Conversation")
    }
}

struct ConversationExplorerTab: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    @State private var activeScenario: ConversationScenario? = nil
    
    let scenarios = ConversationDataSource.getAllScenarios()
    
    private var filteredScenarios: [ConversationScenario] {
        scenarios.filter { scenario in
            let matchesSearch = searchText.isEmpty || 
                scenario.name.localizedCaseInsensitiveContains(searchText) || 
                scenario.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter = selectedFilter == nil || scenario.category == selectedFilter
            
            return matchesSearch && matchesFilter
        }
    }
    
    private let chips: [ChipItem] = [
        .init(id: "travel", label: "Voyage", icon: "airplane"),
        .init(id: "daily", label: "Quotidien", icon: "sun.max"),
        .init(id: "work", label: "Travail", icon: "briefcase"),
        .init(id: "social", label: "Social", icon: "person.2")
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: UI.Spacing.md, pinnedViews: [.sectionHeaders]) {
                Section {
                    if filteredScenarios.isEmpty {
                        EmptyState(
                            title: "Aucun scénario trouvé",
                            message: "Essaie un autre filtre ou une autre recherche",
                            icon: "message.and.waveform"
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: UI.Spacing.md) {
                            ForEach(filteredScenarios) { scenario in
                                ScenarioCard(scenario: scenario) {
                                    activeScenario = scenario
                                }
                            }
                        }
                        .padding(.horizontal, UI.Spacing.lg)
                    }
                } header: {
                    StickyHeader(
                        title: "Explorer les scénarios",
                        subtitle: "Pratique l'italien en situation réelle",
                        searchText: $searchText,
                        chips: chips,
                        selectedChipId: selectedFilter,
                        onSelectChip: { selectedFilter = $0 },
                        countText: "\(filteredScenarios.count) scénarios disponibles"
                    )
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .fullScreenCover(item: $activeScenario) { scenario in
            ActiveConversationView(scenario: scenario)
        }
    }
}

struct ActiveConversationView: View {
    let scenario: ConversationScenario
    @EnvironmentObject var env: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @State private var currentMessageIndex = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(scenario.messages.prefix(currentMessageIndex + 1).enumerated()), id: \.element.id) { index, message in
                            ConversationMessageBubble(message: message, speechService: env.speechService)
                        }
                    }
                    .padding()
                }
                
                VStack(spacing: UI.Spacing.md) {
                    if currentMessageIndex < scenario.messages.count - 1 {
                        PrimaryCTAButton(title: "Message suivant", icon: "arrow.down.circle.fill") {
                            withAnimation {
                                currentMessageIndex += 1
                            }
                        }
                    } else {
                        HStack(spacing: UI.Spacing.md) {
                            Button(action: { currentMessageIndex = 0 }) {
                                Label("Recommencer", systemImage: "arrow.counterclockwise")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(UI.Radius.r16)
                            }
                            .buttonStyle(.plain)
                            
                            PrimaryCTAButton(title: "Terminer", icon: "checkmark.circle.fill") {
                                dismiss()
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
            }
            .navigationTitle(scenario.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Quitter") { dismiss() }
                }
            }
        }
    }
}

struct ScenarioCard: View {
    let scenario: ConversationScenario
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            OnykrouaCard(isInteractive: true) {
                VStack(spacing: UI.Spacing.md) {
                    Text(scenario.icon)
                        .font(.system(size: 40))
                    
                    VStack(spacing: UI.Spacing.xs) {
                        Text(scenario.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("\(scenario.messages.count) messages")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .padding(UI.Spacing.sm)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ConversationPracticeTab: View {
    var body: some View {
        ScrollView {
            VStack(spacing: UI.Spacing.lg) {
                PracticeModeCard(
                    title: "Rôle Libre",
                    subtitle: "Discute librement avec l'IA",
                    icon: "sparkles.rectangle.stack",
                    color: .purple,
                    badge: "Nouveau"
                ) {
                    // Start roleplay
                }
                
                PracticeModeCard(
                    title: "Défis de Grammaire",
                    subtitle: "Applique les règles en parlant",
                    icon: "checkmark.bubble.fill",
                    color: .green
                ) {
                    // Start grammar challenge
                }
            }
            .padding(UI.Spacing.lg)
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct ConversationMessageBubble: View {
    let message: ConversationMessage
    @ObservedObject var speechService: SpeechService
    @State private var showTranslation = false
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if message.isUser { Spacer() }
                
                VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                    Text(message.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(message.isUser ? Color.blue : Color(.systemGray5))
                        .foregroundColor(message.isUser ? .white : .primary)
                        .cornerRadius(20)
                    
                    if showTranslation {
                        Text(message.translation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                            .padding(.horizontal, 8)
                    }
                }
                
                if !message.isUser { Spacer() }
            }
            
            HStack(spacing: 12) {
                if message.isUser { Spacer() }
                
                Button(action: { withAnimation { showTranslation.toggle() } }) {
                    Image(systemName: showTranslation ? "eye.slash.fill" : "eye.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: { speechService.speak(message.text, language: "it-IT") }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if !message.isUser { Spacer() }
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    NavigationView {
        ConversationView()
    }
}
