<script setup lang="ts">
import { ref, computed } from 'vue'
import { ttsService, getTTSLang } from '../../services/tts'
import AudioVisualizer from './AudioVisualizer.vue'

interface Props {
  sound: string           // Le son/graphie (ex: "CH")
  phonetic: string        // Symbole phonétique (ex: "/k/")
  description: string     // Description en français
  examples: string[]      // Exemples de mots
  language: 'it' | 'es'
  category?: string       // Catégorie (voyelle, consonne, etc.)
  tips?: string           // Conseils de prononciation
  commonMistakes?: string // Erreurs fréquentes
}

const props = defineProps<Props>()

const isPlaying = ref(false)
const currentExample = ref<string | null>(null)

const ttsLang = computed(() => getTTSLang(props.language))

const playSound = async (text: string) => {
  if (isPlaying.value) {
    ttsService.stop()
    isPlaying.value = false
    currentExample.value = null
    return
  }

  try {
    isPlaying.value = true
    currentExample.value = text
    await ttsService.speak(text, { lang: ttsLang.value, rate: 0.7 })
  } catch (error) {
    console.error('Erreur TTS:', error)
  } finally {
    isPlaying.value = false
    currentExample.value = null
  }
}

const playAllExamples = async () => {
  for (const example of props.examples) {
    await playSound(example)
    // Petite pause entre les exemples
    await new Promise(resolve => setTimeout(resolve, 500))
  }
}

const languageFlag = computed(() => props.language === 'it' ? '🇮🇹' : '🇪🇸')
</script>

<template>
  <div class="sound-card">
    <div class="sound-header">
      <div class="sound-main">
        <span class="sound-graphie">{{ sound }}</span>
        <span class="sound-phonetic">{{ phonetic }}</span>
      </div>
      <span class="sound-lang">{{ languageFlag }}</span>
    </div>

    <p class="sound-description">{{ description }}</p>

    <div class="sound-category" v-if="category">
      <span class="category-tag">{{ category }}</span>
    </div>

    <div class="advice-section" v-if="tips || commonMistakes">
      <div v-if="tips" class="advice-box tip">
        <strong>💡 Conseil :</strong> {{ tips }}
      </div>
      <div v-if="commonMistakes" class="advice-box mistake">
        <strong>⚠️ Attention :</strong> {{ commonMistakes }}
      </div>
    </div>

    <div class="examples-section">
      <div class="examples-header">
        <strong>Exemples :</strong>
        <div class="header-controls">
          <AudioVisualizer :is-active="isPlaying" />
          <button 
            class="play-all-btn" 
            @click="playAllExamples"
            :disabled="isPlaying"
            title="Écouter tous les exemples"
          >
            🔊 Tout écouter
          </button>
        </div>
      </div>
      
      <div class="examples-list">
        <button 
          v-for="(example, index) in examples" 
          :key="index"
          class="example-btn"
          :class="{ playing: currentExample === example }"
          @click="playSound(example)"
        >
          <span class="example-text">{{ example }}</span>
          <span class="play-icon">{{ currentExample === example ? '⏹️' : '▶️' }}</span>
        </button>
      </div>
    </div>

    <div class="tts-notice" v-if="!ttsService.isAvailable()">
      ⚠️ TTS non disponible sur ce navigateur
    </div>
  </div>
</template>

<style scoped>
.sound-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.2s;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.sound-card:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.sound-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.sound-main {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.sound-graphie {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2c3e50;
  font-family: 'Georgia', serif;
}

.sound-phonetic {
  font-size: 1.25rem;
  color: #9b59b6;
  font-family: monospace;
  background: #f3e5f5;
  padding: 0.25rem 0.75rem;
  border-radius: 6px;
}

.sound-lang {
  font-size: 1.5rem;
}

.sound-description {
  color: #5d6d7e;
  margin: 0 0 1rem 0;
  line-height: 1.5;
  flex-grow: 1;
}

.sound-category {
  margin-bottom: 1rem;
}

.category-tag {
  display: inline-block;
  background: #e8f4fc;
  color: #3498db;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.85rem;
  font-weight: 500;
}

.advice-section {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.advice-box {
  padding: 0.75rem;
  border-radius: 6px;
  font-size: 0.9rem;
  line-height: 1.4;
}

.advice-box strong {
  display: block;
  margin-bottom: 0.25rem;
}

.tip {
  background: #fff8e1;
  color: #f57f17;
  border-left: 3px solid #ffca28;
}

.mistake {
  background: #ffebee;
  color: #c62828;
  border-left: 3px solid #ef5350;
}

.examples-section {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 1rem;
}

.examples-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.header-controls {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.examples-header strong {
  color: #2c3e50;
}

.play-all-btn {
  background: #9b59b6;
  color: white;
  border: none;
  padding: 0.4rem 0.75rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.2s;
  white-space: nowrap;
}

.play-all-btn:hover:not(:disabled) {
  background: #8e44ad;
}

.play-all-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.examples-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.example-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: white;
  border: 1px solid #ddd;
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.95rem;
}

.example-btn:hover {
  border-color: #9b59b6;
  background: #faf5fc;
}

.example-btn.playing {
  background: #9b59b6;
  color: white;
  border-color: #9b59b6;
}

.example-text {
  font-weight: 500;
}

.play-icon {
  font-size: 0.8rem;
}

.tts-notice {
  margin-top: 1rem;
  padding: 0.5rem;
  background: #fff3cd;
  color: #856404;
  border-radius: 4px;
  font-size: 0.85rem;
  text-align: center;
}

/* Responsive */
@media (max-width: 768px) {
  .sound-card {
    padding: 1.25rem;
  }
  
  .sound-graphie {
    font-size: 2rem;
  }
  
  .sound-phonetic {
    font-size: 1.1rem;
  }
  
  .advice-box {
    padding: 0.6rem;
    font-size: 0.85rem;
  }
  
  .examples-section {
    padding: 0.75rem;
  }
  
  .example-btn {
    padding: 0.4rem 0.6rem;
    font-size: 0.9rem;
  }
}

@media (max-width: 480px) {
  .sound-card {
    padding: 1rem;
  }
  
  .sound-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .sound-graphie {
    font-size: 1.75rem;
  }
  
  .sound-phonetic {
    font-size: 1rem;
    padding: 0.2rem 0.5rem;
  }
  
  .sound-description {
    font-size: 0.9rem;
  }
  
  .examples-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .header-controls {
    width: 100%;
    justify-content: space-between;
  }
  
  .examples-list {
    gap: 0.35rem;
  }
  
  .example-btn {
    padding: 0.35rem 0.5rem;
    font-size: 0.85rem;
  }
}
</style>
