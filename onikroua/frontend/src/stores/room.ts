import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { 
  roomRef, 
  sessionRef, 
  messagesRef, 
  subscribe, 
  sendMessage as sendChatMessage,
  createRoomInFirebase,
  joinRoomInFirebase,
  startSessionInFirebase,
  submitAnswerInFirebase,
  nextRoundInFirebase,
  setPlayerReadyInFirebase,
} from '../firebase/db'
import { useAuthStore } from './auth'
import type { Unsubscribe } from 'firebase/database'

// Types
interface Player {
  ready: boolean
  score: number
  name?: string
}

interface Room {
  hostUid: string
  status: 'waiting' | 'playing' | 'finished'
  createdAt: number
  language: 'it' | 'es'
  players: Record<string, Player>
  currentSessionId?: string
}

interface Round {
  type: string
  prompt: string
  choices: string[]
  explanation?: string
  answers?: Record<string, { value: number; ts: number }>
  result?: { correctIndex: number; scores: Record<string, number> }
}

interface Session {
  roomId: string
  language: 'it' | 'es'
  startedAt: number
  state: 'active' | 'finished'
  roundIndex: number
  rounds: Record<string, Round>
}

interface Message {
  uid: string
  text: string
  ts: number
}

export interface QuizOptions {
  mode: 'classic' | 'speed' | 'survival' | 'coop'
  category: 'all' | 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics'
  questionCount: number
  difficulty: 'all' | 'beginner' | 'intermediate' | 'advanced'
  timePerQuestion: number
}

export const useRoomStore = defineStore('room', () => {
  // État
  const roomId = ref<string | null>(null)
  const room = ref<Room | null>(null)
  const sessionId = ref<string | null>(null)
  const session = ref<Session | null>(null)
  const messages = ref<Record<string, Message>>({})
  const loading = ref(false)
  const error = ref<string | null>(null)
  
  // Options de quiz
  const quizOptions = ref<QuizOptions>({
    mode: 'classic',
    category: 'all',
    questionCount: 10,
    difficulty: 'all',
    timePerQuestion: 30
  })

  // Unsubscribers
  let roomUnsub: Unsubscribe | null = null
  let sessionUnsub: Unsubscribe | null = null
  let messagesUnsub: Unsubscribe | null = null

  // Computed
  const players = computed(() => room.value?.players || {})
  const isHost = computed(() => {
    const authStore = useAuthStore()
    return room.value?.hostUid === authStore.user?.uid
  })
  const currentRound = computed(() => {
    if (!session.value?.rounds) return null
    const roundIds = Object.keys(session.value.rounds)
    const currentRoundId = roundIds[session.value.roundIndex]
    return currentRoundId ? { id: currentRoundId, ...session.value.rounds[currentRoundId] } : null
  })
  const messagesList = computed(() => {
    return Object.entries(messages.value)
      .map(([id, msg]) => ({ id, ...msg }))
      .sort((a, b) => (a.ts || 0) - (b.ts || 0))
  })

  // Obtenir le nom d'affichage du joueur
  const getDisplayName = (authStore: ReturnType<typeof useAuthStore>): string => {
    if (!authStore.user) return 'Joueur'
    // Utiliser displayName, sinon la partie avant @ de l'email
    if (authStore.user.displayName) return authStore.user.displayName
    if (authStore.user.email) {
      const emailPart = authStore.user.email.split('@')[0]
      // Capitaliser la première lettre
      return emailPart.charAt(0).toUpperCase() + emailPart.slice(1)
    }
    return 'Joueur'
  }

  // Créer une room (directement via Firebase)
  const createRoom = async (language: 'it' | 'es'): Promise<string> => {
    const authStore = useAuthStore()
    if (!authStore.user) throw new Error('Non authentifié')
    
    try {
      loading.value = true
      error.value = null
      const displayName = getDisplayName(authStore)
      const newRoomId = await createRoomInFirebase(authStore.user.uid, language, displayName)
      return newRoomId
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Erreur création room'
      throw e
    } finally {
      loading.value = false
    }
  }

  // Rejoindre une room (directement via Firebase)
  const joinRoom = async (id: string): Promise<void> => {
    const authStore = useAuthStore()
    if (!authStore.user) throw new Error('Non authentifié')
    
    try {
      loading.value = true
      error.value = null
      const displayName = getDisplayName(authStore)
      await joinRoomInFirebase(id, authStore.user.uid, displayName)
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Erreur join room'
      throw e
    } finally {
      loading.value = false
    }
  }

  // S'abonner aux updates de la room
  const subscribeToRoom = (id: string): void => {
    // Cleanup précédent
    unsubscribeAll()

    roomId.value = id

    // Écouter la room
    roomUnsub = subscribe(roomRef(id), (data) => {
      room.value = data as Room | null
      
      // Si une session est active, s'y abonner
      if (room.value?.currentSessionId && room.value.currentSessionId !== sessionId.value) {
        subscribeToSession(room.value.currentSessionId)
      }
    })

    // Écouter les messages
    messagesUnsub = subscribe(messagesRef(id), (data) => {
      messages.value = (data as Record<string, Message>) || {}
    })
  }

  // S'abonner à une session
  const subscribeToSession = (id: string): void => {
    if (sessionUnsub) sessionUnsub()
    sessionId.value = id

    sessionUnsub = subscribe(sessionRef(id), (data) => {
      session.value = data as Session | null
    })
  }

  // Démarrer une session (host only) - via Firebase
  const startSession = async (
    category?: 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics' | 'all',
    questionCount?: number
  ): Promise<void> => {
    if (!roomId.value || !room.value) throw new Error('Pas de room active')
    try {
      loading.value = true
      error.value = null
      await startSessionInFirebase(
        roomId.value, 
        room.value.language,
        category || quizOptions.value.category,
        questionCount || quizOptions.value.questionCount
      )
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Erreur démarrage session'
      throw e
    } finally {
      loading.value = false
    }
  }

  // Soumettre une réponse - via Firebase
  const sendAnswer = async (roundId: string, value: number): Promise<void> => {
    if (!sessionId.value) throw new Error('Pas de session active')
    const authStore = useAuthStore()
    if (!authStore.user) throw new Error('Non authentifié')
    
    const playerCount = Object.keys(players.value).length
    
    try {
      loading.value = true
      error.value = null
      await submitAnswerInFirebase(sessionId.value, roundId, authStore.user.uid, value, playerCount)
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Erreur envoi réponse'
      throw e
    } finally {
      loading.value = false
    }
  }

  // Envoyer un message chat
  const sendMessage = async (text: string): Promise<void> => {
    if (!roomId.value) return
    const authStore = useAuthStore()
    if (!authStore.user) return
    
    await sendChatMessage(roomId.value, authStore.user.uid, text)
  }

  // Passer à la question suivante
  const nextRound = async (): Promise<void> => {
    if (!sessionId.value) return
    await nextRoundInFirebase(sessionId.value)
  }

  // Marquer le joueur comme prêt
  const setPlayerReady = async (): Promise<boolean> => {
    if (!sessionId.value) return false
    const authStore = useAuthStore()
    if (!authStore.user) return false
    
    const playerCount = Object.keys(players.value).length
    return await setPlayerReadyInFirebase(sessionId.value, authStore.user.uid, playerCount)
  }

  // Cleanup
  const unsubscribeAll = (): void => {
    if (roomUnsub) roomUnsub()
    if (sessionUnsub) sessionUnsub()
    if (messagesUnsub) messagesUnsub()
    roomUnsub = null
    sessionUnsub = null
    messagesUnsub = null
  }

  const leaveRoom = (): void => {
    unsubscribeAll()
    roomId.value = null
    room.value = null
    sessionId.value = null
    session.value = null
    messages.value = {}
  }

  // Définir les options de quiz
  const setQuizOptions = (options: Partial<QuizOptions>): void => {
    quizOptions.value = { ...quizOptions.value, ...options }
  }

  return {
    roomId,
    room,
    sessionId,
    session,
    messages,
    loading,
    error,
    quizOptions,
    players,
    isHost,
    currentRound,
    messagesList,
    createRoom,
    joinRoom,
    subscribeToRoom,
    setQuizOptions,
    startSession,
    sendAnswer,
    sendMessage,
    nextRound,
    setPlayerReady,
    leaveRoom
  }
})
