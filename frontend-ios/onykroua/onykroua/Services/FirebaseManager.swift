import Foundation
import FirebaseCore
@preconcurrency import FirebaseAuth

// MARK: - Firebase Manager

@MainActor
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        // Firebase est configuré via AppDelegate
        // Setup auth state listener
        setupAuthStateListener()
    }
    
    // MARK: - Configuration
    
    private func setupAuthStateListener() {
        // Check if user is already signed in
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            self.isSignedIn = true
            print("✅ Firebase: User already signed in - \(user.uid)")
        }
        
        // Listen to auth state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isSignedIn = user != nil
                if let user = user {
                    print("✅ Firebase: Auth state changed - User: \(user.uid)")
                } else {
                    print("ℹ️ Firebase: Auth state changed - No user")
                }
            }
        }
    }
    
    // MARK: - Sign In with Apple
    
    func signInWithApple(idToken: String, nonce: String, fullName: PersonNameComponents? = nil) async throws {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: fullName
        )
        
        let result = try await Auth.auth().signIn(with: credential)
        
        self.currentUser = result.user
        self.isSignedIn = true
        print("✅ Firebase: Signed in with Apple - \(result.user.uid)")
    }
    
    // MARK: - Sign In with Email/Password
    
    func signInWithEmail(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        
        self.currentUser = result.user
        self.isSignedIn = true
        print("✅ Firebase: Signed in with Email - \(result.user.uid)")
    }
    
    func createAccount(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        self.currentUser = result.user
        self.isSignedIn = true
        print("✅ Firebase: Account created - \(result.user.uid)")
    }
    
    // MARK: - Sign In Anonymously
    
    func signInAnonymously() async throws {
        let result = try await Auth.auth().signInAnonymously()
        
        self.currentUser = result.user
        self.isSignedIn = true
        print("✅ Firebase: Signed in anonymously - \(result.user.uid)")
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        try Auth.auth().signOut()
        
        self.currentUser = nil
        self.isSignedIn = false
        print("✅ Firebase: User signed out")
    }
    
    // MARK: - User Info
    
    var userId: String? {
        currentUser?.uid
    }
    
    var userEmail: String? {
        currentUser?.email
    }
    
    var userDisplayName: String? {
        currentUser?.displayName
    }
}
