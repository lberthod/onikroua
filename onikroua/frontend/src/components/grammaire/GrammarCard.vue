<script setup lang="ts">
import { computed } from 'vue'
import { ttsService, getTTSLang } from '../../services/tts'
import type { GrammarItem } from '../../stores/learning'

interface Props {
  rule: GrammarItem
  language: 'it' | 'es'
}

const props = defineProps<Props>()

const ttsLang = computed(() => getTTSLang(props.language))

const playExample = async (text: string) => {
  // On nettoie le texte pour ne garder que la partie dans la langue cible
  // Ex: "il libro (le livre)" -> on veut juste "il libro"
  // Une regex simple pour prendre tout ce qui est avant une parenthèse ouvrante
  const cleanText = text.split('(')[0].trim()
  
  try {
    await ttsService.speak(cleanText, { lang: ttsLang.value, rate: 0.9 })
  } catch (error) {
    console.error('Erreur TTS:', error)
  }
}

const getDifficultyColor = (diff: string) => {
  switch (diff) {
    case 'beginner': return '#27ae60'
    case 'intermediate': return '#f39c12'
    case 'advanced': return '#e74c3c'
    default: return '#95a5a6'
  }
}

const getDifficultyLabel = (diff: string) => {
  switch (diff) {
    case 'beginner': return 'Débutant'
    case 'intermediate': return 'Intermédiaire'
    case 'advanced': return 'Avancé'
    default: return diff
  }
}
</script>

<template>
  <div class="grammar-card">
    <div class="rule-header">
      <h2 class="rule-name">{{ rule.rule }}</h2>
      <span 
        class="difficulty-badge"
        :style="{ backgroundColor: getDifficultyColor(rule.difficulty) }"
      >
        {{ getDifficultyLabel(rule.difficulty) }}
      </span>
    </div>
    
    <p class="rule-content">{{ rule.content }}</p>
    
    <div class="rule-format">
      <strong>📝 Structure :</strong> 
      <code class="format-code">{{ rule.translation }}</code>
    </div>
    
    <div v-if="rule.example" class="example-section">
      <div class="example-header">
        <strong>💡 Exemple :</strong>
        <button 
          class="play-btn"
          @click="playExample(rule.example)"
          title="Écouter l'exemple"
        >
          🔊
        </button>
      </div>
      <p class="example-text">{{ rule.example }}</p>
    </div>
    
    <div v-if="rule.exceptions && rule.exceptions.length > 0" class="exceptions">
      <strong>⚠️ Exceptions :</strong>
      <ul>
        <li v-for="(exc, index) in rule.exceptions" :key="index">{{ exc }}</li>
      </ul>
    </div>
  </div>
</template>

<style scoped>
.grammar-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.2s;
  height: 100%;
}

.grammar-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.rule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.rule-name {
  font-size: 1.25rem;
  color: #2c3e50;
  margin: 0;
  font-weight: 700;
}

.difficulty-badge {
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
}

.rule-content {
  color: #34495e;
  margin-bottom: 1rem;
  line-height: 1.6;
}

.rule-format {
  background: #f8f9fa;
  padding: 0.75rem;
  border-radius: 6px;
  margin-bottom: 1rem;
  border-left: 4px solid #3498db;
}

.format-code {
  font-family: monospace;
  color: #2980b9;
  font-weight: 600;
  margin-left: 0.5rem;
}

.example-section {
  padding: 0.75rem;
  background: #fff8e1;
  border-radius: 6px;
  margin-bottom: 1rem;
  border-left: 4px solid #ffca28;
}

.example-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.play-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1.1rem;
  padding: 0.25rem;
  border-radius: 50%;
  transition: background 0.2s;
}

.play-btn:hover {
  background: rgba(0, 0, 0, 0.1);
}

.example-text {
  margin: 0;
  color: #5d4037;
  font-style: italic;
}

.exceptions {
  padding: 0.75rem;
  background: #ffebee;
  border-radius: 6px;
  border-left: 4px solid #ef5350;
  color: #c62828;
}

.exceptions ul {
  margin: 0.5rem 0 0 1.5rem;
  padding: 0;
}

.exceptions li {
  margin-bottom: 0.25rem;
}

/* Responsive */
@media (max-width: 768px) {
  .grammar-card {
    padding: 1.25rem;
  }
  
  .rule-name {
    font-size: 1.1rem;
  }
  
  .rule-content {
    font-size: 0.95rem;
  }
  
  .format-code {
    display: block;
    margin-top: 0.5rem;
    margin-left: 0;
  }
}

@media (max-width: 480px) {
  .grammar-card {
    padding: 1rem;
    border-radius: 10px;
  }
  
  .rule-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .rule-name {
    font-size: 1rem;
  }
  
  .difficulty-badge {
    font-size: 0.75rem;
    padding: 0.2rem 0.5rem;
  }
  
  .rule-content {
    font-size: 0.9rem;
    margin-bottom: 0.75rem;
  }
  
  .rule-format, .example-section, .exceptions {
    padding: 0.6rem;
    font-size: 0.9rem;
  }
  
  .example-text {
    font-size: 0.9rem;
  }
  
  .exceptions ul {
    margin-left: 1rem;
  }
}
</style>
