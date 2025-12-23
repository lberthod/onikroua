<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useLearningStore } from '../stores/learning'

const authStore = useAuthStore()
const learningStore = useLearningStore()

const isEditing = ref(false)
const newDisplayName = ref('')

onMounted(() => {
  learningStore.initDemoData()
  if (authStore.user?.displayName) {
    newDisplayName.value = authStore.user.displayName
  }
})

const userName = computed(() => {
  if (authStore.user?.displayName) return authStore.user.displayName
  if (authStore.user?.email) return authStore.user.email.split('@')[0]
  return 'Utilisateur'
})

const userEmail = computed(() => authStore.user?.email || '')

const userInitial = computed(() => userName.value.charAt(0).toUpperCase())

const memberSince = computed(() => {
  if (!authStore.user?.metadata?.creationTime) return 'Inconnu'
  const date = new Date(authStore.user.metadata.creationTime)
  return date.toLocaleDateString('fr-FR', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })
})

const stats = computed(() => ({
  vocabularyCount: learningStore.vocabulary.length,
  grammarCount: learningStore.grammar.length,
  conjugationCount: learningStore.conjugations.length
}))

const toggleEdit = () => {
  isEditing.value = !isEditing.value
  if (!isEditing.value) {
    newDisplayName.value = authStore.user?.displayName || ''
  }
}

const saveProfile = async () => {
  if (newDisplayName.value.trim()) {
    // TODO: Implémenter la mise à jour du profil Firebase
    isEditing.value = false
  }
}

const currentLanguageLabel = computed(() => 
  learningStore.currentLanguage === 'it' ? '🇮🇹 Italien' : '🇪🇸 Espagnol'
)
</script>

<template>
  <div class="profile-container">
    <div class="profile-header">
      <div class="profile-avatar">
        <span class="avatar-initial">{{ userInitial }}</span>
      </div>
      <div class="profile-info">
        <div class="name-section">
          <h1 v-if="!isEditing">{{ userName }}</h1>
          <input 
            v-else 
            v-model="newDisplayName" 
            class="name-input"
            placeholder="Votre nom"
          />
          <button 
            v-if="!isEditing" 
            class="edit-btn" 
            @click="toggleEdit"
            title="Modifier"
          >
            ✏️
          </button>
          <div v-else class="edit-actions">
            <button class="save-btn" @click="saveProfile">✓</button>
            <button class="cancel-btn" @click="toggleEdit">✕</button>
          </div>
        </div>
        <p class="email">{{ userEmail }}</p>
        <p class="member-since">Membre depuis {{ memberSince }}</p>
      </div>
    </div>

    <div class="profile-sections">
      <!-- Préférences -->
      <section class="profile-section card">
        <h2>⚙️ Préférences</h2>
        <div class="preference-item">
          <span class="preference-label">Langue d'apprentissage</span>
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
        </div>
        <p class="current-lang">Actuellement : <strong>{{ currentLanguageLabel }}</strong></p>
      </section>

      <!-- Statistiques -->
      <section class="profile-section card">
        <h2>📊 Statistiques</h2>
        <div class="stats-grid">
          <div class="stat-card">
            <span class="stat-icon">📚</span>
            <span class="stat-value">{{ stats.vocabularyCount }}</span>
            <span class="stat-label">Mots de vocabulaire</span>
          </div>
          <div class="stat-card">
            <span class="stat-icon">📖</span>
            <span class="stat-value">{{ stats.grammarCount }}</span>
            <span class="stat-label">Règles de grammaire</span>
          </div>
          <div class="stat-card">
            <span class="stat-icon">📝</span>
            <span class="stat-value">{{ stats.conjugationCount }}</span>
            <span class="stat-label">Conjugaisons</span>
          </div>
        </div>
      </section>

      <!-- Progression -->
      <section class="profile-section card">
        <h2>🎯 Progression</h2>
        <div class="progress-placeholder">
          <p>Votre progression sera affichée ici au fur et à mesure de votre apprentissage.</p>
          <div class="progress-items">
            <div class="progress-item">
              <span class="progress-icon">🔥</span>
              <span>Continuez à apprendre pour débloquer des succès !</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Actions -->
      <section class="profile-section card danger-zone">
        <h2>🔐 Compte</h2>
        <p class="danger-text">Gérez les paramètres de votre compte</p>
        <div class="account-actions">
          <button class="btn btn-secondary" disabled>
            Changer le mot de passe
          </button>
          <button class="btn btn-danger" disabled>
            Supprimer le compte
          </button>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.profile-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 1rem;
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 2rem;
  background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
  border-radius: 16px;
  color: white;
  margin-bottom: 2rem;
}

.profile-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.avatar-initial {
  font-size: 2.5rem;
  font-weight: 700;
}

.profile-info {
  flex: 1;
}

.name-section {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.name-section h1 {
  margin: 0;
  font-size: 1.75rem;
}

.name-input {
  font-size: 1.5rem;
  padding: 0.5rem;
  border: 2px solid rgba(255, 255, 255, 0.5);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  width: 200px;
}

.name-input::placeholder {
  color: rgba(255, 255, 255, 0.6);
}

.edit-btn, .save-btn, .cancel-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  padding: 0.5rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: background 0.2s;
}

.edit-btn:hover, .save-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

.cancel-btn:hover {
  background: rgba(231, 76, 60, 0.5);
}

.edit-actions {
  display: flex;
  gap: 0.5rem;
}

.email {
  margin: 0.5rem 0 0;
  opacity: 0.9;
}

.member-since {
  margin: 0.25rem 0 0;
  font-size: 0.9rem;
  opacity: 0.7;
}

.profile-sections {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.profile-section {
  padding: 1.5rem;
}

.profile-section h2 {
  margin: 0 0 1rem;
  font-size: 1.25rem;
  color: #2c3e50;
}

.preference-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
}

.preference-label {
  font-weight: 500;
  color: #34495e;
}

.language-toggle {
  display: flex;
  gap: 0.5rem;
}

.lang-btn {
  padding: 0.6rem 1rem;
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

.current-lang {
  margin: 1rem 0 0;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.stat-card {
  background: #f8f9fa;
  padding: 1.25rem;
  border-radius: 12px;
  text-align: center;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.stat-icon {
  font-size: 1.5rem;
}

.stat-value {
  font-size: 1.75rem;
  font-weight: 700;
  color: #2c3e50;
}

.stat-label {
  font-size: 0.85rem;
  color: #7f8c8d;
}

.progress-placeholder {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
  text-align: center;
}

.progress-placeholder p {
  margin: 0 0 1rem;
  color: #7f8c8d;
}

.progress-items {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.progress-item {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  color: #f39c12;
  font-weight: 500;
}

.progress-icon {
  font-size: 1.25rem;
}

.danger-zone {
  border: 1px solid #fadbd8;
}

.danger-text {
  color: #7f8c8d;
  margin: 0 0 1rem;
}

.account-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.btn-danger {
  background: #e74c3c;
  color: white;
}

.btn-danger:hover {
  background: #c0392b;
}

/* Responsive */
@media (max-width: 768px) {
  .profile-header {
    flex-direction: column;
    text-align: center;
    padding: 1.5rem;
  }
  
  .name-section {
    justify-content: center;
    flex-wrap: wrap;
  }
  
  .name-section h1 {
    font-size: 1.5rem;
  }
  
  .profile-avatar {
    width: 80px;
    height: 80px;
  }
  
  .avatar-initial {
    font-size: 2rem;
  }
  
  .preference-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .language-toggle {
    width: 100%;
  }
  
  .lang-btn {
    flex: 1;
  }
}

@media (max-width: 480px) {
  .profile-container {
    padding: 0.5rem;
  }
  
  .profile-header {
    padding: 1rem;
    border-radius: 12px;
  }
  
  .profile-section {
    padding: 1rem;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .account-actions {
    flex-direction: column;
  }
  
  .account-actions .btn {
    width: 100%;
  }
}
</style>
