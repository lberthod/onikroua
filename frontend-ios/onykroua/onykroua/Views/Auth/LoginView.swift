import SwiftUI

// MARK: - Login View

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var showEmailSignIn = false
    var onSuccess: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo and title
                VStack(spacing: 16) {
                    Text("🇮🇹")
                        .font(.system(size: 100))
                    
                    Text("Onykroua")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Apprenez l'italien et l'espagnol")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Sign in options
                VStack(spacing: 16) {
                    SignInWithAppleButton {
                        onSuccess?()
                        dismiss()
                    }
                    
                    SignInWithGoogleButton {
                        onSuccess?()
                        dismiss()
                    }
                    
                    Button(action: { showEmailSignIn = true }) {
                        Label("Continuer avec Email", systemImage: "envelope.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                try await firebaseManager.signInAnonymously()
                                onSuccess?()
                                dismiss()
                            } catch {
                                print("❌ Error signing in anonymously: \(error)")
                            }
                        }
                    }) {
                        Label("Continuer en invité", systemImage: "person.fill.questionmark")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                
                // Privacy note
                Text("En continuant, vous acceptez nos conditions d'utilisation et notre politique de confidentialité")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView()
                .environmentObject(firebaseManager)
        }
    }
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(FirebaseManager.shared)
    }
}
