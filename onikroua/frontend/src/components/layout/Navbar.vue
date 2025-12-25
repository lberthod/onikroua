<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'

const authStore = useAuthStore()
const router = useRouter()

const isMenuOpen = ref(false)

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value
}

const closeMenu = () => {
  isMenuOpen.value = false
}

const handleLogout = async () => {
  closeMenu()
  await authStore.logout()
  router.push('/login')
}

const userName = computed(() => {
  if (authStore.user?.displayName) return authStore.user.displayName
  if (authStore.user?.email) return authStore.user.email.split('@')[0]
  return 'Utilisateur'
})

const navLinks = [
  { path: '/dashboard', label: 'Accueil', icon: '🏠' },
  { path: '/conjugaison', label: 'Conjugaison', icon: '📝' },
  { path: '/vocabulaire', label: 'Vocabulaire', icon: '📚' },
  { path: '/emoji', label: 'Emoji', icon: '😀' },
  { path: '/conversations', label: 'Dialogues', icon: '💬' },
  { path: '/grammaire', label: 'Grammaire', icon: '📖' },
  { path: '/phonetique', label: 'Phonétique', icon: '🎵' },
  { path: '/feed', label: 'Feed', icon: '🎲' },
  { path: '/gemini-live', label: 'Gemini Tutor', icon: '🤖', highlight: true },
  { path: '/lobby', label: 'Quiz Duo', icon: '🎯', highlight: true }
]
</script>

<template>
  <header class="navbar" v-if="authStore.user">
    <div class="navbar-content">
      <!-- Logo -->
      <router-link to="/dashboard" class="logo-link" @click="closeMenu">
        <span class="logo-icon">🎓</span>
        <span class="logo-text">Onikroua</span>
      </router-link>

      <!-- Hamburger Menu (Mobile) -->
      <button class="hamburger" @click="toggleMenu" :class="{ active: isMenuOpen }">
        <span></span>
        <span></span>
        <span></span>
      </button>

      <!-- Navigation -->
      <nav class="nav" :class="{ open: isMenuOpen }">
        <router-link 
          v-for="link in navLinks" 
          :key="link.path"
          :to="link.path" 
          class="nav-link"
          :class="{ highlight: link.highlight }"
          @click="closeMenu"
        >
          <span class="nav-icon">{{ link.icon }}</span>
          <span class="nav-label">{{ link.label }}</span>
        </router-link>

        <!-- User Section (Mobile) -->
        <div class="nav-user-mobile">
          <router-link to="/profile" class="nav-link" @click="closeMenu">
            <span class="nav-icon">👤</span>
            <span class="nav-label">Profil</span>
          </router-link>
          <button class="nav-link logout-btn" @click="handleLogout">
            <span class="nav-icon">🚪</span>
            <span class="nav-label">Déconnexion</span>
          </button>
        </div>
      </nav>

      <!-- User Section (Desktop) -->
      <div class="user-section">
        <router-link to="/profile" class="user-profile">
          <span class="user-avatar">👤</span>
          <span class="user-name">{{ userName }}</span>
        </router-link>
        <button @click="handleLogout" class="logout-btn-desktop" title="Déconnexion">
          🚪
        </button>
      </div>
    </div>

    <!-- Overlay -->
    <div class="nav-overlay" v-if="isMenuOpen" @click="closeMenu"></div>
  </header>
</template>

<style scoped>
.navbar {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  position: sticky;
  top: 0;
  z-index: 1000;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.15);
}

.navbar-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 60px;
}

/* Logo */
.logo-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: white;
}

.logo-icon {
  font-size: 1.5rem;
}

.logo-text {
  font-size: 1.25rem;
  font-weight: 700;
  letter-spacing: -0.5px;
}

/* Hamburger */
.hamburger {
  display: none;
  flex-direction: column;
  justify-content: center;
  gap: 5px;
  width: 30px;
  height: 30px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
  z-index: 1001;
}

.hamburger span {
  display: block;
  width: 100%;
  height: 3px;
  background: white;
  border-radius: 2px;
  transition: all 0.3s;
}

.hamburger.active span:nth-child(1) {
  transform: rotate(45deg) translate(5px, 6px);
}

.hamburger.active span:nth-child(2) {
  opacity: 0;
}

.hamburger.active span:nth-child(3) {
  transform: rotate(-45deg) translate(5px, -6px);
}

/* Navigation */
.nav {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  color: rgba(255, 255, 255, 0.85);
  text-decoration: none;
  padding: 0.5rem 0.75rem;
  border-radius: 8px;
  transition: all 0.2s;
  font-size: 0.9rem;
  font-weight: 500;
  background: none;
  border: none;
  cursor: pointer;
}

.nav-link:hover {
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.nav-link.router-link-active {
  background: rgba(255, 255, 255, 0.15);
  color: white;
}

.nav-link.highlight {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
}

.nav-link.highlight:hover {
  background: linear-gradient(135deg, #e67e22 0%, #d35400 100%);
}

.nav-icon {
  font-size: 1rem;
}

.nav-user-mobile {
  display: none;
}

/* User Section */
.user-section {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: rgba(255, 255, 255, 0.85);
  padding: 0.4rem 0.75rem;
  border-radius: 20px;
  transition: all 0.2s;
  background: rgba(255, 255, 255, 0.1);
}

.user-profile:hover {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

.user-avatar {
  font-size: 1.1rem;
}

.user-name {
  font-size: 0.85rem;
  font-weight: 500;
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.logout-btn-desktop {
  background: rgba(231, 76, 60, 0.2);
  border: none;
  padding: 0.4rem 0.6rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.logout-btn-desktop:hover {
  background: rgba(231, 76, 60, 0.4);
}

/* Overlay */
.nav-overlay {
  display: none;
}

/* Responsive */
@media (max-width: 900px) {
  .nav-label {
    display: none;
  }
  
  .nav-link {
    padding: 0.5rem;
  }
  
  .nav-icon {
    font-size: 1.2rem;
  }
  
  .user-name {
    display: none;
  }
}

@media (max-width: 768px) {
  .hamburger {
    display: flex;
    z-index: 1002;
  }
  
  .nav {
    position: fixed;
    top: 0;
    right: -300px;
    width: 280px;
    height: 100vh;
    height: 100dvh;
    background: linear-gradient(180deg, #2c3e50 0%, #1a252f 100%);
    flex-direction: column;
    align-items: stretch;
    padding: 80px 1.25rem 2rem;
    gap: 0.5rem;
    transition: right 0.35s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: -5px 0 30px rgba(0, 0, 0, 0.4);
    z-index: 1001;
    overflow-y: auto;
  }
  
  .nav.open {
    right: 0;
  }
  
  .nav-link {
    padding: 1rem 1.25rem;
    border-radius: 12px;
    font-size: 1.05rem;
    background: rgba(255, 255, 255, 0.05);
    transition: all 0.2s ease;
  }
  
  .nav-link:hover,
  .nav-link:active {
    background: rgba(255, 255, 255, 0.15);
    transform: translateX(4px);
  }
  
  .nav-link.router-link-active {
    background: rgba(52, 152, 219, 0.3);
    border-left: 3px solid #3498db;
  }
  
  .nav-link.highlight {
    background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
    border-left: none;
  }
  
  .nav-link.highlight:hover {
    background: linear-gradient(135deg, #e67e22 0%, #d35400 100%);
    transform: translateX(4px);
  }
  
  .nav-label {
    display: inline;
  }
  
  .nav-icon {
    font-size: 1.3rem;
    width: 32px;
    text-align: center;
  }
  
  .nav-user-mobile {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    margin-top: auto;
    padding-top: 1.5rem;
    border-top: 1px solid rgba(255, 255, 255, 0.15);
  }
  
  .user-section {
    display: none;
  }
  
  .nav-overlay {
    display: block;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    height: 100dvh;
    background: rgba(0, 0, 0, 0.6);
    z-index: 1000;
    backdrop-filter: blur(2px);
    -webkit-backdrop-filter: blur(2px);
  }
  
  .logout-btn {
    color: #e74c3c;
    background: rgba(231, 76, 60, 0.1) !important;
  }
  
  .logout-btn:hover {
    background: rgba(231, 76, 60, 0.2) !important;
  }
}
</style>
