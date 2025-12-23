<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useLearningStore, type GrammarCategory, type GrammarItem } from '../stores/learning'
import { grammarCategories, grammarSubCategoryLabels } from '../data/grammarConfig'
import GrammarCard from '../components/grammaire/GrammarCard.vue'
import GrammarPractice from '../components/grammaire/GrammarPractice.vue'

const learningStore = useLearningStore()
const activeTab = ref<'learn' | 'practice'>('learn')
const selectedCategory = ref<GrammarCategory | 'all'>('all')
const grammarSearch = ref('')
const grammarDifficulty = ref<'all' | 'beginner' | 'intermediate' | 'advanced'>('all')
const practiceCategory = ref<GrammarCategory | 'all'>('all')
const practiceDifficulty = ref<'all' | 'beginner' | 'intermediate' | 'advanced'>('all')

onMounted(() => {
  learningStore.initDemoData()
  learningStore.setSection('grammaire')
})

const grammar = computed(() => learningStore.getGrammarByLanguage)

const languageLabel = computed(() => 
  learningStore.currentLanguage === 'it' ? '🇮🇹 Italien' : '🇪🇸 Espagnol'
)

// Définition des catégories avec leurs labels et icônes (données statiques depuis src/data/grammarConfig.ts)
const categories = grammarCategories

// Filtrer les règles par catégorie, difficulté et recherche
const filteredGrammar = computed(() => {
  let items = grammar.value as GrammarItem[]

  if (selectedCategory.value !== 'all') {
    items = items.filter((item: GrammarItem) => item.category === selectedCategory.value)
  }

  if (grammarDifficulty.value !== 'all') {
    items = items.filter((item: GrammarItem) => item.difficulty === grammarDifficulty.value)
  }

  const search = grammarSearch.value.trim().toLowerCase()
  if (search) {
    items = items.filter((item: GrammarItem) => {
      return (
        item.rule.toLowerCase().includes(search) ||
        item.content.toLowerCase().includes(search) ||
        (item.example && item.example.toLowerCase().includes(search)) ||
        (item.translation && item.translation.toLowerCase().includes(search))
      )
    })
  }

  return items
})

// Grouper les règles par sous-catégorie pour l'affichage
const groupedGrammar = computed(() => {
  const groups: Record<string, { label: string; items: GrammarItem[] }> = {}

  filteredGrammar.value.forEach((item: GrammarItem) => {
    const subCat = item.subCategory
    if (!groups[subCat]) {
      groups[subCat] = {
        label: grammarSubCategoryLabels[subCat] || subCat,
        items: []
      }
    }
    groups[subCat].items.push(item)
  })

  return groups
})

// Compter les règles par catégorie
const categoryCounts = computed(() => {
  const counts: Record<string, number> = { all: grammar.value.length }
  grammar.value.forEach((item: GrammarItem) => {
    counts[item.category] = (counts[item.category] || 0) + 1
  })
  return counts
})

// Règles utilisées pour la pratique (filtres séparés pour la section "Pratiquer")
const practiceItems = computed(() => {
  let items = grammar.value as GrammarItem[]

  if (practiceCategory.value !== 'all') {
    items = items.filter((item: GrammarItem) => item.category === practiceCategory.value)
  }

  if (practiceDifficulty.value !== 'all') {
    items = items.filter((item: GrammarItem) => item.difficulty === practiceDifficulty.value)
  }

  return items
})
</script>

<template>
  <div class="section-container">
    <header class="section-header">
      <h1>📖 Grammaire</h1>
      <p class="section-subtitle">Maîtrisez les règles de grammaire en {{ languageLabel }}</p>
      
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

    <!-- Onglets -->
    <div class="tabs">
      <button 
        :class="['tab-btn', { active: activeTab === 'learn' }]"
        @click="activeTab = 'learn'"
      >
        📚 Apprendre
      </button>
      <button 
        :class="['tab-btn', { active: activeTab === 'practice' }]"
        @click="activeTab = 'practice'"
      >
        🎯 Pratiquer
      </button>
    </div>

    <!-- Contenu Apprendre -->
    <div v-if="activeTab === 'learn'" class="learn-content">
      <div class="grammar-toolbar">
        <input
          v-model="grammarSearch"
          type="text"
          class="grammar-search-input"
          placeholder="Rechercher une règle, un exemple, un mot-clé..."
        />
        <div class="difficulty-chips">
          <button
            class="difficulty-chip"
            :class="{ active: grammarDifficulty === 'all' }"
            @click="grammarDifficulty = 'all'"
          >
            Tous niveaux
          </button>
          <button
            class="difficulty-chip"
            :class="{ active: grammarDifficulty === 'beginner' }"
            @click="grammarDifficulty = 'beginner'"
          >
            Débutant
          </button>
          <button
            class="difficulty-chip"
            :class="{ active: grammarDifficulty === 'intermediate' }"
            @click="grammarDifficulty = 'intermediate'"
          >
            Intermédiaire
          </button>
          <button
            class="difficulty-chip"
            :class="{ active: grammarDifficulty === 'advanced' }"
            @click="grammarDifficulty = 'advanced'"
          >
            Avancé
          </button>
        </div>
      </div>

      <!-- Navigation par catégories -->
      <div class="category-nav">
        <button
          v-for="cat in categories"
          :key="cat.id"
          :class="['category-btn', { active: selectedCategory === cat.id }]"
          @click="selectedCategory = cat.id"
        >
          <span class="cat-icon">{{ cat.icon }}</span>
          <span class="cat-label">{{ cat.label }}</span>
          <span class="cat-count" v-if="categoryCounts[cat.id]">{{ categoryCounts[cat.id] }}</span>
        </button>
      </div>

      <!-- Affichage groupé par sous-catégorie -->
      <div class="grammar-groups" v-if="Object.keys(groupedGrammar).length > 0">
        <div 
          v-for="(group, subCatKey) in groupedGrammar" 
          :key="subCatKey"
          class="grammar-group"
        >
          <h3 class="group-title">{{ group.label }}</h3>
          <div class="grammar-list">
            <GrammarCard
              v-for="rule in group.items"
              :key="rule.id"
              :rule="rule"
              :language="learningStore.currentLanguage"
            />
          </div>
        </div>
      </div>

      <div v-else class="empty-state">
        <p>Aucune règle de grammaire disponible pour cette catégorie.</p>
      </div>
    </div>

    <!-- Contenu Pratiquer -->
    <div v-if="activeTab === 'practice'" class="practice-content">
      <div class="practice-filters">
        <div class="practice-filter-group">
          <span class="practice-filter-label">Catégorie :</span>
          <div class="practice-filter-chips">
            <button
              v-for="cat in categories"
              :key="cat.id"
              class="practice-filter-chip"
              :class="{ active: practiceCategory === cat.id }"
              @click="practiceCategory = cat.id"
            >
              {{ cat.icon }} {{ cat.label }}
            </button>
          </div>
        </div>
        <div class="practice-filter-group">
          <span class="practice-filter-label">Niveau :</span>
          <div class="practice-filter-chips">
            <button
              class="practice-filter-chip"
              :class="{ active: practiceDifficulty === 'all' }"
              @click="practiceDifficulty = 'all'"
            >
              Tous
            </button>
            <button
              class="practice-filter-chip"
              :class="{ active: practiceDifficulty === 'beginner' }"
              @click="practiceDifficulty = 'beginner'"
            >
              Débutant
            </button>
            <button
              class="practice-filter-chip"
              :class="{ active: practiceDifficulty === 'intermediate' }"
              @click="practiceDifficulty = 'intermediate'"
            >
              Intermédiaire
            </button>
            <button
              class="practice-filter-chip"
              :class="{ active: practiceDifficulty === 'advanced' }"
              @click="practiceDifficulty = 'advanced'"
            >
              Avancé
            </button>
          </div>
        </div>
      </div>

      <GrammarPractice
        v-if="practiceItems.length > 0"
        :items="practiceItems"
        :language="learningStore.currentLanguage"
      />
      <div v-else class="empty-state">
        <p>Aucun exercice disponible pour ces filtres.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.section-container {
  max-width: 900px;
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

/* Styles des onglets */
.tabs {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 2rem;
}

.tab-btn {
  padding: 0.75rem 2rem;
  border: none;
  background: #f1f2f6;
  color: #7f8c8d;
  border-radius: 25px;
  cursor: pointer;
  font-size: 1.1rem;
  font-weight: 600;
  transition: all 0.2s;
}

.tab-btn:hover {
  background: #e1e2e6;
  color: #2c3e50;
}

.tab-btn.active {
  background: #3498db;
  color: white;
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.grammar-list {
  display: grid;
  gap: 1.5rem;
}

.grammar-toolbar {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.grammar-search-input {
  padding: 0.6rem 0.9rem;
  border-radius: 8px;
  border: 1px solid #d0d7de;
  font-size: 0.95rem;
}

.grammar-search-input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
}

.difficulty-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.difficulty-chip {
  padding: 0.3rem 0.8rem;
  border-radius: 999px;
  border: 1px solid #d0d7de;
  background: #f5f5f5;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s;
}

.difficulty-chip.active {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #7f8c8d;
  background: #f8f9fa;
  border-radius: 12px;
}

/* Navigation par catégories */
.category-nav {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 2rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 12px;
}

.category-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1rem;
  border: 2px solid transparent;
  background: white;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.category-btn:hover {
  border-color: #3498db;
  transform: translateY(-1px);
}

.category-btn.active {
  background: #3498db;
  color: white;
  border-color: #3498db;
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.cat-icon {
  font-size: 1.1rem;
}

.cat-label {
  font-weight: 500;
}

.cat-count {
  background: rgba(0,0,0,0.1);
  padding: 0.15rem 0.5rem;
  border-radius: 10px;
  font-size: 0.75rem;
  font-weight: 600;
}

.category-btn.active .cat-count {
  background: rgba(255,255,255,0.3);
}

/* Groupes de grammaire */
.grammar-groups {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.grammar-group {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.group-title {
  font-size: 1.2rem;
  color: #2c3e50;
  margin-bottom: 1rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid #f1f2f6;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.group-title::before {
  content: '';
  display: inline-block;
  width: 4px;
  height: 1.2rem;
  background: #3498db;
  border-radius: 2px;
}

/* Filtres de pratique */
.practice-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.practice-filters {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.practice-filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.practice-filter-label {
  font-size: 0.9rem;
  color: #555;
}

.practice-filter-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.practice-filter-chip {
  padding: 0.3rem 0.75rem;
  border-radius: 999px;
  border: 1px solid #d0d7de;
  background: white;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s;
}

.practice-filter-chip.active {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

/* Responsive */
@media (max-width: 768px) {
  .section-container {
    padding: 1.5rem 0.75rem;
  }
  
  .section-header h1 {
    font-size: 1.5rem;
  }
  
  .lang-btn {
    padding: 0.6rem 1rem;
    font-size: 0.9rem;
  }
  
  .tabs {
    gap: 0.5rem;
  }
  
  .tab-btn {
    padding: 0.6rem 1.5rem;
    font-size: 1rem;
  }
  
  .category-nav {
    justify-content: center;
    padding: 0.75rem;
    gap: 0.35rem;
  }
  
  .category-btn {
    padding: 0.5rem 0.75rem;
    font-size: 0.85rem;
  }
  
  .grammar-group {
    padding: 1rem;
  }
  
  .group-title {
    font-size: 1.1rem;
  }
}

@media (max-width: 480px) {
  .section-container {
    padding: 1rem 0.5rem;
  }
  
  .section-header h1 {
    font-size: 1.3rem;
  }
  
  .language-toggle {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .lang-btn {
    padding: 0.5rem 0.75rem;
    font-size: 0.85rem;
  }
  
  .tabs {
    flex-direction: column;
    gap: 0.35rem;
  }
  
  .tab-btn {
    padding: 0.6rem 1rem;
    font-size: 0.9rem;
  }
  
  .category-nav {
    padding: 0.5rem;
  }
  
  .cat-label {
    display: none;
  }
  
  .category-btn.active .cat-label {
    display: inline;
  }
  
  .cat-count {
    display: none;
  }
  
  .grammar-group {
    padding: 0.75rem;
    border-radius: 12px;
  }
  
  .group-title {
    font-size: 1rem;
  }
  
  .grammar-list {
    gap: 1rem;
  }
}
</style>
