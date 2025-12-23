import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  GoogleAuthProvider,
  signInWithPopup,
  type User,
  type Unsubscribe
} from 'firebase/auth'
import { auth } from './client'

// Inscription avec email/password
export const registerUser = async (email: string, password: string): Promise<User> => {
  const userCredential = await createUserWithEmailAndPassword(auth, email, password)
  return userCredential.user
}

// Connexion avec email/password
export const loginUser = async (email: string, password: string): Promise<User> => {
  const userCredential = await signInWithEmailAndPassword(auth, email, password)
  return userCredential.user
}

// Déconnexion
export const logoutUser = async (): Promise<void> => {
  await signOut(auth)
}

// Listener d'état auth
export const onAuthChange = (callback: (user: User | null) => void): Unsubscribe => {
  return onAuthStateChanged(auth, callback)
}

// Connexion avec Google
export const signInWithGoogle = async (): Promise<User> => {
  const provider = new GoogleAuthProvider()
  const result = await signInWithPopup(auth, provider)
  return result.user
}

// Récupérer le token ID pour les requêtes API
export const getIdToken = async (): Promise<string | null> => {
  const user = auth.currentUser
  if (!user) return null
  return user.getIdToken()
}
