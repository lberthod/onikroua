# Onikroua Frontend

Application Vue 3 + TypeScript pour l'apprentissage en duo de l'italien et l'espagnol.

## Installation

```bash
npm install
```

## Développement

```bash
# Copier et configurer les variables d'environnement
cp .env.example .env

# Lancer le serveur de développement
npm run dev
```

L'application sera disponible sur http://localhost:5173

## Build Production

```bash
npm run build
```

Les fichiers de production seront dans `dist/`.

## Configuration

Créez un fichier `.env` avec vos credentials Firebase :

```env
VITE_FIREBASE_API_KEY=votre-api-key
VITE_FIREBASE_AUTH_DOMAIN=votre-projet.firebaseapp.com
VITE_FIREBASE_DATABASE_URL=https://votre-projet.firebaseio.com
VITE_FIREBASE_PROJECT_ID=votre-projet
VITE_FIREBASE_APP_ID=votre-app-id
VITE_API_BASE_URL=/api
```

## Structure

```
src/
├── main.ts              # Point d'entrée
├── App.vue              # Composant racine
├── router/              # Configuration Vue Router
├── stores/              # Stores Pinia (auth, room)
├── firebase/            # Configuration Firebase client
├── views/               # Pages (Login, Lobby, Room)
└── components/          # Composants réutilisables
```

## Realtime DB Rules (à coller dans Firebase Console)

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "rooms": {
      "$roomId": {
        ".read": "auth != null && (data.child('players').hasChild(auth.uid) || data.child('hostUid').val() === auth.uid)",
        ".write": "auth != null",
        "players": {
          "$playerId": {
            "score": {
              ".write": "auth != null"
            }
          }
        }
      }
    },
    "sessions": {
      "$sessionId": {
        ".read": "auth != null",
        ".write": "auth != null",
        "rounds": {
          "$roundId": {
            "_correctIndex": {
              ".read": false
            },
            "_explanationFR": {
              ".read": false
            }
          }
        }
      }
    },
    "messages": {
      "$roomId": {
        ".read": "auth != null",
        ".write": "auth != null",
        "$messageId": {
          ".validate": "newData.hasChildren(['uid', 'text', 'ts']) && newData.child('uid').val() === auth.uid"
        }
      }
    }
  }
}
```

**Note importante** : Les champs `_correctIndex` et `_explanationFR` dans les sessions sont marqués comme non lisibles pour empêcher les clients de tricher. Seul le backend (avec Admin SDK) peut les lire et écrire les résultats.

## Technologies

- **Vue 3** - Framework frontend
- **TypeScript** - Typage statique
- **Vite** - Build tool
- **Pinia** - State management
- **Vue Router** - Routing
- **Firebase** - Auth + Realtime Database
