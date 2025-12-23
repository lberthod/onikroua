<script setup lang="ts">
import { ref, computed, nextTick, watch } from 'vue'
import { useRoomStore } from '../stores/room'
import { useAuthStore } from '../stores/auth'

const roomStore = useRoomStore()
const authStore = useAuthStore()

const newMessage = ref('')
const messagesContainer = ref<HTMLElement | null>(null)
const showSuggestionForm = ref(false)
const suggestionQuestion = ref('')
const suggestionAnswer = ref('')

const messages = computed(() => roomStore.messagesList)

const isPlayer2 = computed(() => {
  return !roomStore.isHost && roomStore.room?.status === 'playing'
})

const handleSend = async () => {
  const text = newMessage.value.trim()
  if (!text) return
  
  newMessage.value = ''
  await roomStore.sendMessage(text)
}

const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    handleSend()
  }
}

const isMyMessage = (uid: string) => {
  return uid === authStore.user?.uid
}

const handleSuggestQuestion = async () => {
  if (!suggestionQuestion.value.trim()) return
  
  const suggestion = `💡 SUGGESTION: "${suggestionQuestion.value}"${suggestionAnswer.value ? ` (Réponse: ${suggestionAnswer.value})` : ''}`
  await roomStore.sendMessage(suggestion)
  
  suggestionQuestion.value = ''
  suggestionAnswer.value = ''
  showSuggestionForm.value = false
}

// Scroll auto vers le bas quand nouveaux messages
watch(messages, async () => {
  await nextTick()
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}, { deep: true })
</script>

<template>
  <div class="chat-panel card">
    <div class="chat-header">
      <h3>💬 Chat</h3>
      <button 
        v-if="isPlayer2"
        class="suggest-btn"
        @click="showSuggestionForm = !showSuggestionForm"
        :class="{ active: showSuggestionForm }"
      >
        💡 Proposer
      </button>
    </div>

    <!-- Formulaire de suggestion -->
    <div v-if="showSuggestionForm" class="suggestion-form">
      <input
        v-model="suggestionQuestion"
        type="text"
        class="input"
        placeholder="Votre question..."
      />
      <input
        v-model="suggestionAnswer"
        type="text"
        class="input"
        placeholder="Réponse (optionnel)"
      />
      <button 
        class="btn btn-primary"
        @click="handleSuggestQuestion"
        :disabled="!suggestionQuestion.trim()"
      >
        Envoyer la suggestion
      </button>
    </div>

    <div ref="messagesContainer" class="messages-container">
      <div v-if="messages.length === 0" class="no-messages">
        Aucun message. Dites bonjour !
      </div>
      <div
        v-for="msg in messages"
        :key="msg.id"
        :class="['message', { mine: isMyMessage(msg.uid), suggestion: msg.text.startsWith('💡') }]"
      >
        <div class="message-bubble">
          {{ msg.text }}
        </div>
      </div>
    </div>

    <div class="chat-input">
      <input
        v-model="newMessage"
        type="text"
        class="input"
        placeholder="Votre message..."
        @keydown="handleKeydown"
      />
      <button
        @click="handleSend"
        class="btn btn-primary send-btn"
        :disabled="!newMessage.trim()"
      >
        ➤
      </button>
    </div>
  </div>
</template>

<style scoped>
.chat-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 300px;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.chat-header h3 {
  margin: 0;
  color: #2c3e50;
  font-size: 1rem;
}

.suggest-btn {
  background: #f39c12;
  color: white;
  border: none;
  padding: 0.4rem 0.75rem;
  border-radius: 15px;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s;
}

.suggest-btn:hover {
  background: #e67e22;
}

.suggest-btn.active {
  background: #27ae60;
}

.suggestion-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 0.75rem;
  background: #fef9e7;
  border: 1px solid #f39c12;
  border-radius: 8px;
  margin-bottom: 0.75rem;
}

.suggestion-form .input {
  font-size: 0.9rem;
  padding: 0.5rem;
}

.suggestion-form .btn {
  padding: 0.5rem;
  font-size: 0.85rem;
}

.messages-container {
  flex: 1;
  overflow-y: auto;
  padding: 0.5rem;
  background: #f8f9fa;
  border-radius: 6px;
  margin-bottom: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-height: 300px;
}

.no-messages {
  text-align: center;
  color: #7f8c8d;
  font-style: italic;
  padding: 2rem 0;
}

.message {
  display: flex;
}

.message.mine {
  justify-content: flex-end;
}

.message-bubble {
  max-width: 80%;
  padding: 0.5rem 0.75rem;
  border-radius: 12px;
  background: white;
  border: 1px solid #ddd;
  word-break: break-word;
}

.message.mine .message-bubble {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

.message.suggestion .message-bubble {
  background: #fef9e7;
  border-color: #f39c12;
  color: #7f6003;
  font-style: italic;
}

.message.mine.suggestion .message-bubble {
  background: #f39c12;
  border-color: #f39c12;
  color: white;
}

.chat-input {
  display: flex;
  gap: 0.5rem;
}

.chat-input .input {
  flex: 1;
}

.send-btn {
  padding: 0.75rem 1rem;
  min-width: 50px;
}
</style>
