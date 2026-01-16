# 🧪 Guide de Test - iOS Onykroua

Guide complet pour tester toutes les fonctionnalités de l'application iOS.

---

## ✅ Checklist Complète

### Navigation Principale
- [ ] L'écran principal affiche "Ciao!" avec email
- [ ] 6 catégories visibles en grille 2x3
- [ ] Bouton profil en haut à droite fonctionne
- [ ] Card "Continuer l'apprentissage" est cliquable
- [ ] Section "Pratique" avec Gemini Live visible

---

### 📱 Feed d'Apprentissage

**Test Swipe Vertical:**
- [ ] Ouvrir Feed depuis navigation
- [ ] Swipe vertical fonctionne (comme TikTok)
- [ ] 5 cartes différentes s'affichent
- [ ] Bouton "Voir traduction" affiche/cache traduction
- [ ] Bouton ❤️ (Like) change de couleur
- [ ] Bouton 🔖 (Bookmark) change de couleur
- [ ] Bouton 🔊 (Audio) présent
- [ ] Gradient de couleur change selon type de carte
- [ ] Navigation fluide entre cartes

**Types de cartes à vérifier:**
- [ ] Vocabulaire (bleu)
- [ ] Conjugaison (vert)
- [ ] Expression (violet)
- [ ] Grammaire (orange)

---

### 📚 Conjugaison

**Test Tabs:**
- [ ] Ouvrir Conjugaison depuis navigation
- [ ] 3 tabs visibles: Verbes, Temps, Pratique
- [ ] Tab "Verbes" par défaut

**Tab Verbes:**
- [ ] 10 verbes en scroll horizontal
- [ ] Sélection d'un verbe fonctionne
- [ ] Conjugaison affiche 6 formes (io, tu, lui/lei, noi, voi, loro)
- [ ] essere: sono, sei, è, siamo, siete, sono
- [ ] avere: ho, hai, ha, abbiamo, avete, hanno
- [ ] Bouton 🔊 sur chaque ligne

**Tab Temps:**
- [ ] 4 temps listés (Présent, Passé composé, Futur, Imparfait)
- [ ] Description de chaque temps visible

**Tab Pratique:**
- [ ] Message "Mode Pratique" affiché

---

### 📖 Vocabulaire

**Test 3 Tabs:**
- [ ] Ouvrir Vocabulaire depuis navigation
- [ ] Titre affiche "Vocabulaire (10 mots)"
- [ ] 3 tabs: Mots, Catégories, Pratique

**Tab Mots (Dictionnaire):**
- [ ] 10 mots affichés en liste
- [ ] Tap sur une carte fait flip 3D
- [ ] Face avant: Mot italien + catégorie
- [ ] Face arrière: Traduction française + exemple
- [ ] Animation flip fluide

**Tab Catégories:**
- [ ] 6 catégories listées avec emojis
- [ ] Compteur de mots par catégorie
- [ ] Tap change vers tab Mots avec filtre

**Tab Pratique (Flashcards):**
- [ ] Grande carte colorée centrée
- [ ] Compteur "1 / 10" en haut
- [ ] Tap carte fait flip entre IT/FR
- [ ] Boutons ← → pour naviguer
- [ ] Bouton ← désactivé sur première carte
- [ ] Bouton → désactivé sur dernière carte
- [ ] Exemple affiché sur face arrière

---

### 😊 Emoji

**Test Catégories:**
- [ ] Ouvrir Emoji depuis navigation
- [ ] Scroll horizontal de catégories en haut
- [ ] Bouton "Tous" par défaut
- [ ] 3 catégories: Émotions, Actions, Nourriture

**Test Grid:**
- [ ] Grid 3 colonnes
- [ ] Chaque carte affiche: emoji + mot IT + mot FR
- [ ] 18 emojis au total
- [ ] Bouton 🔊 sur chaque carte
- [ ] Filtre par catégorie fonctionne

**Vérifier emojis:**
- [ ] Émotions: 😊 😢 😂 😍 😡 😴
- [ ] Actions: 🏃 🚶 💃 🤔
- [ ] Nourriture: 🍕 🍝 ☕ 🍷

---

### 💬 Conversation

**Test Sélection Scénario:**
- [ ] Ouvrir Conversation depuis navigation
- [ ] 4 scénarios affichés
- [ ] Restaurant 🍽️
- [ ] Hôtel 🏨
- [ ] Gare 🚂
- [ ] Shopping 🛍️
- [ ] Tap ouvre interface chat

**Test Chat:**
- [ ] Message de bienvenue du bot apparaît
- [ ] Input text en bas
- [ ] Tap input ouvre clavier
- [ ] Écrire message et envoyer
- [ ] Message utilisateur (bleu, à droite)
- [ ] Réponse bot après 1s (gris, à gauche)
- [ ] Bouton "Changer" en haut pour revenir

---

### 📝 Grammaire

**Test Règles:**
- [ ] Ouvrir Grammaire depuis navigation
- [ ] 5 règles affichées
- [ ] Chaque règle: emoji + titre + catégorie
- [ ] Tap règle pour expand/collapse
- [ ] Animation expand fluide

**Vérifier règles:**
- [ ] 📝 Les Articles (Base)
- [ ] 🔗 Les Prépositions (Base)
- [ ] 👤 Les Pronoms Personnels (Base)
- [ ] ✨ Les Adjectifs (Intermédiaire)
- [ ] ⏰ Le Passé Composé (Intermédiaire)

**Test Expand:**
- [ ] Explication complète visible
- [ ] 3-4 exemples par règle
- [ ] Bullet points avec •
- [ ] Fermer en retappant

---

### 🔊 Phonétique

**Test Règles:**
- [ ] Ouvrir Phonétique depuis navigation
- [ ] 8 règles de prononciation
- [ ] Chaque carte: lettre + prononciation + exemple
- [ ] Couleurs différentes par carte
- [ ] Bouton 🔊 sur chaque carte

**Vérifier règles:**
- [ ] C [k] - casa (bleu)
- [ ] C [tʃ] - ciao (vert)
- [ ] G [g] - gatto (orange)
- [ ] G [dʒ] - giorno (violet)
- [ ] GL [ʎ] - famiglia (rouge)
- [ ] GN [ɲ] - ognuno (rose)
- [ ] SC [sk] - scarpa (indigo)
- [ ] SC [ʃ] - scienza (teal)

---

### 🎤 Gemini Live

**Test Interface:**
- [ ] Ouvrir Gemini Live depuis navigation
- [ ] Fond dégradé indigo/violet
- [ ] Icône micro au centre
- [ ] Texte instruction
- [ ] Gros bouton rond en bas

**Test Recording:**
- [ ] Tap bouton micro
- [ ] Bouton devient rouge avec stop
- [ ] Icône change en waveform
- [ ] Animation waveform active
- [ ] Message change
- [ ] Tap stop pour arrêter
- [ ] Message "Continue à pratiquer"

---

### 👤 Profil

**Test Ouverture:**
- [ ] Tap bouton profil depuis accueil
- [ ] Modal s'ouvre en sheet
- [ ] Bouton "Fermer" en haut à droite

**Test Contenu:**
- [ ] Photo profil (icône)
- [ ] Email affiché
- [ ] Date membre

**Test Stats:**
- [ ] 3 cartes statistiques
- [ ] 📚 Mots: 127
- [ ] 🔥 Série: 7j
- [ ] ⏰ Temps: 12h

**Test Menu:**
- [ ] 6 options listées
- [ ] Statistiques détaillées
- [ ] Succès
- [ ] Langue: Italien
- [ ] Notifications
- [ ] Paramètres
- [ ] À propos

**Test Actions:**
- [ ] Bouton déconnexion en rouge
- [ ] Tap "Fermer" ferme le modal

---

## 🎨 Tests Visuels

### Design & Animations
- [ ] Transitions fluides entre vues
- [ ] Animations spring sur boutons
- [ ] Ombres douces sur cartes
- [ ] Coins arrondis cohérents (12-20px)
- [ ] Couleurs vives et modernes
- [ ] Pas de lag/stutter

### Responsive
- [ ] Test sur iPhone SE (petit écran)
- [ ] Test sur iPhone 15 Pro (standard)
- [ ] Test sur iPhone 15 Pro Max (grand écran)
- [ ] Test sur iPad (si possible)
- [ ] Rotation portrait ↔️ paysage

---

## 🐛 Tests d'Erreurs

### Stabilité
- [ ] Aucun crash en navigation
- [ ] Retour arrière fonctionne partout
- [ ] Pas de freeze/blocage
- [ ] Mémoire stable (pas de leak)

### Edge Cases
- [ ] Première/dernière carte flashcards
- [ ] Filtres vides (catégories)
- [ ] Input vide (conversation)
- [ ] Spam tap rapide sur boutons

---

## ⚡ Tests Performance

### Temps de Chargement
- [ ] Ouverture app < 2s
- [ ] Navigation entre vues < 0.5s
- [ ] Animations 60fps
- [ ] Scroll fluide partout

### Mémoire
- [ ] Pas de warnings Xcode
- [ ] Usage mémoire < 100MB
- [ ] Pas de leak après 10min

---

## 📱 Tests Appareil Physique

**Sur iPhone réel:**
- [ ] Toutes les animations fluides
- [ ] Pas de lag au scroll
- [ ] Flip 3D smooth
- [ ] Transitions rapides
- [ ] Pas de crash
- [ ] Battery drain normal

---

## ✅ Checklist Finale

Avant déploiement TestFlight:

- [ ] Tous les tests ci-dessus passés
- [ ] Aucun crash en 30min d'utilisation
- [ ] Toutes les vues fonctionnelles
- [ ] Navigation cohérente
- [ ] Design uniforme
- [ ] Animations fluides
- [ ] Textes corrects (pas de lorem ipsum)
- [ ] Icônes appropriées partout
- [ ] Build réussit en Release mode
- [ ] Archive Xcode créée sans erreur

---

## 🚀 Scénario Complet

**Test Flow Utilisateur Complet (15 min):**

1. **Lancer app** (2 min)
   - Voir écran accueil
   - Tap chaque catégorie
   - Retour à l'accueil

2. **Feed** (3 min)
   - Swipe 5 cartes
   - Like une carte
   - Bookmark une carte
   - Voir traduction

3. **Vocabulaire** (3 min)
   - Voir dictionnaire
   - Flip 3 cartes
   - Aller catégories
   - Flashcards: 5 cartes

4. **Conjugaison** (2 min)
   - Essayer 3 verbes
   - Changer de tab

5. **Emoji** (2 min)
   - Filtrer par catégorie
   - Retour "Tous"

6. **Conversation** (2 min)
   - Choisir Restaurant
   - Envoyer 2 messages

7. **Profil** (1 min)
   - Voir stats
   - Fermer

---

## 📊 Résultats Attendus

**✅ SUCCÈS si:**
- 100% des fonctionnalités testées
- 0 crash
- Performance fluide partout
- Design cohérent et moderne
- Utilisable sans hésitation

**❌ ÉCHEC si:**
- Crash fréquent
- Lag visible
- Navigation cassée
- Données manquantes
- Design incohérent

---

## 🎯 Prochaines Étapes

Après tests réussis:
1. ✅ Corriger bugs trouvés
2. ✅ Archive pour TestFlight
3. ✅ Upload sur App Store Connect
4. ✅ Inviter testeurs bêta
5. ✅ Collecter feedback
6. ✅ Itérer améliora tions

---

**Version testée:** 1.0 (Build 1)  
**Date:** Janvier 2026  
**Statut:** ✅ PRÊT POUR TEST
