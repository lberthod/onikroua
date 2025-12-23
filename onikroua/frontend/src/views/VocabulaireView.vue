<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useLearningStore } from '../stores/learning'
import vocabularyIt from '../data/vocabulary_it.json'
import vocabularyEs from '../data/vocabulary_es.json'

const learningStore = useLearningStore()
const selectedCategory = ref<string | null>(null)
const playingWordId = ref<string | null>(null)
const activeTab = ref<'liste' | 'pratique' | 'thematique'>('liste')
const searchQuery = ref('')

onMounted(() => {
  learningStore.initDemoData()
  learningStore.setSection('vocabulaire')
})

// ===== TTS =====
const speak = (text: string, id?: string) => {
  if (playingWordId.value === id) {
    speechSynthesis.cancel()
    playingWordId.value = null
    return
  }
  
  const lang = learningStore.currentLanguage === 'it' ? 'it-IT' : 'es-ES'
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = lang
  utterance.rate = 0.85
  
  playingWordId.value = id || null
  
  utterance.onend = () => { playingWordId.value = null }
  utterance.onerror = () => { playingWordId.value = null }
  
  speechSynthesis.speak(utterance)
}

// ===== Vocabulaire enrichi =====
interface VocabWord {
  word: string
  translation: string
  gender?: 'm' | 'f'
  example?: string
  exampleTranslation?: string
}

interface VocabCategory {
  name: string
  icon: string
  words: VocabWord[]
}

const vocabularyData = computed((): VocabCategory[] => {
  const raw = learningStore.currentLanguage === 'it' ? vocabularyIt : vocabularyEs
  return raw as VocabCategory[]
})

const allWords = computed(() => {
  return vocabularyData.value.flatMap(cat => 
    cat.words.map(w => ({ ...w, category: cat.name, icon: cat.icon }))
  )
})

const categories = computed(() => vocabularyData.value.map(c => ({ name: c.name, icon: c.icon })))

const filteredVocabulary = computed(() => {
  let words = allWords.value
  
  if (selectedCategory.value) {
    words = words.filter(w => w.category === selectedCategory.value)
  }
  
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase().trim()
    words = words.filter(w => 
      w.word.toLowerCase().includes(query) || 
      w.translation.toLowerCase().includes(query)
    )
  }
  
  return words
})

const languageLabel = computed(() => 
  learningStore.currentLanguage === 'it' ? '🇮🇹 Italien' : '🇪🇸 Espagnol'
)

// ===== Mode Pratique =====
const practiceMode = ref<'choice' | 'write' | 'listen'>('choice')
const practiceWord = ref<VocabWord | null>(null)
const practiceCategory = ref<string | null>(null)
const practiceAnswer = ref('')
const practiceResult = ref<'correct' | 'wrong' | null>(null)
const practiceScore = ref(0)
const practiceTotal = ref(0)
const practiceStreak = ref(0)
const practiceDirection = ref<'toFr' | 'fromFr'>('toFr')

const practiceWords = computed(() => {
  if (practiceCategory.value) {
    return allWords.value.filter(w => w.category === practiceCategory.value)
  }
  return allWords.value
})

const practiceChoices = computed(() => {
  if (!practiceWord.value) return []
  
  const correct = practiceDirection.value === 'toFr' 
    ? practiceWord.value.translation 
    : practiceWord.value.word
  
  const otherWords = practiceWords.value
    .filter(w => w.word !== practiceWord.value?.word)
    .map(w => practiceDirection.value === 'toFr' ? w.translation : w.word)
  
  const shuffled = otherWords.sort(() => Math.random() - 0.5).slice(0, 3)
  return [...shuffled, correct].sort(() => Math.random() - 0.5)
})

const correctPracticeAnswer = computed(() => {
  if (!practiceWord.value) return ''
  return practiceDirection.value === 'toFr' 
    ? practiceWord.value.translation 
    : practiceWord.value.word
})

const generatePracticeQuestion = () => {
  practiceResult.value = null
  practiceAnswer.value = ''
  
  const words = practiceWords.value
  if (words.length === 0) return
  
  practiceWord.value = words[Math.floor(Math.random() * words.length)]
  
  if (practiceMode.value === 'listen') {
    setTimeout(() => {
      if (practiceWord.value) {
        speak(practiceWord.value.word, 'practice')
      }
    }, 300)
  }
}

const checkPracticeAnswer = (answer: string) => {
  practiceTotal.value++
  const correct = correctPracticeAnswer.value.toLowerCase().trim()
  const isCorrect = answer.toLowerCase().trim() === correct
  
  if (isCorrect) {
    practiceResult.value = 'correct'
    practiceScore.value++
    practiceStreak.value++
    speak(practiceWord.value?.word || '')
  } else {
    practiceResult.value = 'wrong'
    practiceStreak.value = 0
  }
}

const submitWriteAnswer = () => {
  if (!practiceAnswer.value.trim()) return
  checkPracticeAnswer(practiceAnswer.value)
}

const resetPractice = () => {
  practiceScore.value = 0
  practiceTotal.value = 0
  practiceStreak.value = 0
  generatePracticeQuestion()
}

watch(activeTab, (newTab) => {
  if (newTab === 'pratique' && !practiceWord.value) {
    generatePracticeQuestion()
  }
})

watch(() => learningStore.currentLanguage, () => {
  if (activeTab.value === 'pratique') {
    resetPractice()
  }
})

watch(practiceCategory, () => {
  if (activeTab.value === 'pratique') {
    generatePracticeQuestion()
  }
})
</script>

<template>
  <div class="section-container">
    <header class="section-header">
      <h1>📚 Vocabulaire</h1>
      <p class="section-subtitle">Enrichissez votre vocabulaire en {{ languageLabel }} - {{ allWords.length }} mots</p>
      
      <div class="language-toggle">
        <button 
          :class="['lang-btn', { active: learningStore.currentLanguage === 'it' }]"
          @click="learningStore.setLanguage('it')"
        >
          🇮🇹 Italien
        </button>
        <button 
          :class="['lang-btn', { active: learningStore.currentLanguage === 'es' }]"
          @click="learningStore.setLanguage('es')"
        >
          🇪🇸 Espagnol
        </button>
      </div>
    </header>

    <!-- Tabs -->
    <div class="tabs">
      <button 
        :class="['tab-btn', { active: activeTab === 'liste' }]"
        @click="activeTab = 'liste'"
      >
        📖 Liste
      </button>
      <button 
        :class="['tab-btn', { active: activeTab === 'thematique' }]"
        @click="activeTab = 'thematique'"
      >
        📂 Thématique
      </button>
      <button 
        :class="['tab-btn practice-tab', { active: activeTab === 'pratique' }]"
        @click="activeTab = 'pratique'"
      >
        🎮 Pratique
      </button>
    </div>

    <!-- Tab: Liste -->
    <div v-if="activeTab === 'liste'" class="tab-content">
      <!-- Search -->
      <div class="search-bar">
        <input 
          v-model="searchQuery" 
          type="text" 
          placeholder="🔍 Rechercher un mot..."
          class="search-input"
        />
      </div>

      <!-- Category filter -->
      <div class="category-filter">
        <button 
          :class="['category-btn', { active: !selectedCategory }]"
          @click="selectedCategory = null"
        >
          📋 Tous ({{ allWords.length }})
        </button>
        <button 
          v-for="cat in categories" 
          :key="cat.name"
          :class="['category-btn', { active: selectedCategory === cat.name }]"
          @click="selectedCategory = cat.name"
        >
          {{ cat.icon }} {{ cat.name }}
        </button>
      </div>

      <!-- Vocabulary grid -->
      <div class="vocabulary-grid">
        <div 
          v-for="(word, index) in filteredVocabulary" 
          :key="`${word.word}-${index}`" 
          class="vocabulary-card card"
        >
          <div class="word-header">
            <div class="word-content">
              <span class="word">{{ word.word }}</span>
              <span v-if="word.gender" class="gender">{{ word.gender === 'm' ? '(m)' : '(f)' }}</span>
            </div>
            <button 
              class="speak-btn"
              :class="{ playing: playingWordId === `word-${index}` }"
              @click="speak(word.word, `word-${index}`)"
              title="Écouter"
            >
              {{ playingWordId === `word-${index}` ? '⏹️' : '🔊' }}
            </button>
          </div>
          <div class="translation">{{ word.translation }}</div>
          <div class="category-tag">{{ word.icon }} {{ word.category }}</div>
          <div v-if="word.example" class="example">
            <div class="example-text">{{ word.example }}</div>
            <div v-if="word.exampleTranslation" class="example-translation">{{ word.exampleTranslation }}</div>
            <button 
              class="speak-example-btn"
              @click="speak(word.example, `example-${index}`)"
              title="Écouter l'exemple"
            >
              🔈
            </button>
          </div>
        </div>
      </div>

      <div v-if="filteredVocabulary.length === 0" class="empty-state">
        <p>Aucun mot trouvé pour "{{ searchQuery }}"</p>
      </div>
    </div>

    <!-- Tab: Thématique -->
    <div v-if="activeTab === 'thematique'" class="tab-content">
      <div class="thematic-grid">
        <div 
          v-for="category in vocabularyData" 
          :key="category.name" 
          class="thematic-card card"
        >
          <div class="thematic-header">
            <span class="thematic-icon">{{ category.icon }}</span>
            <h3>{{ category.name }}</h3>
            <span class="word-count">{{ category.words.length }} mots</span>
          </div>
          <div class="thematic-words">
            <div 
              v-for="(word, idx) in category.words.slice(0, 6)" 
              :key="idx"
              class="thematic-word"
              @click="speak(word.word)"
            >
              <span class="tw-word">{{ word.word }}</span>
              <span class="tw-trans">{{ word.translation }}</span>
              <span class="tw-audio">🔊</span>
            </div>
            <div v-if="category.words.length > 6" class="more-words">
              +{{ category.words.length - 6 }} autres mots
            </div>
          </div>
          <button 
            class="view-all-btn"
            @click="selectedCategory = category.name; activeTab = 'liste'"
          >
            Voir tout →
          </button>
        </div>
      </div>
    </div>

    <!-- Tab: Pratique -->
    <div v-if="activeTab === 'pratique'" class="tab-content">
      <!-- Stats -->
      <div class="practice-stats">
        <div class="stat-card">
          <span class="stat-value">{{ practiceScore }}</span>
          <span class="stat-label">Correct</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ practiceTotal }}</span>
          <span class="stat-label">Total</span>
        </div>
        <div class="stat-card streak">
          <span class="stat-value">🔥 {{ practiceStreak }}</span>
          <span class="stat-label">Série</span>
        </div>
        <div class="stat-card accuracy">
          <span class="stat-value">{{ practiceTotal > 0 ? Math.round((practiceScore / practiceTotal) * 100) : 0 }}%</span>
          <span class="stat-label">Précision</span>
        </div>
      </div>

      <!-- Practice settings -->
      <div class="practice-settings">
        <div class="setting-group">
          <label>Catégorie :</label>
          <select v-model="practiceCategory" class="setting-select">
            <option :value="null">Toutes</option>
            <option v-for="cat in categories" :key="cat.name" :value="cat.name">
              {{ cat.icon }} {{ cat.name }}
            </option>
          </select>
        </div>
        <div class="setting-group">
          <label>Mode :</label>
          <select v-model="practiceMode" class="setting-select">
            <option value="choice">Choix multiples</option>
            <option value="write">Écriture</option>
            <option value="listen">Écoute</option>
          </select>
        </div>
        <div class="setting-group">
          <label>Direction :</label>
          <select v-model="practiceDirection" class="setting-select">
            <option value="toFr">{{ learningStore.currentLanguage === 'it' ? 'Italien' : 'Espagnol' }} → Français</option>
            <option value="fromFr">Français → {{ learningStore.currentLanguage === 'it' ? 'Italien' : 'Espagnol' }}</option>
          </select>
        </div>
      </div>

      <!-- Question -->
      <div v-if="practiceWord" class="practice-card card">
        <div class="practice-question">
          <div class="question-word">
            <span v-if="practiceMode !== 'listen'">
              {{ practiceDirection === 'toFr' ? practiceWord.word : practiceWord.translation }}
            </span>
            <span v-else class="listen-prompt">🎧 Écoutez et traduisez</span>
            <button 
              v-if="practiceDirection === 'toFr' || practiceMode === 'listen'"
              class="audio-btn-practice"
              @click="speak(practiceWord.word, 'practice')"
              :class="{ playing: playingWordId === 'practice' }"
            >
              🔊
            </button>
          </div>
        </div>

        <!-- Choices -->
        <div v-if="practiceMode === 'choice'" class="practice-choices">
          <button
            v-for="(choice, idx) in practiceChoices"
            :key="idx"
            class="choice-btn"
            :class="{
              correct: practiceResult && choice === correctPracticeAnswer,
              wrong: practiceResult === 'wrong' && choice !== correctPracticeAnswer,
              disabled: practiceResult !== null
            }"
            :disabled="practiceResult !== null"
            @click="checkPracticeAnswer(choice)"
          >
            {{ choice }}
          </button>
        </div>

        <!-- Write mode -->
        <div v-else class="practice-write">
          <input
            v-model="practiceAnswer"
            type="text"
            class="write-input"
            :placeholder="practiceDirection === 'toFr' ? 'Traduction en français...' : (learningStore.currentLanguage === 'it' ? 'Traduction en italien...' : 'Traduction en espagnol...')"
            :disabled="practiceResult !== null"
            @keyup.enter="submitWriteAnswer"
          />
          <button 
            class="submit-btn"
            :disabled="!practiceAnswer.trim() || practiceResult !== null"
            @click="submitWriteAnswer"
          >
            Valider
          </button>
        </div>

        <!-- Result -->
        <div v-if="practiceResult" class="practice-result" :class="practiceResult">
          <div v-if="practiceResult === 'correct'" class="result-message">
            ✅ Correct ! 
            <span v-if="practiceStreak >= 3">🔥 Série de {{ practiceStreak }} !</span>
          </div>
          <div v-else class="result-message">
            ❌ La réponse était : <strong>{{ correctPracticeAnswer }}</strong>
            <button class="audio-btn-inline" @click="speak(practiceWord.word)">🔊</button>
          </div>
          <button class="next-btn" @click="generatePracticeQuestion">
            Question suivante →
          </button>
        </div>
      </div>

      <div class="practice-actions">
        <button class="reset-btn" @click="resetPractice">
          🔄 Recommencer
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.section-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.section-header {
  text-align: center;
  margin-bottom: 2rem;
}

.section-header h1 {
  font-size: 2rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.section-subtitle {
  color: #7f8c8d;
  margin-bottom: 1.5rem;
}

.language-toggle {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.lang-btn {
  padding: 0.75rem 1.5rem;
  border: 2px solid #ddd;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.lang-btn:hover {
  border-color: #3498db;
}

.lang-btn.active {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

/* Tabs */
.tabs {
  display: flex;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.tab-btn {
  padding: 0.75rem 1.25rem;
  border: none;
  background: #f0f0f0;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 500;
  transition: all 0.2s;
}

.tab-btn:hover {
  background: #e0e0e0;
}

.tab-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.tab-btn.practice-tab.active {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
}

.tab-content {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Search */
.search-bar {
  margin-bottom: 1.5rem;
}

.search-input {
  width: 100%;
  padding: 1rem 1.25rem;
  border: 2px solid #e0e0e0;
  border-radius: 25px;
  font-size: 1rem;
  transition: all 0.2s;
}

.search-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

/* Category filter */
.category-filter {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
}

.category-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  background: white;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.category-btn:hover {
  background: #f8f9fa;
  border-color: #667eea;
}

.category-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
}

/* Vocabulary grid */
.vocabulary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1rem;
}

.vocabulary-card {
  padding: 1.25rem;
  transition: all 0.2s;
}

.vocabulary-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.1);
}

.word-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.word-content {
  flex: 1;
}

.word {
  font-size: 1.4rem;
  font-weight: 600;
  color: #2c3e50;
}

.gender {
  color: #7f8c8d;
  font-size: 0.85rem;
  margin-left: 0.25rem;
}

.translation {
  color: #667eea;
  font-size: 1.1rem;
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.category-tag {
  display: inline-block;
  background: #f0f4ff;
  color: #667eea;
  padding: 0.25rem 0.75rem;
  border-radius: 15px;
  font-size: 0.8rem;
  margin-bottom: 0.75rem;
}

.example {
  font-size: 0.9rem;
  padding-top: 0.75rem;
  border-top: 1px solid #eee;
  position: relative;
}

.example-text {
  color: #555;
  font-style: italic;
  margin-bottom: 0.25rem;
}

.example-translation {
  color: #7f8c8d;
  font-size: 0.85rem;
}

/* TTS buttons */
.speak-btn, .speak-example-btn {
  background: #f0f0f0;
  border: none;
  cursor: pointer;
  font-size: 1.1rem;
  padding: 0.4rem;
  border-radius: 50%;
  transition: all 0.2s;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.speak-btn:hover, .speak-example-btn:hover {
  background: #667eea;
  transform: scale(1.1);
}

.speak-btn.playing {
  background: #667eea;
  animation: pulse 1s infinite;
}

.speak-example-btn {
  font-size: 0.9rem;
  width: 28px;
  height: 28px;
  position: absolute;
  right: 0;
  top: 0.75rem;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

/* Thematic view */
.thematic-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.thematic-card {
  padding: 1.5rem;
  transition: all 0.2s;
}

.thematic-card:hover {
  transform: translateY(-3px);
}

.thematic-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid #f0f0f0;
}

.thematic-icon {
  font-size: 2rem;
}

.thematic-header h3 {
  flex: 1;
  margin: 0;
  color: #2c3e50;
  font-size: 1.1rem;
}

.word-count {
  background: #f0f4ff;
  color: #667eea;
  padding: 0.25rem 0.6rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.thematic-words {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.thematic-word {
  display: flex;
  align-items: center;
  padding: 0.5rem 0.75rem;
  background: #f8f9fa;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.thematic-word:hover {
  background: #e8f4fc;
  transform: translateX(5px);
}

.tw-word {
  font-weight: 600;
  color: #2c3e50;
  flex: 1;
}

.tw-trans {
  color: #7f8c8d;
  font-size: 0.9rem;
  margin-right: 0.5rem;
}

.tw-audio {
  font-size: 0.85rem;
  opacity: 0.5;
}

.thematic-word:hover .tw-audio {
  opacity: 1;
}

.more-words {
  text-align: center;
  color: #7f8c8d;
  font-size: 0.85rem;
  padding: 0.5rem;
}

.view-all-btn {
  width: 100%;
  padding: 0.75rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.2s;
}

.view-all-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* Practice mode */
.practice-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 1rem;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.stat-card.streak {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
  color: white;
}

.stat-card.accuracy {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.stat-value {
  display: block;
  font-size: 1.5rem;
  font-weight: 700;
}

.stat-label {
  font-size: 0.8rem;
  opacity: 0.8;
}

.practice-settings {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 12px;
}

.setting-group {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.setting-group label {
  font-size: 0.9rem;
  color: #666;
}

.setting-select {
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 0.9rem;
  background: white;
  cursor: pointer;
}

.practice-card {
  padding: 2rem;
  text-align: center;
  margin-bottom: 1.5rem;
}

.practice-question {
  margin-bottom: 2rem;
}

.question-word {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
}

.listen-prompt {
  color: #667eea;
}

.audio-btn-practice {
  background: #f0f0f0;
  border: none;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  cursor: pointer;
  font-size: 1.5rem;
  transition: all 0.2s;
}

.audio-btn-practice:hover {
  background: #667eea;
  transform: scale(1.1);
}

.audio-btn-practice.playing {
  background: #667eea;
  animation: pulse 1s infinite;
}

.practice-choices {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  max-width: 500px;
  margin: 0 auto;
}

.choice-btn {
  padding: 1rem 1.5rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 12px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: all 0.2s;
}

.choice-btn:hover:not(:disabled) {
  border-color: #667eea;
  transform: translateY(-2px);
}

.choice-btn.correct {
  background: #d4edda;
  border-color: #28a745;
  color: #155724;
}

.choice-btn.wrong {
  opacity: 0.5;
}

.choice-btn.disabled {
  cursor: default;
}

.practice-write {
  display: flex;
  gap: 1rem;
  max-width: 400px;
  margin: 0 auto;
}

.write-input {
  flex: 1;
  padding: 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  font-size: 1rem;
  text-align: center;
}

.write-input:focus {
  outline: none;
  border-color: #667eea;
}

.submit-btn {
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.2s;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
}

.submit-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.practice-result {
  margin-top: 1.5rem;
  padding: 1.5rem;
  border-radius: 12px;
}

.practice-result.correct {
  background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
}

.practice-result.wrong {
  background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
}

.result-message {
  font-size: 1.2rem;
  margin-bottom: 1rem;
}

.audio-btn-inline {
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 1rem;
}

.next-btn {
  padding: 0.75rem 2rem;
  background: #2c3e50;
  color: white;
  border: none;
  border-radius: 25px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.next-btn:hover {
  background: #1a252f;
  transform: translateY(-2px);
}

.practice-actions {
  text-align: center;
}

.reset-btn {
  padding: 0.75rem 1.5rem;
  background: #f0f0f0;
  border: none;
  border-radius: 25px;
  cursor: pointer;
  font-size: 0.95rem;
  transition: all 0.2s;
}

.reset-btn:hover {
  background: #e0e0e0;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #7f8c8d;
}

/* Responsive */
@media (max-width: 768px) {
  .section-container {
    padding: 1.5rem 0.75rem;
  }
  
  .tabs {
    gap: 0.25rem;
  }
  
  .tab-btn {
    padding: 0.6rem 0.75rem;
    font-size: 0.85rem;
  }
  
  .practice-stats {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .practice-choices {
    grid-template-columns: 1fr;
  }
  
  .question-word {
    font-size: 1.5rem;
  }
  
  .practice-settings {
    flex-direction: column;
    align-items: stretch;
  }
  
  .setting-group {
    justify-content: space-between;
  }
  
  .thematic-grid {
    grid-template-columns: 1fr;
  }
  
  .vocabulary-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  }
}

@media (max-width: 480px) {
  .section-container {
    padding: 1rem 0.5rem;
  }
  
  .language-toggle {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .tabs {
    flex-direction: column;
  }
  
  .tab-btn {
    width: 100%;
  }
  
  .vocabulary-grid {
    grid-template-columns: 1fr;
  }
  
  .word {
    font-size: 1.2rem;
  }
  
  .practice-write {
    flex-direction: column;
  }
  
  .practice-stats {
    gap: 0.5rem;
  }
  
  .stat-card {
    padding: 0.75rem;
  }
  
  .stat-value {
    font-size: 1.2rem;
  }
}
</style>
