# 🚀 Démarrage Rapide Android

## Installation automatique (recommandé)

```bash
cd /Users/berthod/Desktop/onykroua/onikroua/frontend
chmod +x android-setup.sh
./android-setup.sh
```

Ce script va:
- ✅ Installer toutes les dépendances npm
- ✅ Builder l'application web
- ✅ Ajouter la plateforme Android
- ✅ Synchroniser le projet

## Installation manuelle

### 1. Installer les dépendances

```bash
npm install
```

### 2. Builder l'application

```bash
npm run build
```

### 3. Ajouter Android

```bash
npx cap add android
```

### 4. Synchroniser

```bash
npm run android:sync
```

## Générer APK/AAB

### APK Debug (pour tester rapidement)

```bash
npm run android:build:debug
```

📦 Fichier généré: `android/app/build/outputs/apk/debug/app-debug.apk`

### APK Release (pour distribution)

```bash
npm run android:build
```

📦 Fichier généré: `android/app/build/outputs/apk/release/app-release.apk`

⚠️ **Nécessite une signature** - voir section ci-dessous

### AAB Release (pour Google Play Store)

```bash
npm run android:bundle
```

📦 Fichier généré: `android/app/build/outputs/bundle/release/app-release.aab`

⚠️ **Nécessite une signature** - voir section ci-dessous

## Configuration de la signature (obligatoire pour Release)

### Créer le keystore

```bash
cd android/app
keytool -genkey -v -keystore onikroua-release.keystore -alias onikroua -keyalg RSA -keysize 2048 -validity 10000
```

Suivez les instructions et **notez précieusement**:
- Le mot de passe du keystore
- Le mot de passe de la clé

### Configurer Gradle

1. Créer `android/keystore.properties`:

```properties
storeFile=app/onikroua-release.keystore
storePassword=VOTRE_MOT_DE_PASSE_STORE
keyAlias=onikroua
keyPassword=VOTRE_MOT_DE_PASSE_CLE
```

2. Modifier `android/app/build.gradle`

Ajouter **au début du fichier** (avant `android {`):

```gradle
def keystorePropertiesFile = rootProject.file("keystore.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

3. Dans la section `android {`, ajouter:

```gradle
signingConfigs {
    release {
        if (keystorePropertiesFile.exists()) {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

## Ouvrir dans Android Studio

```bash
npm run android:open
```

Ou manuellement: `File > Open > android/`

## Tester sur appareil

### Via Android Studio
1. Brancher le téléphone en USB
2. Activer le mode développeur
3. Activer le débogage USB
4. Cliquer sur le bouton ▶️ Run

### Via ADB
```bash
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

## Workflow de développement

```bash
# 1. Développer en mode web
npm run dev

# 2. Une fois prêt, builder et tester sur Android
npm run build
npm run android:sync
npm run android:open

# 3. Ou directement builder l'APK
npm run android:build:debug
```

## Commandes importantes

| Commande | Description |
|----------|-------------|
| `npm run android:sync` | Synchroniser le code web → Android |
| `npm run android:open` | Ouvrir dans Android Studio |
| `npm run android:build:debug` | Générer APK debug |
| `npm run android:build` | Générer APK release |
| `npm run android:bundle` | Générer AAB release |

## Prérequis système

- ✅ **Node.js** et **npm** (déjà installé)
- ⚠️ **Android Studio** - [Télécharger](https://developer.android.com/studio)
- ⚠️ **JDK 17** - Vérifier avec `java -version`

## Problèmes courants

### Gradle ne fonctionne pas
```bash
cd android
./gradlew clean
./gradlew assembleDebug
```

### Port 5173 occupé
Modifier le port dans `vite.config.ts`

### Erreur de signature
Vérifier que `keystore.properties` est bien configuré

## Prochaines étapes

1. ✅ Configuration terminée
2. 🎨 Créer les icônes (voir `generate-icons.md`)
3. 🔐 Configurer la signature (voir ci-dessus)
4. 📱 Tester sur appareil
5. 🚀 Publier sur Google Play

## Support

- 📖 Documentation complète: `ANDROID_SETUP.md`
- 🎨 Guide icônes: `generate-icons.md`
- 🌐 [Capacitor Docs](https://capacitorjs.com/)
