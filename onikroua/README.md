# Onikroua - Duo Language Learning App

Application web permettant à 2 francophones d'apprendre ensemble l'italien et l'espagnol via des quiz en duo.

## Architecture

```
onikroua/
├── frontend/     # Vue 3 + TypeScript + Vite
├── backend/      # Node.js Express API
└── infra/        # Configuration Nginx + Systemd
```

## Technologies

- **Frontend**: Vue 3, TypeScript, Vite, Pinia, Vue Router
- **Backend**: Node.js, Express
- **Base de données**: Firebase Realtime Database
- **Auth**: Firebase Authentication
- **Déploiement**: VPS avec Nginx reverse proxy

## Installation rapide

### Prérequis

- Node.js 18+
- Compte Firebase avec Realtime Database activé
- Service Account Firebase (pour le backend)

### Frontend

```bash
cd frontend
cp .env.example .env
# Remplir les variables Firebase
npm install
npm run dev
```

### Backend

```bash
cd backend
cp .env.example .env
# Configurer GOOGLE_APPLICATION_CREDENTIALS avec le chemin du service account
npm install
npm run dev
```

## Déploiement VPS

Voir les fichiers dans `infra/` pour la configuration Nginx et Systemd.

## Flow utilisateur

1. **Connexion** - Inscription/connexion via email + password
2. **Lobby** - Choix de la langue (IT/ES), créer ou rejoindre une room
3. **Room** - Voir les joueurs, lancer une session quiz, répondre aux questions
4. **Chat** - Communication en temps réel entre les joueurs

## Licence

MIT
