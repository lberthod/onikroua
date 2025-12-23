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

// Banque de questions statique
const QUIZ_BANK = {
  it: [
    {
      id: 'it1',
      prompt: 'Comment dit-on "Bonjour" en italien ?',
      choices: ['Buongiorno', 'Hola', 'Guten Tag', 'Hello'],
      correctIndex: 0,
      explanationFR: '"Buongiorno" signifie littéralement "bonne journée" et s\'utilise comme salutation.'
    },
    {
      id: 'it2',
      prompt: 'Que signifie "Grazie" ?',
      choices: ['Au revoir', 'S\'il vous plaît', 'Merci', 'Excusez-moi'],
      correctIndex: 2,
      explanationFR: '"Grazie" est le mot italien pour "merci".'
    },
    {
      id: 'it3',
      prompt: 'Comment dit-on "Je m\'appelle" en italien ?',
      choices: ['Mi chiamo', 'Me llamo', 'Ich heiße', 'My name is'],
      correctIndex: 0,
      explanationFR: '"Mi chiamo" vient du verbe "chiamarsi" (s\'appeler).'
    },
    {
      id: 'it4',
      prompt: 'Quel est le mot italien pour "eau" ?',
      choices: ['Vino', 'Acqua', 'Latte', 'Caffè'],
      correctIndex: 1,
      explanationFR: '"Acqua" signifie eau. "Vino" = vin, "Latte" = lait, "Caffè" = café.'
    },
    {
      id: 'it5',
      prompt: 'Comment dit-on le chiffre "trois" en italien ?',
      choices: ['Due', 'Quattro', 'Tre', 'Cinque'],
      correctIndex: 2,
      explanationFR: 'Les chiffres: uno (1), due (2), tre (3), quattro (4), cinque (5).'
    },
    {
      id: 'it6',
      prompt: 'Que signifie "Arrivederci" ?',
      choices: ['Bonjour', 'Bonsoir', 'Au revoir', 'Bonne nuit'],
      correctIndex: 2,
      explanationFR: '"Arrivederci" est une formule de politesse pour dire au revoir.'
    },
    {
      id: 'it7',
      prompt: 'Comment dit-on "oui" en italien ?',
      choices: ['No', 'Sì', 'Forse', 'Mai'],
      correctIndex: 1,
      explanationFR: '"Sì" = oui, "No" = non, "Forse" = peut-être, "Mai" = jamais.'
    },
    {
      id: 'it8',
      prompt: 'Quel est le mot italien pour "maison" ?',
      choices: ['Casa', 'Cassa', 'Cosa', 'Cena'],
      correctIndex: 0,
      explanationFR: '"Casa" signifie maison. Attention aux mots similaires !'
    },
    {
      id: 'it9',
      prompt: 'Comment dit-on "je suis" en italien ?',
      choices: ['Tu sei', 'Io sono', 'Lui è', 'Noi siamo'],
      correctIndex: 1,
      explanationFR: 'Conjugaison de "essere": io sono, tu sei, lui/lei è, noi siamo.'
    },
    {
      id: 'it10',
      prompt: 'Que signifie "Prego" ?',
      choices: ['Merci', 'De rien / Je vous en prie', 'Pardon', 'Excusez-moi'],
      correctIndex: 1,
      explanationFR: '"Prego" s\'utilise pour répondre à "Grazie" ou pour inviter quelqu\'un.'
    }
  ],
  es: [
    {
      id: 'es1',
      prompt: 'Comment dit-on "Bonjour" en espagnol ?',
      choices: ['Buongiorno', 'Hola', 'Guten Tag', 'Hello'],
      correctIndex: 1,
      explanationFR: '"Hola" est la salutation informelle. "Buenos días" pour "bonjour" formel.'
    },
    {
      id: 'es2',
      prompt: 'Que signifie "Gracias" ?',
      choices: ['Au revoir', 'S\'il vous plaît', 'Merci', 'Excusez-moi'],
      correctIndex: 2,
      explanationFR: '"Gracias" est le mot espagnol pour "merci".'
    },
    {
      id: 'es3',
      prompt: 'Comment dit-on "Je m\'appelle" en espagnol ?',
      choices: ['Mi chiamo', 'Me llamo', 'Ich heiße', 'My name is'],
      correctIndex: 1,
      explanationFR: '"Me llamo" vient du verbe "llamarse" (s\'appeler).'
    },
    {
      id: 'es4',
      prompt: 'Quel est le mot espagnol pour "eau" ?',
      choices: ['Vino', 'Agua', 'Leche', 'Café'],
      correctIndex: 1,
      explanationFR: '"Agua" signifie eau. "Vino" = vin, "Leche" = lait, "Café" = café.'
    },
    {
      id: 'es5',
      prompt: 'Comment dit-on le chiffre "trois" en espagnol ?',
      choices: ['Dos', 'Cuatro', 'Tres', 'Cinco'],
      correctIndex: 2,
      explanationFR: 'Les chiffres: uno (1), dos (2), tres (3), cuatro (4), cinco (5).'
    },
    {
      id: 'es6',
      prompt: 'Que signifie "Adiós" ?',
      choices: ['Bonjour', 'Bonsoir', 'Au revoir', 'Bonne nuit'],
      correctIndex: 2,
      explanationFR: '"Adiós" est le mot pour dire au revoir en espagnol.'
    },
    {
      id: 'es7',
      prompt: 'Comment dit-on "oui" en espagnol ?',
      choices: ['No', 'Sí', 'Quizás', 'Nunca'],
      correctIndex: 1,
      explanationFR: '"Sí" = oui, "No" = non, "Quizás" = peut-être, "Nunca" = jamais.'
    },
    {
      id: 'es8',
      prompt: 'Quel est le mot espagnol pour "maison" ?',
      choices: ['Casa', 'Caza', 'Cosa', 'Cena'],
      correctIndex: 0,
      explanationFR: '"Casa" signifie maison. "Caza" = chasse, "Cosa" = chose, "Cena" = dîner.'
    },
    {
      id: 'es9',
      prompt: 'Comment dit-on "je suis" en espagnol ?',
      choices: ['Tú eres', 'Yo soy', 'Él es', 'Nosotros somos'],
      correctIndex: 1,
      explanationFR: 'Conjugaison de "ser": yo soy, tú eres, él/ella es, nosotros somos.'
    },
    {
      id: 'es10',
      prompt: 'Que signifie "De nada" ?',
      choices: ['Merci', 'De rien', 'Pardon', 'Excusez-moi'],
      correctIndex: 1,
      explanationFR: '"De nada" signifie littéralement "de rien" et répond à "Gracias".'
    }
  ]
};

// Génère un ID de session unique
const generateSessionId = () => {
  return 'sess_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 9);
};

// Sélectionne des questions aléatoires
const selectQuestions = (language, count = 3) => {
  const questions = QUIZ_BANK[language] || [];
  const shuffled = [...questions].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, count);
};

// POST /api/sessions/start - Démarrer une session
router.post('/start', authMiddleware, async (req, res) => {
  try {
    const { roomId } = req.body;
    
    if (!roomId) {
      return res.status(400).json({ error: 'roomId requis' });
    }

    // Vérifie la room
    const roomRef = db.ref(`rooms/${roomId}`);
    const roomSnapshot = await roomRef.once('value');
    const room = roomSnapshot.val();

    if (!room) {
      return res.status(404).json({ error: 'Room non trouvée' });
    }

    if (room.hostUid !== req.user.uid) {
      return res.status(403).json({ error: 'Seul l\'hôte peut démarrer la session' });
    }

    if (room.status !== 'waiting') {
      return res.status(400).json({ error: 'La room n\'est pas en attente' });
    }

    const playerCount = Object.keys(room.players || {}).length;
    if (playerCount < 2) {
      return res.status(400).json({ error: 'Il faut 2 joueurs pour démarrer' });
    }

    // Crée la session
    const sessionId = generateSessionId();
    const questions = selectQuestions(room.language, 3);
    
    // Prépare les rounds (sans exposer correctIndex au client via realtime DB)
    const rounds = {};
    questions.forEach((q, index) => {
      rounds[`round_${index}`] = {
        type: 'mcq',
        prompt: q.prompt,
        choices: q.choices,
        // Note: correctIndex et explanation sont stockés mais les règles DB
        // devraient empêcher la lecture directe par les clients
        // Pour le MVP, on les garde ici et on gère côté serveur
        _correctIndex: q.correctIndex,
        _explanationFR: q.explanationFR,
        answers: {},
        result: null
      };
    });

    const sessionData = {
      roomId,
      language: room.language,
      startedAt: Date.now(),
      state: 'active',
      roundIndex: 0,
      rounds
    };

    // Sauvegarde la session
    await db.ref(`sessions/${sessionId}`).set(sessionData);

    // Met à jour la room
    await roomRef.update({
      currentSessionId: sessionId,
      status: 'playing'
    });

    res.json({ sessionId });
  } catch (error) {
    console.error('Erreur démarrage session:', error);
    res.status(500).json({ error: 'Erreur démarrage session' });
  }
});

// POST /api/sessions/:sessionId/answer - Soumettre une réponse
router.post('/:sessionId/answer', authMiddleware, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { roundId, value } = req.body;

    if (roundId === undefined || value === undefined) {
      return res.status(400).json({ error: 'roundId et value requis' });
    }

    const sessionRef = db.ref(`sessions/${sessionId}`);
    const sessionSnapshot = await sessionRef.once('value');
    const session = sessionSnapshot.val();

    if (!session) {
      return res.status(404).json({ error: 'Session non trouvée' });
    }

    if (session.state !== 'active') {
      return res.status(400).json({ error: 'Session non active' });
    }

    const round = session.rounds[roundId];
    if (!round) {
      return res.status(404).json({ error: 'Round non trouvé' });
    }

    // Vérifie si l'utilisateur a déjà répondu
    if (round.answers && round.answers[req.user.uid]) {
      return res.status(400).json({ error: 'Vous avez déjà répondu' });
    }

    // Enregistre la réponse
    await sessionRef.child(`rounds/${roundId}/answers/${req.user.uid}`).set({
      value,
      ts: Date.now()
    });

    // Récupère la room pour connaître les joueurs
    const roomSnapshot = await db.ref(`rooms/${session.roomId}`).once('value');
    const room = roomSnapshot.val();
    const playerUids = Object.keys(room.players || {});

    // Récupère les réponses mises à jour
    const updatedSessionSnapshot = await sessionRef.once('value');
    const updatedSession = updatedSessionSnapshot.val();
    const updatedRound = updatedSession.rounds[roundId];
    const answersCount = Object.keys(updatedRound.answers || {}).length;

    // Si les deux joueurs ont répondu, calcule le résultat
    if (answersCount >= 2) {
      const correctIndex = updatedRound._correctIndex;
      const explanation = updatedRound._explanationFR;

      // Calcule les scores
      const scores = {};
      for (const uid of playerUids) {
        const answer = updatedRound.answers[uid];
        if (answer && answer.value === correctIndex) {
          scores[uid] = 10; // Points pour bonne réponse
          // Met à jour le score du joueur dans la room
          const currentScore = room.players[uid]?.score || 0;
          await db.ref(`rooms/${session.roomId}/players/${uid}/score`).set(currentScore + 10);
        } else {
          scores[uid] = 0;
        }
      }

      // Écrit le résultat
      await sessionRef.child(`rounds/${roundId}/result`).set({
        correctIndex,
        scores
      });

      // Ajoute l'explication (maintenant visible)
      await sessionRef.child(`rounds/${roundId}/explanation`).set(explanation);

      // Passe au round suivant ou termine la session
      const roundKeys = Object.keys(updatedSession.rounds);
      const currentRoundIndex = roundKeys.indexOf(roundId);
      
      if (currentRoundIndex < roundKeys.length - 1) {
        // Prochain round
        await sessionRef.child('roundIndex').set(currentRoundIndex + 1);
      } else {
        // Fin de session
        await sessionRef.child('state').set('finished');
        await db.ref(`rooms/${session.roomId}/status`).set('finished');
      }
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Erreur envoi réponse:', error);
    res.status(500).json({ error: 'Erreur envoi réponse' });
  }
});

// GET /api/sessions/:sessionId - Récupérer une session
router.get('/:sessionId', authMiddleware, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const snapshot = await db.ref(`sessions/${sessionId}`).once('value');
    const session = snapshot.val();

    if (!session) {
      return res.status(404).json({ error: 'Session non trouvée' });
    }

    // Nettoie les données sensibles avant envoi
    const sanitizedSession = { ...session };
    if (sanitizedSession.rounds) {
      for (const roundId in sanitizedSession.rounds) {
        delete sanitizedSession.rounds[roundId]._correctIndex;
        delete sanitizedSession.rounds[roundId]._explanationFR;
      }
    }

    res.json({ session: { id: sessionId, ...sanitizedSession } });
  } catch (error) {
    console.error('Erreur récupération session:', error);
    res.status(500).json({ error: 'Erreur récupération session' });
  }
});

module.exports = router;
