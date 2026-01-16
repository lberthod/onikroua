# 📱 Comparaison Android vs iOS - Onykroua

Guide comparatif entre les versions Android et iOS de Onykroua.

---

## 🎨 Design & Interface

| Aspect | Android | iOS |
|--------|---------|-----|
| **Framework UI** | XML + Material Design | SwiftUI |
| **Langage** | Kotlin | Swift |
| **Navigation** | Activities + Fragments | NavigationView + Sheets |
| **Composants** | RecyclerView, CardView | List, LazyVGrid, ScrollView |
| **Animations** | XML Animations | SwiftUI Animations |
| **Style** | Material Design 3 | iOS Native Design |

---

## 🏗️ Architecture

### Android
```
frontend-android/
└── app/src/main/java/com/loicberthod/onykroua/
    ├── MainActivity.kt
    ├── LoginActivity.kt
    ├── ConjugationActivity.kt
    ├── VocabularyActivity.kt
    ├── EmojiActivity.kt
    ├── ConversationActivity.kt
    ├── GrammarActivity.kt
    ├── PhoneticActivity.kt
    ├── FeedActivity.kt
    ├── ProfileActivity.kt
    └── GeminiLiveActivity.kt
```

### iOS
```
frontend-ios/onykroua/onykroua/
├── onykrouaApp.swift
├── ContentView.swift
└── Views/
    ├── FeedView.swift
    ├── ConjugationView.swift
    ├── VocabularyView.swift
    ├── EmojiView.swift
    ├── ConversationView.swift
    ├── GrammarView.swift
    ├── PhoneticView.swift
    ├── GeminiLiveView.swift
    └── ProfileView.swift
```

---

## 🚀 Déploiement

### Android (Play Store)

**Commandes:**
```bash
cd frontend-android
./gradlew clean
./gradlew bundleRelease
```

**Fichier généré:** `app-release.aab`

**Upload manuel:** Google Play Console

**Temps total:** ~10-15 minutes  
**Révision Google:** Quelques heures à 1 jour

---

### iOS (App Store)

**Commandes:**
```bash
cd frontend-ios
fastlane beta         # TestFlight
fastlane release      # App Store
```

**Automatisé:** Oui, avec fastlane

**Temps total:** ~10-15 minutes  
**Révision Apple:** 1-2 jours

---

## 🔧 Configuration & Build

### Android

**Fichier de config:** `build.gradle`
```gradle
versionCode 5
versionName "1.5"
minSdk 26
targetSdk 35
```

**Signature:**
- Keystore: `app/onykroua-release.keystore`
- Config: `keystore.properties`

**Build types:**
- Debug: `./gradlew assembleDebug`
- Release: `./gradlew bundleRelease`

---

### iOS

**Fichier de config:** `project.pbxproj`
```
MARKETING_VERSION = 1.0
CURRENT_PROJECT_VERSION = 1
IPHONEOS_DEPLOYMENT_TARGET = 16.0
```

**Signature:**
- Certificats: Gérés par fastlane Match
- Team ID: `N668CK695Q`

**Build types:**
- Debug: `⌘R` dans Xcode
- Release: `fastlane beta` ou `fastlane release`

---

## 🔑 Authentification

### Android
```kotlin
FirebaseAuth.getInstance()
auth.signInWithEmailAndPassword(email, password)
auth.currentUser?.email
```

**État actuel:** ✅ Implémenté avec Firebase

---

### iOS
```swift
// À implémenter avec Firebase
import FirebaseAuth
Auth.auth().signIn(withEmail: email, password: password)
Auth.auth().currentUser?.email
```

**État actuel:** ⚠️ Interface prête, Firebase à ajouter

---

## 🎯 Fonctionnalités

| Feature | Android | iOS | Notes |
|---------|---------|-----|-------|
| **Navigation principale** | ✅ | ✅ | Identique |
| **Conjugaison** | ✅ | ✅ | Interface adaptée |
| **Vocabulaire** | ✅ | ✅ | Flashcards flip |
| **Emoji** | ✅ | ✅ | Grid layout |
| **Conversation** | ✅ | ✅ | Chat interactif |
| **Grammaire** | ✅ | ✅ | Sections expansibles |
| **Phonétique** | ✅ | ✅ | Audio à implémenter |
| **Gemini Live** | ✅ | 🔨 | Interface prête |
| **Firebase Auth** | ✅ | ⚠️ | À ajouter |
| **Firestore** | ✅ | ⚠️ | À ajouter |
| **Audio Recording** | ✅ | ⚠️ | À ajouter |

**Légende:**
- ✅ Implémenté
- 🔨 En développement  
- ⚠️ À implémenter

---

## 📦 Dépendances

### Android (`build.gradle`)
```gradle
implementation 'com.google.firebase:firebase-auth-ktx'
implementation 'com.google.firebase:firebase-firestore-ktx'
implementation 'com.google.android.gms:play-services-auth'
implementation 'com.google.code.gson:gson'
implementation 'com.squareup.okhttp3:okhttp'
```

---

### iOS (à ajouter via CocoaPods/SPM)
```ruby
# Podfile (à créer)
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'GoogleSignIn'
```

**Installation:**
```bash
cd frontend-ios/onykroua
pod init
# Éditer Podfile
pod install
# Ouvrir .xcworkspace au lieu de .xcodeproj
```

---

## 🎨 Design Patterns

### Android
- **Pattern:** MVP / MVVM
- **Data binding:** View binding
- **Navigation:** Intent + startActivity
- **State:** Manual state management

---

### iOS
- **Pattern:** MVVM avec SwiftUI
- **Data binding:** @State, @Binding, @ObservedObject
- **Navigation:** NavigationLink, .sheet
- **State:** Déclaratif avec @State

---

## 🧪 Tests

### Android
```bash
./gradlew test           # Unit tests
./gradlew connectedCheck # Instrumented tests
```

---

### iOS
```bash
fastlane test            # Unit + UI tests
⌘U dans Xcode           # Tests interactifs
```

---

## 📊 Analytics & Monitoring

### Android
- Firebase Analytics ✅
- Crashlytics ✅
- Performance Monitoring ✅

---

### iOS (à ajouter)
- Firebase Analytics ⚠️
- Crashlytics ⚠️
- Performance Monitoring ⚠️

---

## 🔄 Migration Android → iOS

### Étapes pour compléter la parité:

1. **Ajouter Firebase iOS**
```bash
# Dans Firebase Console
# Ajouter une app iOS
# Télécharger GoogleService-Info.plist
# Placer dans onykroua/onykroua/
```

2. **Installer Firebase SDK**
```bash
cd frontend-ios/onykroua
# Option 1: CocoaPods
pod init
# Ajouter Firebase/Auth, Firebase/Firestore
pod install

# Option 2: Swift Package Manager (recommandé)
# Dans Xcode: File → Add Packages
# https://github.com/firebase/firebase-ios-sdk
```

3. **Implémenter Auth**
```swift
// LoginView.swift
import FirebaseAuth

Auth.auth().signIn(withEmail: email, password: password)
```

4. **Implémenter Gemini Live**
```swift
// GeminiLiveView.swift
import AVFoundation

AVAudioRecorder()
// Implémenter recording et API calls
```

---

## 💰 Coûts

### Android
- **Google Play Console:** 25$ (une fois)
- **Révision:** Gratuit
- **Compte:** Personnel ou Organisation

---

### iOS
- **Apple Developer:** 99$/an
- **TestFlight:** Inclus
- **Révision:** Gratuit
- **Compte:** Individuel ou Organisation

---

## 🚀 Déploiement Rapide - Résumé

### Android
```bash
cd frontend-android
./gradlew clean bundleRelease
# Upload manuel sur Play Console
```
⏱️ **Total: ~15-20 minutes**

---

### iOS
```bash
cd frontend-ios
fastlane beta  # TestFlight automatique
```
⏱️ **Total: ~10-15 minutes**

---

## 📱 Plateformes supportées

### Android
- **Minimum:** Android 8.0 (API 26)
- **Target:** Android 14 (API 35)
- **Devices:** Téléphones et tablettes
- **% utilisateurs:** ~97%

---

### iOS
- **Minimum:** iOS 16.0
- **Target:** iOS 17
- **Devices:** iPhone, iPad
- **% utilisateurs:** ~90%

---

## 🎯 Prochaines étapes iOS

### Phase 1: Firebase (Haute priorité)
- [ ] Ajouter Firebase SDK
- [ ] Implémenter Authentication
- [ ] Implémenter Firestore
- [ ] Synchroniser données avec Android

### Phase 2: Gemini Integration
- [ ] Configurer Gemini API Key
- [ ] Implémenter audio recording
- [ ] Implémenter WebSocket pour Live
- [ ] Tester conversations

### Phase 3: Features avancées
- [ ] Push notifications
- [ ] Analytics
- [ ] Crashlytics
- [ ] In-app purchases (optionnel)

### Phase 4: Polish
- [ ] Screenshots App Store
- [ ] Vidéo preview
- [ ] Tests Beta extensive
- [ ] Soumission App Store

---

## 📈 Performance

### Android
- **Build time:** ~30-60s
- **Bundle size:** ~15-20 MB
- **Startup time:** <2s

---

### iOS
- **Build time:** ~30-60s
- **App size:** ~10-15 MB
- **Startup time:** <1s

---

## 🔐 Sécurité

### Android
- Keystore protégé
- API Keys dans `local.properties` (gitignored)
- ProGuard/R8 pour obfuscation

---

### iOS
- Certificats dans Match (Git privé)
- API Keys à sécuriser (à implémenter)
- Bitcode pour optimisation

---

## 🎉 Conclusion

**Android:** Application complète et fonctionnelle  
**iOS:** Structure complète, intégrations à finaliser

**Temps pour parité complète:** ~2-3 jours de dev

**Priorités:**
1. Firebase Auth & Firestore
2. Gemini Live API
3. Tests Beta
4. Publication

---

**Version iOS prête pour développement continu! 🚀**
