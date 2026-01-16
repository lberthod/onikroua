# 🚀 SPRINT TODO - Synchronisation iOS ↔️ Android

**Date:** 13 Janvier 2026  
**Objectif:** Rendre l'application iOS 100% similaire à Android en fonctionnalités et contenu

---

## 📊 État Actuel des Vues

| Vue | iOS Actuel | Android | Gap | Priorité |
|-----|-----------|---------|-----|----------|
| **FeedView** | Liste simple | Swipe vertical TikTok-like | ⚠️ ÉLEVÉ | P0 |
| **EmojiView** | 3 catégories, ~25 emojis | 35+ catégories, 500+ emojis | ⚠️ ÉLEVÉ | P0 |
| **ConversationView** | Chat basique | 4 scénarios prédéfinis | ⚠️ MOYEN | P1 |
| **GrammarView** | 4 règles simples | Contenu enrichi | ⚠️ MOYEN | P1 |
| **PhoneticView** | 6 règles | 15+ règles détaillées | ⚠️ MOYEN | P1 |
| **VocabularyView** | ✅ Complet | ✅ Complet | ✅ OK | - |
| **ConjugationView** | ✅ Complet | ✅ Complet | ✅ OK | - |
| **ProfileView** | ✅ Riche | ✅ Standard | ✅ OK | - |
| **GeminiLiveView** | Interface basique | Interface + Animation | ⚠️ BAS | P2 |

---

## 🎯 SPRINT BACKLOG

### ✅ TÂCHE 1: Améliorer FeedView (P0 - CRITIQUE)

**Objectif:** Swipe vertical TikTok-like avec types de cartes variées

**Fonctionnalités Android à porter:**
- ViewPager2 vertical → TabView/ScrollView vertical iOS
- 5 types de cartes:
  - Vocabulaire du jour
  - Conjugaison du jour
  - Expression idiomatique
  - Culture italienne
  - Quiz interactif
- Boutons Like/Bookmark
- Text-to-Speech pour prononciation
- Pagination infinie (charger 10 items par page)
- Support Italien ET Espagnol

**Fichiers à créer/modifier:**
- `Views/FeedView.swift` - Remplacer complètement
- `Models/FeedModels.swift` - Nouveau
- `Services/FeedService.swift` - Nouveau

**Estimation:** 2-3h

---

### ✅ TÂCHE 2: Enrichir EmojiView avec 35+ catégories (P0 - CRITIQUE)

**Objectif:** Porter toutes les catégories d'emojis d'Android vers iOS

**Catégories Android à ajouter (35 total):**
1. ✅ Émotions (20 emojis)
2. ✅ Actions (15)
3. ✅ Nourriture (25)
4. ➕ Animaux (24)
5. ➕ Nature (19)
6. ➕ Transports (13)
7. ➕ Objets (18)
8. ➕ Sports (12)
9. ➕ Lieux (13)
10. ➕ Corps (12)
11. ➕ Métiers (11)
12. ➕ Temps (10)
13. ➕ Vêtements (10)
14. ➕ Couleurs (10)
15. ➕ Famille (10)
16. ➕ Maison (10)
17. ➕ École (10)
18. ➕ Ville (8)
19. ➕ Loisirs (9)
20. ➕ Technologie (9)
21. ➕ Météo (8)
22. ➕ Fêtes (8)
23. ➕ Nombres (15)
24. ➕ Calendrier (24)
25. ➕ Sentiments (14)
26. ➕ Adjectifs Utiles (20)
27. ➕ Verbes Essentiels (18)
28. ➕ Expressions Courantes (20)
29. ➕ Cuisine (18)
30. ➕ Santé & Bien-être (15)
31. ➕ Voyage & Tourisme (15)
32. ➕ Argent & Shopping (15)
33. ➕ Communication (15)
34. ➕ Géographie & Pays (15)
35. ➕ Musique & Arts (15)

**Total:** ~500 emojis (vs 25 actuels)

**Fichiers à modifier:**
- `Views/EmojiView.swift` - Ajouter toutes les catégories
- `Models/EmojiModels.swift` - Nouveau fichier pour données

**Estimation:** 1-2h

---

### ✅ TÂCHE 3: Améliorer ConversationView avec scénarios (P1)

**Objectif:** Ajouter 4 scénarios de conversation prédéfinis

**Scénarios Android:**
1. 🍽️ **Restaurant**
   - Réserver une table
   - Commander
   - Demander l'addition
   
2. 🏨 **Hôtel**
   - Réserver une chambre
   - Check-in/out
   - Services
   
3. 🚂 **Gare**
   - Acheter un billet
   - Demander directions
   - Horaires
   
4. 🏪 **Shopping**
   - Demander prix
   - Essayer vêtements
   - Paiement

**Fonctionnalités:**
- Sélecteur de scénarios en haut
- Messages prédéfinis par scénario
- Réponses automatiques contextuelles
- Traductions FR affichées

**Fichiers à modifier:**
- `Views/ConversationView.swift` - Enrichir
- `Models/ConversationModels.swift` - Nouveau

**Estimation:** 1h

---

### ✅ TÂCHE 4: Enrichir GrammarView (P1)

**Objectif:** Ajouter plus de règles de grammaire avec exemples

**Contenu Android à porter:**
1. **Articles définis**
   - Masculin: il, lo, i, gli
   - Féminin: la, le
   - Exemples contextuels
   
2. **Prépositions simples**
   - di, a, da, in, con, su, per, tra/fra
   - Contractions (del, al, dal, etc.)
   
3. **Prépositions articulées**
   - Tableau complet avec contractions
   
4. **Pronoms personnels**
   - Sujets, compléments directs/indirects
   
5. **Adjectifs possessifs**
   - Mio, tuo, suo, nostro, vostro, loro
   
6. **Genre et nombre**
   - Règles masculin/féminin
   - Singulier/pluriel
   
7. **Verbes modaux**
   - Dovere, potere, volere
   
8. **Accord des adjectifs**
   - Règles et exceptions

**Fonctionnalités:**
- Sections expansibles (déjà implémenté ✅)
- Exemples avec traduction
- Tableaux de conjugaison si nécessaire

**Fichiers à modifier:**
- `Views/GrammarView.swift` - Enrichir contenu
- `Models/GrammarModels.swift` - Nouveau

**Estimation:** 1h

---

### ✅ TÂCHE 5: Améliorer PhoneticView (P1)

**Objectif:** Ajouter toutes les règles de prononciation italiennes

**Règles Android (15 règles):**
1. **Voyelles** - a, e, i, o, u
2. **C** devant a/o/u → [k] (casa, come)
3. **C** devant e/i → [tʃ] (ciao, cena)
4. **CH** → [k] (perché, chiave)
5. **G** devant a/o/u → [g] (gatto, gusto)
6. **G** devant e/i → [dʒ] (gelato, giorno)
7. **GH** → [g] (spaghetti, laghi)
8. **GL** → [ʎ] (famiglia, foglia)
9. **GN** → [ɲ] (gnocchi, bagno)
10. **SC** devant e/i → [ʃ] (pesce, scienza)
11. **SC** devant a/o/u → [sk] (scala, scuola)
12. **Z/ZZ** → [ts] ou [dz] (pizza, zio)
13. **Double consonnes** - Prononciation renforcée
14. **H** - Toujours muet
15. **Accent tonique** - Règles d'accentuation

**Fonctionnalités:**
- Exemples audio (Text-to-Speech)
- Symboles phonétiques IPA
- Exemples multiples par règle

**Fichiers à modifier:**
- `Views/PhoneticView.swift` - Enrichir
- Intégrer SpeechService

**Estimation:** 1h

---

### ✅ TÂCHE 6: Améliorer GeminiLiveView (P2)

**Objectif:** Interface plus riche avec animations

**Améliorations:**
- Waveform animation plus dynamique
- Historique de conversation
- Suggestions de phrases
- Timer de conversation
- Bouton arrêt d'urgence
- Transcription en temps réel (mockée)

**Fichiers à modifier:**
- `Views/GeminiLiveView.swift` - Enrichir

**Estimation:** 30min

---

## 📦 Nouvelles Données à Créer

### Models à créer:
```swift
// FeedModels.swift
struct FeedItem: Identifiable
enum FeedItemType

// EmojiModels.swift  
struct EmojiCategory: Identifiable
struct EmojiWord: Identifiable

// ConversationModels.swift
struct ConversationScenario
struct ConversationMessage

// GrammarModels.swift
struct GrammarRule
struct GrammarExample
```

### Services à créer:
```swift
// FeedService.swift
class FeedService: ObservableObject
- Génération de contenu aléatoire
- Pagination
- Support multi-langue
```

---

## 🔧 Architecture Technique

### Pattern iOS:
- **SwiftUI** pour toutes les vues
- **MVVM** avec @StateObject/@ObservedObject
- **Services** pour logique métier
- **Models** pour structures de données

### Fonctionnalités communes:
- ✅ Text-to-Speech (AVFoundation)
- ✅ Animations SwiftUI
- ✅ Navigation native iOS
- ✅ Design cohérent

---

## ✅ CHECKLIST D'EXÉCUTION

### Phase 1: Contenu Critique (P0)
- [ ] FeedView avec swipe vertical
- [ ] EmojiView avec 35 catégories (500+ emojis)

### Phase 2: Contenu Important (P1)  
- [ ] ConversationView avec 4 scénarios
- [ ] GrammarView avec 8+ règles
- [ ] PhoneticView avec 15 règles

### Phase 3: Polish (P2)
- [ ] GeminiLiveView enrichi
- [ ] Animations fluides partout
- [ ] Tests sur simulateur

---

## 📈 Métriques de Succès

### Contenu:
- ✅ 500+ emojis (vs 25)
- ✅ 35 catégories emoji (vs 3)
- ✅ Feed type TikTok avec 5 types de cartes
- ✅ 4 scénarios de conversation
- ✅ 15 règles de phonétique (vs 6)
- ✅ 8+ règles de grammaire (vs 4)

### Performance:
- ✅ Animations fluides 60fps
- ✅ Chargement < 2s
- ✅ Pas de crashes
- ✅ Memory usage optimisé

### UX:
- ✅ Interface cohérente
- ✅ Text-to-Speech sur tout
- ✅ Navigation intuitive
- ✅ Design moderne iOS

---

## 🚀 Timeline

**Durée totale estimée:** 6-8 heures

- **Phase 1 (P0):** 3-5h - FeedView + EmojiView
- **Phase 2 (P1):** 2-3h - Conversation + Grammar + Phonetic  
- **Phase 3 (P2):** 30min-1h - Polish + Tests

---

## 📝 Notes Importantes

### Différences iOS vs Android acceptables:
- ✅ Pas de Firebase Auth (OK pour l'instant)
- ✅ Pas de Firestore (OK pour l'instant)
- ✅ Design natif iOS vs Material Design
- ✅ Animations SwiftUI vs Android Animations

### Ce qui DOIT être identique:
- ✅ Contenu (textes, emojis, données)
- ✅ Fonctionnalités (toutes présentes)
- ✅ Navigation (même structure)
- ✅ Text-to-Speech (italien + espagnol)

---

**STATUS:** 🔨 EN COURS  
**PROCHAINE ÉTAPE:** Exécuter Phase 1 (FeedView + EmojiView)
