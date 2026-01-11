<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import dictionaryData from '../data/dictionary.json'

interface DictionaryWord {
  it: string
  fr: string
  es: string
  category: string
}

const selectedLanguage = ref<'it-fr' | 'fr-it' | 'es-fr' | 'fr-es'>('it-fr')
const selectedLetter = ref<string>('')
const currentPage = ref(1)
const searchQuery = ref('')
const itemsPerPage = 50

const alphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

const allWords = ref<DictionaryWord[]>(dictionaryData.words)

const filteredWords = computed(() => {
  let words = allWords.value
  
  // Filtrer par recherche
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase()
    words = words.filter(w => 
      w.it.toLowerCase().includes(query) ||
      w.fr.toLowerCase().includes(query) ||
      w.es.toLowerCase().includes(query)
    )
  }
  
  // Filtrer par lettre selon la langue source
  if (!searchQuery.value.trim()) {
    const sourceLang = selectedLanguage.value.split('-')[0] as 'it' | 'fr' | 'es'
    words = words.filter(w => 
      w[sourceLang].toLowerCase().startsWith(selectedLetter.value.toLowerCase())
    )
  }
  
  return words
})

const totalPages = computed(() => {
  return Math.ceil(filteredWords.value.length / itemsPerPage)
})

const paginatedWords = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredWords.value.slice(start, end)
})

const changeLetter = (letter: string) => {
  selectedLetter.value = letter
  currentPage.value = 1
  searchQuery.value = ''
}

const changeLanguage = (lang: 'it-fr' | 'fr-it' | 'es-fr' | 'fr-es') => {
  selectedLanguage.value = lang
  currentPage.value = 1
}

const goToPage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}

const handleSearch = () => {
  currentPage.value = 1
}

const speakWord = (word: string, lang: 'it' | 'es') => {
  if ('speechSynthesis' in window) {
    window.speechSynthesis.cancel()
    const utterance = new SpeechSynthesisUtterance(word)
    utterance.lang = lang === 'it' ? 'it-IT' : 'es-ES'
    utterance.rate = 0.8
    window.speechSynthesis.speak(utterance)
  }
}

const getSourceWord = (word: DictionaryWord): string => {
  const sourceLang = selectedLanguage.value.split('-')[0] as 'it' | 'fr' | 'es'
  return word[sourceLang]
}

const getTargetWord = (word: DictionaryWord): string => {
  const targetLang = selectedLanguage.value.split('-')[1] as 'it' | 'fr' | 'es'
  return word[targetLang]
}

const visiblePages = computed(() => {
  const pages: number[] = []
  const maxVisible = 7
  
  if (totalPages.value <= maxVisible) {
    for (let i = 1; i <= totalPages.value; i++) {
      pages.push(i)
    }
  } else {
    const halfVisible = Math.floor(maxVisible / 2)
    let startPage = currentPage.value - halfVisible
    let endPage = currentPage.value + halfVisible
    
    if (startPage < 1) {
      startPage = 1
      endPage = maxVisible
    }
    
    if (endPage > totalPages.value) {
      endPage = totalPages.value
      startPage = totalPages.value - maxVisible + 1
    }
    
    for (let i = startPage; i <= endPage; i++) {
      pages.push(i)
    }
  }
  
  return pages
})

onMounted(() => {
  // Initial load
})
</script>

<template>
  <div class="dictionary-container">
    <div class="dictionary-header">
      <h1>📖 Dictionnaire Multilingue</h1>
      <p class="subtitle">{{ filteredWords.length }} mots disponibles</p>
    </div>

    <!-- Language Selector -->
    <div class="language-selector">
      <button @click="changeLanguage('it-fr')" class="lang-btn" :class="{ active: selectedLanguage === 'it-fr' }">
        🇮🇹 Italien → 🇫🇷 Français
      </button>
      <button @click="changeLanguage('fr-it')" class="lang-btn" :class="{ active: selectedLanguage === 'fr-it' }">
        🇫🇷 Français → 🇮🇹 Italien
      </button>
      <button @click="changeLanguage('es-fr')" class="lang-btn" :class="{ active: selectedLanguage === 'es-fr' }">
        🇪🇸 Espagnol → 🇫🇷 Français
      </button>
      <button @click="changeLanguage('fr-es')" class="lang-btn" :class="{ active: selectedLanguage === 'fr-es' }">
        🇫🇷 Français → 🇪🇸 Espagnol
      </button>
    </div>

    <!-- Search Bar -->
    <div class="search-bar">
      <input
        v-model="searchQuery"
        @input="handleSearch"
        type="text"
        placeholder="Rechercher un mot..."
        class="search-input"
      />
    </div>

    <!-- Alphabet Navigation -->
    <div v-if="!searchQuery" class="alphabet-nav">
      <button
        v-for="letter in alphabet"
        :key="letter"
        @click="changeLetter(letter)"
        class="letter-btn"
        :class="{ active: selectedLetter === letter }"
      >
        {{ letter }}
      </button>
    </div>

    <!-- Results Info -->
    <div class="results-info">
      <span v-if="searchQuery">
        {{ filteredWords.length }} résultat(s) pour "{{ searchQuery }}"
      </span>
      <span v-else>
        Lettre {{ selectedLetter }} : {{ filteredWords.length }} mot(s)
      </span>
      <span class="page-info">Page {{ currentPage }} / {{ totalPages }}</span>
    </div>

    <!-- Words List -->
    <div class="words-list">
      <div v-for="word in paginatedWords" :key="getSourceWord(word)" class="word-item">
        <div class="word-source">
          <span class="word-text">{{ getSourceWord(word) }}</span>
          <button 
            v-if="selectedLanguage.startsWith('it') || selectedLanguage.startsWith('es')"
            @click="speakWord(getSourceWord(word), selectedLanguage.split('-')[0] as 'it' | 'es')" 
            class="audio-btn-inline"
            title="Écouter"
          >
            🔊
          </button>
        </div>
        <div class="word-arrow">→</div>
        <div class="word-target">
          <span class="word-text">{{ getTargetWord(word) }}</span>
          <span class="word-category">{{ word.category }}</span>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="pagination">
      <button 
        @click="goToPage(1)" 
        :disabled="currentPage === 1"
        class="page-btn"
      >
        «« Première
      </button>
      <button 
        @click="goToPage(currentPage - 1)" 
        :disabled="currentPage === 1"
        class="page-btn"
      >
        « Précédent
      </button>
      
      <div class="page-numbers">
        <button
          v-for="page in visiblePages"
          :key="page"
          @click="goToPage(page)"
          class="page-number"
          :class="{ active: currentPage === page }"
        >
          {{ page }}
        </button>
      </div>
      
      <button 
        @click="goToPage(currentPage + 1)" 
        :disabled="currentPage === totalPages"
        class="page-btn"
      >
        Suivant »
      </button>
      <button 
        @click="goToPage(totalPages)" 
        :disabled="currentPage === totalPages"
        class="page-btn"
      >
        Dernière »»
      </button>
    </div>
  </div>
</template>

<style scoped>
.dictionary-container {
  min-height: calc(100vh - 56px);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1.5rem;
  padding-bottom: 3rem;
}

.dictionary-header {
  text-align: center;
  color: white;
  margin-bottom: 1.75rem;
}

.dictionary-header h1 {
  font-size: 1.75rem;
  margin-bottom: 0.4rem;
  font-weight: 600;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.subtitle {
  font-size: 0.95rem;
  opacity: 0.9;
}

/* Language Selector */
.language-selector {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
  flex-wrap: wrap;
  margin-bottom: 1.5rem;
  max-width: 900px;
  margin-left: auto;
  margin-right: auto;
}

.lang-btn {
  padding: 0.55rem 1rem;
  background: rgba(255, 255, 255, 0.15);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
}

.lang-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-1px);
}

.lang-btn.active {
  background: white;
  color: #667eea;
  border-color: white;
}

/* Search Bar */
.search-bar {
  max-width: 700px;
  margin: 0 auto 1.5rem;
}

.search-input {
  width: 100%;
  padding: 0.85rem 1.25rem;
  border: none;
  border-radius: 10px;
  font-size: 0.95rem;
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.2s;
}

.search-input:focus {
  outline: none;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transform: translateY(-1px);
}

/* Alphabet Navigation */
.alphabet-nav {
  display: flex;
  gap: 0.35rem;
  flex-wrap: wrap;
  justify-content: center;
  margin-bottom: 1.5rem;
  max-width: 900px;
  margin-left: auto;
  margin-right: auto;
}

.letter-btn {
  width: 32px;
  height: 32px;
  padding: 0;
  background: rgba(255, 255, 255, 0.15);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.letter-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-1px);
}

.letter-btn.active {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-color: transparent;
  transform: scale(1.1);
}

/* Results Info */
.results-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 8px;
  color: white;
  font-size: 0.9rem;
  font-weight: 500;
  margin-bottom: 1rem;
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
}

.page-info {
  font-weight: 600;
}

/* Words List */
.words-list {
  max-width: 1200px;
  margin: 0 auto 2rem;
  background: white;
  border-radius: 12px;
  padding: 1rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.word-item {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 1rem;
  align-items: center;
  padding: 0.85rem 1rem;
  border-bottom: 1px solid #f0f0f0;
  transition: all 0.2s;
}

.word-item:last-child {
  border-bottom: none;
}

.word-item:hover {
  background: #f8f9fa;
}

.word-source,
.word-target {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.word-source {
  justify-content: flex-end;
}

.word-text {
  font-size: 1rem;
  font-weight: 600;
  color: #2c3e50;
}

.word-arrow {
  color: #667eea;
  font-size: 1.2rem;
  font-weight: bold;
}

.word-category {
  padding: 0.2rem 0.6rem;
  background: #e8f4f8;
  color: #3498db;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 500;
}

.audio-btn-inline {
  background: rgba(102, 126, 234, 0.15);
  border: 1px solid rgba(102, 126, 234, 0.3);
  padding: 0.3rem 0.5rem;
  border-radius: 6px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.2s;
}

.audio-btn-inline:hover {
  background: rgba(102, 126, 234, 0.25);
  transform: translateY(-1px);
}

/* Pagination */
.pagination {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
  align-items: center;
  flex-wrap: wrap;
  max-width: 1200px;
  margin: 0 auto;
}

.page-btn {
  padding: 0.6rem 1rem;
  background: rgba(255, 255, 255, 0.15);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.page-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-1px);
}

.page-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.page-numbers {
  display: flex;
  gap: 0.35rem;
}

.page-number {
  width: 36px;
  height: 36px;
  padding: 0;
  background: rgba(255, 255, 255, 0.15);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 6px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.page-number:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-1px);
}

.page-number.active {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-color: transparent;
  transform: scale(1.1);
}

/* Responsive */
@media (max-width: 768px) {
  .dictionary-container {
    padding: 1rem;
  }

  .dictionary-header h1 {
    font-size: 1.35rem;
  }

  .language-selector {
    gap: 0.4rem;
  }

  .lang-btn {
    font-size: 0.75rem;
    padding: 0.5rem 0.75rem;
  }

  .alphabet-nav {
    gap: 0.25rem;
  }

  .letter-btn {
    width: 28px;
    height: 28px;
    font-size: 0.75rem;
  }

  .word-item {
    grid-template-columns: 1fr;
    gap: 0.5rem;
    padding: 1rem;
  }

  .word-source {
    justify-content: flex-start;
  }

  .word-arrow {
    display: none;
  }

  .results-info {
    flex-direction: column;
    gap: 0.5rem;
    text-align: center;
  }

  .pagination {
    gap: 0.35rem;
  }

  .page-btn {
    padding: 0.5rem 0.75rem;
    font-size: 0.75rem;
  }

  .page-number {
    width: 32px;
    height: 32px;
    font-size: 0.8rem;
  }
}
</style>
