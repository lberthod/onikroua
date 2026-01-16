# 🔥 Configuration Firebase pour iOS

**Date:** 15 Janvier 2026  
**Objectif:** Configurer Firebase avec Sign In with Apple

---

## ⚠️ ÉTAPES MANUELLES REQUISES DANS XCODE

### 1. Ajouter Firebase via Swift Package Manager

1. **Ouvrir le projet dans Xcode**
2. **File > Add Packages...**
3. **Entrer l'URL:** `https://github.com/firebase/firebase-ios-sdk`
4. **Sélectionner la version:** Latest (recommandé)
5. **Choisir les packages:**
   - ✅ `FirebaseAuth`
   - ✅ `FirebaseCore`
   - ✅ `FirebaseAnalytics` (ou `FirebaseAnalyticsWithoutAdId` sans IDFA)
6. **Cliquer "Add Package"**
7. **Attendre la résolution des dépendances**

### 2. Ajouter GoogleService-Info.plist au projet

1. **Localiser le fichier:** `/Users/berthod/Desktop/onykroua/frontend-ios/onykroua/onykroua/GoogleService-Info.plist`
2. **Dans Xcode, clic droit sur le dossier `onykroua`**
3. **"Add Files to onykroua..."**
4. **Sélectionner `GoogleService-Info.plist`**
5. **✅ Cocher "Copy items if needed"**
6. **✅ Cocher target "onykroua"**
7. **Cliquer "Add"**

### 3. Configurer Sign In with Apple

#### A. Activer la capability

1. **Sélectionner le projet dans le navigateur**
2. **Sélectionner le target "onykroua"**
3. **Onglet "Signing & Capabilities"**
4. **Cliquer "+ Capability"**
5. **Rechercher et ajouter "Sign in with Apple"**

#### B. Configurer Firebase Console

1. **Aller sur [Firebase Console](https://console.firebase.google.com)**
2. **Sélectionner le projet "onikroua"**
3. **Authentication > Sign-in method**
4. **Activer "Apple"**
5. **Entrer les informations:**
   - **Bundle ID:** `com.loicberthod.onykroua`
   - **Team ID:** (depuis Apple Developer Account)

#### C. Configurer Apple Developer

1. **[Apple Developer](https://developer.apple.com)**
2. **Certificates, Identifiers & Profiles**
3. **Identifiers > App IDs**
4. **Sélectionner votre App ID**
5. **✅ Cocher "Sign in with Apple"**
6. **Sauvegarder**

---

## ✅ FICHIERS CRÉÉS

### Services (3 fichiers)

1. **`Services/FirebaseManager.swift`**
   - Configuration Firebase
   - Auth state listener
   - Sign in with Apple integration
   - Sign out

2. **`Services/AppleSignInManager.swift`**
   - ASAuthorizationControllerDelegate
   - Nonce generation (sécurité)
   - SHA256 hashing
   - Token handling

3. **`GoogleService-Info.plist`** (copié depuis Android)
   - Configuration Firebase
   - API keys
   - Project ID

### Views (1 fichier)

4. **`Views/Auth/LoginView.swift`**
   - Interface de connexion
   - Bouton Sign In with Apple
   - Option "Continuer sans compte"
   - Design moderne

### App

5. **`onykrouaApp.swift`** (modifié)
   - Import FirebaseCore
   - Initialisation Firebase
   - FirebaseManager en EnvironmentObject

---

## 🔧 CONFIGURATION DANS LE CODE

### onykrouaApp.swift

```swift
import SwiftUI
import FirebaseCore

@main
struct onykrouaApp: App {
    @StateObject private var appEnvironment = AppEnvironment.shared
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    init() {
        // Configure Firebase
        FirebaseManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .environmentObject(appEnvironment)
                    .environmentObject(firebaseManager)
            } else {
                ContentView()
                    .environmentObject(appEnvironment)
                    .environmentObject(firebaseManager)
            }
        }
    }
}
```

### Utilisation dans les vues

```swift
struct ProfileView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        VStack {
            if firebaseManager.isSignedIn {
                Text("Connecté: \(firebaseManager.userEmail ?? "Utilisateur")")
                
                Button("Se déconnecter") {
                    try? firebaseManager.signOut()
                }
            } else {
                SignInWithAppleButton {
                    print("Connexion réussie!")
                }
            }
        }
    }
}
```

---

## 🎯 FONCTIONNALITÉS DISPONIBLES

### FirebaseManager

```swift
// État de connexion
firebaseManager.isSignedIn // Bool
firebaseManager.currentUser // User?

// Informations utilisateur
firebaseManager.userId // String?
firebaseManager.userEmail // String?
firebaseManager.userDisplayName // String?

// Actions
try await firebaseManager.signInWithApple(idToken:nonce:)
try firebaseManager.signOut()
```

### AppleSignInManager

```swift
// Démarrer le flow
appleSignIn.signInWithApple()

// État
appleSignIn.isSignedIn // Bool
appleSignIn.errorMessage // String?
```

### SignInWithAppleButton (Component SwiftUI)

```swift
SignInWithAppleButton {
    // Callback après connexion réussie
    print("User signed in!")
}
```

---

## 🔐 SÉCURITÉ

### Nonce

Le nonce est généré de manière sécurisée:
1. **Génération aléatoire** avec `SecRandomCopyBytes`
2. **Hashage SHA256** avant envoi à Apple
3. **Vérification** lors du callback

### Token Handling

- **ID Token** récupéré d'Apple
- **Vérification** par Firebase
- **Credential** créé et utilisé pour l'authentification

---

## 📊 INFO.PLIST

Le fichier `GoogleService-Info.plist` contient:

```xml
<key>BUNDLE_ID</key>
<string>com.loicberthod.onykroua</string>

<key>PROJECT_ID</key>
<string>onikroua</string>

<key>CLIENT_ID</key>
<string>1038211179192-g88fkvturv7iqp2gig1o77endsshjnr9.apps.googleusercontent.com</string>

<key>API_KEY</key>
<string>AIzaSyDg4IyAHPfQFxkJ0O2NcC_4ak8NWA90HLE</string>
```

---

## ✅ CHECKLIST COMPLÈTE

### Dans le code (✅ Fait)
- [x] FirebaseManager créé
- [x] AppleSignInManager créé
- [x] LoginView créée
- [x] SignInWithAppleButton component
- [x] Firebase initialisé dans onykrouaApp
- [x] GoogleService-Info.plist copié

### Dans Xcode (⚠️ À faire manuellement)
- [ ] Ajouter Firebase via SPM
- [ ] Ajouter GoogleService-Info.plist au projet
- [ ] Activer "Sign in with Apple" capability
- [ ] Vérifier Bundle ID correspond

### Dans Firebase Console (⚠️ À faire)
- [ ] Activer Apple Sign-in
- [ ] Configurer Bundle ID et Team ID

### Dans Apple Developer (⚠️ À faire)
- [ ] Activer Sign in with Apple pour l'App ID

---

## 🚀 TEST

Une fois configuré, tester:

1. **Lancer l'app**
2. **Vérifier** que Firebase se configure (console logs)
3. **Aller dans ProfileView** ou créer une vue de test
4. **Cliquer sur "Continuer avec Apple"**
5. **Autoriser** la connexion
6. **Vérifier** que `firebaseManager.isSignedIn == true`

---

## 📚 DOCUMENTATION

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [Firebase Auth - Apple](https://firebase.google.com/docs/auth/ios/apple)
- [Sign In with Apple](https://developer.apple.com/sign-in-with-apple/)

---

**Créé avec 🔥 le 15 Janvier 2026**
