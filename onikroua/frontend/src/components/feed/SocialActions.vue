<template>
  <div class="social-actions">
    <div class="actions-left">
      <button 
        :class="['action-btn', 'like-btn', { active: isLiked }]"
        @click="toggleLike"
      >
        <span class="action-icon">{{ isLiked ? '❤️' : '🤍' }}</span>
        <span v-if="likeCount > 0" class="action-count">{{ formatCount(likeCount) }}</span>
      </button>

      <button 
        class="action-btn comment-btn"
        @click="$emit('comment')"
      >
        <span class="action-icon">💬</span>
        <span v-if="commentCount > 0" class="action-count">{{ formatCount(commentCount) }}</span>
      </button>

      <button 
        class="action-btn share-btn"
        @click="$emit('share')"
      >
        <span class="action-icon">📤</span>
      </button>
    </div>

    <div class="actions-right">
      <button 
        :class="['action-btn', 'bookmark-btn', { active: isBookmarked }]"
        @click="toggleBookmark"
      >
        <span class="action-icon">{{ isBookmarked ? '🔖' : '📑' }}</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{
  initialLiked?: boolean
  initialBookmarked?: boolean
  initialLikeCount?: number
  initialCommentCount?: number
}>()

const emit = defineEmits<{
  like: [liked: boolean]
  bookmark: [bookmarked: boolean]
  comment: []
  share: []
}>()

const isLiked = ref(props.initialLiked || false)
const isBookmarked = ref(props.initialBookmarked || false)
const likeCount = ref(props.initialLikeCount || 0)
const commentCount = ref(props.initialCommentCount || 0)

const toggleLike = () => {
  isLiked.value = !isLiked.value
  likeCount.value += isLiked.value ? 1 : -1
  emit('like', isLiked.value)
  
  // Animation du like
  if (isLiked.value) {
    triggerLikeAnimation()
  }
}

const toggleBookmark = () => {
  isBookmarked.value = !isBookmarked.value
  emit('bookmark', isBookmarked.value)
}

const triggerLikeAnimation = () => {
  // Créer une animation de coeur qui pulse
  const btn = document.querySelector('.like-btn')
  if (btn) {
    btn.classList.add('pulse')
    setTimeout(() => btn.classList.remove('pulse'), 600)
  }
}

const formatCount = (count: number): string => {
  if (count >= 1000000) {
    return (count / 1000000).toFixed(1) + 'M'
  } else if (count >= 1000) {
    return (count / 1000).toFixed(1) + 'K'
  }
  return count.toString()
}
</script>

<style scoped>
.social-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  margin-top: 0.75rem;
  background: linear-gradient(180deg, transparent 0%, rgba(250, 250, 250, 0.5) 100%);
}

.actions-left,
.actions-right {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 12px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  min-width: 44px;
  min-height: 44px;
  justify-content: center;
  position: relative;
}

.action-btn::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 12px;
  background: currentColor;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.action-btn:hover::before {
  opacity: 0.08;
}

.action-btn:active {
  transform: scale(0.9);
}


.action-icon {
  font-size: 1.5rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  z-index: 1;
}

.action-btn:hover .action-icon {
  transform: scale(1.1);
}

.action-count {
  font-size: 0.9rem;
  font-weight: 600;
  color: #374151;
  position: relative;
  z-index: 1;
  transition: all 0.3s ease;
}

/* Like button */
.like-btn {
  color: #6b7280;
}

.like-btn.active {
  color: #E1306C;
}

.like-btn.active .action-icon {
  animation: heartBeat 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  filter: drop-shadow(0 2px 4px rgba(225, 48, 108, 0.3));
}

.like-btn.pulse .action-icon {
  animation: heartPulse 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}

.like-btn.active .action-count {
  color: #E1306C;
}

@keyframes heartBeat {
  0%, 100% { transform: scale(1); }
  25% { transform: scale(1.3) rotate(-5deg); }
  50% { transform: scale(1.1) rotate(5deg); }
  75% { transform: scale(1.2) rotate(-3deg); }
}

@keyframes heartPulse {
  0% { transform: scale(1); }
  30% { transform: scale(1.5); }
  60% { transform: scale(1.1); }
  100% { transform: scale(1); }
}

/* Bookmark button */
.bookmark-btn {
  color: #6b7280;
}

.bookmark-btn.active {
  color: #f59e0b;
}

.bookmark-btn.active .action-icon {
  animation: bookmarkFlip 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  filter: drop-shadow(0 2px 4px rgba(245, 158, 11, 0.3));
}

@keyframes bookmarkFlip {
  0% { transform: rotateY(0deg) scale(1); }
  50% { transform: rotateY(180deg) scale(1.2); }
  100% { transform: rotateY(360deg) scale(1); }
}

/* Comment button */
.comment-btn {
  color: #6b7280;
}

.comment-btn:hover {
  color: #3b82f6;
}

.comment-btn:active .action-icon {
  animation: commentBounce 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes commentBounce {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.15) rotate(-5deg); }
}

/* Share button */
.share-btn {
  color: #6b7280;
}

.share-btn:hover {
  color: #10b981;
}

.share-btn:active .action-icon {
  animation: shareFloat 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes shareFloat {
  0% { transform: translateY(0); }
  30% { transform: translateY(-8px) scale(1.1); }
  60% { transform: translateY(-4px); }
  100% { transform: translateY(0); }
}

/* Responsive */
@media (max-width: 768px) {
  .social-actions {
    padding: 0.5rem 0;
  }
  
  .actions-left,
  .actions-right {
    gap: 0.5rem;
  }
  
  .action-btn {
    padding: 0.4rem;
    min-width: 40px;
    min-height: 40px;
  }
  
  .action-icon {
    font-size: 1.35rem;
  }
  
  .action-count {
    font-size: 0.85rem;
  }
}
</style>
