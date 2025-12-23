<script setup lang="ts">
import { ref, computed, nextTick, onMounted } from 'vue'
import { useLearningStore } from '../stores/learning'

const learningStore = useLearningStore()

interface Message {
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

const messages = ref<Message[]>([])
const inputMessage = ref('')
const isLoading = ref(false)
const chatContainer = ref<HTMLElement | null>(null)
const mode = ref<'tutor' | 'translate' | 'grammar' | 'practice' | 'quiz'>('tutor')

// Exercise state
const currentExercise = ref<any>(null)
const exerciseAnswer = ref('')
const exerciseResult = ref<'correct' | 'wrong' | null>(null)
const exerciseType = ref<'vocabulary' | 'conjugation' | 'fillblank'>('vocabulary')
const exerciseLevel = ref<'beginner' | 'intermediate' | 'advanced'>('beginner')

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001'

const languageLabel = computed(() => 
  learningStore.currentLanguage === 'it' ? 'Italien' : 'Espagnol'
)

const modeLabels = {
  tutor: { icon: '🎓', label: 'Tuteur', desc: 'Pose tes questions' },
  translate: { icon: '🔄', label: 'Traduction', desc: 'Traduis des textes' },
  grammar: { icon: '📖', label: 'Grammaire', desc: 'Explications grammaticales' },
  practice: { icon: '💬', label: 'Conversation', desc: 'Pratique la langue' },
  quiz: { icon: '🎯', label: 'Quiz', desc: 'Teste tes connaissances' }
}

const scrollToBottom = async () => {
  await nextTick()
  if (chatContainer.value) {
    chatContainer.value.scrollTop = chatContainer.value.scrollHeight
  }
}

const sendMessage = async () => {
  if (!inputMessage.value.trim() || isLoading.value) return

  const userMessage = inputMessage.value.trim()
  inputMessage.value = ''

  messages.value.push({
    role: 'user',
    content: userMessage,
    timestamp: new Date()
  })

  await scrollToBottom()
  isLoading.value = true

  try {
    const response = await fetch(`${API_URL}/api/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: userMessage,
        language: learningStore.currentLanguage,
        mode: mode.value,
        history: messages.value.slice(-10).map(m => ({
          role: m.role,
          content: m.content
        }))
      })
    })

    if (!response.ok) {
      throw new Error('Erreur API')
    }

    const data = await response.json()

    messages.value.push({
      role: 'assistant',
      content: data.response,
      timestamp: new Date()
    })

  } catch (error) {
    console.error('AI Chat error:', error)
    messages.value.push({
      role: 'assistant',
      content: '❌ Désolé, une erreur s\'est produite. Vérifie que le serveur backend est lancé et que la clé API Gemini est configurée.',
      timestamp: new Date()
    })
  } finally {
    isLoading.value = false
    await scrollToBottom()
  }
}

const generateExercise = async () => {
  isLoading.value = true
  currentExercise.value = null
  exerciseAnswer.value = ''
  exerciseResult.value = null

  try {
    const response = await fetch(`${API_URL}/api/ai/exercise`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        type: exerciseType.value,
        language: learningStore.currentLanguage,
        level: exerciseLevel.value
      })
    })

    if (!response.ok) throw new Error('Erreur API')

    const data = await response.json()
    currentExercise.value = data.exercise

  } catch (error) {
    console.error('Exercise error:', error)
    currentExercise.value = { error: 'Erreur lors de la génération. Vérifie le backend.' }
  } finally {
    isLoading.value = false
  }
}

const checkExerciseAnswer = () => {
  if (!currentExercise.value || !exerciseAnswer.value.trim()) return

  const answer = exerciseAnswer.value.trim().toLowerCase()
  const correct = (currentExercise.value.answer || '').toLowerCase()

  if (answer === correct) {
    exerciseResult.value = 'correct'
  } else {
    exerciseResult.value = 'wrong'
  }
}

const clearChat = () => {
  messages.value = []
}

const speak = (text: string) => {
  const lang = learningStore.currentLanguage === 'it' ? 'it-IT' : 'es-ES'
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = lang
  utterance.rate = 0.85
  speechSynthesis.speak(utterance)
}

// Welcome message
onMounted(() => {
  messages.value.push({
    role: 'assistant',
    content: `Ciao! 👋 Je suis ton tuteur d'${languageLabel.value.toLowerCase()}. Comment puis-je t'aider aujourd'hui?\n\n💡 Tu peux me demander:\n- Des traductions\n- Des explications de grammaire\n- De pratiquer une conversation\n- Des exercices et quiz\n\nQu'est-ce qui t'intéresse?`,
    timestamp: new Date()
  })
})
</script>

<template>
  <div class="ai-tutor-container">
    <header class="tutor-header">
      <div class="header-content">
        <h1>🤖 AI Tutor</h1>
        <p class="subtitle">Ton assistant personnel pour apprendre l'{{ languageLabel.toLowerCase() }}</p>
      </div>
      
      <div class="language-toggle">
        <button 
          :class="['lang-btn', { active: learningStore.currentLanguage === 'it' }]"
          @click="learningStore.setLanguage('it')"
        >
          🇮🇹 Italien
        </button>
        <button 
          :class="['lang-btn', { active: learningStore.currentLanguage === 'es' }]"
          @click="learningStore.setLanguage('es')"
        >
          🇪🇸 Espagnol
        </button>
      </div>
    </header>

    <div class="tutor-layout">
      <!-- Sidebar -->
      <aside class="tutor-sidebar">
        <div class="mode-selector">
          <h3>Mode</h3>
          <button 
            v-for="(info, key) in modeLabels" 
            :key="key"
            :class="['mode-btn', { active: mode === key }]"
            @click="mode = key as any"
          >
            <span class="mode-icon">{{ info.icon }}</span>
            <div class="mode-info">
              <span class="mode-label">{{ info.label }}</span>
              <span class="mode-desc">{{ info.desc }}</span>
            </div>
          </button>
        </div>

        <div class="exercise-section">
          <h3>🎲 Exercice rapide</h3>
          <div class="exercise-options">
            <select v-model="exerciseType" class="exercise-select">
              <option value="vocabulary">Vocabulaire</option>
              <option value="conjugation">Conjugaison</option>
              <option value="fillblank">Phrase à trous</option>
            </select>
            <select v-model="exerciseLevel" class="exercise-select">
              <option value="beginner">Débutant</option>
              <option value="intermediate">Intermédiaire</option>
              <option value="advanced">Avancé</option>
            </select>
          </div>
          <button 
            class="generate-btn"
            @click="generateExercise"
            :disabled="isLoading"
          >
            {{ isLoading ? '⏳' : '🎲' }} Générer
          </button>

          <!-- Exercise display -->
          <div v-if="currentExercise && !currentExercise.error" class="exercise-card">
            <div v-if="exerciseType === 'vocabulary'" class="exercise-content">
              <div class="exercise-word">{{ currentExercise.word }}</div>
              <div class="exercise-hint">💡 {{ currentExercise.hint }}</div>
              <input 
                v-model="exerciseAnswer"
                type="text"
                placeholder="Ta réponse..."
                class="exercise-input"
                @keyup.enter="checkExerciseAnswer"
                :disabled="exerciseResult !== null"
              />
            </div>
            <div v-else-if="exerciseType === 'conjugation'" class="exercise-content">
              <div class="exercise-verb">{{ currentExercise.verb }}</div>
              <div class="exercise-hint">{{ currentExercise.tense }} - {{ currentExercise.subject }}</div>
              <input 
                v-model="exerciseAnswer"
                type="text"
                placeholder="Conjugaison..."
                class="exercise-input"
                @keyup.enter="checkExerciseAnswer"
                :disabled="exerciseResult !== null"
              />
            </div>
            <div v-else class="exercise-content">
              <div class="exercise-sentence">{{ currentExercise.sentence }}</div>
              <div class="exercise-hint">💡 {{ currentExercise.hint }}</div>
              <input 
                v-model="exerciseAnswer"
                type="text"
                placeholder="Mot manquant..."
                class="exercise-input"
                @keyup.enter="checkExerciseAnswer"
                :disabled="exerciseResult !== null"
              />
            </div>

            <button 
              v-if="exerciseResult === null"
              class="check-btn"
              @click="checkExerciseAnswer"
              :disabled="!exerciseAnswer.trim()"
            >
              Vérifier
            </button>

            <div v-if="exerciseResult" class="exercise-result" :class="exerciseResult">
              <span v-if="exerciseResult === 'correct'">✅ Bravo !</span>
              <span v-else>❌ La réponse était : <strong>{{ currentExercise.answer }}</strong></span>
              <button class="next-exercise-btn" @click="generateExercise">
                Suivant →
              </button>
            </div>
          </div>

          <div v-if="currentExercise?.error" class="exercise-error">
            {{ currentExercise.error }}
          </div>
        </div>

        <button class="clear-btn" @click="clearChat">
          🗑️ Effacer la conversation
        </button>
      </aside>

      <!-- Chat area -->
      <main class="chat-area">
        <div class="chat-messages" ref="chatContainer">
          <div 
            v-for="(msg, idx) in messages" 
            :key="idx"
            class="message"
            :class="msg.role"
          >
            <div class="message-avatar">
              {{ msg.role === 'user' ? '👤' : '🤖' }}
            </div>
            <div class="message-content">
              <div class="message-text" v-html="msg.content.replace(/\n/g, '<br>')"></div>
              <button 
                v-if="msg.role === 'assistant'"
                class="speak-btn"
                @click="speak(msg.content)"
                title="Écouter"
              >
                🔊
              </button>
            </div>
          </div>

          <div v-if="isLoading" class="message assistant loading">
            <div class="message-avatar">🤖</div>
            <div class="message-content">
              <div class="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        </div>

        <div class="chat-input-area">
          <div class="input-wrapper">
            <textarea
              v-model="inputMessage"
              placeholder="Écris ton message..."
              class="chat-input"
              @keydown.enter.exact.prevent="sendMessage"
              :disabled="isLoading"
              rows="1"
            ></textarea>
            <button 
              class="send-btn"
              @click="sendMessage"
              :disabled="!inputMessage.trim() || isLoading"
            >
              {{ isLoading ? '⏳' : '📤' }}
            </button>
          </div>
          <div class="input-hints">
            <span>Entrée pour envoyer</span>
            <span>Mode: {{ modeLabels[mode].label }}</span>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<style scoped>
.ai-tutor-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  height: calc(100vh - 80px);
  display: flex;
  flex-direction: column;
}

.tutor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.header-content h1 {
  margin: 0;
  font-size: 1.75rem;
  color: #2c3e50;
}

.subtitle {
  margin: 0.25rem 0 0;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.language-toggle {
  display: flex;
  gap: 0.5rem;
}

.lang-btn {
  padding: 0.5rem 1rem;
  border: 2px solid #ddd;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
}

.lang-btn:hover {
  border-color: #3498db;
}

.lang-btn.active {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

/* Layout */
.tutor-layout {
  display: flex;
  gap: 1rem;
  flex: 1;
  min-height: 0;
}

/* Sidebar */
.tutor-sidebar {
  width: 280px;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  flex-shrink: 0;
}

.mode-selector h3,
.exercise-section h3 {
  margin: 0 0 0.75rem;
  font-size: 0.9rem;
  color: #7f8c8d;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.mode-btn {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #e0e0e0;
  background: white;
  border-radius: 10px;
  cursor: pointer;
  text-align: left;
  transition: all 0.2s;
  margin-bottom: 0.5rem;
}

.mode-btn:hover {
  border-color: #667eea;
  background: #f8f9ff;
}

.mode-btn.active {
  border-color: #667eea;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.mode-icon {
  font-size: 1.5rem;
}

.mode-info {
  display: flex;
  flex-direction: column;
}

.mode-label {
  font-weight: 600;
  font-size: 0.95rem;
}

.mode-desc {
  font-size: 0.75rem;
  opacity: 0.7;
}

/* Exercise section */
.exercise-section {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 12px;
}

.exercise-options {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.exercise-select {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 0.85rem;
}

.generate-btn {
  width: 100%;
  padding: 0.75rem;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 600;
  transition: all 0.2s;
}

.generate-btn:hover:not(:disabled) {
  transform: translateY(-2px);
}

.generate-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.exercise-card {
  margin-top: 1rem;
  padding: 1rem;
  background: white;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.exercise-word,
.exercise-verb {
  font-size: 1.25rem;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.exercise-sentence {
  font-size: 1rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.exercise-hint {
  font-size: 0.85rem;
  color: #7f8c8d;
  margin-bottom: 0.75rem;
}

.exercise-input {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  text-align: center;
}

.exercise-input:focus {
  outline: none;
  border-color: #667eea;
}

.check-btn {
  width: 100%;
  margin-top: 0.75rem;
  padding: 0.6rem;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}

.check-btn:disabled {
  opacity: 0.5;
}

.exercise-result {
  margin-top: 0.75rem;
  padding: 0.75rem;
  border-radius: 8px;
  text-align: center;
}

.exercise-result.correct {
  background: #d4edda;
  color: #155724;
}

.exercise-result.wrong {
  background: #f8d7da;
  color: #721c24;
}

.next-exercise-btn {
  margin-top: 0.5rem;
  padding: 0.4rem 1rem;
  background: #2c3e50;
  color: white;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  font-size: 0.85rem;
}

.exercise-error {
  margin-top: 1rem;
  padding: 0.75rem;
  background: #fff3cd;
  color: #856404;
  border-radius: 8px;
  font-size: 0.85rem;
}

.clear-btn {
  padding: 0.75rem;
  background: #f0f0f0;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
  margin-top: auto;
}

.clear-btn:hover {
  background: #e0e0e0;
}

/* Chat area */
.chat-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.08);
  overflow: hidden;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.message {
  display: flex;
  gap: 0.75rem;
  max-width: 85%;
}

.message.user {
  align-self: flex-end;
  flex-direction: row-reverse;
}

.message-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
  flex-shrink: 0;
}

.message.assistant .message-avatar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.message-content {
  position: relative;
}

.message-text {
  padding: 1rem 1.25rem;
  border-radius: 18px;
  line-height: 1.5;
}

.message.user .message-text {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-bottom-right-radius: 4px;
}

.message.assistant .message-text {
  background: #f0f2f5;
  color: #2c3e50;
  border-bottom-left-radius: 4px;
}

.speak-btn {
  position: absolute;
  bottom: -8px;
  right: 8px;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 50%;
  width: 28px;
  height: 28px;
  cursor: pointer;
  font-size: 0.8rem;
  transition: all 0.2s;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.speak-btn:hover {
  background: #667eea;
  border-color: #667eea;
  transform: scale(1.1);
}

/* Typing indicator */
.typing-indicator {
  display: flex;
  gap: 4px;
  padding: 1rem 1.25rem;
  background: #f0f2f5;
  border-radius: 18px;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  background: #7f8c8d;
  border-radius: 50%;
  animation: typing 1.4s infinite;
}

.typing-indicator span:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 60%, 100% { transform: translateY(0); }
  30% { transform: translateY(-8px); }
}

/* Input area */
.chat-input-area {
  padding: 1rem 1.5rem;
  border-top: 1px solid #e0e0e0;
  background: #fafafa;
}

.input-wrapper {
  display: flex;
  gap: 0.75rem;
  align-items: flex-end;
}

.chat-input {
  flex: 1;
  padding: 0.875rem 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 24px;
  font-size: 1rem;
  resize: none;
  font-family: inherit;
  line-height: 1.4;
  max-height: 120px;
}

.chat-input:focus {
  outline: none;
  border-color: #667eea;
}

.send-btn {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  cursor: pointer;
  font-size: 1.25rem;
  transition: all 0.2s;
  flex-shrink: 0;
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.05);
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.input-hints {
  display: flex;
  justify-content: space-between;
  margin-top: 0.5rem;
  font-size: 0.75rem;
  color: #7f8c8d;
}

/* Responsive */
@media (max-width: 900px) {
  .tutor-layout {
    flex-direction: column;
  }
  
  .tutor-sidebar {
    width: 100%;
    flex-direction: row;
    flex-wrap: wrap;
  }
  
  .mode-selector {
    flex: 1;
    min-width: 200px;
  }
  
  .exercise-section {
    flex: 1;
    min-width: 200px;
  }
  
  .clear-btn {
    width: 100%;
    margin-top: 0;
  }
}

@media (max-width: 600px) {
  .ai-tutor-container {
    padding: 0.5rem;
    height: calc(100vh - 70px);
  }
  
  .tutor-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .tutor-sidebar {
    flex-direction: column;
  }
  
  .mode-selector {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
  }
  
  .mode-btn {
    flex: 1;
    min-width: 100px;
    padding: 0.5rem;
  }
  
  .mode-info {
    display: none;
  }
  
  .mode-icon {
    font-size: 1.25rem;
  }
  
  .chat-messages {
    padding: 1rem;
  }
  
  .message {
    max-width: 95%;
  }
  
  .message-text {
    padding: 0.75rem 1rem;
    font-size: 0.95rem;
  }
}
</style>
