<template>
  <div class="gemini-chat-container">
    <div class="chat-header">
      <div class="header-content">
        <h1>💬 Gemini Chat</h1>
        <p class="subtitle">Powered by Gemini 2.5 Flash Lite</p>
      </div>
      <div class="header-actions">
        <button @click="audioEnabled = !audioEnabled" class="audio-toggle-btn" :class="{ active: audioEnabled }">
          {{ audioEnabled ? '🔊 Audio activé' : '🔇 Audio désactivé' }}
        </button>
        <button v-if="messages.length > 0" @click="clearChat" class="clear-btn">
          Nouvelle conversation
        </button>
      </div>
    </div>

    <div class="chat-messages" ref="messagesContainer">
      <div v-if="messages.length === 0" class="welcome-message">
        <div class="welcome-icon">✨</div>
        <h2>Bienvenue sur Gemini Chat</h2>
        <p>Posez-moi n'importe quelle question, je suis là pour vous aider !</p>
      </div>

      <div
        v-for="(msg, index) in messages"
        :key="index"
        :class="['message', msg.role]"
      >
        <div class="message-avatar">
          {{ msg.role === 'user' ? '👤' : '🤖' }}
        </div>
        <div class="message-content">
          <div class="message-text" v-html="formatMessage(msg.text)"></div>
          <div class="message-time">{{ formatTime(msg.timestamp) }}</div>
        </div>
      </div>

      <div v-if="isLoading" class="message assistant">
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

    <div class="chat-input-container">
      <div v-if="error" class="error-message">
        {{ error }}
      </div>
      <form @submit.prevent="sendMessage" class="chat-input-form">
        <textarea
          v-model="inputMessage"
          @keydown.enter.exact.prevent="sendMessage"
          placeholder="Écrivez votre message... (Entrée pour envoyer)"
          class="chat-input"
          rows="1"
          :disabled="isLoading"
        ></textarea>
        <button
          type="submit"
          class="send-btn"
          :disabled="!inputMessage.trim() || isLoading"
        >
          <span v-if="!isLoading">📤</span>
          <span v-else class="spinner">⏳</span>
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick, onMounted } from 'vue'

interface Message {
  role: 'user' | 'assistant'
  text: string
  timestamp: Date
}

const messages = ref<Message[]>([])
const inputMessage = ref('')
const isLoading = ref(false)
const error = ref('')
const messagesContainer = ref<HTMLElement | null>(null)
const audioEnabled = ref(false)

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001'

const speakText = (text: string) => {
  if (!('speechSynthesis' in window)) {
    console.error('Speech Synthesis not supported')
    return
  }

  window.speechSynthesis.cancel()

  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = 'fr-FR'
  utterance.rate = 1.0
  utterance.pitch = 1.0
  utterance.volume = 1.0

  const voices = window.speechSynthesis.getVoices()
  const frenchVoice = voices.find(voice => voice.lang.startsWith('fr'))
  if (frenchVoice) {
    utterance.voice = frenchVoice
  }

  window.speechSynthesis.speak(utterance)
}

const formatMessage = (text: string) => {
  return text
    .replace(/\n/g, '<br>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/`(.*?)`/g, '<code>$1</code>')
}

const formatTime = (date: Date) => {
  return date.toLocaleTimeString('fr-FR', { 
    hour: '2-digit', 
    minute: '2-digit' 
  })
}

const scrollToBottom = async () => {
  await nextTick()
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

const sendMessage = async () => {
  if (!inputMessage.value.trim() || isLoading.value) return

  const userMessage = inputMessage.value.trim()
  inputMessage.value = ''
  error.value = ''

  messages.value.push({
    role: 'user',
    text: userMessage,
    timestamp: new Date()
  })

  scrollToBottom()

  isLoading.value = true

  const assistantMessageIndex = messages.value.length
  messages.value.push({
    role: 'assistant',
    text: '',
    timestamp: new Date()
  })

  try {
    const conversationHistory = messages.value.slice(0, -2).map(msg => ({
      role: msg.role === 'user' ? 'user' : 'model',
      text: msg.text
    }))

    const endpoint = audioEnabled.value ? '/api/gemini/stream-audio' : '/api/gemini/stream'
    
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        message: userMessage,
        conversationHistory
      })
    })

    if (!response.ok) {
      throw new Error('Erreur lors de la requête')
    }

    const reader = response.body?.getReader()
    const decoder = new TextDecoder()

    if (!reader) {
      throw new Error('Stream non disponible')
    }

    let accumulatedText = ''

    while (true) {
      const { done, value } = await reader.read()
      
      if (done) break

      const chunk = decoder.decode(value, { stream: true })
      const lines = chunk.split('\n')

      for (const line of lines) {
        if (line.startsWith('data: ')) {
          const data = line.slice(6)
          
          try {
            const parsed = JSON.parse(data)
            
            if (parsed.text) {
              accumulatedText += parsed.text
              messages.value[assistantMessageIndex].text = accumulatedText
              scrollToBottom()
            }
            
            if (parsed.fullText && audioEnabled.value) {
              speakText(parsed.fullText)
            }
            
            if (parsed.done) {
              isLoading.value = false
            }

            if (parsed.error) {
              throw new Error(parsed.error)
            }
          } catch (parseErr) {
            console.error('Error parsing SSE data:', parseErr)
          }
        }
      }
    }

    if (!accumulatedText) {
      messages.value[assistantMessageIndex].text = '❌ Aucune réponse reçue'
    }

  } catch (err: any) {
    console.error('Error sending message:', err)
    error.value = err.message || 'Une erreur est survenue'
    
    messages.value[assistantMessageIndex].text = '❌ Désolé, une erreur est survenue. Veuillez réessayer.'
  } finally {
    isLoading.value = false
    scrollToBottom()
  }
}

const clearChat = () => {
  if (confirm('Voulez-vous vraiment effacer cette conversation ?')) {
    messages.value = []
    error.value = ''
  }
}

onMounted(() => {
  scrollToBottom()
})
</script>

<style scoped>
.gemini-chat-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.chat-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 1.5rem 2rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-content h1 {
  margin: 0;
  font-size: 1.75rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.subtitle {
  margin: 0.25rem 0 0 0;
  font-size: 0.9rem;
  color: #666;
}

.header-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.audio-toggle-btn {
  padding: 0.6rem 1.2rem;
  background: white;
  border: 2px solid #999;
  color: #666;
  border-radius: 20px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.audio-toggle-btn:hover {
  border-color: #667eea;
  color: #667eea;
}

.audio-toggle-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: #667eea;
  color: white;
}

.audio-toggle-btn.active:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.clear-btn {
  padding: 0.6rem 1.2rem;
  background: white;
  border: 2px solid #667eea;
  color: #667eea;
  border-radius: 20px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.clear-btn:hover {
  background: #667eea;
  color: white;
  transform: translateY(-2px);
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.welcome-message {
  text-align: center;
  padding: 3rem 2rem;
  color: white;
}

.welcome-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.welcome-message h2 {
  margin: 1rem 0;
  font-size: 2rem;
}

.welcome-message p {
  font-size: 1.1rem;
  opacity: 0.9;
}

.message {
  display: flex;
  gap: 1rem;
  max-width: 80%;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.message.user {
  align-self: flex-end;
  flex-direction: row-reverse;
}

.message-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.message-content {
  background: white;
  border-radius: 18px;
  padding: 1rem 1.25rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  min-width: 100px;
}

.message.user .message-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.message-text {
  line-height: 1.5;
  word-wrap: break-word;
}

.message-text :deep(strong) {
  font-weight: 700;
}

.message-text :deep(em) {
  font-style: italic;
}

.message-text :deep(code) {
  background: rgba(0, 0, 0, 0.1);
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-family: monospace;
  font-size: 0.9em;
}

.message.user .message-text :deep(code) {
  background: rgba(255, 255, 255, 0.2);
}

.message-time {
  font-size: 0.75rem;
  color: #999;
  margin-top: 0.5rem;
}

.message.user .message-time {
  color: rgba(255, 255, 255, 0.8);
  text-align: right;
}

.typing-indicator {
  display: flex;
  gap: 0.3rem;
  padding: 0.5rem 0;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #667eea;
  animation: bounce 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) {
  animation-delay: -0.32s;
}

.typing-indicator span:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

.chat-input-container {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 1.5rem 2rem;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
}

.error-message {
  background: #fee;
  color: #c33;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  font-size: 0.9rem;
}

.chat-input-form {
  display: flex;
  gap: 1rem;
  align-items: flex-end;
}

.chat-input {
  flex: 1;
  padding: 1rem 1.25rem;
  border: 2px solid #e0e0e0;
  border-radius: 24px;
  font-size: 1rem;
  font-family: inherit;
  resize: none;
  min-height: 50px;
  max-height: 150px;
  transition: border-color 0.3s ease;
}

.chat-input:focus {
  outline: none;
  border-color: #667eea;
}

.chat-input:disabled {
  background: #f5f5f5;
  cursor: not-allowed;
}

.send-btn {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.spinner {
  display: inline-block;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.chat-messages::-webkit-scrollbar {
  width: 8px;
}

.chat-messages::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 4px;
}

.chat-messages::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.3);
  border-radius: 4px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.5);
}
</style>
