# 🔐 Activer l'Authentification Firebase

**Objectif:** Activer Email/Password et Anonyme dans Firebase Console

---

## ⚠️ CONFIGURATION REQUISE DANS FIREBASE CONSOLE

### Étape 1: Accéder à Firebase Console

1. **Aller sur** [Firebase Console](https://console.firebase.google.com)
2. **Se connecter** avec votre compte Google
3. **Sélectionner** le projet "onikroua"

### Étape 2: Activer Email/Password

1. **Menu latéral:** Authentication
2. **Onglet:** Sign-in method
3. **Trouver:** Email/Password
4. **Cliquer** sur la ligne "Email/Password"
5. **Toggle:** Activer "Email/Password"
6. **Toggle:** Activer "Email link (passwordless sign-in)" (optionnel)
7. **Cliquer:** Save

✅ **Résultat:** Vous pouvez maintenant créer des comptes et vous connecter avec email/mot de passe

### Étape 3: Activer Anonymous

1. **Toujours dans:** Authentication → Sign-in method
2. **Trouver:** Anonymous
3. **Cliquer** sur la ligne "Anonymous"
4. **Toggle:** Activer
5. **Cliquer:** Save

✅ **Résultat:** Les utilisateurs peuvent se connecter en mode invité sans compte

### Étape 4: Activer Apple (déjà fait normalement)

1. **Toujours dans:** Authentication → Sign-in method
2. **Trouver:** Apple
3. **Cliquer** sur la ligne "Apple"
4. **Toggle:** Activer
5. **Cliquer:** Save

---

## 📋 VÉRIFICATION

Après configuration, vous devriez voir dans **Sign-in method**:

| Provider | Status |
|----------|--------|
| Email/Password | ✅ Enabled |
| Anonymous | ✅ Enabled |
| Apple | ✅ Enabled |

---

## 🎯 MÉTHODES DE CONNEXION DISPONIBLES

### 1. Sign In with Apple (OAuth)
- **Avantages:** Sécurisé, rapide, natif iOS
- **Utilisation:** Utilisateurs avec compte Apple
- **Code:**
```swift
try await firebaseManager.signInWithApple(idToken:nonce:fullName:)
```

### 2. Email/Password
- **Avantages:** Universel, contrôle total
- **Utilisation:** Création de compte personnalisé
- **Code:**
```swift
// Créer un compte
try await firebaseManager.createAccount(email:password:)

// Se connecter
try await firebaseManager.signInWithEmail(email:password:)
```

### 3. Anonymous
- **Avantages:** Pas besoin de compte, conversion possible
- **Utilisation:** Utilisateurs qui veulent essayer l'app
- **Code:**
```swift
try await firebaseManager.signInAnonymously()
```

---

## 🔄 CONVERSION ANONYMOUS → COMPTE RÉEL

Un utilisateur anonyme peut plus tard créer un compte:

```swift
// Lier un email/password à un compte anonyme
let credential = EmailAuthProvider.credential(withEmail: email, password: password)
try await Auth.auth().currentUser?.link(with: credential)
```

---

## 📱 DANS L'APPLICATION

### OnboardingView (dernière page)

Affiche 4 options:
1. **🍎 Continuer avec Apple** (noir)
2. **✉️ Continuer avec Email** (bleu)
3. **👤 Continuer en mode invité** (gris)
4. **Passer** (texte gris)

### ProfileView (non connecté)

Affiche 3 options:
1. **🍎 Continuer avec Apple**
2. **✉️ Connexion avec Email**
3. **👤 Mode invité**

### EmailSignInView

Modal avec:
- Champs Email et Mot de passe
- Toggle "Se connecter" / "Créer un compte"
- Validation (6+ caractères)
- Messages d'erreur clairs

---

## 🔒 SÉCURITÉ

### Règles de mot de passe
- **Minimum:** 6 caractères (Firebase)
- **Recommandé:** 8+ caractères avec majuscules/chiffres
- Peut être renforcé dans le code

### Validation d'email
Firebase envoie automatiquement un email de vérification (optionnel):
```swift
try await Auth.auth().currentUser?.sendEmailVerification()
```

### Anonyme → Compte
Les données peuvent être conservées lors de la conversion

---

## 📊 ANALYTICS

Firebase Auth track automatiquement:
- Nombre de sign-ups par méthode
- Nombre de sign-ins
- Utilisateurs actifs
- Taux de conversion anonymous → réel

**Voir:** Firebase Console → Analytics → Events

---

## ⚠️ LIMITES FIREBASE

### Plan Gratuit (Spark)
- ✅ Auth illimité
- ✅ 10K vérifications/mois
- ✅ 1GB stockage
- ✅ 10GB transfert/mois

### Plan Blaze (Pay as you go)
- ✅ Tout illimité
- 💰 $0.06/auth après 50K/mois

---

## 🧪 TEST

### Tester Email/Password
1. Lancer l'app
2. Onboarding → "Continuer avec Email"
3. "Créer un compte"
4. Email: test@onykroua.com
5. Password: test123456
6. Vérifier connexion réussie

### Tester Anonymous
1. Lancer l'app
2. Onboarding → "Continuer en mode invité"
3. Vérifier connexion instantanée
4. ProfileView → doit afficher "Invité"

### Vérifier dans Firebase Console
1. Authentication → Users
2. Voir les comptes créés
3. Vérifier Provider (Apple/Email/Anonymous)

---

## 🎉 RÉSULTAT FINAL

**3 méthodes de connexion actives:**
- ✅ Apple Sign In (OAuth sécurisé)
- ✅ Email/Password (universel)
- ✅ Anonymous (test facile)

**Expérience utilisateur:**
- Onboarding fluide avec choix
- ProfileView avec état dynamique
- Conversion anonymous → compte possible

---

**Créé le 15 Janvier 2026**
