<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { usePhonetiqueStore } from '../stores/phonetique'
import SoundCard from '../components/phonetique/SoundCard.vue'
import PracticeMode from '../components/phonetique/PracticeMode.vue'
import CategoryNav from '../components/phonetique/CategoryNav.vue'

const phonetiqueStore = usePhonetiqueStore()

const activeTab = ref<'learn' | 'practice'>('learn')

onMounted(() => {
  phonetiqueStore.loadPhoneticData()
})

const sounds = computed(() => phonetiqueStore.filteredSounds)
const practiceWords = computed(() => phonetiqueStore.filteredPracticeWords)
const categories = computed(() => phonetiqueStore.categoriesWithCount)

const languageLabel = computed(() => 
  phonetiqueStore.currentLanguage === 'it' ? '🇮🇹 Italien' : '🇪🇸 Espagnol'
)

const handleCategorySelect = (categoryId: string) => {
  phonetiqueStore.setCategory(categoryId)
}
</script>

<template>
  <div class="section-container">
    <header class="section-header">
      <h1>🎵 Phonétique</h1>
      <p class="section-subtitle">Maîtrisez la prononciation en {{ languageLabel }}</p>
      
      <div class="language-toggle">
        <button 
          :class="['lang-btn', { active: phonetiqueStore.currentLanguage === 'it' }]"
          @click="phonetiqueStore.setLanguage('it')"
        >
          🇮🇹 Italien
        </button>
        <button 
          :class="['lang-btn', { active: phonetiqueStore.currentLanguage === 'es' }]"
          @click="phonetiqueStore.setLanguage('es')"
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
      <CategoryNav 
        :categories="categories"
        :active-category="phonetiqueStore.currentCategory"
        @select="handleCategorySelect"
      />

      <div class="sounds-grid">
        <SoundCard
          v-for="sound in sounds"
          :key="sound.id"
          :sound="sound.graphie"
          :phonetic="sound.phonetic"
          :description="sound.description"
          :examples="sound.examples"
          :language="sound.language"
          :category="sound.category"
          :tips="sound.tips"
          :common-mistakes="sound.commonMistakes"
        />
      </div>

      <div v-if="sounds.length === 0" class="empty-state">
        <p>Aucun son disponible pour cette catégorie.</p>
      </div>
    </div>

    <!-- Contenu Pratiquer -->
    <div v-if="activeTab === 'practice'" class="practice-content">
      <PracticeMode
        v-if="practiceWords.length > 0"
        :items="practiceWords"
        :language="phonetiqueStore.currentLanguage"
        :title="'🎧 Pratique de prononciation - ' + languageLabel"
      />
      <div v-else class="empty-state">
        <p>Aucun mot de pratique disponible.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.section-container {
  max-width: 1100px;
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
  border-color: #9b59b6;
}

.lang-btn.active {
  background: #9b59b6;
  color: white;
  border-color: #9b59b6;
}

/* Onglets */
.tabs {
  display: flex;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
  padding: 0.5rem;
  background: #f8f9fa;
  border-radius: 12px;
}

.tab-btn {
  padding: 0.75rem 2rem;
  border: none;
  background: transparent;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  color: #7f8c8d;
  transition: all 0.2s;
}

.tab-btn:hover {
  color: #9b59b6;
  background: rgba(155, 89, 182, 0.1);
}

.tab-btn.active {
  background: #9b59b6;
  color: white;
}

/* Grille des sons */
.sounds-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 1.5rem;
}

/* Contenu pratique */
.practice-content {
  max-width: 600px;
  margin: 0 auto;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #7f8c8d;
  background: #f8f9fa;
  border-radius: 12px;
}

/* Responsive */
@media (max-width: 768px) {
  .section-container {
    padding: 1.5rem 0.75rem;
  }
  
  .section-header h1 {
    font-size: 1.5rem;
  }
  
  .section-subtitle {
    font-size: 0.95rem;
  }
  
  .language-toggle {
    flex-wrap: wrap;
  }
  
  .lang-btn {
    padding: 0.6rem 1rem;
    font-size: 0.9rem;
  }
  
  .tabs {
    padding: 0.35rem;
    gap: 0.25rem;
  }
  
  .tab-btn {
    padding: 0.6rem 1rem;
    font-size: 0.9rem;
  }
  
  .sounds-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .practice-content {
    max-width: 100%;
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
    gap: 0.5rem;
  }
  
  .lang-btn {
    padding: 0.5rem 0.75rem;
    font-size: 0.85rem;
  }
  
  .tab-btn {
    padding: 0.5rem 0.75rem;
    font-size: 0.85rem;
  }
  
  .empty-state {
    padding: 2rem 1rem;
  }
}
</style>
