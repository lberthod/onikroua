<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useLearningStore } from '../stores/learning'

const router = useRouter()
const authStore = useAuthStore()
const learningStore = useLearningStore()

onMounted(() => {
  learningStore.initDemoData()
})

const sections = [
  { id: 'feed', name: 'Feed', icon: '🌟', route: '/feed', color: '#8b5cf6', description: 'Découvrez du contenu varié en mode infinite scroll' },
  { id: 'conjugaison', name: 'Conjugaison', icon: '📝', route: '/conjugaison', color: '#3498db', description: 'Apprenez les conjugaisons des verbes' },
  { id: 'vocabulaire', name: 'Vocabulaire', icon: '📚', route: '/vocabulaire', color: '#27ae60', description: 'Enrichissez votre vocabulaire' },
  { id: 'grammaire', name: 'Grammaire', icon: '📖', route: '/grammaire', color: '#9b59b6', description: 'Maîtrisez les règles de grammaire' },
  { id: 'phonetique', name: 'Phonétique', icon: '🎵', route: '/phonetique', color: '#e74c3c', description: 'Perfectionnez votre prononciation' },
  { id: 'quiz', name: 'Quiz Duo', icon: '🎯', route: '/lobby', color: '#f39c12', description: 'Testez-vous en duo avec un ami' }
]

const userName = computed(() => {
  if (authStore.user?.displayName) return authStore.user.displayName
  if (authStore.user?.email) return authStore.user.email.split('@')[0]
  return 'Apprenant'
})

const navigateTo = (route: string) => {
  router.push(route)
}
</script>

<template>
  <div class="dashboard-container">
    <header class="dashboard-header">
      <h1>Bienvenue, {{ userName }} ! 👋</h1>
      <p class="dashboard-subtitle">Que souhaitez-vous apprendre aujourd'hui ?</p>
      
      <div class="language-selector">
        <span>Langue d'apprentissage :</span>
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

    <div class="sections-grid">
      <div 
        v-for="section in sections" 
        :key="section.id"
        class="section-card card"
        :style="{ borderTopColor: section.color }"
        @click="navigateTo(section.route)"
      >
        <div class="section-icon" :style="{ backgroundColor: section.color }">
          {{ section.icon }}
        </div>
        <h2 class="section-name">{{ section.name }}</h2>
        <p class="section-description">{{ section.description }}</p>
        <span class="section-arrow">→</span>
      </div>
    </div>

    <div class="quick-stats">
      <h3>📊 Votre progression</h3>
      <p class="stats-placeholder">Commencez à apprendre pour voir votre progression ici !</p>
    </div>
  </div>
</template>

<style scoped>
.dashboard-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.dashboard-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

.dashboard-header h1 {
  font-size: 2rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.dashboard-subtitle {
  color: #7f8c8d;
  font-size: 1.1rem;
  margin-bottom: 1.5rem;
}

.language-selector {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.language-selector span {
  color: #7f8c8d;
}

.lang-btn {
  padding: 0.5rem 1rem;
  border: 2px solid #ddd;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.95rem;
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

.sections-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2.5rem;
}

.section-card {
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.2s;
  border-top: 4px solid;
  position: relative;
}

.section-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.section-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  margin-bottom: 1rem;
}

.section-name {
  font-size: 1.25rem;
  color: #2c3e50;
  margin: 0 0 0.5rem 0;
}

.section-description {
  color: #7f8c8d;
  font-size: 0.9rem;
  margin: 0;
  line-height: 1.5;
}

.section-arrow {
  position: absolute;
  right: 1.5rem;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.5rem;
  color: #ddd;
  transition: all 0.2s;
}

.section-card:hover .section-arrow {
  color: #3498db;
  transform: translateY(-50%) translateX(5px);
}

.quick-stats {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1.5rem;
  text-align: center;
}

.quick-stats h3 {
  color: #2c3e50;
  margin: 0 0 1rem 0;
}

.stats-placeholder {
  color: #7f8c8d;
  margin: 0;
}

/* Responsive */
@media (max-width: 768px) {
  .dashboard-header h1 {
    font-size: 1.5rem;
  }
  
  .dashboard-subtitle {
    font-size: 1rem;
  }
  
  .language-selector {
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .language-selector span {
    margin-bottom: 0.25rem;
  }
  
  .sections-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .section-card {
    padding: 1.25rem;
  }
  
  .section-icon {
    width: 45px;
    height: 45px;
    font-size: 1.3rem;
  }
  
  .section-name {
    font-size: 1.1rem;
  }
  
  .section-arrow {
    display: none;
  }
}

@media (max-width: 480px) {
  .dashboard-container {
    padding: 1rem 0.75rem;
  }
  
  .dashboard-header h1 {
    font-size: 1.3rem;
  }
  
  .lang-btn {
    padding: 0.5rem 0.75rem;
    font-size: 0.9rem;
  }
  
  .section-card {
    padding: 1rem;
  }
  
  .section-description {
    font-size: 0.85rem;
  }
  
  .quick-stats {
    padding: 1rem;
  }
}
</style>
