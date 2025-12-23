<script setup lang="ts">
import { computed } from 'vue'

// Version depuis package.json (injectée par Vite)
const appVersion = __APP_VERSION__

const currentYear = computed(() => new Date().getFullYear())
</script>

<template>
  <footer class="footer">
    <div class="footer-content">
      <div class="footer-main">
        <div class="footer-brand">
          <span class="footer-logo">🎓 Onikroua</span>
          <p class="footer-tagline">Apprenez l'italien et l'espagnol en duo</p>
        </div>
        
        <div class="footer-links">
          <div class="footer-section">
            <h4>Apprendre</h4>
            <router-link to="/conjugaison">Conjugaison</router-link>
            <router-link to="/vocabulaire">Vocabulaire</router-link>
            <router-link to="/grammaire">Grammaire</router-link>
            <router-link to="/phonetique">Phonétique</router-link>
          </div>
          
          <div class="footer-section">
            <h4>Jouer</h4>
            <router-link to="/lobby">Quiz Duo</router-link>
            <router-link to="/profile">Mon Profil</router-link>
          </div>
        </div>
      </div>
      
      <div class="footer-bottom">
        <p class="copyright">© {{ currentYear }} Onikroua. Tous droits réservés.</p>
        <p class="version">Version {{ appVersion }}</p>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.footer {
  background: linear-gradient(135deg, #1a252f 0%, #2c3e50 100%);
  color: rgba(255, 255, 255, 0.8);
  padding: 2rem 1rem 1rem;
  margin-top: auto;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
}

.footer-main {
  display: flex;
  justify-content: space-between;
  gap: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.footer-brand {
  max-width: 300px;
}

.footer-logo {
  font-size: 1.25rem;
  font-weight: 700;
  color: white;
}

.footer-tagline {
  margin: 0.5rem 0 0;
  font-size: 0.9rem;
  color: rgba(255, 255, 255, 0.6);
}

.footer-links {
  display: flex;
  gap: 3rem;
}

.footer-section h4 {
  color: white;
  font-size: 0.9rem;
  margin: 0 0 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.footer-section a {
  display: block;
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  font-size: 0.9rem;
  padding: 0.25rem 0;
  transition: color 0.2s;
}

.footer-section a:hover {
  color: white;
}

.footer-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  font-size: 0.8rem;
  color: rgba(255, 255, 255, 0.5);
}

.copyright, .version {
  margin: 0;
}

.version {
  background: rgba(255, 255, 255, 0.1);
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: monospace;
}

/* Responsive */
@media (max-width: 768px) {
  .footer-main {
    flex-direction: column;
    gap: 1.5rem;
  }
  
  .footer-brand {
    text-align: center;
    max-width: 100%;
  }
  
  .footer-links {
    justify-content: center;
    gap: 2rem;
  }
  
  .footer-section {
    text-align: center;
  }
  
  .footer-bottom {
    flex-direction: column;
    gap: 0.5rem;
    text-align: center;
  }
}

@media (max-width: 480px) {
  .footer {
    padding: 1.5rem 0.75rem 1rem;
  }
  
  .footer-links {
    flex-direction: column;
    gap: 1.5rem;
  }
}
</style>
