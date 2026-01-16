# 🚀 Guide de Déploiement iOS - Onykroua

Guide complet pour déployer votre application iOS sur TestFlight et l'App Store avec **fastlane** pour des déploiements ultra-rapides.

---

## 📋 Prérequis

### 1️⃣ Compte Apple Developer

- Compte Apple Developer actif (99$/an)
- Accès à [App Store Connect](https://appstoreconnect.apple.com)
- Team ID: `N668CK695Q`

### 2️⃣ Outils requis

```bash
# Installer Homebrew (si pas déjà fait)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Installer Ruby (si pas déjà fait)
brew install ruby

# Installer bundler
gem install bundler

# Installer CocoaPods
sudo gem install cocoapods
```

---

## ⚡ Installation rapide (une seule fois)

### Étape 1: Installer les dépendances

```bash
cd /Users/berthod/Desktop/onykroua/frontend-ios
bundle install
```

### Étape 2: Initialiser fastlane

```bash
fastlane init
```

Choisissez l'option **2** (Automate beta distribution to TestFlight)

### Étape 3: Configurer les identifiants Apple

```bash
# Créer un mot de passe spécifique à l'app
# 1. Allez sur appleid.apple.com
# 2. Sécurité → Mots de passe spécifiques aux apps
# 3. Générez un nouveau mot de passe
# 4. Copiez-le

# Ajoutez-le dans fastlane/.env.default
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

### Étape 4: Synchroniser les certificats

```bash
# Première fois: créer les certificats
fastlane match development
fastlane match appstore

# Suivre les instructions pour créer un repo Git privé pour stocker les certificats
```

---

## 🚀 Déploiements rapides

### 📱 Déployer sur TestFlight (RECOMMANDÉ pour les tests)

```bash
cd /Users/berthod/Desktop/onykroua/frontend-ios
fastlane beta
```

✅ **C'est tout!** Fastlane va:
1. Incrémenter le numéro de build
2. Compiler l'app en mode release
3. Signer l'app
4. Uploader sur TestFlight
5. Envoyer une notification Slack (optionnel)

⏱️ **Temps: ~5-10 minutes**

### 🏪 Déployer sur l'App Store (PRODUCTION)

```bash
cd /Users/berthod/Desktop/onykroua/frontend-ios
fastlane release
```

⏱️ **Temps: ~10-15 minutes + validation Apple (quelques heures)**

### 🛠️ Build de développement (local)

```bash
fastlane dev
```

---

## 📱 Configuration TestFlight

### 1️⃣ Ajouter des testeurs

Dans [App Store Connect](https://appstoreconnect.apple.com):

1. **TestFlight** → **Testeurs internes**
   - Ajoutez vos collègues (max 100, gratuit)
   - Ils reçoivent les builds immédiatement

2. **TestFlight** → **Testeurs externes**
   - Ajoutez jusqu'à 10 000 testeurs
   - Nécessite une révision Apple (1-2 jours)

### 2️⃣ Tester l'app

1. Les testeurs reçoivent un email
2. Ils installent l'app TestFlight depuis l'App Store
3. Ils peuvent installer votre app et la tester

---

## 🎨 Préparer les assets pour l'App Store

### Captures d'écran requises

```bash
# Générer automatiquement avec fastlane
fastlane screenshots
```

**Tailles requises:**
- **iPhone 6.7"** (iPhone 15 Pro Max): au moins 3 captures
- **iPhone 5.5"** (iPhone 8 Plus): au moins 3 captures  
- **iPad Pro 12.9"**: au moins 3 captures (si support iPad)

**Format:** PNG ou JPEG, sans canal alpha

### Icône de l'app

- **Taille:** 1024x1024 px
- **Format:** PNG sans transparence
- **Déjà configuré dans:** `onykroua/Assets.xcassets/AppIcon.appiconset/`

### Métadonnées

**Description courte** (30 caractères):
```
Apprends l'italien avec l'IA
```

**Description complète** (max 4000 caractères):
```
Onykroua est l'application parfaite pour apprendre l'italien de manière interactive!

🎯 FONCTIONNALITÉS:
• Conjugaison interactive des verbes
• Vocabulaire avec cartes flashcards
• Conversations avec Gemini AI
• Grammaire italienne simplifiée
• Phonétique et prononciation
• Emoji pour apprendre en s'amusant

🚀 INTELLIGENCE ARTIFICIELLE:
Pratiquez avec Gemini Live pour des conversations naturelles en italien.

📚 CONTENU:
• Des centaines de mots et phrases
• Leçons progressives
• Exercices interactifs
• Suivi de progression

Parfait pour débutants et intermédiaires!
```

**Mots-clés** (max 100 caractères, séparés par virgules):
```
italien,langue,apprentissage,IA,vocabulaire,conversation,grammaire
```

**Catégorie principale:** Éducation  
**Catégorie secondaire:** Langues

---

## 🔄 Workflow recommandé

### Pour chaque nouvelle version:

```bash
# 1. Développer les nouvelles fonctionnalités
# 2. Tester localement sur votre iPhone
cd /Users/berthod/Desktop/onykroua/frontend-ios
open onykroua/onykroua.xcodeproj

# 3. Incrémenter la version dans Xcode (optionnel, fastlane le fait)
# Product → Scheme → Edit Scheme → Run → Info → Version

# 4. Déployer sur TestFlight pour tests
fastlane beta

# 5. Faire tester par votre équipe via TestFlight
# 6. Une fois validé, déployer en production
fastlane release
```

---

## ⚡ Commandes rapides

```bash
# Déploiement TestFlight (le plus utilisé)
fastlane beta

# Déploiement App Store
fastlane release

# Build local
fastlane dev

# Tests automatisés
fastlane test

# Screenshots automatiques
fastlane screenshots

# Synchroniser certificats
fastlane sync_certificates

# Ajouter un nouveau device
fastlane setup_device
```

---

## 📊 Versionning

### Incrémenter les versions

**Format:** `versionName (versionCode)`  
Exemple: `1.5 (5)`

```bash
# Dans Xcode:
# Target → General → Version: 1.0 → 1.1
# Target → General → Build: 1 → 2

# Ou automatiquement avec fastlane (déjà inclus dans les lanes)
```

**Règles:**
- **versionCode** (Build): toujours croissant, +1 à chaque upload
- **versionName** (Version): sémantique (1.0, 1.1, 2.0)

---

## 🔒 Sécurité & Certificats

### Gestion des certificats avec Match

Fastlane Match synchronise vos certificats dans un repo Git privé.

```bash
# Créer les certificats (première fois)
fastlane match development
fastlane match appstore

# Sur une nouvelle machine
fastlane match development --readonly
fastlane match appstore --readonly
```

**⚠️ IMPORTANT:**
- Gardez le mot de passe Match en sécurité
- Ne partagez jamais votre repo de certificats publiquement
- Utilisez un repo Git privé (GitHub, GitLab, etc.)

### Fichiers sensibles (dans .gitignore)

```
fastlane/.env.default
fastlane/report.xml
*.mobileprovision
*.p12
*.cer
```

---

## 🆘 Dépannage

### Erreur: "No signing certificate found"

```bash
# Régénérer les certificats
fastlane match appstore --force
```

### Erreur: "Invalid credentials"

```bash
# Vérifier votre Apple ID et mot de passe spécifique
# Régénérer le mot de passe sur appleid.apple.com
```

### Erreur: "Build processing failed"

- Vérifiez dans App Store Connect → TestFlight
- Attendez 5-10 minutes pour le processing
- Vérifiez les logs dans Xcode Organizer

### L'app crash en mode Release

```bash
# Tester le build release localement
fastlane dev
# Installer sur votre iPhone et debugger
```

### Fastlane est lent

```bash
# Nettoyer le cache
rm -rf ~/Library/Caches/org.carthage.CarthageKit
rm -rf ~/Library/Developer/Xcode/DerivedData

# Rebuild
fastlane beta
```

---

## 📈 Optimisations avancées

### 1. CI/CD avec GitHub Actions

Créez `.github/workflows/ios.yml`:

```yaml
name: iOS Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          cd frontend-ios
          bundle install
          
      - name: Deploy to TestFlight
        env:
          FASTLANE_USER: ${{ secrets.FASTLANE_USER }}
          FASTLANE_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        run: |
          cd frontend-ios
          fastlane beta
```

### 2. Notifications Slack

Dans `fastlane/.env.default`:
```bash
SLACK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

### 3. Génération automatique de changelog

```bash
# Ajoutez dans votre Fastfile
changelog_from_git_commits(
  between: [last_git_tag, "HEAD"],
  pretty: "• %s"
)
```

---

## ✅ Checklist avant production

- [ ] App testée sur iPhone et iPad physiques
- [ ] Toutes les captures d'écran prêtes (3 par taille)
- [ ] Icône 1024x1024 configurée
- [ ] Description et mots-clés rédigés
- [ ] Politique de confidentialité publiée (URL requise)
- [ ] Compte Apple Developer actif
- [ ] Certificats synchronisés avec Match
- [ ] Version incrémentée correctement
- [ ] Tests Beta via TestFlight validés
- [ ] Pas de crash ou bug majeur

---

## 📧 Support & Ressources

**Documentation:**
- [Fastlane Docs](https://docs.fastlane.tools)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)
- [TestFlight Guide](https://developer.apple.com/testflight/)

**Commandes utiles:**
```bash
# Aide fastlane
fastlane --help
fastlane action [action_name]

# Voir les logs détaillés
fastlane beta --verbose

# Nettoyer tout
fastlane clean
rm -rf ~/Library/Developer/Xcode/DerivedData
```

---

## 🎯 Résumé: Workflow quotidien

```bash
# 1. Développer
open onykroua/onykroua.xcodeproj
# ... coder ...

# 2. Tester localement
⌘R dans Xcode

# 3. Déployer sur TestFlight
fastlane beta

# 4. Tester avec l'équipe
# App TestFlight → installer → tester

# 5. Si OK → Production
fastlane release
```

**C'est tout! 🚀**

---

**Créé avec ❤️ pour Onykroua - Janvier 2026**
