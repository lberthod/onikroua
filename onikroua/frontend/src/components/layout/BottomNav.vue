<template>
  <nav class="bottom-nav">
    <button 
      v-for="item in navItems" 
      :key="item.id"
      :class="['nav-item', { active: activeTab === item.id }]"
      @click="$emit('navigate', item.id)"
    >
      <span class="nav-icon">{{ item.icon }}</span>
      <span class="nav-label">{{ item.label }}</span>
    </button>
  </nav>
</template>

<script setup lang="ts">
defineProps<{
  activeTab: string
}>()

defineEmits<{
  navigate: [tab: string]
}>()

const navItems = [
  { id: 'feed', icon: '🏠', label: 'Feed' },
  { id: 'search', icon: '🔍', label: 'Recherche' },
  { id: 'add', icon: '➕', label: 'Créer' },
  { id: 'favorites', icon: '❤️', label: 'Favoris' },
  { id: 'profile', icon: '👤', label: 'Profil' }
]
</script>

<style scoped>
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 60px;
  background: linear-gradient(180deg, #fafafa 0%, #ffffff 100%);
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding: 0 0.5rem;
  z-index: 1000;
  box-shadow: 0 -4px 16px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(20px);
}

.nav-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.25rem;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  min-width: 44px;
  min-height: 44px;
  border-radius: 12px;
  position: relative;
}

.nav-item::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 12px;
  background: linear-gradient(135deg, rgba(225, 48, 108, 0.1), rgba(253, 29, 29, 0.1));
  opacity: 0;
  transition: opacity 0.3s ease;
}

.nav-item:hover::before {
  opacity: 1;
}

.nav-item:active {
  transform: scale(0.95);
}

.nav-icon {
  font-size: 1.5rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  z-index: 1;
}

.nav-item.active .nav-icon {
  transform: scale(1.15) translateY(-2px);
  filter: drop-shadow(0 2px 4px rgba(225, 48, 108, 0.3));
}

.nav-label {
  font-size: 0.65rem;
  font-weight: 500;
  color: #6b7280;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  z-index: 1;
  letter-spacing: -0.01em;
}

.nav-item.active .nav-label {
  color: #E1306C;
  font-weight: 700;
  transform: translateY(-1px);
}

.nav-item.active {
  background: linear-gradient(135deg, rgba(225, 48, 108, 0.08), rgba(253, 29, 29, 0.08));
}

.nav-item.active::before {
  opacity: 0;
}

/* Desktop: masquer la bottom nav */
@media (min-width: 768px) {
  .bottom-nav {
    display: none;
  }
}

/* Safe area pour iPhone avec encoche */
@supports (padding-bottom: env(safe-area-inset-bottom)) {
  .bottom-nav {
    padding-bottom: env(safe-area-inset-bottom);
    height: calc(60px + env(safe-area-inset-bottom));
  }
}
</style>
