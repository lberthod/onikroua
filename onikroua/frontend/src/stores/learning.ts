import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

// Types pour les sections d'apprentissage
export interface LearningItem {
  id: string
  language: 'it' | 'es'
  difficulty: 'beginner' | 'intermediate' | 'advanced'
  content: string
  translation: string
  example?: string
  audio?: string
}

export interface ConjugationItem extends LearningItem {
  verb: string
  tense: string
  conjugations: Record<string, string>
}

export interface VocabularyItem extends LearningItem {
  category: string
  gender?: 'm' | 'f'
  plural?: string
}

export interface GrammarExercise {
  id: string
  type: 'quiz' | 'fill-in'
  question: string
  options?: string[]
  correctAnswer: string
  explanation?: string
}

export type GrammarCategory = 
  | 'bases'           // Articles, pluriel, genre
  | 'adjectifs'       // Accord, possessifs, démonstratifs
  | 'pronoms'         // Sujets, COD, COI, réfléchis
  | 'verbes'          // Conjugaisons, temps, modes
  | 'syntaxe'         // Négation, questions, ordre des mots
  | 'prepositions'    // Prépositions, contractions
  | 'orthographe'     // Orthographe, accentuation

export type GrammarSubCategory = 
  // Bases
  | 'articles-definis' | 'articles-indefinis' | 'pluriel' | 'genre'
  // Adjectifs
  | 'accord-adjectifs' | 'possessifs' | 'demonstratifs' | 'comparatifs'
  // Pronoms
  | 'pronoms-sujets' | 'pronoms-cod' | 'pronoms-coi' | 'pronoms-reflexifs'
  // Verbes
  | 'present' | 'passe-compose' | 'imparfait' | 'futur' | 'conditionnel' | 'subjonctif' | 'imperatif' | 'verbes-irreguliers'
  // Syntaxe
  | 'negation' | 'questions' | 'ordre-mots'
  // Prépositions
  | 'prepositions-base' | 'prepositions-articulees' | 'por-para' | 'ser-estar'
  // Orthographe
  | 'orthographe'

export interface GrammarItem extends LearningItem {
  rule: string
  category: GrammarCategory
  subCategory: GrammarSubCategory
  exceptions?: string[]
  exercises?: GrammarExercise[]
}

export interface PhoneticItem extends LearningItem {
  phonetic: string
  audioUrl?: string
}

export interface LearningProgress {
  sectionId: string
  itemsCompleted: number
  totalItems: number
  lastAccessed: Date
  score: number
}

export const useLearningStore = defineStore('learning', () => {
  // État
  const currentLanguage = ref<'it' | 'es'>('it')
  const currentSection = ref<string>('conjugaison')
  const currentDifficulty = ref<'beginner' | 'intermediate' | 'advanced'>('beginner')
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Progression par section
  const progress = ref<Record<string, LearningProgress>>({})

  // Données d'apprentissage (à remplir depuis Firebase ou API)
  const conjugations = ref<ConjugationItem[]>([])
  const vocabulary = ref<VocabularyItem[]>([])
  const grammar = ref<GrammarItem[]>([])
  const phonetics = ref<PhoneticItem[]>([])

  // Computed
  const currentProgress = computed(() => {
    const key = `${currentSection.value}_${currentLanguage.value}`
    return progress.value[key] || null
  })

  const progressPercentage = computed(() => {
    if (!currentProgress.value) return 0
    return Math.round((currentProgress.value.itemsCompleted / currentProgress.value.totalItems) * 100)
  })

  // Actions
  const setLanguage = (lang: 'it' | 'es') => {
    currentLanguage.value = lang
  }

  const setSection = (section: string) => {
    currentSection.value = section
  }

  const setDifficulty = (diff: 'beginner' | 'intermediate' | 'advanced') => {
    currentDifficulty.value = diff
  }

  const updateProgress = (sectionId: string, completed: number, total: number, score: number) => {
    const key = `${sectionId}_${currentLanguage.value}`
    progress.value[key] = {
      sectionId,
      itemsCompleted: completed,
      totalItems: total,
      lastAccessed: new Date(),
      score
    }
  }

  const resetSection = (sectionId: string) => {
    const key = `${sectionId}_${currentLanguage.value}`
    delete progress.value[key]
  }

  // Données de démonstration - Conjugaisons
  const loadDemoConjugations = () => {
    conjugations.value = [
      // Italien
      {
        id: 'it-essere-present',
        language: 'it',
        difficulty: 'beginner',
        verb: 'essere',
        tense: 'Présent',
        content: 'Conjugaison du verbe être en italien',
        translation: 'être',
        conjugations: {
          'io': 'sono',
          'tu': 'sei',
          'lui/lei': 'è',
          'noi': 'siamo',
          'voi': 'siete',
          'loro': 'sono'
        },
        example: 'Io sono italiano. (Je suis italien.)'
      },
      {
        id: 'it-avere-present',
        language: 'it',
        difficulty: 'beginner',
        verb: 'avere',
        tense: 'Présent',
        content: 'Conjugaison du verbe avoir en italien',
        translation: 'avoir',
        conjugations: {
          'io': 'ho',
          'tu': 'hai',
          'lui/lei': 'ha',
          'noi': 'abbiamo',
          'voi': 'avete',
          'loro': 'hanno'
        },
        example: 'Io ho fame. (J\'ai faim.)'
      },
      {
        id: 'it-parlare-present',
        language: 'it',
        difficulty: 'beginner',
        verb: 'parlare',
        tense: 'Présent',
        content: 'Conjugaison du verbe parler en italien',
        translation: 'parler',
        conjugations: {
          'io': 'parlo',
          'tu': 'parli',
          'lui/lei': 'parla',
          'noi': 'parliamo',
          'voi': 'parlate',
          'loro': 'parlano'
        },
        example: 'Io parlo italiano. (Je parle italien.)'
      },
      // Espagnol
      {
        id: 'es-ser-present',
        language: 'es',
        difficulty: 'beginner',
        verb: 'ser',
        tense: 'Présent',
        content: 'Conjugaison du verbe être (permanent) en espagnol',
        translation: 'être',
        conjugations: {
          'yo': 'soy',
          'tú': 'eres',
          'él/ella': 'es',
          'nosotros': 'somos',
          'vosotros': 'sois',
          'ellos': 'son'
        },
        example: 'Yo soy español. (Je suis espagnol.)'
      },
      {
        id: 'es-estar-present',
        language: 'es',
        difficulty: 'beginner',
        verb: 'estar',
        tense: 'Présent',
        content: 'Conjugaison du verbe être (état) en espagnol',
        translation: 'être',
        conjugations: {
          'yo': 'estoy',
          'tú': 'estás',
          'él/ella': 'está',
          'nosotros': 'estamos',
          'vosotros': 'estáis',
          'ellos': 'están'
        },
        example: 'Yo estoy cansado. (Je suis fatigué.)'
      },
      {
        id: 'es-hablar-present',
        language: 'es',
        difficulty: 'beginner',
        verb: 'hablar',
        tense: 'Présent',
        content: 'Conjugaison du verbe parler en espagnol',
        translation: 'parler',
        conjugations: {
          'yo': 'hablo',
          'tú': 'hablas',
          'él/ella': 'habla',
          'nosotros': 'hablamos',
          'vosotros': 'habláis',
          'ellos': 'hablan'
        },
        example: 'Yo hablo español. (Je parle espagnol.)'
      },
      // Verbes italiens supplémentaires
      {
        id: 'it-potere-present',
        language: 'it',
        difficulty: 'beginner',
        verb: 'potere',
        tense: 'Présent',
        content: 'Conjugaison du verbe pouvoir en italien',
        translation: 'pouvoir',
        conjugations: {
          'io': 'posso',
          'tu': 'puoi',
          'lui/lei': 'può',
          'noi': 'possiamo',
          'voi': 'potete',
          'loro': 'possono'
        },
        example: 'Posso venire domani. (Je peux venir demain.)'
      },
      {
        id: 'it-volere-present',
        language: 'it',
        difficulty: 'beginner',
        verb: 'volere',
        tense: 'Présent',
        content: 'Conjugaison du verbe vouloir en italien',
        translation: 'vouloir',
        conjugations: {
          'io': 'voglio',
          'tu': 'vuoi',
          'lui/lei': 'vuole',
          'noi': 'vogliamo',
          'voi': 'volete',
          'loro': 'vogliono'
        },
        example: 'Voglio imparare l\'italiano. (Je veux apprendre l\'italien.)'
      },
      {
        id: 'it-dovere-present',
        language: 'it',
        difficulty: 'beginner',
        verb: 'dovere',
        tense: 'Présent',
        content: 'Conjugaison du verbe devoir en italien',
        translation: 'devoir',
        conjugations: {
          'io': 'devo',
          'tu': 'devi',
          'lui/lei': 'deve',
          'noi': 'dobbiamo',
          'voi': 'dovete',
          'loro': 'devono'
        },
        example: 'Devo studiare stasera. (Je dois étudier ce soir.)'
      },
      {
        id: 'it-andare-present',
        language: 'it',
        difficulty: 'beginner',
        verb: 'andare',
        tense: 'Présent',
        content: 'Conjugaison du verbe aller en italien',
        translation: 'aller',
        conjugations: {
          'io': 'vado',
          'tu': 'vai',
          'lui/lei': 'va',
          'noi': 'andiamo',
          'voi': 'andate',
          'loro': 'vanno'
        },
        example: 'Vado a scuola. (Je vais à l\'école.)'
      },
      {
        id: 'it-fare-present',
        language: 'it',
        difficulty: 'beginner',
        verb: 'fare',
        tense: 'Présent',
        content: 'Conjugaison du verbe faire en italien',
        translation: 'faire',
        conjugations: {
          'io': 'faccio',
          'tu': 'fai',
          'lui/lei': 'fa',
          'noi': 'facciamo',
          'voi': 'fate',
          'loro': 'fanno'
        },
        example: 'Faccio i compiti. (Je fais les devoirs.)'
      },
      // Verbes espagnols supplémentaires
      {
        id: 'es-tener-present',
        language: 'es',
        difficulty: 'beginner',
        verb: 'tener',
        tense: 'Présent',
        content: 'Conjugaison du verbe avoir en espagnol',
        translation: 'avoir',
        conjugations: {
          'yo': 'tengo',
          'tú': 'tienes',
          'él/ella': 'tiene',
          'nosotros': 'tenemos',
          'vosotros': 'tenéis',
          'ellos': 'tienen'
        },
        example: 'Tengo dos hermanos. (J\'ai deux frères.)'
      },
      {
        id: 'es-poder-present',
        language: 'es',
        difficulty: 'beginner',
        verb: 'poder',
        tense: 'Présent',
        content: 'Conjugaison du verbe pouvoir en espagnol',
        translation: 'pouvoir',
        conjugations: {
          'yo': 'puedo',
          'tú': 'puedes',
          'él/ella': 'puede',
          'nosotros': 'podemos',
          'vosotros': 'podéis',
          'ellos': 'pueden'
        },
        example: 'Puedo hablar español. (Je peux parler espagnol.)'
      },
      {
        id: 'es-querer-present',
        language: 'es',
        difficulty: 'beginner',
        verb: 'querer',
        tense: 'Présent',
        content: 'Conjugaison du verbe vouloir en espagnol',
        translation: 'vouloir',
        conjugations: {
          'yo': 'quiero',
          'tú': 'quieres',
          'él/ella': 'quiere',
          'nosotros': 'queremos',
          'vosotros': 'queréis',
          'ellos': 'quieren'
        },
        example: 'Quiero viajar más. (Je veux voyager davantage.)'
      },
      {
        id: 'es-ir-present',
        language: 'es',
        difficulty: 'beginner',
        verb: 'ir',
        tense: 'Présent',
        content: 'Conjugaison du verbe aller en espagnol',
        translation: 'aller',
        conjugations: {
          'yo': 'voy',
          'tú': 'vas',
          'él/ella': 'va',
          'nosotros': 'vamos',
          'vosotros': 'vais',
          'ellos': 'van'
        },
        example: 'Voy al trabajo. (Je vais au travail.)'
      },
      {
        id: 'es-hacer-present',
        language: 'es',
        difficulty: 'beginner',
        verb: 'hacer',
        tense: 'Présent',
        content: 'Conjugaison du verbe faire en espagnol',
        translation: 'faire',
        conjugations: {
          'yo': 'hago',
          'tú': 'haces',
          'él/ella': 'hace',
          'nosotros': 'hacemos',
          'vosotros': 'hacéis',
          'ellos': 'hacen'
        },
        example: 'Hago los deberes. (Je fais les devoirs.)'
      }
    ]
  }

  // Données de démonstration - Vocabulaire
  const loadDemoVocabulary = () => {
    vocabulary.value = [
      // ========== ITALIEN ==========
      // Salutations
      { id: 'it-ciao', language: 'it', difficulty: 'beginner', category: 'Salutations', content: 'Ciao', translation: 'Salut / Au revoir', example: 'Ciao, come stai?' },
      { id: 'it-buongiorno', language: 'it', difficulty: 'beginner', category: 'Salutations', content: 'Buongiorno', translation: 'Bonjour', example: 'Buongiorno, signore!' },
      { id: 'it-buonasera', language: 'it', difficulty: 'beginner', category: 'Salutations', content: 'Buonasera', translation: 'Bonsoir', example: 'Buonasera a tutti!' },
      { id: 'it-arrivederci', language: 'it', difficulty: 'beginner', category: 'Salutations', content: 'Arrivederci', translation: 'Au revoir', example: 'Arrivederci e buona giornata!' },
      // Politesse
      { id: 'it-grazie', language: 'it', difficulty: 'beginner', category: 'Politesse', content: 'Grazie', translation: 'Merci', example: 'Grazie mille!' },
      { id: 'it-prego', language: 'it', difficulty: 'beginner', category: 'Politesse', content: 'Prego', translation: 'De rien / Je vous en prie', example: 'Prego, si accomodi.' },
      { id: 'it-scusi', language: 'it', difficulty: 'beginner', category: 'Politesse', content: 'Scusi', translation: 'Excusez-moi', example: 'Scusi, dov\'è la stazione?' },
      { id: 'it-per-favore', language: 'it', difficulty: 'beginner', category: 'Politesse', content: 'Per favore', translation: 'S\'il vous plaît', example: 'Un caffè, per favore.' },
      // Nourriture
      { id: 'it-acqua', language: 'it', difficulty: 'beginner', category: 'Nourriture', content: 'Acqua', translation: 'Eau', gender: 'f', example: 'Un bicchiere d\'acqua, per favore.' },
      { id: 'it-pane', language: 'it', difficulty: 'beginner', category: 'Nourriture', content: 'Pane', translation: 'Pain', gender: 'm', example: 'Il pane è fresco.' },
      { id: 'it-vino', language: 'it', difficulty: 'beginner', category: 'Nourriture', content: 'Vino', translation: 'Vin', gender: 'm', example: 'Un bicchiere di vino rosso.' },
      { id: 'it-caffe', language: 'it', difficulty: 'beginner', category: 'Nourriture', content: 'Caffè', translation: 'Café', gender: 'm', example: 'Prendo un caffè.' },
      { id: 'it-pizza', language: 'it', difficulty: 'beginner', category: 'Nourriture', content: 'Pizza', translation: 'Pizza', gender: 'f', example: 'La pizza margherita è buonissima.' },
      { id: 'it-pasta', language: 'it', difficulty: 'beginner', category: 'Nourriture', content: 'Pasta', translation: 'Pâtes', gender: 'f', example: 'Mi piace la pasta al pomodoro.' },
      { id: 'it-formaggio', language: 'it', difficulty: 'beginner', category: 'Nourriture', content: 'Formaggio', translation: 'Fromage', gender: 'm', example: 'Il parmigiano è un formaggio italiano.' },
      // Famille
      { id: 'it-madre', language: 'it', difficulty: 'beginner', category: 'Famille', content: 'Madre', translation: 'Mère', gender: 'f', example: 'Mia madre si chiama Maria.' },
      { id: 'it-padre', language: 'it', difficulty: 'beginner', category: 'Famille', content: 'Padre', translation: 'Père', gender: 'm', example: 'Mio padre lavora in ufficio.' },
      { id: 'it-fratello', language: 'it', difficulty: 'beginner', category: 'Famille', content: 'Fratello', translation: 'Frère', gender: 'm', example: 'Ho un fratello maggiore.' },
      { id: 'it-sorella', language: 'it', difficulty: 'beginner', category: 'Famille', content: 'Sorella', translation: 'Sœur', gender: 'f', example: 'Mia sorella ha vent\'anni.' },
      { id: 'it-nonno', language: 'it', difficulty: 'beginner', category: 'Famille', content: 'Nonno', translation: 'Grand-père', gender: 'm', example: 'Il nonno racconta storie.' },
      { id: 'it-nonna', language: 'it', difficulty: 'beginner', category: 'Famille', content: 'Nonna', translation: 'Grand-mère', gender: 'f', example: 'La nonna cucina benissimo.' },
      // Nombres
      { id: 'it-uno', language: 'it', difficulty: 'beginner', category: 'Nombres', content: 'Uno', translation: '1 (un)', example: 'Ho un gatto.' },
      { id: 'it-due', language: 'it', difficulty: 'beginner', category: 'Nombres', content: 'Due', translation: '2 (deux)', example: 'Due caffè, per favore.' },
      { id: 'it-tre', language: 'it', difficulty: 'beginner', category: 'Nombres', content: 'Tre', translation: '3 (trois)', example: 'Sono le tre.' },
      { id: 'it-quattro', language: 'it', difficulty: 'beginner', category: 'Nombres', content: 'Quattro', translation: '4 (quatre)', example: 'Ho quattro fratelli.' },
      { id: 'it-cinque', language: 'it', difficulty: 'beginner', category: 'Nombres', content: 'Cinque', translation: '5 (cinq)', example: 'Cinque minuti.' },
      { id: 'it-dieci', language: 'it', difficulty: 'beginner', category: 'Nombres', content: 'Dieci', translation: '10 (dix)', example: 'Costa dieci euro.' },
      // Couleurs
      { id: 'it-rosso', language: 'it', difficulty: 'beginner', category: 'Couleurs', content: 'Rosso', translation: 'Rouge', example: 'Il vino rosso.' },
      { id: 'it-blu', language: 'it', difficulty: 'beginner', category: 'Couleurs', content: 'Blu', translation: 'Bleu', example: 'Il cielo è blu.' },
      { id: 'it-verde', language: 'it', difficulty: 'beginner', category: 'Couleurs', content: 'Verde', translation: 'Vert', example: 'L\'erba è verde.' },
      { id: 'it-bianco', language: 'it', difficulty: 'beginner', category: 'Couleurs', content: 'Bianco', translation: 'Blanc', example: 'La neve è bianca.' },
      { id: 'it-nero', language: 'it', difficulty: 'beginner', category: 'Couleurs', content: 'Nero', translation: 'Noir', example: 'Un caffè nero.' },
      // Temps
      { id: 'it-oggi', language: 'it', difficulty: 'beginner', category: 'Temps', content: 'Oggi', translation: 'Aujourd\'hui', example: 'Oggi è lunedì.' },
      { id: 'it-domani', language: 'it', difficulty: 'beginner', category: 'Temps', content: 'Domani', translation: 'Demain', example: 'Ci vediamo domani.' },
      { id: 'it-ieri', language: 'it', difficulty: 'beginner', category: 'Temps', content: 'Ieri', translation: 'Hier', example: 'Ieri sono andato al cinema.' },
      { id: 'it-ora', language: 'it', difficulty: 'beginner', category: 'Temps', content: 'Ora', translation: 'Maintenant', example: 'Vengo ora.' },
      { id: 'it-sempre', language: 'it', difficulty: 'beginner', category: 'Temps', content: 'Sempre', translation: 'Toujours', example: 'Ti amerò sempre.' },
      // Lieux
      { id: 'it-casa', language: 'it', difficulty: 'beginner', category: 'Lieux', content: 'Casa', translation: 'Maison', gender: 'f', example: 'Torno a casa.' },
      { id: 'it-ristorante', language: 'it', difficulty: 'beginner', category: 'Lieux', content: 'Ristorante', translation: 'Restaurant', gender: 'm', example: 'Andiamo al ristorante.' },
      { id: 'it-stazione', language: 'it', difficulty: 'beginner', category: 'Lieux', content: 'Stazione', translation: 'Gare', gender: 'f', example: 'La stazione è vicina.' },
      { id: 'it-aeroporto', language: 'it', difficulty: 'beginner', category: 'Lieux', content: 'Aeroporto', translation: 'Aéroport', gender: 'm', example: 'L\'aeroporto è lontano.' },
      // Verbes essentiels
      { id: 'it-essere', language: 'it', difficulty: 'beginner', category: 'Verbes', content: 'Essere', translation: 'Être', example: 'Io sono italiano.' },
      { id: 'it-avere', language: 'it', difficulty: 'beginner', category: 'Verbes', content: 'Avere', translation: 'Avoir', example: 'Ho fame.' },
      { id: 'it-fare', language: 'it', difficulty: 'beginner', category: 'Verbes', content: 'Fare', translation: 'Faire', example: 'Cosa fai?' },
      { id: 'it-andare', language: 'it', difficulty: 'beginner', category: 'Verbes', content: 'Andare', translation: 'Aller', example: 'Vado a Roma.' },
      { id: 'it-venire', language: 'it', difficulty: 'beginner', category: 'Verbes', content: 'Venire', translation: 'Venir', example: 'Vieni con me?' },
      { id: 'it-mangiare', language: 'it', difficulty: 'beginner', category: 'Verbes', content: 'Mangiare', translation: 'Manger', example: 'Mangio la pizza.' },
      { id: 'it-bere', language: 'it', difficulty: 'beginner', category: 'Verbes', content: 'Bere', translation: 'Boire', example: 'Bevo un caffè.' },
      { id: 'it-parlare', language: 'it', difficulty: 'beginner', category: 'Verbes', content: 'Parlare', translation: 'Parler', example: 'Parlo italiano.' },
      
      // ========== ESPAGNOL ==========
      // Salutations
      { id: 'es-hola', language: 'es', difficulty: 'beginner', category: 'Salutations', content: 'Hola', translation: 'Salut / Bonjour', example: '¡Hola! ¿Qué tal?' },
      { id: 'es-buenos-dias', language: 'es', difficulty: 'beginner', category: 'Salutations', content: 'Buenos días', translation: 'Bonjour', example: '¡Buenos días, señor!' },
      { id: 'es-buenas-tardes', language: 'es', difficulty: 'beginner', category: 'Salutations', content: 'Buenas tardes', translation: 'Bon après-midi', example: 'Buenas tardes a todos.' },
      { id: 'es-buenas-noches', language: 'es', difficulty: 'beginner', category: 'Salutations', content: 'Buenas noches', translation: 'Bonsoir / Bonne nuit', example: 'Buenas noches, hasta mañana.' },
      { id: 'es-adios', language: 'es', difficulty: 'beginner', category: 'Salutations', content: 'Adiós', translation: 'Au revoir', example: '¡Adiós, amigo!' },
      // Politesse
      { id: 'es-gracias', language: 'es', difficulty: 'beginner', category: 'Politesse', content: 'Gracias', translation: 'Merci', example: '¡Muchas gracias!' },
      { id: 'es-de-nada', language: 'es', difficulty: 'beginner', category: 'Politesse', content: 'De nada', translation: 'De rien', example: 'De nada, es un placer.' },
      { id: 'es-por-favor', language: 'es', difficulty: 'beginner', category: 'Politesse', content: 'Por favor', translation: 'S\'il vous plaît', example: 'Un café, por favor.' },
      { id: 'es-perdone', language: 'es', difficulty: 'beginner', category: 'Politesse', content: 'Perdone', translation: 'Excusez-moi', example: 'Perdone, ¿dónde está la estación?' },
      { id: 'es-lo-siento', language: 'es', difficulty: 'beginner', category: 'Politesse', content: 'Lo siento', translation: 'Je suis désolé', example: 'Lo siento mucho.' },
      // Nourriture
      { id: 'es-agua', language: 'es', difficulty: 'beginner', category: 'Nourriture', content: 'Agua', translation: 'Eau', gender: 'f', example: 'Un vaso de agua, por favor.' },
      { id: 'es-pan', language: 'es', difficulty: 'beginner', category: 'Nourriture', content: 'Pan', translation: 'Pain', gender: 'm', example: 'El pan está fresco.' },
      { id: 'es-vino', language: 'es', difficulty: 'beginner', category: 'Nourriture', content: 'Vino', translation: 'Vin', gender: 'm', example: 'Una copa de vino tinto.' },
      { id: 'es-cafe', language: 'es', difficulty: 'beginner', category: 'Nourriture', content: 'Café', translation: 'Café', gender: 'm', example: 'Quiero un café con leche.' },
      { id: 'es-carne', language: 'es', difficulty: 'beginner', category: 'Nourriture', content: 'Carne', translation: 'Viande', gender: 'f', example: 'La carne está muy buena.' },
      { id: 'es-pescado', language: 'es', difficulty: 'beginner', category: 'Nourriture', content: 'Pescado', translation: 'Poisson', gender: 'm', example: 'Me gusta el pescado.' },
      { id: 'es-fruta', language: 'es', difficulty: 'beginner', category: 'Nourriture', content: 'Fruta', translation: 'Fruit', gender: 'f', example: 'Como fruta todos los días.' },
      // Famille
      { id: 'es-madre', language: 'es', difficulty: 'beginner', category: 'Famille', content: 'Madre', translation: 'Mère', gender: 'f', example: 'Mi madre se llama Ana.' },
      { id: 'es-padre', language: 'es', difficulty: 'beginner', category: 'Famille', content: 'Padre', translation: 'Père', gender: 'm', example: 'Mi padre trabaja mucho.' },
      { id: 'es-hermano', language: 'es', difficulty: 'beginner', category: 'Famille', content: 'Hermano', translation: 'Frère', gender: 'm', example: 'Tengo un hermano mayor.' },
      { id: 'es-hermana', language: 'es', difficulty: 'beginner', category: 'Famille', content: 'Hermana', translation: 'Sœur', gender: 'f', example: 'Mi hermana tiene veinte años.' },
      { id: 'es-abuelo', language: 'es', difficulty: 'beginner', category: 'Famille', content: 'Abuelo', translation: 'Grand-père', gender: 'm', example: 'Mi abuelo cuenta historias.' },
      { id: 'es-abuela', language: 'es', difficulty: 'beginner', category: 'Famille', content: 'Abuela', translation: 'Grand-mère', gender: 'f', example: 'Mi abuela cocina muy bien.' },
      // Nombres
      { id: 'es-uno', language: 'es', difficulty: 'beginner', category: 'Nombres', content: 'Uno', translation: '1 (un)', example: 'Tengo un gato.' },
      { id: 'es-dos', language: 'es', difficulty: 'beginner', category: 'Nombres', content: 'Dos', translation: '2 (deux)', example: 'Dos cafés, por favor.' },
      { id: 'es-tres', language: 'es', difficulty: 'beginner', category: 'Nombres', content: 'Tres', translation: '3 (trois)', example: 'Son las tres.' },
      { id: 'es-cuatro', language: 'es', difficulty: 'beginner', category: 'Nombres', content: 'Cuatro', translation: '4 (quatre)', example: 'Tengo cuatro hermanos.' },
      { id: 'es-cinco', language: 'es', difficulty: 'beginner', category: 'Nombres', content: 'Cinco', translation: '5 (cinq)', example: 'Cinco minutos.' },
      { id: 'es-diez', language: 'es', difficulty: 'beginner', category: 'Nombres', content: 'Diez', translation: '10 (dix)', example: 'Cuesta diez euros.' },
      // Couleurs
      { id: 'es-rojo', language: 'es', difficulty: 'beginner', category: 'Couleurs', content: 'Rojo', translation: 'Rouge', example: 'El vino tinto es rojo.' },
      { id: 'es-azul', language: 'es', difficulty: 'beginner', category: 'Couleurs', content: 'Azul', translation: 'Bleu', example: 'El cielo es azul.' },
      { id: 'es-verde', language: 'es', difficulty: 'beginner', category: 'Couleurs', content: 'Verde', translation: 'Vert', example: 'La hierba es verde.' },
      { id: 'es-blanco', language: 'es', difficulty: 'beginner', category: 'Couleurs', content: 'Blanco', translation: 'Blanc', example: 'La nieve es blanca.' },
      { id: 'es-negro', language: 'es', difficulty: 'beginner', category: 'Couleurs', content: 'Negro', translation: 'Noir', example: 'Un café solo.' },
      // Temps
      { id: 'es-hoy', language: 'es', difficulty: 'beginner', category: 'Temps', content: 'Hoy', translation: 'Aujourd\'hui', example: 'Hoy es lunes.' },
      { id: 'es-manana', language: 'es', difficulty: 'beginner', category: 'Temps', content: 'Mañana', translation: 'Demain', example: 'Nos vemos mañana.' },
      { id: 'es-ayer', language: 'es', difficulty: 'beginner', category: 'Temps', content: 'Ayer', translation: 'Hier', example: 'Ayer fui al cine.' },
      { id: 'es-ahora', language: 'es', difficulty: 'beginner', category: 'Temps', content: 'Ahora', translation: 'Maintenant', example: 'Vengo ahora.' },
      { id: 'es-siempre', language: 'es', difficulty: 'beginner', category: 'Temps', content: 'Siempre', translation: 'Toujours', example: 'Te querré siempre.' },
      // Lieux
      { id: 'es-casa', language: 'es', difficulty: 'beginner', category: 'Lieux', content: 'Casa', translation: 'Maison', gender: 'f', example: 'Vuelvo a casa.' },
      { id: 'es-restaurante', language: 'es', difficulty: 'beginner', category: 'Lieux', content: 'Restaurante', translation: 'Restaurant', gender: 'm', example: 'Vamos al restaurante.' },
      { id: 'es-estacion', language: 'es', difficulty: 'beginner', category: 'Lieux', content: 'Estación', translation: 'Gare', gender: 'f', example: 'La estación está cerca.' },
      { id: 'es-aeropuerto', language: 'es', difficulty: 'beginner', category: 'Lieux', content: 'Aeropuerto', translation: 'Aéroport', gender: 'm', example: 'El aeropuerto está lejos.' },
      { id: 'es-playa', language: 'es', difficulty: 'beginner', category: 'Lieux', content: 'Playa', translation: 'Plage', gender: 'f', example: 'Vamos a la playa.' },
      // Verbes essentiels
      { id: 'es-ser', language: 'es', difficulty: 'beginner', category: 'Verbes', content: 'Ser', translation: 'Être (permanent)', example: 'Soy español.' },
      { id: 'es-estar', language: 'es', difficulty: 'beginner', category: 'Verbes', content: 'Estar', translation: 'Être (état)', example: 'Estoy cansado.' },
      { id: 'es-tener', language: 'es', difficulty: 'beginner', category: 'Verbes', content: 'Tener', translation: 'Avoir', example: 'Tengo hambre.' },
      { id: 'es-hacer', language: 'es', difficulty: 'beginner', category: 'Verbes', content: 'Hacer', translation: 'Faire', example: '¿Qué haces?' },
      { id: 'es-ir', language: 'es', difficulty: 'beginner', category: 'Verbes', content: 'Ir', translation: 'Aller', example: 'Voy a Madrid.' },
      { id: 'es-venir', language: 'es', difficulty: 'beginner', category: 'Verbes', content: 'Venir', translation: 'Venir', example: '¿Vienes conmigo?' },
      { id: 'es-comer', language: 'es', difficulty: 'beginner', category: 'Verbes', content: 'Comer', translation: 'Manger', example: 'Como paella.' },
      { id: 'es-beber', language: 'es', difficulty: 'beginner', category: 'Verbes', content: 'Beber', translation: 'Boire', example: 'Bebo agua.' },
      { id: 'es-hablar', language: 'es', difficulty: 'beginner', category: 'Verbes', content: 'Hablar', translation: 'Parler', example: 'Hablo español.' }
    ]
  }

  // Données de démonstration - Grammaire
  const loadDemoGrammar = () => {
    grammar.value = [
      // Italien
      {
        id: 'it-articles-definis',
        language: 'it',
        difficulty: 'beginner',
        category: 'bases',
        subCategory: 'articles-definis',
        rule: 'Articles définis',
        content: 'Les articles définis en italien varient selon le genre et le nombre',
        translation: 'il, lo, la, i, gli, le',
        example: 'il libro (le livre), la casa (la maison), i libri (les livres)',
        exceptions: ['lo devant s+consonne, z, gn, ps, x, y', 'l\' devant voyelle'],
        exercises: [
          {
            id: 'ex-it-art-1',
            type: 'quiz',
            question: 'Quel est l\'article pour "libro" (livre, masculin singulier) ?',
            options: ['il', 'la', 'lo', 'i'],
            correctAnswer: 'il',
            explanation: 'Libro est masculin singulier et commence par une consonne normale.'
          },
          {
            id: 'ex-it-art-2',
            type: 'fill-in',
            question: 'Complétez : ___ casa (la maison)',
            correctAnswer: 'la',
            explanation: 'Casa est féminin singulier.'
          },
          {
            id: 'ex-it-art-3',
            type: 'quiz',
            question: 'Quel article utiliser devant "studente" (étudiant, commence par s+consonne) ?',
            options: ['il', 'lo', 'la', 'gli'],
            correctAnswer: 'lo',
            explanation: 'On utilise "lo" devant les mots masculins commençant par s + consonne.'
          }
        ]
      },
      {
        id: 'it-pluriel',
        language: 'it',
        difficulty: 'beginner',
        category: 'bases',
        subCategory: 'pluriel',
        rule: 'Formation du pluriel',
        content: 'Le pluriel se forme en changeant la terminaison',
        translation: '-o → -i (masc), -a → -e (fém), -e → -i',
        example: 'libro → libri, casa → case, notte → notti',
        exercises: [
          {
            id: 'ex-it-plu-1',
            type: 'quiz',
            question: 'Quel est le pluriel de "gatto" (chat) ?',
            options: ['gatte', 'gatti', 'gatta', 'gattos'],
            correctAnswer: 'gatti',
            explanation: 'Les mots masculins en -o font leur pluriel en -i.'
          },
          {
            id: 'ex-it-plu-2',
            type: 'fill-in',
            question: 'Écrivez le pluriel de "pizza" :',
            correctAnswer: 'pizze',
            explanation: 'Les mots féminins en -a font leur pluriel en -e.'
          }
        ]
      },
      {
        id: 'it-negation',
        language: 'it',
        difficulty: 'beginner',
        category: 'syntaxe',
        subCategory: 'negation',
        rule: 'La négation',
        content: 'La négation se forme avec "non" devant le verbe',
        translation: 'non + verbe',
        example: 'Non parlo italiano. (Je ne parle pas italien.)',
        exercises: [
          {
            id: 'ex-it-neg-1',
            type: 'fill-in',
            question: 'Transformez à la forme négative : "Mangio" (Je mange)',
            correctAnswer: 'non mangio',
            explanation: 'On place "non" juste devant le verbe conjugué.'
          },
          {
            id: 'ex-it-neg-2',
            type: 'quiz',
            question: 'Où placer la négation ?',
            options: ['Après le verbe', 'Avant le verbe', 'À la fin de la phrase'],
            correctAnswer: 'Avant le verbe',
            explanation: 'En italien, la négation se place toujours avant le verbe.'
          }
        ]
      },
      {
        id: 'it-articles-indefinis',
        language: 'it',
        difficulty: 'beginner',
        category: 'bases',
        subCategory: 'articles-indefinis',
        rule: 'Articles indéfinis',
        content: 'Les articles indéfinis varient selon le genre et la première lettre du mot',
        translation: 'un, uno, una, un\'',
        example: 'un libro (un livre), uno studente (un étudiant), una casa (une maison), un\'amica (une amie)',
        exceptions: ['uno devant s+consonne, z, gn, ps, x, y', 'un\' devant voyelle féminine'],
        exercises: [
          {
            id: 'ex-it-artind-1',
            type: 'quiz',
            question: 'Quel article indéfini pour "amico" (ami, masculin) ?',
            options: ['un', 'uno', 'una', 'un\''],
            correctAnswer: 'un',
            explanation: 'Amico est masculin et commence par une voyelle, on utilise "un".'
          },
          {
            id: 'ex-it-artind-2',
            type: 'fill-in',
            question: 'Complétez : ___ zaino (un sac à dos)',
            correctAnswer: 'uno',
            explanation: 'Zaino commence par z, donc on utilise "uno".'
          }
        ]
      },
      {
        id: 'it-adjectifs',
        language: 'it',
        difficulty: 'beginner',
        category: 'adjectifs',
        subCategory: 'accord-adjectifs',
        rule: 'Accord des adjectifs',
        content: 'Les adjectifs s\'accordent en genre et en nombre avec le nom',
        translation: '-o/-a/-i/-e ou -e/-i',
        example: 'un ragazzo alto (un garçon grand), una ragazza alta (une fille grande)',
        exceptions: ['Les adjectifs en -e sont identiques au masculin et féminin singulier'],
        exercises: [
          {
            id: 'ex-it-adj-1',
            type: 'quiz',
            question: 'Accordez : una donna ___ (bello)',
            options: ['bello', 'bella', 'belli', 'belle'],
            correctAnswer: 'bella',
            explanation: 'Donna est féminin singulier, donc bello devient bella.'
          },
          {
            id: 'ex-it-adj-2',
            type: 'fill-in',
            question: 'Accordez : i ragazzi ___ (intelligente)',
            correctAnswer: 'intelligenti',
            explanation: 'Les adjectifs en -e font leur pluriel en -i pour les deux genres.'
          },
          {
            id: 'ex-it-adj-3',
            type: 'quiz',
            question: 'Pluriel de "casa grande" ?',
            options: ['case grande', 'case grandi', 'casi grandi', 'case grandes'],
            correctAnswer: 'case grandi',
            explanation: 'Casa → case (fém. pluriel), grande → grandi (pluriel).'
          }
        ]
      },
      {
        id: 'it-possessifs',
        language: 'it',
        difficulty: 'intermediate',
        category: 'adjectifs',
        subCategory: 'possessifs',
        rule: 'Adjectifs possessifs',
        content: 'Les possessifs s\'accordent avec l\'objet possédé et sont précédés de l\'article',
        translation: 'il mio, la mia, i miei, le mie',
        example: 'il mio libro (mon livre), la mia casa (ma maison)',
        exceptions: ['Pas d\'article devant les noms de famille au singulier : mia madre, mio padre'],
        exercises: [
          {
            id: 'ex-it-poss-1',
            type: 'quiz',
            question: 'Comment dire "mes amis" ?',
            options: ['i mio amici', 'i miei amici', 'le mie amici', 'il mio amici'],
            correctAnswer: 'i miei amici',
            explanation: 'Amici est masculin pluriel, donc i miei.'
          },
          {
            id: 'ex-it-poss-2',
            type: 'fill-in',
            question: 'Complétez : ___ sorella (ma sœur)',
            correctAnswer: 'mia',
            explanation: 'Devant un nom de famille singulier, on omet l\'article.'
          },
          {
            id: 'ex-it-poss-3',
            type: 'quiz',
            question: 'Comment dire "notre maison" ?',
            options: ['il nostro casa', 'la nostra casa', 'i nostri casa', 'le nostre casa'],
            correctAnswer: 'la nostra casa',
            explanation: 'Casa est féminin singulier, donc la nostra.'
          }
        ]
      },
      {
        id: 'it-pronoms-sujets',
        language: 'it',
        difficulty: 'beginner',
        category: 'pronoms',
        subCategory: 'pronoms-sujets',
        rule: 'Pronoms personnels sujets',
        content: 'Les pronoms sujets sont souvent omis car la conjugaison indique la personne',
        translation: 'io, tu, lui/lei, noi, voi, loro',
        example: 'Parlo italiano. (Je parle italien.) - "io" est sous-entendu',
        exercises: [
          {
            id: 'ex-it-pron-1',
            type: 'quiz',
            question: 'Quel pronom pour "nous" ?',
            options: ['io', 'tu', 'noi', 'voi'],
            correctAnswer: 'noi',
            explanation: 'Noi = nous.'
          },
          {
            id: 'ex-it-pron-2',
            type: 'quiz',
            question: 'Forme polie pour "vous" (singulier) ?',
            options: ['tu', 'voi', 'Lei', 'loro'],
            correctAnswer: 'Lei',
            explanation: 'Lei (avec majuscule) est la forme de politesse au singulier.'
          }
        ]
      },
      {
        id: 'it-present',
        language: 'it',
        difficulty: 'beginner',
        category: 'verbes',
        subCategory: 'present',
        rule: 'Présent de l\'indicatif',
        content: 'Trois groupes de verbes : -are, -ere, -ire',
        translation: 'parlare: parlo, parli, parla, parliamo, parlate, parlano',
        example: 'Io parlo, tu parli, lui parla (Je parle, tu parles, il parle)',
        exercises: [
          {
            id: 'ex-it-pres-1',
            type: 'fill-in',
            question: 'Conjuguez "parlare" à la 1ère personne du singulier :',
            correctAnswer: 'parlo',
            explanation: 'Parlare → parlo (je parle).'
          },
          {
            id: 'ex-it-pres-2',
            type: 'quiz',
            question: 'Conjuguez "mangiare" (manger) avec "noi" :',
            options: ['mangio', 'mangi', 'mangiamo', 'mangiano'],
            correctAnswer: 'mangiamo',
            explanation: 'Noi mangiamo = nous mangeons.'
          },
          {
            id: 'ex-it-pres-3',
            type: 'fill-in',
            question: 'Conjuguez "vivere" (vivre) avec "tu" :',
            correctAnswer: 'vivi',
            explanation: 'Vivere → tu vivi (tu vis).'
          }
        ]
      },
      {
        id: 'it-passato-prossimo',
        language: 'it',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'passe-compose',
        rule: 'Passé composé (Passato Prossimo)',
        content: 'Formé avec essere ou avere + participe passé',
        translation: 'avere/essere + participio passato',
        example: 'Ho mangiato (J\'ai mangé), Sono andato (Je suis allé)',
        exceptions: ['Verbes de mouvement et réflexifs utilisent essere', 'Accord du participe avec essere'],
        exercises: [
          {
            id: 'ex-it-pass-1',
            type: 'quiz',
            question: 'Quel auxiliaire pour "andare" (aller) ?',
            options: ['avere', 'essere'],
            correctAnswer: 'essere',
            explanation: 'Les verbes de mouvement utilisent essere.'
          },
          {
            id: 'ex-it-pass-2',
            type: 'fill-in',
            question: 'Complétez : Io ___ mangiato (J\'ai mangé)',
            correctAnswer: 'ho',
            explanation: 'Mangiare utilise avere → ho mangiato.'
          },
          {
            id: 'ex-it-pass-3',
            type: 'quiz',
            question: 'Maria ___ andata a Roma.',
            options: ['ha', 'è', 'sono', 'hanno'],
            correctAnswer: 'è',
            explanation: 'Andare utilise essere, et le participe s\'accorde (andata).'
          }
        ]
      },
      {
        id: 'it-imperfetto',
        language: 'it',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'imparfait',
        rule: 'Imparfait (Imperfetto)',
        content: 'Utilisé pour les actions habituelles ou en cours dans le passé',
        translation: 'parlare: parlavo, parlavi, parlava, parlavamo, parlavate, parlavano',
        example: 'Quando ero bambino, giocavo sempre. (Quand j\'étais enfant, je jouais toujours.)',
        exercises: [
          {
            id: 'ex-it-imp-1',
            type: 'fill-in',
            question: 'Conjuguez "essere" à l\'imparfait, 1ère personne :',
            correctAnswer: 'ero',
            explanation: 'Essere → ero (j\'étais).'
          },
          {
            id: 'ex-it-imp-2',
            type: 'quiz',
            question: 'Quand utilise-t-on l\'imparfait ?',
            options: ['Action ponctuelle', 'Action habituelle dans le passé', 'Action future'],
            correctAnswer: 'Action habituelle dans le passé',
            explanation: 'L\'imparfait décrit des habitudes ou des états dans le passé.'
          }
        ]
      },
      {
        id: 'it-futuro',
        language: 'it',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'futur',
        rule: 'Futur simple',
        content: 'Terminaisons ajoutées au radical du verbe',
        translation: 'parlare: parlerò, parlerai, parlerà, parleremo, parlerete, parleranno',
        example: 'Domani parlerò con lui. (Demain je parlerai avec lui.)',
        exercises: [
          {
            id: 'ex-it-fut-1',
            type: 'fill-in',
            question: 'Conjuguez "andare" au futur, 1ère personne :',
            correctAnswer: 'andrò',
            explanation: 'Andare → andrò (j\'irai). Attention au radical irrégulier.'
          },
          {
            id: 'ex-it-fut-2',
            type: 'quiz',
            question: 'Conjuguez "essere" au futur avec "noi" :',
            options: ['siamo', 'saremo', 'eravamo', 'sarò'],
            correctAnswer: 'saremo',
            explanation: 'Essere → noi saremo (nous serons).'
          }
        ]
      },
      {
        id: 'it-prepositions',
        language: 'it',
        difficulty: 'intermediate',
        category: 'prepositions',
        subCategory: 'prepositions-articulees',
        rule: 'Prépositions articulées',
        content: 'Les prépositions se contractent avec les articles définis',
        translation: 'di+il=del, a+la=alla, da+i=dai, in+le=nelle, su+lo=sullo',
        example: 'Vado al cinema. (Je vais au cinéma.) a + il = al',
        exercises: [
          {
            id: 'ex-it-prep-1',
            type: 'quiz',
            question: 'Comment dire "du livre" (di + il libro) ?',
            options: ['di il libro', 'del libro', 'dal libro', 'nel libro'],
            correctAnswer: 'del libro',
            explanation: 'di + il = del.'
          },
          {
            id: 'ex-it-prep-2',
            type: 'fill-in',
            question: 'Complétez : Vado ___ stazione (à la gare)',
            correctAnswer: 'alla',
            explanation: 'a + la = alla.'
          }
        ]
      },
      {
        id: 'it-questions',
        language: 'it',
        difficulty: 'beginner',
        category: 'syntaxe',
        subCategory: 'questions',
        rule: 'Mots interrogatifs',
        content: 'Les principaux mots pour poser des questions',
        translation: 'chi, che/cosa, dove, quando, come, perché, quanto',
        example: 'Dove vai? (Où vas-tu?), Perché piangi? (Pourquoi pleures-tu?)',
        exercises: [
          {
            id: 'ex-it-quest-1',
            type: 'quiz',
            question: 'Comment demander "Où ?" en italien ?',
            options: ['Chi', 'Dove', 'Quando', 'Come'],
            correctAnswer: 'Dove',
            explanation: 'Dove = Où.'
          },
          {
            id: 'ex-it-quest-2',
            type: 'fill-in',
            question: 'Complétez : ___ ti chiami? (Comment t\'appelles-tu?)',
            correctAnswer: 'Come',
            explanation: 'Come = Comment.'
          }
        ]
      },
      {
        id: 'it-verbes-irreguliers',
        language: 'it',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'verbes-irreguliers',
        rule: 'Verbes irréguliers courants',
        content: 'Les verbes essere, avere, fare, andare, venire sont irréguliers',
        translation: 'essere: sono, sei, è, siamo, siete, sono',
        example: 'Io sono italiano. Io ho fame. Io faccio sport.',
        exercises: [
          {
            id: 'ex-it-irreg-1',
            type: 'fill-in',
            question: 'Conjuguez "fare" (faire) avec "io" :',
            correctAnswer: 'faccio',
            explanation: 'Fare → io faccio (je fais).'
          },
          {
            id: 'ex-it-irreg-2',
            type: 'quiz',
            question: 'Conjuguez "venire" (venir) avec "loro" :',
            options: ['viene', 'veniamo', 'vengono', 'venite'],
            correctAnswer: 'vengono',
            explanation: 'Venire → loro vengono (ils viennent).'
          }
        ]
      },
      // Espagnol
      {
        id: 'es-articles-definis',
        language: 'es',
        difficulty: 'beginner',
        category: 'bases',
        subCategory: 'articles-definis',
        rule: 'Articles définis',
        content: 'Les articles définis en espagnol varient selon le genre et le nombre',
        translation: 'el, la, los, las',
        example: 'el libro (le livre), la casa (la maison), los libros (les livres)',
        exercises: [
          {
            id: 'ex-es-art-1',
            type: 'quiz',
            question: 'Quel est l\'article pour "libro" (livre, masculin singulier) ?',
            options: ['el', 'la', 'los', 'las'],
            correctAnswer: 'el',
            explanation: 'Libro est masculin singulier.'
          },
          {
            id: 'ex-es-art-2',
            type: 'fill-in',
            question: 'Complétez : ___ casa (la maison)',
            correctAnswer: 'la',
            explanation: 'Casa est féminin singulier.'
          }
        ]
      },
      {
        id: 'es-ser-estar',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'ser-estar',
        rule: 'Ser vs Estar',
        content: 'Deux verbes "être" en espagnol avec des usages différents',
        translation: 'ser (permanent) vs estar (temporaire/lieu)',
        example: 'Soy español (Je suis espagnol) vs Estoy cansado (Je suis fatigué)',
        exceptions: ['estar muerto (être mort) - permanent mais avec estar'],
        exercises: [
          {
            id: 'ex-es-ser-1',
            type: 'quiz',
            question: 'Quel verbe utiliser pour la nationalité ? (Je suis français)',
            options: ['soy', 'estoy'],
            correctAnswer: 'soy',
            explanation: 'La nationalité est une caractéristique permanente (ou d\'identité), donc on utilise SER.'
          },
          {
            id: 'ex-es-ser-2',
            type: 'quiz',
            question: 'Quel verbe utiliser pour l\'humeur ? (Je suis triste)',
            options: ['soy', 'estoy'],
            correctAnswer: 'estoy',
            explanation: 'L\'humeur est un état temporaire, donc on utilise ESTAR.'
          }
        ]
      },
      {
        id: 'es-negation',
        language: 'es',
        difficulty: 'beginner',
        category: 'syntaxe',
        subCategory: 'negation',
        rule: 'La négation',
        content: 'La négation se forme avec "no" devant le verbe',
        translation: 'no + verbe',
        example: 'No hablo español. (Je ne parle pas espagnol.)',
        exercises: [
          {
            id: 'ex-es-neg-1',
            type: 'fill-in',
            question: 'Transformez à la forme négative : "Hablo francés" (Je parle français)',
            correctAnswer: 'no hablo francés',
            explanation: 'On ajoute simplement "no" avant le verbe.'
          },
          {
            id: 'ex-es-neg-2',
            type: 'quiz',
            question: 'Où placer "no" dans la phrase ?',
            options: ['Après le verbe', 'Avant le verbe', 'À la fin'],
            correctAnswer: 'Avant le verbe',
            explanation: 'En espagnol, "no" se place toujours avant le verbe.'
          }
        ]
      },
      {
        id: 'es-articles-indefinis',
        language: 'es',
        difficulty: 'beginner',
        category: 'bases',
        subCategory: 'articles-indefinis',
        rule: 'Articles indéfinis',
        content: 'Les articles indéfinis varient selon le genre et le nombre',
        translation: 'un, una, unos, unas',
        example: 'un libro (un livre), una casa (une maison), unos libros (des livres)',
        exercises: [
          {
            id: 'ex-es-artind-1',
            type: 'quiz',
            question: 'Quel article indéfini pour "mesa" (table, féminin) ?',
            options: ['un', 'una', 'unos', 'unas'],
            correctAnswer: 'una',
            explanation: 'Mesa est féminin singulier, donc una.'
          },
          {
            id: 'ex-es-artind-2',
            type: 'fill-in',
            question: 'Complétez : ___ amigos (des amis)',
            correctAnswer: 'unos',
            explanation: 'Amigos est masculin pluriel, donc unos.'
          }
        ]
      },
      {
        id: 'es-pluriel',
        language: 'es',
        difficulty: 'beginner',
        category: 'bases',
        subCategory: 'pluriel',
        rule: 'Formation du pluriel',
        content: 'Le pluriel se forme en ajoutant -s ou -es selon la terminaison',
        translation: 'voyelle + s, consonne + es',
        example: 'libro → libros, ciudad → ciudades, lápiz → lápices',
        exceptions: ['Les mots en -z changent en -ces au pluriel'],
        exercises: [
          {
            id: 'ex-es-plu-1',
            type: 'quiz',
            question: 'Quel est le pluriel de "ciudad" (ville) ?',
            options: ['ciudads', 'ciudades', 'ciudaes', 'ciudas'],
            correctAnswer: 'ciudades',
            explanation: 'Les mots terminant par consonne ajoutent -es.'
          },
          {
            id: 'ex-es-plu-2',
            type: 'fill-in',
            question: 'Écrivez le pluriel de "lápiz" (crayon) :',
            correctAnswer: 'lápices',
            explanation: 'Les mots en -z changent en -ces au pluriel.'
          },
          {
            id: 'ex-es-plu-3',
            type: 'quiz',
            question: 'Pluriel de "mesa" (table) ?',
            options: ['mesas', 'mesaes', 'meses', 'mesa'],
            correctAnswer: 'mesas',
            explanation: 'Les mots terminant par voyelle ajoutent simplement -s.'
          }
        ]
      },
      {
        id: 'es-adjectifs',
        language: 'es',
        difficulty: 'beginner',
        category: 'adjectifs',
        subCategory: 'accord-adjectifs',
        rule: 'Accord des adjectifs',
        content: 'Les adjectifs s\'accordent en genre et en nombre avec le nom',
        translation: '-o/-a/-os/-as ou invariable',
        example: 'un chico alto (un garçon grand), una chica alta (une fille grande)',
        exceptions: ['Les adjectifs en -e ou consonne sont invariables en genre'],
        exercises: [
          {
            id: 'ex-es-adj-1',
            type: 'quiz',
            question: 'Accordez : una mujer ___ (bonito)',
            options: ['bonito', 'bonita', 'bonitos', 'bonitas'],
            correctAnswer: 'bonita',
            explanation: 'Mujer est féminin singulier, donc bonito devient bonita.'
          },
          {
            id: 'ex-es-adj-2',
            type: 'fill-in',
            question: 'Accordez : los niños ___ (inteligente)',
            correctAnswer: 'inteligentes',
            explanation: 'Les adjectifs en -e ajoutent -s au pluriel.'
          },
          {
            id: 'ex-es-adj-3',
            type: 'quiz',
            question: 'Pluriel de "casa grande" ?',
            options: ['casas grande', 'casas grandes', 'casa grandes', 'casas grandas'],
            correctAnswer: 'casas grandes',
            explanation: 'Casa → casas, grande → grandes.'
          }
        ]
      },
      {
        id: 'es-possessifs',
        language: 'es',
        difficulty: 'intermediate',
        category: 'adjectifs',
        subCategory: 'possessifs',
        rule: 'Adjectifs possessifs',
        content: 'Les possessifs courts se placent avant le nom, les longs après',
        translation: 'mi/tu/su/nuestro/vuestro/su + nom',
        example: 'mi libro (mon livre), tu casa (ta maison), nuestros amigos (nos amis)',
        exceptions: ['Nuestro et vuestro s\'accordent en genre et nombre'],
        exercises: [
          {
            id: 'ex-es-poss-1',
            type: 'quiz',
            question: 'Comment dire "nos maisons" ?',
            options: ['nuestro casas', 'nuestras casas', 'nuestra casas', 'nuestros casas'],
            correctAnswer: 'nuestras casas',
            explanation: 'Casas est féminin pluriel, donc nuestras.'
          },
          {
            id: 'ex-es-poss-2',
            type: 'fill-in',
            question: 'Complétez : ___ hermano (mon frère)',
            correctAnswer: 'mi',
            explanation: 'Mi est invariable en genre.'
          },
          {
            id: 'ex-es-poss-3',
            type: 'quiz',
            question: 'Comment dire "vos livres" (vouvoiement) ?',
            options: ['tu libros', 'sus libros', 'vuestros libros', 'su libros'],
            correctAnswer: 'sus libros',
            explanation: 'Su/sus est utilisé pour le vouvoiement.'
          }
        ]
      },
      {
        id: 'es-pronoms-sujets',
        language: 'es',
        difficulty: 'beginner',
        category: 'pronoms',
        subCategory: 'pronoms-sujets',
        rule: 'Pronoms personnels sujets',
        content: 'Les pronoms sujets sont souvent omis car la conjugaison indique la personne',
        translation: 'yo, tú, él/ella/usted, nosotros, vosotros, ellos/ustedes',
        example: 'Hablo español. (Je parle espagnol.) - "yo" est sous-entendu',
        exercises: [
          {
            id: 'ex-es-pron-1',
            type: 'quiz',
            question: 'Quel pronom pour "nous" ?',
            options: ['yo', 'tú', 'nosotros', 'vosotros'],
            correctAnswer: 'nosotros',
            explanation: 'Nosotros = nous.'
          },
          {
            id: 'ex-es-pron-2',
            type: 'quiz',
            question: 'Forme polie pour "vous" (singulier) ?',
            options: ['tú', 'vosotros', 'usted', 'ustedes'],
            correctAnswer: 'usted',
            explanation: 'Usted est la forme de politesse au singulier.'
          }
        ]
      },
      {
        id: 'es-present',
        language: 'es',
        difficulty: 'beginner',
        category: 'verbes',
        subCategory: 'present',
        rule: 'Présent de l\'indicatif',
        content: 'Trois groupes de verbes : -ar, -er, -ir',
        translation: 'hablar: hablo, hablas, habla, hablamos, habláis, hablan',
        example: 'Yo hablo, tú hablas, él habla (Je parle, tu parles, il parle)',
        exercises: [
          {
            id: 'ex-es-pres-1',
            type: 'fill-in',
            question: 'Conjuguez "hablar" à la 1ère personne du singulier :',
            correctAnswer: 'hablo',
            explanation: 'Hablar → hablo (je parle).'
          },
          {
            id: 'ex-es-pres-2',
            type: 'quiz',
            question: 'Conjuguez "comer" (manger) avec "nosotros" :',
            options: ['como', 'comes', 'comemos', 'comen'],
            correctAnswer: 'comemos',
            explanation: 'Nosotros comemos = nous mangeons.'
          },
          {
            id: 'ex-es-pres-3',
            type: 'fill-in',
            question: 'Conjuguez "vivir" (vivre) avec "tú" :',
            correctAnswer: 'vives',
            explanation: 'Vivir → tú vives (tu vis).'
          }
        ]
      },
      {
        id: 'es-preterito-perfecto',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'passe-compose',
        rule: 'Passé composé (Pretérito Perfecto)',
        content: 'Formé avec haber + participe passé',
        translation: 'haber + participio: he, has, ha, hemos, habéis, han',
        example: 'He comido (J\'ai mangé), Has llegado (Tu es arrivé)',
        exercises: [
          {
            id: 'ex-es-perf-1',
            type: 'fill-in',
            question: 'Complétez : Yo ___ comido (J\'ai mangé)',
            correctAnswer: 'he',
            explanation: 'Haber → yo he.'
          },
          {
            id: 'ex-es-perf-2',
            type: 'quiz',
            question: 'Participe passé de "escribir" (écrire) ?',
            options: ['escribido', 'escrito', 'escribado', 'escribiendo'],
            correctAnswer: 'escrito',
            explanation: 'Escribir → escrito (irrégulier).'
          },
          {
            id: 'ex-es-perf-3',
            type: 'quiz',
            question: 'Ella ___ llegado tarde.',
            options: ['he', 'has', 'ha', 'han'],
            correctAnswer: 'ha',
            explanation: 'Ella → ha (3ème personne singulier).'
          }
        ]
      },
      {
        id: 'es-preterito-indefinido',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'passe-compose',
        rule: 'Passé simple (Pretérito Indefinido)',
        content: 'Utilisé pour les actions ponctuelles terminées dans le passé',
        translation: 'hablar: hablé, hablaste, habló, hablamos, hablasteis, hablaron',
        example: 'Ayer comí pizza. (Hier j\'ai mangé une pizza.)',
        exercises: [
          {
            id: 'ex-es-indef-1',
            type: 'fill-in',
            question: 'Conjuguez "hablar" au passé simple, 1ère personne :',
            correctAnswer: 'hablé',
            explanation: 'Hablar → hablé (je parlai).'
          },
          {
            id: 'ex-es-indef-2',
            type: 'quiz',
            question: 'Conjuguez "ir" (aller) au passé simple avec "él" :',
            options: ['iba', 'fue', 'va', 'irá'],
            correctAnswer: 'fue',
            explanation: 'Ir → él fue (il alla). Verbe irrégulier.'
          }
        ]
      },
      {
        id: 'es-imperfecto',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'imparfait',
        rule: 'Imparfait (Pretérito Imperfecto)',
        content: 'Utilisé pour les actions habituelles ou en cours dans le passé',
        translation: 'hablar: hablaba, hablabas, hablaba, hablábamos, hablabais, hablaban',
        example: 'Cuando era niño, jugaba mucho. (Quand j\'étais enfant, je jouais beaucoup.)',
        exercises: [
          {
            id: 'ex-es-imp-1',
            type: 'fill-in',
            question: 'Conjuguez "ser" à l\'imparfait, 1ère personne :',
            correctAnswer: 'era',
            explanation: 'Ser → era (j\'étais). Verbe irrégulier.'
          },
          {
            id: 'ex-es-imp-2',
            type: 'quiz',
            question: 'Quand utilise-t-on l\'imparfait ?',
            options: ['Action ponctuelle', 'Action habituelle dans le passé', 'Action future'],
            correctAnswer: 'Action habituelle dans le passé',
            explanation: 'L\'imparfait décrit des habitudes ou des états dans le passé.'
          }
        ]
      },
      {
        id: 'es-futuro',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'futur',
        rule: 'Futur simple',
        content: 'Terminaisons ajoutées à l\'infinitif',
        translation: 'hablar: hablaré, hablarás, hablará, hablaremos, hablaréis, hablarán',
        example: 'Mañana hablaré con él. (Demain je parlerai avec lui.)',
        exercises: [
          {
            id: 'ex-es-fut-1',
            type: 'fill-in',
            question: 'Conjuguez "ir" au futur, 1ère personne :',
            correctAnswer: 'iré',
            explanation: 'Ir → iré (j\'irai).'
          },
          {
            id: 'ex-es-fut-2',
            type: 'quiz',
            question: 'Conjuguez "tener" au futur avec "nosotros" :',
            options: ['tenemos', 'tendremos', 'teníamos', 'tendré'],
            correctAnswer: 'tendremos',
            explanation: 'Tener → tendremos (nous aurons). Radical irrégulier.'
          }
        ]
      },
      {
        id: 'es-por-para',
        language: 'es',
        difficulty: 'intermediate',
        category: 'prepositions',
        subCategory: 'por-para',
        rule: 'Por vs Para',
        content: 'Deux prépositions avec des usages différents',
        translation: 'por (cause, moyen, durée) vs para (but, destination, délai)',
        example: 'Trabajo por dinero (Je travaille pour l\'argent) vs Trabajo para vivir (Je travaille pour vivre)',
        exceptions: ['Certaines expressions figées : por favor, para siempre'],
        exercises: [
          {
            id: 'ex-es-porpara-1',
            type: 'quiz',
            question: 'Complétez : Este regalo es ___ ti (Ce cadeau est pour toi)',
            options: ['por', 'para'],
            correctAnswer: 'para',
            explanation: 'Para indique le destinataire.'
          },
          {
            id: 'ex-es-porpara-2',
            type: 'quiz',
            question: 'Complétez : Gracias ___ tu ayuda (Merci pour ton aide)',
            options: ['por', 'para'],
            correctAnswer: 'por',
            explanation: 'Por indique la cause ou la raison.'
          },
          {
            id: 'ex-es-porpara-3',
            type: 'quiz',
            question: 'Complétez : Salgo ___ Madrid mañana (Je pars pour Madrid demain)',
            options: ['por', 'para'],
            correctAnswer: 'para',
            explanation: 'Para indique la destination.'
          }
        ]
      },
      {
        id: 'es-questions',
        language: 'es',
        difficulty: 'beginner',
        category: 'syntaxe',
        subCategory: 'questions',
        rule: 'Mots interrogatifs',
        content: 'Les principaux mots pour poser des questions (avec accent)',
        translation: 'quién, qué, dónde, cuándo, cómo, por qué, cuánto',
        example: '¿Dónde vives? (Où habites-tu?), ¿Por qué lloras? (Pourquoi pleures-tu?)',
        exercises: [
          {
            id: 'ex-es-quest-1',
            type: 'quiz',
            question: 'Comment demander "Où ?" en espagnol ?',
            options: ['Quién', 'Dónde', 'Cuándo', 'Cómo'],
            correctAnswer: 'Dónde',
            explanation: 'Dónde = Où.'
          },
          {
            id: 'ex-es-quest-2',
            type: 'fill-in',
            question: 'Complétez : ¿___ te llamas? (Comment t\'appelles-tu?)',
            correctAnswer: 'Cómo',
            explanation: 'Cómo = Comment.'
          }
        ]
      },
      {
        id: 'es-verbes-irreguliers',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'verbes-irreguliers',
        rule: 'Verbes irréguliers courants',
        content: 'Les verbes ser, estar, ir, tener, hacer sont irréguliers',
        translation: 'ser: soy, eres, es, somos, sois, son',
        example: 'Yo soy español. Yo tengo hambre. Yo hago deporte.',
        exercises: [
          {
            id: 'ex-es-irreg-1',
            type: 'fill-in',
            question: 'Conjuguez "hacer" (faire) avec "yo" :',
            correctAnswer: 'hago',
            explanation: 'Hacer → yo hago (je fais).'
          },
          {
            id: 'ex-es-irreg-2',
            type: 'quiz',
            question: 'Conjuguez "ir" (aller) avec "ellos" :',
            options: ['va', 'vamos', 'van', 'vais'],
            correctAnswer: 'van',
            explanation: 'Ir → ellos van (ils vont).'
          },
          {
            id: 'ex-es-irreg-3',
            type: 'fill-in',
            question: 'Conjuguez "tener" (avoir) avec "tú" :',
            correctAnswer: 'tienes',
            explanation: 'Tener → tú tienes (tu as).'
          }
        ]
      },
      {
        id: 'es-reflexifs',
        language: 'es',
        difficulty: 'intermediate',
        category: 'pronoms',
        subCategory: 'pronoms-reflexifs',
        rule: 'Verbes réfléchis',
        content: 'Les verbes réfléchis utilisent les pronoms me, te, se, nos, os, se',
        translation: 'llamarse: me llamo, te llamas, se llama...',
        example: 'Me llamo Juan. (Je m\'appelle Juan.) Me levanto a las 7. (Je me lève à 7h.)',
        exercises: [
          {
            id: 'ex-es-refl-1',
            type: 'fill-in',
            question: 'Complétez : Yo ___ llamo María (Je m\'appelle María)',
            correctAnswer: 'me',
            explanation: 'Le pronom réfléchi pour "yo" est "me".'
          },
          {
            id: 'ex-es-refl-2',
            type: 'quiz',
            question: 'Quel pronom réfléchi pour "nosotros" ?',
            options: ['me', 'te', 'se', 'nos'],
            correctAnswer: 'nos',
            explanation: 'Nosotros → nos.'
          }
        ]
      },
      {
        id: 'es-gustar',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'verbes-irreguliers',
        rule: 'Le verbe Gustar',
        content: 'Gustar fonctionne à l\'envers : ce qui plaît est le sujet',
        translation: 'me gusta (ça me plaît), me gustan (ils me plaisent)',
        example: 'Me gusta el café. (J\'aime le café.) Me gustan los libros. (J\'aime les livres.)',
        exercises: [
          {
            id: 'ex-es-gust-1',
            type: 'quiz',
            question: 'Complétez : Me ___ las películas (J\'aime les films)',
            options: ['gusta', 'gustan', 'gusto', 'gustas'],
            correctAnswer: 'gustan',
            explanation: 'Películas est pluriel, donc gustan.'
          },
          {
            id: 'ex-es-gust-2',
            type: 'fill-in',
            question: 'Complétez : A él le ___ bailar (Il aime danser)',
            correctAnswer: 'gusta',
            explanation: 'Avec un infinitif, on utilise gusta (singulier).'
          }
        ]
      },
      // ========== RÈGLES SUPPLÉMENTAIRES ITALIEN ==========
      {
        id: 'it-demonstratifs',
        language: 'it',
        difficulty: 'beginner',
        category: 'adjectifs',
        subCategory: 'demonstratifs',
        rule: 'Adjectifs démonstratifs',
        content: 'Questo (ce, proche) et quello (ce, éloigné) s\'accordent avec le nom',
        translation: 'questo/questa/questi/queste - quello/quella/quelli/quelle',
        example: 'Questo libro è interessante. Quella casa è grande.',
        exercises: [
          {
            id: 'ex-it-demo-1',
            type: 'quiz',
            question: 'Comment dire "cette maison" (proche) ?',
            options: ['questo casa', 'questa casa', 'quello casa', 'quella casa'],
            correctAnswer: 'questa casa',
            explanation: 'Casa est féminin, donc questa (proche).'
          },
          {
            id: 'ex-it-demo-2',
            type: 'fill-in',
            question: 'Complétez : ___ ragazzi sono simpatici (ces garçons, éloignés)',
            correctAnswer: 'quei',
            explanation: 'Quei est la forme de quello devant consonne au masculin pluriel.'
          }
        ]
      },
      {
        id: 'it-comparatifs',
        language: 'it',
        difficulty: 'intermediate',
        category: 'adjectifs',
        subCategory: 'comparatifs',
        rule: 'Comparatifs et superlatifs',
        content: 'più...di (plus que), meno...di (moins que), il più (le plus)',
        translation: 'più grande di = plus grand que',
        example: 'Roma è più grande di Firenze. È il libro più interessante.',
        exercises: [
          {
            id: 'ex-it-comp-1',
            type: 'fill-in',
            question: 'Complétez : Maria è ___ alta di Luca (plus)',
            correctAnswer: 'più',
            explanation: 'Più = plus dans les comparaisons.'
          },
          {
            id: 'ex-it-comp-2',
            type: 'quiz',
            question: 'Comment dire "le plus beau" ?',
            options: ['più bello', 'il più bello', 'molto bello', 'bellissimo'],
            correctAnswer: 'il più bello',
            explanation: 'Le superlatif relatif se forme avec l\'article + più + adjectif.'
          }
        ]
      },
      {
        id: 'it-imperatif',
        language: 'it',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'imperatif',
        rule: 'Impératif',
        content: 'L\'impératif sert à donner des ordres ou des conseils',
        translation: 'parla! (parle!), parlate! (parlez!), parli! (parlez! poli)',
        example: 'Ascolta! (Écoute!) Mangia la pasta! (Mange les pâtes!)',
        exercises: [
          {
            id: 'ex-it-imp-1',
            type: 'quiz',
            question: 'Comment dire "Parle!" (tu) ?',
            options: ['Parla!', 'Parli!', 'Parlate!', 'Parlare!'],
            correctAnswer: 'Parla!',
            explanation: 'L\'impératif 2ème personne singulier des verbes en -are se termine en -a.'
          },
          {
            id: 'ex-it-imp-2',
            type: 'fill-in',
            question: 'Forme négative : Non ___ ! (ne parle pas)',
            correctAnswer: 'parlare',
            explanation: 'L\'impératif négatif 2ème personne utilise l\'infinitif : Non parlare!'
          }
        ]
      },
      {
        id: 'it-conditionnel',
        language: 'it',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'conditionnel',
        rule: 'Conditionnel présent',
        content: 'Exprime un souhait, une possibilité ou une demande polie',
        translation: 'parlare: parlerei, parleresti, parlerebbe...',
        example: 'Vorrei un caffè. (Je voudrais un café.) Potresti aiutarmi? (Pourrais-tu m\'aider?)',
        exercises: [
          {
            id: 'ex-it-cond-1',
            type: 'fill-in',
            question: 'Complétez : ___ un gelato, per favore (je voudrais)',
            correctAnswer: 'Vorrei',
            explanation: 'Vorrei est le conditionnel de volere (vouloir).'
          },
          {
            id: 'ex-it-cond-2',
            type: 'quiz',
            question: 'Conjuguez "essere" au conditionnel avec "io" :',
            options: ['sono', 'sarò', 'sarei', 'ero'],
            correctAnswer: 'sarei',
            explanation: 'Essere → io sarei (je serais).'
          }
        ]
      },
      // ========== RÈGLES SUPPLÉMENTAIRES ESPAGNOL ==========
      {
        id: 'es-demonstratifs',
        language: 'es',
        difficulty: 'beginner',
        category: 'adjectifs',
        subCategory: 'demonstratifs',
        rule: 'Adjectifs démonstratifs',
        content: 'Este (proche), ese (moyen), aquel (éloigné) s\'accordent avec le nom',
        translation: 'este/esta/estos/estas - ese/esa - aquel/aquella',
        example: 'Este libro es mío. Esa casa es grande. Aquel coche es rojo.',
        exercises: [
          {
            id: 'ex-es-demo-1',
            type: 'quiz',
            question: 'Comment dire "cette maison" (proche) ?',
            options: ['este casa', 'esta casa', 'ese casa', 'esa casa'],
            correctAnswer: 'esta casa',
            explanation: 'Casa est féminin, donc esta (proche).'
          },
          {
            id: 'ex-es-demo-2',
            type: 'fill-in',
            question: 'Complétez : ___ chicos son simpáticos (ces garçons, éloignés)',
            correctAnswer: 'aquellos',
            explanation: 'Aquellos = ces (masculin pluriel, éloigné).'
          }
        ]
      },
      {
        id: 'es-comparatifs',
        language: 'es',
        difficulty: 'intermediate',
        category: 'adjectifs',
        subCategory: 'comparatifs',
        rule: 'Comparatifs et superlatifs',
        content: 'más...que (plus que), menos...que (moins que), el más (le plus)',
        translation: 'más grande que = plus grand que',
        example: 'Madrid es más grande que Barcelona. Es el libro más interesante.',
        exceptions: ['Irréguliers : bueno→mejor, malo→peor, grande→mayor, pequeño→menor'],
        exercises: [
          {
            id: 'ex-es-comp-1',
            type: 'fill-in',
            question: 'Complétez : María es ___ alta que Luca (plus)',
            correctAnswer: 'más',
            explanation: 'Más = plus dans les comparaisons.'
          },
          {
            id: 'ex-es-comp-2',
            type: 'quiz',
            question: 'Comment dire "meilleur" (comparatif de bueno) ?',
            options: ['más bueno', 'mejor', 'el mejor', 'buenísimo'],
            correctAnswer: 'mejor',
            explanation: 'Mejor est le comparatif irrégulier de bueno.'
          }
        ]
      },
      {
        id: 'es-imperatif',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'imperatif',
        rule: 'Impératif',
        content: 'L\'impératif affirmatif et négatif ont des formes différentes',
        translation: 'habla! (parle!), hablad! (parlez!), hable! (parlez! poli)',
        example: '¡Escucha! (Écoute!) ¡Come la paella! (Mange la paella!)',
        exceptions: ['Négatif : No hables (ne parle pas) - utilise le subjonctif'],
        exercises: [
          {
            id: 'ex-es-imp-1',
            type: 'quiz',
            question: 'Comment dire "Parle!" (tú) ?',
            options: ['¡Habla!', '¡Hable!', '¡Hablad!', '¡Hablar!'],
            correctAnswer: '¡Habla!',
            explanation: 'L\'impératif 2ème personne singulier des verbes en -ar se termine en -a.'
          },
          {
            id: 'ex-es-imp-2',
            type: 'fill-in',
            question: 'Forme négative : ¡No ___ ! (ne parle pas)',
            correctAnswer: 'hables',
            explanation: 'L\'impératif négatif utilise le subjonctif : ¡No hables!'
          }
        ]
      },
      {
        id: 'es-conditionnel',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'conditionnel',
        rule: 'Conditionnel simple',
        content: 'Exprime un souhait, une possibilité ou une demande polie',
        translation: 'hablar: hablaría, hablarías, hablaría...',
        example: 'Querría un café. (Je voudrais un café.) ¿Podrías ayudarme? (Pourrais-tu m\'aider?)',
        exercises: [
          {
            id: 'ex-es-cond-1',
            type: 'fill-in',
            question: 'Complétez : ___ un helado, por favor (je voudrais)',
            correctAnswer: 'Querría',
            explanation: 'Querría est le conditionnel de querer (vouloir).'
          },
          {
            id: 'ex-es-cond-2',
            type: 'quiz',
            question: 'Conjuguez "ser" au conditionnel avec "yo" :',
            options: ['soy', 'seré', 'sería', 'era'],
            correctAnswer: 'sería',
            explanation: 'Ser → yo sería (je serais).'
          }
        ]
      },
      {
        id: 'es-estar-gerondif',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'present',
        rule: 'Estar + gérondif (présent progressif)',
        content: 'Exprime une action en cours : estar + verbe en -ando/-iendo',
        translation: 'estoy hablando = je suis en train de parler',
        example: 'Estoy comiendo. (Je suis en train de manger.) ¿Qué estás haciendo?',
        exercises: [
          {
            id: 'ex-es-ger-1',
            type: 'fill-in',
            question: 'Complétez : Estoy ___ (manger)',
            correctAnswer: 'comiendo',
            explanation: 'Comer → comiendo (gérondif des verbes en -er).'
          },
          {
            id: 'ex-es-ger-2',
            type: 'quiz',
            question: 'Quel est le gérondif de "hablar" ?',
            options: ['hablado', 'hablando', 'habliendo', 'hablar'],
            correctAnswer: 'hablando',
            explanation: 'Les verbes en -ar forment le gérondif en -ando.'
          }
        ]
      },
      {
        id: 'it-stare-gerondio',
        language: 'it',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'present',
        rule: 'Stare + gérondif (présent progressif)',
        content: 'Exprime une action en cours : stare + verbe en -ando/-endo',
        translation: 'sto parlando = je suis en train de parler',
        example: 'Sto mangiando. (Je suis en train de manger.) Cosa stai facendo?',
        exercises: [
          {
            id: 'ex-it-ger-1',
            type: 'fill-in',
            question: 'Complétez : Sto ___ (manger)',
            correctAnswer: 'mangiando',
            explanation: 'Mangiare → mangiando (gérondif des verbes en -are).'
          },
          {
            id: 'ex-it-ger-2',
            type: 'quiz',
            question: 'Quel est le gérondif de "leggere" (lire) ?',
            options: ['letto', 'leggendo', 'leggando', 'leggere'],
            correctAnswer: 'leggendo',
            explanation: 'Les verbes en -ere forment le gérondif en -endo.'
          }
        ]
      },
      // ========== ORTHOGRAPHE ITALIEN ==========
      {
        id: 'it-orthographe-accents',
        language: 'it',
        difficulty: 'beginner',
        category: 'orthographe',
        subCategory: 'orthographe',
        rule: 'Accents graphiques en italien',
        content: 'Les accents indiquent souvent l’accent tonique sur la dernière syllabe : à, ì, ò…',
        translation: 'città, perché, così, lunedì',
        example: 'Abito in città. (J’habite en ville.) Perché sei triste? (Pourquoi es-tu triste ?)',
        exercises: [
          {
            id: 'ex-it-ortho-acc-1',
            type: 'quiz',
            question: 'Où faut-il mettre l’accent ? citta / città',
            options: ['citta', 'città'],
            correctAnswer: 'città',
            explanation: 'Les mots comme città (ville) prennent un accent grave sur la dernière syllabe.'
          },
          {
            id: 'ex-it-ortho-acc-2',
            type: 'fill-in',
            question: 'Complétez avec l’accent : perche (pourquoi)',
            correctAnswer: 'perché',
            explanation: 'Perché s’écrit avec un accent aigu sur le é final.'
          }
        ]
      },
      {
        id: 'it-orthographe-doubles',
        language: 'it',
        difficulty: 'beginner',
        category: 'orthographe',
        subCategory: 'orthographe',
        rule: 'Lettres doubles et sens différent',
        content: 'En italien, les consonnes doubles changent souvent le sens : ano / anno, pala / palla…',
        translation: 'pala (pelle) vs palla (ballon), ano (anus) vs anno (année)',
        example: 'Quest’anno studio italiano. (Cette année, j’étudie l’italien.)',
        exercises: [
          {
            id: 'ex-it-ortho-dbl-1',
            type: 'quiz',
            question: 'Laquelle est correcte pour "année" ? ano / anno',
            options: ['ano', 'anno'],
            correctAnswer: 'anno',
            explanation: 'Année se dit anno avec deux n.'
          },
          {
            id: 'ex-it-ortho-dbl-2',
            type: 'fill-in',
            question: 'Complétez : Ho comprato una pa__a nuova (un ballon)',
            correctAnswer: 'palla',
            explanation: 'Palla (ballon) s’écrit avec deux l.'
          }
        ]
      },
      // ========== ORTHOGRAPHE ESPAGNOL ==========
      {
        id: 'es-orthographe-accents',
        language: 'es',
        difficulty: 'beginner',
        category: 'orthographe',
        subCategory: 'orthographe',
        rule: 'Accents qui changent le sens',
        content: 'Beaucoup de petits mots se distinguent par un accent : tú / tu, él / el, sí / si, más / mas…',
        translation: 'tú (toi) vs tu (ton), él (il) vs el (le)',
        example: 'Él es mi amigo. (C’est mon ami.) ¿Tú vienes? (Toi, tu viens ?)',
        exercises: [
          {
            id: 'ex-es-ortho-acc-1',
            type: 'quiz',
            question: 'Choisissez la bonne forme : ___ hermano es médico (Mon frère est médecin)',
            options: ['tú', 'tu'],
            correctAnswer: 'tu',
            explanation: 'Tu (sans accent) est l’adjectif possessif « ton / ta / tes ».'
          },
          {
            id: 'ex-es-ortho-acc-2',
            type: 'fill-in',
            question: 'Complétez : ___ es español (Lui est espagnol)',
            correctAnswer: 'Él',
            explanation: 'Él (avec accent) signifie « il », el (sans accent) signifie « le ».'
          }
        ]
      },
      {
        id: 'es-orthographe-bv',
        language: 'es',
        difficulty: 'intermediate',
        category: 'orthographe',
        subCategory: 'orthographe',
        rule: 'Confusions fréquentes b / v',
        content: 'En espagnol, b et v se prononcent presque pareil, mais l’orthographe suit des schémas : après m → b, après n → v, et certains mots sont à mémoriser.',
        translation: 'también, cambiar (toujours b après m) ; enviar, invierno (souvent v après n)',
        example: 'También quiero venir. (Je veux aussi venir.) Envié una carta. (J’ai envoyé une lettre.)',
        exercises: [
          {
            id: 'ex-es-ortho-bv-1',
            type: 'quiz',
            question: 'Quelle orthographe est correcte pour "aussi" ?',
            options: ['tambien', 'también', 'tavbien'],
            correctAnswer: 'también',
            explanation: 'On écrit también avec b et un accent sur é.'
          },
          {
            id: 'ex-es-ortho-bv-2',
            type: 'fill-in',
            question: 'Complétez : en__iar (envoyer)',
            correctAnswer: 'enviar',
            explanation: 'Le verbe est enviar, avec v après n.'
          }
        ]
      },
      // ========== THEMES SUPPLÉMENTAIRES ITALIEN (2ᵉ série) ==========
      {
        id: 'it-genre-noms',
        language: 'it',
        difficulty: 'beginner',
        category: 'bases',
        subCategory: 'genre',
        rule: 'Genre des noms',
        content: 'Beaucoup de noms masculins finissent en -o, féminins en -a, avec des exceptions en -e.',
        translation: 'ragazzo (m), ragazza (f), cane (m), notte (f)',
        example: 'Il ragazzo è alto. La ragazza è alta.',
        exercises: [
          {
            id: 'ex-it-genre-1',
            type: 'quiz',
            question: 'Quel est le genre le plus probable de "libro" ?',
            options: ['masculin', 'féminin'],
            correctAnswer: 'masculin',
            explanation: 'Les noms en -o sont en général masculins.'
          },
          {
            id: 'ex-it-genre-2',
            type: 'fill-in',
            question: 'Complétez avec l’article défini : ___ notte (la nuit)',
            correctAnswer: 'la',
            explanation: 'Notte est féminin → la notte.'
          }
        ]
      },
      {
        id: 'it-pronoms-reflexifs-plus',
        language: 'it',
        difficulty: 'intermediate',
        category: 'pronoms',
        subCategory: 'pronoms-reflexifs',
        rule: 'Verbes réfléchis fréquents',
        content: 'Molti verbi comuni sono riflessivi : alzarsi, vestirsi, divertirsi, riposarsi...',
        translation: 'mi alzo, ti vesti, si diverte, ci riposiamo',
        example: 'La mattina mi alzo presto. (Le matin je me lève tôt.)',
        exercises: [
          {
            id: 'ex-it-reflplus-1',
            type: 'fill-in',
            question: 'Complétez : Noi ___ riposiamo (Nous nous reposons).',
            correctAnswer: 'ci',
            explanation: 'Noi → ci riposiamo.'
          },
          {
            id: 'ex-it-reflplus-2',
            type: 'quiz',
            question: 'Quel verbe est réfléchi ?',
            options: ['mangiare', 'parlare', 'vestirsi', 'andare'],
            correctAnswer: 'vestirsi',
            explanation: 'Vestirsi (s’habiller) est un verbe réfléchi.'
          }
        ]
      },
      {
        id: 'it-questions-plus',
        language: 'it',
        difficulty: 'intermediate',
        category: 'syntaxe',
        subCategory: 'questions',
        rule: 'Questions : mots interrogatifs composés',
        content: 'Come mai, da quanto tempo, da dove, per quanto... permettent de préciser la question.',
        translation: 'Da quanto tempo studi italiano? Come mai sei qui?',
        example: 'Da quanto tempo vivi a Roma? (Depuis combien de temps vis-tu à Rome ?)',
        exercises: [
          {
            id: 'ex-it-questplus-1',
            type: 'quiz',
            question: 'Quel mot interrogatif pour "Depuis combien de temps" ?',
            options: ['Come mai', 'Da quanto tempo', 'Perché', 'Quando'],
            correctAnswer: 'Da quanto tempo',
            explanation: '"Da quanto tempo" sert à parler de durée depuis un point de départ.'
          },
          {
            id: 'ex-it-questplus-2',
            type: 'fill-in',
            question: 'Complétez : ___ sei triste? (Pourquoi es-tu triste ?)',
            correctAnswer: 'Perché',
            explanation: 'Perché = pourquoi.'
          }
        ]
      },
      {
        id: 'it-verbes-frequents',
        language: 'it',
        difficulty: 'beginner',
        category: 'verbes',
        subCategory: 'verbes-irreguliers',
        rule: 'Verbes très fréquents en contexte',
        content: 'Être, avoir, faire, aller utilisés dans des expressions typiques.',
        translation: 'essere, avere, fare, andare',
        example: 'Ho fame, ho sonno, vado a casa, faccio la spesa.',
        exercises: [
          {
            id: 'ex-it-freq-1',
            type: 'quiz',
            question: 'Complétez : Ho ___ (faim).',
            options: ['freddo', 'fame', 'sete', 'sonno'],
            correctAnswer: 'fame',
            explanation: 'On dit "ho fame" pour j’ai faim.'
          },
          {
            id: 'ex-it-freq-2',
            type: 'fill-in',
            question: 'Complétez : Vado __ casa (Je vais à la maison).',
            correctAnswer: 'a',
            explanation: 'On dit andare a casa.'
          }
        ]
      },
      {
        id: 'it-expressions-temps-plus',
        language: 'it',
        difficulty: 'intermediate',
        category: 'syntaxe',
        subCategory: 'ordre-mots',
        rule: 'Expressions temporelles composées',
        content: 'Da un anno, da due giorni, tra poco, fra un’ora... permettent de situer dans le temps.',
        translation: 'Da due anni studio italiano. Fra un’ora partiamo.',
        example: 'Studio italiano da un anno. (J’étudie l’italien depuis un an.)',
        exercises: [
          {
            id: 'ex-it-exptpsplus-1',
            type: 'quiz',
            question: 'Quelle expression signifie "dans peu de temps" ?',
            options: ['da un anno', 'tra poco', 'da due giorni', 'ieri'],
            correctAnswer: 'tra poco',
            explanation: 'Tra poco = dans peu de temps.'
          },
          {
            id: 'ex-it-exptpsplus-2',
            type: 'fill-in',
            question: 'Complétez : Studio italiano __ due anni (depuis deux ans).',
            correctAnswer: 'da',
            explanation: 'On utilise da pour exprimer la durée depuis.'
          }
        ]
      },
      // ========== THEMES SUPPLÉMENTAIRES ESPAGNOL (2ᵉ série) ==========
      {
        id: 'es-genre-noms-plus',
        language: 'es',
        difficulty: 'beginner',
        category: 'bases',
        subCategory: 'genre',
        rule: 'Genre des noms – cas particuliers',
        content: 'Certains noms ne suivent pas le schéma -o/-a : la mano (f), el día (m), el problema (m).',
        translation: 'el día, el problema, la mano',
        example: 'El día es largo. La mano está fría.',
        exercises: [
          {
            id: 'ex-es-genreplus-1',
            type: 'quiz',
            question: 'Quel article pour "problema" ?',
            options: ['la', 'el'],
            correctAnswer: 'el',
            explanation: 'Problema est masculin malgré la terminaison -a.'
          },
          {
            id: 'ex-es-genreplus-2',
            type: 'fill-in',
            question: 'Complétez : ___ día (le jour).',
            correctAnswer: 'el',
            explanation: 'Día est masculin : el día.'
          }
        ]
      },
      {
        id: 'es-questions-plus',
        language: 'es',
        difficulty: 'intermediate',
        category: 'syntaxe',
        subCategory: 'questions',
        rule: 'Questions avec prépositions',
        content: 'La préposition peut se placer devant le mot interrogatif : ¿Con quién...? ¿De qué...?',
        translation: '¿Con quién hablas? ¿De qué hablas?',
        example: '¿Con quién vives? (Avec qui vis-tu ?)',
        exercises: [
          {
            id: 'ex-es-questplus-1',
            type: 'quiz',
            question: 'Quelle question est correcte ?',
            options: ['¿Quién con hablas?', '¿Con quién hablas?', '¿Quién hablas con?'],
            correctAnswer: '¿Con quién hablas?',
            explanation: 'La préposition se met devant quién : con quién.'
          },
          {
            id: 'ex-es-questplus-2',
            type: 'fill-in',
            question: 'Complétez : ¿___ qué hablas? (De quoi parles-tu ?)',
            correctAnswer: 'De',
            explanation: 'On dit de qué pour "de quoi".'
          }
        ]
      },
      {
        id: 'es-verbes-frequents',
        language: 'es',
        difficulty: 'beginner',
        category: 'verbes',
        subCategory: 'verbes-irreguliers',
        rule: 'Verbes très fréquents en contexte',
        content: 'Ser, estar, tener, ir, hacer dans des expressions de base.',
        translation: 'tener hambre, tener frío, estar cansado, ir a casa',
        example: 'Tengo hambre. Estoy cansado. Voy a casa.',
        exercises: [
          {
            id: 'ex-es-freq-1',
            type: 'quiz',
            question: 'Complétez : ___ hambre (J’ai faim).',
            options: ['Soy', 'Tengo', 'Estoy', 'Voy'],
            correctAnswer: 'Tengo',
            explanation: 'On dit tengo hambre.'
          },
          {
            id: 'ex-es-freq-2',
            type: 'fill-in',
            question: 'Complétez : Estoy ___ (fatigué).',
            correctAnswer: 'cansado',
            explanation: 'Être fatigué → estar cansado.'
          }
        ]
      },
      {
        id: 'es-expressions-temps-plus',
        language: 'es',
        difficulty: 'intermediate',
        category: 'syntaxe',
        subCategory: 'ordre-mots',
        rule: 'Expressions temporelles composées',
        content: 'Desde hace, dentro de, hace... que, todos los días…',
        translation: 'Vivo aquí desde hace dos años. Dentro de una hora salimos.',
        example: 'Hace tres años que estudio español. (J’étudie l’espagnol depuis trois ans.)',
        exercises: [
          {
            id: 'ex-es-exptpsplus-1',
            type: 'quiz',
            question: 'Complétez : Vivo aquí ___ hace un año (depuis un an).',
            options: ['desde', 'hace', 'desde hace', 'por'],
            correctAnswer: 'desde hace',
            explanation: 'On dit desde hace + durée.'
          },
          {
            id: 'ex-es-exptpsplus-2',
            type: 'fill-in',
            question: 'Complétez : ___ de dos horas llegamos (Dans deux heures nous arrivons).',
            correctAnswer: 'Dentro',
            explanation: 'Dentro de dos horas = dans deux heures.'
          }
        ]
      },
      {
        id: 'es-verbes-impersonnels-plus',
        language: 'es',
        difficulty: 'intermediate',
        category: 'verbes',
        subCategory: 'verbes-irreguliers',
        rule: 'Verbes impersonnels fréquents',
        content: 'Haber (hay), hacer (hace frío), llover (llueve), nevar (nieva).',
        translation: 'hay (il y a), hace frío (il fait froid), llueve (il pleut)',
        example: 'Hoy hace frío y llueve. (Aujourd’hui il fait froid et il pleut.)',
        exercises: [
          {
            id: 'ex-es-impersplus-1',
            type: 'quiz',
            question: 'Complétez : ___ una fiesta esta noche (Il y a une fête ce soir).',
            options: ['Es', 'Está', 'Hace', 'Hay'],
            correctAnswer: 'Hay',
            explanation: 'Haber → hay pour "il y a".'
          },
          {
            id: 'ex-es-impersplus-2',
            type: 'fill-in',
            question: 'Complétez : ___ sol hoy (Il fait soleil aujourd’hui).',
            correctAnswer: 'Hace',
            explanation: 'On dit hace sol.'
          }
        ]
      },
      // ========== THEMES SUPPLÉMENTAIRES ITALIEN ==========
      {
        id: 'it-pronoms-cod',
        language: 'it',
        difficulty: 'intermediate',
        category: 'pronoms',
        subCategory: 'pronoms-cod',
        rule: 'Pronoms compléments d’objet direct',
        content: 'Les pronoms COD remplacent le complément et se placent en général avant le verbe.',
        translation: 'mi, ti, lo, la, ci, vi, li, le',
        example: 'Vedo Marco → Lo vedo. (Je le vois.)',
        exercises: [
          {
            id: 'ex-it-cod-1',
            type: 'quiz',
            question: 'Complétez : Vedo Maria → ___ vedo.',
            options: ['la', 'lo', 'lei', 'lui'],
            correctAnswer: 'la',
            explanation: 'Maria est féminin singulier → la vedo.'
          },
          {
            id: 'ex-it-cod-2',
            type: 'fill-in',
            question: 'Complétez : Invito gli amici → ___ invito (Je les invite).',
            correctAnswer: 'li',
            explanation: 'Gli amici (masc. pluriel) → li.'
          }
        ]
      },
      {
        id: 'it-pronoms-coi',
        language: 'it',
        difficulty: 'intermediate',
        category: 'pronoms',
        subCategory: 'pronoms-coi',
        rule: 'Pronoms compléments d’objet indirect',
        content: 'Les pronoms COI se combinent avec les verbes comme dire, dare, telefonare, parlare…',
        translation: 'mi, ti, gli/le, ci, vi, gli',
        example: 'Parlo a Marco → Gli parlo. (Je lui parle.)',
        exercises: [
          {
            id: 'ex-it-coi-1',
            type: 'quiz',
            question: 'Complétez : Scrivo a mia madre → ___ scrivo.',
            options: ['la', 'gli', 'le', 'ci'],
            correctAnswer: 'le',
            explanation: 'Mia madre (fém. sing.) → le scrivo.'
          },
          {
            id: 'ex-it-coi-2',
            type: 'fill-in',
            question: 'Complétez : Telefoniamo agli amici → ___ telefoniamo.',
            correctAnswer: 'gli',
            explanation: 'Agli amici (à eux) → gli telefoniamo.'
          }
        ]
      },
      {
        id: 'it-ordre-mots',
        language: 'it',
        difficulty: 'beginner',
        category: 'syntaxe',
        subCategory: 'ordre-mots',
        rule: 'Ordre des mots de base',
        content: 'L’ordre neutre est Sujet–Verbe–Compléments, avec possibilité d’inverser pour insister.',
        translation: 'Io mangio la pizza. / Mangio la pizza.',
        example: 'Stasera mangio la pizza. (Ce soir je mange la pizza.)',
        exercises: [
          {
            id: 'ex-it-ordre-1',
            type: 'quiz',
            question: 'Quel ordre est le plus naturel ? (Je lis le livre)',
            options: ['Leggo il libro.', 'Il libro leggo.', 'Libro leggo il.'],
            correctAnswer: 'Leggo il libro.',
            explanation: 'Verbe + COD est la structure la plus fréquente à l’oral.'
          },
          {
            id: 'ex-it-ordre-2',
            type: 'fill-in',
            question: 'Remettez dans l’ordre : la / bevo / mattina / caffè',
            correctAnswer: 'La mattina bevo caffè',
            explanation: 'Complément de temps → verbe → complément d’objet.'
          }
        ]
      },
      {
        id: 'it-prepositions-base',
        language: 'it',
        difficulty: 'beginner',
        category: 'prepositions',
        subCategory: 'prepositions-base',
        rule: 'Prépositions de base',
        content: 'Les prépositions simples indiquent lieu, origine, moyen, but…',
        translation: 'a, da, di, in, su, con, per, tra/fra',
        example: 'Vado a Roma, vengo da Milano, viaggio in treno.',
        exercises: [
          {
            id: 'ex-it-prepbase-1',
            type: 'quiz',
            question: 'Complétez : Vado __ scuola (Je vais à l’école)',
            options: ['a', 'in', 'da', 'di'],
            correctAnswer: 'a',
            explanation: 'On dit andare a scuola.'
          },
          {
            id: 'ex-it-prepbase-2',
            type: 'fill-in',
            question: 'Complétez : Vengo __ Francia (Je viens de France)',
            correctAnswer: 'dalla',
            explanation: 'On utilise di/da + article → dalla Francia.'
          }
        ]
      },
      {
        id: 'it-subjonctif-pres',
        language: 'it',
        difficulty: 'advanced',
        category: 'verbes',
        subCategory: 'subjonctif',
        rule: 'Subjonctif présent (Congiuntivo presente)',
        content: 'Utilisé après certains verbes d’opinion, de doute, de souhait, de nécessité…',
        translation: 'che io parli, che tu parli, che lui/lei parli, che noi parliamo, che voi parliate, che loro parlino',
        example: 'Penso che sia una buona idea. (Je pense que c’est une bonne idée.)',
        exercises: [
          {
            id: 'ex-it-subj-1',
            type: 'fill-in',
            question: 'Complétez : Spero che tu ___ bene (andare).',
            correctAnswer: 'vada',
            explanation: 'Andare au subjonctif → che tu vada.'
          },
          {
            id: 'ex-it-subj-2',
            type: 'quiz',
            question: 'Après lequel de ces verbes utilise-t-on souvent le subjonctif ? (io ___ che...)',
            options: ['so', 'spero', 'vedo', 'ho'],
            correctAnswer: 'spero',
            explanation: 'Les verbes exprimant souhait/doute comme sperare prennent souvent le congiuntivo.'
          }
        ]
      },
      // ========== THEMES SUPPLÉMENTAIRES ESPAGNOL ==========
      {
        id: 'es-pronoms-cod',
        language: 'es',
        difficulty: 'intermediate',
        category: 'pronoms',
        subCategory: 'pronoms-cod',
        rule: 'Pronoms compléments d’objet direct',
        content: 'Les pronoms COD remplaçant le complément se placent en général avant le verbe conjugué.',
        translation: 'me, te, lo, la, nos, os, los, las',
        example: 'Veo a María → La veo. (Je la vois.)',
        exercises: [
          {
            id: 'ex-es-cod-1',
            type: 'quiz',
            question: 'Complétez : Veo a mis amigos → ___ veo.',
            options: ['los', 'les', 'las', 'lo'],
            correctAnswer: 'los',
            explanation: 'Mis amigos (masc. pluriel) → los veo.'
          },
          {
            id: 'ex-es-cod-2',
            type: 'fill-in',
            question: 'Complétez : Quiero el libro → ___ quiero (Je le veux).',
            correctAnswer: 'lo',
            explanation: 'El libro (masc. sing.) → lo quiero.'
          }
        ]
      },
      {
        id: 'es-pronoms-coi',
        language: 'es',
        difficulty: 'intermediate',
        category: 'pronoms',
        subCategory: 'pronoms-coi',
        rule: 'Pronoms compléments d’objet indirect',
        content: 'Les pronoms COI se combinent avec des verbes comme dar, decir, gustar, escribir…',
        translation: 'me, te, le, nos, os, les',
        example: 'Doy el libro a Juan → Le doy el libro. (Je lui donne le livre.)',
        exercises: [
          {
            id: 'ex-es-coi-1',
            type: 'quiz',
            question: 'Complétez : Escribo a mis padres → ___ escribo.',
            options: ['los', 'les', 'lo', 'le'],
            correctAnswer: 'les',
            explanation: 'A mis padres (à eux) → les escribo.'
          },
          {
            id: 'ex-es-coi-2',
            type: 'fill-in',
            question: 'Complétez : Damos el regalo a Ana → ___ damos el regalo.',
            correctAnswer: 'le',
            explanation: 'A Ana (à elle) → le damos el regalo.'
          }
        ]
      },
      {
        id: 'es-ordre-mots',
        language: 'es',
        difficulty: 'beginner',
        category: 'syntaxe',
        subCategory: 'ordre-mots',
        rule: 'Ordre des mots de base',
        content: 'L’ordre neutre est Sujet–Verbe–Compléments, avec des inversions possibles dans les questions.',
        translation: 'Yo como pan. / Como pan. ¿Dónde vives tú?',
        example: 'Por la mañana bebo café. (Le matin je bois du café.)',
        exercises: [
          {
            id: 'ex-es-ordre-1',
            type: 'quiz',
            question: 'Quel ordre est le plus naturel ? (Je lis le livre)',
            options: ['Leo el libro.', 'El libro leo.', 'Libro leo el.'],
            correctAnswer: 'Leo el libro.',
            explanation: 'Sujet implicite + verbe + COD est la structure la plus fréquente.'
          },
          {
            id: 'ex-es-ordre-2',
            type: 'fill-in',
            question: 'Remettez dans l’ordre : la / vemos / noche / película',
            correctAnswer: 'Vemos la película noche',
            explanation: 'Une solution naturelle serait "Por la noche vemos la película", l’idée est de reconstituer un ordre logique S–V–COD.'
          }
        ]
      },
      {
        id: 'es-prepositions-base',
        language: 'es',
        difficulty: 'beginner',
        category: 'prepositions',
        subCategory: 'prepositions-base',
        rule: 'Prépositions de base',
        content: 'Les prépositions simples indiquent lieu, origine, moyen, cause…',
        translation: 'a, de, en, con, por, para, sin, entre',
        example: 'Voy a Madrid, vengo de Francia, estoy en casa.',
        exercises: [
          {
            id: 'ex-es-prepbase-1',
            type: 'quiz',
            question: 'Complétez : Voy __ la playa (Je vais à la plage)',
            options: ['a', 'en', 'de', 'por'],
            correctAnswer: 'a',
            explanation: 'On dit ir a la playa.'
          },
          {
            id: 'ex-es-prepbase-2',
            type: 'fill-in',
            question: 'Complétez : Vengo __ Francia (Je viens de France)',
            correctAnswer: 'de',
            explanation: 'On utilise de pour l’origine : vengo de Francia.'
          }
        ]
      },
      {
        id: 'es-subjonctif-pres',
        language: 'es',
        difficulty: 'advanced',
        category: 'verbes',
        subCategory: 'subjonctif',
        rule: 'Subjonctif présent (Subjuntivo presente)',
        content: 'Utilisé après certains verbes d’opinion, de doute, de volonté ou d’émotion.',
        translation: 'que yo hable, que tú hables, que él hable, que nosotros hablemos...',
        example: 'Espero que tengas un buen día. (J’espère que tu passes une bonne journée.)',
        exercises: [
          {
            id: 'ex-es-subj-1',
            type: 'fill-in',
            question: 'Complétez : Quiero que tú ___ la verdad (decir).',
            correctAnswer: 'digas',
            explanation: 'Decir au subjonctif → que tú digas.'
          },
          {
            id: 'ex-es-subj-2',
            type: 'quiz',
            question: 'Après lequel de ces verbes utilise-t-on souvent le subjonctif ? (yo ___ que...)',
            options: ['creo', 'pienso', 'dudo', 'veo'],
            correctAnswer: 'dudo',
            explanation: 'Les verbes exprimant le doute comme dudar prennent souvent le subjuntivo.'
          }
        ]
      }
    ]
  }

  // Données de démonstration - Phonétique
  const loadDemoPhonetics = () => {
    phonetics.value = [
      // Italien
      {
        id: 'it-ch',
        language: 'it',
        difficulty: 'beginner',
        content: 'CH',
        phonetic: '/k/',
        translation: 'Se prononce comme "k" en français',
        example: 'che (ke), chi (ki), chiesa (kiéza)'
      },
      {
        id: 'it-gh',
        language: 'it',
        difficulty: 'beginner',
        content: 'GH',
        phonetic: '/g/',
        translation: 'Se prononce comme "g" dur en français',
        example: 'ghiaccio (giatchô), spaghetti (spaguètti)'
      },
      {
        id: 'it-gl',
        language: 'it',
        difficulty: 'beginner',
        content: 'GL + I',
        phonetic: '/ʎ/',
        translation: 'Se prononce comme "ill" en français',
        example: 'famiglia (familla), figlio (fillo)'
      },
      {
        id: 'it-gn',
        language: 'it',
        difficulty: 'beginner',
        content: 'GN',
        phonetic: '/ɲ/',
        translation: 'Se prononce comme "gn" en français',
        example: 'gnocchi (niokki),ognuno (oniuno)'
      },
      // Espagnol
      {
        id: 'es-j',
        language: 'es',
        difficulty: 'beginner',
        content: 'J',
        phonetic: '/x/',
        translation: 'Son guttural (comme le "ch" allemand)',
        example: 'jamón (ramone), julio (roulio)'
      },
      {
        id: 'es-ll',
        language: 'es',
        difficulty: 'beginner',
        content: 'LL',
        phonetic: '/ʝ/ ou /ʃ/',
        translation: 'Se prononce "y" ou "ch" selon les régions',
        example: 'llamar (yamar/chamar), calle (kayé/kaché)'
      },
      {
        id: 'es-n-tilde',
        language: 'es',
        difficulty: 'beginner',
        content: 'Ñ',
        phonetic: '/ɲ/',
        translation: 'Se prononce comme "gn" en français',
        example: 'España (Espania), niño (gnigno)'
      },
      {
        id: 'es-rr',
        language: 'es',
        difficulty: 'intermediate',
        content: 'RR',
        phonetic: '/r/',
        translation: 'R roulé fortement',
        example: 'perro (pèrro), carro (karro)'
      }
    ]
  }

  // Initialiser les données de démonstration
  const initDemoData = () => {
    loadDemoConjugations()
    loadDemoVocabulary()
    loadDemoGrammar()
    loadDemoPhonetics()
  }

  // Filtrer par langue
  const getConjugationsByLanguage = computed(() => {
    return conjugations.value.filter(c => c.language === currentLanguage.value)
  })

  const getVocabularyByLanguage = computed(() => {
    return vocabulary.value.filter(v => v.language === currentLanguage.value)
  })

  const getGrammarByLanguage = computed(() => {
    return grammar.value.filter(g => g.language === currentLanguage.value)
  })

  const getPhoneticsByLanguage = computed(() => {
    return phonetics.value.filter(p => p.language === currentLanguage.value)
  })

  return {
    // État
    currentLanguage,
    currentSection,
    currentDifficulty,
    loading,
    error,
    progress,
    conjugations,
    vocabulary,
    grammar,
    phonetics,
    // Computed
    currentProgress,
    progressPercentage,
    getConjugationsByLanguage,
    getVocabularyByLanguage,
    getGrammarByLanguage,
    getPhoneticsByLanguage,
    // Actions
    setLanguage,
    setSection,
    setDifficulty,
    updateProgress,
    resetSection,
    initDemoData
  }
})
