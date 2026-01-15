# 🚀 Guide de Déploiement Play Store - Onykroua

## Préparation avant le déploiement

### 1️⃣ Créer le Keystore (une seule fois)

Le keystore est le fichier qui signe votre application. **GARDEZ-LE PRÉCIEUSEMENT !**

```bash
cd /Users/berthod/Desktop/onykroua/onikroua/frontend-android
chmod +x create-keystore.sh
./create-keystore.sh
```

**Informations à fournir lors de la création :**
- **Mot de passe keystore** : choisissez un mot de passe fort
- **Mot de passe clé** : peut être le même que le keystore
- **Nom et prénom** : Loic Berthod
- **Nom de l'organisation** : Onykroua
- **Ville** : votre ville
- **Pays** : CH (pour Suisse)

⚠️ **IMPORTANT** : Sauvegardez `app/onykroua-release.keystore` et les mots de passe dans un endroit sûr (ex: gestionnaire de mots de passe). Sans eux, vous ne pourrez plus publier de mises à jour !

### 2️⃣ Configurer keystore.properties

Créez le fichier `keystore.properties` à la racine du projet Android :

```bash
cd /Users/berthod/Desktop/onykroua/onikroua/frontend-android
cp keystore.properties.example keystore.properties
```

Éditez `keystore.properties` avec vos vraies valeurs :
```properties
storePassword=VOTRE_MOT_DE_PASSE_KEYSTORE
keyPassword=VOTRE_MOT_DE_PASSE_KEY
keyAlias=onykroua-key
storeFile=app/onykroua-release.keystore
```

### 3️⃣ Configurer local.properties avec l'API Key Gemini

Créez/éditez le fichier `local.properties` :

```bash
cd /Users/berthod/Desktop/onykroua/onikroua/frontend-android
```

Ajoutez cette ligne dans `local.properties` (créez le fichier s'il n'existe pas) :
```properties
GEMINI_API_KEY=AIzaSyCkan4wo81C2uUVkekdBLALWV3zr20QM28
```

⚠️ **SÉCURITÉ** : Ces fichiers sont dans `.gitignore` et ne seront PAS commités sur Git.

---

## 📦 Génération de l'App Bundle

### Étape 1 : Nettoyer le projet

```bash
cd /Users/berthod/Desktop/onykroua/onikroua/frontend-android
./gradlew clean
```

### Étape 2 : Générer l'Android App Bundle (.aab)

```bash
./gradlew bundleRelease
```

✅ Le fichier `.aab` sera généré ici :
```
app/build/outputs/bundle/release/app-release.aab
```

### Étape 3 : Vérifier la signature

```bash
jarsigner -verify -verbose -certs app/build/outputs/bundle/release/app-release.aab
```

Vous devriez voir : `jar verified.`

---

## 🏪 Publication sur le Play Store

### 1️⃣ Préparer les assets

Avant de publier, préparez :

**Captures d'écran requises :**
- 📱 Téléphone : au moins 2 captures (1080x1920 ou similaire)
- 📱 Tablette 7" : au moins 2 captures (1024x1920 recommandé)

**Icône de l'application :**
- 512x512 px, PNG, 32-bit avec alpha

**Feature graphic :**
- 1024x500 px, JPEG ou PNG 24-bit

**Description courte :**
- Maximum 80 caractères
- Exemple : "Apprenez l'italien avec Gemini AI - Conversations interactives"

**Description complète :**
- Maximum 4000 caractères
- Décrivez les fonctionnalités principales

### 2️⃣ Se connecter à la Play Console

1. Allez sur [Google Play Console](https://play.google.com/console)
2. Connectez-vous avec votre compte Google développeur
3. Créez une nouvelle application

### 3️⃣ Remplir les informations

**Fiche de l'application :**
- Nom : Onykroua
- Description courte et complète
- Catégorie : Éducation
- Type de contenu : Apprentissage des langues

**Confidentialité :**
- Politique de confidentialité (URL requise)
- Déclarations de confidentialité des données

**Classification du contenu :**
- Remplir le questionnaire
- Pour une app éducative : généralement "Tous publics"

### 4️⃣ Uploader l'App Bundle

1. Dans la Play Console, allez dans **Production** (ou **Test interne**/Test fermé** pour tester d'abord)
2. Cliquez sur **Créer une version**
3. Uploadez `app-release.aab`
4. Remplissez les notes de version
5. Cliquez sur **Enregistrer** puis **Vérifier la version**
6. Cliquez sur **Déployer vers la production**

⏱️ La validation Google prend généralement **quelques heures à quelques jours**.

---

## 🔄 Mise à jour de l'application

Pour publier une mise à jour :

### 1. Incrémenter la version

Éditez `app/build.gradle` :

```gradle
versionCode 2  // Augmenter de 1
versionName "1.1"  // Nouvelle version
```

### 2. Régénérer l'App Bundle

```bash
./gradlew clean
./gradlew bundleRelease
```

### 3. Uploader dans Play Console

Suivez les mêmes étapes que pour la publication initiale.

---

## ✅ Checklist finale avant publication

- [ ] Keystore créé et sauvegardé
- [ ] `keystore.properties` configuré
- [ ] `local.properties` avec GEMINI_API_KEY configuré
- [ ] App Bundle généré avec succès
- [ ] App Bundle vérifié avec jarsigner
- [ ] Toutes les captures d'écran préparées
- [ ] Icônes préparées (512x512)
- [ ] Feature graphic préparé (1024x500)
- [ ] Description de l'app rédigée
- [ ] Politique de confidentialité rédigée et hébergée
- [ ] Compte développeur Google Play actif (25$ one-time)
- [ ] Testé l'app en mode release sur un vrai appareil

---

## 🆘 Dépannage

### Erreur "keystore not found"
- Vérifiez que `keystore.properties` pointe vers le bon chemin
- Le fichier keystore doit être dans `app/onykroua-release.keystore`

### Erreur "GEMINI_API_KEY not found"
- Vérifiez que `local.properties` contient bien `GEMINI_API_KEY=...`
- Faites `./gradlew clean` puis rebuild

### L'app crash au démarrage (mode release)
- Vérifiez les règles ProGuard dans `proguard-rules.pro`
- Testez l'APK de release avant de publier

### Permissions refusées
- Vérifiez que toutes les permissions sont dans `AndroidManifest.xml`
- La permission RECORD_AUDIO nécessite l'acceptation utilisateur

---

## 📧 Support

Pour toute question sur le déploiement, consultez :
- [Documentation Google Play Console](https://support.google.com/googleplay/android-developer)
- [Guide de publication Android](https://developer.android.com/studio/publish)
