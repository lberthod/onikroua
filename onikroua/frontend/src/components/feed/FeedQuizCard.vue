<template>
  <div class="feed-card quiz-card">
    <div class="card-header">
      <div class="card-type">
        <span class="type-icon">🎯</span>
        <span class="type-label">Quiz</span>
      </div>
      <div class="difficulty-badge" :class="item.difficulty">
        {{ difficultyLabel }}
      </div>
    </div>

    <div class="card-content">
      <div class="quiz-info">
        <div class="category-badge" :class="item.data.category">
          {{ categoryLabels[item.data.category] || item.data.category }}
        </div>
        <div v-if="item.data.subCategory" class="subcategory-badge">
          {{ item.data.subCategory }}
        </div>
      </div>

      <div class="quiz-question-section">
        <div class="question-header">
          <span class="question-icon">❓</span>
          <span class="question-type">{{ typeLabels[item.data.type] }}</span>
        </div>
        <div class="question-text">{{ item.data.prompt }}</div>
      </div>

      <!-- Multiple Choice Questions -->
      <div v-if="item.data.type === 'choice' && item.data.choices" class="multiple-choice">
        <div class="choices-grid">
          <button
            v-for="(choice, index) in item.data.choices"
            :key="index"
            @click="selectChoice(index)"
            :class="[
              'choice-btn',
              {
                'selected': selectedChoice === index,
                'correct': showAnswer && index === item.data.correctIndex,
                'incorrect': showAnswer && selectedChoice === index && index !== item.data.correctIndex
              }
            ]"
            :disabled="showAnswer"
          >
            <span class="choice-letter">{{ String.fromCharCode(65 + index) }}</span>
            <span class="choice-text">{{ choice }}</span>
          </button>
        </div>
      </div>

      <!-- Fill-in Questions -->
      <div v-if="item.data.type === 'write'" class="fill-in-section">
        <div class="fill-in-input-container">
          <input
            v-model="fillInAnswer"
            @keyup.enter="checkFillInAnswer"
            type="text"
            class="fill-in-input"
            placeholder="Tapez votre réponse..."
            :disabled="showAnswer"
          />
          <button
            @click="checkFillInAnswer"
            :disabled="showAnswer || !fillInAnswer.trim()"
            class="submit-btn"
          >
            Vérifier
          </button>
        </div>
      </div>

      <!-- Audio Questions -->
      <div v-if="item.data.type === 'listen' && item.data.audio && item.data.audioText" class="audio-section">
        <div class="audio-controls">
          <button @click="playAudio" :disabled="isPlaying" class="audio-btn">
            🔊 {{ isPlaying ? 'Lecture...' : 'Écouter l\'audio' }}
          </button>
          <div class="audio-hint">Écoutez et répondez</div>
        </div>
      </div>

      <!-- Answer Feedback -->
      <div v-if="showAnswer" class="answer-feedback">
        <div class="feedback-result" :class="{ correct: answerCorrect }">
          <span class="result-icon">{{ answerCorrect ? '✅' : '❌' }}</span>
          <span class="result-text">
            {{ answerCorrect ? 'Excellente réponse !' : 'Pas tout à fait correct' }}
          </span>
        </div>

        <div class="correct-answer-section">
          <strong>Réponse correcte :</strong> {{ item.data.correctAnswer }}
        </div>

        <div v-if="item.data.explanation" class="explanation-section">
          <div class="explanation-header">
            <span class="explanation-icon">💡</span>
            <strong>Explication :</strong>
          </div>
          <div class="explanation-text">{{ item.data.explanation }}</div>
        </div>
      </div>
    </div>

    <div class="card-actions">
      <button v-if="!showAnswer" @click="giveHint" class="hint-btn">
        <span class="btn-icon">💡</span>
        Indice
      </button>
      <button v-if="showAnswer" @click="resetQuiz" class="retry-btn">
        <span class="btn-icon">🔄</span>
        Réessayer
      </button>
      <button @click="toggleBookmark" class="bookmark-btn" :class="{ bookmarked }">
        <span class="btn-icon">{{ bookmarked ? '⭐' : '☆' }}</span>
        {{ bookmarked ? 'Favori' : 'Marquer' }}
      </button>
    </div>

    <!-- Hint Section -->
    <div v-if="showHint" class="hint-section">
      <div class="hint-header">
        <span class="hint-icon">💡</span>
        <strong>Indice :</strong>
      </div>
      <div class="hint-content">{{ generateHint() }}</div>
    </div>

    <!-- Related Content -->
    <div v-if="showAnswer" class="related-section">
      <div class="related-header">
        <span class="related-icon">🔗</span>
        <strong>Pour aller plus loin :</strong>
      </div>
      <div class="related-suggestion">
        Explorez plus de contenu sur <strong>{{ item.data.category }}</strong> dans les autres sections du feed !
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import type { QuizFeedItem } from '../../services/feedService'

const props = defineProps<{
  item: QuizFeedItem
  language: 'it' | 'es'
}>()

const selectedChoice = ref<number | null>(null)
const fillInAnswer = ref('')
const showAnswer = ref(false)
const answerCorrect = ref(false)
const showHint = ref(false)
const bookmarked = ref(false)
const isPlaying = ref(false)

const categoryLabels = {
  vocabulary: '📚 Vocabulaire',
  grammar: '📖 Grammaire',
  conjugation: '⚡ Conjugaison',
  phonetics: '🔊 Phonétique'
}

const typeLabels = {
  choice: '🅰️ Choix multiple',
  write: '✏️ Texte libre',
  listen: '🎧 Audio'
}

const difficultyLabel = computed(() => {
  const labels = {
    'beginner': 'Débutant',
    'intermediate': 'Intermédiaire',
    'advanced': 'Avancé'
  }
  return labels[props.item.difficulty]
})

const selectChoice = (index: number) => {
  if (showAnswer.value) return
  
  selectedChoice.value = index
  showAnswer.value = true
  
  if (props.item.data.type === 'choice') {
    answerCorrect.value = index === props.item.data.correctIndex
  }
}

const checkFillInAnswer = () => {
  if (showAnswer.value || !fillInAnswer.value.trim()) return
  
  showAnswer.value = true
  const userAnswer = fillInAnswer.value.toLowerCase().trim()
  const correctAnswer = (props.item.data.correctAnswer || '').toLowerCase().trim()
  
  // Allow for minor variations in fill-in answers
  answerCorrect.value = userAnswer === correctAnswer || 
                       correctAnswer.includes(userAnswer) ||
                       userAnswer.includes(correctAnswer)
}

const playAudio = () => {
  if (isPlaying.value || !props.item.data.audioText) return
  
  isPlaying.value = true
  const utterance = new SpeechSynthesisUtterance(props.item.data.audioText)
  utterance.lang = props.language === 'it' ? 'it-IT' : 'es-ES'
  utterance.rate = 0.8
  
  utterance.onend = () => {
    isPlaying.value = false
  }
  
  speechSynthesis.speak(utterance)
}

const giveHint = () => {
  showHint.value = true
}

const generateHint = () => {
  const hints = [
    `Cette question porte sur ${categoryLabels[props.item.data.category] || props.item.data.category}`,
    `Pensez aux règles de base de ${props.language === 'it' ? "l'italien" : "l'espagnol"}`,
    props.item.data.correctAnswer ? `La réponse commence par "${props.item.data.correctAnswer[0]}"` : ''
  ]
  
  if (props.item.data.type === 'choice' && props.item.data.choices) {
    return `Éliminez les options qui ne correspondent pas au contexte de la question.`
  }
  
  return hints[Math.floor(Math.random() * hints.length)]
}

const toggleBookmark = () => {
  bookmarked.value = !bookmarked.value
  // In a real app, this would save to user preferences
}

const resetQuiz = () => {
  selectedChoice.value = null
  fillInAnswer.value = ''
  showAnswer.value = false
  answerCorrect.value = false
  showHint.value = false
}

// Reset when item changes
watch(() => props.item.id, () => {
  resetQuiz()
  bookmarked.value = false
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
  color: #7c2d12;
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

.quiz-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.category-badge {
  padding: 0.5rem 0.75rem;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
}

.category-badge.vocabulary {
  background: #ecfdf5;
  color: #065f46;
}

.category-badge.grammar {
  background: #e0e7ff;
  color: #3730a3;
}

.category-badge.pronunciation {
  background: #f3e8ff;
  color: #6b21a8;
}

.category-badge.culture {
  background: #fef3c7;
  color: #92400e;
}

.category-badge.conjugation {
  background: #fee2e2;
  color: #991b1b;
}

.subcategory-badge {
  padding: 0.25rem 0.5rem;
  background: #f3f4f6;
  color: #374151;
  border-radius: 8px;
  font-size: 0.8rem;
}

.quiz-question-section {
  background: linear-gradient(135deg, #fef7ed, #fed7aa);
  padding: 1.5rem;
  border-radius: 16px;
  margin-bottom: 1.5rem;
  border-left: 4px solid #ea580c;
}

.question-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  color: #9a3412;
  font-weight: 600;
}

.question-text {
  color: #9a3412;
  font-size: 1.1rem;
  line-height: 1.5;
  font-weight: 500;
}

.multiple-choice {
  margin-bottom: 1.5rem;
}

.choices-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 0.75rem;
}

.choice-btn {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border: 2px solid #e5e7eb;
  background: white;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: left;
}

.choice-btn:hover:not(:disabled) {
  border-color: #7c2d12;
  background: #fef7ed;
}

.choice-btn.selected {
  border-color: #7c2d12;
  background: #fef7ed;
}

.choice-btn.correct {
  border-color: #10b981;
  background: #d1fae5;
  color: #065f46;
}

.choice-btn.incorrect {
  border-color: #ef4444;
  background: #fee2e2;
  color: #991b1b;
}

.choice-btn:disabled {
  cursor: not-allowed;
}

.choice-letter {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  background: #f3f4f6;
  border-radius: 50%;
  font-weight: bold;
  color: #374151;
  flex-shrink: 0;
}

.choice-btn.correct .choice-letter {
  background: #10b981;
  color: white;
}

.choice-btn.incorrect .choice-letter {
  background: #ef4444;
  color: white;
}

.choice-text {
  flex: 1;
  font-size: 1rem;
  line-height: 1.4;
}

.fill-in-section {
  margin-bottom: 1.5rem;
}

.fill-in-input-container {
  display: flex;
  gap: 0.75rem;
}

.fill-in-input {
  flex: 1;
  padding: 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
}

.fill-in-input:focus {
  outline: none;
  border-color: #7c2d12;
}

.fill-in-input:disabled {
  background: #f9fafb;
  cursor: not-allowed;
}

.submit-btn {
  background: #7c2d12;
  color: white;
  border: none;
  padding: 1rem 1.5rem;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.submit-btn:hover:not(:disabled) {
  background: #9a3412;
  transform: translateY(-1px);
}

.submit-btn:disabled {
  background: #d1d5db;
  cursor: not-allowed;
}

.audio-section {
  margin-bottom: 1.5rem;
  text-align: center;
}

.audio-controls {
  background: linear-gradient(135deg, #f0f9ff, #dbeafe);
  padding: 1.5rem;
  border-radius: 12px;
  border: 2px solid #3b82f6;
}

.audio-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 1rem 1.5rem;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  font-size: 1rem;
  margin-bottom: 0.5rem;
  transition: all 0.3s ease;
}

.audio-btn:hover:not(:disabled) {
  background: #2563eb;
  transform: scale(1.05);
}

.audio-btn:disabled {
  background: #9ca3af;
  cursor: not-allowed;
}

.audio-hint {
  color: #1e40af;
  font-style: italic;
}

.answer-feedback {
  background: white;
  border: 2px solid #e5e7eb;
  border-radius: 16px;
  padding: 1.5rem;
  margin-bottom: 1rem;
}

.feedback-result {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
  padding: 1rem;
  border-radius: 12px;
}

.feedback-result.correct {
  background: #d1fae5;
  color: #065f46;
}

.feedback-result:not(.correct) {
  background: #fee2e2;
  color: #991b1b;
}

.result-icon {
  font-size: 1.5rem;
}

.result-text {
  font-weight: 600;
  font-size: 1.1rem;
}

.correct-answer-section {
  margin-bottom: 1rem;
  padding: 1rem;
  background: #f3f4f6;
  border-radius: 8px;
  color: #374151;
}

.explanation-section {
  padding: 1rem;
  background: linear-gradient(135deg, #f0f9ff, #dbeafe);
  border-radius: 12px;
  border-left: 4px solid #3b82f6;
}

.explanation-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  color: #1e40af;
  font-weight: 600;
}

.explanation-text {
  color: #1e3a8a;
  line-height: 1.6;
}

.card-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.hint-btn, .retry-btn, .bookmark-btn {
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
  flex: 1;
}

.hint-btn {
  background: linear-gradient(135deg, #f59e0b, #f97316);
  color: white;
}

.hint-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(245, 158, 11, 0.4);
}

.retry-btn {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: white;
}

.retry-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.4);
}

.bookmark-btn {
  background: linear-gradient(135deg, #6b7280, #9ca3af);
  color: white;
}

.bookmark-btn.bookmarked {
  background: linear-gradient(135deg, #fbbf24, #f59e0b);
}

.bookmark-btn:hover {
  transform: translateY(-1px);
}

.hint-section, .related-section {
  margin-top: 1rem;
  padding: 1rem;
  border-radius: 12px;
}

.hint-section {
  background: linear-gradient(135deg, #fef3c7, #fde68a);
  border-left: 4px solid #f59e0b;
}

.related-section {
  background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
  border-left: 4px solid #6366f1;
}

.hint-header, .related-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  font-weight: 600;
}

.hint-header {
  color: #92400e;
}

.related-header {
  color: #4338ca;
}

.hint-content, .related-suggestion {
  line-height: 1.5;
}

.hint-content {
  color: #78350f;
}

.related-suggestion {
  color: #312e81;
}
</style>
