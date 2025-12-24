import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import LoginView from '../views/LoginView.vue'
import LobbyView from '../views/LobbyView.vue'
import RoomView from '../views/RoomView.vue'
import DashboardView from '../views/DashboardView.vue'
import ConjugaisonView from '../views/ConjugaisonView.vue'
import VocabulaireView from '../views/VocabulaireView.vue'
import GrammaireView from '../views/GrammaireView.vue'
import PhonetiqueView from '../views/PhonetiqueView.vue'
import ProfileView from '../views/ProfileView.vue'
import EmojiLearnView from '../views/EmojiLearnView.vue'
import ConversationView from '../views/ConversationView.vue'
import AITutorView from '../views/AITutorView.vue'
import FeedView from '../views/FeedView.vue'
import RobotView from '../views/RobotView.vue'
import RobotViewOptimized from '../views/RobotViewOptimized.vue'
import GeminiChatView from '../views/GeminiChatView.vue'
import GeminiLiveView from '../views/GeminiLiveView.vue'

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/login',
    name: 'login',
    component: LoginView,
    meta: { requiresGuest: true }
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: DashboardView,
    meta: { requiresAuth: true }
  },
  {
    path: '/lobby',
    name: 'lobby',
    component: LobbyView,
    meta: { requiresAuth: true }
  },
  {
    path: '/room/:roomId',
    name: 'room',
    component: RoomView,
    meta: { requiresAuth: true }
  },
  {
    path: '/conjugaison',
    name: 'conjugaison',
    component: ConjugaisonView,
    meta: { requiresAuth: true }
  },
  {
    path: '/vocabulaire',
    name: 'vocabulaire',
    component: VocabulaireView,
    meta: { requiresAuth: true }
  },
  {
    path: '/grammaire',
    name: 'grammaire',
    component: GrammaireView,
    meta: { requiresAuth: true }
  },
  {
    path: '/phonetique',
    name: 'phonetique',
    component: PhonetiqueView,
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'profile',
    component: ProfileView,
    meta: { requiresAuth: true }
  },
  {
    path: '/emoji',
    name: 'emoji',
    component: EmojiLearnView,
    meta: { requiresAuth: true }
  },
  {
    path: '/conversations',
    name: 'conversations',
    component: ConversationView,
    meta: { requiresAuth: true }
  },
  {
    path: '/ai-tutor',
    name: 'ai-tutor',
    component: AITutorView,
    meta: { requiresAuth: true }
  },
  {
    path: '/feed',
    name: 'feed',
    component: FeedView,
    meta: { requiresAuth: true }
  },
  {
    path: '/robot',
    name: 'robot',
    component: RobotViewOptimized,
    meta: { requiresAuth: true }
  },
  {
    path: '/robot-old',
    name: 'robot-old',
    component: RobotView,
    meta: { requiresAuth: true }
  },
  {
    path: '/gemini-chat',
    name: 'gemini-chat',
    component: GeminiChatView,
    meta: { requiresAuth: true }
  },
  {
    path: '/gemini-live',
    name: 'gemini-live',
    component: GeminiLiveView,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guard
router.beforeEach(async (to, _from, next) => {
  const authStore = useAuthStore()

  // S'assurer que l'état d'authentification est initialisé avant de décider
  if (authStore.loading) {
    await authStore.init()
  }

  if (to.meta.requiresAuth && !authStore.user) {
    next('/login')
  } else if (to.meta.requiresGuest && authStore.user) {
    next('/lobby')
  } else {
    next()
  }
})

export default router
