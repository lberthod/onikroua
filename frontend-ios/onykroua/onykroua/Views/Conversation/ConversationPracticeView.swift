import SwiftUI

struct ConversationPracticeView: View {
    let language: String
    @State private var scenarios: [ConversationScenario] = []
    @State private var selectedCategory: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if let category = selectedCategory {
                        categoryScenarios(category: category)
                    } else {
                        categoriesGrid
                    }
                }
                .padding()
            }
            .navigationTitle("💬 Conversations")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if selectedCategory != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { selectedCategory = nil }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Retour")
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadScenarios()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Pratique les conversations")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("24 scénarios réels pour améliorer ta fluidité")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var categoriesGrid: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Catégories")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ConversationCategoryButton(
                    icon: "🏨",
                    title: "Voyage",
                    count: scenariosCount(for: "Voyage"),
                    isSelected: selectedCategory == "Voyage",
                    action: { selectedCategory = "Voyage" }
                )
                
                ConversationCategoryButton(
                    icon: "☕",
                    title: "Quotidien",
                    count: scenariosCount(for: "Quotidien"),
                    isSelected: selectedCategory == "Quotidien",
                    action: { selectedCategory = "Quotidien" }
                )
                
                ConversationCategoryButton(
                    icon: "💼",
                    title: "Professionnel",
                    count: scenariosCount(for: "Professionnel"),
                    isSelected: selectedCategory == "Professionnel",
                    action: { selectedCategory = "Professionnel" }
                )
                
                ConversationCategoryButton(
                    icon: "👥",
                    title: "Social",
                    count: scenariosCount(for: "Social"),
                    isSelected: selectedCategory == "Social",
                    action: { selectedCategory = "Social" }
                )
                
                ConversationCategoryButton(
                    icon: "🏥",
                    title: "Urgences",
                    count: scenariosCount(for: "Urgences"),
                    isSelected: selectedCategory == "Urgences",
                    action: { selectedCategory = "Urgences" }
                )
                
                ConversationCategoryButton(
                    icon: "🎭",
                    title: "Culture",
                    count: scenariosCount(for: "Culture"),
                    isSelected: selectedCategory == "Culture",
                    action: { selectedCategory = "Culture" }
                )
            }
        }
    }
    
    private func categoryScenarios(category: String) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(category)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(filteredScenarios(category).count) scénarios")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(filteredScenarios(category)) { scenario in
                NavigationLink(destination: ConversationDetailView(scenario: scenario)) {
                    ScenarioCard(scenario: scenario)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func loadScenarios() {
        scenarios = ConversationData.getScenarios(for: language)
    }
    
    private func scenariosCount(for category: String) -> Int {
        return filteredScenarios(category).count
    }
    
    private func filteredScenarios(_ category: String) -> [ConversationScenario] {
        return scenarios.filter { $0.category == category }
    }
}

struct ConversationCategoryButton: View {
    let icon: String
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 30))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text("\(count) scénarios")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct ScenarioCard: View {
    let scenario: ConversationScenario
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(scenario.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(scenario.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Label("\(scenario.messages.count) messages", systemImage: "message.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label(scenario.difficulty.rawValue, systemImage: scenario.difficulty.icon)
                    .font(.caption)
                    .foregroundColor(difficultyColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private var difficultyColor: Color {
        switch scenario.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Conversation Detail View

struct ConversationDetailView: View {
    let scenario: ConversationScenario
    @State private var currentMessageIndex = 0
    @State private var showTranslation = false
    @State private var isPlaying = false
    @State private var completedMessages: Set<Int> = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            progressHeader
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        scenarioInfo
                        
                        messagesSection
                        
                        if currentMessageIndex >= scenario.messages.count {
                            completionSection
                        }
                    }
                    .padding()
                }
            }
            
            if currentMessageIndex < scenario.messages.count {
                controlsSection
            }
        }
        .navigationTitle(scenario.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Message \(min(currentMessageIndex + 1, scenario.messages.count))/\(scenario.messages.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showTranslation.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: showTranslation ? "eye.fill" : "eye.slash.fill")
                        Text(showTranslation ? "Masquer" : "Afficher")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            ProgressView(value: Double(currentMessageIndex), total: Double(scenario.messages.count))
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var scenarioInfo: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(scenario.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(scenario.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                InfoBadge(icon: "person.2.fill", text: "\(scenario.messages.count) messages")
                InfoBadge(icon: "chart.bar.fill", text: scenario.difficulty.rawValue)
                InfoBadge(icon: "folder.fill", text: scenario.category)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var messagesSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(scenario.messages.enumerated()), id: \.offset) { index, message in
                if index <= currentMessageIndex {
                    MessageBubble(
                        message: message,
                        showTranslation: showTranslation,
                        isVisible: true
                    )
                    .id(index)
                }
            }
        }
    }
    
    private var completionSection: some View {
        VStack(spacing: 24) {
            Text("🎉")
                .font(.system(size: 80))
            
            Text("Conversation terminée!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tu as complété ce scénario avec succès")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button(action: resetConversation) {
                    Label("Recommencer", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
                
                Button(action: { dismiss() }) {
                    Label("Terminer", systemImage: "checkmark")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: previousMessage) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .disabled(currentMessageIndex == 0)
                .opacity(currentMessageIndex == 0 ? 0.5 : 1)
                
                Button(action: togglePlay) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: nextMessage) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .disabled(currentMessageIndex >= scenario.messages.count)
                .opacity(currentMessageIndex >= scenario.messages.count ? 0.5 : 1)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func nextMessage() {
        if currentMessageIndex < scenario.messages.count {
            withAnimation {
                completedMessages.insert(currentMessageIndex)
                currentMessageIndex += 1
            }
        }
    }
    
    private func previousMessage() {
        if currentMessageIndex > 0 {
            withAnimation {
                currentMessageIndex -= 1
            }
        }
    }
    
    private func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            playConversation()
        }
    }
    
    private func playConversation() {
        guard isPlaying && currentMessageIndex < scenario.messages.count else {
            isPlaying = false
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            nextMessage()
            playConversation()
        }
    }
    
    private func resetConversation() {
        currentMessageIndex = 0
        completedMessages.removeAll()
        showTranslation = false
        isPlaying = false
    }
}

struct MessageBubble: View {
    let message: ConversationMessage
    let showTranslation: Bool
    let isVisible: Bool
    
    var body: some View {
        HStack {
            if message.speaker == "B" {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.speaker == "A" ? .leading : .trailing, spacing: 8) {
                HStack(spacing: 8) {
                    if message.speaker == "A" {
                        Text("👤")
                            .font(.caption)
                    }
                    
                    Text(message.speaker == "A" ? "Toi" : "Interlocuteur")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    if message.speaker == "B" {
                        Text("💬")
                            .font(.caption)
                    }
                }
                
                VStack(alignment: message.speaker == "A" ? .leading : .trailing, spacing: 8) {
                    Text(message.text)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if showTranslation {
                        Text(message.translation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(message.speaker == "A" ? Color.blue.opacity(0.1) : Color(.systemGray6))
                )
            }
            
            if message.speaker == "A" {
                Spacer(minLength: 50)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.spring(), value: isVisible)
    }
}

struct InfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
        )
        .foregroundColor(.secondary)
    }
}
