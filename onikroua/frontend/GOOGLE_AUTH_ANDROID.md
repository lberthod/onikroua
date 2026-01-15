# Configuration Google Sign-In pour Android

## ⚠️ Important

Le code a été adapté pour supporter la connexion Google sur Android et Web :
- **Web** : Utilise `signInWithPopup` (popup Google)
- **Android** : Utilise `@codetrix-studio/capacitor-google-auth` (natif)

## 🔧 Étapes de configuration

### 1. Installer les dépendances

```bash
cd /Users/berthod/Desktop/onykroua/onikroua/frontend
npm install
```

### 2. Obtenir le SHA-1 de votre keystore

Pour que Google Sign-In fonctionne sur Android, Firebase a besoin de votre **SHA-1 fingerprint**.

#### Pour le keystore de debug (test)

```bash
cd android
./gradlew signingReport
```

Cherchez dans la sortie :
```
Variant: debug
Config: debug
Store: ~/.android/debug.keystore
Alias: AndroidDebugKey
MD5: ...
SHA1: D2:0F:46:A4:42:50:72:C9:85:88:98:2A:B7:93:53:3F:B0:C6:1F:31
SHA-256: ...
```

Copiez le **SHA1**.

#### Pour le keystore de release (production)

```bash
keytool -list -v -keystore android/app/onikroua-release.keystore -alias onikroua
```

Entrez le mot de passe, puis copiez le **SHA1**.

### 3. Configurer Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet **Onikroua**
3. Allez dans **Paramètres du projet** (icône engrenage) → **Général**
4. Descendez à **Vos applications** → trouvez votre app Android
5. Si pas d'app Android, cliquez **Ajouter une application** → **Android**
   - Package name : `com.loicberthod.onykroua`
   - Téléchargez `google-services.json`
6. Dans **Empreintes digitales du certificat SHA**, cliquez **Ajouter une empreinte digitale**
7. Collez votre **SHA-1** (faites-le pour debug ET release)

### 4. Télécharger google-services.json

1. Dans Firebase Console → **Paramètres du projet** → **Général**
2. Descendez à votre app Android
3. Cliquez sur **Télécharger google-services.json**
4. **Placez le fichier dans** : `android/app/google-services.json`

### 5. Vérifier le Client ID

Dans Firebase Console → **Authentication** → **Fournisseurs de connexion** → **Google** :
- Activez Google si ce n'est pas fait
- Notez le **ID client Web** (commence par `XXX.apps.googleusercontent.com`)

Ce Client ID doit correspondre à celui dans :
- `src/firebase/auth.ts` (ligne 20)
- `capacitor.config.ts` (ligne 27)

**Client ID actuel utilisé** : 
```
569943827846-9mtqlucqe3qqk0vtkukg3o4lvbg48b5q.apps.googleusercontent.com
```

⚠️ **Vérifiez que c'est le bon Client ID pour votre projet Firebase !**

### 6. Modifier build.gradle (si nécessaire)

Vérifiez que `android/build.gradle` contient :

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

Et dans `android/app/build.gradle`, à la fin du fichier :

```gradle
apply plugin: 'com.google.gms.google-services'
```

### 7. Build et test

```bash
# Installer les dépendances
npm install

# Build l'app
npm run build

# Synchroniser avec Android
npm run android:sync

# Ouvrir dans Android Studio
npm run android:open

# Ou directement builder l'APK
npm run android:build:debug
```

## 🧪 Test

### Sur le web (localhost)

```bash
npm run dev
```

La connexion Google ouvrira un popup (méthode web standard).

### Sur Android (APK)

1. Installez l'APK sur votre appareil
2. Cliquez sur "Se connecter avec Google"
3. Une fenêtre native Android s'ouvrira
4. Sélectionnez votre compte Google
5. Connexion réussie ✅

## 🐛 Dépannage

### Erreur : "Developer Error" ou "Error 10"

**Cause** : SHA-1 manquant ou incorrect dans Firebase Console

**Solution** :
1. Obtenez le bon SHA-1 avec `./gradlew signingReport`
2. Ajoutez-le dans Firebase Console
3. Re-téléchargez `google-services.json`
4. Placez-le dans `android/app/`
5. Rebuilder l'app

### Erreur : "API not enabled"

**Cause** : Google Sign-In API pas activée

**Solution** :
1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionnez votre projet
3. API & Services → Bibliothèque
4. Cherchez "Google+ API" et activez-la

### Erreur : "The package name does not match"

**Cause** : Le package name dans Firebase ne correspond pas

**Solution** :
- Package name doit être : `com.loicberthod.onykroua`
- Vérifiez dans `capacitor.config.ts` → `appId`
- Vérifiez dans Firebase Console → App Android

### Connexion fonctionne sur web mais pas sur Android

**Causes possibles** :
1. `google-services.json` manquant dans `android/app/`
2. SHA-1 pas configuré dans Firebase
3. Client ID incorrect

**Solution** :
1. Vérifiez toutes les étapes ci-dessus
2. Nettoyez et rebuilder :
   ```bash
   cd android
   ./gradlew clean
   cd ..
   npm run build
   npm run android:sync
   npm run android:build:debug
   ```

## 📝 Fichiers modifiés

- ✅ `package.json` - Ajout de `@codetrix-studio/capacitor-google-auth`
- ✅ `capacitor.config.ts` - Configuration GoogleAuth
- ✅ `src/firebase/auth.ts` - Détection plateforme + méthodes adaptées
- ⚠️ `android/app/google-services.json` - **À télécharger depuis Firebase**

## 🔐 Sécurité

- **NE JAMAIS** commiter `google-services.json` en production
- **NE JAMAIS** commiter les keystores
- Le fichier `.gitignore` est déjà configuré pour les exclure

## ✅ Checklist

- [ ] Installer les dépendances (`npm install`)
- [ ] Obtenir le SHA-1 du keystore debug
- [ ] Ajouter le SHA-1 dans Firebase Console
- [ ] Télécharger `google-services.json`
- [ ] Placer `google-services.json` dans `android/app/`
- [ ] Vérifier le Client ID dans `auth.ts` et `capacitor.config.ts`
- [ ] Build et sync (`npm run build && npm run android:sync`)
- [ ] Tester sur appareil Android
- [ ] Obtenir SHA-1 du keystore release (pour production)
- [ ] Ajouter SHA-1 release dans Firebase Console

## 📖 Ressources

- [Capacitor Google Auth Plugin](https://github.com/CodetrixStudio/CapacitorGoogleAuth)
- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Google Sign-In Android](https://developers.google.com/identity/sign-in/android/start)

## 🎯 Résumé

Le login fonctionne maintenant :
- ✅ **Email/Password** : Fonctionne sur web ET Android (aucune config supplémentaire)
- ✅ **Google Sign-In** : Adapté pour web (popup) et Android (natif)
- ✅ **Détection automatique** : Le code détecte la plateforme et utilise la bonne méthode

Une fois configuré correctement, l'utilisateur pourra se connecter avec Google dans l'APK Android ! 🎉
