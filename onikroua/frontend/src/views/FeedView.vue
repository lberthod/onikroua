<template>
  <div class="feed-container">
    <!-- Stories Bar -->
    <StoriesBar @story-click="handleStoryClick" />

    <!-- Language Toggle (compact mobile) -->
    <div class="language-toggle-compact">
      <button 
        :class="['lang-btn-compact', { active: currentLanguage === 'it' }]"
        @click="setLanguage('it')"
      >
        🇮🇹
      </button>
      <button 
        :class="['lang-btn-compact', { active: currentLanguage === 'es' }]"
        @click="setLanguage('es')"
      >
        🇪🇸
      </button>
    </div>

    <!-- Swipeable Feed Content -->
    <div 
      class="feed-swiper" 
      ref="feedSwiper"
      @touchstart="handleTouchStart"
      @touchmove="handleTouchMove"
      @touchend="handleTouchEnd"
      @mousedown="handleMouseDown"
    >
      <div 
        class="feed-track"
        :style="{
          transform: `translateY(${-currentIndex * 100}vh)`,
          transition: isTransitioning ? 'transform 0.4s cubic-bezier(0.4, 0, 0.2, 1)' : 'none'
        }"
      >
        <div
          v-for="(item, index) in feedItems"
          :key="item.id"
          class="feed-slide"
          :class="{ active: index === currentIndex }"
        >
          <div class="feed-card-wrapper">
            <!-- Grammaire -->
            <FeedGrammarCard 
              v-if="item.type === 'grammar'"
              :item="item"
              :language="currentLanguage"
            />
            
            <!-- Vocabulaire -->
            <FeedVocabularyCard 
              v-if="item.type === 'vocabulary'"
              :item="item"
              :language="currentLanguage"
            />
            
            <!-- Phonétique -->
            <FeedPhoneticCard 
              v-if="item.type === 'phonetic'"
              :item="item"
              :language="currentLanguage"
            />
            
            <!-- Conjugaison -->
            <FeedConjugationCard 
              v-if="item.type === 'conjugation'"
              :item="item"
              :language="currentLanguage"
            />
            
            <!-- Quiz -->
            <FeedQuizCard 
              v-if="item.type === 'quiz'"
              :item="item"
              :language="currentLanguage"
            />

            <!-- Social Actions -->
            <SocialActions 
              :initial-liked="item.liked"
              :initial-bookmarked="item.bookmarked"
              :initial-like-count="item.likeCount || 0"
              :initial-comment-count="item.commentCount || 0"
              @like="(liked) => handleLike(item.id, liked)"
              @bookmark="(bookmarked) => handleBookmark(item.id, bookmarked)"
              @comment="handleComment(item.id)"
              @share="handleShare(item.id)"
            />
          </div>

          <!-- Swipe Indicator -->
          <div class="swipe-indicator" v-if="index === currentIndex && feedItems.length > 1">
            <div class="indicator-dot" v-for="i in Math.min(feedItems.length, 5)" :key="i" :class="{ active: i - 1 === currentIndex }"></div>
          </div>
        </div>
      </div>

      <!-- Loading indicator -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner"></div>
      </div>
    </div>

    <!-- Bottom Navigation -->
    <BottomNav :active-tab="'feed'" @navigate="handleNavigation" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { feedService, type FeedItem } from '../services/feedService'
import FeedGrammarCard from '../components/feed/FeedGrammarCard.vue'
import FeedVocabularyCard from '../components/feed/FeedVocabularyCard.vue'
import FeedPhoneticCard from '../components/feed/FeedPhoneticCard.vue'
import FeedConjugationCard from '../components/feed/FeedConjugationCard.vue'
import FeedQuizCard from '../components/feed/FeedQuizCard.vue'
import StoriesBar from '../components/feed/StoriesBar.vue'
import SocialActions from '../components/feed/SocialActions.vue'
import BottomNav from '../components/layout/BottomNav.vue'

const currentLanguage = ref<'it' | 'es'>('it')
const feedItems = ref<FeedItem[]>([])
const loading = ref(false)
const hasMore = ref(true)
const currentIndex = ref(0)
const isTransitioning = ref(false)

// Touch/Swipe state
const touchStartY = ref(0)
const touchCurrentY = ref(0)
const isDragging = ref(false)
const isMouseDragging = ref(false)

const setLanguage = (language: 'it' | 'es') => {
  currentLanguage.value = language
  feedService.setLanguage(language)
  feedItems.value = []
  currentIndex.value = 0
  hasMore.value = true
  loadMoreItems()
}

const loadMoreItems = async () => {
  if (loading.value || !hasMore.value) return
  
  loading.value = true
  
  await new Promise(resolve => setTimeout(resolve, 300))
  
  try {
    const newItems = feedService.getNextPage()
    feedItems.value.push(...newItems)
    hasMore.value = feedService.hasMore()
  } catch (error) {
    console.error('Erreur lors du chargement des items:', error)
  } finally {
    loading.value = false
  }
}

// Swipe Gestures - Touch
const handleTouchStart = (e: TouchEvent) => {
  touchStartY.value = e.touches[0].clientY
  isDragging.value = true
}

const handleTouchMove = (e: TouchEvent) => {
  if (!isDragging.value) return
  touchCurrentY.value = e.touches[0].clientY
}

const handleTouchEnd = () => {
  if (!isDragging.value) return
  
  const diff = touchStartY.value - touchCurrentY.value
  const threshold = 50
  
  if (Math.abs(diff) > threshold) {
    if (diff > 0) {
      // Swipe up - next card
      goToNext()
    } else {
      // Swipe down - previous card
      goToPrevious()
    }
  }
  
  isDragging.value = false
  touchStartY.value = 0
  touchCurrentY.value = 0
}

// Swipe Gestures - Mouse (desktop)
const handleMouseDown = (e: MouseEvent) => {
  touchStartY.value = e.clientY
  isMouseDragging.value = true
  
  const handleMouseMove = (moveEvent: MouseEvent) => {
    if (!isMouseDragging.value) return
    touchCurrentY.value = moveEvent.clientY
  }
  
  const handleMouseUp = () => {
    if (!isMouseDragging.value) return
    
    const diff = touchStartY.value - touchCurrentY.value
    const threshold = 50
    
    if (Math.abs(diff) > threshold) {
      if (diff > 0) {
        goToNext()
      } else {
        goToPrevious()
      }
    }
    
    isMouseDragging.value = false
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
  }
  
  document.addEventListener('mousemove', handleMouseMove)
  document.addEventListener('mouseup', handleMouseUp)
}

const goToNext = () => {
  if (isTransitioning.value) return
  
  if (currentIndex.value < feedItems.value.length - 1) {
    isTransitioning.value = true
    currentIndex.value++
    setTimeout(() => {
      isTransitioning.value = false
    }, 400)
    
    // Charger plus si proche de la fin
    if (currentIndex.value >= feedItems.value.length - 2) {
      loadMoreItems()
    }
  }
}

const goToPrevious = () => {
  if (isTransitioning.value) return
  
  if (currentIndex.value > 0) {
    isTransitioning.value = true
    currentIndex.value--
    setTimeout(() => {
      isTransitioning.value = false
    }, 400)
  }
}

// Keyboard navigation
const handleKeyDown = (e: KeyboardEvent) => {
  if (e.key === 'ArrowDown' || e.key === 'ArrowRight') {
    e.preventDefault()
    goToNext()
  } else if (e.key === 'ArrowUp' || e.key === 'ArrowLeft') {
    e.preventDefault()
    goToPrevious()
  }
}

// Social Actions Handlers
const handleLike = (itemId: string, liked: boolean) => {
  const item = feedItems.value.find(i => i.id === itemId)
  if (item) {
    item.liked = liked
    item.likeCount = (item.likeCount || 0) + (liked ? 1 : -1)
  }
}

const handleBookmark = (itemId: string, bookmarked: boolean) => {
  const item = feedItems.value.find(i => i.id === itemId)
  if (item) {
    item.bookmarked = bookmarked
  }
}

const handleComment = (itemId: string) => {
  console.log('Comment on:', itemId)
}

const handleShare = (itemId: string) => {
  console.log('Share:', itemId)
}

const handleStoryClick = (storyId: string) => {
  console.log('Story clicked:', storyId)
}

const handleNavigation = (tab: string) => {
  console.log('Navigate to:', tab)
}

onMounted(() => {
  feedService.setLanguage(currentLanguage.value)
  loadMoreItems()
  window.addEventListener('keydown', handleKeyDown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown)
})
</script>

<style scoped>
/* ========== MOBILE-FIRST FULL-SCREEN LAYOUT ========== */
.feed-container {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  background: #FAFAFA;
  display: flex;
  flex-direction: column;
}

/* Language Toggle - Compact Mobile */
.language-toggle-compact {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  display: flex;
  gap: 0.5rem;
  z-index: 200;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 0.25rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.language-toggle-compact:hover {
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
}

.lang-btn-compact {
  width: 40px;
  height: 40px;
  border: none;
  background: transparent;
  border-radius: 16px;
  cursor: pointer;
  font-size: 1.5rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.lang-btn-compact::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 16px;
  background: linear-gradient(135deg, #E1306C, #FD1D1D);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.lang-btn-compact:hover::before {
  opacity: 0.1;
}

.lang-btn-compact:active {
  transform: scale(0.9);
}

.lang-btn-compact.active {
  background: linear-gradient(135deg, #E1306C, #FD1D1D);
  transform: scale(1.05);
  box-shadow: 0 2px 8px rgba(225, 48, 108, 0.3);
}

.lang-btn-compact.active::before {
  opacity: 0;
}

/* ========== SWIPEABLE FEED ========== */
.feed-swiper {
  flex: 1;
  position: relative;
  overflow: hidden;
  width: 100%;
  height: 100%;
  touch-action: pan-y;
  user-select: none;
  -webkit-user-select: none;
}

.feed-track {
  height: 100%;
  will-change: transform;
}

.feed-slide {
  height: 100vh;
  width: 100vw;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
  padding: 0.5rem;
  padding-top: 110px;
  padding-bottom: 70px;
  box-sizing: border-box;
  position: relative;
}

.feed-card-wrapper {
  width: 100%;
  max-width: 600px;
  height: 100%;
  max-height: calc(100vh - 180px);
  overflow-y: auto;
  overflow-x: hidden;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: thin;
  scrollbar-color: rgba(225, 48, 108, 0.3) transparent;
  background: white;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  animation: slideInCard 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid rgba(0, 0, 0, 0.04);
}

.feed-card-wrapper::-webkit-scrollbar {
  width: 4px;
}

.feed-card-wrapper::-webkit-scrollbar-track {
  background: transparent;
}

.feed-card-wrapper::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, rgba(225, 48, 108, 0.3), rgba(253, 29, 29, 0.3));
  border-radius: 2px;
}

.feed-card-wrapper::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, rgba(225, 48, 108, 0.5), rgba(253, 29, 29, 0.5));
}

@keyframes slideInCard {
  from {
    opacity: 0;
    transform: scale(0.95) translateY(20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

/* Swipe Indicators */
.swipe-indicator {
  position: absolute;
  bottom: 72px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 0.4rem;
  z-index: 10;
}

.indicator-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.15);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.indicator-dot.active {
  background: linear-gradient(90deg, #E1306C, #FD1D1D);
  width: 20px;
  border-radius: 3px;
  box-shadow: 0 2px 6px rgba(225, 48, 108, 0.4);
}

/* Loading Overlay */
.loading-overlay {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 1000;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid rgba(225, 48, 108, 0.15);
  border-top: 4px solid transparent;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  position: relative;
}

.loading-spinner::before {
  content: '';
  position: absolute;
  inset: -4px;
  border-radius: 50%;
  border: 4px solid transparent;
  border-top-color: #E1306C;
  animation: spin 1.2s linear infinite reverse;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* ========== RESPONSIVE - DESKTOP ========== */
@media (min-width: 768px) {
  .feed-container {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }

  .language-toggle-compact {
    top: 1.5rem;
    right: 1.5rem;
  }

  .lang-btn-compact {
    width: 48px;
    height: 48px;
    font-size: 1.75rem;
  }

  .feed-slide {
    padding: 2rem;
    padding-top: 140px;
    padding-bottom: 100px;
  }

  .feed-card-wrapper {
    max-width: 700px;
    max-height: calc(100vh - 240px);
    border-radius: 24px;
    box-shadow: 0 12px 48px rgba(0, 0, 0, 0.2);
  }

  .swipe-indicator {
    bottom: 100px;
  }

  .indicator-dot {
    width: 10px;
    height: 10px;
  }

  .indicator-dot.active {
    width: 28px;
  }
}

/* ========== ANIMATIONS ========== */
@media (prefers-reduced-motion: reduce) {
  .feed-card-wrapper,
  .indicator-dot,
  .lang-btn-compact {
    animation: none;
    transition: none;
  }
}

/* Touch feedback */
.feed-swiper:active {
  cursor: grabbing;
}

/* Safe area for notch devices */
@supports (padding-top: env(safe-area-inset-top)) {
  .feed-slide {
    padding-top: calc(120px + env(safe-area-inset-top));
    padding-bottom: calc(80px + env(safe-area-inset-bottom));
  }
}
</style>
