<template>
  <div class="feed-card vocabulary-card">
    <div class="card-header">
      <div class="card-type">
        <span class="type-icon">📚</span>
        <span class="type-label">Vocabulaire</span>
      </div>
      <div class="difficulty-badge" :class="item.difficulty">
        {{ difficultyLabel }}
      </div>
    </div>

    <div class="card-content">
      <div class="vocabulary-header">
        <div class="category-info">
          <span class="category-icon">{{ item.data.categoryIcon }}</span>
          <span class="category-name">{{ item.data.category }}</span>
        </div>
        <div v-if="item.data.gender" class="gender-badge" :class="item.data.gender">
          {{ item.data.gender === 'm' ? '♂️ masculin' : '♀️ féminin' }}
        </div>
      </div>

      <div class="word-display">
        <div class="main-word">
          {{ item.data.word }}
          <button 
            @click="playText(item.data.word)"
            class="word-tts-btn"
            :disabled="isPlaying"
          >
            🔊
          </button>
        </div>
        <div class="translation">{{ item.data.translation }}</div>
      </div>

      <div v-if="item.data.example" class="vocabulary-example">
        <div class="example-header">
          <span class="example-icon">💡</span>
          <strong>Exemple :</strong>
        </div>
        <div class="example-text">
          <div class="original">{{ item.data.example }}</div>
          <div v-if="item.data.exampleTranslation" class="translated">
            {{ item.data.exampleTranslation }}
          </div>
        </div>
        <button 
          @click="playText(item.data.example)"
          class="example-tts-btn"
          :disabled="isPlaying"
        >
          🔊
        </button>
      </div>
    </div>

    <div class="card-actions">
      <button @click="startQuiz" class="quiz-btn">
        <span class="btn-icon">🎯</span>
        Tester ce mot
      </button>
      <button @click="showMemoryTip = !showMemoryTip" class="memory-btn">
        <span class="btn-icon">💡</span>
        Astuce mémoire
      </button>
    </div>

    <!-- Quiz rapide -->
    <div v-if="showQuiz" class="quick-quiz">
      <div class="quiz-header">
        <h4>Quiz rapide</h4>
        <button @click="showQuiz = false" class="close-btn">×</button>
      </div>
      
      <div class="quiz-question">
        Comment dit-on "{{ item.data.translation }}" en {{ languageLabel.toLowerCase() }} ?
      </div>
      
      <div class="quiz-options">
        <button
          v-for="(option, index) in quizOptions"
          :key="index"
          @click="selectQuizAnswer(index)"
          :class="[
            'quiz-option',
            {
              'selected': selectedAnswer === index,
              'correct': showQuizAnswer && index === correctAnswerIndex,
              'incorrect': showQuizAnswer && selectedAnswer === index && index !== correctAnswerIndex
            }
          ]"
        >
          {{ option }}
        </button>
      </div>

      <div v-if="showQuizAnswer" class="quiz-feedback">
        <div class="feedback-result" :class="{ correct: quizResult }">
          {{ quizResult ? '✅ Excellent !' : '❌ Pas tout à fait' }}
        </div>
        <div class="feedback-explanation">
          La bonne réponse est : <strong>{{ item.data.word }}</strong>
        </div>
      </div>
    </div>

    <!-- Astuce mémoire -->
    <div v-if="showMemoryTip" class="memory-tip">
      <div class="tip-header">
        <span class="tip-icon">🧠</span>
        <strong>Astuce pour retenir :</strong>
      </div>
      <div class="tip-content">
        {{ generateMemoryTip() }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import type { VocabularyFeedItem } from '../../services/feedService'

const props = defineProps<{
  item: VocabularyFeedItem
  language: 'it' | 'es'
}>()

const showQuiz = ref(false)
const showMemoryTip = ref(false)
const selectedAnswer = ref<number | null>(null)
const showQuizAnswer = ref(false)
const quizResult = ref(false)
const isPlaying = ref(false)
const quizOptions = ref<string[]>([])
const correctAnswerIndex = ref(0)

const difficultyLabel = computed(() => {
  const labels = {
    'beginner': 'Débutant',
    'intermediate': 'Intermédiaire',
    'advanced': 'Avancé'
  }
  return labels[props.item.difficulty]
})

const languageLabel = computed(() => 
  props.language === 'it' ? 'Italien' : 'Espagnol'
)

const generateQuizOptions = () => {
  const correctAnswer = props.item.data.word
  const similarWords = generateSimilarWords(correctAnswer)
  
  const options = [correctAnswer, ...similarWords.slice(0, 3)]
  
  // Mélanger les options
  for (let i = options.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[options[i], options[j]] = [options[j], options[i]]
  }
  
  correctAnswerIndex.value = options.indexOf(correctAnswer)
  quizOptions.value = options
}

const generateSimilarWords = (word: string): string[] => {
  // Générer des mots similaires pour rendre le quiz plus réaliste
  const variations = []
  
  // Variations basées sur la langue
  if (props.language === 'it') {
    const endings = ['a', 'o', 'e', 'i']
    const base = word.slice(0, -1)
    endings.forEach(ending => {
      if (base + ending !== word) {
        variations.push(base + ending)
      }
    })
  } else {
    const endings = ['a', 'o', 'e', 'ar', 'er', 'ir']
    const base = word.length > 3 ? word.slice(0, -2) : word.slice(0, -1)
    endings.forEach(ending => {
      if (base + ending !== word) {
        variations.push(base + ending)
      }
    })
  }
  
  // Ajouter quelques variations supplémentaires
  variations.push(word + 's', word.slice(0, -1) + 'i', word + 'a')
  
  return variations.filter(v => v !== word && v.length > 1)
}

const startQuiz = () => {
  showQuiz.value = true
  selectedAnswer.value = null
  showQuizAnswer.value = false
  generateQuizOptions()
}

const selectQuizAnswer = (index: number) => {
  if (showQuizAnswer.value) return
  
  selectedAnswer.value = index
  showQuizAnswer.value = true
  quizResult.value = index === correctAnswerIndex.value
}

const generateMemoryTip = () => {
  const word = props.item.data.word
  const translation = props.item.data.translation
  
  const tips = [
    `"${word}" ressemble à "${translation}" - cherchez les sonorités communes !`,
    `Visualisez "${translation}" quand vous entendez "${word}"`,
    `"${word}" commence par "${word[0]}" comme "${translation[0] || 'le premier son'}"`,
    `Associez "${word}" à une image mentale de "${translation}"`,
    `Répétez "${word}" 3 fois en pensant à "${translation}"`
  ]
  
  return tips[Math.floor(Math.random() * tips.length)]
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

// Reset quiz when item changes
watch(() => props.item.id, () => {
  showQuiz.value = false
  showMemoryTip.value = false
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
  color: #059669;
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

.vocabulary-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.category-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: #f0fdf4;
  padding: 0.5rem 0.75rem;
  border-radius: 20px;
  color: #166534;
  font-size: 0.9rem;
}

.gender-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 8px;
  font-size: 0.75rem;
  font-weight: 600;
}

.gender-badge.m {
  background: #dbeafe;
  color: #1e40af;
}

.gender-badge.f {
  background: #fce7f3;
  color: #be185d;
}

.word-display {
  text-align: center;
  margin: 1rem 0;
  position: relative;
}

.main-word {
  font-size: 1.75rem;
  font-weight: bold;
  color: #059669;
  margin-bottom: 0.4rem;
  position: relative;
  display: inline-block;
}

.word-tts-btn {
  position: absolute;
  top: -0.5rem;
  right: -2rem;
  background: rgba(5, 150, 105, 0.1);
  border: 2px solid #059669;
  border-radius: 50%;
  width: 2rem;
  height: 2rem;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.word-tts-btn:hover:not(:disabled) {
  background: #059669;
  transform: scale(1.1);
}

.word-tts-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.translation {
  font-size: 1.2rem;
  color: #6b7280;
  font-style: italic;
}

.vocabulary-example {
  background: linear-gradient(135deg, #ecfdf5, #d1fae5);
  padding: 0.75rem;
  border-radius: 10px;
  margin: 0.75rem 0;
  position: relative;
}

.example-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  color: #065f46;
  font-weight: 600;
}

.example-text .original {
  font-style: italic;
  color: #064e3b;
  font-size: 1.05rem;
  margin-bottom: 0.25rem;
}

.example-text .translated {
  color: #6b7280;
  font-size: 0.9rem;
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

.card-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid #e5e7eb;
}

.quiz-btn, .memory-btn {
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
  min-height: 48px;
}

.quiz-btn {
  background: linear-gradient(135deg, #059669, #10b981);
  color: white;
}

.quiz-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(5, 150, 105, 0.4);
}

.memory-btn {
  background: linear-gradient(135deg, #f59e0b, #f97316);
  color: white;
}

.memory-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(245, 158, 11, 0.4);
}

.quick-quiz {
  margin-top: 1rem;
  padding: 1rem;
  background: #f9fafb;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
}

.quiz-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.quiz-header h4 {
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

.quiz-question {
  margin-bottom: 1rem;
  font-weight: 500;
  color: #374151;
}

.quiz-options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.quiz-option {
  padding: 0.75rem;
  border: 2px solid #e5e7eb;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.quiz-option:hover {
  border-color: #059669;
}

.quiz-option.selected {
  border-color: #059669;
  background: #ecfdf5;
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

.feedback-explanation {
  margin-top: 0.5rem;
  color: #4b5563;
}

.memory-tip {
  margin-top: 0.75rem;
  padding: 0.75rem;
  background: linear-gradient(135deg, #fef3c7, #fde68a);
  border-radius: 10px;
  border-left: 3px solid #f59e0b;
}

.tip-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  color: #92400e;
  font-weight: 600;
}

.tip-content {
  color: #78350f;
  line-height: 1.5;
}
</style>
