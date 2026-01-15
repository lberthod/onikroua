import SwiftUI

struct RhythmSelectionScreen: View {
    @Binding var dailyMinutes: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Combien de temps par jour ?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Un objectif réaliste te motivera davantage")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            VStack(spacing: 30) {
                Text("\(dailyMinutes) min")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.blue)
                
                Slider(value: Binding(
                    get: { Double(dailyMinutes) },
                    set: { dailyMinutes = Int($0) }
                ), in: 5...60, step: 5)
                    .tint(.blue)
                    .padding(.horizontal, 40)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Objectif quotidien")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(expectedXP) XP/jour")
                                .font(.headline)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Progression estimée")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.green)
                            Text("\(expectedWordsPerWeek) mots/semaine")
                                .font(.headline)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                
                VStack(spacing: 12) {
                    OnboardingRecommendationRow(
                        minutes: 5,
                        label: "Rapide",
                        description: "Parfait pour commencer",
                        isSelected: dailyMinutes == 5,
                        action: { dailyMinutes = 5 }
                    )
                    
                    OnboardingRecommendationRow(
                        minutes: 10,
                        label: "Équilibré",
                        description: "Recommandé pour la plupart",
                        isSelected: dailyMinutes == 10,
                        action: { dailyMinutes = 10 }
                    )
                    
                    OnboardingRecommendationRow(
                        minutes: 20,
                        label: "Intensif",
                        description: "Pour progresser rapidement",
                        isSelected: dailyMinutes == 20,
                        action: { dailyMinutes = 20 }
                    )
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    private var expectedXP: Int {
        switch dailyMinutes {
        case 0..<10: return 50
        case 10..<20: return 100
        case 20..<30: return 150
        default: return 200
        }
    }
    
    private var expectedWordsPerWeek: Int {
        dailyMinutes * 7 / 2
    }
}

struct OnboardingRecommendationRow: View {
    let minutes: Int
    let label: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(minutes) min")
                            .font(.headline)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(label)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}
