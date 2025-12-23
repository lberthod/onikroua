<template>
  <div class="feed-card grammar-card">
    <div class="card-header">
      <div class="card-type">
        <span class="type-icon">📖</span>
        <span class="type-label">Grammaire</span>
      </div>
      <div class="difficulty-badge" :class="item.difficulty">
        {{ difficultyLabel }}
      </div>
    </div>

    <div class="card-content">
      <h3 class="grammar-rule">{{ item.data.rule }}</h3>
      <p class="grammar-content">{{ item.data.content }}</p>
      
      <div v-if="item.data.translation" class="grammar-structure">
        <strong>Structure :</strong> {{ item.data.translation }}
      </div>
      
      <div v-if="item.data.example" class="grammar-example">
        <div class="example-header">
          <span class="example-icon">💡</span>
          <strong>Exemple :</strong>
        </div>
        <div class="example-text">{{ item.data.example }}</div>
        <button 
          v-if="item.data.example"
          @click="playText(item.data.example)"
          class="tts-btn"
          :disabled="isPlaying"
        >
          🔊
        </button>
      </div>

      <div v-if="item.data.exceptions?.length" class="grammar-exceptions">
        <strong>⚠️ Exceptions :</strong>
        <ul>
          <li v-for="exception in item.data.exceptions" :key="exception">
            {{ exception }}
          </li>
        </ul>
      </div>
    </div>

    <div v-if="item.data.exercises?.length" class="card-actions">
      <button @click="showExercises = !showExercises" class="practice-btn">
        <span class="btn-icon">🎯</span>
        {{ showExercises ? 'Masquer' : 'Pratiquer' }} ({{ item.data.exercises.length }} exercices)
      </button>
    </div>

    <!-- Exercices -->
    <div v-if="showExercises && item.data.exercises?.length" class="exercises-section">
      <div 
        v-for="(exercise, index) in item.data.exercises"
        :key="exercise.id"
        class="mini-exercise"
      >
        <div class="exercise-header">
          <span class="exercise-number">{{ index + 1 }}.</span>
          <span class="exercise-type-badge" :class="exercise.type">
            {{ exercise.type === 'quiz' ? '🅰️ QCM' : '✏️ Écriture' }}
          </span>
        </div>
        
        <div class="exercise-question">{{ exercise.question }}</div>
        
        <!-- Quiz options -->
        <div v-if="exercise.type === 'quiz' && exercise.options" class="quiz-options">
          <button
            v-for="(option, optIndex) in exercise.options"
            :key="optIndex"
            @click="selectAnswer(exercise.id, optIndex)"
            :class="[
              'quiz-option',
              {
                'selected': selectedAnswers[exercise.id] === optIndex,
                'correct': showAnswers[exercise.id] && optIndex === exercise.options?.indexOf(exercise.correctAnswer),
                'incorrect': showAnswers[exercise.id] && selectedAnswers[exercise.id] === optIndex && optIndex !== exercise.options?.indexOf(exercise.correctAnswer)
              }
            ]"
          >
            {{ option }}
          </button>
        </div>

        <!-- Fill-in input -->
        <div v-else-if="exercise.type === 'fill-in'" class="fill-in-section">
          <input
            v-model="fillInAnswers[exercise.id]"
            @keyup.enter="checkFillInAnswer(exercise.id, exercise.correctAnswer)"
            type="text"
            class="fill-in-input"
            placeholder="Votre réponse..."
          />
          <button
            @click="checkFillInAnswer(exercise.id, exercise.correctAnswer)"
            class="check-btn"
          >
            Vérifier
          </button>
        </div>

        <!-- Feedback -->
        <div v-if="showAnswers[exercise.id]" class="exercise-feedback">
          <div class="feedback-result" :class="{ correct: exerciseResults[exercise.id] }">
            {{ exerciseResults[exercise.id] ? '✅ Correct !' : '❌ Incorrect' }}
          </div>
          <div v-if="exercise.explanation" class="feedback-explanation">
            💡 {{ exercise.explanation }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import type { GrammarFeedItem } from '../../services/feedService'

const props = defineProps<{
  item: GrammarFeedItem
  language: 'it' | 'es'
}>()

const showExercises = ref(false)
const selectedAnswers = ref<Record<string, number>>({})
const fillInAnswers = ref<Record<string, string>>({})
const showAnswers = ref<Record<string, boolean>>({})
const exerciseResults = ref<Record<string, boolean>>({})
const isPlaying = ref(false)

const difficultyLabel = computed(() => {
  const labels = {
    'beginner': 'Débutant',
    'intermediate': 'Intermédiaire',
    'advanced': 'Avancé'
  }
  return labels[props.item.difficulty]
})

const selectAnswer = (exerciseId: string, optionIndex: number) => {
  if (showAnswers.value[exerciseId]) return
  
  selectedAnswers.value[exerciseId] = optionIndex
  showAnswers.value[exerciseId] = true
  
  const exercise = props.item.data.exercises?.find(ex => ex.id === exerciseId)
  if (exercise && exercise.options) {
    const correctIndex = exercise.options.indexOf(exercise.correctAnswer)
    exerciseResults.value[exerciseId] = optionIndex === correctIndex
  }
}

const checkFillInAnswer = (exerciseId: string, correctAnswer: string) => {
  if (showAnswers.value[exerciseId]) return
  
  const userAnswer = fillInAnswers.value[exerciseId]?.toLowerCase().trim()
  const correct = correctAnswer.toLowerCase().trim()
  
  showAnswers.value[exerciseId] = true
  exerciseResults.value[exerciseId] = userAnswer === correct
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
  color: #6366f1;
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

.grammar-rule {
  color: #1f2937;
  font-size: 1.1rem;
  margin-bottom: 0.75rem;
  font-weight: 600;
}

.grammar-content {
  color: #4b5563;
  line-height: 1.6;
  margin-bottom: 1rem;
}

.grammar-structure {
  background: #f3f4f6;
  padding: 0.65rem;
  border-radius: 8px;
  margin-bottom: 0.75rem;
  color: #374151;
  font-size: 0.95rem;
}

.grammar-example {
  background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
  padding: 0.75rem;
  border-radius: 10px;
  margin-bottom: 0.75rem;
  position: relative;
}

.example-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  color: #4338ca;
  font-weight: 600;
}

.example-text {
  font-style: italic;
  color: #1e1b4b;
  font-size: 1.05rem;
}

.tts-btn {
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

.tts-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.95);
  transform: scale(1.1);
}

.tts-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.grammar-exceptions {
  background: #fef7ed;
  border-left: 3px solid #ea580c;
  padding: 0.75rem;
  border-radius: 0 8px 8px 0;
  margin-bottom: 0.75rem;
}

.grammar-exceptions ul {
  margin: 0.5rem 0 0 1rem;
  padding: 0;
}

.grammar-exceptions li {
  margin-bottom: 0.25rem;
  color: #9a3412;
}

.card-actions {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid #e5e7eb;
}

.practice-btn {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
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
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.4);
}

.exercises-section {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.mini-exercise {
  background: #f9fafb;
  padding: 1rem;
  border-radius: 12px;
  margin-bottom: 1rem;
}

.exercise-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.exercise-number {
  font-weight: bold;
  color: #6366f1;
}

.exercise-type-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
}

.exercise-type-badge.quiz {
  background: #e0e7ff;
  color: #4338ca;
}

.exercise-type-badge.fill-in {
  background: #ecfdf5;
  color: #065f46;
}

.exercise-question {
  font-weight: 500;
  margin-bottom: 0.75rem;
  color: #374151;
}

.quiz-options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.quiz-option {
  padding: 0.5rem;
  border: 2px solid #e5e7eb;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.quiz-option:hover {
  border-color: #6366f1;
}

.quiz-option.selected {
  border-color: #6366f1;
  background: #e0e7ff;
}

.quiz-option.correct {
  border-color: #10b981;
  background: #d1fae5;
  color: #065f46;
}

.quiz-option.incorrect {
  border-color: #ef4444;
  background: #fee2e2;
  color: #991b1b;
}

.fill-in-section {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.fill-in-input {
  flex: 1;
  padding: 0.5rem;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  font-size: 1rem;
}

.fill-in-input:focus {
  outline: none;
  border-color: #6366f1;
}

.check-btn {
  background: #6366f1;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
}

.exercise-feedback {
  margin-top: 0.75rem;
  padding: 0.75rem;
  border-radius: 8px;
  background: #f3f4f6;
}

.feedback-result.correct {
  color: #065f46;
  font-weight: 600;
}

.feedback-result:not(.correct) {
  color: #991b1b;
  font-weight: 600;
}

.feedback-explanation {
  margin-top: 0.5rem;
  color: #4b5563;
  font-style: italic;
}
</style>
