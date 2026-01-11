<script setup lang="ts">
import { ref, computed } from 'vue'

interface TatoebaSentence {
  id: number
  text: string
  lang: string
  translations?: TatoebaSentence[]
}

interface SearchResult {
  source: TatoebaSentence
  translation: TatoebaSentence
}

const searchQuery = ref('')
const sourceLang = ref<'ita' | 'fra' | 'spa'>('ita')
const targetLang = ref<'fra' | 'ita' | 'spa' | 'eng'>('fra')
const loading = ref(false)
const error = ref('')
const results = ref<SearchResult[]>([])
const currentPage = ref(1)
const itemsPerPage = 20

const languageOptions = [
  { code: 'ita', name: 'Italien', flag: '🇮🇹' },
  { code: 'fra', name: 'Français', flag: '🇫🇷' },
  { code: 'spa', name: 'Espagnol', flag: '🇪🇸' },
  { code: 'eng', name: 'Anglais', flag: '🇬🇧' }
]

const searchSentences = async () => {
  if (!searchQuery.value.trim()) {
    error.value = 'Veuillez entrer un mot ou une phrase'
    return
  }

  loading.value = true
  error.value = ''
  results.value = []
  currentPage.value = 1

  try {
    // API Tatoeba - recherche de phrases
    const searchUrl = `https://tatoeba.org/en/api_v0/search?from=${sourceLang.value}&to=${targetLang.value}&query=${encodeURIComponent(searchQuery.value.trim())}&trans_filter=limit&trans_to=${targetLang.value}&sort=relevance`
    
    const response = await fetch(searchUrl)
    
    if (!response.ok) {
      throw new Error('Erreur lors de la recherche')
    }

    const data = await response.json()
    
    if (!data.results || data.results.length === 0) {
      error.value = 'Aucune phrase trouvée. Essayez avec un autre mot.'
      return
    }

    // Transformer les résultats
    const searchResults: SearchResult[] = []
    
    for (const item of data.results) {
      if (item.translations && item.translations.length > 0) {
        // Filtrer les traductions dans la langue cible
        const targetTranslations = item.translations[0].filter((t: any) => 
          t.lang === targetLang.value
        )
        
        if (targetTranslations.length > 0) {
          searchResults.push({
            source: {
              id: item.id,
              text: item.text,
              lang: item.lang
            },
            translation: {
              id: targetTranslations[0].id,
              text: targetTranslations[0].text,
              lang: targetTranslations[0].lang
            }
          })
        }
      }
    }

    results.value = searchResults

    if (searchResults.length === 0) {
      error.value = 'Aucune traduction trouvée dans la langue sélectionnée.'
    }

  } catch (err) {
    error.value = 'Impossible de récupérer les phrases. Vérifiez votre connexion.'
    console.error(err)
  } finally {
    loading.value = false
  }
}

const handleSearch = (e: Event) => {
  e.preventDefault()
  searchSentences()
}

const quickSearch = (word: string) => {
  searchQuery.value = word
  searchSentences()
}

const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return results.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(results.value.length / itemsPerPage)
})

const goToPage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
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

const speakSentence = (text: string, lang: string) => {
  if ('speechSynthesis' in window) {
    window.speechSynthesis.cancel()
    const utterance = new SpeechSynthesisUtterance(text)
    
    const langMap: { [key: string]: string } = {
      'ita': 'it-IT',
      'fra': 'fr-FR',
      'spa': 'es-ES',
      'eng': 'en-US'
    }
    
    utterance.lang = langMap[lang] || 'en-US'
    utterance.rate = 0.8
    window.speechSynthesis.speak(utterance)
  }
}

const getLanguageName = (code: string): string => {
  const lang = languageOptions.find(l => l.code === code)
  return lang ? lang.name : code
}

const getLanguageFlag = (code: string): string => {
  const lang = languageOptions.find(l => l.code === code)
  return lang ? lang.flag : '🌐'
}

const popularWords = {
  ita: ['ciao', 'grazie', 'casa', 'amore', 'mangiare', 'bello'],
  fra: ['bonjour', 'merci', 'maison', 'amour', 'manger', 'beau'],
  spa: ['hola', 'gracias', 'casa', 'amor', 'comer', 'bonito']
}

const getSentenceLevel = (text: string): string => {
  const wordCount = text.split(' ').length
  if (wordCount <= 5) return 'A1'
  if (wordCount <= 10) return 'A2'
  if (wordCount <= 15) return 'B1'
  return 'B2+'
}
</script>

<template>
  <div class="tatoeba-container">
    <div class="tatoeba-header">
      <h1>💬 Phrases Bilingues - Tatoeba</h1>
      <p class="subtitle">Apprenez avec des exemples réels • A1-B1</p>
    </div>

    <!-- Language Selector -->
    <div class="language-config">
      <div class="lang-group">
        <label class="lang-label">Langue source :</label>
        <div class="lang-buttons">
          <button
            @click="sourceLang = 'ita'"
            class="lang-btn"
            :class="{ active: sourceLang === 'ita' }"
          >
            🇮🇹 Italien
          </button>
          <button
            @click="sourceLang = 'fra'"
            class="lang-btn"
            :class="{ active: sourceLang === 'fra' }"
          >
            🇫🇷 Français
          </button>
          <button
            @click="sourceLang = 'spa'"
            class="lang-btn"
            :class="{ active: sourceLang === 'spa' }"
          >
            🇪🇸 Espagnol
          </button>
        </div>
      </div>

      <div class="arrow-icon">→</div>

      <div class="lang-group">
        <label class="lang-label">Langue cible :</label>
        <div class="lang-buttons">
          <button
            v-for="lang in languageOptions"
            :key="lang.code"
            @click="targetLang = lang.code as any"
            class="lang-btn"
            :class="{ active: targetLang === lang.code }"
            :disabled="sourceLang === lang.code"
          >
            {{ lang.flag }} {{ lang.name }}
          </button>
        </div>
      </div>
    </div>

    <!-- Search Section -->
    <div class="search-section">
      <form @submit="handleSearch" class="search-form">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Rechercher un mot ou une phrase..."
          class="search-input"
        />
        <button type="submit" class="search-btn" :disabled="loading">
          🔍 Rechercher
        </button>
      </form>

      <!-- Popular Words -->
      <div class="popular-words">
        <span class="popular-label">Mots populaires :</span>
        <button
          v-for="word in popularWords[sourceLang]"
          :key="word"
          @click="quickSearch(word)"
          class="popular-word-btn"
        >
          {{ word }}
        </button>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="error" class="error-message">
      {{ error }}
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
      <p>Recherche de phrases sur Tatoeba...</p>
    </div>

    <!-- Results -->
    <div v-else-if="results.length > 0" class="results-section">
      <div class="results-info">
        <span>{{ results.length }} phrase(s) trouvée(s)</span>
        <span class="page-info">Page {{ currentPage }} / {{ totalPages }}</span>
      </div>

      <div class="sentences-list">
        <div
          v-for="result in paginatedResults"
          :key="result.source.id"
          class="sentence-card"
        >
          <div class="sentence-row source-row">
            <div class="sentence-header">
              <span class="language-badge">
                {{ getLanguageFlag(result.source.lang) }} {{ getLanguageName(result.source.lang) }}
              </span>
              <span class="level-badge">{{ getSentenceLevel(result.source.text) }}</span>
            </div>
            <div class="sentence-content">
              <p class="sentence-text">{{ result.source.text }}</p>
              <button
                @click="speakSentence(result.source.text, result.source.lang)"
                class="audio-btn"
                title="Écouter"
              >
                🔊
              </button>
            </div>
          </div>

          <div class="sentence-divider">↓</div>

          <div class="sentence-row translation-row">
            <div class="sentence-header">
              <span class="language-badge translation-badge">
                {{ getLanguageFlag(result.translation.lang) }} {{ getLanguageName(result.translation.lang) }}
              </span>
            </div>
            <div class="sentence-content">
              <p class="sentence-text">{{ result.translation.text }}</p>
              <button
                @click="speakSentence(result.translation.text, result.translation.lang)"
                class="audio-btn"
                title="Écouter"
              >
                🔊
              </button>
            </div>
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

    <!-- Empty State -->
    <div v-else-if="!loading" class="empty-state">
      <div class="empty-icon">💬</div>
      <h3>Recherchez des phrases</h3>
      <p>Découvrez des exemples authentiques en contexte réel</p>
      <p class="empty-hint">Tatoeba contient des milliers de phrases pour l'apprentissage</p>
    </div>
  </div>
</template>

<style scoped>
.tatoeba-container {
  min-height: calc(100vh - 56px);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1.5rem;
  padding-bottom: 3rem;
}

.tatoeba-header {
  text-align: center;
  color: white;
  margin-bottom: 1.75rem;
}

.tatoeba-header h1 {
  font-size: 1.75rem;
  margin-bottom: 0.4rem;
  font-weight: 600;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.subtitle {
  font-size: 0.95rem;
  opacity: 0.9;
}

/* Language Configuration */
.language-config {
  max-width: 1000px;
  margin: 0 auto 2rem;
  display: flex;
  gap: 1.5rem;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  background: rgba(255, 255, 255, 0.1);
  padding: 1.5rem;
  border-radius: 12px;
}

.lang-group {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.lang-label {
  color: white;
  font-size: 0.85rem;
  font-weight: 600;
  text-align: center;
}

.lang-buttons {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
  justify-content: center;
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

.lang-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-1px);
}

.lang-btn.active {
  background: white;
  color: #667eea;
  border-color: white;
}

.lang-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.arrow-icon {
  font-size: 2rem;
  color: white;
  font-weight: bold;
}

/* Search Section */
.search-section {
  max-width: 800px;
  margin: 0 auto 2rem;
}

.search-form {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.search-input {
  flex: 1;
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

.search-btn {
  padding: 0.85rem 1.75rem;
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  white-space: nowrap;
}

.search-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #e67e22 0%, #d35400 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.search-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Popular Words */
.popular-words {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  align-items: center;
  background: rgba(255, 255, 255, 0.1);
  padding: 0.75rem 1rem;
  border-radius: 8px;
}

.popular-label {
  color: white;
  font-size: 0.85rem;
  font-weight: 600;
  margin-right: 0.25rem;
}

.popular-word-btn {
  padding: 0.35rem 0.85rem;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.popular-word-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-1px);
}

/* Error & Loading */
.error-message {
  max-width: 600px;
  margin: 2rem auto;
  padding: 1rem 1.5rem;
  background: rgba(231, 76, 60, 0.2);
  border: 1px solid rgba(231, 76, 60, 0.5);
  border-radius: 8px;
  color: white;
  text-align: center;
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 3rem;
  color: white;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Results */
.results-section {
  max-width: 1200px;
  margin: 0 auto;
}

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
}

.page-info {
  font-weight: 600;
}

.sentences-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 2rem;
}

.sentence-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
}

.sentence-card:hover {
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
  transform: translateY(-2px);
}

.sentence-row {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.source-row {
  padding-bottom: 1rem;
}

.translation-row {
  padding-top: 1rem;
}

.sentence-header {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.language-badge {
  padding: 0.35rem 0.85rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

.translation-badge {
  background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
}

.level-badge {
  padding: 0.35rem 0.75rem;
  background: #e8f4f8;
  color: #3498db;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
}

.sentence-content {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.sentence-text {
  flex: 1;
  margin: 0;
  font-size: 1.1rem;
  line-height: 1.6;
  color: #2c3e50;
}

.audio-btn {
  background: rgba(102, 126, 234, 0.15);
  border: 1px solid rgba(102, 126, 234, 0.3);
  padding: 0.5rem 0.75rem;
  border-radius: 8px;
  font-size: 1.1rem;
  cursor: pointer;
  transition: all 0.2s;
  flex-shrink: 0;
}

.audio-btn:hover {
  background: rgba(102, 126, 234, 0.25);
  transform: translateY(-2px);
}

.sentence-divider {
  text-align: center;
  color: #667eea;
  font-size: 1.5rem;
  font-weight: bold;
  margin: 0.5rem 0;
}

/* Pagination */
.pagination {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
  align-items: center;
  flex-wrap: wrap;
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

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: white;
}

.empty-icon {
  font-size: 5rem;
  margin-bottom: 1rem;
  opacity: 0.8;
}

.empty-state h3 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
}

.empty-state p {
  font-size: 1rem;
  opacity: 0.9;
  margin-bottom: 0.5rem;
}

.empty-hint {
  font-size: 0.9rem;
  opacity: 0.7;
  font-style: italic;
}

/* Responsive */
@media (max-width: 768px) {
  .tatoeba-container {
    padding: 1rem;
  }

  .tatoeba-header h1 {
    font-size: 1.35rem;
  }

  .language-config {
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
  }

  .arrow-icon {
    transform: rotate(90deg);
  }

  .lang-buttons {
    gap: 0.35rem;
  }

  .lang-btn {
    font-size: 0.75rem;
    padding: 0.5rem 0.75rem;
  }

  .search-form {
    flex-direction: column;
  }

  .search-btn {
    width: 100%;
  }

  .sentence-card {
    padding: 1rem;
  }

  .sentence-text {
    font-size: 1rem;
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
