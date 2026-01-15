import Foundation
import SwiftUI
import AuthenticationServices
import CryptoKit

// MARK: - Apple Sign In Manager

class AppleSignInManager: NSObject, ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var errorMessage: String?
    
    private var currentNonce: String?
    
    // MARK: - Sign In
    
    func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    // MARK: - Nonce Generation
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("❌ Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("❌ Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("❌ Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Sign in with Firebase
            Task {
                do {
                    try await FirebaseManager.shared.signInWithApple(
                        idToken: idTokenString,
                        nonce: nonce,
                        fullName: appleIDCredential.fullName
                    )
                    
                    DispatchQueue.main.async {
                        self.isSignedIn = true
                        
                        // Save user info if available
                        if let fullName = appleIDCredential.fullName {
                            let displayName = [fullName.givenName, fullName.familyName]
                                .compactMap { $0 }
                                .joined(separator: " ")
                            
                            if !displayName.isEmpty {
                                UserDefaults.standard.set(displayName, forKey: "userDisplayName")
                            }
                        }
                        
                        if let email = appleIDCredential.email {
                            UserDefaults.standard.set(email, forKey: "userEmail")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        print("❌ Error signing in with Apple: \(error)")
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            print("❌ Sign in with Apple errored: \(error)")
        }
    }
}

// MARK: - Sign In with Apple Button

struct SignInWithAppleButton: View {
    @StateObject private var appleSignIn = AppleSignInManager()
    let onSuccess: () -> Void
    
    var body: some View {
        Button(action: {
            appleSignIn.signInWithApple()
        }) {
            HStack {
                Image(systemName: "applelogo")
                    .font(.title2)
                
                Text("Continuer avec Apple")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.black)
            .cornerRadius(16)
        }
        .onChange(of: appleSignIn.isSignedIn) { _, isSignedIn in
            if isSignedIn {
                onSuccess()
            }
        }
        .alert("Erreur de connexion", isPresented: .constant(appleSignIn.errorMessage != nil)) {
            Button("OK") {
                appleSignIn.errorMessage = nil
            }
        } message: {
            if let errorMessage = appleSignIn.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
