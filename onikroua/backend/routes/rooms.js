const express = require('express');
const router = express.Router();
const { admin, db } = require('../firebaseAdmin');

// Middleware d'authentification
const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token manquant' });
  }

  const token = authHeader.split('Bearer ')[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = { uid: decodedToken.uid, email: decodedToken.email };
    next();
  } catch (error) {
    console.error('Erreur vérification token:', error);
    return res.status(401).json({ error: 'Token invalide' });
  }
};

// Génère un code de room court
const generateRoomId = () => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let result = '';
  for (let i = 0; i < 6; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

// POST /api/rooms - Créer une room
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { language } = req.body;
    
    if (!language || !['it', 'es'].includes(language)) {
      return res.status(400).json({ error: 'Langue invalide (it ou es requis)' });
    }

    const roomId = generateRoomId();
    const roomData = {
      hostUid: req.user.uid,
      status: 'waiting',
      createdAt: Date.now(),
      language,
      players: {
        [req.user.uid]: {
          ready: true,
          score: 0
        }
      },
      currentSessionId: null
    };

    await db.ref(`rooms/${roomId}`).set(roomData);

    res.status(201).json({ roomId });
  } catch (error) {
    console.error('Erreur création room:', error);
    res.status(500).json({ error: 'Erreur création room' });
  }
});

// POST /api/rooms/:roomId/join - Rejoindre une room
router.post('/:roomId/join', authMiddleware, async (req, res) => {
  try {
    const { roomId } = req.params;
    const roomRef = db.ref(`rooms/${roomId}`);
    
    const snapshot = await roomRef.once('value');
    const room = snapshot.val();

    if (!room) {
      return res.status(404).json({ error: 'Room non trouvée' });
    }

    if (room.status !== 'waiting') {
      return res.status(400).json({ error: 'Cette room n\'est plus disponible' });
    }

    const playerCount = Object.keys(room.players || {}).length;
    
    // Vérifie si l'utilisateur est déjà dans la room
    if (room.players && room.players[req.user.uid]) {
      return res.json({ room: { id: roomId, ...room } });
    }

    if (playerCount >= 2) {
      return res.status(400).json({ error: 'Room complète' });
    }

    // Ajoute le joueur
    await roomRef.child(`players/${req.user.uid}`).set({
      ready: true,
      score: 0
    });

    // Récupère la room mise à jour
    const updatedSnapshot = await roomRef.once('value');
    
    res.json({ room: { id: roomId, ...updatedSnapshot.val() } });
  } catch (error) {
    console.error('Erreur join room:', error);
    res.status(500).json({ error: 'Erreur pour rejoindre la room' });
  }
});

// GET /api/rooms/:roomId - Récupérer une room
router.get('/:roomId', authMiddleware, async (req, res) => {
  try {
    const { roomId } = req.params;
    const snapshot = await db.ref(`rooms/${roomId}`).once('value');
    const room = snapshot.val();

    if (!room) {
      return res.status(404).json({ error: 'Room non trouvée' });
    }

    res.json({ room: { id: roomId, ...room } });
  } catch (error) {
    console.error('Erreur récupération room:', error);
    res.status(500).json({ error: 'Erreur récupération room' });
  }
});

module.exports = router;
