# 🗣️ Onikroua iOS

**Application iOS complète d'apprentissage de l'italien** avec système de gamification avancé, exercices interactifs, révisions adaptatives (SRS) et analytics personnalisés.

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

---

## ✨ Caractéristiques Principales

### 📚 Contenu Pédagogique Massif
- ✅ **24 scénarios** conversationnels (voyage, quotidien, professionnel, social, urgences, culture)
- ✅ **80+ verbes** italiens avec conjugaisons complètes (7 temps)
- ✅ **60+ règles** de grammaire structurées par catégories
- ✅ **40,000+ mots** de vocabulaire thématique (50+ catégories)
- ✅ **30 achievements** gamifiés avec système de progression
- ✅ **6 niveaux CEFR** (A1 → C2) avec évaluation initiale

### 🎮 Système d'Apprentissage Complet

#### Quiz Interactifs (6 types)
- 📝 **Vocabulaire** - Traduction avec exemples
- ✏️ **Conjugaison** - Verbes à tous les temps
- 📖 **Grammaire** - Règles avec cas pratiques
- 🔄 **Traduction** - Phrases complètes IT ↔ FR
- 💬 **Conversation** - Dialogues contextualisés
- 🎧 **Écoute** - Compréhension audio (prêt pour intégration)

#### Exercices Pratiques (3 types)
- 🎴 **Flashcards** - Cartes mémoire swipeable avec animation 3D
- 📝 **Texte à trous** - 4 options de réponse avec feedback immédiat
- 🔗 **Associations** - Matching vocabulaire/conjugaisons

#### Révisions Adaptatives (SRS)
- 🧠 **SuperMemo SM-2** - Algorithme de répétition espacée
- 📦 **Système Leitner** - Alternative par boîtes (6 niveaux)
- 🎯 **Priorisation intelligente** - Mix urgent/faible/nouveau/apprentissage
- 📊 **8 niveaux de maîtrise** - New → Mastered (1j → 180j)

#### Analytics & Insights
- 💡 **6 types d'insights** personnalisés (force, faiblesse, amélioration, jalon, warning, suggestion)
- 🎯 **Recommandations prioritaires** (critique → suggéré)
- 📈 **5 domaines de compétences** analysés
- 🔮 **Prédiction de jalons** avec niveau de confiance
- 📊 **Patterns d'étude** avec recommandations

### 🎨 Interface & Navigation

#### Navigation TabBar (5 onglets)
- 🏠 **Accueil** - Dashboard avec quick actions, streak, objectif du jour
- 💪 **Pratique** - Hub d'exercices (flashcards, quiz, associations)
- 📚 **Vocabulaire** - 40K+ mots organisés par catégories
- 📊 **Progression** - Stats, graphiques, achievements, niveau CEFR
- 👤 **Profil** - Stats utilisateur, badges, settings

#### Onboarding Complet (6 étapes)
1. Welcome - Introduction
2. Langue - Italien/Espagnol
3. Objectifs - Voyage, travail, culture...
4. Niveau - Auto-évaluation
5. Rythme - 5-60 min/jour
6. Permissions - Notifications

#### Test de Niveau
- 10 questions adaptées
- Évaluation CEFR (A1 → C2)
- Résultat instantané avec description

### 🏆 Gamification

#### Système XP
- Quiz: 10 XP/question correcte
- Exercice: 5 XP/item
- Conversation: 50 XP
- Objectif quotidien: 100 XP
- Milestones: 50-500 XP

#### Progression
- 20 niveaux avec seuils XP
- 30 achievements débloquables
- Système de streak (série de jours)
- Animations et confetti

---

## ⚡ Déploiement Ultra-Rapide

### TestFlight (en 1 commande)
```bash
cd /Users/berthod/Desktop/onykroua/frontend-ios
fastlane beta
```
⏱️ **5-10 minutes** → App sur TestFlight

### App Store (en 1 commande)
```bash
fastlane release
```
⏱️ **10-15 minutes** → App soumise à Apple

📖 **Guides détaillés:**
- [`IMPLEMENTATION.md`](IMPLEMENTATION.md) - Documentation technique complète
- [`DEPLOY-GUIDE.md`](DEPLOY-GUIDE.md) - Guide de déploiement
- [`COMPARAISON-ANDROID-iOS.md`](COMPARAISON-ANDROID-iOS.md) - Comparaison Android/iOS

---

## 🏗️ Architecture Technique

### Stack Technologique
- **Framework:** SwiftUI 5.0
- **Persistence:** SwiftData
- **Minimum iOS:** 17.0+
- **Language:** Swift 5.9
- **Architecture:** MVVM + Services
- **Async:** async/await, Combine

### Structure Projet
```
onykroua/
├── Models/              # Données et structures
│   ├── QuizModels.swift (395 lignes)
│   ├── ExerciseModels.swift (367 lignes)
│   ├── ConversationModels.swift (427 lignes)
│   ├── VerbData.swift (945 lignes - 80+ verbes)
│   ├── GrammarData.swift (438 lignes - 60+ règles)
│   └── VocabularyModels.swift
│
├── Services/            # Logique métier
│   ├── GamificationManager.swift
│   ├── AdaptiveReviewSystem.swift (450+ lignes)
│   ├── AdvancedAnalyticsService.swift (500+ lignes)
│   ├── LevelAssessmentService.swift
│   └── NotificationManager.swift
│
├── Views/               # Interface SwiftUI
│   ├── AppRootView.swift
│   ├── MainTabView.swift
│   ├── Quiz/ (Selection, Game, Results)
│   ├── Practice/ (Hub, Flashcards, FillBlank, Matching, Review)
│   ├── Conversation/ (Practice, Detail)
│   ├── Analytics/ (Insights)
│   ├── Profile/ (Profile, Settings)
│   └── Onboarding/ (6 écrans)
│
├── Utilities/           # Helpers
│   ├── Extensions.swift (300+ lignes)
│   └── AppError.swift
│
└── Data/
    └── vocabulary_it.json (40,468 lignes)
```

### Services Principaux

#### GamificationManager
- Gestion XP et niveaux
- Déblocage achievements
- Calcul streaks
- Système de récompenses

#### AdaptiveReviewSystem
- Algorithme SuperMemo SM-2
- Système Leitner alternatif
- Priorisation items à réviser
- Statistiques de performance

#### AdvancedAnalyticsService
- Insights personnalisés
- Recommandations prioritaires
- Analyse compétences
- Prédiction progression

---

## 📱 Installation

### Prérequis
- macOS avec Xcode 15.0 ou plus récent
- iPhone ou iPad avec iOS 16.0 ou plus récent

### Étapes de déploiement

1. **Ouvrir le projet**
   ```bash
   cd frontend-ios/onykroua
   open onykroua.xcodeproj
   ```

2. **Configuration dans Xcode**
   - Sélectionnez votre équipe de développement dans "Signing & Capabilities"
   - Connectez votre iPhone via USB
   - Sélectionnez votre iPhone comme destination dans la barre d'outils Xcode

3. **Sur votre iPhone** (première fois uniquement)
   - Allez dans Réglages → Général → Gestion des profils
   - Faites confiance au certificat de développeur

4. **Lancer l'app**
   - Cliquez sur le bouton ▶️ dans Xcode
   - L'app se compile et s'installe sur votre iPhone

## 🎨 Structure du Projet

```
onykroua/
├── onykroua.xcodeproj/          # Configuration Xcode
└── onykroua/
    ├── onykrouaApp.swift        # Point d'entrée de l'app
    ├── ContentView.swift        # Interface principale
    └── Assets.xcassets/         # Ressources (icônes, couleurs)
```

## 💻 Développement

### Modifier l'interface

Éditez `onykroua/ContentView.swift` pour personnaliser l'UI. Utilisez le preview en temps réel dans Xcode avec `⌥⌘P`.

### Ajouter des fonctionnalités

1. Créez de nouveaux fichiers Swift dans le dossier `onykroua/`
2. Importez-les dans votre vue principale
3. Compilez avec `⌘B` pour vérifier les erreurs

## 🛠️ Build & Release

### Build de debug
```bash
xcodebuild -project onykroua.xcodeproj -scheme onykroua -configuration Debug
```

### Archive pour TestFlight/App Store
1. Product → Archive dans Xcode
2. Suivez l'assistant pour uploader vers App Store Connect

## 📄 Configuration

- **Bundle ID** : `com.onykroua.app`
- **Version** : 1.0
- **Target iOS** : 16.0+
- **Orientations** : Portrait & Landscape

## 🎯 Fonctionnement de l'App

### Compteur
- **+** : Incrémente de 1
- **−** : Décrémente de 1
- **↻** : Réinitialise à 0

### Timer
- **Start/Pause** : Démarre ou met en pause le chronomètre
- **Reset** : Remet à zéro et arrête le timer

## 🐛 Dépannage

**L'app ne se lance pas sur l'iPhone ?**
- Vérifiez que l'iPhone est bien déverrouillé
- Assurez-vous que le certificat est approuvé dans les réglages

**Erreur de signature ?**
- Sélectionnez votre compte Apple dans Xcode → Preferences → Accounts
- Dans le projet, choisissez "Automatically manage signing"

**Preview ne fonctionne pas ?**
- Utilisez `⌥⌘P` pour rafraîchir le preview
- Vérifiez qu'il n'y a pas d'erreurs de compilation

## 📱 Test sur Simulateur

Si vous n'avez pas d'iPhone physique :
```
1. Ouvrez Xcode
2. Choisissez un simulateur iPhone dans la barre d'outils
3. Cliquez sur ▶️
```

## 🔄 Mises à jour

Pour mettre à jour l'app :
1. Modifiez le code
2. Incrémentez la version dans project.pbxproj
3. Relancez depuis Xcode

## 📞 Support

Pour toute question sur le développement iOS avec SwiftUI, consultez :
- [Documentation SwiftUI](https://developer.apple.com/documentation/swiftui/)
- [Forums Apple Developer](https://developer.apple.com/forums/)

---

**Créé avec ❤️ pour Onykroua - Janvier 2026**
