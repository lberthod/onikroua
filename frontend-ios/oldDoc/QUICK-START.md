# ⚡ Quick Start - Déploiement iOS

Guide ultra-rapide pour déployer Onykroua sur iOS.

---

## 🎯 Setup initial (une seule fois)

```bash
cd /Users/berthod/Desktop/onykroua/frontend-ios

# 1. Installer les dépendances
bundle install

# 2. Configurer fastlane
fastlane init

# 3. Synchroniser les certificats
fastlane match development
fastlane match appstore
```

---

## 🚀 Déployer en 1 commande

### TestFlight (tests)

```bash
cd /Users/berthod/Desktop/onykroua/frontend-ios
fastlane beta
```

⏱️ **5-10 minutes** → App disponible sur TestFlight

### App Store (production)

```bash
cd /Users/berthod/Desktop/onykroua/frontend-ios
fastlane release
```

⏱️ **10-15 minutes** → App soumise à Apple

---

## 📱 Développement local

```bash
# Ouvrir dans Xcode
cd /Users/berthod/Desktop/onykroua/frontend-ios
open onykroua/onykroua.xcodeproj

# Connecter iPhone → Sélectionner comme destination → ▶️ Run
```

---

## 🔧 Configuration requise

**Dans Xcode:**
1. Signing & Capabilities → Team: `N668CK695Q`
2. Bundle ID: `com.onykroua.app`
3. iPhone connecté et déverrouillé

**Apple ID:**
- `loic.berthod@onykroua.com`
- Mot de passe spécifique app (dans `fastlane/.env.default`)

---

## 📊 Structure du projet

```
frontend-ios/
├── onykroua/                    # Projet Xcode
│   ├── onykroua/
│   │   ├── onykrouaApp.swift   # Point d'entrée
│   │   ├── ContentView.swift    # Vue principale
│   │   └── Views/               # Toutes les vues
│   │       ├── FeedView.swift
│   │       ├── ConjugationView.swift
│   │       ├── VocabularyView.swift
│   │       ├── EmojiView.swift
│   │       ├── ConversationView.swift
│   │       ├── GrammarView.swift
│   │       ├── PhoneticView.swift
│   │       ├── GeminiLiveView.swift
│   │       └── ProfileView.swift
│   └── onykroua.xcodeproj/
├── fastlane/                    # Config déploiement
│   ├── Fastfile                 # Lanes de déploiement
│   ├── Appfile                  # Config app
│   └── .env.default             # Variables d'env
├── Gemfile                      # Dépendances Ruby
├── DEPLOY-GUIDE.md             # Guide complet
└── QUICK-START.md              # Ce fichier
```

---

## 🎨 Fonctionnalités implémentées

✅ **Navigation principale** avec 6 catégories  
✅ **Conjugaison** interactive des verbes italiens  
✅ **Vocabulaire** avec flashcards flip animées  
✅ **Emoji** pour apprendre les émotions  
✅ **Conversation** chat interactif  
✅ **Grammaire** avec sections expansibles  
✅ **Phonétique** avec exemples audio  
✅ **Gemini Live** conversation IA (interface)  
✅ **Profil** utilisateur  
✅ **Design moderne** iOS 2026 avec animations

---

## ⚡ Commandes essentielles

```bash
# Déployer sur TestFlight
fastlane beta

# Déployer sur App Store
fastlane release

# Build local
fastlane dev

# Screenshots automatiques
fastlane screenshots

# Sync certificats
fastlane sync_certificates
```

---

## 🔄 Workflow de développement

```bash
# 1. Coder dans Xcode
open onykroua/onykroua.xcodeproj

# 2. Tester localement (⌘R)

# 3. Déployer TestFlight
fastlane beta

# 4. Tests équipe

# 5. Production
fastlane release
```

---

## 📱 Différences iOS vs Android

| Feature | Android | iOS |
|---------|---------|-----|
| **Framework** | Kotlin + XML | SwiftUI |
| **Navigation** | Activities | NavigationView |
| **Auth** | Firebase Auth | À implémenter |
| **Déploiement** | `./gradlew bundleRelease` | `fastlane beta` |
| **Store** | Play Store | App Store + TestFlight |
| **Temps deploy** | ~10min | ~10min |
| **Révision** | Quelques heures | 1-2 jours |

---

## 🆘 Aide rapide

**App ne compile pas?**
```bash
# Nettoyer
⌘⇧K dans Xcode
# Rebuild
⌘B
```

**Certificat manquant?**
```bash
fastlane match appstore --force
```

**Fastlane erreur?**
```bash
bundle update fastlane
bundle install
```

---

## 📖 Documentation complète

Voir `DEPLOY-GUIDE.md` pour le guide détaillé complet.

---

**🚀 Prêt à déployer!**
