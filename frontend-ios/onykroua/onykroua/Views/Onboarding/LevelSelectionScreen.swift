import SwiftUI

struct LevelSelectionScreen: View {
    @Binding var selectedLevel: String
    @State private var showAssessment = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Quel est ton niveau actuel ?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Nous allons adapter le contenu à ton niveau")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                OnboardingLevelOption(
                    level: .a1,
                    description: "Débutant complet",
                    isSelected: selectedLevel == CEFRLevel.a1.rawValue,
                    action: { selectedLevel = CEFRLevel.a1.rawValue }
                )
                
                OnboardingLevelOption(
                    level: .a2,
                    description: "J'ai des bases",
                    isSelected: selectedLevel == CEFRLevel.a2.rawValue,
                    action: { selectedLevel = CEFRLevel.a2.rawValue }
                )
                
                OnboardingLevelOption(
                    level: .b1,
                    description: "Intermédiaire",
                    isSelected: selectedLevel == CEFRLevel.b1.rawValue,
                    action: { selectedLevel = CEFRLevel.b1.rawValue }
                )
                
                OnboardingLevelOption(
                    level: .b2,
                    description: "Avancé",
                    isSelected: selectedLevel == CEFRLevel.b2.rawValue,
                    action: { selectedLevel = CEFRLevel.b2.rawValue }
                )
                
                Button(action: { showAssessment = true }) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading) {
                            Text("Je ne sais pas")
                                .font(.headline)
                            Text("Passer un test de niveau")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showAssessment) {
            LevelAssessmentView(selectedLevel: $selectedLevel)
        }
    }
}

struct OnboardingLevelOption: View {
    let level: CEFRLevel
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(level.icon)
                    .font(.system(size: 30))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
