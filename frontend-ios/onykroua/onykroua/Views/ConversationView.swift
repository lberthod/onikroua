import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedScenario: ConversationScenario?
    @State private var showScenarioPicker = true
    @State private var currentMessageIndex = 0
    
    let scenarios = ConversationDataSource.getAllScenarios()
    
    var body: some View {
        VStack(spacing: 0) {
            if showScenarioPicker {
                scenarioPicker
            } else if let scenario = selectedScenario {
                conversationView(scenario: scenario)
            }
        }
        .navigationTitle("💬 Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !showScenarioPicker {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Changer") {
                        withAnimation {
                            showScenarioPicker = true
                            currentMessageIndex = 0
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    var scenarioPicker: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Choisissez un scénario")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text("Pratiquez l'italien dans différentes situations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(scenarios) { scenario in
                        ScenarioCard(scenario: scenario) {
                            withAnimation {
                                selectedScenario = scenario
                                showScenarioPicker = false
                                currentMessageIndex = 0
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    func conversationView(scenario: ConversationScenario) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(scenario.icon)
                    .font(.title)
                Text(scenario.name)
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(scenario.messages.prefix(currentMessageIndex + 1).enumerated()), id: \.element.id) { index, message in
                        ConversationMessageBubble(message: message, speechService: env.speechService)
                    }
                }
                .padding()
            }
            
            if currentMessageIndex < scenario.messages.count - 1 {
                Button(action: { 
                    withAnimation {
                        currentMessageIndex += 1
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Message suivant")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(getScenarioColor(scenario.color))
                    .cornerRadius(16)
                }
                .padding()
                .background(Color(.systemBackground))
            } else {
                HStack(spacing: 12) {
                    Button(action: { currentMessageIndex = 0 }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Recommencer")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(16)
                    }
                    
                    Button(action: { 
                        withAnimation {
                            showScenarioPicker = true
                            currentMessageIndex = 0
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Terminé")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(16)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
    }
    
    func getScenarioColor(_ colorName: String) -> Color {
        switch colorName {
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        default: return .blue
        }
    }
}

struct ScenarioCard: View {
    let scenario: ConversationScenario
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(scenario.icon)
                    .font(.system(size: 50))
                
                Text(scenario.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(scenario.messages.count) messages")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
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
