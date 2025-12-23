<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRoomStore } from '../stores/room'
import { quizCategories } from '../data/quizQuestions'

const roomStore = useRoomStore()

const selectedAnswer = ref<number | null>(null)
const writtenAnswer = ref('')
const hasAnswered = ref(false)
const isReady = ref(false)
const countdown = ref<number | null>(null)
const isTransitioning = ref(false)

// Options pour nouveau quiz
const newQuizCategory = ref<'all' | 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics'>('all')
const newQuizCount = ref(10)

const round = computed(() => roomStore.currentRound)

const isWriteQuestion = computed(() => {
  return round.value?.type === 'write'
})

const isListenQuestion = computed(() => {
  return round.value?.type === 'listen'
})

const isWriteCorrect = computed(() => {
  const r = round.value as { correctAnswer?: string } | null
  if (!r?.correctAnswer || !writtenAnswer.value) return false
  return writtenAnswer.value.toLowerCase().trim() === r.correctAnswer.toLowerCase().trim()
})

// Audio pour les questions phonétiques
const isPlaying = ref(false)
const playAudio = () => {
  const r = round.value as { audioText?: string } | null
  if (!r?.audioText || isPlaying.value) return
  
  isPlaying.value = true
  const utterance = new SpeechSynthesisUtterance(r.audioText)
  
  // Déterminer la langue
  const lang = roomStore.room?.language === 'it' ? 'it-IT' : 'es-ES'
  utterance.lang = lang
  utterance.rate = 0.8 // Légèrement plus lent pour l'apprentissage
  
  utterance.onend = () => {
    isPlaying.value = false
  }
  utterance.onerror = () => {
    isPlaying.value = false
  }
  
  speechSynthesis.speak(utterance)
}

const showResult = computed(() => {
  return round.value?.result !== undefined
})

const correctIndex = computed(() => {
  return round.value?.result?.correctIndex ?? null
})

const isQuizFinished = computed(() => {
  return roomStore.session?.state === 'finished'
})

const totalRounds = computed(() => {
  if (!roomStore.session?.rounds) return 0
  return Object.keys(roomStore.session.rounds).length
})

const currentRoundNumber = computed(() => {
  return (roomStore.session?.roundIndex ?? 0) + 1
})

const handleAnswer = async (index: number) => {
  if (hasAnswered.value || !round.value) return
  
  selectedAnswer.value = index
  hasAnswered.value = true
  
  try {
    await roomStore.sendAnswer(round.value.id, index)
  } catch (e) {
    console.error('Erreur envoi réponse:', e)
    hasAnswered.value = false
    selectedAnswer.value = null
  }
}

const handleWriteAnswer = async () => {
  if (hasAnswered.value || !round.value || !writtenAnswer.value.trim()) return
  
  hasAnswered.value = true
  
  // Pour les questions écrites, on envoie 1 si correct, 0 sinon
  const isCorrect = writtenAnswer.value.toLowerCase().trim() === (round.value as { correctAnswer?: string }).correctAnswer?.toLowerCase().trim()
  const answerValue = isCorrect ? 1 : 0
  
  try {
    await roomStore.sendAnswer(round.value.id, answerValue)
  } catch (e) {
    console.error('Erreur envoi réponse:', e)
    hasAnswered.value = false
  }
}

// Bouton Prêt - envoie à Firebase et vérifie si tous sont prêts
const handleReady = async () => {
  isReady.value = true
  const allReady = await roomStore.setPlayerReady()
  
  // Si tous les joueurs sont prêts, démarrer le compte à rebours
  if (allReady) {
    startCountdown()
  }
}

// Démarrer le compte à rebours
const startCountdown = () => {
  if (isTransitioning.value) return
  isTransitioning.value = true
  countdown.value = 3
  
  const interval = setInterval(() => {
    if (countdown.value !== null && countdown.value > 1) {
      countdown.value--
    } else {
      clearInterval(interval)
      countdown.value = null
      roomStore.nextRound()
      isTransitioning.value = false
    }
  }, 1000)
}

// Surveiller si tous les joueurs sont prêts (via session.readyPlayers)
const allPlayersReady = computed(() => {
  const session = roomStore.session as { readyPlayers?: Record<string, boolean> } | null
  if (!session?.readyPlayers) return false
  const readyCount = Object.keys(session.readyPlayers).length
  const playerCount = Object.keys(roomStore.players).length
  return readyCount >= playerCount
})

// Quand tous sont prêts, démarrer le compte à rebours
watch(allPlayersReady, (ready) => {
  if (ready && showResult.value && !isTransitioning.value) {
    startCountdown()
  }
})

// Reset quand on change de round
watch(() => round.value?.id, () => {
  selectedAnswer.value = null
  writtenAnswer.value = ''
  hasAnswered.value = false
  isReady.value = false
  countdown.value = null
})

// Démarrer un nouveau quiz (host only)
const handleNewQuiz = async () => {
  if (!roomStore.isHost) return
  await roomStore.startSession(newQuizCategory.value, newQuizCount.value)
}
</script>

<template>
  <div class="quiz-panel card">
    <!-- Quiz terminé -->
    <div v-if="isQuizFinished" class="quiz-finished">
      <h2>🎉 Quiz terminé !</h2>
      <p>Bravo, vous avez répondu à toutes les questions.</p>
      
      <!-- Options pour nouveau quiz (host only) -->
      <div v-if="roomStore.isHost" class="new-quiz-options">
        <h3>🔄 Nouveau Quiz</h3>
        
        <div class="option-group">
          <label>Catégorie</label>
          <div class="category-buttons">
            <button
              v-for="cat in quizCategories"
              :key="cat.id"
              :class="['cat-btn', { active: newQuizCategory === cat.id }]"
              @click="newQuizCategory = cat.id as typeof newQuizCategory"
            >
              <span>{{ cat.icon }}</span>
              <span>{{ cat.label }}</span>
            </button>
          </div>
        </div>
        
        <div class="option-group">
          <label>Nombre de questions</label>
          <div class="count-buttons">
            <button 
              v-for="n in [5, 10, 15, 20]" 
              :key="n"
              :class="['count-btn', { active: newQuizCount === n }]"
              @click="newQuizCount = n"
            >
              {{ n }}
            </button>
          </div>
        </div>
        
        <button 
          class="btn btn-success new-quiz-btn"
          @click="handleNewQuiz"
          :disabled="roomStore.loading"
        >
          {{ roomStore.loading ? 'Démarrage...' : '🚀 Lancer le Quiz' }}
        </button>
      </div>
      
      <!-- Message pour joueur 2 -->
      <div v-else class="waiting-host">
        <p>⏳ En attente que l'hôte lance un nouveau quiz...</p>
      </div>
    </div>

    <!-- Question en cours -->
    <div v-else-if="round" class="quiz-content">
      <div class="quiz-header">
        <span class="round-badge">Question {{ currentRoundNumber }} / {{ totalRounds }}</span>
      </div>

      <h2 class="quiz-prompt">{{ round.prompt }}</h2>

      <!-- Bouton audio pour questions d'écoute -->
      <div v-if="isListenQuestion" class="audio-section">
        <button 
          class="audio-btn"
          @click="playAudio"
          :disabled="isPlaying"
        >
          <span v-if="isPlaying">🔊 Lecture...</span>
          <span v-else>🔈 Écouter la phrase</span>
        </button>
        <p class="audio-hint">Cliquez pour écouter, puis choisissez la bonne transcription</p>
      </div>

      <!-- Questions à choix multiples (et listen) -->
      <div v-if="!isWriteQuestion" class="quiz-choices">
        <button
          v-for="(choice, index) in round.choices"
          :key="index"
          @click="handleAnswer(index)"
          :disabled="hasAnswered"
          :class="[
            'choice-btn',
            {
              selected: selectedAnswer === index,
              correct: showResult && correctIndex === index,
              wrong: showResult && selectedAnswer === index && correctIndex !== index
            }
          ]"
        >
          <span class="choice-letter">{{ ['A', 'B', 'C', 'D'][index] }}</span>
          <span class="choice-text">{{ choice }}</span>
        </button>
      </div>

      <!-- Questions à réponse écrite -->
      <div v-else class="write-answer">
        <input
          v-model="writtenAnswer"
          type="text"
          class="write-input"
          placeholder="Tapez votre réponse..."
          :disabled="hasAnswered"
          @keydown.enter="handleWriteAnswer"
        />
        <button
          class="btn btn-primary submit-btn"
          @click="handleWriteAnswer"
          :disabled="hasAnswered || !writtenAnswer.trim()"
        >
          Valider
        </button>
        
        <!-- Afficher la bonne réponse après -->
        <div v-if="showResult" class="correct-answer-display">
          <span v-if="isWriteCorrect">✅ Correct !</span>
          <span v-else>❌ La réponse était : <strong>{{ (round as any).correctAnswer }}</strong></span>
        </div>
        
        <!-- Explication pour questions écrites -->
        <p v-if="showResult && round.explanation" class="explanation">
          💡 {{ round.explanation }}
        </p>
        
        <!-- Compte à rebours pour questions écrites -->
        <div v-if="showResult && countdown !== null" class="countdown">
          <span class="countdown-number">{{ countdown }}</span>
        </div>
        
        <!-- Bouton Prêt pour questions écrites -->
        <div v-if="showResult && countdown === null" class="ready-section">
          <button 
            v-if="!isReady"
            class="btn btn-ready"
            @click="handleReady"
          >
            ✓ Prêt pour la suite
          </button>
          <p v-else class="waiting-ready">
            ⏳ En attente de l'autre joueur...
          </p>
        </div>
      </div>

      <!-- Feedback après réponse -->
      <div v-if="hasAnswered && !showResult" class="waiting-result">
        ⏳ En attente de l'autre joueur...
      </div>

      <div v-if="showResult && !isWriteQuestion" class="quiz-result">
        <div v-if="selectedAnswer === correctIndex" class="result-correct">
          ✅ Bonne réponse !
        </div>
        <div v-else class="result-wrong">
          ❌ Mauvaise réponse
        </div>
        <p v-if="round.explanation" class="explanation">
          💡 {{ round.explanation }}
        </p>
        
        <!-- Compte à rebours -->
        <div v-if="countdown !== null" class="countdown">
          <span class="countdown-number">{{ countdown }}</span>
        </div>
        
        <!-- Bouton Prêt -->
        <div v-else class="ready-section">
          <button 
            v-if="!isReady"
            class="btn btn-ready"
            @click="handleReady"
          >
            ✓ Prêt pour la suite
          </button>
          <p v-else class="waiting-ready">
            ⏳ En attente de l'autre joueur...
          </p>
        </div>
      </div>
    </div>

    <div v-else class="no-round">
      <p>Chargement du quiz...</p>
    </div>
  </div>
</template>

<style scoped>
.quiz-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.quiz-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.quiz-header {
  display: flex;
  justify-content: center;
}

.round-badge {
  background: #3498db;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 500;
}

.quiz-prompt {
  text-align: center;
  font-size: 1.3rem;
  color: #2c3e50;
  margin: 0;
}

.quiz-choices {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.choice-btn {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border: 2px solid #ddd;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  text-align: left;
  transition: all 0.2s;
}

.choice-btn:hover:not(:disabled) {
  border-color: #3498db;
  background: #f8f9fa;
}

.choice-btn:disabled {
  cursor: default;
}

.choice-btn.selected {
  border-color: #3498db;
  background: #e8f4fc;
}

.choice-btn.correct {
  border-color: #27ae60;
  background: #e8f8f0;
}

.choice-btn.wrong {
  border-color: #e74c3c;
  background: #fdf2f2;
}

.choice-letter {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #ecf0f1;
  border-radius: 50%;
  font-weight: 600;
  color: #2c3e50;
}

.choice-btn.correct .choice-letter {
  background: #27ae60;
  color: white;
}

.choice-btn.wrong .choice-letter {
  background: #e74c3c;
  color: white;
}

.choice-text {
  flex: 1;
}

.waiting-result {
  text-align: center;
  color: #7f8c8d;
  font-style: italic;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.quiz-result {
  text-align: center;
  padding: 1rem;
  border-radius: 8px;
}

.result-correct {
  font-size: 1.2rem;
  color: #27ae60;
  font-weight: 600;
}

.result-wrong {
  font-size: 1.2rem;
  color: #e74c3c;
  font-weight: 600;
}

.explanation {
  margin-top: 1rem;
  padding: 1rem;
  background: #fef9e7;
  border-radius: 8px;
  color: #7f6003;
}

.no-round {
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 1;
  color: #7f8c8d;
}

.quiz-finished {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
  text-align: center;
  padding: 2rem;
}

.quiz-finished h2 {
  font-size: 1.5rem;
  color: #27ae60;
  margin: 0 0 1rem;
}

.quiz-finished p {
  color: #7f8c8d;
  margin: 0;
}

.ready-section {
  margin-top: 1.5rem;
}

.btn-ready {
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
}

.btn-ready:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(39, 174, 96, 0.4);
}

.btn-ready:active {
  transform: translateY(0);
}

.waiting-ready {
  color: #7f8c8d;
  font-style: italic;
  margin: 0;
}

.countdown {
  margin-top: 1.5rem;
  display: flex;
  justify-content: center;
}

.countdown-number {
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
  color: white;
  font-size: 2.5rem;
  font-weight: 700;
  border-radius: 50%;
  animation: pulse 1s ease-in-out infinite;
  box-shadow: 0 4px 20px rgba(52, 152, 219, 0.4);
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

/* Write answer styles */
.write-answer {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  align-items: center;
}

.write-input {
  width: 100%;
  max-width: 400px;
  padding: 1rem 1.25rem;
  font-size: 1.1rem;
  border: 2px solid #ddd;
  border-radius: 12px;
  text-align: center;
  transition: all 0.2s;
}

.write-input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2);
}

.write-input:disabled {
  background: #f8f9fa;
  color: #7f8c8d;
}

.submit-btn {
  padding: 0.75rem 2rem;
  font-size: 1rem;
}

.correct-answer-display {
  margin-top: 0.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
  font-size: 1.1rem;
}

.correct-answer-display strong {
  color: #27ae60;
}

/* New quiz options */
.new-quiz-options {
  margin-top: 2rem;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 12px;
  text-align: left;
}

.new-quiz-options h3 {
  margin: 0 0 1rem;
  color: #2c3e50;
  font-size: 1.1rem;
  text-align: center;
}

.new-quiz-options .option-group {
  margin-bottom: 1rem;
}

.new-quiz-options label {
  display: block;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}

.category-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  justify-content: center;
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

.count-buttons {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
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

.new-quiz-btn {
  width: 100%;
  padding: 1rem;
  font-size: 1.1rem;
  margin-top: 1rem;
}

.waiting-host {
  margin-top: 1.5rem;
  padding: 1rem;
  background: #fef9e7;
  border-radius: 8px;
}

.waiting-host p {
  margin: 0;
  color: #7f6003;
  font-style: italic;
}

/* Audio section styles */
.audio-section {
  margin-bottom: 1.5rem;
  text-align: center;
}

.audio-btn {
  background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 50px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(155, 89, 182, 0.3);
}

.audio-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(155, 89, 182, 0.4);
}

.audio-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  animation: pulse-audio 1s ease-in-out infinite;
}

@keyframes pulse-audio {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.audio-hint {
  margin-top: 0.75rem;
  color: #7f8c8d;
  font-size: 0.9rem;
  font-style: italic;
}
</style>
