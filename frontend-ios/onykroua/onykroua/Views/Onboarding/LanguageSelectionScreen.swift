import SwiftUI

struct LanguageSelectionScreen: View {
    @Binding var selectedLanguage: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Quelle langue veux-tu apprendre ?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Tu pourras en ajouter d'autres plus tard")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            VStack(spacing: 20) {
                OnboardingLanguageOption(
                    flag: "🇮🇹",
                    name: "Italien",
                    isSelected: selectedLanguage == Language.italian.rawValue,
                    action: { selectedLanguage = Language.italian.rawValue }
                )
                
                OnboardingLanguageOption(
                    flag: "🇪🇸",
                    name: "Espagnol",
                    isSelected: selectedLanguage == Language.spanish.rawValue,
                    action: { selectedLanguage = Language.spanish.rawValue }
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct OnboardingLanguageOption: View {
    let flag: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(flag)
                    .font(.system(size: 50))
                
                Text(name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
