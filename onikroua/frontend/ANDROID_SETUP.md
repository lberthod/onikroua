# Configuration Android pour Onikroua

## Prérequis

1. **Node.js et npm** (déjà installés)
2. **Android Studio** - [Télécharger ici](https://developer.android.com/studio)
3. **Java JDK 17** - Requis pour Gradle

## Installation

### Étape 1: Installer les dépendances

```bash
cd /Users/berthod/Desktop/onykroua/onikroua/frontend
npm install
```

### Étape 2: Initialiser Capacitor

```bash
npx cap init
```

Utiliser les valeurs suivantes quand demandé:
- **App name**: `Onikroua`
- **App ID**: `com.onikroua.app`
- **Web dir**: `dist`

### Étape 3: Ajouter la plateforme Android

```bash
npx cap add android
```

### Étape 4: Build de l'application web

```bash
npm run build
```

### Étape 5: Synchroniser avec Android

```bash
npm run android:sync
```

### Étape 6: Ouvrir Android Studio

```bash
npm run android:open
```

## Générer les fichiers APK/AAB

### APK Debug (pour tester)

```bash
npm run android:build:debug
```

L'APK sera dans: `android/app/build/outputs/apk/debug/app-debug.apk`

### APK Release (pour distribuer)

```bash
npm run android:build
```

L'APK sera dans: `android/app/build/outputs/apk/release/app-release.apk`

**Note**: Vous devez d'abord configurer la signature dans `android/app/build.gradle`

### AAB (Android App Bundle - pour Google Play)

```bash
npm run android:bundle
```

L'AAB sera dans: `android/app/build/outputs/bundle/release/app-release.aab`

## Configuration de la signature (Release)

Pour publier sur Google Play ou distribuer l'APK, vous devez signer l'application:

### 1. Créer un keystore

```bash
keytool -genkey -v -keystore onikroua-release.keystore -alias onikroua -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Configurer le keystore dans Android

Créer le fichier `android/keystore.properties`:

```properties
storeFile=/path/to/onikroua-release.keystore
storePassword=YOUR_STORE_PASSWORD
keyAlias=onikroua
keyPassword=YOUR_KEY_PASSWORD
```

### 3. Ajouter dans `android/app/build.gradle`

Ajouter avant `android {`:

```gradle
def keystorePropertiesFile = rootProject.file("keystore.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Dans la section `android { ... }`, ajouter:

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
        minifyEnabled false
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

## Icônes et Splash Screen

Les icônes PWA doivent être placées dans `public/`:
- `pwa-192x192.png` (192x192)
- `pwa-512x512.png` (512x512)

Pour générer automatiquement toutes les icônes Android:

```bash
npx @capacitor/assets generate --android
```

## Dépannage

### Erreur Gradle

Si vous rencontrez des erreurs Gradle, vérifiez que vous utilisez JDK 17:

```bash
java -version
```

### Port déjà utilisé

Si le port 5173 est occupé, modifier dans `vite.config.ts`

### Erreurs de build

Nettoyer et rebuild:

```bash
cd android
./gradlew clean
./gradlew assembleDebug
```

## Commandes utiles

- `npm run android:sync` - Synchroniser le web build avec Android
- `npm run android:open` - Ouvrir dans Android Studio
- `npm run android:build:debug` - Build APK debug
- `npm run android:build` - Build APK release
- `npm run android:bundle` - Build AAB release

## Test sur appareil physique

1. Activer le mode développeur sur votre téléphone Android
2. Activer le débogage USB
3. Connecter via USB
4. Dans Android Studio, cliquer sur Run (icône play verte)

## Test sur émulateur

1. Dans Android Studio: Tools > Device Manager
2. Créer un Virtual Device
3. Lancer l'émulateur
4. Cliquer sur Run dans Android Studio
