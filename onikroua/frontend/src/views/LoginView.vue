<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

// Rediriger si déjà connecté
onMounted(() => {
  if (authStore.user) {
    router.push('/dashboard')
  }
})

const email = ref('')
const password = ref('')
const isRegistering = ref(false)
const localError = ref('')

const handleSubmit = async () => {
  localError.value = ''
  try {
    if (isRegistering.value) {
      await authStore.register(email.value, password.value)
    } else {
      await authStore.login(email.value, password.value)
    }
    router.push('/lobby')
  } catch (e: unknown) {
    localError.value = e instanceof Error ? e.message : 'Une erreur est survenue'
  }
}

const handleGoogleLogin = async () => {
  localError.value = ''
  try {
    await authStore.loginWithGoogle()
    router.push('/lobby')
  } catch (e: unknown) {
    localError.value = e instanceof Error ? e.message : 'Une erreur est survenue avec Google'
  }
}

const toggleMode = () => {
  isRegistering.value = !isRegistering.value
  localError.value = ''
}
</script>

<template>
  <div class="login-container">
    <div class="login-card card">
      <h1 class="login-title">🎓 Onikroua</h1>
      <p class="login-subtitle">Apprenez l'italien et l'espagnol en duo</p>

      <form @submit.prevent="handleSubmit" class="login-form">
        <div class="form-group">
          <label for="email">Email</label>
          <input
            id="email"
            v-model="email"
            type="email"
            class="input"
            placeholder="votre@email.com"
            required
          />
        </div>

        <div class="form-group">
          <label for="password">Mot de passe</label>
          <input
            id="password"
            v-model="password"
            type="password"
            class="input"
            placeholder="••••••••"
            required
            minlength="6"
          />
        </div>

        <p v-if="localError" class="error-message">{{ localError }}</p>

        <button
          type="submit"
          class="btn btn-primary btn-block"
          :disabled="authStore.loading"
        >
          {{ authStore.loading ? 'Chargement...' : (isRegistering ? 'S\'inscrire' : 'Se connecter') }}
        </button>
      </form>

      <!-- Séparateur -->
      <div class="auth-divider">
        <span>ou</span>
      </div>

      <!-- Bouton Google amélioré -->
      <button
        @click="handleGoogleLogin"
        class="btn btn-google btn-block"
        :disabled="authStore.loading"
      >
        <svg class="google-icon" viewBox="0 0 24 24">
          <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
          <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
          <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
          <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
        </svg>
        <span>Se connecter avec Google</span>
      </button>

      <div class="login-toggle">
        <span v-if="isRegistering">Déjà un compte ?</span>
        <span v-else>Pas encore de compte ?</span>
        <button @click="toggleMode" class="link-btn">
          {{ isRegistering ? 'Se connecter' : 'S\'inscrire' }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 80vh;
}

.login-card {
  width: 100%;
  max-width: 400px;
}

.login-title {
  text-align: center;
  font-size: 2rem;
  margin-bottom: 0.5rem;
  color: #2c3e50;
}

.login-subtitle {
  text-align: center;
  color: #7f8c8d;
  margin-bottom: 2rem;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-weight: 500;
  color: #34495e;
}

.btn-block {
  width: 100%;
  margin-top: 0.5rem;
}

.login-toggle {
  text-align: center;
  margin-top: 1.5rem;
  color: #7f8c8d;
}

.link-btn {
  background: none;
  border: none;
  color: #3498db;
  cursor: pointer;
  font-size: 1rem;
  padding: 0;
  margin-left: 0.25rem;
}

.link-btn:hover {
  text-decoration: underline;
}

.auth-divider {
  display: flex;
  align-items: center;
  margin: 1.5rem 0;
  color: #7f8c8d;
}

.auth-divider::before,
.auth-divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: #ddd;
}

.auth-divider span {
  padding: 0 1rem;
  font-size: 0.9rem;
}

.btn-google {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  background: white;
  color: #3c4043;
  border: 1px solid #dadce0;
  font-weight: 500;
  font-size: 0.95rem;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.2s ease;
  margin: 0.5rem 0;
}

.btn-google:hover {
  background: #f8f9fa;
  border-color: #c6c6c6;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
  transform: translateY(-1px);
}

.btn-google:active {
  transform: translateY(0);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.btn-google:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.google-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

/* Responsive */
@media (max-width: 480px) {
  .login-container {
    padding: 1rem;
    min-height: 70vh;
  }
  
  .login-card {
    padding: 1.5rem;
  }
  
  .login-title {
    font-size: 1.75rem;
  }
  
  .login-subtitle {
    font-size: 0.95rem;
    margin-bottom: 1.5rem;
  }
  
  .form-group label {
    font-size: 0.95rem;
  }
  
  .btn-google {
    font-size: 0.9rem;
    padding: 0.7rem;
  }
  
  .google-icon {
    width: 18px;
    height: 18px;
  }
}
</style>
