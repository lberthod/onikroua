<template>
  <div class="stories-bar">
    <div class="stories-container" ref="storiesContainer">
      <div 
        v-for="story in stories" 
        :key="story.id"
        :class="['story-item', { active: story.viewed }]"
        @click="$emit('story-click', story.id)"
      >
        <div class="story-avatar">
          <div class="avatar-ring" :style="{ borderColor: story.color }">
            <span class="avatar-icon">{{ story.icon }}</span>
          </div>
          <div v-if="story.progress" class="progress-indicator">
            <div class="progress-bar" :style="{ width: story.progress + '%' }"></div>
          </div>
        </div>
        <span class="story-label">{{ story.label }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

defineEmits<{
  'story-click': [id: string]
}>()

const stories = ref([
  { id: 'grammar', icon: '📖', label: 'Grammaire', color: '#6366f1', progress: 65, viewed: false },
  { id: 'vocabulary', icon: '📚', label: 'Vocabulaire', color: '#059669', progress: 40, viewed: false },
  { id: 'phonetic', icon: '🗣️', label: 'Phonétique', color: '#f59e0b', progress: 80, viewed: true },
  { id: 'conjugation', icon: '✍️', label: 'Conjugaison', color: '#8b5cf6', progress: 25, viewed: false },
  { id: 'quiz', icon: '🎯', label: 'Quiz', color: '#ef4444', progress: 90, viewed: true },
  { id: 'daily', icon: '⭐', label: 'Du jour', color: '#ec4899', progress: 0, viewed: false }
])
</script>

<style scoped>
.stories-bar {
  background: linear-gradient(180deg, #ffffff 0%, #fafafa 100%);
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  padding: 0.5rem 0;
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(20px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.stories-container {
  display: flex;
  gap: 0.75rem;
  overflow-x: auto;
  overflow-y: hidden;
  padding: 0 0.75rem;
  scroll-behavior: smooth;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
}

.stories-container::-webkit-scrollbar {
  display: none;
}

.story-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.35rem;
  cursor: pointer;
  flex-shrink: 0;
  transition: transform 0.2s ease;
  min-width: 60px;
}

.story-item:active {
  transform: scale(0.95);
}

.story-avatar {
  position: relative;
  width: 56px;
  height: 56px;
}

.avatar-ring {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 2.5px solid;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #ffffff, #f8f9fa);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.story-item:not(.active) .avatar-ring {
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.12);
}

.story-item:hover:not(.active) .avatar-ring {
  transform: scale(1.05);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.16);
}

.story-item.active .avatar-ring {
  border-color: #d1d5db;
  opacity: 0.5;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.avatar-icon {
  font-size: 1.5rem;
}

.progress-indicator {
  position: absolute;
  bottom: -2px;
  left: 50%;
  transform: translateX(-50%);
  width: 90%;
  height: 3px;
  background: #e5e7eb;
  border-radius: 2px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background: linear-gradient(90deg, #E1306C, #FD1D1D, #F77737);
  transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  border-radius: 2px;
  box-shadow: 0 1px 3px rgba(225, 48, 108, 0.3);
}

.story-label {
  font-size: 0.65rem;
  font-weight: 600;
  color: #1f2937;
  text-align: center;
  max-width: 60px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  letter-spacing: -0.01em;
}

.story-item.active .story-label {
  color: #9ca3af;
  font-weight: 500;
}

/* Animation d'entrée */
.story-item {
  animation: slideInStory 0.4s ease forwards;
  opacity: 0;
}

.story-item:nth-child(1) { animation-delay: 0.05s; }
.story-item:nth-child(2) { animation-delay: 0.1s; }
.story-item:nth-child(3) { animation-delay: 0.15s; }
.story-item:nth-child(4) { animation-delay: 0.2s; }
.story-item:nth-child(5) { animation-delay: 0.25s; }
.story-item:nth-child(6) { animation-delay: 0.3s; }

@keyframes slideInStory {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Desktop */
@media (min-width: 768px) {
  .stories-bar {
    padding: 1rem 0;
  }
  
  .stories-container {
    justify-content: center;
    gap: 1.5rem;
  }
  
  .story-item {
    min-width: 80px;
  }
  
  .story-avatar {
    width: 72px;
    height: 72px;
  }
  
  .avatar-icon {
    font-size: 2rem;
  }
  
  .story-label {
    font-size: 0.75rem;
  }
}
</style>
