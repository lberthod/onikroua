import SwiftUI

struct GeminiLiveView: View {
    @State private var isRecording = false
    @State private var transcription = "Appuyez sur le micro pour commencer..."
    @State private var conversationHistory: [String] = []
    @State private var recordingTime: Int = 0
    @State private var timer: Timer?
    
    let suggestions = [
        "Come si dice... in italiano?",
        "Mi puoi aiutare con...",
        "Non capisco questa parola",
        "Puoi ripetere per favore?"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "waveform")
                        .font(.system(size: 80))
                        .foregroundColor(.indigo)
                        .symbolEffect(.variableColor, isActive: isRecording)
                    
                    Text("🤖 Gemini Live")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if isRecording {
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 12, height: 12)
                            Text("Enregistrement... \(recordingTime)s")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    Text(transcription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    if !conversationHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📝 Historique")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(conversationHistory.indices, id: \.self) { index in
                                Text(conversationHistory[index])
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    if !isRecording {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("💡 Suggestions")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button(action: {
                                    transcription = suggestion
                                }) {
                                    HStack {
                                        Text(suggestion)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(.indigo)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 40)
            }
            
            VStack(spacing: 16) {
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red : Color.indigo)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                if !conversationHistory.isEmpty {
                    Button(action: { conversationHistory.removeAll() }) {
                        Text("Réinitialiser")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
        }
        .navigationTitle("🎙️ Gemini Live")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    private func toggleRecording() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isRecording.toggle()
        }
        
        if isRecording {
            transcription = "🎤 Parle en italien..."
            recordingTime = 0
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                recordingTime += 1
            }
        } else {
            timer?.invalidate()
            timer = nil
            transcription = "✅ Enregistrement terminé! Analyse en cours..."
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let response = "Molto bene! La tua pronuncia è buona. Continua così!"
                conversationHistory.append("Toi: [Enregistrement \(recordingTime)s]")
                conversationHistory.append("IA: \(response)")
                transcription = response
            }
        }
    }
}

#Preview {
    NavigationView {
        GeminiLiveView()
    }
}
