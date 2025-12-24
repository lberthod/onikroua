# 🎤 Configuration Gemini Live Audio Native

## Étape 1 : Obtenir une API Key Gemini

1. **Visitez** : https://aistudio.google.com/apikey
2. **Créez** une nouvelle API Key
3. **Copiez** la clé générée

## Étape 2 : Configuration Backend

Ajoutez votre API Key dans le fichier `.env` :

```bash
GEMINI_API_KEY=votre_api_key_ici
```

## Étape 3 : Démarrer les serveurs

### Backend
```bash
cd backend
npm run dev
```

Le serveur démarre sur `http://localhost:3001` avec WebSocket sur `/gemini-live`

### Frontend
```bash
cd frontend
npm run dev
```

Le frontend démarre sur `http://localhost:5173`

## Étape 4 : Accéder à Gemini Live

Naviguez vers : **http://localhost:5173/gemini-live**

## 🎯 Architecture

```
Frontend (Vue.js)
  ↓ getUserMedia() → PCM 16-bit mono 16kHz
WebSocket (/gemini-live)
  ↓
Backend Node.js (proxy)
  ↓
Gemini Live API
  ↑
Audio PCM 24kHz
  ↓
Frontend → AudioContext playback
```

## ⚠️ Note importante sur l'implémentation

**L'implémentation actuelle utilise un WebSocket serveur simplifié.**

Pour une vraie intégration Gemini Live Native Audio avec streaming bidirectionnel :

### Option A : Client-side direct (RECOMMANDÉ)
Utilisez le SDK `@google/genai` **directement côté frontend** :

```bash
cd frontend
npm install @google/genai
```

Puis dans votre composant Vue :
```typescript
import { GoogleGenerativeAI } from '@google/genai'

const genAI = new GoogleGenerativeAI(apiKey)
const model = genAI.getGenerativeModel({ 
  model: 'gemini-2.5-flash-native-audio'
})

// Connexion streaming avec audio natif
```

### Option B : Vertex AI (Entreprise)
Pour une solution serveur avec authentification IAM :
- Utilisez Vertex AI avec Service Account
- Plus lourd mais adapté aux environnements enterprise

## 🔧 Formats Audio

- **Entrée micro** : PCM 16-bit, mono, 16 kHz, little-endian
- **Sortie Gemini** : PCM 16-bit, mono, 24 kHz, little-endian

## 📊 Fonctionnalités disponibles

- ✅ Streaming audio bidirectionnel
- ✅ Voix naturelle (30 voix HD disponibles)
- ✅ Multilingue (24 langues)
- ✅ Faible latence (~300ms)
- ✅ VAD (détection automatique de parole)
- ✅ Barge-in (interruption naturelle)

## 💰 Tarifs (estimation)

- **Audio IN** : ~$3/h de conversation
- **Audio OUT** : ~$12/h de sortie audio

Moins cher que GPT Realtime (~$10 IN / ~$20 OUT)

## 🔗 Resources

- **API Docs** : https://ai.google.dev/api/multimodal-live
- **AI Studio** : https://aistudio.google.com/
- **Pricing** : https://ai.google.dev/pricing
