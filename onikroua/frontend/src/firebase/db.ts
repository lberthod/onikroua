import {
  ref,
  onValue,
  push,
  set,
  get,
  update,
  serverTimestamp,
  type DatabaseReference,
  type Unsubscribe
} from 'firebase/database'
import { database } from './client'
import { getQuestionsByFilter, type QuizQuestion } from '../data/quizQuestions'

// Référence vers une room
export const roomRef = (roomId: string): DatabaseReference => {
  return ref(database, `rooms/${roomId}`)
}

// Référence vers une session
export const sessionRef = (sessionId: string): DatabaseReference => {
  return ref(database, `sessions/${sessionId}`)
}

// Référence vers les messages d'une room
export const messagesRef = (roomId: string): DatabaseReference => {
  return ref(database, `messages/${roomId}`)
}

// Référence vers le profil utilisateur
export const userRef = (uid: string): DatabaseReference => {
  return ref(database, `users/${uid}`)
}

// Écouter une référence
export const subscribe = (
  dbRef: DatabaseReference,
  callback: (data: unknown) => void
): Unsubscribe => {
  return onValue(dbRef, (snapshot) => {
    callback(snapshot.val())
  })
}

// Envoyer un message dans le chat
export const sendMessage = async (roomId: string, uid: string, text: string): Promise<void> => {
  const messagesListRef = messagesRef(roomId)
  const newMessageRef = push(messagesListRef)
  await set(newMessageRef, {
    uid,
    text,
    ts: serverTimestamp()
  })
}

// Créer/mettre à jour le profil utilisateur
export const updateUserProfile = async (uid: string, displayName: string): Promise<void> => {
  await set(userRef(uid), {
    displayName,
    createdAt: serverTimestamp(),
    activeLanguages: ['it', 'es']
  })
}

// Générer un ID de room court (6 caractères)
const generateRoomId = (): string => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  let result = ''
  for (let i = 0; i < 6; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return result
}

// Créer une room directement dans Firebase
export const createRoomInFirebase = async (
  hostUid: string,
  language: 'it' | 'es',
  displayName?: string
): Promise<string> => {
  const roomId = generateRoomId()
  const roomData = {
    hostUid,
    status: 'waiting',
    createdAt: serverTimestamp(),
    language,
    players: {
      [hostUid]: {
        ready: true,
        score: 0,
        name: displayName || 'Joueur'
      }
    }
  }
  
  await set(roomRef(roomId), roomData)
  return roomId
}

// Rejoindre une room dans Firebase
export const joinRoomInFirebase = async (
  roomId: string,
  uid: string,
  displayName?: string
): Promise<void> => {
  // Vérifier que la room existe
  const snapshot = await get(roomRef(roomId))
  if (!snapshot.exists()) {
    throw new Error('Room introuvable')
  }
  
  const roomData = snapshot.val()
  if (roomData.status !== 'waiting') {
    throw new Error('La room n\'est plus disponible')
  }
  
  // Ajouter le joueur
  await update(roomRef(roomId), {
    [`players/${uid}`]: {
      ready: false,
      score: 0,
      name: displayName || 'Joueur'
    }
  })
}

// Démarrer une session de quiz
export const startSessionInFirebase = async (
  roomId: string,
  language: 'it' | 'es',
  category: 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics' | 'all' = 'all',
  questionCount: number = 10
): Promise<string> => {
  // Créer une nouvelle session
  const sessionsRef = ref(database, 'sessions')
  const newSessionRef = push(sessionsRef)
  const sessionId = newSessionRef.key!
  
  // Générer des questions de quiz
  const rounds = generateQuizRounds(language, category, questionCount)
  
  const sessionData = {
    roomId,
    language,
    startedAt: serverTimestamp(),
    state: 'active',
    roundIndex: 0,
    rounds
  }
  
  await set(newSessionRef, sessionData)
  
  // Mettre à jour la room avec l'ID de session
  await update(roomRef(roomId), {
    status: 'playing',
    currentSessionId: sessionId
  })
  
  return sessionId
}

// Générer des rounds de quiz à partir du fichier de questions
const generateQuizRounds = (
  language: 'it' | 'es',
  category: 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics' | 'all' = 'all',
  questionCount: number = 10
): Record<string, object> => {
  const questions = getQuestionsByFilter(language, category, undefined, 'all', questionCount)
  
  const rounds: Record<string, object> = {}
  questions.forEach((q: QuizQuestion, i: number) => {
    // Firebase n'accepte pas undefined, on ne met que les valeurs définies
    const round: Record<string, unknown> = {
      type: q.type,
      prompt: q.prompt,
      choices: q.choices || [],
      category: q.category,
      subCategory: q.subCategory,
      difficulty: q.difficulty
    }
    
    // Ajouter seulement si défini
    if (q.correctIndex !== undefined) round.correctIndex = q.correctIndex
    if (q.correctAnswer !== undefined) round.correctAnswer = q.correctAnswer
    if (q.explanation !== undefined) round.explanation = q.explanation
    if (q.audioText !== undefined) round.audioText = q.audioText
    
    rounds[`round_${i}`] = round
  })
  
  return rounds
}

// Soumettre une réponse et vérifier si tous ont répondu
export const submitAnswerInFirebase = async (
  sessionId: string,
  roundId: string,
  uid: string,
  value: number,
  playerCount: number
): Promise<void> => {
  const answerRef = ref(database, `sessions/${sessionId}/rounds/${roundId}/answers/${uid}`)
  await set(answerRef, {
    value,
    ts: serverTimestamp()
  })
  
  // Vérifier si tous les joueurs ont répondu
  const roundRef = ref(database, `sessions/${sessionId}/rounds/${roundId}`)
  const roundSnap = await get(roundRef)
  const roundData = roundSnap.val()
  
  if (roundData?.answers) {
    const answerCount = Object.keys(roundData.answers).length
    
    // Si tous ont répondu, calculer les scores et ajouter le résultat
    if (answerCount >= playerCount) {
      const scores: Record<string, number> = {}
      
      // Trouver qui a répondu correctement et le plus vite
      const correctAnswers: { uid: string; ts: number }[] = []
      
      for (const [odUid, answer] of Object.entries(roundData.answers)) {
        const answerData = answer as { value: number; ts: number }
        // Pour les questions à choix: value === correctIndex = correct
        // Pour les questions écrites: value === 1 = correct
        const isCorrect = roundData.type === 'write' 
          ? answerData.value === 1 
          : answerData.value === roundData.correctIndex
        
        if (isCorrect) {
          correctAnswers.push({ uid: odUid, ts: answerData.ts || Date.now() })
        }
        scores[odUid] = 0 // Initialiser à 0
      }
      
      // Trier par timestamp pour trouver le plus rapide
      correctAnswers.sort((a, b) => a.ts - b.ts)
      
      // Attribuer les points: 1 pt si correct, 2 pts si le plus rapide
      for (let i = 0; i < correctAnswers.length; i++) {
        const { uid } = correctAnswers[i]
        if (i === 0) {
          scores[uid] = 2 // Le plus rapide: 2 points
        } else {
          scores[uid] = 1 // Correct mais pas le plus rapide: 1 point
        }
      }
      
      // Récupérer le roomId depuis la session
      const sessionRefPath = ref(database, `sessions/${sessionId}`)
      const sessionSnap = await get(sessionRefPath)
      const sessionData = sessionSnap.val()
      
      if (sessionData?.roomId) {
        const roomCode = sessionData.roomId
        const roomRefPath = ref(database, `rooms/${roomCode}`)
        const roomSnap = await get(roomRefPath)
        const roomData = roomSnap.val()
        
        if (roomData?.players) {
          for (const [playerUid, pointsEarned] of Object.entries(scores)) {
            if (roomData.players[playerUid] !== undefined) {
              const currentScore = roomData.players[playerUid]?.score || 0
              const playerScoreRef = ref(database, `rooms/${roomCode}/players/${playerUid}/score`)
              await set(playerScoreRef, currentScore + pointsEarned)
            }
          }
        }
      }
      
      // Construire le résultat sans valeurs undefined
      const result: Record<string, unknown> = {
        scores,
        completed: true
      }
      
      // Ajouter correctIndex seulement pour les questions à choix (choice/listen)
      if (roundData.type === 'choice' || roundData.type === 'listen') {
        result.correctIndex = roundData.correctIndex ?? 0
      }
      
      // Pour les questions écrites, on stocke la bonne réponse
      if (roundData.type === 'write' && roundData.correctAnswer) {
        result.correctAnswer = roundData.correctAnswer
      }
      
      await update(roundRef, { result })
    }
  }
}

// Passer à la question suivante
export const nextRoundInFirebase = async (sessionId: string): Promise<void> => {
  const sessionRefPath = ref(database, `sessions/${sessionId}`)
  const sessionSnap = await get(sessionRefPath)
  const sessionData = sessionSnap.val()
  
  if (!sessionData) return
  
  const roundCount = Object.keys(sessionData.rounds || {}).length
  const nextIndex = (sessionData.roundIndex || 0) + 1
  
  if (nextIndex < roundCount) {
    await update(sessionRefPath, { 
      roundIndex: nextIndex,
      readyPlayers: null // Reset les joueurs prêts
    })
  } else {
    // Quiz terminé
    await update(sessionRefPath, { state: 'finished' })
  }
}

// Marquer un joueur comme prêt pour la question suivante
export const setPlayerReadyInFirebase = async (
  sessionId: string,
  uid: string,
  playerCount: number
): Promise<boolean> => {
  const readyRef = ref(database, `sessions/${sessionId}/readyPlayers/${uid}`)
  await set(readyRef, true)
  
  // Vérifier si tous les joueurs sont prêts
  const readyPlayersRef = ref(database, `sessions/${sessionId}/readyPlayers`)
  const readySnap = await get(readyPlayersRef)
  const readyData = readySnap.val()
  
  if (readyData) {
    const readyCount = Object.keys(readyData).length
    return readyCount >= playerCount
  }
  return false
}
