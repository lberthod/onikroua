import SwiftUI

struct XPGainAnimationView: View {
    let xpAmount: Int
    @Binding var isShowing: Bool
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("+\(xpAmount) XP")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.blue)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .foregroundColor(.white)
                .offset(y: offset)
                .opacity(opacity)
                .scaleEffect(scale)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(.top, 100)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                offset = 0
                opacity = 1
                scale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    offset = -50
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isShowing = false
                }
            }
        }
    }
}

struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { index in
                Circle()
                    .fill(colors.randomElement() ?? .blue)
                    .frame(width: 10, height: 10)
                    .offset(
                        x: animate ? CGFloat.random(in: -200...200) : 0,
                        y: animate ? CGFloat.random(in: -400...400) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.5)
                            .delay(Double(index) * 0.02),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct LevelUpModalView: View {
    let newLevel: CEFRLevel
    @Binding var isShowing: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            if showConfetti {
                ConfettiView()
            }
            
            VStack(spacing: 30) {
                Text(newLevel.icon)
                    .font(.system(size: 100))
                    .scaleEffect(scale)
                
                VStack(spacing: 12) {
                    Text("🎉 Félicitations !")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Niveau atteint")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(newLevel.displayName)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text(newLevel.detailedDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: dismissModal) {
                    Text("Continuer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .padding(40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
    
    private func dismissModal() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}

struct AchievementUnlockedModalView: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            if showConfetti {
                ConfettiView()
            }
            
            VStack(spacing: 30) {
                Text(achievement.achievementType.icon)
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                
                VStack(spacing: 12) {
                    Text("🎉 Badge Débloqué !")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(achievement.achievementType.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(achievement.achievementType.rarity.color)
                    
                    Text(achievement.achievementType.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("+\(achievement.achievementType.xpReward) XP")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.2))
                    )
                    
                    Text(achievement.achievementType.rarity.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(achievement.achievementType.rarity.color)
                }
                
                Button(action: dismissModal) {
                    Text("Génial !")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .padding(40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
    
    private func dismissModal() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}
