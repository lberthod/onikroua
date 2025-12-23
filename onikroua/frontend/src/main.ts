import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { useAuthStore } from './stores/auth'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Initialise l'auth listener avant de monter l'app
const authStore = useAuthStore()
authStore.init().then(() => {
  app.mount('#app')
})
