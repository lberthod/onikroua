# 🚀 Déploiement iOS sans Fastlane

Guide pour déployer sur TestFlight et App Store directement avec Xcode (sans fastlane).

---

## ✅ Avantages de cette méthode

- ✅ Pas besoin d'installer Ruby 3.x
- ✅ Interface graphique Xcode
- ✅ Fonctionne immédiatement
- ✅ Parfait pour débuter

---

## 📱 Déployer sur TestFlight

### Étape 1: Ouvrir le projet

```bash
cd /Users/berthod/Desktop/onykroua/frontend-ios/onykroua
open onykroua.xcodeproj
```

### Étape 2: Configurer la signature

1. Dans Xcode, sélectionnez le projet **onykroua** (bleu)
2. Target **onykroua** → **Signing & Capabilities**
3. Team: Sélectionnez votre équipe `N668CK695Q`
4. Cochez **Automatically manage signing**

### Étape 3: Connecter votre appareil (optionnel pour tester)

1. Connectez votre iPhone via USB
2. En haut de Xcode, sélectionnez votre iPhone comme destination
3. Cliquez sur ▶️ pour tester l'app
4. Sur iPhone: Réglages → Général → Gestion des profils → Faire confiance

### Étape 4: Créer une archive

1. En haut, sélectionnez **Any iOS Device (arm64)** comme destination
2. Menu: **Product** → **Archive**
3. Attendez la compilation (~2-5 minutes)
4. La fenêtre Organizer s'ouvre automatiquement

### Étape 5: Uploader sur TestFlight

1. Dans Organizer, sélectionnez votre archive
2. Cliquez **Distribute App**
3. Choisissez **App Store Connect**
4. Cliquez **Upload**
5. Choisissez les options:
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number (pour auto-increment)
6. Cliquez **Next** → **Upload**
7. Attendez l'upload (~2-5 minutes)

### Étape 6: Configurer TestFlight

1. Allez sur [App Store Connect](https://appstoreconnect.apple.com)
2. **TestFlight** → Attendez que le build soit traité (~5-10 min)
3. Une fois "Ready to Submit", ajoutez des testeurs:
   - **Testeurs internes**: Instant, max 100 personnes
   - **Testeurs externes**: Révision Apple, max 10,000 personnes

⏱️ **Temps total: ~15-20 minutes**

---

## 🏪 Déployer sur l'App Store

### Étape 1: Créer l'app dans App Store Connect

1. Allez sur [App Store Connect](https://appstoreconnect.apple.com)
2. **Mes apps** → **➕** (Ajouter)
3. Remplissez:
   - **Nom**: Onykroua
   - **Langue principale**: Français
   - **Bundle ID**: com.onykroua.app
   - **SKU**: onykroua-ios-2026

### Étape 2: Remplir les métadonnées

**Informations générales:**
- **Catégorie principale**: Éducation
- **Catégorie secondaire**: Langues
- **Pays**: Suisse, France, Italie, etc.

**Description:**
```
Onykroua est l'application parfaite pour apprendre l'italien avec l'IA!

🎯 FONCTIONNALITÉS:
• Conjugaison interactive des verbes
• Vocabulaire avec flashcards
• Conversations avec Gemini AI
• Grammaire italienne simplifiée
• Phonétique et prononciation
• Emoji pour apprendre en s'amusant

🚀 INTELLIGENCE ARTIFICIELLE:
Pratiquez avec Gemini Live pour des conversations naturelles.

📚 CONTENU:
• Centaines de mots et phrases
• Leçons progressives
• Exercices interactifs
• Suivi de progression

Parfait pour débutants et intermédiaires!
```

**Mots-clés** (100 caractères max):
```
italien,langue,apprentissage,IA,vocabulaire,conversation,grammaire
```

### Étape 3: Ajouter les captures d'écran

**Tailles requises:**
- **iPhone 6.7"** (iPhone 15 Pro Max): 3-10 captures
- **iPhone 5.5"** (iPhone 8 Plus): 3-10 captures

**Comment créer les captures:**
1. Lancez l'app dans le simulateur: **iPhone 15 Pro Max**
2. Naviguez vers les différentes vues
3. **⌘S** pour capturer (sauvegarde sur le Bureau)
4. Uploadez dans App Store Connect

### Étape 4: Ajouter l'icône et autres assets

**Icône 1024x1024:**
- Déjà configurée dans `Assets.xcassets/AppIcon`
- Format: PNG sans transparence

**Politique de confidentialité:**
- URL requise (hébergez sur votre site ou GitHub Pages)

### Étape 5: Uploader le build

Suivez les mêmes étapes que TestFlight (Product → Archive → Upload)

### Étape 6: Soumettre pour révision

1. Dans App Store Connect, sélectionnez votre build uploadé
2. Remplissez toutes les informations obligatoires
3. Cliquez **Soumettre pour révision**
4. Attendez la révision Apple (1-3 jours généralement)

⏱️ **Temps total: ~30-45 minutes + révision Apple**

---

## 🔄 Mettre à jour l'app

### 1. Incrémenter la version

Dans Xcode:
1. Sélectionnez le projet
2. Target **onykroua** → **General**
3. **Version**: 1.0 → 1.1 (nouvelle version utilisateur)
4. **Build**: 1 → 2 (doit toujours augmenter)

### 2. Créer une nouvelle archive

Répétez les étapes Product → Archive → Upload

### 3. Soumettre la mise à jour

Dans App Store Connect, créez une nouvelle version et soumettez.

---

## 📊 Versionning recommandé

| Changement | Version | Build |
|------------|---------|-------|
| Corrections bugs mineurs | 1.0 | 1→2 |
| Nouvelles petites features | 1.0→1.1 | 2→3 |
| Refonte majeure | 1.1→2.0 | 3→4 |

**Règle:** Build doit TOUJOURS augmenter, jamais baisser.

---

## ⚡ Raccourcis Xcode utiles

```
⌘B          Compiler
⌘R          Lancer sur simulateur/iPhone
⌘⇧K         Clean build folder
⌥⌘P         Rafraîchir les previews SwiftUI
⌘0          Toggle navigateur
⌘⌥0         Toggle inspecteur
```

---

## 🆘 Dépannage

### Erreur: "No signing certificate"

1. Xcode → Preferences → Accounts
2. Ajoutez votre Apple ID
3. Téléchargez les certificats automatiquement

### Erreur: "Failed to create provisioning profile"

1. Allez sur [developer.apple.com/account](https://developer.apple.com/account)
2. Certificates, IDs & Profiles → Profiles
3. Supprimez les anciens profils
4. Dans Xcode, relancez l'archivage

### Archive grisée dans Organizer

- Attendez que "Processing" soit terminé (~5-10 min)
- Vérifiez dans App Store Connect → TestFlight

### App crash en mode Release

1. Activez les logs: Product → Scheme → Edit Scheme → Run → Diagnostics
2. Testez avec un build Ad Hoc pour debugger

---

## 📱 Tester avant publication

### Sur simulateur (gratuit)

```bash
# Lancer dans Xcode
⌘R
# Ou ligne de commande
xcodebuild -scheme onykroua -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Sur iPhone physique (nécessite Apple Developer)

1. Connectez iPhone via USB
2. Sélectionnez-le comme destination
3. ▶️ Run
4. Acceptez le profil sur iPhone

---

## ✅ Checklist avant soumission

- [ ] App testée sur iPhone et iPad physiques
- [ ] Toutes les captures d'écran uploadées
- [ ] Icône 1024x1024 configurée
- [ ] Description rédigée
- [ ] Mots-clés définis
- [ ] Politique de confidentialité (URL)
- [ ] Pas de crash ou bug majeur
- [ ] Version et Build incrémentés
- [ ] Compte Apple Developer actif (99$/an)

---

## 🎯 Workflow recommandé

```
1. Développer dans Xcode (⌘R pour tester)
2. Incrémenter Version/Build
3. Product → Archive
4. Upload vers TestFlight
5. Tester avec équipe via TestFlight
6. Si OK → Soumettre à l'App Store
```

---

## 💡 Pourquoi utiliser Fastlane plus tard?

Fastlane devient utile quand:
- ✅ Vous déployez très fréquemment (plusieurs fois par jour)
- ✅ Vous voulez automatiser avec CI/CD
- ✅ Vous gérez plusieurs apps
- ✅ Vous voulez générer les screenshots automatiquement

**Pour commencer:** Xcode est parfait! ✨

---

**C'est prêt! Vous pouvez déployer maintenant avec Xcode. 🚀**
