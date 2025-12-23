import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { User } from 'firebase/auth'
import { registerUser, loginUser, logoutUser, signInWithGoogle, onAuthChange, getIdToken } from '../firebase/auth'
import { updateUserProfile } from '../firebase/db'

export const useAuthStore = defineStore('auth', () => {
  // État
  const user = ref<User | null>(null)
  const loading = ref(true)
  const error = ref<string | null>(null)

  // Initialisation du listener auth
  const init = (): Promise<void> => {
    return new Promise((resolve) => {
      onAuthChange((firebaseUser) => {
        user.value = firebaseUser
        loading.value = false
        resolve()
      })
    })
  }

  // Inscription
  const register = async (email: string, password: string): Promise<void> => {
    try {
      error.value = null
      loading.value = true
      const newUser = await registerUser(email, password)
      // Créer le profil utilisateur
      const displayName = email.split('@')[0]
      await updateUserProfile(newUser.uid, displayName)
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Erreur lors de l\'inscription'
      throw e
    } finally {
      loading.value = false
    }
  }

  // Connexion
  const login = async (email: string, password: string): Promise<void> => {
    try {
      error.value = null
      loading.value = true
      await loginUser(email, password)
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Erreur lors de la connexion'
      throw e
    } finally {
      loading.value = false
    }
  }

  // Connexion Google
  const loginWithGoogle = async (): Promise<void> => {
    try {
      error.value = null
      loading.value = true
      const googleUser = await signInWithGoogle()
      // Créer/mettre à jour le profil utilisateur
      const displayName = googleUser.displayName || googleUser.email?.split('@')[0] || 'Utilisateur'
      await updateUserProfile(googleUser.uid, displayName)
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Erreur lors de la connexion Google'
      throw e
    } finally {
      loading.value = false
    }
  }

  // Déconnexion
  const logout = async (): Promise<void> => {
    try {
      await logoutUser()
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Erreur lors de la déconnexion'
    }
  }

  // Obtenir le token pour les requêtes API
  const getToken = async (): Promise<string | null> => {
    return getIdToken()
  }

  return {
    user,
    loading,
    error,
    init,
    register,
    login,
    loginWithGoogle,
    logout,
    getToken
  }
})
