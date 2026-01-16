# 🚀 SPRINT iOS - Parité avec Android

Sprint pour implémenter toutes les fonctionnalités Android sur iOS (sauf login)

**Date:** 13 Janvier 2026  
**Objectif:** Application iOS 100% fonctionnelle comme Android

---

## 📊 Vue d'ensemble

| Fonctionnalité | Android | iOS | Statut |
|----------------|---------|-----|--------|
| Navigation principale | ✅ | ✅ | ✅ FAIT |
| Feed d'apprentissage | ✅ | ✅ | ✅ FAIT |
| Conjugaison | ✅ | ✅ | ✅ FAIT |
| Vocabulaire | ✅ | ✅ | ✅ FAIT |
| Emoji | ✅ | ✅ | ✅ FAIT |
| Conversation | ✅ | ✅ | ✅ FAIT |
| Grammaire | ✅ | ✅ | ✅ FAIT |
| Phonétique | ✅ | ✅ | ✅ FAIT |
| Gemini Live | ✅ | ✅ | ✅ FAIT (Interface) |
| Profil | ✅ | ✅ | ✅ FAIT |

---

## ✅ FAIT - Sprint 1 TERMINÉ !

- [x] Structure projet iOS
- [x] Navigation principale avec 6 catégories
- [x] Design moderne iOS avec animations
- [x] **FeedView complète** - Swipe vertical TikTok-like avec 5 types de cartes
- [x] **ConjugationView** - Tabs avec 10 verbes, temps, pratique
- [x] **VocabularyView** - Dictionnaire, catégories, flashcards flip 3D
- [x] **EmojiView** - 3 catégories, grid 3 colonnes, 18 emojis
- [x] **ConversationView** - Chat interface avec 4 scénarios
- [x] **GrammarView** - 5 règles avec sections expansibles
- [x] **PhoneticView** - 8 règles de prononciation avec exemples
- [x] **GeminiLiveView** - Interface moderne avec waveform animation
- [x] **ProfileView** - Stats, paramètres, succès
- [x] Toutes les animations SwiftUI fluides
- [x] Données réelles italiennes

---

## 🎯 DÉTAILS IMPLÉMENTÉS

### 1. Feed d'apprentissage (FeedView)
**Android:** Swipe vertical avec cartes (TikTok-like)
- [ ] Créer FeedItem model
- [ ] Implémenter scroll vertical avec cartes
- [ ] Ajouter vocabulaire daily
- [ ] Ajouter conjugaison du jour
- [ ] Ajouter expressions idiomatiques
- [ ] Like / Bookmark fonctionnels
- [ ] Text-to-Speech pour prononciation

**Fichiers Android:** 
- `FeedActivity.kt` - ViewPager2 vertical
- `feed/FeedItem.kt` - Modèle
- `feed/FeedService.kt` - Génération contenu
- `feed/FeedPagerAdapter.kt` - Adapter

**iOS à créer:**
- Remplacer FeedView temporaire
- TabView avec scroll vertical
- FeedCard component
- Audio playback

---

### 2. Conjugaison (ConjugationView)
**Android:** Tabs (Règles, Verbes, Temps, Pratique, Plus)
- [ ] Implémenter TabView avec 5 sections
- [ ] Section Règles: Règles de conjugaison IT
- [ ] Section Verbes: Liste 50+ verbes communs
- [ ] Section Temps: Présent, Passé, Futur, Imparfait
- [ ] Section Pratique: Quiz interactif
- [ ] Text-to-Speech pour prononciation
- [ ] Données Verb.kt (45KB de verbes!)

**Fichiers Android:**
- `ConjugationActivity.kt` - ViewPager avec tabs
- `Verb.kt` - 45KB de données verbes!
- `conjugation/` - 7 fichiers fragments

**iOS à créer:**
- Système de tabs
- Liste verbes scrollable
- Conjugaison interactive
- Quiz practice mode

---

### 3. Vocabulaire (VocabularyView)
**Android:** Tabs (Dictionnaire, Catégories, Pratique)
- [ ] Implémenter TabView avec 3 sections
- [ ] Dictionnaire: Liste A-Z mots
- [ ] Catégories: Salutations, Nourriture, Famille, etc.
- [ ] Pratique: Flashcards avec flip
- [ ] Text-to-Speech
- [ ] Charger vocabulary_it.json (assets)

**Fichiers Android:**
- `VocabularyActivity.kt` - 3 tabs
- `vocabulary/` - 6 fichiers
- `vocabulary_it.json` - Données

**iOS à créer:**
- Dictionary view avec search
- Categories grid
- Flashcards interactives avec flip 3D
- Practice mode

---

### 4. Emoji (EmojiView)
**Android:** Catégories + Grid d'emojis avec prononciation
- [ ] Catégories: Émotions, Actions, Objets, etc.
- [ ] Grid 3 colonnes
- [ ] Tap pour prononcer
- [ ] Afficher traduction FR
- [ ] Text-to-Speech

**Fichiers Android:**
- `EmojiActivity.kt` - 212 lignes
- `emoji/EmojiData.kt` - Données
- `emoji/EmojiWord.kt` - Model

**iOS à créer:**
- Categories horizontal scroll
- LazyVGrid 3 colonnes
- Tap to speak
- Emoji cards animées

---

### 5. Conversation (ConversationView)
**Android:** Chat avec scénarios prédéfinis
- [ ] Interface chat (bubbles)
- [ ] Scénarios: Restaurant, Hôtel, Gare, etc.
- [ ] Messages prédéfinis
- [ ] Input text pour réponses
- [ ] Afficher traductions

**Fichiers Android:**
- `ConversationActivity.kt` - 15KB
- `conversation/` - 2 fichiers

**iOS à créer:**
- Chat UI avec ScrollView
- Message bubbles (user/bot)
- Scenarios selector
- Text input field

---

### 6. Grammaire (GrammarView)
**Android:** Tabs (Règles, Exemples, Exercices)
- [ ] Articles (il, la, i, le, etc.)
- [ ] Prépositions
- [ ] Pronoms
- [ ] Adjectifs
- [ ] Sections expansibles
- [ ] Exemples contextuels

**Fichiers Android:**
- `GrammarActivity.kt` - 12KB
- `grammar/` - 3 fichiers

**iOS à créer:**
- Tabbed interface
- Expandable sections
- Grammar rules avec exemples
- Interactive exercises

---

### 7. Phonétique (PhoneticView)
**Android:** Lettres + Prononciation + Exemples
- [ ] Alphabet italien
- [ ] Règles de prononciation
- [ ] C/G devant voyelles
- [ ] GL, GN, SC
- [ ] Exemples audio
- [ ] Text-to-Speech

**Fichiers Android:**
- `PhoneticActivity.kt` - 15KB
- `phonetic/` - 2 fichiers

**iOS à créer:**
- Letter cards
- Pronunciation rules
- Audio examples
- Interactive practice

---

### 8. Profil (ProfileView)
**Android:** Stats + Paramètres
- [ ] Photo profil
- [ ] Email (sans auth)
- [ ] Statistiques: mots appris, temps, etc.
- [ ] Succès/badges
- [ ] Paramètres langue
- [ ] Dark mode toggle
- [ ] Bouton déconnexion (sans Firebase)

**Fichiers Android:**
- `ProfileActivity.kt` - 5KB

**iOS à créer:**
- Profile header
- Stats cards
- Settings list
- Achievement badges

---

## ⏳ TODO - Sprint 2

### 9. Gemini Live (Interface uniquement)
- [ ] UI conversation IA
- [ ] Bouton micro
- [ ] Waveform animation
- [ ] Transcription display
- [ ] Note: API Gemini pas implémentée (OK)

---

## 📦 Données à porter

### Assets nécessaires
- `vocabulary_it.json` - Vocabulaire complet
- `Verb.kt` données - 45KB verbes
- `EmojiData.kt` - Emojis catégorisés
- `GrammarRules` - Règles grammaire
- `PhoneticRules` - Règles phonétique

### Models à créer
```swift
struct VocabularyWord {
    let italian: String
    let french: String
    let category: String
    let example: String?
}

struct Verb {
    let infinitive: String
    let conjugations: [String: [String]] // tense -> forms
}

struct EmojiItem {
    let emoji: String
    let italian: String
    let french: String
    let category: String
}

struct GrammarRule {
    let title: String
    let explanation: String
    let examples: [String]
}
```

---

## 🎯 Priorités

1. **P0 (Critique):** Feed, Vocabulaire, Conjugaison
2. **P1 (Important):** Emoji, Conversation, Grammaire
3. **P2 (Nice to have):** Phonétique, Gemini Live

---

## 🔧 Détails techniques iOS

### Text-to-Speech
```swift
import AVFoundation

let synthesizer = AVSpeechSynthesizer()
let utterance = AVSpeechUtterance(string: "Ciao")
utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
synthesizer.speak(utterance)
```

### TabView iOS
```swift
TabView {
    View1().tabItem { Label("Tab1", systemImage: "icon") }
    View2().tabItem { Label("Tab2", systemImage: "icon") }
}
```

### Données JSON
```swift
if let url = Bundle.main.url(forResource: "vocabulary_it", withExtension: "json") {
    let data = try Data(contentsOf: url)
    let words = try JSONDecoder().decode([VocabularyWord].self, from: data)
}
```

---

## ✅ Checklist avant déploiement

- [ ] Toutes les vues fonctionnelles
- [ ] Text-to-Speech sur toutes les vues
- [ ] Navigation fluide
- [ ] Pas de crashes
- [ ] Données chargées correctement
- [ ] Animations fluides
- [ ] Design cohérent
- [ ] Testé sur iPhone physique
- [ ] Archive Xcode réussie

---

## 📈 Métriques de succès

- ✅ 100% des fonctionnalités Android portées
- ✅ Temps de chargement < 2s
- ✅ 0 crashes
- ✅ UI/UX identique ou meilleure
- ✅ Performance fluide (60fps)

---

## 🚀 Timeline

- **Jour 1:** Feed + Vocabulaire + Conjugaison (ce sprint)
- **Jour 2:** Emoji + Conversation + Grammaire
- **Jour 3:** Phonétique + Profil + Polish
- **Jour 4:** Tests + Debug + Deploy TestFlight

---

**Status:** 🔨 EN COURS
**Prochaine tâche:** Implémenter FeedView complète
