<template>
  <div class="gemini-live-container">
    <!-- Scenario Selection -->
    <div v-if="!selectedScenario" class="scenario-selection">
      <div class="selection-header">
        <h1>🎤 Gemini Tutor - Italien</h1>
        <p class="subtitle">Choisis une situation pour pratiquer ton italien</p>
      </div>

      <div class="scenarios-grid">
        <div 
          v-for="scenario in scenarios" 
          :key="scenario.id" 
          class="scenario-card"
          @click="selectScenario(scenario)"
        >
          <div class="scenario-icon">{{ scenario.icon }}</div>
          <h3>{{ scenario.title }}</h3>
          <p class="scenario-description">{{ scenario.description }}</p>
          <span class="difficulty-badge" :class="`difficulty-${scenario.difficulty}`">
            {{ scenario.difficulty }}
          </span>
        </div>
      </div>
    </div>

    <!-- Conversation Interface -->
    <div v-else class="conversation-view">
      <div class="live-header">
        <button @click="backToScenarios" class="btn-back">← Retour</button>
        <div class="header-content">
          <h1>{{ selectedScenario.icon }} {{ selectedScenario.title }}</h1>
          <p class="subtitle">{{ selectedScenario.description }}</p>
        </div>
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
        <div class="transcript-header">
          <h3>📝 Transcription</h3>
          <button 
            @click="toggleDisplayMode" 
            class="btn-display-mode"
            :title="displayMode === 'italic' ? 'Afficher avec [it]' : 'Afficher en italique'"
          >
            {{ displayMode === 'italic' ? '📘 Italique' : '🔤 [it]' }}
          </button>
        </div>
        <div class="transcript-content" ref="transcriptContainer">
          <div v-for="(msg, index) in messages" :key="index" :class="['transcript-message', msg.role]">
            <div class="message-role">{{ msg.role === 'user' ? '👤 Vous' : '🤖 Gemini' }}</div>
            <div class="message-text" v-html="formatMessageText(msg.text)"></div>
          </div>
          <div v-if="currentTranscript" class="transcript-message user partial">
            <div class="message-role">👤 Vous (en cours...)</div>
            <div class="message-text" v-html="formatMessageText(currentTranscript)"></div>
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

          <button 
            @click="toggleLanguage" 
            class="btn-language"
            :title="recognitionLang === 'fr-FR' ? 'Passer en italien' : 'Passer en français'"
          >
            {{ recognitionLang === 'fr-FR' ? '🇫🇷 FR' : '🇮🇹 IT' }}
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import scenariosData from '../data/scenarios.json'

interface Scenario {
  id: string
  title: string
  icon: string
  description: string
  difficulty: string
  systemPrompt: string
}

interface Message {
  role: 'user' | 'assistant'
  text: string
}

const scenarios = ref<Scenario[]>(scenariosData.scenarios)
const selectedScenario = ref<Scenario | null>(null)
const isConnecting = ref(false)
const isConnected = ref(false)
const isMuted = ref(false)
const isSpeaking = ref(false)
const recognitionLang = ref<'fr-FR' | 'it-IT'>('fr-FR')
const displayMode = ref<'brackets' | 'italic'>('italic')
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
      const italianVoices = availableVoices.filter(v => v.lang.startsWith('it'))
      console.log('🇫🇷 Voix françaises:', frenchVoices.map(v => v.name))
      console.log('🇮🇹 Voix italiennes:', italianVoices.map(v => v.name))
      resolve()
    } else {
      window.speechSynthesis.onvoiceschanged = () => {
        availableVoices = window.speechSynthesis.getVoices()
        console.log('✅ Voix chargées (via event):', availableVoices.length)
        const frenchVoices = availableVoices.filter(v => v.lang.startsWith('fr'))
        const italianVoices = availableVoices.filter(v => v.lang.startsWith('it'))
        console.log('🇫🇷 Voix françaises:', frenchVoices.map(v => v.name))
        console.log('🇮🇹 Voix italiennes:', italianVoices.map(v => v.name))
        resolve()
      }
    }
  })
}

type LangCode = 'fr-FR' | 'it-IT'

const formatMessageText = (text: string): string => {
  if (displayMode.value === 'brackets') {
    // Mode crochets : afficher [it]...[/it] tel quel
    return text
  } else {
    // Mode italique : convertir en <em> pour italique
    return text.replace(/\[it\]([\s\S]*?)\[\/it\]/g, '<em>$1</em>')
  }
}

const fixPunctuationInItTags = (text: string): string => {
  // Déplacer la ponctuation qui suit [/it] à l'intérieur des balises
  // "[it]Ciao[/it]!" devient "[it]Ciao![/it]"
  return text.replace(/\[\/it\]\s*([.,!?;:]+)/g, '$1[/it]')
}

const splitByItTags = (text: string) => {
  const parts: { lang: LangCode; text: string }[] = []
  const regex = /\[it\]([\s\S]*?)\[\/it\]/g

  let lastIndex = 0
  let match: RegExpExecArray | null

  while ((match = regex.exec(text)) !== null) {
    const before = text.slice(lastIndex, match.index)
    if (before && before.trim().length > 0) {
      parts.push({ lang: 'fr-FR', text: before.trim() })
      console.log('📝 Segment FR:', before.trim())
    }

    const itText = match[1]
    if (itText && itText.trim().length > 0) {
      parts.push({ lang: 'it-IT', text: itText.trim() })
      console.log('📝 Segment IT:', itText.trim())
    }

    lastIndex = match.index + match[0].length
  }

  const after = text.slice(lastIndex)
  if (after && after.trim().length > 0) {
    parts.push({ lang: 'fr-FR', text: after.trim() })
    console.log('📝 Segment FR (fin):', after.trim())
  }

  console.log('📊 Total segments:', parts.length)
  return parts
}

const speakBilingualFR_IT = (text: string) => {
  if (!('speechSynthesis' in window)) return

  // Forcer l'arrêt de toute lecture en cours
  window.speechSynthesis.cancel()
  
  // Petit délai pour s'assurer que cancel() est terminé
  setTimeout(() => {
    const queue = splitByItTags(text)
    
    if (queue.length === 0) {
      console.warn('⚠️ Aucun segment à prononcer')
      return
    }
    
    console.log('🗣️ Segments à prononcer:', queue)
    console.log(`📊 Total: ${queue.length} segments | FR: ${queue.filter(s => s.lang === 'fr-FR').length} | IT: ${queue.filter(s => s.lang === 'it-IT').length}`)

    const speakNext = (i: number) => {
    if (i >= queue.length) {
      console.log('✅ Lecture audio terminée - tous les segments prononcés')
      isSpeaking.value = false
      if (liveSession && isConnected.value && !isMuted.value) {
        console.log('⏳ Attente de 2s avant redémarrage micro (éviter capture audio résiduel)')
        setTimeout(() => {
          try {
            console.log('▶️ Redémarrage de la reconnaissance vocale')
            liveSession.start()
          } catch (err) {
            console.log('⚠️ Micro déjà actif, pas besoin de redémarrer')
          }
        }, 2000)
      }
      return
    }

    const seg = queue[i]
    console.log(`\n🎯 Traitement segment ${i + 1}/${queue.length}:`, seg)
    
    const u = new SpeechSynthesisUtterance(seg.text)
    u.lang = seg.lang
    
    // Paramètres audio
    u.rate = 0.85
    u.pitch = 1.0
    u.volume = 1.0

    // Sélection voix optimisée par langue
    let voice
    if (seg.lang === 'fr-FR') {
      // Essayer les meilleures voix françaises dans l'ordre
      const preferredFrenchVoices = ['Thomas', 'Amélie', 'Daniel', 'Google français']
      for (const voiceName of preferredFrenchVoices) {
        voice = availableVoices.find(v => v.name === voiceName)
        if (voice) break
      }
      // Fallback : n'importe quelle voix française
      if (!voice) {
        voice = availableVoices.find(v => v.lang.startsWith('fr'))
      }
    } else if (seg.lang === 'it-IT') {
      // Essayer les meilleures voix italiennes
      const preferredItalianVoices = ['Alice', 'Google italiano']
      for (const voiceName of preferredItalianVoices) {
        voice = availableVoices.find(v => v.name === voiceName)
        if (voice) break
      }
      if (!voice) {
        voice = availableVoices.find(v => v.lang.startsWith('it'))
      }
    }

    if (voice) {
      u.voice = voice
      console.log(`✅ [${seg.lang}] Voix: ${voice.name} | Volume: ${u.volume} | Rate: ${u.rate}`)
    } else {
      console.warn(`⚠️ [${seg.lang}] AUCUNE voix trouvée!`)
    }

    u.onstart = () => {
      console.log(`▶️ LECTURE EN COURS [${seg.lang}]: "${seg.text}"`)
      console.log(`   📢 Volume: ${u.volume} | Rate: ${u.rate} | Voice: ${u.voice?.name}`)
    }

    u.onend = () => {
      console.log(`✅ Segment ${i + 1} terminé après ${Date.now() - segmentStartTime}ms`)
      // Pause plus longue entre segments pour meilleure clarté
      setTimeout(() => speakNext(i + 1), 300)
    }
    
    u.onerror = (event) => {
      console.error(`❌ Erreur sur segment ${i + 1}:`, event.error)
      setTimeout(() => speakNext(i + 1), 50)
    }

    const segmentStartTime = Date.now()
    console.log(`🎤 Envoi à speechSynthesis [${i + 1}/${queue.length}]: "${seg.text}"`)
    
    // Force resume au cas où
    if (window.speechSynthesis.paused) {
      window.speechSynthesis.resume()
    }
    
    window.speechSynthesis.speak(u)
    
    console.log(`   ⏱️ En attente de lecture...`)
  }

    isSpeaking.value = true
    speakNext(0)
  }, 100)
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
    liveSession.lang = recognitionLang.value
    
    console.log(`🎤 Reconnaissance vocale initialisée en: ${recognitionLang.value}`)

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
          const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${GEMINI_API_KEY}`
        //  const apiUrl = `https://aiplatform.googleapis.com/v1/publishers/google/models/gemini-2.5-flash-lite:streamGenerateContent?key=${GEMINI_API_KEY}`
          
          const response = await fetch(apiUrl, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              system_instruction: {
                parts: [{
                  text: selectedScenario.value?.systemPrompt
                }]
              },
              contents: messages.value.map(msg => ({
                role: msg.role === 'user' ? 'user' : 'model',
                parts: [{
                  text: msg.text
                }]
              })).concat([{
                role: "user",
                parts: [{
                  text: transcript
                }]
              }])
            })
          })

          const data = await response.json()
          const geminiResponse = data.candidates?.[0]?.content?.parts?.[0]?.text || 'Pas de réponse'
          
          console.log('📨 RÉPONSE GEMINI COMPLÈTE:', geminiResponse)
          console.log('📏 Longueur:', geminiResponse.length, 'caractères')
          
          // Corriger la ponctuation pour qu'elle soit dans les balises [it]
          const fixedResponse = fixPunctuationInItTags(geminiResponse)
          console.log('✏️ Après correction ponctuation:', fixedResponse)
          
          messages.value.push({
            role: 'assistant',
            text: fixedResponse
          })
          scrollToBottom()

          if ('speechSynthesis' in window) {
            console.log('🔊 Début de la synthèse vocale bilingue FR-IT...')
            speakBilingualFR_IT(fixedResponse)
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

const toggleLanguage = () => {
  recognitionLang.value = recognitionLang.value === 'fr-FR' ? 'it-IT' : 'fr-FR'
  console.log(`🌍 Langue changée: ${recognitionLang.value}`)
  
  // Redémarrer la reconnaissance avec la nouvelle langue si active
  if (liveSession && isConnected.value) {
    liveSession.lang = recognitionLang.value
    liveSession.stop()
    setTimeout(() => {
      liveSession.start()
      console.log(`✅ Reconnaissance redémarrée en ${recognitionLang.value}`)
    }, 100)
  }
}

const toggleDisplayMode = () => {
  displayMode.value = displayMode.value === 'italic' ? 'brackets' : 'italic'
  console.log(`🎨 Mode d'affichage: ${displayMode.value}`)
}

const selectScenario = (scenario: Scenario) => {
  selectedScenario.value = scenario
  console.log(`📚 Scénario sélectionné: ${scenario.title}`)
}

const backToScenarios = () => {
  if (isConnected.value) {
    cleanup()
  }
  selectedScenario.value = null
  messages.value = []
  console.log('← Retour à la sélection des scénarios')
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
  min-height: calc(100vh - 56px);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1.5rem;
}

/* Scenario Selection */
.scenario-selection {
  width: 100%;
  max-width: 1600px;
  margin: 0 auto;
}

.selection-header {
  text-align: center;
  color: white;
  margin-bottom: 1.75rem;
  padding: 0 1rem;
}

.selection-header h1 {
  font-size: 1.75rem;
  margin-bottom: 0.35rem;
  font-weight: 600;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.scenarios-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 0.75rem;
  padding: 0 0.5rem;
  width: 100%;
}

.scenario-card {
  background: white;
  border-radius: 10px;
  padding: 1rem 0.85rem;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06), 0 1px 2px rgba(0, 0, 0, 0.04);
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.scenario-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12), 0 2px 4px rgba(0, 0, 0, 0.08);
  border-color: rgba(102, 126, 234, 0.2);
}

.scenario-icon {
  font-size: 2.25rem;
  margin-bottom: 0.5rem;
  filter: grayscale(0.1);
}

.scenario-card h3 {
  color: #1a202c;
  font-size: 0.875rem;
  font-weight: 600;
  margin-bottom: 0.4rem;
  line-height: 1.25;
  letter-spacing: -0.01em;
}

.scenario-description {
  color: #64748b;
  font-size: 0.75rem;
  margin-bottom: 0.6rem;
  line-height: 1.35;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.difficulty-badge {
  padding: 0.2rem 0.55rem;
  border-radius: 5px;
  font-size: 0.65rem;
  font-weight: 500;
  margin-top: auto;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

.difficulty-débutant {
  background: #e8f5e9;
  color: #2e7d32;
  border: 1px solid #a5d6a7;
}

.difficulty-intermédiaire {
  background: #fff8e1;
  color: #f57f17;
  border: 1px solid #ffe082;
}

/* Responsive Design */
@media (max-width: 1400px) {
  .scenarios-grid {
    grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
  }
}

@media (max-width: 1200px) {
  .gemini-live-container {
    padding: 1.25rem;
  }
  
  .scenarios-grid {
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 0.65rem;
  }
}

@media (max-width: 992px) {
  .selection-header h1 {
    font-size: 1.5rem;
  }
  
  .scenarios-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  }
}

@media (max-width: 768px) {
  .gemini-live-container {
    padding: 1rem;
  }
  
  .selection-header {
    margin-bottom: 1.5rem;
  }
  
  .selection-header h1 {
    font-size: 1.35rem;
  }
  
  .scenarios-grid {
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 0.6rem;
    padding: 0;
  }
  
  .scenario-card {
    padding: 0.85rem 0.7rem;
  }
  
  .scenario-icon {
    font-size: 2rem;
  }
  
  .scenario-card h3 {
    font-size: 0.85rem;
  }
  
  .scenario-description {
    font-size: 0.7rem;
  }
}

@media (max-width: 576px) {
  .gemini-live-container {
    padding: 0.75rem;
  }
  
  .selection-header h1 {
    font-size: 1.2rem;
  }
  
  .selection-header .subtitle {
    font-size: 0.85rem;
  }
  
  .scenarios-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.5rem;
  }
  
  .scenario-card {
    padding: 0.75rem 0.6rem;
  }
  
  .scenario-icon {
    font-size: 1.85rem;
    margin-bottom: 0.4rem;
  }
  
  .scenario-card h3 {
    font-size: 0.8rem;
    margin-bottom: 0.35rem;
  }
  
  .scenario-description {
    font-size: 0.68rem;
    margin-bottom: 0.5rem;
    -webkit-line-clamp: 2;
  }
  
  .difficulty-badge {
    font-size: 0.6rem;
    padding: 0.18rem 0.45rem;
  }
}

@media (max-width: 400px) {
  .scenarios-grid {
    grid-template-columns: 1fr;
    gap: 0.5rem;
  }
  
  .scenario-card {
    padding: 0.9rem;
  }
  
  .scenario-icon {
    font-size: 2.2rem;
  }
  
  .scenario-card h3 {
    font-size: 0.9rem;
  }
  
  .scenario-description {
    font-size: 0.75rem;
  }
}

/* Conversation View */
.conversation-view {
  width: 100%;
}

.btn-back {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid white;
  padding: 0.5rem 1.5rem;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-bottom: 1rem;
}

.btn-back:hover {
  background: white;
  color: #667eea;
}

.live-header {
  text-align: center;
  color: white;
  margin-bottom: 2rem;
}

.header-content {
  margin-top: 1rem;
}

.live-header h1 {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
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

.transcript-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.transcript-panel h3 {
  margin: 0;
  color: #333;
}

.btn-display-mode {
  padding: 0.5rem 1rem;
  font-size: 0.9rem;
  font-weight: 600;
  border: 2px solid #2196F3;
  background: white;
  color: #2196F3;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-display-mode:hover {
  background: #2196F3;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(33, 150, 243, 0.3);
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

.message-text em {
  font-style: italic;
  font-weight: 600;
  color: #2196F3;
}

.transcript-message.user .message-text em {
  color: #64B5F6;
}

.transcript-message.assistant .message-text em {
  color: #1976D2;
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
.btn-toggle,
.btn-language {
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
  background: #4caf50;
  color: white;
}

.btn-toggle:not(.active) {
  background: #9e9e9e;
}

.btn-toggle:hover {
  opacity: 0.9;
  transform: translateY(-2px);
}

.btn-language {
  background: linear-gradient(135deg, #FF9800 0%, #F57C00 100%);
  color: white;
  min-width: 100px;
}

.btn-language:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 152, 0, 0.4);
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
