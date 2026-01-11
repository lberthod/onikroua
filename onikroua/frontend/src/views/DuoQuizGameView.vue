<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { quizQuestions, quizCategories, type QuizQuestion } from '../data/quizQuestions'

interface Player {
  id: number
  name: string
  score: number
  streak: number
  selectedAnswer: number | null
  hasAnswered: boolean
  gamepadIndex: number | null
  color: string
}

const players = ref<Player[]>([
  { id: 1, name: 'Joueur 1', score: 0, streak: 0, selectedAnswer: null, hasAnswered: false, gamepadIndex: null, color: '#3498db' },
  { id: 2, name: 'Joueur 2', score: 0, streak: 0, selectedAnswer: null, hasAnswered: false, gamepadIndex: null, color: '#e74c3c' }
])

const gameState = ref<'setup' | 'playing' | 'result' | 'finished'>('setup')
const currentQuestionIndex = ref(0)
const selectedQuestions = ref<QuizQuestion[]>([])
const showCorrectAnswer = ref(false)
const countdown = ref<number | null>(null)
const selectedCategory = ref<'all' | 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics'>('all')
const questionCount = ref(10)

const gamepadPollingInterval = ref<number | null>(null)
const buttonStates = ref<Map<number, boolean[]>>(new Map())
const isPlayingAudio = ref(false)

const buttonMapping: Record<number, number> = {
  0: 1,
  1: 0,
  2: 3,
  3: 2
}

const currentQuestion = computed(() => selectedQuestions.value[currentQuestionIndex.value])
const totalQuestions = computed(() => selectedQuestions.value.length)
const progress = computed(() => ((currentQuestionIndex.value + 1) / totalQuestions.value) * 100)

const winner = computed(() => {
  if (players.value[0].score > players.value[1].score) return players.value[0]
  if (players.value[1].score > players.value[0].score) return players.value[1]
  return null
})

const detectGamepads = () => {
  const gamepads = navigator.getGamepads()
  
  for (let i = 0; i < gamepads.length; i++) {
    const gamepad = gamepads[i]
    if (gamepad) {
      players.value.forEach(player => {
        if (player.gamepadIndex === null && !players.value.some(p => p.gamepadIndex === i)) {
          player.gamepadIndex = i
        }
      })
    }
  }
}

const pollGamepads = () => {
  const gamepads = navigator.getGamepads()
  
  players.value.forEach((player, playerIndex) => {
    if (player.gamepadIndex === null) return
    
    const gamepad = gamepads[player.gamepadIndex]
    if (!gamepad) return
    
    if (!buttonStates.value.has(player.gamepadIndex)) {
      buttonStates.value.set(player.gamepadIndex, new Array(gamepad.buttons.length).fill(false))
    }
    
    const previousStates = buttonStates.value.get(player.gamepadIndex)!
    
    for (let i = 0; i < Math.min(4, gamepad.buttons.length); i++) {
      const isPressed = gamepad.buttons[i].pressed
      const wasPressed = previousStates[i]
      
      if (isPressed && !wasPressed) {
        handleGamepadInput(playerIndex, i)
      }
      
      previousStates[i] = isPressed
    }
  })
}

const handleGamepadInput = (playerIndex: number, rawButtonIndex: number) => {
  const player = players.value[playerIndex]
  const buttonIndex = buttonMapping[rawButtonIndex] ?? rawButtonIndex
  
  if (gameState.value === 'setup') {
    if (buttonIndex === 0) {
      startGame()
    }
  } else if (gameState.value === 'playing' && !player.hasAnswered && currentQuestion.value) {
    if (buttonIndex < (currentQuestion.value.choices?.length || 0)) {
      handleAnswer(playerIndex, buttonIndex)
    }
  } else if (gameState.value === 'result') {
    if (buttonIndex === 0) {
      nextQuestion()
    }
  }
}

const startGame = () => {
  let questions = quizQuestions.filter(q => selectedCategory.value === 'all' || q.category === selectedCategory.value)
  
  questions = questions.filter(q => q.type === 'choice' && q.choices && q.choices.length >= 2)
  
  const shuffled = [...questions].sort(() => Math.random() - 0.5)
  selectedQuestions.value = shuffled.slice(0, questionCount.value)
  
  players.value.forEach(p => {
    p.score = 0
    p.streak = 0
    p.selectedAnswer = null
    p.hasAnswered = false
  })
  
  currentQuestionIndex.value = 0
  gameState.value = 'playing'
  showCorrectAnswer.value = false
  
  setTimeout(() => {
    playQuestionAudio()
  }, 500)
}

const handleAnswer = (playerIndex: number, answerIndex: number) => {
  const player = players.value[playerIndex]
  if (player.hasAnswered || !currentQuestion.value) return
  
  player.selectedAnswer = answerIndex
  player.hasAnswered = true
  
  const isCorrect = answerIndex === currentQuestion.value.correctIndex
  
  if (isCorrect) {
    const basePoints = 10
    const streakBonus = player.streak * 5
    player.score += basePoints + streakBonus
    player.streak++
  } else {
    player.streak = 0
  }
  
  checkBothAnswered()
}

const checkBothAnswered = () => {
  if (players.value.every(p => p.hasAnswered)) {
    showCorrectAnswer.value = true
    gameState.value = 'result'
    startCountdown()
  }
}

const startCountdown = () => {
  countdown.value = 3
  
  const interval = setInterval(() => {
    if (countdown.value !== null && countdown.value > 1) {
      countdown.value--
    } else {
      clearInterval(interval)
      countdown.value = null
      nextQuestion()
    }
  }, 1000)
}

const nextQuestion = () => {
  if (countdown.value !== null) return
  
  if (currentQuestionIndex.value < selectedQuestions.value.length - 1) {
    currentQuestionIndex.value++
    players.value.forEach(p => {
      p.selectedAnswer = null
      p.hasAnswered = false
    })
    showCorrectAnswer.value = false
    gameState.value = 'playing'
    
    setTimeout(() => {
      playQuestionAudio()
    }, 500)
  } else {
    gameState.value = 'finished'
  }
}

const resetGame = () => {
  gameState.value = 'setup'
  currentQuestionIndex.value = 0
  selectedQuestions.value = []
  players.value.forEach(p => {
    p.score = 0
    p.streak = 0
    p.selectedAnswer = null
    p.hasAnswered = false
  })
}

const getButtonLabel = (index: number): string => {
  const labels = ['A', 'B', 'X', 'Y']
  return labels[index] || String.fromCharCode(65 + index)
}

const getButtonColor = (index: number): string => {
  const colors = ['#28a745', '#dc3545', '#6f42c1', '#007bff']
  return colors[index] || '#6c757d'
}

const playQuestionAudio = () => {
  if (!currentQuestion.value || isPlayingAudio.value) return
  
  speechSynthesis.cancel()
  
  const question = currentQuestion.value
  const textToSpeak = question.prompt
  
  isPlayingAudio.value = true
  const utterance = new SpeechSynthesisUtterance(textToSpeak)
  
  const lang = question.language === 'it' ? 'it-IT' : 'es-ES'
  utterance.lang = lang
  utterance.rate = 0.85
  utterance.pitch = 1.0
  
  utterance.onend = () => {
    isPlayingAudio.value = false
  }
  utterance.onerror = () => {
    isPlayingAudio.value = false
  }
  
  speechSynthesis.speak(utterance)
}

onMounted(() => {
  window.addEventListener('gamepadconnected', detectGamepads)
  window.addEventListener('gamepaddisconnected', detectGamepads)
  
  detectGamepads()
  
  gamepadPollingInterval.value = window.setInterval(pollGamepads, 50)
})

onUnmounted(() => {
  window.removeEventListener('gamepadconnected', detectGamepads)
  window.removeEventListener('gamepaddisconnected', detectGamepads)
  
  if (gamepadPollingInterval.value) {
    clearInterval(gamepadPollingInterval.value)
  }
  
  speechSynthesis.cancel()
})
</script>

<template>
  <div class="duo-quiz-game">
    <div class="game-header">
      <h1>🎮 Quiz Duo - Mode Manette</h1>
      <div v-if="gameState !== 'setup'" class="progress-bar">
        <div class="progress-fill" :style="{ width: `${progress}%` }"></div>
        <span class="progress-text">{{ currentQuestionIndex + 1 }} / {{ totalQuestions }}</span>
      </div>
    </div>

    <div class="setup-screen" v-if="gameState === 'setup'">
      <div class="setup-card">
        <h2>⚙️ Configuration du Jeu</h2>
        
        <div class="players-status">
          <div 
            v-for="player in players" 
            :key="player.id"
            class="player-status"
            :style="{ borderColor: player.color }"
          >
            <div class="player-icon" :style="{ backgroundColor: player.color }">
              {{ player.id }}
            </div>
            <div class="player-info">
              <h3>{{ player.name }}</h3>
              <div class="gamepad-status">
                <span v-if="player.gamepadIndex !== null" class="connected">
                  ✓ Manette {{ player.gamepadIndex + 1 }} connectée
                </span>
                <span v-else class="disconnected">
                  ⏳ En attente de manette...
                </span>
              </div>
            </div>
          </div>
        </div>

        <div class="game-options">
          <div class="option-group">
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
          
          <div class="option-group">
            <label>Nombre de questions</label>
            <div class="count-buttons">
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

        <div class="controls-help">
          <h3>🎮 Contrôles</h3>
          <div class="controls-grid">
            <div class="control-item">
              <span class="btn-icon">A</span>
              <span>Réponse A / Démarrer</span>
            </div>
            <div class="control-item">
              <span class="btn-icon">B</span>
              <span>Réponse B</span>
            </div>
            <div class="control-item">
              <span class="btn-icon">X</span>
              <span>Réponse C</span>
            </div>
            <div class="control-item">
              <span class="btn-icon">Y</span>
              <span>Réponse D</span>
            </div>
          </div>
        </div>

        <button 
          class="start-button"
          @click="startGame"
          :disabled="players.some(p => p.gamepadIndex === null)"
        >
          🚀 Lancer le Quiz
          <span v-if="players.some(p => p.gamepadIndex === null)" class="hint">
            (Connectez les manettes)
          </span>
        </button>
      </div>
    </div>

    <div class="game-screen" v-else-if="gameState === 'playing' || gameState === 'result'">
      <div class="question-section">
        <div class="question-card">
          <div class="question-header">
            <span class="category-badge" :style="{ backgroundColor: getCategoryColor(currentQuestion?.category) }">
              {{ getCategoryIcon(currentQuestion?.category) }} {{ getCategoryLabel(currentQuestion?.category) }}
            </span>
            <span class="difficulty-badge" :class="currentQuestion?.difficulty">
              {{ currentQuestion?.difficulty }}
            </span>
          </div>
          
          <h2 class="question-text">{{ currentQuestion?.prompt }}</h2>
          
          <div class="choices-controller">
            <div 
              v-for="(choice, index) in currentQuestion?.choices?.slice(0, 4)"
              :key="index"
              :class="[
                'controller-button',
                `button-${index}`,
                {
                  'player1-selected': players[0].selectedAnswer === index,
                  'player2-selected': players[1].selectedAnswer === index,
                  'correct': showCorrectAnswer && currentQuestion?.correctIndex === index,
                  'wrong': showCorrectAnswer && currentQuestion?.correctIndex !== index && (players[0].selectedAnswer === index || players[1].selectedAnswer === index)
                }
              ]"
            >
              <div class="button-face" :style="{ backgroundColor: getButtonColor(index) }">
                <span class="button-label">{{ getButtonLabel(index) }}</span>
              </div>
              <div class="button-content">
                <div class="player-indicators-inline">
                  <span 
                    v-if="players[0].selectedAnswer === index" 
                    class="indicator-small p1"
                    :style="{ backgroundColor: players[0].color }"
                  >1</span>
                  <span 
                    v-if="players[1].selectedAnswer === index" 
                    class="indicator-small p2"
                    :style="{ backgroundColor: players[1].color }"
                  >2</span>
                </div>
                <div class="choice-text">{{ choice }}</div>
              </div>
            </div>
          </div>

          <div v-if="showCorrectAnswer && currentQuestion?.explanation" class="explanation">
            💡 {{ currentQuestion.explanation }}
          </div>

          <div v-if="countdown !== null" class="countdown">
            <span class="countdown-number">{{ countdown }}</span>
          </div>
        </div>
      </div>

      <div class="scoreboard">
        <div 
          v-for="player in players" 
          :key="player.id"
          class="player-score-card"
          :style="{ borderColor: player.color }"
        >
          <div class="player-avatar" :style="{ backgroundColor: player.color }">
            {{ player.id }}
          </div>
          <div class="player-details">
            <h3>{{ player.name }}</h3>
            <div class="score">{{ player.score }} pts</div>
            <div v-if="player.streak > 0" class="streak">
              🔥 {{ player.streak }} combo
            </div>
            <div v-if="!player.hasAnswered && gameState === 'playing'" class="waiting">
              En attente...
            </div>
            <div v-else-if="player.hasAnswered" class="answered">
              ✓ Répondu
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="finished-screen" v-else-if="gameState === 'finished'">
      <div class="results-card">
        <h2>🎉 Quiz Terminé !</h2>
        
        <div class="final-scores">
          <div 
            v-for="(player, index) in [...players].sort((a, b) => b.score - a.score)" 
            :key="player.id"
            :class="['final-player', { winner: index === 0 && winner }]"
            :style="{ borderColor: player.color }"
          >
            <div class="rank">{{ index === 0 ? '🏆' : '🥈' }}</div>
            <div class="player-avatar-large" :style="{ backgroundColor: player.color }">
              {{ player.id }}
            </div>
            <div class="player-final-info">
              <h3>{{ player.name }}</h3>
              <div class="final-score">{{ player.score }} points</div>
            </div>
          </div>
        </div>

        <div v-if="winner" class="winner-announcement">
          <h3>🎊 Victoire de {{ winner.name }} ! 🎊</h3>
        </div>
        <div v-else class="draw-announcement">
          <h3>🤝 Égalité parfaite ! 🤝</h3>
        </div>

        <button class="restart-button" @click="resetGame">
          🔄 Nouvelle Partie
        </button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
export default {
  methods: {
    getCategoryColor(category?: string): string {
      const colors: Record<string, string> = {
        vocabulary: '#3498db',
        grammar: '#9b59b6',
        conjugation: '#e67e22',
        phonetics: '#1abc9c'
      }
      return colors[category || ''] || '#95a5a6'
    },
    getCategoryIcon(category?: string): string {
      const icons: Record<string, string> = {
        vocabulary: '📖',
        grammar: '📝',
        conjugation: '✍️',
        phonetics: '🎵'
      }
      return icons[category || ''] || '📚'
    },
    getCategoryLabel(category?: string): string {
      const labels: Record<string, string> = {
        vocabulary: 'Vocabulaire',
        grammar: 'Grammaire',
        conjugation: 'Conjugaison',
        phonetics: 'Phonétique'
      }
      return labels[category || ''] || 'Quiz'
    }
  }
}
</script>

<style scoped>
.duo-quiz-game {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem;
}

.game-header {
  text-align: center;
  margin-bottom: 2rem;
}

.game-header h1 {
  color: white;
  font-size: 2.5rem;
  margin: 0 0 1rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.progress-bar {
  max-width: 600px;
  margin: 0 auto;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  position: relative;
  overflow: hidden;
  backdrop-filter: blur(10px);
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #27ae60, #2ecc71);
  transition: width 0.5s ease;
  border-radius: 20px;
}

.progress-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-weight: 600;
  font-size: 1rem;
}

.setup-screen {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 70vh;
}

.setup-card {
  background: white;
  padding: 2.5rem;
  border-radius: 20px;
  max-width: 700px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.setup-card h2 {
  text-align: center;
  margin: 0 0 2rem;
  color: #2c3e50;
  font-size: 1.8rem;
}

.players-status {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-bottom: 2rem;
}

.player-status {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border: 3px solid;
  border-radius: 12px;
  background: #f8f9fa;
}

.player-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 1.5rem;
}

.player-info h3 {
  margin: 0 0 0.5rem;
  color: #2c3e50;
}

.gamepad-status {
  font-size: 0.9rem;
}

.connected {
  color: #27ae60;
  font-weight: 600;
}

.disconnected {
  color: #e67e22;
  font-style: italic;
}

.game-options {
  margin-bottom: 2rem;
}

.option-group {
  margin-bottom: 1.5rem;
}

.option-group label {
  display: block;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 0.75rem;
  font-size: 1rem;
}

.category-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  justify-content: center;
}

.cat-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 25px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
  font-weight: 600;
}

.cat-btn:hover {
  border-color: #667eea;
  transform: translateY(-2px);
}

.cat-btn.active {
  border-color: #667eea;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.count-buttons {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
}

.count-btn {
  padding: 0.75rem 1.5rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 12px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 700;
  transition: all 0.2s;
}

.count-btn:hover {
  border-color: #3498db;
  transform: translateY(-2px);
}

.count-btn.active {
  border-color: #3498db;
  background: #3498db;
  color: white;
}

.controls-help {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
  margin-bottom: 1.5rem;
}

.controls-help h3 {
  margin: 0 0 1rem;
  color: #2c3e50;
  text-align: center;
}

.controls-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
}

.control-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.9rem;
  color: #555;
}

.btn-icon {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.9rem;
}

.start-button {
  width: 100%;
  padding: 1.25rem;
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1.3rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
}

.start-button:hover:not(:disabled) {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(39, 174, 96, 0.4);
}

.start-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.start-button .hint {
  display: block;
  font-size: 0.9rem;
  margin-top: 0.5rem;
  opacity: 0.9;
}

.game-screen {
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

.question-section {
  flex: 1;
}

.question-card {
  background: white;
  padding: 2rem;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.category-badge {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  color: white;
  font-weight: 600;
  font-size: 0.9rem;
}

.difficulty-badge {
  padding: 0.4rem 0.8rem;
  border-radius: 15px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
}

.difficulty-badge.beginner {
  background: #d4edda;
  color: #155724;
}

.difficulty-badge.intermediate {
  background: #fff3cd;
  color: #856404;
}

.difficulty-badge.advanced {
  background: #f8d7da;
  color: #721c24;
}

.question-text {
  font-size: 1.5rem;
  color: #2c3e50;
  margin: 0 0 2rem;
  text-align: center;
}

.choices-controller {
  position: relative;
  width: 100%;
  max-width: 500px;
  margin: 0 auto 2rem;
  padding: 3rem;
  min-height: 400px;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-template-rows: repeat(3, 1fr);
  gap: 1rem;
}

.controller-button {
  background: white;
  border: 3px solid #e0e0e0;
  border-radius: 16px;
  padding: 1rem;
  transition: all 0.3s;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.controller-button:hover {
  transform: translateY(-3px) scale(1.02);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.button-0 {
  grid-column: 2;
  grid-row: 3;
}

.button-1 {
  grid-column: 3;
  grid-row: 2;
}

.button-2 {
  grid-column: 1;
  grid-row: 2;
}

.button-3 {
  grid-column: 2;
  grid-row: 1;
}

.controller-button.player1-selected {
  border-color: #3498db;
  background: linear-gradient(135deg, #e8f4fc 0%, #d4e9f7 100%);
  transform: translateY(-3px) scale(1.05);
}

.controller-button.player2-selected {
  border-color: #e74c3c;
  background: linear-gradient(135deg, #fdf2f2 0%, #fce4e4 100%);
  transform: translateY(-3px) scale(1.05);
}

.controller-button.correct {
  border-color: #27ae60;
  background: linear-gradient(135deg, #e8f8f0 0%, #d1f2e1 100%);
  animation: correctPulse 0.6s ease-out;
}

.controller-button.wrong {
  border-color: #e74c3c;
  background: linear-gradient(135deg, #fdf2f2 0%, #fce4e4 100%);
  opacity: 0.7;
  animation: wrongShake 0.5s ease-out;
}

@keyframes correctPulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.1); }
  100% { transform: scale(1); }
}

@keyframes wrongShake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-10px); }
  75% { transform: translateX(10px); }
}

.button-face {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2), inset 0 -2px 5px rgba(0, 0, 0, 0.2);
  transition: all 0.2s;
}

.controller-button:active .button-face {
  transform: translateY(2px);
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2), inset 0 1px 3px rgba(0, 0, 0, 0.3);
}

.button-label {
  color: white;
  font-weight: 800;
  font-size: 1.5rem;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.button-content {
  text-align: center;
  width: 100%;
}

.player-indicators-inline {
  display: flex;
  gap: 0.4rem;
  justify-content: center;
  margin-bottom: 0.5rem;
  min-height: 24px;
}

.indicator-small {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 0.75rem;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
}

.choice-text {
  font-size: 0.95rem;
  color: #2c3e50;
  font-weight: 600;
  line-height: 1.3;
}

.explanation {
  padding: 1.25rem;
  background: #fef9e7;
  border-radius: 12px;
  color: #7f6003;
  margin-bottom: 1.5rem;
  border-left: 4px solid #f39c12;
}

.countdown {
  display: flex;
  justify-content: center;
  margin-top: 1.5rem;
}

.countdown-number {
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 2.5rem;
  font-weight: 700;
  border-radius: 50%;
  animation: pulse 1s ease-in-out infinite;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.5);
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

.scoreboard {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.player-score-card {
  background: white;
  padding: 1.5rem;
  border-radius: 16px;
  border: 3px solid;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  display: flex;
  align-items: center;
  gap: 1rem;
}

.player-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 1.8rem;
}

.player-details h3 {
  margin: 0 0 0.5rem;
  color: #2c3e50;
  font-size: 1.2rem;
}

.score {
  font-size: 1.5rem;
  font-weight: 700;
  color: #27ae60;
  margin-bottom: 0.25rem;
}

.streak {
  font-size: 0.9rem;
  color: #e67e22;
  font-weight: 600;
}

.waiting {
  font-size: 0.85rem;
  color: #95a5a6;
  font-style: italic;
}

.answered {
  font-size: 0.9rem;
  color: #27ae60;
  font-weight: 600;
}

.finished-screen {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 70vh;
}

.results-card {
  background: white;
  padding: 3rem;
  border-radius: 20px;
  max-width: 600px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  text-align: center;
}

.results-card h2 {
  font-size: 2.5rem;
  margin: 0 0 2rem;
  color: #2c3e50;
}

.final-scores {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.final-player {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1.5rem;
  border: 3px solid;
  border-radius: 16px;
  background: #f8f9fa;
  transition: all 0.3s;
}

.final-player.winner {
  background: linear-gradient(135deg, #fff9e6 0%, #ffe6cc 100%);
  transform: scale(1.05);
}

.rank {
  font-size: 2.5rem;
}

.player-avatar-large {
  width: 70px;
  height: 70px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 2rem;
}

.player-final-info {
  flex: 1;
  text-align: left;
}

.player-final-info h3 {
  margin: 0 0 0.5rem;
  color: #2c3e50;
  font-size: 1.5rem;
}

.final-score {
  font-size: 1.8rem;
  font-weight: 700;
  color: #27ae60;
}

.winner-announcement {
  padding: 1.5rem;
  background: linear-gradient(135deg, #f8e896 0%, #f5d76e 100%);
  border-radius: 12px;
  margin-bottom: 2rem;
}

.winner-announcement h3 {
  margin: 0;
  color: #856404;
  font-size: 1.5rem;
}

.draw-announcement {
  padding: 1.5rem;
  background: #e8f4fc;
  border-radius: 12px;
  margin-bottom: 2rem;
}

.draw-announcement h3 {
  margin: 0;
  color: #3498db;
  font-size: 1.5rem;
}

.restart-button {
  width: 100%;
  padding: 1.25rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1.3rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.restart-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

@media (max-width: 1024px) {
  .game-screen {
    grid-template-columns: 1fr;
  }
  
  .scoreboard {
    flex-direction: row;
  }
}

@media (max-width: 768px) {
  .choices-controller {
    max-width: 350px;
    padding: 2rem;
    min-height: 350px;
    gap: 0.75rem;
  }
  
  .button-face {
    width: 50px;
    height: 50px;
  }
  
  .button-label {
    font-size: 1.2rem;
  }
  
  .choice-text {
    font-size: 0.85rem;
  }
  
  .players-status {
    grid-template-columns: 1fr;
  }
  
  .scoreboard {
    flex-direction: column;
  }
}
</style>
