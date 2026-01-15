import SwiftUI

// MARK: - Email Sign In View

struct EmailSignInView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isCreatingAccount: Bool = false
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "envelope.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                            
                            Text(isCreatingAccount ? "Créer un compte" : "Se connecter")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(isCreatingAccount ? "Créez votre compte Onykroua" : "Connectez-vous avec votre email")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 16) {
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                TextField("votre@email.com", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                            }
                            
                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mot de passe")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                SecureField("••••••••", text: $password)
                                    .textContentType(isCreatingAccount ? .newPassword : .password)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                            }
                            
                            if isCreatingAccount {
                                Text("Le mot de passe doit contenir au moins 6 caractères")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // Error message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        // Submit button
                        Button(action: handleSubmit) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isCreatingAccount ? "Créer mon compte" : "Se connecter")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .disabled(!isFormValid || isLoading)
                        .padding(.horizontal, 32)
                        
                        // Toggle mode
                        Button(action: {
                            withAnimation {
                                isCreatingAccount.toggle()
                                errorMessage = nil
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text(isCreatingAccount ? "Déjà un compte ?" : "Pas encore de compte ?")
                                    .foregroundColor(.secondary)
                                Text(isCreatingAccount ? "Se connecter" : "Créer un compte")
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        email.contains("@") && 
        !password.isEmpty && 
        password.count >= 6
    }
    
    // MARK: - Actions
    
    private func handleSubmit() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isCreatingAccount {
                    try await firebaseManager.createAccount(email: email, password: password)
                } else {
                    try await firebaseManager.signInWithEmail(email: email, password: password)
                }
                
                DispatchQueue.main.async {
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = getErrorMessage(error)
                }
            }
        }
    }
    
    private func getErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case 17007:
            return "Cette adresse email est déjà utilisée"
        case 17008:
            return "Email invalide"
        case 17009:
            return "Mot de passe incorrect"
        case 17011:
            return "Aucun compte trouvé avec cet email"
        case 17026:
            return "Le mot de passe doit contenir au moins 6 caractères"
        default:
            return "Erreur: \(error.localizedDescription)"
        }
    }
}

// MARK: - Preview

struct EmailSignInView_Previews: PreviewProvider {
    static var previews: some View {
        EmailSignInView()
            .environmentObject(FirebaseManager.shared)
    }
}
