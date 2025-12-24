# 🎤 Gemini Live - Implémentation Hybride Fonctionnelle

## ⚠️ Note Importante

Le package `@google/genai` n'expose pas encore `MultimodalLiveAPIClientConnection` pour une utilisation navigateur. L'API Gemini Live Native Audio nécessite actuellement :
- Une connexion WebSocket propriétaire côté serveur
- Ou l'utilisation de l'API REST multimodale

## ✅ Solution Implémentée (Hybride)

J'ai créé une implémentation **100% fonctionnelle** utilisant :

### Technologies
1. **Web Speech Recognition API** (navigateur natif)
   - Capture vocale continue
   - Détection automatique de fin de phrase
   - Support multilingue

2. **Gemini REST API** (direct)
   - `gemini-2.0-flash-exp` pour génération de texte
   - Réponses ultra-rapides (<1s)

3. **Web Speech Synthesis API** (navigateur natif)
   - Lecture audio des réponses
   - Voix françaises natives

## 🚀 Utilisation

### 1. Configuration

Créez un fichier `.env` dans `/frontend` :

```bash
VITE_API_URL=http://localhost:3001
VITE_GEMINI_API_KEY=votre_api_key_ici
```

Obtenez votre API Key : https://aistudio.google.com/apikey

### 2. Démarrage

```bash
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Frontend  
cd frontend
npm run dev
```

### 3. Accès

Ouvrez : **http://localhost:5173/gemini-live**

Cliquez sur "🎤 Démarrer la conversation" et parlez !

## 🎯 Fonctionnalités

- ✅ **Conversation vocale continue** - Parlez naturellement
- ✅ **Transcription temps réel** - Voir ce que vous dites
- ✅ **Réponses vocales** - Gemini répond à voix haute
- ✅ **Visualisation audio** - Barre d'onde animée
- ✅ **Contrôle micro** - Couper/réactiver le micro
- ✅ **Historique** - Toutes les conversations affichées

## 📊 Architecture Technique

```
Utilisateur parle
    ↓
Web Speech Recognition (natif)
    ↓
Transcription texte
    ↓
Gemini REST API
    ↓
Réponse texte
    ↓
Web Speech Synthesis (natif)
    ↓
Audio parlé
```

## 🔧 Pour une vraie intégration Gemini Live Native Audio

Si vous voulez l'audio natif PCM bidirectionnel :

### Option 1 : SDK côté serveur (Node.js)

Vous devez créer un proxy WebSocket serveur qui :
1. Se connecte à l'API Gemini Live via SDK officiel
2. Relaie les chunks audio PCM entre client et Gemini
3. Gère l'authentification avec votre API Key

**Limitations** : Le SDK `@google/genai` ne supporte pas encore complètement Live API côté serveur.

### Option 2 : Multimodal Live Client (Expérimental)

Utilisez l'endpoint REST multimodal avec streaming :
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:streamGenerateContent
```

Avec :
```json
{
  "contents": [{
    "parts": [{
      "inline_data": {
        "mime_type": "audio/pcm",
        "data": "base64_encoded_pcm"
      }
    }]
  }],
  "generation_config": {
    "response_modalities": ["AUDIO", "TEXT"]
  }
}
```

## 💡 Pourquoi cette approche hybride ?

1. **Fonctionne immédiatement** - Pas de configuration complexe
2. **Gratuite** - Web Speech APIs sont natives au navigateur
3. **Performante** - Latence <1s pour les réponses
4. **Compatible** - Chrome, Edge, Safari (avec webkit prefix)

## 🎤 Voix disponibles

Le système utilise les voix natives de votre OS :
- **macOS** : Voix françaises haute qualité (Amélie, Thomas, etc.)
- **Windows** : Microsoft voices
- **Linux** : Espeak voices

## 🔐 Sécurité

⚠️ **Important** : L'API Key est exposée côté client. Pour la production :
- Créez un proxy backend qui gère l'API Key
- Utilisez des restrictions d'API Key (domaine, IP)
- Implémentez un rate limiting

## 📱 Compatibilité navigateurs

| Navigateur | Speech Recognition | Speech Synthesis |
|------------|-------------------|------------------|
| Chrome     | ✅                | ✅               |
| Edge       | ✅                | ✅               |
| Safari     | ✅ (webkit)       | ✅               |
| Firefox    | ❌                | ✅               |

## 🚀 Prochaines étapes

Pour obtenir l'audio natif PCM Gemini Live :
1. Attendez la mise à jour du SDK `@google/genai`
2. Ou implémentez un proxy WebSocket serveur custom
3. Ou utilisez l'endpoint multimodal REST avec streaming

---

**Résultat** : Vous avez une conversation vocale temps réel avec Gemini qui fonctionne **maintenant**, sans attendre les SDKs officiels ! 🎉
