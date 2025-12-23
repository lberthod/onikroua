# 📚 Documentation de Développement - Onikroua

Guide complet pour continuer le développement de l'application Onikroua.

## 📁 Structure du Projet

```
onikroua/
├── frontend/                    # Application Vue 3 + TypeScript
│   ├── src/
│   │   ├── components/          # Composants réutilisables
│   │   ├── views/               # Pages/Vues de l'application
│   │   ├── stores/              # Stores Pinia (état global)
│   │   ├── router/              # Configuration Vue Router
│   │   ├── firebase/            # Intégration Firebase
│   │   ├── App.vue              # Composant racine
│   │   └── main.ts              # Point d'entrée
│   └── ...
├── backend/                     # API Node.js Express
│   ├── routes/                  # Routes API
│   ├── firebaseAdmin.js         # Firebase Admin SDK
│   └── index.js                 # Point d'entrée serveur
├── infra/                       # Configuration infrastructure
└── docs/                        # Documentation
```

## 🎯 Sections d'Apprentissage

### Pages Existantes

| Route | Vue | Description |
|-------|-----|-------------|
| `/dashboard` | `DashboardView.vue` | Tableau de bord principal |
| `/conjugaison` | `ConjugaisonView.vue` | Conjugaisons des verbes |
| `/vocabulaire` | `VocabulaireView.vue` | Vocabulaire par catégories |
| `/grammaire` | `GrammaireView.vue` | Règles de grammaire |
| `/phonetique` | `PhonetiqueView.vue` | Prononciation et phonétique |
| `/lobby` | `LobbyView.vue` | Lobby pour quiz duo |
| `/room/:roomId` | `RoomView.vue` | Salle de quiz en temps réel |

### Store Learning (`stores/learning.ts`)

Le store `learning` gère l'état des sections d'apprentissage :

```typescript
// Utilisation
import { useLearningStore } from '../stores/learning'

const learningStore = useLearningStore()

// Changer la langue
learningStore.setLanguage('it') // ou 'es'

// Accéder aux données
const conjugations = learningStore.getConjugationsByLanguage
const vocabulary = learningStore.getVocabularyByLanguage
```

## 🚀 Ajouter une Nouvelle Section

### 1. Créer la Vue

```vue
<!-- src/views/NouvelleSection.vue -->
<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useLearningStore } from '../stores/learning'

const learningStore = useLearningStore()

onMounted(() => {
  learningStore.initDemoData()
  learningStore.setSection('nouvelle-section')
})

// Données filtrées par langue
const items = computed(() => {
  // Logique de filtrage
})
</script>

<template>
  <div class="section-container">
    <header class="section-header">
      <h1>📌 Nouvelle Section</h1>
      <!-- Sélecteur de langue -->
      <div class="language-toggle">
        <button 
          :class="['lang-btn', { active: learningStore.currentLanguage === 'it' }]"
          @click="learningStore.setLanguage('it')"
        >
          🇮🇹 Italien
        </button>
        <button 
          :class="['lang-btn', { active: learningStore.currentLanguage === 'es' }]"
          @click="learningStore.setLanguage('es')"
        >
          🇪🇸 Espagnol
        </button>
      </div>
    </header>
    
    <!-- Contenu de la section -->
  </div>
</template>
```

### 2. Ajouter la Route

```typescript
// src/router/index.ts
import NouvelleSectionView from '../views/NouvelleSectionView.vue'

const routes = [
  // ... autres routes
  {
    path: '/nouvelle-section',
    name: 'nouvelle-section',
    component: NouvelleSectionView,
    meta: { requiresAuth: true }
  }
]
```

### 3. Ajouter au Dashboard

```typescript
// src/views/DashboardView.vue
const sections = [
  // ... sections existantes
  { 
    id: 'nouvelle-section', 
    name: 'Nouvelle Section', 
    icon: '📌', 
    route: '/nouvelle-section', 
    color: '#xxx', 
    description: 'Description' 
  }
]
```

### 4. Ajouter à la Navigation

```vue
<!-- src/App.vue -->
<nav class="nav">
  <!-- ... liens existants -->
  <router-link to="/nouvelle-section" class="nav-link">Nouvelle Section</router-link>
</nav>
```

## 📊 Types de Données

### Interfaces Principales

```typescript
// LearningItem - Base commune
interface LearningItem {
  id: string
  language: 'it' | 'es'
  difficulty: 'beginner' | 'intermediate' | 'advanced'
  content: string
  translation: string
  example?: string
  audio?: string
}

// ConjugationItem - Conjugaisons
interface ConjugationItem extends LearningItem {
  verb: string
  tense: string
  conjugations: Record<string, string>
}

// VocabularyItem - Vocabulaire
interface VocabularyItem extends LearningItem {
  category: string
  gender?: 'm' | 'f'
  plural?: string
}

// GrammarItem - Grammaire
interface GrammarItem extends LearningItem {
  rule: string
  exceptions?: string[]
}

// PhoneticItem - Phonétique
interface PhoneticItem extends LearningItem {
  phonetic: string
  audioUrl?: string
}
```

## 🗃️ Ajouter du Contenu

### Méthode 1: Données Statiques (Demo)

Modifier `stores/learning.ts` :

```typescript
const loadDemoConjugations = () => {
  conjugations.value = [
    // Ajouter ici
    {
      id: 'it-mangiare-present',
      language: 'it',
      difficulty: 'beginner',
      verb: 'mangiare',
      tense: 'Présent',
      content: 'Conjugaison du verbe manger',
      translation: 'manger',
      conjugations: {
        'io': 'mangio',
        'tu': 'mangi',
        // ...
      },
      example: 'Io mangio la pizza.'
    }
  ]
}
```

### Méthode 2: Firebase Realtime Database

```typescript
// Charger depuis Firebase
import { db } from '../firebase/client'
import { ref, get } from 'firebase/database'

const loadFromFirebase = async () => {
  const snapshot = await get(ref(db, 'learning/conjugations'))
  if (snapshot.exists()) {
    conjugations.value = Object.values(snapshot.val())
  }
}
```

## 🎨 Conventions de Style

### Classes CSS Communes

```css
.section-container    /* Container principal de section */
.section-header       /* En-tête avec titre et langue */
.language-toggle      /* Boutons de sélection de langue */
.lang-btn            /* Bouton de langue */
.lang-btn.active     /* Bouton actif */
.card                /* Carte générique */
.empty-state         /* État vide */
```

### Couleurs par Section

| Section | Couleur |
|---------|---------|
| Conjugaison | `#3498db` (bleu) |
| Vocabulaire | `#27ae60` (vert) |
| Grammaire | `#9b59b6` (violet) |
| Phonétique | `#e74c3c` (rouge) |
| Quiz | `#f39c12` (orange) |

## 🔧 Commandes Utiles

```bash
# Frontend
cd frontend
npm run dev      # Développement
npm run build    # Production
npm run preview  # Preview du build

# Backend
cd backend
npm run dev      # Développement (nodemon)
npm start        # Production
```

## 📝 Idées de Sections à Ajouter

1. **Expressions Idiomatiques** - Expressions courantes avec traduction
2. **Dialogues** - Conversations types par situation
3. **Culture** - Aspects culturels des pays
4. **Exercices** - QCM et exercices interactifs
5. **Écoute** - Compréhension orale avec audio
6. **Lecture** - Textes avec traduction
7. **Écriture** - Exercices d'écriture guidée
8. **Faux Amis** - Mots similaires avec sens différents
9. **Nombres** - Chiffres et nombres
10. **Temps/Météo** - Vocabulaire temporel

## 🔗 Ressources

- [Vue 3 Documentation](https://vuejs.org/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Vue Router Documentation](https://router.vuejs.org/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)

## 📞 Support

Pour toute question, consultez les READMEs dans `frontend/` et `backend/`.
