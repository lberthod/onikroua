# Installation rapide de Google Sign-In

## 📦 Installer le package GoogleSignIn-iOS

### Dans Xcode :

1. **File** > **Add Package Dependencies...**

2. Dans la barre de recherche, colle cette URL :
   ```
   https://github.com/google/GoogleSignIn-iOS
   ```

3. Clique sur **Add Package**

4. Sélectionne **GoogleSignIn** dans la liste des produits

5. Clique sur **Add Package**

---

## ✅ Après l'installation

### Décommente les boutons Google Sign-In :

#### Dans `LoginView.swift` (lignes 50-54) :
Remplace :
```swift
// TODO: Décommenter après avoir installé GoogleSignIn-iOS via SPM
// SignInWithGoogleButton {
//     onSuccess?()
//     dismiss()
// }
```

Par :
```swift
SignInWithGoogleButton {
    onSuccess?()
    dismiss()
}
```

#### Dans `onykrouaApp.swift` (lignes 121-124) :
Remplace :
```swift
// TODO: Décommenter après avoir installé GoogleSignIn-iOS via SPM
// SignInWithGoogleButton {
//     // Action déjà gérée dans le bouton
// }
```

Par :
```swift
SignInWithGoogleButton {
    // Action déjà gérée dans le bouton
}
```

---

## 🎯 Configuration déjà faite

✅ **Info.plist** : GIDClientID configuré  
✅ **GoogleService-Info.plist** : Présent dans le projet  
✅ **URL Scheme** : REVERSED_CLIENT_ID configuré  
✅ **SignInWithGoogleButton.swift** : Composant créé  

Une fois le package installé, l'app devrait fonctionner sans crash !
