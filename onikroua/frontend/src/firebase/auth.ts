import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  GoogleAuthProvider,
  signInWithPopup,
  signInWithCredential,
  type User,
  type Unsubscribe
} from 'firebase/auth'
import { auth } from './client'
import { Capacitor } from '@capacitor/core'
import { GoogleAuth } from '@codetrix-studio/capacitor-google-auth'

// Initialiser Google Auth pour Capacitor
const initGoogleAuth = () => {
  if (Capacitor.isNativePlatform()) {
    GoogleAuth.initialize({
      clientId: '569943827846-9mtqlucqe3qqk0vtkukg3o4lvbg48b5q.apps.googleusercontent.com',
      scopes: ['profile', 'email'],
      grantOfflineAccess: true
    })
  }
}

initGoogleAuth()

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
  if (Capacitor.isNativePlatform()) {
    await GoogleAuth.signOut()
  }
}

// Listener d'état auth
export const onAuthChange = (callback: (user: User | null) => void): Unsubscribe => {
  return onAuthStateChanged(auth, callback)
}

// Connexion avec Google (adapté pour web et mobile)
export const signInWithGoogle = async (): Promise<User> => {
  if (Capacitor.isNativePlatform()) {
    const googleUser = await GoogleAuth.signIn()
    
    const credential = GoogleAuthProvider.credential(googleUser.authentication.idToken)
    const result = await signInWithCredential(auth, credential)
    return result.user
  } else {
    const provider = new GoogleAuthProvider()
    const result = await signInWithPopup(auth, provider)
    return result.user
  }
}

// Récupérer le token ID pour les requêtes API
export const getIdToken = async (): Promise<string | null> => {
  const user = auth.currentUser
  if (!user) return null
  return user.getIdToken()
}
