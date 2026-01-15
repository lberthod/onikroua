import SwiftUI

struct GoalSelectionScreen: View {
    @Binding var selectedGoals: [String]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Pourquoi apprends-tu l'italien ?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Sélectionne un ou plusieurs objectifs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(LearningGoal.allCases, id: \.rawValue) { goal in
                    OnboardingGoalOption(
                        icon: goal.icon,
                        title: goal.rawValue,
                        isSelected: selectedGoals.contains(goal.rawValue),
                        action: {
                            if selectedGoals.contains(goal.rawValue) {
                                selectedGoals.removeAll { $0 == goal.rawValue }
                            } else {
                                selectedGoals.append(goal.rawValue)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct OnboardingGoalOption: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.system(size: 30))
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.title3)
                        .foregroundColor(.gray)
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
