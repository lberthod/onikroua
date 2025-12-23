<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { ttsService, getTTSLang } from '../../services/tts'
import { audioRecorder } from '../../services/audioRecorder'
import AudioVisualizer from './AudioVisualizer.vue'

interface PracticeItem {
  word: string
  phonetic?: string
  translation: string
}

interface Props {
  items: PracticeItem[]
  language: 'it' | 'es'
  title?: string
}

const props = defineProps<Props>()

const currentIndex = ref(0)
const showTranslation = ref(false)
const isPlaying = ref(false)
const isRecording = ref(false)
const isUserPlaying = ref(false)
const userAudioUrl = ref<string | null>(null)
const speed = ref<'slow' | 'normal' | 'fast'>('normal')
const attempts = ref(0)
const correctCount = ref(0)

const ttsLang = computed(() => getTTSLang(props.language))

const currentItem = computed(() => props.items[currentIndex.value])

const progress = computed(() => {
  if (props.items.length === 0) return 0
  return Math.round(((currentIndex.value + 1) / props.items.length) * 100)
})

const speedRate = computed(() => {
  switch (speed.value) {
    case 'slow': return 0.5
    case 'normal': return 0.8
    case 'fast': return 1.1
  }
})

const playWord = async () => {
  if (!currentItem.value || isPlaying.value) return

  try {
    isPlaying.value = true
    await ttsService.speak(currentItem.value.word, { 
      lang: ttsLang.value, 
      rate: speedRate.value 
    })
  } catch (error) {
    console.error('Erreur TTS:', error)
  } finally {
    isPlaying.value = false
  }
}

const startRecording = async () => {
  try {
    const permitted = await audioRecorder.requestPermission()
    if (permitted) {
      audioRecorder.startRecording()
      isRecording.value = true
      userAudioUrl.value = null
    }
  } catch (error) {
    console.error('Erreur enregistrement:', error)
  }
}

const stopRecording = async () => {
  try {
    const result = await audioRecorder.stopRecording()
    isRecording.value = false
    userAudioUrl.value = result.url
  } catch (error) {
    console.error('Erreur arrêt enregistrement:', error)
    isRecording.value = false
  }
}

const playUserRecording = () => {
  if (userAudioUrl.value) {
    const audio = new Audio(userAudioUrl.value)
    isUserPlaying.value = true
    audio.onended = () => {
      isUserPlaying.value = false
    }
    audio.play()
  }
}

const nextWord = () => {
  showTranslation.value = false
  userAudioUrl.value = null
  isUserPlaying.value = false
  if (currentIndex.value < props.items.length - 1) {
    currentIndex.value++
  }
}

const prevWord = () => {
  showTranslation.value = false
  userAudioUrl.value = null
  if (currentIndex.value > 0) {
    currentIndex.value--
  }
}

const toggleTranslation = () => {
  showTranslation.value = !showTranslation.value
}

const markCorrect = () => {
  correctCount.value++
  attempts.value++
  nextWord()
}

const markIncorrect = () => {
  attempts.value++
  nextWord()
}

const restart = () => {
  currentIndex.value = 0
  showTranslation.value = false
  attempts.value = 0
  correctCount.value = 0
  userAudioUrl.value = null
}

const accuracy = computed(() => {
  if (attempts.value === 0) return 0
  return Math.round((correctCount.value / attempts.value) * 100)
})

// Auto-play au changement de mot
watch(currentIndex, () => {
  setTimeout(() => playWord(), 300)
})
</script>

<template>
  <div class="practice-mode">
    <div class="practice-header">
      <h3>{{ title || '🎯 Mode Pratique' }}</h3>
      <div class="progress-info">
        <span>{{ currentIndex + 1 }} / {{ items.length }}</span>
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: progress + '%' }"></div>
        </div>
      </div>
    </div>

    <div class="speed-control">
      <span>Vitesse :</span>
      <button 
        :class="['speed-btn', { active: speed === 'slow' }]"
        @click="speed = 'slow'"
      >
        🐢 Lent
      </button>
      <button 
        :class="['speed-btn', { active: speed === 'normal' }]"
        @click="speed = 'normal'"
      >
        🚶 Normal
      </button>
      <button 
        :class="['speed-btn', { active: speed === 'fast' }]"
        @click="speed = 'fast'"
      >
        🏃 Rapide
      </button>
    </div>

    <div class="word-display" v-if="currentItem">
      <div class="word-main">
        <span class="word-text">{{ currentItem.word }}</span>
        <span v-if="currentItem.phonetic" class="word-phonetic">{{ currentItem.phonetic }}</span>
      </div>

      <div class="visualizer-container">
        <AudioVisualizer 
          :is-active="isPlaying || isRecording || isUserPlaying" 
          :color="isRecording ? '#e74c3c' : (isUserPlaying ? '#2ecc71' : '#9b59b6')"
        />
      </div>

      <div class="audio-controls">
        <div class="listen-section">
          <button 
            class="listen-btn"
            @click="playWord"
            :disabled="isPlaying || isRecording || isUserPlaying"
          >
            {{ isPlaying ? '🔊 Lecture...' : '🔊 Écouter' }}
          </button>
        </div>

        <div class="record-section">
          <div v-if="isRecording" class="recording-indicator">
            🔴 Enregistrement...
          </div>
          
          <button 
            v-if="!isRecording && !userAudioUrl"
            class="record-btn"
            @click="startRecording"
            :disabled="isPlaying || isUserPlaying"
          >
            🎙️ Prononcer
          </button>
          
          <button 
            v-if="isRecording"
            class="record-btn stop"
            @click="stopRecording"
          >
            ⏹️ Arrêter
          </button>

          <div v-if="userAudioUrl" class="user-audio-actions">
            <button 
              class="play-record-btn" 
              @click="playUserRecording"
              :disabled="isPlaying || isRecording || isUserPlaying"
            >
              {{ isUserPlaying ? '🔊 Lecture...' : '▶️ Ma prononciation' }}
            </button>
            <button class="retry-btn" @click="userAudioUrl = null" :disabled="isUserPlaying">
              🔄 Réessayer
            </button>
          </div>
        </div>
      </div>

      <div class="translation-section">
        <button 
          class="reveal-btn"
          @click="toggleTranslation"
        >
          {{ showTranslation ? '🙈 Cacher' : '👁️ Voir la traduction' }}
        </button>
        <div class="translation" v-show="showTranslation">
          {{ currentItem.translation }}
        </div>
      </div>
    </div>

    <div class="practice-actions">
      <button 
        class="action-btn incorrect"
        @click="markIncorrect"
        :disabled="currentIndex >= items.length - 1 && attempts > 0"
      >
        ❌ À revoir
      </button>
      <button 
        class="action-btn correct"
        @click="markCorrect"
        :disabled="currentIndex >= items.length - 1 && attempts > 0"
      >
        ✅ Compris
      </button>
    </div>

    <div class="navigation">
      <button 
        class="nav-btn"
        @click="prevWord"
        :disabled="currentIndex === 0"
      >
        ← Précédent
      </button>
      <button 
        class="nav-btn"
        @click="nextWord"
        :disabled="currentIndex >= items.length - 1"
      >
        Suivant →
      </button>
    </div>

    <div class="stats" v-if="attempts > 0">
      <div class="stat-item">
        <span class="stat-value">{{ correctCount }}</span>
        <span class="stat-label">Corrects</span>
      </div>
      <div class="stat-item">
        <span class="stat-value">{{ attempts - correctCount }}</span>
        <span class="stat-label">À revoir</span>
      </div>
      <div class="stat-item">
        <span class="stat-value">{{ accuracy }}%</span>
        <span class="stat-label">Précision</span>
      </div>
    </div>

    <div class="complete-message" v-if="currentIndex >= items.length - 1 && attempts > 0">
      <h4>🎉 Session terminée !</h4>
      <p>Score : {{ correctCount }} / {{ items.length }} ({{ accuracy }}%)</p>
      <button class="restart-btn" @click="restart">🔄 Recommencer</button>
    </div>

    <div class="keyboard-hints">
      <small>⌨️ Raccourcis : <strong>Espace</strong> (Écouter) • <strong>Entrée</strong> (Traduction) • <strong>←/→</strong> (Naviguer)</small>
    </div>
  </div>
</template>

<style scoped>
.practice-mode {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  position: relative;
}

.keyboard-hints {
  text-align: center;
  margin-top: 2rem;
  color: #95a5a6;
  font-size: 0.85rem;
  border-top: 1px solid #f0f0f0;
  padding-top: 1rem;
}

.practice-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.practice-header h3 {
  margin: 0;
  color: #2c3e50;
}

.progress-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.progress-bar {
  width: 100px;
  height: 8px;
  background: #eee;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #9b59b6, #8e44ad);
  transition: width 0.3s ease;
}

.speed-control {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}

.speed-control span {
  color: #7f8c8d;
  font-size: 0.9rem;
}

.speed-btn {
  padding: 0.4rem 0.75rem;
  border: 1px solid #ddd;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.2s;
}

.speed-btn:hover {
  border-color: #9b59b6;
}

.speed-btn.active {
  background: #9b59b6;
  color: white;
  border-color: #9b59b6;
}

.word-display {
  text-align: center;
  padding: 2rem;
  background: #f8f9fa;
  border-radius: 12px;
  margin-bottom: 1.5rem;
}

.word-main {
  margin-bottom: 1.5rem;
}

.word-text {
  display: block;
  font-size: 2.5rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.word-phonetic {
  display: block;
  font-size: 1.25rem;
  color: #9b59b6;
  font-family: monospace;
}

.visualizer-container {
  display: flex;
  justify-content: center;
  margin-bottom: 1.5rem;
  height: 40px;
}

.audio-controls {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.listen-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.listen-btn {
  background: #9b59b6;
  color: white;
  border: none;
  padding: 0.75rem 2rem;
  border-radius: 25px;
  cursor: pointer;
  font-size: 1.1rem;
  transition: all 0.2s;
}

.listen-btn:hover:not(:disabled) {
  background: #8e44ad;
  transform: scale(1.05);
}

.listen-btn:disabled {
  opacity: 0.7;
}

.record-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding-top: 1rem;
  border-top: 1px solid #e0e0e0;
  width: 100%;
}

.recording-indicator {
  color: #e74c3c;
  font-weight: 600;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
}

.record-btn {
  background: white;
  border: 2px solid #e74c3c;
  color: #e74c3c;
  padding: 0.5rem 1.5rem;
  border-radius: 25px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.record-btn:hover {
  background: #e74c3c;
  color: white;
}

.record-btn.stop {
  background: #e74c3c;
  color: white;
}

.user-audio-actions {
  display: flex;
  gap: 0.5rem;
}

.play-record-btn {
  background: #3498db;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
}

.retry-btn {
  background: transparent;
  color: #7f8c8d;
  border: 1px solid #ddd;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
}

.translation-section {
  margin-top: 1rem;
}

.reveal-btn {
  background: #e8e8e8;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
}

.reveal-btn:hover {
  background: #ddd;
}

.translation {
  margin-top: 0.75rem;
  font-size: 1.25rem;
  color: #3498db;
  font-style: italic;
}

.practice-actions {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.action-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.action-btn.correct {
  background: #27ae60;
  color: white;
}

.action-btn.correct:hover:not(:disabled) {
  background: #219a52;
}

.action-btn.incorrect {
  background: #e74c3c;
  color: white;
}

.action-btn.incorrect:hover:not(:disabled) {
  background: #c0392b;
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.navigation {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1.5rem;
}

.nav-btn {
  background: none;
  border: 1px solid #ddd;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.nav-btn:hover:not(:disabled) {
  border-color: #9b59b6;
  color: #9b59b6;
}

.nav-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.stats {
  display: flex;
  justify-content: center;
  gap: 2rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  display: block;
  font-size: 1.5rem;
  font-weight: 600;
  color: #2c3e50;
}

.stat-label {
  font-size: 0.85rem;
  color: #7f8c8d;
}

.complete-message {
  text-align: center;
  padding: 1.5rem;
  background: #e8f5e9;
  border-radius: 8px;
  margin-top: 1rem;
}

.complete-message h4 {
  margin: 0 0 0.5rem 0;
  color: #27ae60;
}

.complete-message p {
  margin: 0 0 1rem 0;
  color: #2e7d32;
}

.restart-btn {
  background: #27ae60;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.restart-btn:hover {
  background: #219a52;
}

/* Responsive */
@media (max-width: 768px) {
  .practice-container {
    padding: 1.25rem;
  }
  
  .word-display {
    font-size: 2rem;
    padding: 2rem;
  }
  
  .practice-actions {
    flex-wrap: wrap;
  }
  
  .action-btn {
    padding: 0.6rem 1rem;
    font-size: 0.95rem;
  }
  
  .stats {
    gap: 1rem;
    flex-wrap: wrap;
  }
  
  .stat-value {
    font-size: 1.25rem;
  }
}

@media (max-width: 480px) {
  .practice-container {
    padding: 1rem;
  }
  
  .word-display {
    font-size: 1.5rem;
    padding: 1.5rem;
  }
  
  .translation {
    font-size: 1.1rem;
  }
  
  .practice-actions {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .action-btn {
    width: 100%;
    padding: 0.75rem;
  }
  
  .navigation {
    gap: 0.5rem;
  }
  
  .nav-btn {
    padding: 0.4rem 0.75rem;
    font-size: 0.9rem;
  }
  
  .stats {
    padding: 0.75rem;
    gap: 0.75rem;
  }
  
  .stat-value {
    font-size: 1.1rem;
  }
  
  .stat-label {
    font-size: 0.8rem;
  }
  
  .complete-message {
    padding: 1rem;
  }
  
  .restart-btn {
    padding: 0.6rem 1rem;
    font-size: 0.95rem;
  }
}
</style>
