<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useRoomStore } from '../stores/room'

const router = useRouter()
const roomStore = useRoomStore()

const selectedLanguage = ref<'it' | 'es'>('it')
const selectedCategory = ref<'all' | 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics'>('all')
const joinCode = ref('')
const localError = ref('')

const categories = [
  { id: 'all', label: 'Tout', icon: '📚' },
  { id: 'vocabulary', label: 'Vocabulaire', icon: '📖' },
  { id: 'grammar', label: 'Grammaire', icon: '📝' },
  { id: 'conjugation', label: 'Conjugaison', icon: '✍️' },
  { id: 'phonetics', label: 'Phonétique', icon: '🎵' }
]

const handleCreate = async () => {
  localError.value = ''
  try {
    roomStore.setQuizOptions({
      category: selectedCategory.value
    })
    const roomId = await roomStore.createRoom(selectedLanguage.value)
    router.push(`/room/${roomId}`)
  } catch (e: unknown) {
    localError.value = e instanceof Error ? e.message : 'Erreur création room'
  }
}

const handleJoin = async () => {
  if (!joinCode.value.trim()) {
    localError.value = 'Veuillez entrer un code de room'
    return
  }
  localError.value = ''
  try {
    await roomStore.joinRoom(joinCode.value.trim())
    router.push(`/room/${joinCode.value.trim()}`)
  } catch (e: unknown) {
    localError.value = e instanceof Error ? e.message : 'Erreur pour rejoindre la room'
  }
}
</script>

<template>
  <div class="lobby">
    <h1 class="lobby-title">🎯 Quiz Duo</h1>
    <p class="lobby-subtitle">Créez une room ou rejoignez un ami pour apprendre ensemble</p>

    <div class="lobby-grid">
      <!-- Créer une room -->
      <div class="card lobby-section create-section">
        <h2>🆕 Créer une Room</h2>
        
        <!-- Langue -->
        <div class="option-group">
          <label class="option-label">Langue</label>
          <div class="language-selector">
            <button
              :class="['lang-btn', { active: selectedLanguage === 'it' }]"
              @click="selectedLanguage = 'it'"
            >
              🇮🇹 Italien
            </button>
            <button
              :class="['lang-btn', { active: selectedLanguage === 'es' }]"
              @click="selectedLanguage = 'es'"
            >
              🇪🇸 Espagnol
            </button>
          </div>
        </div>

        <!-- Catégorie -->
        <div class="option-group">
          <label class="option-label">Catégorie</label>
          <div class="category-selector">
            <button
              v-for="cat in categories"
              :key="cat.id"
              :class="['cat-btn', { active: selectedCategory === cat.id }]"
              @click="selectedCategory = cat.id as typeof selectedCategory"
            >
              <span>{{ cat.icon }}</span>
              <span>{{ cat.label }}</span>
            </button>
          </div>
        </div>

        <button
          @click="handleCreate"
          class="btn btn-success btn-create"
          :disabled="roomStore.loading"
        >
          {{ roomStore.loading ? 'Création...' : '🚀 Créer la Room' }}
        </button>
      </div>

      <!-- Rejoindre une room -->
      <div class="card lobby-section join-section">
        <h2>🔗 Rejoindre une Room</h2>
        <p>Entrez le code partagé par votre ami</p>

        <div class="join-form">
          <input
            v-model="joinCode"
            type="text"
            class="input join-input"
            placeholder="Ex: ABC123"
            maxlength="6"
          />
          <button
            @click="handleJoin"
            class="btn btn-primary"
            :disabled="roomStore.loading || !joinCode.trim()"
          >
            Rejoindre
          </button>
        </div>

        <div class="join-hint">
          <span>💡</span>
          <span>Le code est affiché dans la room de votre ami</span>
        </div>
      </div>
    </div>

    <p v-if="localError" class="error-message center-error">{{ localError }}</p>

    <!-- Infos -->
    <div class="lobby-info card">
      <h3>🎮 Comment ça marche ?</h3>
      <div class="info-steps">
        <div class="info-step">
          <span class="step-number">1</span>
          <span>Créez une room ou rejoignez celle d'un ami</span>
        </div>
        <div class="info-step">
          <span class="step-number">2</span>
          <span>L'hôte peut modifier les options en jeu</span>
        </div>
        <div class="info-step">
          <span class="step-number">3</span>
          <span>Répondez aux questions et gagnez des points</span>
        </div>
        <div class="info-step">
          <span class="step-number">4</span>
          <span>Le joueur 2 peut proposer des questions</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.lobby {
  max-width: 900px;
  margin: 0 auto;
}

/* Option groups */
.option-group {
  margin-bottom: 1rem;
}

.option-label {
  display: block;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}

/* Category selector */
.category-selector {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.cat-btn {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.5rem 0.75rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.2s;
}

.cat-btn:hover {
  border-color: #9b59b6;
}

.cat-btn.active {
  border-color: #9b59b6;
  background: #f3e5f5;
  color: #9b59b6;
}

/* Create button */
.btn-create {
  width: 100%;
  padding: 1rem;
  font-size: 1.1rem;
  margin-top: 0.5rem;
}

/* Join section */
.join-section {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.join-input {
  text-transform: uppercase;
  font-family: monospace;
  font-size: 1.2rem;
  letter-spacing: 2px;
  text-align: center;
}

.join-hint {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-top: 1rem;
  font-size: 0.85rem;
  color: #7f8c8d;
}

/* Info steps */
.info-steps {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.info-step {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.step-number {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #3498db;
  color: white;
  border-radius: 50%;
  font-weight: 600;
  font-size: 0.9rem;
  flex-shrink: 0;
}

.lobby-title {
  text-align: center;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.lobby-subtitle {
  text-align: center;
  color: #7f8c8d;
  margin-bottom: 2rem;
}

.lobby-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.lobby-section {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.lobby-section h2 {
  margin: 0;
  color: #2c3e50;
}

.lobby-section p {
  margin: 0;
  color: #7f8c8d;
}

.language-selector {
  display: flex;
  gap: 0.5rem;
}

.lang-btn {
  flex: 1;
  padding: 1rem;
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
  border-color: #27ae60;
  background: #e8f8f0;
}

.join-form {
  display: flex;
  gap: 0.5rem;
}

.join-form .input {
  flex: 1;
}

.center-error {
  text-align: center;
  margin-top: 1rem;
}

.lobby-info {
  margin-top: 2rem;
  background: #f8f9fa;
}

.lobby-info h3 {
  margin-top: 0;
  color: #2c3e50;
}

.lobby-info ol {
  margin: 0;
  padding-left: 1.5rem;
  color: #555;
}

.lobby-info li {
  margin-bottom: 0.5rem;
}

/* Responsive */
@media (max-width: 768px) {
  .lobby {
    padding: 1rem;
  }
  
  .lobby-title {
    font-size: 1.5rem;
  }
  
  .lobby-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .lang-btn {
    padding: 0.75rem;
    font-size: 0.95rem;
  }
  
  .mode-selector {
    grid-template-columns: repeat(4, 1fr);
  }
  
  .mode-btn {
    padding: 0.5rem;
  }
  
  .mode-label {
    display: none;
  }
  
  .mode-icon {
    font-size: 1.3rem;
  }
  
  .info-steps {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 480px) {
  .lobby {
    padding: 0.75rem;
  }
  
  .lobby-title {
    font-size: 1.3rem;
  }
  
  .lobby-subtitle {
    font-size: 0.95rem;
    margin-bottom: 1.5rem;
  }
  
  .lobby-section {
    padding: 1rem;
  }
  
  .lobby-section h2 {
    font-size: 1.1rem;
  }
  
  .join-form {
    flex-direction: column;
  }
  
  .join-form .btn {
    width: 100%;
  }
  
  .lobby-info {
    padding: 1rem;
  }
  
  .lobby-info h3 {
    font-size: 1rem;
  }
  
  .mode-selector {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .mode-label {
    display: block;
    font-size: 0.75rem;
  }
  
  .category-selector {
    justify-content: center;
  }
  
  .cat-btn {
    padding: 0.4rem 0.6rem;
    font-size: 0.8rem;
  }
  
  .difficulty-selector {
    justify-content: center;
  }
  
  .diff-btn {
    padding: 0.4rem 0.6rem;
    font-size: 0.8rem;
  }
  
  .info-steps {
    grid-template-columns: 1fr;
  }
  
  .info-step {
    font-size: 0.9rem;
  }
  
  .btn-create {
    padding: 0.9rem;
    font-size: 1rem;
  }
}
</style>
