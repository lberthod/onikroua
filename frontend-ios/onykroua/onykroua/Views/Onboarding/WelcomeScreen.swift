import SwiftUI

struct WelcomeScreen: View {
    @Binding var isPresented: Bool
    @State private var animateIcon = false
    @State private var showLogin = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("🇮🇹")
                .font(.system(size: 100))
                .scaleEffect(animateIcon ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animateIcon)
                .onAppear { animateIcon = true }
            
            VStack(spacing: 12) {
                Text("Bienvenue sur Onykroua")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Apprendre l'italien avec l'IA")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                OnboardingFeatureRow(icon: "book.fill", text: "15,000+ mots", color: .blue)
                OnboardingFeatureRow(icon: "mic.fill", text: "Tuteur IA vocal", color: .purple)
                OnboardingFeatureRow(icon: "gamecontroller.fill", text: "Gamification addictive", color: .orange)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 12) {
                Text("Commence ton voyage linguistique")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: { showLogin = true }) {
                    Text("J'ai déjà un compte")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showLogin) {
            LoginView(onSuccess: {
                print("🔔 LoginView onSuccess called - triggering skip")
                // Fermer le sheet d'abord
                showLogin = false
                // Puis déclencher le skip après un délai
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    print("🔔 Setting isPresented = true to trigger skip")
                    isPresented = true
                }
            })
        }
    }
}

struct OnboardingFeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(text)
                .font(.headline)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
