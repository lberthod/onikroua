import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct SignInWithGoogleButton: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await signInWithGoogle()
            }
        }) {
            HStack {
                Image(systemName: "globe")
                    .font(.title3)
                Text("Continuer avec Google")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.26, green: 0.52, blue: 0.96), Color(red: 0.22, green: 0.45, blue: 0.82)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    private func signInWithGoogle() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ No root view controller found")
            return
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                print("❌ No ID token from Google Sign In")
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            await MainActor.run {
                firebaseManager.currentUser = authResult.user
                firebaseManager.isSignedIn = true
                print("✅ Firebase: Signed in with Google - \(authResult.user.uid)")
                action()
            }
        } catch {
            print("❌ Error signing in with Google: \(error.localizedDescription)")
        }
    }
}
