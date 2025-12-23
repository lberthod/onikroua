<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import type { GrammarItem, GrammarExercise } from '../../stores/learning'
import { ttsService, getTTSLang } from '../../services/tts'

interface Props {
  items: GrammarItem[]
  language: 'it' | 'es'
}

const props = defineProps<Props>()

// État
const currentIndex = ref(0)
const selectedOption = ref<string | null>(null)
const userInput = ref('')
const showFeedback = ref(false)
const isCorrect = ref(false)
const score = ref(0)
const completed = ref(false)

// Flattened list of all exercises with their rule context
const allQuestions = computed(() => {
  const questions: { exercise: GrammarExercise, ruleName: string }[] = []
  props.items.forEach(item => {
    if (item.exercises) {
      item.exercises.forEach(ex => {
        questions.push({
          exercise: ex,
          ruleName: item.rule
        })
      })
    }
  })
  return questions
})

const currentQuestion = computed(() => {
  if (allQuestions.value.length === 0) return null
  return allQuestions.value[currentIndex.value]
})

const ttsLang = computed(() => getTTSLang(props.language))

// Initialisation
watch(() => props.items, () => {
  reset()
}, { immediate: true })

function reset() {
  currentIndex.value = 0
  selectedOption.value = null
  userInput.value = ''
  showFeedback.value = false
  score.value = 0
  completed.value = false
}

// Actions
const playText = async (text: string) => {
  try {
    await ttsService.speak(text, { lang: ttsLang.value })
  } catch (error) {
    console.error('Erreur TTS:', error)
  }
}

const checkAnswer = () => {
  if (!currentQuestion.value) return

  let correct = false
  const answer = currentQuestion.value.exercise.correctAnswer.toLowerCase().trim()

  if (currentQuestion.value.exercise.type === 'quiz') {
    if (selectedOption.value) {
      correct = selectedOption.value.toLowerCase() === answer
    }
  } else {
    // Fill-in
    correct = userInput.value.toLowerCase().trim() === answer
  }

  isCorrect.value = correct
  showFeedback.value = true
  
  if (correct) {
    score.value++
  }
}

const nextExercise = () => {
  showFeedback.value = false
  selectedOption.value = null
  userInput.value = ''
  
  if (currentIndex.value < allQuestions.value.length - 1) {
    currentIndex.value++
  } else {
    completed.value = true
  }
}
</script>

<template>
  <div class="grammar-practice">
    <!-- Écran de fin -->
    <div v-if="completed" class="completion-screen">
      <div class="completion-content">
        <span class="completion-icon">🏆</span>
        <h3>Session terminée !</h3>
        <p>Vous avez obtenu un score de <strong>{{ score }} / {{ allQuestions.length }}</strong></p>
        <button class="restart-btn" @click="reset">Recommencer</button>
      </div>
    </div>

    <!-- Interface d'exercice -->
    <div v-else-if="currentQuestion" class="exercise-container">
      <div class="exercise-header">
        <span class="rule-title">Règle : {{ currentQuestion.ruleName }}</span>
        <div class="progress-indicator">
          Question {{ currentIndex + 1 }} / {{ allQuestions.length }}
        </div>
      </div>

      <div class="question-card">
        <h3 class="question-text">
          {{ currentQuestion.exercise.question }}
          <button class="tts-btn" @click="playText(currentQuestion.exercise.question)">🔊</button>
        </h3>

        <!-- Type Quiz (QCM) -->
        <div v-if="currentQuestion.exercise.type === 'quiz'" class="options-grid">
          <button
            v-for="(option, idx) in currentQuestion.exercise.options"
            :key="idx"
            class="option-btn"
            :class="{ 
              selected: selectedOption === option,
              correct: showFeedback && option === currentQuestion.exercise.correctAnswer,
              wrong: showFeedback && selectedOption === option && option !== currentQuestion.exercise.correctAnswer
            }"
            @click="!showFeedback && (selectedOption = option)"
            :disabled="showFeedback"
          >
            {{ option }}
          </button>
        </div>

        <!-- Type Fill-in (Texte à trous) -->
        <div v-else class="input-container">
          <input 
            v-model="userInput"
            type="text" 
            placeholder="Tapez votre réponse..."
            class="text-input"
            :class="{ 
              correct: showFeedback && isCorrect,
              wrong: showFeedback && !isCorrect
            }"
            :disabled="showFeedback"
            @keyup.enter="!showFeedback && checkAnswer()"
          />
        </div>
      </div>

      <!-- Feedback -->
      <div v-if="showFeedback" class="feedback-section" :class="{ success: isCorrect, error: !isCorrect }">
        <div class="feedback-content">
          <span class="feedback-icon">{{ isCorrect ? '✅' : '❌' }}</span>
          <div>
            <strong>{{ isCorrect ? 'Correct !' : 'Incorrect' }}</strong>
            <p v-if="!isCorrect">La bonne réponse était : <strong>{{ currentQuestion.exercise.correctAnswer }}</strong></p>
            <p v-if="currentQuestion.exercise.explanation" class="explanation">💡 {{ currentQuestion.exercise.explanation }}</p>
          </div>
        </div>
        <button class="next-btn" @click="nextExercise">
          {{ completed ? 'Voir les résultats' : 'Suivant' }} →
        </button>
      </div>

      <!-- Bouton Valider -->
      <button 
        v-else 
        class="check-btn"
        @click="checkAnswer"
        :disabled="(!selectedOption && !userInput) || showFeedback"
      >
        Valider
      </button>
    </div>

    <!-- État vide -->
    <div v-else class="empty-state">
      <p>Aucun exercice disponible pour cette section.</p>
    </div>
  </div>
</template>

<style scoped>
.grammar-practice {
  max-width: 800px;
  margin: 0 auto;
}

.exercise-container {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.exercise-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.rule-title {
  background: #f0f2f5;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  color: #2c3e50;
  font-weight: 500;
}

.question-card {
  margin-bottom: 2rem;
}

.question-text {
  font-size: 1.5rem;
  color: #2c3e50;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.tts-btn {
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
  opacity: 0.6;
  transition: opacity 0.2s;
}

.tts-btn:hover {
  opacity: 1;
}

/* Options QCM */
.options-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.option-btn {
  padding: 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  background: white;
  font-size: 1.1rem;
  cursor: pointer;
  transition: all 0.2s;
  text-align: left;
}

.option-btn:hover:not(:disabled) {
  border-color: #3498db;
  background: #f0f8ff;
}

.option-btn.selected {
  border-color: #3498db;
  background: #e1f0fa;
  color: #2980b9;
}

.option-btn.correct {
  border-color: #27ae60;
  background: #e8f5e9;
  color: #27ae60;
}

.option-btn.wrong {
  border-color: #e74c3c;
  background: #fdecea;
  color: #c0392b;
  opacity: 0.7;
}

/* Input texte */
.input-container {
  margin-top: 1rem;
}

.text-input {
  width: 100%;
  padding: 1rem;
  font-size: 1.2rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  transition: all 0.2s;
}

.text-input:focus {
  outline: none;
  border-color: #3498db;
}

.text-input.correct {
  border-color: #27ae60;
  background: #e8f5e9;
}

.text-input.wrong {
  border-color: #e74c3c;
  background: #fdecea;
}

/* Bouton valider */
.check-btn {
  width: 100%;
  padding: 1rem;
  background: #3498db;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.check-btn:hover:not(:disabled) {
  background: #2980b9;
}

.check-btn:disabled {
  background: #bdc3c7;
  cursor: not-allowed;
}

/* Feedback */
.feedback-section {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
  margin-top: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  animation: slideUp 0.3s ease;
}

.feedback-section.success {
  background: #e8f5e9;
  border-left: 5px solid #27ae60;
}

.feedback-section.error {
  background: #ffebee;
  border-left: 5px solid #e74c3c;
}

.feedback-content {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}

.feedback-icon {
  font-size: 1.5rem;
}

.explanation {
  margin: 0.5rem 0 0 0;
  font-size: 0.9rem;
  color: #666;
}

.next-btn {
  padding: 0.75rem 1.5rem;
  background: #2c3e50;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  white-space: nowrap;
}

.next-btn:hover {
  background: #34495e;
}

/* Écran de fin */
.completion-screen {
  text-align: center;
  padding: 3rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.completion-icon {
  font-size: 4rem;
  display: block;
  margin-bottom: 1rem;
}

.restart-btn {
  margin-top: 1.5rem;
  padding: 0.75rem 1.5rem;
  background: #3498db;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Responsive */
@media (max-width: 768px) {
  .practice-container {
    padding: 1.25rem;
  }
  
  .question-text {
    font-size: 1.1rem;
  }
  
  .option-btn {
    padding: 0.9rem 1rem;
    font-size: 1rem;
  }
  
  .text-input {
    padding: 0.9rem;
    font-size: 1.1rem;
  }
  
  .feedback-section {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }
  
  .feedback-content {
    flex-direction: column;
    align-items: center;
  }
  
  .next-btn {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .practice-container {
    padding: 1rem;
    border-radius: 10px;
  }
  
  .progress-bar {
    height: 6px;
  }
  
  .question-text {
    font-size: 1rem;
  }
  
  .options-grid {
    gap: 0.5rem;
  }
  
  .option-btn {
    padding: 0.75rem;
    font-size: 0.95rem;
  }
  
  .text-input {
    padding: 0.75rem;
    font-size: 1rem;
  }
  
  .check-btn {
    padding: 0.9rem;
    font-size: 1rem;
  }
  
  .completion-screen {
    padding: 2rem 1rem;
  }
  
  .completion-icon {
    font-size: 3rem;
  }
}
</style>
