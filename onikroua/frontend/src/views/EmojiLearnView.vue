<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useLearningStore } from '../stores/learning'

const learningStore = useLearningStore()
const activeTab = ref<'liste' | 'pratique' | 'histoires'>('liste')
const selectedCategory = ref<string | null>(null)
const playingId = ref<string | null>(null)

// TTS
const speak = (text: string, id?: string) => {
  if (playingId.value === id) {
    speechSynthesis.cancel()
    playingId.value = null
    return
  }
  
  const lang = learningStore.currentLanguage === 'it' ? 'it-IT' : 'es-ES'
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = lang
  utterance.rate = 0.85
  
  playingId.value = id || null
  utterance.onend = () => { playingId.value = null }
  utterance.onerror = () => { playingId.value = null }
  
  speechSynthesis.speak(utterance)
}

interface EmojiWord {
  emoji: string
  fr: string
  word: string
}

interface EmojiCategory {
  name: string
  icon: string
  items: EmojiWord[]
}

interface EmojiStory {
  id: string
  emojis: string
  fr: string
  sentence: string
}

const emojiData = computed((): EmojiCategory[] => {
  if (learningStore.currentLanguage === 'it') {
    return [
      {
        name: 'Émotions',
        icon: '😊',
        items: [
          { emoji: '😀', fr: 'content', word: 'contento' },
          { emoji: '😢', fr: 'triste', word: 'triste' },
          { emoji: '😡', fr: 'en colère', word: 'arrabbiato' },
          { emoji: '😱', fr: 'effrayé', word: 'spaventato' },
          { emoji: '😍', fr: 'amoureux', word: 'innamorato' },
          { emoji: '🤔', fr: 'pensif', word: 'pensieroso' },
          { emoji: '😴', fr: 'fatigué', word: 'stanco' },
          { emoji: '🤢', fr: 'malade', word: 'malato' },
          { emoji: '😎', fr: 'cool', word: 'figo' },
          { emoji: '🥳', fr: 'festif', word: 'festoso' },
          { emoji: '😤', fr: 'frustré', word: 'frustrato' },
          { emoji: '🥺', fr: 'suppliant', word: 'implorante' },
          { emoji: '🤩', fr: 'impressionné', word: 'impressionato' },
          { emoji: '😭', fr: 'en larmes', word: 'in lacrime' },
          { emoji: '😇', fr: 'sage', word: 'buono' }
        ]
      },
      {
        name: 'Nourriture',
        icon: '🍕',
        items: [
          { emoji: '🍕', fr: 'pizza', word: 'la pizza' },
          { emoji: '🍝', fr: 'pâtes', word: 'la pasta' },
          { emoji: '🍞', fr: 'pain', word: 'il pane' },
          { emoji: '🧀', fr: 'fromage', word: 'il formaggio' },
          { emoji: '🍷', fr: 'vin', word: 'il vino' },
          { emoji: '☕', fr: 'café', word: 'il caffè' },
          { emoji: '🍦', fr: 'glace', word: 'il gelato' },
          { emoji: '🍎', fr: 'pomme', word: 'la mela' },
          { emoji: '🍊', fr: 'orange', word: 'l\'arancia' },
          { emoji: '🍋', fr: 'citron', word: 'il limone' },
          { emoji: '🍇', fr: 'raisin', word: 'l\'uva' },
          { emoji: '🍓', fr: 'fraise', word: 'la fragola' },
          { emoji: '🥕', fr: 'carotte', word: 'la carota' },
          { emoji: '🥒', fr: 'concombre', word: 'il cetriolo' },
          { emoji: '🍅', fr: 'tomate', word: 'il pomodoro' },
          { emoji: '🥚', fr: 'œuf', word: 'l\'uovo' }
        ]
      },
      {
        name: 'Animaux',
        icon: '🐱',
        items: [
          { emoji: '🐱', fr: 'chat', word: 'il gatto' },
          { emoji: '🐶', fr: 'chien', word: 'il cane' },
          { emoji: '🐦', fr: 'oiseau', word: 'l\'uccello' },
          { emoji: '🐟', fr: 'poisson', word: 'il pesce' },
          { emoji: '🐴', fr: 'cheval', word: 'il cavallo' },
          { emoji: '🐄', fr: 'vache', word: 'la mucca' },
          { emoji: '🐷', fr: 'cochon', word: 'il maiale' },
          { emoji: '🐑', fr: 'mouton', word: 'la pecora' },
          { emoji: '🐓', fr: 'coq', word: 'il gallo' },
          { emoji: '🦋', fr: 'papillon', word: 'la farfalla' },
          { emoji: '🐝', fr: 'abeille', word: 'l\'ape' },
          { emoji: '🐢', fr: 'tortue', word: 'la tartaruga' },
          { emoji: '🐘', fr: 'éléphant', word: 'l\'elefante' },
          { emoji: '🦁', fr: 'lion', word: 'il leone' },
          { emoji: '🐻', fr: 'ours', word: 'l\'orso' },
          { emoji: '🐰', fr: 'lapin', word: 'il coniglio' }
        ]
      },
      {
        name: 'Nature',
        icon: '🌳',
        items: [
          { emoji: '🌳', fr: 'arbre', word: 'l\'albero' },
          { emoji: '🌸', fr: 'fleur', word: 'il fiore' },
          { emoji: '🌞', fr: 'soleil', word: 'il sole' },
          { emoji: '🌙', fr: 'lune', word: 'la luna' },
          { emoji: '⭐', fr: 'étoile', word: 'la stella' },
          { emoji: '🌧️', fr: 'pluie', word: 'la pioggia' },
          { emoji: '❄️', fr: 'neige', word: 'la neve' },
          { emoji: '🌈', fr: 'arc-en-ciel', word: 'l\'arcobaleno' },
          { emoji: '🌊', fr: 'vague', word: 'l\'onda' },
          { emoji: '⛰️', fr: 'montagne', word: 'la montagna' },
          { emoji: '🏝️', fr: 'île', word: 'l\'isola' },
          { emoji: '🌴', fr: 'palmier', word: 'la palma' }
        ]
      },
      {
        name: 'Transports',
        icon: '🚗',
        items: [
          { emoji: '🚗', fr: 'voiture', word: 'la macchina' },
          { emoji: '🚌', fr: 'bus', word: 'l\'autobus' },
          { emoji: '🚂', fr: 'train', word: 'il treno' },
          { emoji: '✈️', fr: 'avion', word: 'l\'aereo' },
          { emoji: '🚢', fr: 'bateau', word: 'la nave' },
          { emoji: '🚲', fr: 'vélo', word: 'la bicicletta' },
          { emoji: '🏍️', fr: 'moto', word: 'la moto' },
          { emoji: '🚁', fr: 'hélicoptère', word: 'l\'elicottero' },
          { emoji: '🚀', fr: 'fusée', word: 'il razzo' },
          { emoji: '🛴', fr: 'trottinette', word: 'il monopattino' }
        ]
      },
      {
        name: 'Objets',
        icon: '📱',
        items: [
          { emoji: '📱', fr: 'téléphone', word: 'il telefono' },
          { emoji: '💻', fr: 'ordinateur', word: 'il computer' },
          { emoji: '📺', fr: 'télévision', word: 'la televisione' },
          { emoji: '📷', fr: 'appareil photo', word: 'la macchina fotografica' },
          { emoji: '🎸', fr: 'guitare', word: 'la chitarra' },
          { emoji: '🎹', fr: 'piano', word: 'il pianoforte' },
          { emoji: '📚', fr: 'livres', word: 'i libri' },
          { emoji: '✏️', fr: 'crayon', word: 'la matita' },
          { emoji: '🔑', fr: 'clé', word: 'la chiave' },
          { emoji: '💡', fr: 'ampoule', word: 'la lampadina' },
          { emoji: '🕶️', fr: 'lunettes', word: 'gli occhiali' },
          { emoji: '👜', fr: 'sac', word: 'la borsa' }
        ]
      },
      {
        name: 'Sports',
        icon: '⚽',
        items: [
          { emoji: '⚽', fr: 'football', word: 'il calcio' },
          { emoji: '🏀', fr: 'basketball', word: 'la pallacanestro' },
          { emoji: '🎾', fr: 'tennis', word: 'il tennis' },
          { emoji: '🏊', fr: 'natation', word: 'il nuoto' },
          { emoji: '🚴', fr: 'cyclisme', word: 'il ciclismo' },
          { emoji: '⛷️', fr: 'ski', word: 'lo sci' },
          { emoji: '🏃', fr: 'course', word: 'la corsa' },
          { emoji: '🥊', fr: 'boxe', word: 'la boxe' }
        ]
      },
      {
        name: 'Lieux',
        icon: '🏠',
        items: [
          { emoji: '🏠', fr: 'maison', word: 'la casa' },
          { emoji: '🏫', fr: 'école', word: 'la scuola' },
          { emoji: '🏥', fr: 'hôpital', word: 'l\'ospedale' },
          { emoji: '🏪', fr: 'magasin', word: 'il negozio' },
          { emoji: '🏦', fr: 'banque', word: 'la banca' },
          { emoji: '⛪', fr: 'église', word: 'la chiesa' },
          { emoji: '🏰', fr: 'château', word: 'il castello' },
          { emoji: '🏖️', fr: 'plage', word: 'la spiaggia' },
          { emoji: '🎭', fr: 'théâtre', word: 'il teatro' },
          { emoji: '🎢', fr: 'parc d\'attractions', word: 'il parco divertimenti' }
        ]
      },
      {
        name: 'Corps',
        icon: '👁️',
        items: [
          { emoji: '👁️', fr: 'œil', word: 'l\'occhio' },
          { emoji: '👂', fr: 'oreille', word: 'l\'orecchio' },
          { emoji: '👃', fr: 'nez', word: 'il naso' },
          { emoji: '👄', fr: 'bouche', word: 'la bocca' },
          { emoji: '🦷', fr: 'dent', word: 'il dente' },
          { emoji: '👅', fr: 'langue', word: 'la lingua' },
          { emoji: '✋', fr: 'main', word: 'la mano' },
          { emoji: '🦶', fr: 'pied', word: 'il piede' },
          { emoji: '❤️', fr: 'cœur', word: 'il cuore' },
          { emoji: '🧠', fr: 'cerveau', word: 'il cervello' }
        ]
      },
      {
        name: 'Métiers',
        icon: '👨‍⚕️',
        items: [
          { emoji: '👨‍⚕️', fr: 'médecin', word: 'il medico' },
          { emoji: '👨‍🏫', fr: 'professeur', word: 'il professore' },
          { emoji: '👨‍🍳', fr: 'cuisinier', word: 'il cuoco' },
          { emoji: '👨‍🚒', fr: 'pompier', word: 'il pompiere' },
          { emoji: '👮', fr: 'policier', word: 'il poliziotto' },
          { emoji: '👨‍🌾', fr: 'agriculteur', word: 'l\'agricoltore' },
          { emoji: '👨‍🔧', fr: 'mécanicien', word: 'il meccanico' },
          { emoji: '👨‍💼', fr: 'homme d\'affaires', word: 'l\'uomo d\'affari' }
        ]
      },
      {
        name: 'Temps',
        icon: '⏰',
        items: [
          { emoji: '⏰', fr: 'heure', word: 'l\'ora' },
          { emoji: '📅', fr: 'jour', word: 'il giorno' },
          { emoji: '🌅', fr: 'matin', word: 'la mattina' },
          { emoji: '🌇', fr: 'soir', word: 'la sera' },
          { emoji: '🌃', fr: 'nuit', word: 'la notte' },
          { emoji: '📆', fr: 'semaine', word: 'la settimana' },
          { emoji: '🗓️', fr: 'mois', word: 'il mese' },
          { emoji: '🎆', fr: 'année', word: 'l\'anno' }
        ]
      },
      {
        name: 'Actions',
        icon: '🏃',
        items: [
          { emoji: '🚶', fr: 'marcher', word: 'camminare' },
          { emoji: '🏃', fr: 'courir', word: 'correre' },
          { emoji: '🏊', fr: 'nager', word: 'nuotare' },
          { emoji: '💤', fr: 'dormir', word: 'dormire' },
          { emoji: '🍽️', fr: 'manger', word: 'mangiare' },
          { emoji: '🥤', fr: 'boire', word: 'bere' },
          { emoji: '📖', fr: 'lire', word: 'leggere' },
          { emoji: '✍️', fr: 'écrire', word: 'scrivere' },
          { emoji: '🎤', fr: 'chanter', word: 'cantare' },
          { emoji: '💃', fr: 'danser', word: 'ballare' },
          { emoji: '👏', fr: 'applaudir', word: 'applaudire' },
          { emoji: '🧹', fr: 'nettoyer', word: 'pulire' },
          { emoji: '🧺', fr: 'faire la lessive', word: 'fare il bucato' }
        ]
      },
      {
        name: 'Vêtements',
        icon: '👕',
        items: [
          { emoji: '👕', fr: 't-shirt', word: 'la maglietta' },
          { emoji: '👖', fr: 'pantalon', word: 'i pantaloni' },
          { emoji: '👗', fr: 'robe', word: 'il vestito' },
          { emoji: '🧥', fr: 'manteau', word: 'il cappotto' },
          { emoji: '🧢', fr: 'casquette', word: 'il cappello' },
          { emoji: '👟', fr: 'chaussures', word: 'le scarpe' },
          { emoji: '🧦', fr: 'chaussettes', word: 'i calzini' }
        ]
      },
      {
        name: 'Couleurs',
        icon: '🎨',
        items: [
          { emoji: '🔴', fr: 'rouge', word: 'rosso' },
          { emoji: '🔵', fr: 'bleu', word: 'blu' },
          { emoji: '🟢', fr: 'vert', word: 'verde' },
          { emoji: '🟡', fr: 'jaune', word: 'giallo' },
          { emoji: '⚫', fr: 'noir', word: 'nero' },
          { emoji: '⚪', fr: 'blanc', word: 'bianco' },
          { emoji: '🟠', fr: 'orange', word: 'arancione' },
          { emoji: '🌸', fr: 'rose', word: 'rosa' }
        ]
      },
      {
        name: 'Famille',
        icon: '👨‍👩‍👧‍👦',
        items: [
          { emoji: '👩', fr: 'mère', word: 'la mamma' },
          { emoji: '👨', fr: 'père', word: 'il papà' },
          { emoji: '👦', fr: 'fils', word: 'il figlio' },
          { emoji: '👧', fr: 'fille', word: 'la figlia' },
          { emoji: '🧒', fr: 'enfant', word: 'il bambino' },
          { emoji: '👵', fr: 'grand-mère', word: 'la nonna' },
          { emoji: '👴', fr: 'grand-père', word: 'il nonno' },
          { emoji: '👨‍👩‍👧‍👦', fr: 'famille', word: 'la famiglia' }
        ]
      },
      {
        name: 'Maison',
        icon: '🏡',
        items: [
          { emoji: '🏡', fr: 'maison', word: 'la casa' },
          { emoji: '🛏️', fr: 'lit', word: 'il letto' },
          { emoji: '🚿', fr: 'douche', word: 'la doccia' },
          { emoji: '🚪', fr: 'porte', word: 'la porta' },
          { emoji: '🪑', fr: 'chaise', word: 'la sedia' },
          { emoji: '🪟', fr: 'fenêtre', word: 'la finestra' },
          { emoji: '🧽', fr: 'éponge', word: 'la spugna' }
        ]
      },
      {
        name: 'École',
        icon: '🎓',
        items: [
          { emoji: '🎓', fr: 'école', word: 'la scuola' },
          { emoji: '🎒', fr: 'sac à dos', word: 'lo zaino' },
          { emoji: '📚', fr: 'livres', word: 'i libri' },
          { emoji: '✏️', fr: 'crayon', word: 'la matita' },
          { emoji: '🖊️', fr: 'stylo', word: 'la penna' },
          { emoji: '🧮', fr: 'calculatrice', word: 'la calcolatrice' },
          { emoji: '🧑‍🏫', fr: 'professeur', word: "l'insegnante" }
        ]
      },
      {
        name: 'Ville',
        icon: '🏙️',
        items: [
          { emoji: '🏙️', fr: 'ville', word: 'la città' },
          { emoji: '🏬', fr: 'centre commercial', word: 'il centro commerciale' },
          { emoji: '🚇', fr: 'métro', word: 'la metropolitana' },
          { emoji: '🏢', fr: 'immeuble', word: "l'ufficio" },
          { emoji: '🌉', fr: 'pont', word: 'il ponte' },
          { emoji: '🚦', fr: 'feu rouge', word: 'il semaforo' }
        ]
      },
      {
        name: 'Loisirs',
        icon: '🧸',
        items: [
          { emoji: '🎮', fr: 'jeu vidéo', word: 'il videogioco' },
          { emoji: '🎨', fr: 'dessin', word: 'il disegno' },
          { emoji: '🎧', fr: 'musique', word: 'la musica' },
          { emoji: '🎬', fr: 'film', word: 'il film' },
          { emoji: '📺', fr: 'série', word: 'la serie' },
          { emoji: '🧸', fr: 'jouet', word: 'il giocattolo' }
        ]
      },
      {
        name: 'Technologie',
        icon: '💾',
        items: [
          { emoji: '💾', fr: 'disque', word: 'il disco' },
          { emoji: '🖥️', fr: 'ordinateur fixe', word: 'il computer fisso' },
          { emoji: '⌨️', fr: 'clavier', word: 'la tastiera' },
          { emoji: '🖱️', fr: 'souris', word: 'il mouse' },
          { emoji: '📱', fr: 'smartphone', word: 'lo smartphone' },
          { emoji: '📶', fr: 'wifi', word: 'il wifi' }
        ]
      }
    ]
  } else {
    return [
      {
        name: 'Émotions',
        icon: '😊',
        items: [
          { emoji: '😀', fr: 'content', word: 'contento' },
          { emoji: '😢', fr: 'triste', word: 'triste' },
          { emoji: '😡', fr: 'en colère', word: 'enfadado' },
          { emoji: '😱', fr: 'effrayé', word: 'asustado' },
          { emoji: '😍', fr: 'amoureux', word: 'enamorado' },
          { emoji: '🤔', fr: 'pensif', word: 'pensativo' },
          { emoji: '😴', fr: 'fatigué', word: 'cansado' },
          { emoji: '🤢', fr: 'malade', word: 'enfermo' },
          { emoji: '😎', fr: 'cool', word: 'guay' },
          { emoji: '🥳', fr: 'festif', word: 'festivo' },
          { emoji: '😤', fr: 'frustré', word: 'frustrado' },
          { emoji: '🥺', fr: 'suppliant', word: 'suplicante' },
          { emoji: '🤩', fr: 'impressionné', word: 'impresionado' },
          { emoji: '😭', fr: 'en larmes', word: 'llorando' },
          { emoji: '😇', fr: 'sage', word: 'bueno' }
        ]
      },
      {
        name: 'Nourriture',
        icon: '🍕',
        items: [
          { emoji: '🍕', fr: 'pizza', word: 'la pizza' },
          { emoji: '🍝', fr: 'pâtes', word: 'la pasta' },
          { emoji: '🍞', fr: 'pain', word: 'el pan' },
          { emoji: '🧀', fr: 'fromage', word: 'el queso' },
          { emoji: '🍷', fr: 'vin', word: 'el vino' },
          { emoji: '☕', fr: 'café', word: 'el café' },
          { emoji: '🍦', fr: 'glace', word: 'el helado' },
          { emoji: '🍎', fr: 'pomme', word: 'la manzana' },
          { emoji: '🍊', fr: 'orange', word: 'la naranja' },
          { emoji: '🍋', fr: 'citron', word: 'el limón' },
          { emoji: '🍇', fr: 'raisin', word: 'la uva' },
          { emoji: '🍓', fr: 'fraise', word: 'la fresa' },
          { emoji: '🥕', fr: 'carotte', word: 'la zanahoria' },
          { emoji: '🥒', fr: 'concombre', word: 'el pepino' },
          { emoji: '🍅', fr: 'tomate', word: 'el tomate' },
          { emoji: '🥚', fr: 'œuf', word: 'el huevo' },
          { emoji: '🍌', fr: 'banane', word: 'el plátano' },
          { emoji: '🍰', fr: 'gâteau', word: 'el pastel' },
          { emoji: '🍟', fr: 'frites', word: 'las patatas fritas' }
        ]
      },
      {
        name: 'Animaux',
        icon: '🐱',
        items: [
          { emoji: '🐱', fr: 'chat', word: 'el gato' },
          { emoji: '🐶', fr: 'chien', word: 'el perro' },
          { emoji: '🐦', fr: 'oiseau', word: 'el pájaro' },
          { emoji: '🐟', fr: 'poisson', word: 'el pez' },
          { emoji: '🐴', fr: 'cheval', word: 'el caballo' },
          { emoji: '🐄', fr: 'vache', word: 'la vaca' },
          { emoji: '🐷', fr: 'cochon', word: 'el cerdo' },
          { emoji: '🐑', fr: 'mouton', word: 'la oveja' },
          { emoji: '🐓', fr: 'coq', word: 'el gallo' },
          { emoji: '🦋', fr: 'papillon', word: 'la mariposa' },
          { emoji: '🐝', fr: 'abeille', word: 'la abeja' },
          { emoji: '🐢', fr: 'tortue', word: 'la tortuga' },
          { emoji: '🐘', fr: 'éléphant', word: 'el elefante' },
          { emoji: '🦁', fr: 'lion', word: 'el león' },
          { emoji: '🐻', fr: 'ours', word: 'el oso' },
          { emoji: '🐰', fr: 'lapin', word: 'el conejo' }
        ]
      },
      {
        name: 'Nature',
        icon: '🌳',
        items: [
          { emoji: '🌳', fr: 'arbre', word: 'el árbol' },
          { emoji: '🌸', fr: 'fleur', word: 'la flor' },
          { emoji: '🌞', fr: 'soleil', word: 'el sol' },
          { emoji: '🌙', fr: 'lune', word: 'la luna' },
          { emoji: '⭐', fr: 'étoile', word: 'la estrella' },
          { emoji: '🌧️', fr: 'pluie', word: 'la lluvia' },
          { emoji: '❄️', fr: 'neige', word: 'la nieve' },
          { emoji: '🌈', fr: 'arc-en-ciel', word: 'el arcoíris' },
          { emoji: '🌊', fr: 'vague', word: 'la ola' },
          { emoji: '⛰️', fr: 'montagne', word: 'la montaña' },
          { emoji: '🏝️', fr: 'île', word: 'la isla' },
          { emoji: '🌴', fr: 'palmier', word: 'la palmera' }
        ]
      },
      {
        name: 'Transports',
        icon: '🚗',
        items: [
          { emoji: '🚗', fr: 'voiture', word: 'el coche' },
          { emoji: '🚌', fr: 'bus', word: 'el autobús' },
          { emoji: '🚂', fr: 'train', word: 'el tren' },
          { emoji: '✈️', fr: 'avion', word: 'el avión' },
          { emoji: '🚢', fr: 'bateau', word: 'el barco' },
          { emoji: '🚲', fr: 'vélo', word: 'la bicicleta' },
          { emoji: '🏍️', fr: 'moto', word: 'la moto' },
          { emoji: '🚁', fr: 'hélicoptère', word: 'el helicóptero' },
          { emoji: '🚀', fr: 'fusée', word: 'el cohete' },
          { emoji: '🛴', fr: 'trottinette', word: 'el patinete' }
        ]
      },
      {
        name: 'Objets',
        icon: '📱',
        items: [
          { emoji: '📱', fr: 'téléphone', word: 'el teléfono' },
          { emoji: '💻', fr: 'ordinateur', word: 'el ordenador' },
          { emoji: '📺', fr: 'télévision', word: 'la televisión' },
          { emoji: '📷', fr: 'appareil photo', word: 'la cámara' },
          { emoji: '🎸', fr: 'guitare', word: 'la guitarra' },
          { emoji: '🎹', fr: 'piano', word: 'el piano' },
          { emoji: '📚', fr: 'livres', word: 'los libros' },
          { emoji: '✏️', fr: 'crayon', word: 'el lápiz' },
          { emoji: '🔑', fr: 'clé', word: 'la llave' },
          { emoji: '💡', fr: 'ampoule', word: 'la bombilla' },
          { emoji: '🕶️', fr: 'lunettes', word: 'las gafas' },
          { emoji: '👜', fr: 'sac', word: 'el bolso' }
        ]
      },
      {
        name: 'Sports',
        icon: '⚽',
        items: [
          { emoji: '⚽', fr: 'football', word: 'el fútbol' },
          { emoji: '🏀', fr: 'basketball', word: 'el baloncesto' },
          { emoji: '🎾', fr: 'tennis', word: 'el tenis' },
          { emoji: '🏊', fr: 'natation', word: 'la natación' },
          { emoji: '🚴', fr: 'cyclisme', word: 'el ciclismo' },
          { emoji: '⛷️', fr: 'ski', word: 'el esquí' },
          { emoji: '🏃', fr: 'course', word: 'la carrera' },
          { emoji: '🥊', fr: 'boxe', word: 'el boxeo' }
        ]
      },
      {
        name: 'Lieux',
        icon: '🏠',
        items: [
          { emoji: '🏠', fr: 'maison', word: 'la casa' },
          { emoji: '🏫', fr: 'école', word: 'la escuela' },
          { emoji: '🏥', fr: 'hôpital', word: 'el hospital' },
          { emoji: '🏪', fr: 'magasin', word: 'la tienda' },
          { emoji: '🏦', fr: 'banque', word: 'el banco' },
          { emoji: '⛪', fr: 'église', word: 'la iglesia' },
          { emoji: '🏰', fr: 'château', word: 'el castillo' },
          { emoji: '🏖️', fr: 'plage', word: 'la playa' },
          { emoji: '🎭', fr: 'théâtre', word: 'el teatro' },
          { emoji: '🎢', fr: 'parc d\'attractions', word: 'el parque de atracciones' }
        ]
      },
      {
        name: 'Corps',
        icon: '👁️',
        items: [
          { emoji: '👁️', fr: 'œil', word: 'el ojo' },
          { emoji: '👂', fr: 'oreille', word: 'la oreja' },
          { emoji: '👃', fr: 'nez', word: 'la nariz' },
          { emoji: '👄', fr: 'bouche', word: 'la boca' },
          { emoji: '🦷', fr: 'dent', word: 'el diente' },
          { emoji: '👅', fr: 'langue', word: 'la lengua' },
          { emoji: '✋', fr: 'main', word: 'la mano' },
          { emoji: '🦶', fr: 'pied', word: 'el pie' },
          { emoji: '❤️', fr: 'cœur', word: 'el corazón' },
          { emoji: '🧠', fr: 'cerveau', word: 'el cerebro' }
        ]
      },
      {
        name: 'Métiers',
        icon: '👨‍⚕️',
        items: [
          { emoji: '👨‍⚕️', fr: 'médecin', word: 'el médico' },
          { emoji: '👨‍🏫', fr: 'professeur', word: 'el profesor' },
          { emoji: '👨‍🍳', fr: 'cuisinier', word: 'el cocinero' },
          { emoji: '👨‍🚒', fr: 'pompier', word: 'el bombero' },
          { emoji: '👮', fr: 'policier', word: 'el policía' },
          { emoji: '👨‍🌾', fr: 'agriculteur', word: 'el agricultor' },
          { emoji: '👨‍🔧', fr: 'mécanicien', word: 'el mecánico' },
          { emoji: '👨‍💼', fr: 'homme d\'affaires', word: 'el empresario' }
        ]
      },
      {
        name: 'Temps',
        icon: '⏰',
        items: [
          { emoji: '⏰', fr: 'heure', word: 'la hora' },
          { emoji: '📅', fr: 'jour', word: 'el día' },
          { emoji: '🌅', fr: 'matin', word: 'la mañana' },
          { emoji: '🌇', fr: 'soir', word: 'la tarde' },
          { emoji: '🌃', fr: 'nuit', word: 'la noche' },
          { emoji: '📆', fr: 'semaine', word: 'la semana' },
          { emoji: '🗓️', fr: 'mois', word: 'el mes' },
          { emoji: '🎆', fr: 'année', word: 'el año' }
        ]
      },
      {
        name: 'Actions',
        icon: '🏃',
        items: [
          { emoji: '🚶', fr: 'marcher', word: 'caminar' },
          { emoji: '🏃', fr: 'courir', word: 'correr' },
          { emoji: '🏊', fr: 'nager', word: 'nadar' },
          { emoji: '💤', fr: 'dormir', word: 'dormir' },
          { emoji: '🍽️', fr: 'manger', word: 'comer' },
          { emoji: '🥤', fr: 'boire', word: 'beber' },
          { emoji: '📖', fr: 'lire', word: 'leer' },
          { emoji: '✍️', fr: 'écrire', word: 'escribir' },
          { emoji: '🎤', fr: 'chanter', word: 'cantar' },
          { emoji: '💃', fr: 'danser', word: 'bailar' },
          { emoji: '👏', fr: 'applaudir', word: 'aplaudir' },
          { emoji: '🧹', fr: 'nettoyer', word: 'limpiar' },
          { emoji: '🧺', fr: 'faire la lessive', word: 'lavar la ropa' }
        ]
      },
      {
        name: 'Vêtements',
        icon: '👕',
        items: [
          { emoji: '👕', fr: 't-shirt', word: 'la camiseta' },
          { emoji: '👖', fr: 'pantalon', word: 'los pantalones' },
          { emoji: '👗', fr: 'robe', word: 'el vestido' },
          { emoji: '🧥', fr: 'manteau', word: 'el abrigo' },
          { emoji: '🧢', fr: 'casquette', word: 'la gorra' },
          { emoji: '👟', fr: 'chaussures', word: 'los zapatos' },
          { emoji: '🧦', fr: 'chaussettes', word: 'los calcetines' }
        ]
      },
      {
        name: 'Couleurs',
        icon: '🎨',
        items: [
          { emoji: '🔴', fr: 'rouge', word: 'rojo' },
          { emoji: '🔵', fr: 'bleu', word: 'azul' },
          { emoji: '🟢', fr: 'vert', word: 'verde' },
          { emoji: '🟡', fr: 'jaune', word: 'amarillo' },
          { emoji: '⚫', fr: 'noir', word: 'negro' },
          { emoji: '⚪', fr: 'blanc', word: 'blanco' },
          { emoji: '🟠', fr: 'orange', word: 'naranja' },
          { emoji: '🌸', fr: 'rose', word: 'rosa' }
        ]
      },
      {
        name: 'Famille',
        icon: '👨‍👩‍👧‍👦',
        items: [
          { emoji: '👩', fr: 'mère', word: 'la madre' },
          { emoji: '👨', fr: 'père', word: 'el padre' },
          { emoji: '👦', fr: 'fils', word: 'el hijo' },
          { emoji: '👧', fr: 'fille', word: 'la hija' },
          { emoji: '🧒', fr: 'enfant', word: 'el niño' },
          { emoji: '👵', fr: 'grand-mère', word: 'la abuela' },
          { emoji: '👴', fr: 'grand-père', word: 'el abuelo' },
          { emoji: '👨‍👩‍👧‍👦', fr: 'famille', word: 'la familia' }
        ]
      },
      {
        name: 'Maison',
        icon: '🏡',
        items: [
          { emoji: '🏡', fr: 'maison', word: 'la casa' },
          { emoji: '🛏️', fr: 'lit', word: 'la cama' },
          { emoji: '🚿', fr: 'douche', word: 'la ducha' },
          { emoji: '🚪', fr: 'porte', word: 'la puerta' },
          { emoji: '🪑', fr: 'chaise', word: 'la silla' },
          { emoji: '🪟', fr: 'fenêtre', word: 'la ventana' },
          { emoji: '🧽', fr: 'éponge', word: 'la esponja' }
        ]
      },
      {
        name: 'École',
        icon: '🎓',
        items: [
          { emoji: '🎓', fr: 'école', word: 'la escuela' },
          { emoji: '🎒', fr: 'sac à dos', word: 'la mochila' },
          { emoji: '📚', fr: 'livres', word: 'los libros' },
          { emoji: '✏️', fr: 'crayon', word: 'el lápiz' },
          { emoji: '🖊️', fr: 'stylo', word: 'el bolígrafo' },
          { emoji: '🧮', fr: 'calculatrice', word: 'la calculadora' },
          { emoji: '🧑‍🏫', fr: 'professeur', word: 'el profesor' }
        ]
      },
      {
        name: 'Ville',
        icon: '🏙️',
        items: [
          { emoji: '🏙️', fr: 'ville', word: 'la ciudad' },
          { emoji: '🏬', fr: 'centre commercial', word: 'el centro comercial' },
          { emoji: '🚇', fr: 'métro', word: 'el metro' },
          { emoji: '🏢', fr: 'immeuble', word: 'el edificio' },
          { emoji: '🌉', fr: 'pont', word: 'el puente' },
          { emoji: '🚦', fr: 'feu rouge', word: 'el semáforo' }
        ]
      },
      {
        name: 'Loisirs',
        icon: '🧸',
        items: [
          { emoji: '🎮', fr: 'jeu vidéo', word: 'el videojuego' },
          { emoji: '🎨', fr: 'dessin', word: 'el dibujo' },
          { emoji: '🎧', fr: 'musique', word: 'la música' },
          { emoji: '🎬', fr: 'film', word: 'la película' },
          { emoji: '📺', fr: 'série', word: 'la serie' },
          { emoji: '🧸', fr: 'jouet', word: 'el juguete' }
        ]
      },
      {
        name: 'Technologie',
        icon: '💾',
        items: [
          { emoji: '💾', fr: 'disque', word: 'el disco' },
          { emoji: '🖥️', fr: 'ordinateur fixe', word: 'el ordenador de sobremesa' },
          { emoji: '⌨️', fr: 'clavier', word: 'el teclado' },
          { emoji: '🖱️', fr: 'souris', word: 'el ratón' },
          { emoji: '📱', fr: 'smartphone', word: 'el móvil' },
          { emoji: '📶', fr: 'wifi', word: 'el wifi' }
        ]
      }
    ]
  }
})

const emojiStories = computed((): EmojiStory[] => {
  if (learningStore.currentLanguage === 'it') {
    return [
      {
        id: 'it-breakfast',
        emojis: '🍞☕',
        fr: 'Je prends du pain et un café.',
        sentence: 'Mangio il pane e bevo il caffè.'
      },
      {
        id: 'it-school',
        emojis: '🏫🎒📚',
        fr: "Je vais à l'école avec mon sac et mes livres.",
        sentence: 'Vado a scuola con lo zaino e i libri.'
      },
      {
        id: 'it-beach',
        emojis: '🏖️🌞🌊',
        fr: 'Nous sommes à la plage au soleil.',
        sentence: 'Siamo in spiaggia al sole.'
      },
      {
        id: 'it-sport',
        emojis: '⚽🏃🥤',
        fr: "Je joue au foot et je bois de l'eau.",
        sentence: 'Gioco a calcio e bevo acqua.'
      },
      {
        id: 'it-family-dinner',
        emojis: '👨‍👩‍👧‍👦🍽️🏠',
        fr: 'Je dîne à la maison avec ma famille.',
        sentence: 'Ceno a casa con la mia famiglia.'
      },
      {
        id: 'it-travel',
        emojis: '🧳✈️🏨',
        fr: "Je voyage en avion et je dors à l'hôtel.",
        sentence: 'Viaggio in aereo e dormo in hotel.'
      }
    ]
  } else {
    return [
      {
        id: 'es-breakfast',
        emojis: '🍞☕',
        fr: 'Je prends du pain et un café.',
        sentence: 'Como pan y bebo café.'
      },
      {
        id: 'es-school',
        emojis: '🏫🎒📚',
        fr: "Je vais à l'école avec mon sac et mes livres.",
        sentence: 'Voy a la escuela con la mochila y los libros.'
      },
      {
        id: 'es-beach',
        emojis: '🏖️🌞🌊',
        fr: 'Nous sommes à la plage au soleil.',
        sentence: 'Estamos en la playa al sol.'
      },
      {
        id: 'es-sport',
        emojis: '⚽🏃🥤',
        fr: "Je joue au foot et je bois de l'eau.",
        sentence: 'Juego al fútbol y bebo agua.'
      },
      {
        id: 'es-family-dinner',
        emojis: '👨‍👩‍👧‍👦🍽️🏠',
        fr: 'Je dîne à la maison avec ma famille.',
        sentence: 'Ceno en casa con mi familia.'
      },
      {
        id: 'es-travel',
        emojis: '🧳✈️🏨',
        fr: "Je voyage en avion et je dors à l'hôtel.",
        sentence: 'Viajo en avión y duermo en el hotel.'
      }
    ]
  }
})

const allEmojis = computed(() => {
  return emojiData.value.flatMap(cat => 
    cat.items.map(item => ({ ...item, category: cat.name, categoryIcon: cat.icon }))
  )
})

const filteredEmojis = computed(() => {
  if (!selectedCategory.value) return allEmojis.value
  return allEmojis.value.filter(e => e.category === selectedCategory.value)
})

const languageLabel = computed(() => 
  learningStore.currentLanguage === 'it' ? '🇮🇹 Italien' : '🇪🇸 Espagnol'
)

// Practice mode
const practiceMode = ref<'emojiToWord' | 'wordToEmoji' | 'frToEmoji'>('emojiToWord')
const practiceItem = ref<EmojiWord | null>(null)
const practiceCategory = ref<string | null>(null)
const practiceResult = ref<'correct' | 'wrong' | null>(null)
const practiceScore = ref(0)
const practiceTotal = ref(0)
const practiceStreak = ref(0)

const practiceItems = computed(() => {
  if (practiceCategory.value) {
    return allEmojis.value.filter(e => e.category === practiceCategory.value)
  }
  return allEmojis.value
})

const practiceChoices = computed(() => {
  if (!practiceItem.value) return []
  
  let correct: string
  let others: string[]
  
  if (practiceMode.value === 'emojiToWord') {
    correct = practiceItem.value.word
    others = practiceItems.value.filter(e => e.emoji !== practiceItem.value?.emoji).map(e => e.word)
  } else if (practiceMode.value === 'wordToEmoji') {
    correct = practiceItem.value.emoji
    others = practiceItems.value.filter(e => e.word !== practiceItem.value?.word).map(e => e.emoji)
  } else {
    correct = practiceItem.value.emoji
    others = practiceItems.value.filter(e => e.fr !== practiceItem.value?.fr).map(e => e.emoji)
  }
  
  const shuffled = others.sort(() => Math.random() - 0.5).slice(0, 3)
  return [...shuffled, correct].sort(() => Math.random() - 0.5)
})

const correctAnswer = computed(() => {
  if (!practiceItem.value) return ''
  if (practiceMode.value === 'emojiToWord') return practiceItem.value.word
  return practiceItem.value.emoji
})

const generateQuestion = () => {
  practiceResult.value = null
  const items = practiceItems.value
  if (items.length === 0) return
  practiceItem.value = items[Math.floor(Math.random() * items.length)]
}

const checkAnswer = (answer: string) => {
  practiceTotal.value++
  const isCorrect = answer === correctAnswer.value
  
  if (isCorrect) {
    practiceResult.value = 'correct'
    practiceScore.value++
    practiceStreak.value++
    if (practiceItem.value) speak(practiceItem.value.word)
  } else {
    practiceResult.value = 'wrong'
    practiceStreak.value = 0
  }
}

const resetPractice = () => {
  practiceScore.value = 0
  practiceTotal.value = 0
  practiceStreak.value = 0
  generateQuestion()
}

watch(activeTab, (tab) => {
  if (tab === 'pratique' && !practiceItem.value) {
    generateQuestion()
  }
})

watch(() => learningStore.currentLanguage, () => {
  if (activeTab.value === 'pratique') resetPractice()
})

watch(practiceCategory, () => {
  if (activeTab.value === 'pratique') generateQuestion()
})
</script>

<template>
  <div class="section-container">
    <header class="section-header">
      <h1>😀 Emoji Learn</h1>
      <p class="section-subtitle">Apprenez le vocabulaire avec des emojis en {{ languageLabel }} - {{ allEmojis.length }} mots</p>
      
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

    <!-- Tabs -->
    <div class="tabs">
      <button 
        :class="['tab-btn', { active: activeTab === 'liste' }]"
        @click="activeTab = 'liste'"
      >
        📋 Liste
      </button>
      <button 
        :class="['tab-btn practice-tab', { active: activeTab === 'pratique' }]"
        @click="activeTab = 'pratique'"
      >
        🎮 Pratique
      </button>
      <button
        :class="['tab-btn stories-tab', { active: activeTab === 'histoires' }]"
        @click="activeTab = 'histoires'"
      >
        📖 Histoires
      </button>
    </div>

    <!-- Tab: Liste -->
    <div v-if="activeTab === 'liste'" class="tab-content">
      <!-- Category filter -->
      <div class="category-filter">
        <button 
          :class="['category-btn', { active: !selectedCategory }]"
          @click="selectedCategory = null"
        >
          📋 Tous
        </button>
        <button 
          v-for="cat in emojiData" 
          :key="cat.name"
          :class="['category-btn', { active: selectedCategory === cat.name }]"
          @click="selectedCategory = cat.name"
        >
          {{ cat.icon }} {{ cat.name }}
        </button>
      </div>

      <!-- Emoji grid -->
      <div class="emoji-grid">
        <div 
          v-for="(item, idx) in filteredEmojis" 
          :key="`${item.emoji}-${idx}`" 
          class="emoji-card"
          @click="speak(item.word, `emoji-${idx}`)"
        >
          <div class="emoji-icon">{{ item.emoji }}</div>
          <div class="emoji-word">{{ item.word }}</div>
          <div class="emoji-fr">{{ item.fr }}</div>
          <div class="emoji-audio" :class="{ playing: playingId === `emoji-${idx}` }">🔊</div>
        </div>
      </div>
    </div>

    <div v-if="activeTab === 'pratique'" class="tab-content">
      <!-- Stats -->
      <div class="practice-stats">
        <div class="stat-card">
          <span class="stat-value">{{ practiceScore }}</span>
          <span class="stat-label">Correct</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ practiceTotal }}</span>
          <span class="stat-label">Total</span>
        </div>
        <div class="stat-card streak">
          <span class="stat-value">🔥 {{ practiceStreak }}</span>
          <span class="stat-label">Série</span>
        </div>
        <div class="stat-card accuracy">
          <span class="stat-value">{{ practiceTotal > 0 ? Math.round((practiceScore / practiceTotal) * 100) : 0 }}%</span>
          <span class="stat-label">Précision</span>
        </div>
      </div>

      <!-- Settings -->
      <div class="practice-settings">
        <div class="setting-group">
          <label>Catégorie :</label>
          <select v-model="practiceCategory" class="setting-select">
            <option :value="null">Toutes</option>
            <option v-for="cat in emojiData" :key="cat.name" :value="cat.name">
              {{ cat.icon }} {{ cat.name }}
            </option>
          </select>
        </div>
        <div class="setting-group">
          <label>Mode :</label>
          <select v-model="practiceMode" class="setting-select">
            <option value="emojiToWord">Emoji → Mot</option>
            <option value="wordToEmoji">Mot → Emoji</option>
            <option value="frToEmoji">Français → Emoji</option>
          </select>
        </div>
      </div>

      <!-- Question -->
      <div v-if="practiceItem" class="practice-card card">
        <div class="practice-question">
          <div v-if="practiceMode === 'emojiToWord'" class="question-emoji">
            {{ practiceItem.emoji }}
          </div>
          <div v-else-if="practiceMode === 'wordToEmoji'" class="question-word">
            {{ practiceItem.word }}
            <button class="audio-btn" @click="speak(practiceItem.word)">🔊</button>
          </div>
          <div v-else class="question-fr">
            {{ practiceItem.fr }}
          </div>
        </div>

        <!-- Choices -->
        <div class="practice-choices" :class="{ 'emoji-choices': practiceMode !== 'emojiToWord' }">
          <button
            v-for="(choice, idx) in practiceChoices"
            :key="idx"
            class="choice-btn"
            :class="{
              correct: practiceResult && choice === correctAnswer,
              wrong: practiceResult === 'wrong' && choice !== correctAnswer,
              'emoji-choice': practiceMode !== 'emojiToWord'
            }"
            :disabled="practiceResult !== null"
            @click="checkAnswer(choice)"
          >
            {{ choice }}
          </button>
        </div>

        <!-- Result -->
        <div v-if="practiceResult" class="practice-result" :class="practiceResult">
          <div v-if="practiceResult === 'correct'" class="result-message">
            ✅ Correct ! {{ practiceItem.emoji }}
            <span v-if="practiceStreak >= 3">🔥 Série de {{ practiceStreak }} !</span>
          </div>
          <div v-else class="result-message">
            ❌ C'était : {{ practiceItem.emoji }} = <strong>{{ practiceItem.word }}</strong>
            <button class="audio-btn-inline" @click="speak(practiceItem.word)">🔊</button>
          </div>
          <button class="next-btn" @click="generateQuestion">
            Question suivante →
          </button>
        </div>
      </div>

      <div class="practice-actions">
        <button class="reset-btn" @click="resetPractice">
          🔄 Recommencer
        </button>
      </div>
    </div>
    <div v-if="activeTab === 'histoires'" class="tab-content">
      <div class="stories-intro">
        <p>Lis la phrase en français, puis la phrase en {{ languageLabel }}. Utilise les emojis pour imaginer la scène.</p>
      </div>
      <div class="stories-grid">
        <div
          v-for="story in emojiStories"
          :key="story.id"
          class="story-card"
        >
          <div class="story-emojis">{{ story.emojis }}</div>
          <div class="story-text-fr">{{ story.fr }}</div>
          <div class="story-text-foreign">{{ story.sentence }}</div>
          <button class="audio-btn" @click="speak(story.sentence)">🔊</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.section-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.section-header {
  text-align: center;
  margin-bottom: 2rem;
}

.section-header h1 {
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.section-subtitle {
  color: #7f8c8d;
  margin-bottom: 1.5rem;
}

.language-toggle {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.lang-btn {
  padding: 0.75rem 1.5rem;
  border: 2px solid #ddd;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.lang-btn:hover {
  border-color: #3498db;
}

.lang-btn.active {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

/* Tabs */
.tabs {
  display: flex;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.tab-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  background: #f0f0f0;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: all 0.2s;
}

.tab-btn:hover {
  background: #e0e0e0;
}

.tab-btn.active {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.tab-btn.practice-tab.active {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
}

.tab-btn.stories-tab.active {
  background: linear-gradient(135deg, #6a89cc 0%, #4a69bd 100%);
  color: white;
}

.tab-content {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Category filter */
.category-filter {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.category-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  background: white;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
}

.category-btn:hover {
  border-color: #f093fb;
}

.category-btn.active {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  border-color: transparent;
}

/* Emoji grid */
.emoji-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 1rem;
}

.emoji-card {
  background: white;
  border-radius: 16px;
  padding: 1.25rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  position: relative;
}

.emoji-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.15);
}

.emoji-icon {
  font-size: 3rem;
  margin-bottom: 0.5rem;
}

.emoji-word {
  font-weight: 600;
  color: #2c3e50;
  font-size: 0.95rem;
  margin-bottom: 0.25rem;
}

.emoji-fr {
  color: #7f8c8d;
  font-size: 0.85rem;
}

.emoji-audio {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  font-size: 0.8rem;
  opacity: 0.3;
  transition: all 0.2s;
}

.emoji-card:hover .emoji-audio {
  opacity: 1;
}

.emoji-audio.playing {
  opacity: 1;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.2); }
}

/* Practice */
.practice-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 1rem;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.stat-card.streak {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
  color: white;
}

.stat-card.accuracy {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.stat-value {
  display: block;
  font-size: 1.5rem;
  font-weight: 700;
}

.stat-label {
  font-size: 0.8rem;
  opacity: 0.8;
}

.practice-settings {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 12px;
}

.setting-group {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.setting-group label {
  font-size: 0.9rem;
  color: #666;
}

.setting-select {
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 0.9rem;
  background: white;
}

.practice-card {
  padding: 2rem;
  text-align: center;
  margin-bottom: 1.5rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.practice-question {
  margin-bottom: 2rem;
}

.question-emoji {
  font-size: 6rem;
}

.question-word {
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.question-fr {
  font-size: 2rem;
  font-weight: 600;
  color: #7f8c8d;
}

.audio-btn {
  background: #f0f0f0;
  border: none;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  cursor: pointer;
  font-size: 1.5rem;
  transition: all 0.2s;
}

.audio-btn:hover {
  background: #f093fb;
  transform: scale(1.1);
}

.practice-choices {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  max-width: 500px;
  margin: 0 auto;
}

.practice-choices.emoji-choices {
  grid-template-columns: repeat(4, 1fr);
  max-width: 400px;
}

.choice-btn {
  padding: 1rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 12px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 500;
  transition: all 0.2s;
}

.choice-btn.emoji-choice {
  font-size: 2.5rem;
  padding: 1rem;
}

.choice-btn:hover:not(:disabled) {
  border-color: #f093fb;
  transform: translateY(-2px);
}

.choice-btn.correct {
  background: #d4edda;
  border-color: #28a745;
}

.choice-btn.wrong {
  opacity: 0.5;
}

.practice-result {
  margin-top: 1.5rem;
  padding: 1.5rem;
  border-radius: 12px;
}

.practice-result.correct {
  background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
}

.practice-result.wrong {
  background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
}

.result-message {
  font-size: 1.2rem;
  margin-bottom: 1rem;
}

.audio-btn-inline {
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 1rem;
}

.next-btn {
  padding: 0.75rem 2rem;
  background: #2c3e50;
  color: white;
  border: none;
  border-radius: 25px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.next-btn:hover {
  background: #1a252f;
  transform: translateY(-2px);
}

.practice-actions {
  text-align: center;
}

.reset-btn {
  padding: 0.75rem 1.5rem;
  background: #f0f0f0;
  border: none;
  border-radius: 25px;
  cursor: pointer;
  font-size: 0.95rem;
  transition: all 0.2s;
}

.reset-btn:hover {
  background: #e0e0e0;
}

/* Responsive */
@media (max-width: 768px) {
  .emoji-grid {
    grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
  }
  
  .emoji-icon {
    font-size: 2.5rem;
  }
  
  .practice-stats {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .practice-choices.emoji-choices {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .question-emoji {
    font-size: 4rem;
  }
}

@media (max-width: 480px) {
  .emoji-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 0.5rem;
  }
  
  .emoji-card {
    padding: 0.75rem;
  }
  
  .emoji-icon {
    font-size: 2rem;
  }
  
  .emoji-word {
    font-size: 0.8rem;
  }
  
  .emoji-fr {
    font-size: 0.7rem;
  }
  
  .practice-settings {
    flex-direction: column;
  }
  
  .practice-choices {
    grid-template-columns: 1fr;
  }
}

.stories-intro {
  margin-bottom: 1.5rem;
  text-align: center;
  color: #7f8c8d;
}

.stories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 1rem;
}

.story-card {
  background: white;
  border-radius: 16px;
  padding: 1.25rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.story-emojis {
  font-size: 2rem;
}

.story-text-fr {
  font-size: 0.9rem;
  color: #7f8c8d;
}

.story-text-foreign {
  font-size: 1rem;
  font-weight: 600;
  color: #2c3e50;
}
</style>
