<template>
  <div class="feed-card conjugation-card">
    <div class="card-header">
      <div class="card-type">
        <span class="type-icon">⚡</span>
        <span class="type-label">Conjugaison</span>
      </div>
      <div class="difficulty-badge" :class="item.difficulty">
        {{ difficultyLabel }}
      </div>
    </div>

    <div class="card-content">
      <div class="verb-info">
        <div class="verb-display">
          <div class="verb-name">{{ item.data.verb }}</div>
          <div class="verb-translation">{{ item.data.translation }}</div>
          <div class="tense-badge">{{ item.data.tense }}</div>
        </div>
        <button 
          @click="playText(item.data.verb)"
          class="verb-tts-btn"
          :disabled="isPlaying"
        >
          🔊
        </button>
      </div>

      <div v-if="item.data.example" class="conjugation-example">
        <div class="example-header">
          <span class="example-icon">💡</span>
          <strong>Exemple :</strong>
        </div>
        <div class="example-text">{{ item.data.example }}</div>
        <button 
          @click="playText(item.data.example)"
          class="example-tts-btn"
          :disabled="isPlaying"
        >
          🔊
        </button>
      </div>

      <div v-if="item.data.conjugations" class="conjugations-table">
        <h4>Conjugaison complète :</h4>
        <div class="conjugations-grid">
          <div 
            v-for="(conjugation, pronoun) in item.data.conjugations"
            :key="pronoun"
            class="conjugation-row"
            @click="playConjugation(pronoun, conjugation)"
          >
            <span class="pronoun">{{ pronoun }}</span>
            <span class="conjugated-form">{{ conjugation }}</span>
            <span class="play-mini">🔊</span>
          </div>
        </div>
      </div>
    </div>

    <div class="card-actions">
      <button @click="startQuiz" class="quiz-btn">
        <span class="btn-icon">🎯</span>
        Quiz conjugaison
      </button>
      <button @click="showFullConjugation = !showFullConjugation" class="details-btn">
        <span class="btn-icon">📋</span>
        {{ showFullConjugation ? 'Masquer' : 'Détails' }}
      </button>
    </div>

    <!-- Quiz Section -->
    <div v-if="showQuiz" class="quiz-section">
      <div class="quiz-header">
        <h4>🎯 Quiz Conjugaison</h4>
        <button @click="showQuiz = false" class="close-btn">×</button>
      </div>

      <div class="quiz-progress">
        <div class="progress-bar">
          <div 
            class="progress-fill" 
            :style="{ width: `${(currentQuestion / totalQuestions) * 100}%` }"
          ></div>
        </div>
        <span class="progress-text">{{ currentQuestion }} / {{ totalQuestions }}</span>
      </div>

      <div class="quiz-question">
        <div class="question-text">
          Comment conjuguer <strong>{{ item.data.verb }}</strong> avec <strong>{{ currentPronoun }}</strong> ?
        </div>
        <div class="question-hint">
          {{ currentPronoun }} {{ item.data.verb }} → ?
        </div>
      </div>

      <div class="quiz-input">
        <input
          v-model="userAnswer"
          @keyup.enter="checkAnswer"
          type="text"
          class="conjugation-input"
          placeholder="Tapez votre réponse..."
          :disabled="showAnswer"
        />
        <button 
          @click="checkAnswer"
          :disabled="showAnswer || !userAnswer.trim()"
          class="check-btn"
        >
          Vérifier
        </button>
      </div>

      <div v-if="showAnswer" class="quiz-feedback">
        <div class="feedback-result" :class="{ correct: answerCorrect }">
          {{ answerCorrect ? '✅ Excellent !' : '❌ Pas tout à fait' }}
        </div>
        <div class="correct-answer">
          La bonne réponse est : <strong>{{ currentPronoun }} {{ correctAnswer }}</strong>
        </div>
        <button @click="nextQuestion" class="next-btn">
          {{ currentQuestion < totalQuestions ? 'Question suivante' : 'Terminer' }}
        </button>
      </div>
    </div>

    <!-- Full Conjugation Details -->
    <div v-if="showFullConjugation" class="full-conjugation">
      <div class="conjugation-header">
        <h4>📋 Conjugaison complète - {{ item.data.tense }}</h4>
      </div>

      <div class="conjugation-table">
        <div 
          v-for="(conjugation, pronoun) in item.data.conjugations"
          :key="pronoun"
          class="table-row"
        >
          <div class="pronoun-cell">{{ pronoun }}</div>
          <div class="verb-cell">{{ item.data.verb }}</div>
          <div class="conjugation-cell">{{ conjugation }}</div>
          <button 
            @click="playConjugation(pronoun, conjugation)"
            class="play-cell"
          >
            🔊
          </button>
        </div>
      </div>

      <div class="conjugation-tips">
        <div class="tip">
          <strong>💡 Règle :</strong> 
          {{ getConjugationRule() }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import type { ConjugationFeedItem } from '../../services/feedService'

const props = defineProps<{
  item: ConjugationFeedItem
  language: 'it' | 'es'
}>()

const showQuiz = ref(false)
const showFullConjugation = ref(false)
const isPlaying = ref(false)
const currentQuestion = ref(1)
const totalQuestions = ref(5)
const userAnswer = ref('')
const showAnswer = ref(false)
const answerCorrect = ref(false)
const currentPronoun = ref('')
const correctAnswer = ref('')
const score = ref(0)

const difficultyLabel = computed(() => {
  const labels = {
    'beginner': 'Débutant',
    'intermediate': 'Intermédiaire',
    'advanced': 'Avancé'
  }
  return labels[props.item.difficulty]
})

const pronouns = computed(() => {
  if (!props.item.data.conjugations) return []
  return Object.keys(props.item.data.conjugations)
})

const startQuiz = () => {
  showQuiz.value = true
  currentQuestion.value = 1
  score.value = 0
  generateQuestion()
}

const generateQuestion = () => {
  if (pronouns.value.length === 0) return
  
  const randomPronoun = pronouns.value[Math.floor(Math.random() * pronouns.value.length)]
  currentPronoun.value = randomPronoun
  correctAnswer.value = props.item.data.conjugations?.[randomPronoun] || ''
  
  userAnswer.value = ''
  showAnswer.value = false
  answerCorrect.value = false
}

const checkAnswer = () => {
  if (!userAnswer.value.trim()) return
  
  showAnswer.value = true
  const userAnswerClean = userAnswer.value.trim().toLowerCase()
  const correctAnswerClean = correctAnswer.value.toLowerCase()
  
  answerCorrect.value = userAnswerClean === correctAnswerClean
  
  if (answerCorrect.value) {
    score.value++
  }
}

const nextQuestion = () => {
  if (currentQuestion.value < totalQuestions.value) {
    currentQuestion.value++
    generateQuestion()
  } else {
    // Quiz terminé
    showQuiz.value = false
    // Optionally show final score
    console.log(`Quiz terminé! Score: ${score.value}/${totalQuestions.value}`)
  }
}

const playText = (text: string) => {
  if (isPlaying.value || !text) return
  
  isPlaying.value = true
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = props.language === 'it' ? 'it-IT' : 'es-ES'
  utterance.rate = 0.8
  
  utterance.onend = () => {
    isPlaying.value = false
  }
  
  speechSynthesis.speak(utterance)
}

const playConjugation = (pronoun: string, conjugation: string) => {
  const fullSentence = `${pronoun} ${conjugation}`
  playText(fullSentence)
}

const getConjugationRule = () => {
  const verb = props.item.data.verb
  const tense = props.item.data.tense
  
  if (props.language === 'it') {
    if (verb.endsWith('are')) {
      return `Verbe du 1er groupe (-are) au ${tense.toLowerCase()}`
    } else if (verb.endsWith('ere')) {
      return `Verbe du 2ème groupe (-ere) au ${tense.toLowerCase()}`
    } else if (verb.endsWith('ire')) {
      return `Verbe du 3ème groupe (-ire) au ${tense.toLowerCase()}`
    }
  } else {
    if (verb.endsWith('ar')) {
      return `Verbe du 1er groupe (-ar) au ${tense.toLowerCase()}`
    } else if (verb.endsWith('er')) {
      return `Verbe du 2ème groupe (-er) au ${tense.toLowerCase()}`
    } else if (verb.endsWith('ir')) {
      return `Verbe du 3ème groupe (-ir) au ${tense.toLowerCase()}`
    }
  }
  
  return `Conjugaison du verbe "${verb}" au ${tense.toLowerCase()}`
}

// Reset when item changes
watch(() => props.item.id, () => {
  showQuiz.value = false
  showFullConjugation.value = false
})
</script>

<style scoped>
.feed-card {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
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
  color: #dc2626;
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

.verb-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, #fee2e2, #fecaca);
  padding: 1.5rem;
  border-radius: 16px;
  margin-bottom: 1rem;
}

.verb-display {
  text-align: center;
}

.verb-name {
  font-size: 2rem;
  font-weight: bold;
  color: #991b1b;
  margin-bottom: 0.25rem;
}

.verb-translation {
  font-size: 1.1rem;
  color: #6b7280;
  font-style: italic;
  margin-bottom: 0.5rem;
}

.tense-badge {
  background: rgba(255, 255, 255, 0.9);
  color: #dc2626;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 600;
}

.verb-tts-btn {
  background: rgba(255, 255, 255, 0.9);
  border: 2px solid #dc2626;
  border-radius: 50%;
  width: 3rem;
  height: 3rem;
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.3s ease;
}

.verb-tts-btn:hover:not(:disabled) {
  background: #dc2626;
  transform: scale(1.1);
}

.verb-tts-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.conjugation-example {
  background: linear-gradient(135deg, #f0f9ff, #dbeafe);
  padding: 1rem;
  border-radius: 12px;
  margin-bottom: 1rem;
  position: relative;
}

.example-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  color: #1e40af;
  font-weight: 600;
}

.example-text {
  font-style: italic;
  color: #1e3a8a;
  font-size: 1.05rem;
}

.example-tts-btn {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  background: rgba(255, 255, 255, 0.8);
  border: none;
  border-radius: 8px;
  padding: 0.5rem;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.example-tts-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.95);
  transform: scale(1.1);
}

.conjugations-table h4 {
  color: #374151;
  margin-bottom: 0.75rem;
  font-size: 1rem;
}

.conjugations-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 0.5rem;
}

.conjugation-row {
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.75rem;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
  position: relative;
}

.conjugation-row:hover {
  border-color: #dc2626;
  background: #fee2e2;
}

.pronoun {
  display: block;
  font-size: 0.85rem;
  color: #6b7280;
  margin-bottom: 0.25rem;
}

.conjugated-form {
  display: block;
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.25rem;
}

.play-mini {
  font-size: 0.8rem;
  opacity: 0.7;
}

.card-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.quiz-btn, .details-btn {
  flex: 1;
  padding: 0.75rem;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.quiz-btn {
  background: linear-gradient(135deg, #dc2626, #ef4444);
  color: white;
}

.quiz-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(220, 38, 38, 0.4);
}

.details-btn {
  background: linear-gradient(135deg, #6b7280, #9ca3af);
  color: white;
}

.details-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(107, 114, 128, 0.4);
}

.quiz-section, .full-conjugation {
  margin-top: 1rem;
  padding: 1rem;
  background: #f9fafb;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
}

.quiz-header, .conjugation-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.quiz-header h4, .conjugation-header h4 {
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

.quiz-progress {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.progress-bar {
  flex: 1;
  height: 8px;
  background: #e5e7eb;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #dc2626, #ef4444);
  transition: width 0.3s ease;
}

.progress-text {
  font-weight: 600;
  color: #374151;
}

.quiz-question {
  margin-bottom: 1rem;
}

.question-text {
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.5rem;
}

.question-hint {
  color: #6b7280;
  font-style: italic;
}

.quiz-input {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.conjugation-input {
  flex: 1;
  padding: 0.75rem;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  font-size: 1rem;
}

.conjugation-input:focus {
  outline: none;
  border-color: #dc2626;
}

.check-btn {
  background: #dc2626;
  color: white;
  border: none;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

.check-btn:disabled {
  background: #d1d5db;
  cursor: not-allowed;
}

.quiz-feedback {
  padding: 0.75rem;
  border-radius: 8px;
  background: white;
}

.feedback-result.correct {
  color: #065f46;
  font-weight: 600;
}

.feedback-result:not(.correct) {
  color: #991b1b;
  font-weight: 600;
}

.correct-answer {
  margin: 0.5rem 0;
  color: #374151;
}

.next-btn {
  background: #6366f1;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
}

.next-btn:hover {
  background: #4f46e5;
}

.conjugation-table {
  margin-bottom: 1rem;
}

.table-row {
  display: grid;
  grid-template-columns: 80px 1fr 1fr auto;
  gap: 0.5rem;
  align-items: center;
  padding: 0.75rem;
  border-bottom: 1px solid #e5e7eb;
}

.table-row:last-child {
  border-bottom: none;
}

.pronoun-cell {
  font-weight: 600;
  color: #6b7280;
}

.verb-cell {
  font-style: italic;
  color: #9ca3af;
}

.conjugation-cell {
  font-weight: 600;
  color: #dc2626;
}

.play-cell {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  transition: background 0.3s ease;
}

.play-cell:hover {
  background: #f3f4f6;
}

.conjugation-tips {
  margin-top: 1rem;
}

.conjugation-tips .tip {
  background: white;
  padding: 0.75rem;
  border-radius: 8px;
  border-left: 3px solid #dc2626;
  color: #374151;
}
</style>
