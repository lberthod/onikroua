# Onikroua Backend

API Node.js Express pour la gestion des rooms et sessions de quiz.

## Installation

```bash
npm install
```

## Configuration

Créez un fichier `.env` :

```env
PORT=3001
CORS_ORIGIN=http://localhost:5173
FIREBASE_DATABASE_URL=https://votre-projet.firebaseio.com
GOOGLE_APPLICATION_CREDENTIALS=/chemin/vers/serviceAccount.json
```

### Service Account Firebase

1. Allez dans Firebase Console > Paramètres du projet > Comptes de service
2. Cliquez sur "Générer une nouvelle clé privée"
3. Sauvegardez le fichier JSON
4. Configurez `GOOGLE_APPLICATION_CREDENTIALS` avec le chemin absolu

## Développement

```bash
npm run dev
```

Le serveur sera disponible sur http://localhost:3001

## Production

```bash
npm start
```

## Endpoints API

### Rooms

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/api/rooms` | Créer une room |
| POST | `/api/rooms/:roomId/join` | Rejoindre une room |
| GET | `/api/rooms/:roomId` | Récupérer une room |

### Sessions

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/api/sessions/start` | Démarrer une session quiz |
| POST | `/api/sessions/:sessionId/answer` | Soumettre une réponse |
| GET | `/api/sessions/:sessionId` | Récupérer une session |

### Healthcheck

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/health` | Vérifier l'état du serveur |

## Authentification

Tous les endpoints (sauf `/health`) requièrent un token Firebase ID dans le header :

```
Authorization: Bearer <firebase-id-token>
```

## Structure

```
backend/
├── index.js           # Point d'entrée Express
├── firebaseAdmin.js   # Configuration Firebase Admin SDK
└── routes/
    ├── rooms.js       # Routes des rooms
    └── sessions.js    # Routes des sessions + banque de quiz
```

## Banque de Quiz

Le fichier `routes/sessions.js` contient 10 questions pour l'italien et 10 pour l'espagnol. Pour ajouter des questions, modifiez l'objet `QUIZ_BANK`.

Format d'une question :
```javascript
{
  id: 'it1',
  prompt: 'Comment dit-on "Bonjour" en italien ?',
  choices: ['Buongiorno', 'Hola', 'Guten Tag', 'Hello'],
  correctIndex: 0,
  explanationFR: 'Explication en français...'
}
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
        ".write": "auth != null"
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
        ".write": "auth != null"
      }
    }
  }
}
```

**Sécurité des réponses** :
- Les champs `_correctIndex` et `_explanationFR` sont préfixés par `_` et les règles empêchent leur lecture directe
- Seul le backend (via Admin SDK qui bypass les règles) peut accéder à ces valeurs
- Le résultat et l'explication sont écrits par le backend une fois que tous les joueurs ont répondu

## Déploiement VPS

1. Copiez les fichiers sur le serveur
2. Installez les dépendances : `npm install --production`
3. Configurez le fichier `.env`
4. Utilisez le service systemd fourni dans `infra/systemd/`

```bash
# Copier le service
sudo cp /var/www/onikroua/infra/systemd/onikroua-api.service /etc/systemd/system/

# Activer et démarrer
sudo systemctl daemon-reload
sudo systemctl enable onikroua-api
sudo systemctl start onikroua-api

# Vérifier le status
sudo systemctl status onikroua-api
```
