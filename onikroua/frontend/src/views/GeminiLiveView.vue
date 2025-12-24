<template>
  <div class="gemini-live-container">
    <div class="live-header">
      <h1>🎤 Gemini Live - Audio Temps Réel</h1>
      <p class="subtitle">Conversation vocale bidirectionnelle avec Gemini Native Audio</p>
    </div>

    <div class="live-content">
      <div class="status-panel">
        <div class="status-indicator" :class="connectionStatus">
          <span class="status-dot"></span>
          <span class="status-text">{{ statusText }}</span>
        </div>

        <div v-if="errorMessage" class="error-banner">
          ⚠️ {{ errorMessage }}
        </div>

        <div class="audio-visualizer" v-if="isConnected">
          <div class="wave-bars">
            <div v-for="i in 20" :key="i" class="wave-bar" :style="{ height: waveBars[i] + '%' }"></div>
          </div>
        </div>
      </div>

      <div class="transcript-panel">
        <h3>📝 Transcription</h3>
        <div class="transcript-content" ref="transcriptContainer">
          <div v-for="(msg, index) in messages" :key="index" :class="['transcript-message', msg.role]">
            <div class="message-role">{{ msg.role === 'user' ? '👤 Vous' : '🤖 Gemini' }}</div>
            <div class="message-text">{{ msg.text }}</div>
          </div>
          <div v-if="currentTranscript" class="transcript-message user partial">
            <div class="message-role">👤 Vous (en cours...)</div>
            <div class="message-text">{{ currentTranscript }}</div>
          </div>
        </div>
      </div>

      <div class="controls-panel">
        <button 
          v-if="!isConnected" 
          @click="connect" 
          class="btn-connect"
          :disabled="isConnecting"
        >
          {{ isConnecting ? '⏳ Connexion...' : '🎤 Démarrer la conversation' }}
        </button>

        <div v-else class="active-controls">
          <button 
            @click="toggleMute" 
            class="btn-toggle"
            :class="{ active: !isMuted }"
          >
            {{ isMuted ? '🔇 Micro coupé' : '🎤 Micro actif' }}
          </button>

          <button @click="disconnect" class="btn-disconnect">
            ⏹️ Arrêter
          </button>
        </div>

        <div class="info-text" v-if="isConnected && !isMuted && !isSpeaking">
          💡 Parlez naturellement - Gemini vous écoute en temps réel
        </div>
        <div class="speaking-indicator" v-if="isSpeaking">
          🔊 Gemini parle... (micro désactivé pour éviter l'écho)
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'

interface Message {
  role: 'user' | 'assistant'
  text: string
}

const isConnecting = ref(false)
const isConnected = ref(false)
const isMuted = ref(false)
const isSpeaking = ref(false)
const isPushToTalkMode = ref(true)
const isHoldingToTalk = ref(false)
const errorMessage = ref('')
const messages = ref<Message[]>([])
const currentTranscript = ref('')
const transcriptContainer = ref<HTMLElement | null>(null)
const waveBars = ref<number[]>(Array(20).fill(20))

let liveSession: any = null
let availableVoices: SpeechSynthesisVoice[] = []

const GEMINI_API_KEY = import.meta.env.VITE_GEMINI_API_KEY

const loadVoices = () => {
  return new Promise<void>((resolve) => {
    availableVoices = window.speechSynthesis.getVoices()
    
    if (availableVoices.length > 0) {
      console.log('✅ Voix chargées:', availableVoices.length)
      const frenchVoices = availableVoices.filter(v => v.lang.startsWith('fr'))
      console.log('🇫🇷 Voix françaises:', frenchVoices.map(v => v.name))
      resolve()
    } else {
      window.speechSynthesis.onvoiceschanged = () => {
        availableVoices = window.speechSynthesis.getVoices()
        console.log('✅ Voix chargées (via event):', availableVoices.length)
        const frenchVoices = availableVoices.filter(v => v.lang.startsWith('fr'))
        console.log('🇫🇷 Voix françaises:', frenchVoices.map(v => v.name))
        resolve()
      }
    }
  })
}

const connectionStatus = computed(() => {
  if (isConnected.value) return 'connected'
  if (isConnecting.value) return 'connecting'
  return 'disconnected'
})

const statusText = computed(() => {
  if (isConnected.value) return 'Connecté'
  if (isConnecting.value) return 'Connexion...'
  return 'Déconnecté'
})

const scrollToBottom = async () => {
  await nextTick()
  if (transcriptContainer.value) {
    transcriptContainer.value.scrollTop = transcriptContainer.value.scrollHeight
  }
}

const updateWaveform = () => {
  if (!isConnected.value || isMuted.value) {
    waveBars.value = Array(20).fill(20)
    return
  }
  
  waveBars.value = waveBars.value.map(() => Math.random() * 80 + 20)
  requestAnimationFrame(updateWaveform)
}

const connect = async () => {
  try {
    isConnecting.value = true
    errorMessage.value = ''

    if (!GEMINI_API_KEY) {
      throw new Error('API Key manquante. Ajoutez VITE_GEMINI_API_KEY dans .env')
    }

    if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
      throw new Error('Speech Recognition non supporté par ce navigateur')
    }

    const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition
    liveSession = new SpeechRecognition()
    liveSession.continuous = true
    liveSession.interimResults = true
    liveSession.lang = 'fr-FR'

    liveSession.onstart = () => {
      console.log('✅ Reconnaissance vocale démarrée')
      isConnected.value = true
      isConnecting.value = false
      updateWaveform()
    }

    liveSession.onresult = async (event: any) => {
      const last = event.results.length - 1
      const transcript = event.results[last][0].transcript
      
      if (event.results[last].isFinal) {
        currentTranscript.value = ''
        
        messages.value.push({
          role: 'user',
          text: transcript
        })
        scrollToBottom()

        if (liveSession && !isMuted.value) {
          console.log('🛑 ARRÊT COMPLET du micro avant traitement')
          liveSession.stop()
          liveSession.abort()
        }

        await new Promise(resolve => setTimeout(resolve, 300))

        try {
          const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${GEMINI_API_KEY}`
          
          const response = await fetch(apiUrl, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              contents: [{
                parts: [{
                  text: transcript
                }]
              }]
            })
          })

          const data = await response.json()
          const geminiResponse = data.candidates?.[0]?.content?.parts?.[0]?.text || 'Pas de réponse'
          
          messages.value.push({
            role: 'assistant',
            text: geminiResponse
          })
          scrollToBottom()

          if ('speechSynthesis' in window) {
            window.speechSynthesis.cancel()
            
            const utterance = new SpeechSynthesisUtterance(geminiResponse)
            utterance.lang = 'fr-FR'
            utterance.rate = 1.0
            utterance.pitch = 1.0
            utterance.volume = 1.0
            
            const frenchVoice = availableVoices.find(v => v.lang.startsWith('fr-FR') || v.lang.startsWith('fr'))
            if (frenchVoice) {
              utterance.voice = frenchVoice
              console.log('🔊 Voix sélectionnée:', frenchVoice.name)
            } else {
              console.warn('⚠️ Aucune voix française trouvée (' + availableVoices.length + ' voix disponibles), utilisation de la voix par défaut')
            }
            
            utterance.onstart = () => {
              console.log('🎤 Lecture audio démarrée (micro désactivé)')
              isSpeaking.value = true
            }
            
            utterance.onend = () => {
              console.log('✅ Lecture audio terminée')
              isSpeaking.value = false
              if (liveSession && isConnected.value && !isMuted.value) {
                console.log('⏳ Attente de 2s avant redémarrage micro (éviter capture audio résiduel)')
                setTimeout(() => {
                  console.log('▶️ Redémarrage de la reconnaissance vocale')
                  liveSession.start()
                }, 2000)
              }
            }
            
            utterance.onerror = (event) => {
              console.error('❌ Erreur lecture audio:', event)
              isSpeaking.value = false
              if (liveSession && isConnected.value && !isMuted.value) {
                console.log('▶️ Redémarrage de la reconnaissance vocale (après erreur)')
                liveSession.start()
              }
            }
            
            console.log('🔊 Début de la synthèse vocale...')
            window.speechSynthesis.speak(utterance)
          } else {
            console.error('❌ Speech Synthesis non supporté')
          }
        } catch (err) {
          console.error('Error with Gemini:', err)
          errorMessage.value = 'Erreur lors de la génération de réponse'
        }
      } else {
        currentTranscript.value = transcript
      }
    }

    liveSession.onerror = (event: any) => {
      console.error('❌ Erreur reconnaissance vocale:', event.error)
      errorMessage.value = `Erreur: ${event.error}`
    }

    liveSession.onend = () => {
      if (isConnected.value) {
        liveSession.start()
      }
    }

    liveSession.start()

  } catch (err: any) {
    console.error('Erreur connexion:', err)
    errorMessage.value = err.message || 'Erreur lors de la connexion'
    isConnecting.value = false
  }
}

const toggleMute = () => {
  isMuted.value = !isMuted.value
  if (liveSession) {
    if (isMuted.value) {
      liveSession.stop()
    } else {
      liveSession.start()
    }
  }
}

const disconnect = () => {
  cleanup()
}

const cleanup = () => {
  if (liveSession) {
    liveSession.stop()
    liveSession = null
  }

  if ('speechSynthesis' in window) {
    window.speechSynthesis.cancel()
  }

  isConnected.value = false
  isConnecting.value = false
  isMuted.value = false
  currentTranscript.value = ''
  waveBars.value = Array(20).fill(20)
}

onMounted(async () => {
  if ('speechSynthesis' in window) {
    await loadVoices()
  }
})

onUnmounted(() => {
  cleanup()
})
</script>

<style scoped>
.gemini-live-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.live-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 2rem;
  text-align: center;
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
}

.live-header h1 {
  margin: 0;
  font-size: 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.subtitle {
  margin: 0.5rem 0 0 0;
  color: #666;
}

.live-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  padding: 2rem;
  overflow: hidden;
}

.status-panel {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 1.1rem;
  font-weight: 600;
}

.status-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #ccc;
  animation: pulse 2s infinite;
}

.status-indicator.connected .status-dot {
  background: #4caf50;
}

.status-indicator.connecting .status-dot {
  background: #ff9800;
}

.status-indicator.disconnected .status-dot {
  background: #999;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.error-banner {
  margin-top: 1rem;
  padding: 1rem;
  background: #fee;
  color: #c33;
  border-radius: 8px;
  font-weight: 600;
}

.audio-visualizer {
  margin-top: 1.5rem;
}

.wave-bars {
  display: flex;
  align-items: flex-end;
  justify-content: center;
  gap: 4px;
  height: 80px;
}

.wave-bar {
  width: 8px;
  background: linear-gradient(to top, #667eea, #764ba2);
  border-radius: 4px;
  transition: height 0.1s ease;
}

.transcript-panel {
  flex: 1;
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.transcript-panel h3 {
  margin: 0 0 1rem 0;
  color: #333;
}

.transcript-content {
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.transcript-message {
  padding: 1rem;
  border-radius: 12px;
  background: #f5f5f5;
}

.transcript-message.user {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  align-self: flex-end;
  max-width: 70%;
}

.transcript-message.assistant {
  background: #e8eaf6;
  color: #333;
  align-self: flex-start;
  max-width: 70%;
}

.transcript-message.partial {
  opacity: 0.7;
  font-style: italic;
}

.message-role {
  font-size: 0.85rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  opacity: 0.9;
}

.message-text {
  line-height: 1.5;
}

.controls-panel {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.btn-connect,
.btn-disconnect,
.btn-toggle {
  padding: 1rem 2rem;
  font-size: 1.1rem;
  font-weight: 600;
  border: none;
  border-radius: 24px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-connect {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-connect:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-connect:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.active-controls {
  display: flex;
  gap: 1rem;
}

.btn-toggle {
  background: #e0e0e0;
  color: #666;
}

.btn-toggle.active {
  background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
  color: white;
}

.btn-disconnect {
  background: #f44336;
  color: white;
}

.btn-disconnect:hover {
  background: #d32f2f;
  transform: translateY(-2px);
}

.info-text {
  color: #666;
  font-size: 0.95rem;
  text-align: center;
}

.speaking-indicator {
  color: #667eea;
  font-size: 1rem;
  font-weight: 600;
  text-align: center;
  padding: 0.75rem;
  background: rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  animation: pulse-speaking 1.5s infinite;
}

@keyframes pulse-speaking {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.8;
    transform: scale(1.02);
  }
}

.transcript-content::-webkit-scrollbar {
  width: 8px;
}

.transcript-content::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.transcript-content::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.transcript-content::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>
