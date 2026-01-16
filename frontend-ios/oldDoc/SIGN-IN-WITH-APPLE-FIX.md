# ⚠️ CORRIGER L'ERREUR SIGN IN WITH APPLE

**Erreur:** `AuthenticationServices.AuthorizationError error 1000`

Cette erreur signifie que **Sign in with Apple n'est pas activé** dans votre projet Xcode.

---

## ✅ SOLUTION - 3 ÉTAPES OBLIGATOIRES

### 1. Activer Sign in with Apple dans Xcode

1. **Ouvrir le projet** dans Xcode
2. **Sélectionner** le projet "onykroua" dans le navigateur (icône bleue)
3. **Sélectionner** le target "onykroua" dans la liste
4. **Onglet "Signing & Capabilities"**
5. **Cliquer sur "+ Capability"** (en haut à gauche)
6. **Chercher** "Sign in with Apple"
7. **Double-cliquer** pour l'ajouter
8. **Vérifier** qu'une nouvelle section "Sign in with Apple" apparaît

### 2. Configurer Apple Developer (obligatoire)

1. **Aller sur** [Apple Developer](https://developer.apple.com)
2. **Se connecter** avec votre compte développeur
3. **Menu:** Certificates, Identifiers & Profiles
4. **Cliquer sur:** Identifiers
5. **Chercher** votre App ID: `com.loicberthod.onykroua`
6. **Si l'App ID n'existe pas:**
   - Cliquer "+" pour créer
   - Type: App IDs
   - Description: Onykroua
   - Bundle ID: `com.loicberthod.onykroua`
   - Cocher "Sign in with Apple"
   - Sauvegarder

7. **Si l'App ID existe déjà:**
   - Cliquer dessus
   - **Cocher** "Sign in with Apple" dans les capabilities
   - Cliquer "Save"

### 3. Configurer Firebase Console

1. **Aller sur** [Firebase Console](https://console.firebase.google.com)
2. **Sélectionner** le projet "onikroua"
3. **Menu:** Authentication
4. **Onglet:** Sign-in method
5. **Activer** Apple
6. **Entrer les informations:**
   - **Services ID:** (optionnel pour iOS)
   - Cliquer "Save"

---

## 🔍 VÉRIFICATION

Après avoir fait ces étapes:

1. **Dans Xcode:**
   - Signing & Capabilities → "Sign in with Apple" doit être visible
   - Team: Votre équipe de développement
   - Bundle Identifier: `com.loicberthod.onykroua`

2. **Dans Apple Developer:**
   - App ID `com.loicberthod.onykroua` avec Sign in with Apple ✓

3. **Dans Firebase:**
   - Authentication → Sign-in method → Apple: Activé ✓

---

## 🚀 TEST

1. **Build & Run** dans Xcode (Cmd+R)
2. **Aller dans:** Profil
3. **Cliquer:** "Continuer avec Apple"
4. **Autoriser** la connexion
5. **Vérifier:** Nom et email apparaissent dans le profil

---

## ⚠️ ERREURS COURANTES

### Erreur 1000
**Cause:** Capability "Sign in with Apple" non activée dans Xcode  
**Solution:** Étape 1 ci-dessus

### Erreur 1001
**Cause:** Bundle ID incorrect  
**Solution:** Vérifier que le Bundle ID dans Xcode = Bundle ID dans Apple Developer

### "Aucun compte trouvé"
**Cause:** Pas de compte Apple configuré sur l'appareil  
**Solution:** Réglages → Se connecter à l'iPhone

### "Échec de l'autorisation"
**Cause:** App ID non configuré dans Apple Developer  
**Solution:** Étape 2 ci-dessus

---

## 📱 SI VOUS TESTEZ SUR UN APPAREIL PHYSIQUE

1. **Connecter** l'iPhone au Mac
2. **Xcode:** Sélectionner votre iPhone dans la liste des devices
3. **Signing & Capabilities:**
   - Team: Sélectionner votre équipe
   - "Automatically manage signing" ✓
4. **Build & Run**

---

## 💡 NOTES IMPORTANTES

### Simulateur vs Appareil réel

- ✅ **Sign in with Apple fonctionne** sur simulateur iOS 15+
- ✅ **Sign in with Apple fonctionne** sur appareil réel
- ⚠️ **MAIS** il faut un compte Apple configuré sur l'appareil

### Environnement de test

Pour tester facilement:
1. **Simulateur:** Menu → Features → Face ID → Enrolled
2. **Simulateur:** Settings → Sign in to iCloud (compte test)
3. **Appareil:** Réglages → Connexion (votre compte Apple)

---

## 🎯 CHECKLIST FINALE

Avant de tester:

- [ ] Capability "Sign in with Apple" ajoutée dans Xcode
- [ ] App ID configuré dans Apple Developer avec Sign in with Apple
- [ ] Firebase Console: Apple activé dans Authentication
- [ ] Bundle ID identique partout: `com.loicberthod.onykroua`
- [ ] Team de développement sélectionné dans Xcode
- [ ] GoogleService-Info.plist ajouté au projet
- [ ] Firebase packages ajoutés via SPM (FirebaseAuth, FirebaseCore)

---

## 📞 SI ÇA NE FONCTIONNE TOUJOURS PAS

1. **Clean Build Folder:** Cmd+Shift+K
2. **Supprimer DerivedData:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. **Relancer Xcode**
4. **Build à nouveau**

---

**Créé le 15 Janvier 2026 - Guide de résolution error 1000**
