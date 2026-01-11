# 📱 Onikroua - Version Android

Application Vue3 + PWA + Capacitor configurée pour Android

## ⚡ Démarrage ultra-rapide

```bash
cd /Users/berthod/Desktop/onykroua/onikroua/frontend

# Installer les dépendances
npm install

# Builder et préparer Android
npm run build
npx cap add android
npm run android:sync
```

## 📦 Générer APK/AAB

### APK Debug (test immédiat)
```bash
npm run android:build:debug
```
→ Fichier: `android/app/build/outputs/apk/debug/app-debug.apk`

### APK Release (distribution)
```bash
npm run android:build
```
→ Fichier: `android/app/build/outputs/apk/release/app-release.apk`
⚠️ Nécessite signature

### AAB (Google Play)
```bash
npm run android:bundle
```
→ Fichier: `android/app/build/outputs/bundle/release/app-release.aab`
⚠️ Nécessite signature

## 📚 Documentation

- **DEMARRAGE_RAPIDE_ANDROID.md** - Guide de démarrage rapide
- **ANDROID_SETUP.md** - Documentation complète
- **generate-icons.md** - Créer les icônes de l'app

## 🔧 Prérequis

- ✅ Node.js et npm (déjà installé)
- ⚠️ Android Studio ([télécharger](https://developer.android.com/studio))
- ⚠️ JDK 17 (`java -version` pour vérifier)

## 🛠️ Commandes principales

```bash
npm run dev                    # Développement web (port 5173)
npm run build                  # Build production
npm run android:sync           # Sync web → Android
npm run android:open           # Ouvrir Android Studio
npm run android:build:debug    # APK debug
npm run android:build          # APK release
npm run android:bundle         # AAB release
```

## 📱 Workflow complet

1. **Développer** en mode web: `npm run dev`
2. **Tester** les changements
3. **Builder**: `npm run build`
4. **Synchroniser**: `npm run android:sync`
5. **Tester sur Android**: `npm run android:open`
6. **Générer APK**: `npm run android:build:debug`

## 🎨 Icônes à créer

Placer dans `public/`:
- `pwa-192x192.png` (192x192)
- `pwa-512x512.png` (512x512)
- `apple-touch-icon.png` (180x180)

Voir `generate-icons.md` pour les détails

## 🔐 Signature (pour Release)

Créer le keystore:
```bash
cd android/app
keytool -genkey -v -keystore onikroua-release.keystore \
  -alias onikroua -keyalg RSA -keysize 2048 -validity 10000
```

Configurer dans `android/keystore.properties`:
```properties
storeFile=app/onikroua-release.keystore
storePassword=VOTRE_PASSWORD
keyAlias=onikroua
keyPassword=VOTRE_PASSWORD
```

Voir `DEMARRAGE_RAPIDE_ANDROID.md` pour la configuration Gradle complète.

## 🚨 Important

- **Ne jamais commiter** le keystore ou keystore.properties
- **Sauvegarder** le keystore en lieu sûr
- **Noter** les mots de passe du keystore

## 📦 Structure du projet

```
frontend/
├── src/                      # Code source Vue3
├── public/                   # Assets statiques + icônes PWA
├── dist/                     # Build de production (généré)
├── android/                  # Projet Android (généré)
├── capacitor.config.ts       # Configuration Capacitor
├── vite.config.ts            # Configuration Vite + PWA
└── package.json              # Dépendances + scripts
```

## 🐛 Dépannage

### Erreurs TypeScript au démarrage
Les erreurs `Cannot find module 'vite-plugin-pwa'` et `'@capacitor/cli'` disparaîtront après `npm install`.

### Gradle ne fonctionne pas
```bash
cd android
./gradlew clean
./gradlew assembleDebug
```

### Port occupé
Modifier le port dans `vite.config.ts` (ligne 76)

## 🌟 Fonctionnalités

- ✅ PWA (Progressive Web App)
- ✅ Mode offline avec Service Worker
- ✅ Cache intelligent (fonts, Firebase)
- ✅ Application Android native
- ✅ Splash screen personnalisé
- ✅ Status bar configurée
- ✅ Icônes adaptatives

## 📖 Ressources

- [Capacitor Documentation](https://capacitorjs.com/)
- [Vite PWA Plugin](https://vite-pwa-org.netlify.app/)
- [Android Developer](https://developer.android.com/)

## ✅ Checklist de publication

- [ ] Installer les dépendances (`npm install`)
- [ ] Créer les icônes PWA
- [ ] Builder l'application (`npm run build`)
- [ ] Ajouter Android (`npx cap add android`)
- [ ] Créer le keystore
- [ ] Configurer la signature
- [ ] Tester l'APK debug
- [ ] Générer l'APK/AAB release
- [ ] Tester sur appareil réel
- [ ] Préparer les screenshots pour le Play Store
- [ ] Rédiger la description de l'app
- [ ] Publier sur Google Play Store

---

**Prêt à démarrer ?** → Lire `DEMARRAGE_RAPIDE_ANDROID.md`
