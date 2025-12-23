<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useRoomStore } from '../stores/room'
import { useAuthStore } from '../stores/auth'
import RoomPlayers from '../components/RoomPlayers.vue'
import QuizPanel from '../components/QuizPanel.vue'
import ChatPanel from '../components/ChatPanel.vue'
import { quizCategories } from '../data/quizQuestions'

const route = useRoute()
const router = useRouter()
const roomStore = useRoomStore()
void useAuthStore()

const roomId = computed(() => route.params.roomId as string)
const showSettings = ref(false)
const selectedCategory = ref<'all' | 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics'>('all')
const questionCount = ref(10)

const languageLabel = computed(() => {
  if (!roomStore.room) return ''
  return roomStore.room.language === 'it' ? '🇮🇹 Italien' : '🇪🇸 Espagnol'
})

const statusLabel = computed(() => {
  if (!roomStore.room) return ''
  const statuses: Record<string, string> = {
    waiting: '⏳ En attente',
    playing: '🎮 En cours',
    finished: '✅ Terminé'
  }
  return statuses[roomStore.room.status] || roomStore.room.status
})

const canStart = computed(() => {
  if (!roomStore.room || !roomStore.isHost) return false
  const playerCount = Object.keys(roomStore.players).length
  return roomStore.room.status === 'waiting' && playerCount >= 2
})

const handleStartSession = async () => {
  try {
    await roomStore.startSession(selectedCategory.value, questionCount.value)
    showSettings.value = false
  } catch (e) {
    console.error('Erreur démarrage session:', e)
  }
}

const handleLeave = () => {
  roomStore.leaveRoom()
  router.push('/lobby')
}

onMounted(() => {
  roomStore.subscribeToRoom(roomId.value)
  // Charger les options depuis le store
  selectedCategory.value = roomStore.quizOptions.category
  questionCount.value = roomStore.quizOptions.questionCount
})

onUnmounted(() => {
  roomStore.leaveRoom()
})
</script>

<template>
  <div class="room">
    <!-- Header Room -->
    <div class="room-header card">
      <div class="room-info">
        <h1>Room: {{ roomId }}</h1>
        <div class="room-meta">
          <span class="badge">{{ languageLabel }}</span>
          <span class="badge status">{{ statusLabel }}</span>
        </div>
      </div>
      <div class="room-actions">
        <button
          v-if="canStart"
          @click="handleStartSession"
          class="btn btn-success"
          :disabled="roomStore.loading"
        >
          🚀 Démarrer le Quiz
        </button>
        <button @click="handleLeave" class="btn btn-secondary">
          Quitter
        </button>
      </div>
    </div>

    <!-- Message attente si host seul -->
    <div v-if="roomStore.room?.status === 'waiting' && Object.keys(roomStore.players).length < 2" class="waiting-message card">
      <p>🔗 Partagez ce code avec votre ami pour qu'il rejoigne :</p>
      <div class="room-code">{{ roomId }}</div>
      <p class="hint">En attente du deuxième joueur...</p>
    </div>

    <!-- Panneau de configuration (Host) -->
    <div v-if="roomStore.isHost && roomStore.room?.status === 'waiting' && Object.keys(roomStore.players).length >= 2" class="settings-panel card">
      <div class="settings-header">
        <h3>⚙️ Configuration du Quiz</h3>
        <button class="toggle-settings" @click="showSettings = !showSettings">
          {{ showSettings ? '▲ Masquer' : '▼ Options' }}
        </button>
      </div>
      
      <div v-if="showSettings" class="settings-content">
        <div class="setting-group">
          <label>Catégorie</label>
          <div class="category-buttons">
            <button
              v-for="cat in quizCategories"
              :key="cat.id"
              :class="['cat-btn', { active: selectedCategory === cat.id }]"
              @click="selectedCategory = cat.id as typeof selectedCategory"
            >
              <span>{{ cat.icon }}</span>
              <span>{{ cat.label }}</span>
            </button>
          </div>
        </div>
        
        <div class="setting-group">
          <label>Nombre de questions : {{ questionCount }}</label>
          <div class="question-count-btns">
            <button 
              v-for="n in [5, 10, 15, 20]" 
              :key="n"
              :class="['count-btn', { active: questionCount === n }]"
              @click="questionCount = n"
            >
              {{ n }}
            </button>
          </div>
        </div>
      </div>
      
      <button
        @click="handleStartSession"
        class="btn btn-success start-btn"
        :disabled="roomStore.loading"
      >
        {{ roomStore.loading ? 'Démarrage...' : '🚀 Lancer le Quiz' }}
      </button>
    </div>

    <!-- Contenu principal -->
    <div class="room-content">
      <!-- Joueurs -->
      <div class="room-sidebar">
        <RoomPlayers />
      </div>

      <!-- Zone principale : Quiz ou placeholder -->
      <div class="room-main">
        <QuizPanel v-if="roomStore.session" />
        <div v-else class="no-session card">
          <p v-if="roomStore.isHost && Object.keys(roomStore.players).length >= 2">
            ⬆️ Configurez et lancez le quiz ci-dessus
          </p>
          <p v-else-if="roomStore.isHost">
            ⏳ En attente d'un autre joueur...
          </p>
          <p v-else>
            ⏳ En attente que l'hôte démarre le quiz...
          </p>
        </div>
      </div>

      <!-- Chat -->
      <div class="room-chat">
        <ChatPanel />
      </div>
    </div>

    <p v-if="roomStore.error" class="error-message">{{ roomStore.error }}</p>
  </div>
</template>

<style scoped>
.room {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.room-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
}

.room-info h1 {
  margin: 0;
  font-size: 1.25rem;
  color: #2c3e50;
}

.room-meta {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.badge {
  padding: 0.25rem 0.75rem;
  background: #ecf0f1;
  border-radius: 20px;
  font-size: 0.85rem;
}

.badge.status {
  background: #e8f4fc;
  color: #2980b9;
}

.room-actions {
  display: flex;
  gap: 0.5rem;
}

.waiting-message {
  text-align: center;
  background: #fffbea;
  border: 1px solid #f1c40f;
}

.room-code {
  font-size: 1.5rem;
  font-weight: bold;
  font-family: monospace;
  background: #2c3e50;
  color: #fff;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  display: inline-block;
  margin: 0.5rem 0;
  user-select: all;
}

.hint {
  color: #7f8c8d;
  font-size: 0.9rem;
}

.room-content {
  display: grid;
  grid-template-columns: 200px 1fr 280px;
  gap: 1rem;
  min-height: 400px;
}

@media (max-width: 900px) {
  .room-content {
    grid-template-columns: 1fr;
  }
}

.room-sidebar,
.room-main,
.room-chat {
  display: flex;
  flex-direction: column;
}

.no-session {
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 1;
  text-align: center;
  color: #7f8c8d;
  font-size: 1.1rem;
}

/* Settings Panel */
.settings-panel {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border: 2px solid #3498db;
}

.settings-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.settings-header h3 {
  margin: 0;
  color: #2c3e50;
  font-size: 1.1rem;
}

.toggle-settings {
  background: none;
  border: none;
  color: #7f8c8d;
  cursor: pointer;
  font-size: 0.9rem;
  padding: 0.25rem 0.5rem;
}

.toggle-settings:hover {
  color: #3498db;
}

.settings-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1rem;
  background: white;
  border-radius: 8px;
  margin-bottom: 1rem;
}

.setting-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.setting-group label {
  font-weight: 600;
  color: #2c3e50;
  font-size: 0.9rem;
}

.category-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.cat-btn {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.5rem 0.75rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.2s;
}

.cat-btn:hover {
  border-color: #9b59b6;
}

.cat-btn.active {
  border-color: #9b59b6;
  background: #f3e5f5;
  color: #9b59b6;
}

.question-count-btns {
  display: flex;
  gap: 0.5rem;
}

.count-btn {
  padding: 0.5rem 1rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 600;
  transition: all 0.2s;
}

.count-btn:hover {
  border-color: #3498db;
}

.count-btn.active {
  border-color: #3498db;
  background: #e8f4fc;
  color: #3498db;
}

.start-btn {
  width: 100%;
  padding: 1rem;
  font-size: 1.1rem;
}

@media (max-width: 768px) {
  .settings-content {
    padding: 0.75rem;
  }
  
  .category-buttons {
    justify-content: center;
  }
  
  .question-count-btns {
    justify-content: center;
  }
}
</style>
