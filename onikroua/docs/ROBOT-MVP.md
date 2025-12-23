# 🤖 Robot Pédagogique - MVP Documentation

## Vue d'ensemble

Le Robot Pédagogique est un MVP démontrant l'apprentissage oral des langues via une interaction vocale en streaming temps réel. L'utilisateur peut parler naturellement avec un robot qui écoute, répond et reformule gentiment les phrases.

## Architecture

### Stack Technique

- **Frontend**: Vue 3 + TypeScript
- **Backend**: Node.js + Express + WebSocket
- **IA Audio**: OpenAI GPT-4 Realtime API (gpt-4o-realtime-preview-2024-12-17)
- **Transport**: WebSocket pour streaming audio bidirectionnel
- **Format Audio**: PCM16 à 24kHz

### Composants

#### Backend (`/backend/robotServer.js`)

Le serveur WebSocket gère:
- Connexion à l'API OpenAI Realtime
- Streaming audio bidirectionnel (micro → IA → haut-parleurs)
- Gestion des états (idle, listening, thinking, speaking)
- Logique pédagogique (instructions pour l'IA)
- Interruptions (barge-in)

#### Frontend (`/frontend/src/views/RobotView.vue`)

L'interface utilisateur gère:
- Capture du microphone en streaming
- Lecture audio en streaming
- Affichage des états du robot (idle, listening, thinking, speaking)
- Transcription en temps réel
- Interruption automatique du robot quand l'utilisateur parle

## Fonctionnalités Clés

### 1. Streaming Audio Bidirectionnel

- **Capture micro**: AudioWorkletNode capture l'audio en chunks de 200ms
- **Conversion**: Float32 → PCM16 → Base64 pour transmission WebSocket
- **Lecture**: Base64 → PCM16 → Float32 → AudioBuffer pour lecture

### 2. Barge-in (Interruption)

Le système détecte automatiquement quand l'utilisateur parle:
- Analyse de l'amplitude audio en temps réel
- Détection de parole avec seuil de silence
- Interruption immédiate du robot
- Envoi d'un message `interrupt` au serveur
- Vidage de la queue audio

### 3. États UI

- **idle**: Prêt à écouter
- **listening**: L'utilisateur parle
- **thinking**: L'IA traite la réponse
- **speaking**: Le robot parle

### 4. Logique Pédagogique

Scénario: **"Se présenter" (A1)**

Le robot:
- Pose des questions simples sur le nom, l'âge, l'origine
- Garde des réponses courtes (1-2 phrases)
- Encourage toujours
- Reformule gentiment sans critiquer
- Reste concentré sur le sujet

## Installation

### 1. Backend

```bash
cd backend
npm install
```

### 2. Configuration

Ajoutez votre clé API OpenAI dans `.env`:

```env
OPENAI_API_KEY=sk-your-openai-api-key-here
```

**Important**: Vous devez avoir accès à l'API Realtime d'OpenAI.

### 3. Démarrage

**Backend**:
```bash
cd backend
npm run dev
```

Le serveur démarre sur `http://localhost:3001`
WebSocket disponible sur `ws://localhost:3001/robot`

**Frontend**:
```bash
cd frontend
npm run dev
```

L'application démarre sur `http://localhost:5173`

### 4. Accès

Naviguez vers: `http://localhost:5173/robot`

## Utilisation

1. **Autoriser le microphone** quand le navigateur le demande
2. **Cliquer sur "Démarrer la conversation"**
3. **Attendre** que le robot vous salue
4. **Parler naturellement** dans votre micro
5. **Interrompre** le robot à tout moment en parlant
6. **Observer** la transcription et les corrections en temps réel

## Flux de Données

```
Utilisateur parle
    ↓
Microphone → AudioWorklet
    ↓
Float32 → PCM16 → Base64
    ↓
WebSocket → Backend
    ↓
OpenAI Realtime API
    ↓
Réponse IA (audio + texte)
    ↓
WebSocket → Frontend
    ↓
Base64 → PCM16 → Float32
    ↓
AudioBuffer → Haut-parleurs
```

## Détection de Parole

L'AudioWorklet analyse l'amplitude audio:
- **Seuil**: 0.01 (amplitude moyenne)
- **Silence**: 10 frames consécutifs sous le seuil
- **Action**: Envoi d'événements `speaking: true/false`

Quand `speaking: true` et `robotState === 'speaking'`:
→ Interruption automatique

## Limitations du MVP

- ✅ Un seul scénario: "Se présenter"
- ✅ Pas de persistance des conversations
- ✅ Pas de métriques d'apprentissage
- ✅ Pas de support multi-utilisateurs
- ✅ Nécessite une connexion stable
- ✅ Fonctionne uniquement en local

## Améliorations Futures

- Support de multiples scénarios pédagogiques
- Système de progression et niveaux
- Analyse de prononciation
- Feedback visuel sur les erreurs
- Historique des conversations
- Mode hors-ligne avec modèles locaux
- Support mobile

## Dépannage

### Le robot ne répond pas

- Vérifiez que `OPENAI_API_KEY` est configurée
- Vérifiez que vous avez accès à l'API Realtime
- Consultez les logs du backend

### Pas de son

- Vérifiez les permissions du microphone
- Vérifiez le volume de votre système
- Ouvrez la console du navigateur pour voir les erreurs

### Latence élevée

- Vérifiez votre connexion internet
- L'API Realtime nécessite une bande passante stable
- Réduisez la taille des chunks audio si nécessaire

## Support

Pour toute question ou problème, consultez:
- Logs backend: `console.log` dans le terminal
- Logs frontend: Console du navigateur (F12)
- Documentation OpenAI Realtime: https://platform.openai.com/docs/guides/realtime

## Licence

Projet pédagogique - Usage interne uniquement
