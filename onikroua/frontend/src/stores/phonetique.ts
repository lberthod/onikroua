import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface PhoneticSound {
  id: string
  language: 'it' | 'es'
  category: 'vowels' | 'consonants' | 'combinations' | 'accent' | 'special'
  graphie: string           // Graphie (ex: "CH", "GN")
  phonetic: string          // Symbole IPA (ex: "/k/", "/ɲ/")
  description: string       // Description en français
  examples: string[]        // Mots exemples
  position?: string         // Position dans le mot (début, milieu, fin)
  difficulty: 'easy' | 'medium' | 'hard'
  tips?: string             // Conseils de prononciation
  commonMistakes?: string   // Erreurs fréquentes des francophones
}

export interface PracticeWord {
  word: string
  phonetic?: string
  translation: string
  soundIds?: string[]       // IDs des sons présents dans le mot
}

export const usePhonetiqueStore = defineStore('phonetique', () => {
  const currentLanguage = ref<'it' | 'es'>('it')
  const currentCategory = ref<string>('all')
  const sounds = ref<PhoneticSound[]>([])
  const practiceWords = ref<PracticeWord[]>([])

  // Catégories disponibles
  const categories = [
    { id: 'all', name: 'Tous', icon: '📚' },
    { id: 'vowels', name: 'Voyelles', icon: '🔤' },
    { id: 'consonants', name: 'Consonnes', icon: '🔠' },
    { id: 'combinations', name: 'Combinaisons', icon: '🔗' },
    { id: 'accent', name: 'Accent', icon: '🎵' },
    { id: 'special', name: 'Spéciaux', icon: '⭐' }
  ]

  // Charger les données phonétiques
  const loadPhoneticData = () => {
    sounds.value = [
      // ============ ITALIEN - VOYELLES ============
      {
        id: 'it-a',
        language: 'it',
        category: 'vowels',
        graphie: 'A',
        phonetic: '/a/',
        description: 'Voyelle ouverte, comme le "a" français dans "patte"',
        examples: ['casa', 'amare', 'strada'],
        difficulty: 'easy',
        tips: 'Prononcez comme en français, bouche bien ouverte'
      },
      {
        id: 'it-e-open',
        language: 'it',
        category: 'vowels',
        graphie: 'E (ouvert)',
        phonetic: '/ɛ/',
        description: 'E ouvert, comme dans "père" en français',
        examples: ['bello', 'festa', 'tempo'],
        difficulty: 'medium',
        tips: 'Bouche plus ouverte que pour le E fermé',
        commonMistakes: 'Confusion avec le E fermé'
      },
      {
        id: 'it-e-closed',
        language: 'it',
        category: 'vowels',
        graphie: 'E (fermé)',
        phonetic: '/e/',
        description: 'E fermé, comme dans "été" en français',
        examples: ['sera', 'verde', 'pesce'],
        difficulty: 'medium',
        tips: 'Lèvres légèrement étirées'
      },
      {
        id: 'it-i',
        language: 'it',
        category: 'vowels',
        graphie: 'I',
        phonetic: '/i/',
        description: 'Voyelle fermée, comme le "i" français',
        examples: ['libro', 'vino', 'finire'],
        difficulty: 'easy'
      },
      {
        id: 'it-o-open',
        language: 'it',
        category: 'vowels',
        graphie: 'O (ouvert)',
        phonetic: '/ɔ/',
        description: 'O ouvert, comme dans "mort" en français',
        examples: ['cosa', 'porta', 'forte'],
        difficulty: 'medium'
      },
      {
        id: 'it-o-closed',
        language: 'it',
        category: 'vowels',
        graphie: 'O (fermé)',
        phonetic: '/o/',
        description: 'O fermé, comme dans "beau" en français',
        examples: ['sole', 'nome', 'poco'],
        difficulty: 'medium'
      },
      {
        id: 'it-u',
        language: 'it',
        category: 'vowels',
        graphie: 'U',
        phonetic: '/u/',
        description: 'Voyelle fermée arrondie, comme le "ou" français',
        examples: ['uno', 'luna', 'muro'],
        difficulty: 'easy',
        tips: 'Lèvres arrondies et projetées'
      },

      // ============ ITALIEN - CONSONNES ============
      {
        id: 'it-c-hard',
        language: 'it',
        category: 'consonants',
        graphie: 'C + a/o/u',
        phonetic: '/k/',
        description: 'C dur devant a, o, u - comme le "k" français',
        examples: ['casa', 'cosa', 'cuore'],
        difficulty: 'easy'
      },
      {
        id: 'it-c-soft',
        language: 'it',
        category: 'consonants',
        graphie: 'C + e/i',
        phonetic: '/tʃ/',
        description: 'C doux devant e, i - comme "tch" français',
        examples: ['cena', 'cinema', 'cielo'],
        difficulty: 'easy',
        tips: 'Pensez au son "tch" de "tchèque"'
      },
      {
        id: 'it-g-hard',
        language: 'it',
        category: 'consonants',
        graphie: 'G + a/o/u',
        phonetic: '/g/',
        description: 'G dur devant a, o, u - comme le "g" de "gare"',
        examples: ['gatto', 'gonna', 'gusto'],
        difficulty: 'easy'
      },
      {
        id: 'it-g-soft',
        language: 'it',
        category: 'consonants',
        graphie: 'G + e/i',
        phonetic: '/dʒ/',
        description: 'G doux devant e, i - comme "dj" français',
        examples: ['gelato', 'giro', 'gente'],
        difficulty: 'easy',
        tips: 'Comme le "j" anglais dans "job"'
      },
      {
        id: 'it-s-voiced',
        language: 'it',
        category: 'consonants',
        graphie: 'S (sonore)',
        phonetic: '/z/',
        description: 'S sonore entre deux voyelles',
        examples: ['rosa', 'casa', 'uso'],
        difficulty: 'medium',
        commonMistakes: 'Les francophones ont tendance à prononcer "ss"'
      },
      {
        id: 'it-z',
        language: 'it',
        category: 'consonants',
        graphie: 'Z',
        phonetic: '/ts/ ou /dz/',
        description: 'Z peut être sourd (ts) ou sonore (dz)',
        examples: ['pizza', 'zero', 'mezzo'],
        difficulty: 'hard',
        tips: 'Pizza = "pittsa", zero = "dzèro"'
      },
      {
        id: 'it-r',
        language: 'it',
        category: 'consonants',
        graphie: 'R',
        phonetic: '/r/',
        description: 'R roulé avec la pointe de la langue',
        examples: ['Roma', 'caro', 'treno'],
        difficulty: 'hard',
        tips: 'Faites vibrer la pointe de la langue contre le palais',
        commonMistakes: 'Ne pas utiliser le R français de gorge'
      },

      // ============ ITALIEN - COMBINAISONS ============
      {
        id: 'it-ch',
        language: 'it',
        category: 'combinations',
        graphie: 'CH',
        phonetic: '/k/',
        description: 'CH devant e/i se prononce "k" (dur)',
        examples: ['che', 'chi', 'chiesa', 'perché'],
        difficulty: 'medium',
        tips: 'CH = K, contrairement au français !',
        commonMistakes: 'Ne pas prononcer comme le "ch" français'
      },
      {
        id: 'it-gh',
        language: 'it',
        category: 'combinations',
        graphie: 'GH',
        phonetic: '/g/',
        description: 'GH devant e/i se prononce "g" dur',
        examples: ['ghiaccio', 'spaghetti', 'laghi'],
        difficulty: 'medium'
      },
      {
        id: 'it-gl',
        language: 'it',
        category: 'combinations',
        graphie: 'GLI',
        phonetic: '/ʎ/',
        description: 'GLI se prononce comme "lli" mouillé (comme "ill" dans "fille")',
        examples: ['famiglia', 'figlio', 'moglie', 'aglio'],
        difficulty: 'hard',
        tips: 'Langue contre le palais, son mouillé'
      },
      {
        id: 'it-gn',
        language: 'it',
        category: 'combinations',
        graphie: 'GN',
        phonetic: '/ɲ/',
        description: 'GN se prononce comme en français dans "agneau"',
        examples: ['gnocchi', 'bagno', 'montagna', 'ognuno'],
        difficulty: 'easy',
        tips: 'Identique au français !'
      },
      {
        id: 'it-sc-soft',
        language: 'it',
        category: 'combinations',
        graphie: 'SC + e/i',
        phonetic: '/ʃ/',
        description: 'SC devant e/i se prononce "ch" français',
        examples: ['pesce', 'uscire', 'scena', 'sciare'],
        difficulty: 'medium'
      },
      {
        id: 'it-sc-hard',
        language: 'it',
        category: 'combinations',
        graphie: 'SC + a/o/u',
        phonetic: '/sk/',
        description: 'SC devant a/o/u se prononce "sk"',
        examples: ['scuola', 'scarpa', 'disco'],
        difficulty: 'easy'
      },

      // ============ ITALIEN - DOUBLES CONSONNES ============
      {
        id: 'it-double',
        language: 'it',
        category: 'special',
        graphie: 'Doubles consonnes',
        phonetic: '/CC/',
        description: 'Les doubles consonnes sont prononcées plus longtemps',
        examples: ['pizza', 'cappuccino', 'mamma', 'bello'],
        difficulty: 'hard',
        tips: 'Allongez le son de la consonne, faites une petite pause',
        commonMistakes: 'pala ≠ palla, caro ≠ carro'
      },

      // ============ ESPAGNOL - VOYELLES ============
      {
        id: 'es-a',
        language: 'es',
        category: 'vowels',
        graphie: 'A',
        phonetic: '/a/',
        description: 'Voyelle ouverte, comme le "a" français',
        examples: ['casa', 'agua', 'mañana'],
        difficulty: 'easy'
      },
      {
        id: 'es-e',
        language: 'es',
        category: 'vowels',
        graphie: 'E',
        phonetic: '/e/',
        description: 'E toujours fermé en espagnol (pas de distinction ouvert/fermé)',
        examples: ['verde', 'leche', 'tres'],
        difficulty: 'easy'
      },
      {
        id: 'es-i',
        language: 'es',
        category: 'vowels',
        graphie: 'I',
        phonetic: '/i/',
        description: 'Voyelle fermée, comme le "i" français',
        examples: ['libro', 'vino', 'isla'],
        difficulty: 'easy'
      },
      {
        id: 'es-o',
        language: 'es',
        category: 'vowels',
        graphie: 'O',
        phonetic: '/o/',
        description: 'O toujours fermé en espagnol',
        examples: ['solo', 'como', 'poco'],
        difficulty: 'easy'
      },
      {
        id: 'es-u',
        language: 'es',
        category: 'vowels',
        graphie: 'U',
        phonetic: '/u/',
        description: 'Voyelle fermée arrondie, comme "ou" français',
        examples: ['uno', 'luna', 'mundo'],
        difficulty: 'easy'
      },

      // ============ ESPAGNOL - CONSONNES ============
      {
        id: 'es-b-v',
        language: 'es',
        category: 'consonants',
        graphie: 'B / V',
        phonetic: '/b/ ou /β/',
        description: 'B et V se prononcent de la même façon en espagnol',
        examples: ['bien', 'vino', 'beber', 'vivir'],
        difficulty: 'medium',
        tips: 'Entre deux voyelles, son plus doux (entre b et v)',
        commonMistakes: 'Ne faites pas de différence b/v comme en français'
      },
      {
        id: 'es-c-soft',
        language: 'es',
        category: 'consonants',
        graphie: 'C + e/i',
        phonetic: '/θ/ ou /s/',
        description: 'C devant e/i: "th" en Espagne, "s" en Amérique latine',
        examples: ['cielo', 'cinco', 'cena'],
        difficulty: 'medium',
        tips: 'En Espagne: langue entre les dents'
      },
      {
        id: 'es-d',
        language: 'es',
        category: 'consonants',
        graphie: 'D',
        phonetic: '/d/ ou /ð/',
        description: 'D entre voyelles devient très doux, presque "th" anglais',
        examples: ['dado', 'todo', 'nada'],
        difficulty: 'medium'
      },
      {
        id: 'es-g-hard',
        language: 'es',
        category: 'consonants',
        graphie: 'G + a/o/u',
        phonetic: '/g/ ou /ɣ/',
        description: 'G dur devant a, o, u',
        examples: ['gato', 'gota', 'gusto'],
        difficulty: 'easy'
      },
      {
        id: 'es-h',
        language: 'es',
        category: 'consonants',
        graphie: 'H',
        phonetic: '∅ (muet)',
        description: 'H est toujours muet en espagnol',
        examples: ['hola', 'hora', 'hacer'],
        difficulty: 'easy',
        tips: 'Ne prononcez jamais le H !'
      },
      {
        id: 'es-j',
        language: 'es',
        category: 'consonants',
        graphie: 'J',
        phonetic: '/x/',
        description: 'J = son guttural (comme le "ch" allemand)',
        examples: ['jamón', 'julio', 'rojo'],
        difficulty: 'hard',
        tips: 'Son qui vient du fond de la gorge',
        commonMistakes: 'Ce n\'est pas le "j" français !'
      },
      {
        id: 'es-r',
        language: 'es',
        category: 'consonants',
        graphie: 'R',
        phonetic: '/ɾ/',
        description: 'R simple: un seul battement de langue',
        examples: ['pero', 'caro', 'tres'],
        difficulty: 'medium'
      },
      {
        id: 'es-rr',
        language: 'es',
        category: 'consonants',
        graphie: 'RR',
        phonetic: '/r/',
        description: 'RR roulé: plusieurs battements de langue',
        examples: ['perro', 'carro', 'correo'],
        difficulty: 'hard',
        tips: 'Faites vibrer la langue plusieurs fois',
        commonMistakes: 'pero (mais) ≠ perro (chien)'
      },
      {
        id: 'es-z',
        language: 'es',
        category: 'consonants',
        graphie: 'Z',
        phonetic: '/θ/ ou /s/',
        description: 'Z: "th" en Espagne, "s" en Amérique latine',
        examples: ['zapato', 'azul', 'plaza'],
        difficulty: 'medium'
      },

      // ============ ESPAGNOL - COMBINAISONS ============
      {
        id: 'es-ll',
        language: 'es',
        category: 'combinations',
        graphie: 'LL',
        phonetic: '/ʝ/ ou /ʃ/',
        description: 'LL: "y" ou "ch" selon les régions',
        examples: ['llamar', 'calle', 'lluvia'],
        difficulty: 'medium',
        tips: 'En Argentine: proche du "ch" français'
      },
      {
        id: 'es-n-tilde',
        language: 'es',
        category: 'combinations',
        graphie: 'Ñ',
        phonetic: '/ɲ/',
        description: 'Ñ = comme "gn" français dans "agneau"',
        examples: ['España', 'niño', 'año', 'mañana'],
        difficulty: 'easy',
        tips: 'Identique au "gn" français !'
      },
      {
        id: 'es-qu',
        language: 'es',
        category: 'combinations',
        graphie: 'QU',
        phonetic: '/k/',
        description: 'QU devant e/i = "k" (U muet)',
        examples: ['que', 'quiero', 'pequeño'],
        difficulty: 'easy',
        tips: 'Le U ne se prononce pas'
      },
      {
        id: 'es-gu',
        language: 'es',
        category: 'combinations',
        graphie: 'GU + e/i',
        phonetic: '/g/',
        description: 'GU devant e/i = "g" dur (U muet)',
        examples: ['guerra', 'guitarra', 'guía'],
        difficulty: 'easy'
      },
      {
        id: 'es-gue-gui-dieresis',
        language: 'es',
        category: 'combinations',
        graphie: 'GÜ',
        phonetic: '/gw/',
        description: 'GÜ avec tréma = U prononcé',
        examples: ['pingüino', 'vergüenza', 'bilingüe'],
        difficulty: 'medium',
        tips: 'Le tréma indique que le U se prononce'
      },

      // ============ ESPAGNOL - ACCENT ============
      {
        id: 'es-accent',
        language: 'es',
        category: 'accent',
        graphie: 'Accent tonique',
        phonetic: 'ˈ',
        description: 'L\'accent écrit indique la syllabe accentuée',
        examples: ['música', 'teléfono', 'rápido', 'café'],
        difficulty: 'medium',
        tips: 'L\'accent change parfois le sens: si/sí, el/él'
      }
    ]

    // Mots pour la pratique
    practiceWords.value = [
      // Italien
      { word: 'ciao', phonetic: '/tʃao/', translation: 'salut' },
      { word: 'grazie', phonetic: '/ˈgrattsje/', translation: 'merci' },
      { word: 'prego', phonetic: '/ˈprɛːgo/', translation: 'de rien' },
      { word: 'buongiorno', phonetic: '/bwonˈdʒorno/', translation: 'bonjour' },
      { word: 'arrivederci', phonetic: '/arriˈvedertʃi/', translation: 'au revoir' },
      { word: 'famiglia', phonetic: '/faˈmiʎʎa/', translation: 'famille' },
      { word: 'spaghetti', phonetic: '/spaˈgetti/', translation: 'spaghetti' },
      { word: 'cappuccino', phonetic: '/kappuˈtʃiːno/', translation: 'cappuccino' },
      { word: 'pizza', phonetic: '/ˈpittsa/', translation: 'pizza' },
      { word: 'gelato', phonetic: '/dʒeˈlaːto/', translation: 'glace' },
      // Espagnol
      { word: 'hola', phonetic: '/ˈola/', translation: 'salut' },
      { word: 'gracias', phonetic: '/ˈgɾaθjas/', translation: 'merci' },
      { word: 'buenos días', phonetic: '/ˈbwenos ˈdias/', translation: 'bonjour' },
      { word: 'adiós', phonetic: '/aˈðjos/', translation: 'au revoir' },
      { word: 'por favor', phonetic: '/poɾ faˈβoɾ/', translation: 's\'il vous plaît' },
      { word: 'España', phonetic: '/esˈpaɲa/', translation: 'Espagne' },
      { word: 'mañana', phonetic: '/maˈɲana/', translation: 'demain' },
      { word: 'cerveza', phonetic: '/θerˈβeθa/', translation: 'bière' },
      { word: 'paella', phonetic: '/paˈeʎa/', translation: 'paella' },
      { word: 'jamón', phonetic: '/xaˈmon/', translation: 'jambon' }
    ]
  }

  // Filtres
  const filteredSounds = computed(() => {
    let result = sounds.value.filter(s => s.language === currentLanguage.value)
    if (currentCategory.value !== 'all') {
      result = result.filter(s => s.category === currentCategory.value)
    }
    return result
  })

  const filteredPracticeWords = computed(() => {
    return practiceWords.value.filter(w => {
      // Déterminer la langue du mot basé sur les exemples
      const itWords = ['ciao', 'grazie', 'prego', 'buongiorno', 'arrivederci', 'famiglia', 'spaghetti', 'cappuccino', 'pizza', 'gelato']
      if (currentLanguage.value === 'it') {
        return itWords.includes(w.word.toLowerCase())
      } else {
        return !itWords.includes(w.word.toLowerCase())
      }
    })
  })

  const categoryCount = computed(() => {
    const counts: Record<string, number> = {}
    const langSounds = sounds.value.filter(s => s.language === currentLanguage.value)
    
    counts['all'] = langSounds.length
    categories.forEach(cat => {
      if (cat.id !== 'all') {
        counts[cat.id] = langSounds.filter(s => s.category === cat.id).length
      }
    })
    return counts
  })

  const categoriesWithCount = computed(() => {
    return categories.map(cat => ({
      ...cat,
      count: categoryCount.value[cat.id] || 0
    }))
  })

  // Actions
  const setLanguage = (lang: 'it' | 'es') => {
    currentLanguage.value = lang
  }

  const setCategory = (category: string) => {
    currentCategory.value = category
  }

  return {
    currentLanguage,
    currentCategory,
    sounds,
    practiceWords,
    categories,
    filteredSounds,
    filteredPracticeWords,
    categoriesWithCount,
    loadPhoneticData,
    setLanguage,
    setCategory
  }
})
