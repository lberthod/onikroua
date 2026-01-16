# Configuration Google Sign-In pour iOS

## Prérequis

### 1. Installation de la dépendance GoogleSignIn

Ajoutez le package Swift GoogleSignIn à votre projet Xcode :

1. Dans Xcode, allez dans **File > Add Package Dependencies...**
2. Entrez l'URL : `https://github.com/google/GoogleSignIn-iOS`
3. Sélectionnez la version **7.0.0** ou plus récente
4. Cliquez sur **Add Package**

### 2. Configuration Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet **onykroua**
3. Dans **Authentication**, activez le fournisseur **Google** :
   - Cliquez sur **Sign-in method**
   - Activez **Google**
   - Renseignez l'email de support
   - Sauvegardez

### 3. Configuration Google Cloud Console

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionnez votre projet Firebase
3. Dans **APIs & Services > Credentials** :
   - Créez un **OAuth 2.0 Client ID** pour iOS
   - Type : **iOS**
   - Bundle ID : `com.yourcompany.onykroua` (remplacez par votre vrai Bundle ID)
   - Téléchargez le fichier de configuration

### 4. Configuration Xcode

#### A. Télécharger GoogleService-Info.plist mis à jour

1. Dans Firebase Console, téléchargez le nouveau `GoogleService-Info.plist`
2. Remplacez l'ancien fichier dans Xcode

#### B. Configurer l'URL Scheme

1. Dans Xcode, sélectionnez votre target **onykroua**
2. Allez dans l'onglet **Info**
3. Développez **URL Types**
4. Ajoutez un nouveau URL Scheme :
   - **Identifier** : `com.googleusercontent.apps.Y1038211179192-g88fkvturv7iqp2gig1o77endsshjnr9`
   - **URL Schemes** : Collez le `REVERSED_CLIENT_ID` trouvé dans `GoogleService-Info.plist`
   - Exemple : `com.googleusercontent.apps.123456789-abcdefg`

### 5. Initialisation dans AppDelegate

Ajoutez cette ligne dans `onykrouaApp.swift` :

```swift
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        // Configuration Google Sign-In
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("⚠️ Google Sign-In restore error: \(error.localizedDescription)")
                return
            }
            if let user = user {
                print("✅ Google Sign-In: User restored - \(user.userID ?? "unknown")")
            }
        }
        
        print("✅ Firebase configured via AppDelegate")
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
```

### 6. Vérification

Lancez l'application et testez :
1. Cliquez sur "Continuer avec Google"
2. Sélectionnez un compte Google
3. Autorisez l'accès
4. Vérifiez que l'utilisateur est connecté

## Fichiers modifiés

- ✅ `/Views/Auth/SignInWithGoogleButton.swift` (créé)
- ✅ `/Views/Auth/LoginView.swift` (ajout du bouton)
- ✅ `/onykrouaApp.swift` (ajout du bouton dans AuthSelectionView)

## Dépannage

### Erreur "No client ID found"
- Vérifiez que `GoogleService-Info.plist` est bien dans le projet
- Vérifiez que le Bundle ID correspond

### Erreur "URL Scheme not found"
- Vérifiez que le REVERSED_CLIENT_ID est bien ajouté dans URL Types

### L'authentification ne fonctionne pas
- Vérifiez que Google est activé dans Firebase Authentication
- Vérifiez les logs dans la console Xcode
