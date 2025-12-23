<template>
  <div class="feed-card phonetic-card">
    <div class="card-header">
      <div class="card-type">
        <span class="type-icon">🔊</span>
        <span class="type-label">Phonétique</span>
      </div>
      <div class="difficulty-badge" :class="item.difficulty">
        {{ difficultyLabel }}
      </div>
    </div>

    <div class="card-content">
      <div class="phonetic-header">
        <div class="category-badge" :class="item.data.category">
          {{ categoryLabels[item.data.category] }}
        </div>
        <div v-if="item.data.position" class="position-badge">
          📍 {{ item.data.position }}
        </div>
      </div>

      <div class="sound-display">
        <div class="graphie-phonetic">
          <div class="graphie">{{ item.data.graphie }}</div>
          <div class="phonetic-symbol">{{ item.data.phonetic }}</div>
        </div>
        <button 
          @click="playExamples"
          class="play-sound-btn"
          :disabled="isPlaying"
        >
          🎵 Écouter
        </button>
      </div>

      <div class="description">
        {{ item.data.description }}
      </div>

      <div v-if="item.data.examples?.length" class="examples-section">
        <h4>Exemples :</h4>
        <div class="examples-grid">
          <div 
            v-for="example in item.data.examples.slice(0, 4)"
            :key="example"
            class="example-word"
            @click="playText(example)"
          >
            <span class="word">{{ example }}</span>
            <span class="play-icon">🔊</span>
          </div>
        </div>
      </div>

      <div v-if="item.data.tips" class="tips-section">
        <div class="tips-header">
          <span class="tips-icon">💡</span>
          <strong>Conseil :</strong>
        </div>
        <div class="tips-content">{{ item.data.tips }}</div>
      </div>

      <div v-if="item.data.commonMistakes" class="mistakes-section">
        <div class="mistakes-header">
          <span class="mistakes-icon">⚠️</span>
          <strong>Attention :</strong>
        </div>
        <div class="mistakes-content">{{ item.data.commonMistakes }}</div>
      </div>
    </div>

    <div class="card-actions">
      <button @click="startPractice" class="practice-btn">
        <span class="btn-icon">🎯</span>
        Pratiquer la prononciation
      </button>
    </div>

    <!-- Practice section -->
    <div v-if="showPractice" class="practice-section">
      <div class="practice-header">
        <h4>🗣️ Entraînement</h4>
        <button @click="showPractice = false" class="close-btn">×</button>
      </div>
      
      <div class="practice-word">
        <div class="word-to-practice">{{ currentPracticeWord }}</div>
        <div class="phonetic-guide">{{ item.data.phonetic }}</div>
        
        <div class="practice-controls">
          <button @click="playText(currentPracticeWord)" class="listen-btn">
            🎧 Écouter
          </button>
          <button @click="startRecording" :disabled="isRecording" class="record-btn">
            {{ isRecording ? '🔴 Arrêter' : '🎤 S\'enregistrer' }}
          </button>
        </div>
      </div>

      <div v-if="practiceWords.length > 1" class="word-navigation">
        <button 
          @click="previousWord" 
          :disabled="currentWordIndex === 0"
          class="nav-btn"
        >
          ← Précédent
        </button>
        <span class="word-counter">
          {{ currentWordIndex + 1 }} / {{ practiceWords.length }}
        </span>
        <button 
          @click="nextWord" 
          :disabled="currentWordIndex === practiceWords.length - 1"
          class="nav-btn"
        >
          Suivant →
        </button>
      </div>

      <div class="practice-tips">
        <div class="tip">
          <strong>🎯 Focus :</strong> Concentrez-vous sur le son {{ item.data.phonetic }}
        </div>
        <div v-if="item.data.tips" class="tip">
          <strong>💡 Astuce :</strong> {{ item.data.tips }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import type { PhoneticFeedItem } from '../../services/feedService'

const props = defineProps<{
  item: PhoneticFeedItem
  language: 'it' | 'es'
}>()

const showPractice = ref(false)
const isPlaying = ref(false)
const isRecording = ref(false)
const currentWordIndex = ref(0)

const categoryLabels = {
  vowels: '🔤 Voyelles',
  consonants: '🔠 Consonnes', 
  combinations: '🔗 Combinaisons',
  accent: '🎵 Accent',
  special: '⭐ Spéciaux'
}

const difficultyLabel = computed(() => {
  const labels = {
    'beginner': 'Débutant',
    'intermediate': 'Intermédiaire', 
    'advanced': 'Avancé'
  }
  return labels[props.item.difficulty]
})

const practiceWords = computed(() => {
  return props.item.data.examples || []
})

const currentPracticeWord = computed(() => {
  return practiceWords.value[currentWordIndex.value] || ''
})

const startPractice = () => {
  showPractice.value = true
  currentWordIndex.value = 0
}

const nextWord = () => {
  if (currentWordIndex.value < practiceWords.value.length - 1) {
    currentWordIndex.value++
  }
}

const previousWord = () => {
  if (currentWordIndex.value > 0) {
    currentWordIndex.value--
  }
}

const playText = (text: string) => {
  if (isPlaying.value || !text) return
  
  isPlaying.value = true
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = props.language === 'it' ? 'it-IT' : 'es-ES'
  utterance.rate = 0.7 // Slower for pronunciation practice
  
  utterance.onend = () => {
    isPlaying.value = false
  }
  
  speechSynthesis.speak(utterance)
}

const playExamples = () => {
  if (props.item.data.examples && props.item.data.examples.length > 0) {
    playText(props.item.data.examples[0])
  }
}

const startRecording = () => {
  if (isRecording.value) {
    stopRecording()
  } else {
    startMicrophoneRecording()
  }
}

const startMicrophoneRecording = async () => {
  try {
    // Note: In a real app, you would implement actual recording
    // For now, we'll just simulate the recording process
    isRecording.value = true
    
    // Simulate recording for 3 seconds
    setTimeout(() => {
      isRecording.value = false
      // Here you would process the recording and provide feedback
      console.log('Recording completed')
    }, 3000)
    
  } catch (error) {
    console.error('Could not start recording:', error)
    isRecording.value = false
  }
}

const stopRecording = () => {
  isRecording.value = false
}

// Reset practice when item changes
watch(() => props.item.id, () => {
  showPractice.value = false
  currentWordIndex.value = 0
})
</script>

<style scoped>
.feed-card {
  background: white;
  border-radius: 0;
  padding: 1rem;
  box-shadow: none;
  border: none;
  transition: all 0.3s ease;
  height: 100%;
}

.feed-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.card-type {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #7c3aed;
  font-weight: 600;
}

.type-icon {
  font-size: 1.2rem;
}

.difficulty-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.difficulty-badge.beginner {
  background: #dcfce7;
  color: #166534;
}

.difficulty-badge.intermediate {
  background: #fef3c7;
  color: #92400e;
}

.difficulty-badge.advanced {
  background: #fee2e2;
  color: #991b1b;
}

.phonetic-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.category-badge {
  padding: 0.5rem 0.75rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
}

.category-badge.vowels {
  background: #e0e7ff;
  color: #3730a3;
}

.category-badge.consonants {
  background: #ecfdf5;
  color: #065f46;
}

.category-badge.combinations {
  background: #fef3c7;
  color: #92400e;
}

.category-badge.accent {
  background: #fce7f3;
  color: #be185d;
}

.category-badge.special {
  background: #f3e8ff;
  color: #6b21a8;
}

.position-badge {
  padding: 0.25rem 0.5rem;
  background: #f3f4f6;
  color: #374151;
  border-radius: 8px;
  font-size: 0.8rem;
}

.sound-display {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: linear-gradient(135deg, #f3e8ff, #e879f9);
  padding: 1.25rem;
  border-radius: 12px;
  margin: 0.75rem 0;
}

.graphie-phonetic {
  text-align: center;
}

.graphie {
  font-size: 2rem;
  font-weight: bold;
  color: #6b21a8;
  margin-bottom: 0.4rem;
}

.phonetic-symbol {
  font-size: 1.1rem;
  color: #7c3aed;
  font-family: 'Courier New', monospace;
  background: rgba(255, 255, 255, 0.8);
  padding: 0.2rem 0.4rem;
  border-radius: 6px;
}

.play-sound-btn {
  background: rgba(255, 255, 255, 0.9);
  border: 2px solid #7c3aed;
  border-radius: 12px;
  padding: 0.75rem 1rem;
  cursor: pointer;
  font-weight: 600;
  color: #6b21a8;
  transition: all 0.3s ease;
}

.play-sound-btn:hover:not(:disabled) {
  background: #7c3aed;
  color: white;
  transform: scale(1.05);
}

.play-sound-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.description {
  color: #4b5563;
  line-height: 1.5;
  margin: 0.75rem 0;
  text-align: center;
  font-style: italic;
  font-size: 0.95rem;
}

.examples-section {
  margin: 0.75rem 0;
}

.examples-section h4 {
  color: #374151;
  margin-bottom: 0.75rem;
  font-size: 1rem;
}

.examples-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem;
}

.example-word {
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.6rem;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
  position: relative;
  min-height: 44px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.example-word:hover {
  border-color: #7c3aed;
  background: #f3e8ff;
}

.example-word .word {
  display: block;
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.25rem;
}

.example-word .play-icon {
  font-size: 0.8rem;
  opacity: 0.7;
}

.tips-section, .mistakes-section {
  background: linear-gradient(135deg, #fef7ed, #fed7aa);
  padding: 0.75rem;
  border-radius: 10px;
  margin: 0.75rem 0;
  border-left: 3px solid #ea580c;
}

.mistakes-section {
  background: linear-gradient(135deg, #fef2f2, #fecaca);
  border-left-color: #dc2626;
}

.tips-header, .mistakes-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.tips-header {
  color: #9a3412;
}

.mistakes-header {
  color: #991b1b;
}

.tips-content, .mistakes-content {
  line-height: 1.5;
}

.tips-content {
  color: #9a3412;
}

.mistakes-content {
  color: #991b1b;
}

.card-actions {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid #e5e7eb;
}

.practice-btn {
  background: linear-gradient(135deg, #7c3aed, #a855f7);
  color: white;
  border: none;
  padding: 0.75rem 1rem;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  width: 100%;
  justify-content: center;
  min-height: 48px;
}

.practice-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.4);
}

.practice-section {
  margin-top: 1rem;
  padding: 1rem;
  background: #f9fafb;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
}

.practice-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.practice-header h4 {
  margin: 0;
  color: #374151;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #6b7280;
  width: 2rem;
  height: 2rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: #e5e7eb;
}

.practice-word {
  text-align: center;
  margin-bottom: 1.5rem;
}

.word-to-practice {
  font-size: 2rem;
  font-weight: bold;
  color: #7c3aed;
  margin-bottom: 0.5rem;
}

.phonetic-guide {
  font-family: 'Courier New', monospace;
  font-size: 1.2rem;
  color: #6b7280;
  margin-bottom: 1rem;
}

.practice-controls {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.listen-btn, .record-btn {
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.listen-btn {
  background: #e0e7ff;
  color: #3730a3;
}

.listen-btn:hover {
  background: #c7d2fe;
}

.record-btn {
  background: #fecaca;
  color: #991b1b;
}

.record-btn:hover:not(:disabled) {
  background: #fca5a5;
}

.record-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.word-navigation {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 1rem 0;
  padding: 0.75rem;
  background: white;
  border-radius: 8px;
}

.nav-btn {
  background: #6366f1;
  color: white;
  border: none;
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
}

.nav-btn:hover:not(:disabled) {
  background: #4f46e5;
}

.nav-btn:disabled {
  background: #d1d5db;
  cursor: not-allowed;
}

.word-counter {
  font-weight: 600;
  color: #374151;
}

.practice-tips {
  margin-top: 1rem;
}

.practice-tips .tip {
  background: white;
  padding: 0.75rem;
  border-radius: 8px;
  margin-bottom: 0.5rem;
  border-left: 3px solid #7c3aed;
  color: #374151;
}
</style>
