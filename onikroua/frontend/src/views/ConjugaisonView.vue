<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useLearningStore } from '../stores/learning'

const learningStore = useLearningStore()

onMounted(() => {
  learningStore.initDemoData()
  learningStore.setSection('conjugaison')
})

const activeTab = ref<'verbes' | 'temps' | 'regles' | 'pratique' | 'plus'>('verbes')
const expandedVerb = ref<string | null>(null)

const conjugations = computed(() => learningStore.getConjugationsByLanguage)

const verbSearch = ref('')
const verbFilter = ref<'all' | 'aux' | 'modal' | 'movement'>('all')

const languageLabel = computed(() => 
  learningStore.currentLanguage === 'it' ? '🇮🇹 Italien' : '🇪🇸 Espagnol'
)

const toggleVerb = (id: string) => {
  expandedVerb.value = expandedVerb.value === id ? null : id
}

const getVerbLabels = (verb: string) => {
  const lang = learningStore.currentLanguage
  const labels: string[] = []

  if (lang === 'it') {
    if (['essere', 'avere'].includes(verb)) {
      labels.push('auxiliaire')
    }
    if (['potere', 'volere', 'dovere'].includes(verb)) {
      labels.push('modal')
    }
    if (['andare', 'venire'].includes(verb)) {
      labels.push('mouvement')
    }
  } else {
    if (['ser', 'estar', 'haber'].includes(verb)) {
      labels.push('verbe clé')
    }
    if (['poder', 'querer', 'tener'].includes(verb)) {
      labels.push('modal / fréquent')
    }
    if (['ir', 'venir'].includes(verb)) {
      labels.push('mouvement')
    }
  }

  return labels
}

const filteredConjugations = computed(() => {
  let list = conjugations.value

  const search = verbSearch.value.trim().toLowerCase()
  if (search) {
    list = list.filter(conj => 
      conj.verb.toLowerCase().includes(search) ||
      (conj.translation && conj.translation.toLowerCase().includes(search))
    )
  }

  if (verbFilter.value !== 'all') {
    list = list.filter(conj => {
      const labels = getVerbLabels(conj.verb)
      if (verbFilter.value === 'aux') {
        return labels.includes('auxiliaire') || labels.includes('verbe clé')
      }
      if (verbFilter.value === 'modal') {
        return labels.includes('modal') || labels.includes('modal / fréquent')
      }
      if (verbFilter.value === 'movement') {
        return labels.includes('mouvement')
      }
      return true
    })
  }

  return list
})

// ===== TTS (Text-to-Speech) =====
const isPlaying = ref(false)
const currentPlayingId = ref<string | null>(null)

const speak = (text: string, id?: string) => {
  if (isPlaying.value) {
    speechSynthesis.cancel()
    isPlaying.value = false
    currentPlayingId.value = null
    return
  }
  
  const lang = learningStore.currentLanguage === 'it' ? 'it-IT' : 'es-ES'
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = lang
  utterance.rate = 0.85
  utterance.pitch = 1
  
  isPlaying.value = true
  currentPlayingId.value = id || null
  
  utterance.onend = () => {
    isPlaying.value = false
    currentPlayingId.value = null
  }
  utterance.onerror = () => {
    isPlaying.value = false
    currentPlayingId.value = null
  }
  
  speechSynthesis.speak(utterance)
}

const speakConjugation = (verb: string, forms: Record<string, string>) => {
  const pronouns = Object.keys(forms)
  const text = pronouns.map(p => `${p}, ${forms[p]}`).join('. ')
  speak(`${verb}. ${text}`)
}

// ===== Mode Pratique =====
const practiceMode = ref<'choice' | 'write'>('choice')
const practiceVerb = ref<string | null>(null)
const practicePronoun = ref<string | null>(null)
const practiceAnswer = ref('')
const practiceResult = ref<'correct' | 'wrong' | null>(null)
const practiceScore = ref(0)
const practiceTotal = ref(0)
const practiceStreak = ref(0)
const practiceSelectedTense = ref<'present' | 'past'>('present')

const practiceVerbs = computed(() => {
  const lang = learningStore.currentLanguage
  const tense = practiceSelectedTense.value

  if (lang === 'it') {
    if (tense === 'present') {
      return [
        { infinitive: 'parlare', translation: 'parler', forms: { io: 'parlo', tu: 'parli', 'lui/lei': 'parla', noi: 'parliamo', voi: 'parlate', loro: 'parlano' } },
        { infinitive: 'mangiare', translation: 'manger', forms: { io: 'mangio', tu: 'mangi', 'lui/lei': 'mangia', noi: 'mangiamo', voi: 'mangiate', loro: 'mangiano' } },
        { infinitive: 'vedere', translation: 'voir', forms: { io: 'vedo', tu: 'vedi', 'lui/lei': 'vede', noi: 'vediamo', voi: 'vedete', loro: 'vedono' } },
        { infinitive: 'dormire', translation: 'dormir', forms: { io: 'dormo', tu: 'dormi', 'lui/lei': 'dorme', noi: 'dormiamo', voi: 'dormite', loro: 'dormono' } },
        { infinitive: 'essere', translation: 'être', forms: { io: 'sono', tu: 'sei', 'lui/lei': 'è', noi: 'siamo', voi: 'siete', loro: 'sono' } },
        { infinitive: 'avere', translation: 'avoir', forms: { io: 'ho', tu: 'hai', 'lui/lei': 'ha', noi: 'abbiamo', voi: 'avete', loro: 'hanno' } },
        { infinitive: 'andare', translation: 'aller', forms: { io: 'vado', tu: 'vai', 'lui/lei': 'va', noi: 'andiamo', voi: 'andate', loro: 'vanno' } },
        { infinitive: 'fare', translation: 'faire', forms: { io: 'faccio', tu: 'fai', 'lui/lei': 'fa', noi: 'facciamo', voi: 'fate', loro: 'fanno' } }
      ]
    }

    return [
      { infinitive: 'parlare', translation: 'parler', forms: { io: 'ho parlato', tu: 'hai parlato', 'lui/lei': 'ha parlato', noi: 'abbiamo parlato', voi: 'avete parlato', loro: 'hanno parlato' } },
      { infinitive: 'andare', translation: 'aller', forms: { io: 'sono andato', tu: 'sei andato', 'lui/lei': 'è andato', noi: 'siamo andati', voi: 'siete andati', loro: 'sono andati' } },
      { infinitive: 'essere', translation: 'être', forms: { io: 'sono stato', tu: 'sei stato', 'lui/lei': 'è stato', noi: 'siamo stati', voi: 'siete stati', loro: 'sono stati' } }
    ]
  }

  if (tense === 'present') {
    return [
      { infinitive: 'hablar', translation: 'parler', forms: { yo: 'hablo', tú: 'hablas', 'él/ella': 'habla', nosotros: 'hablamos', vosotros: 'habláis', ellos: 'hablan' } },
      { infinitive: 'comer', translation: 'manger', forms: { yo: 'como', tú: 'comes', 'él/ella': 'come', nosotros: 'comemos', vosotros: 'coméis', ellos: 'comen' } },
      { infinitive: 'vivir', translation: 'vivre', forms: { yo: 'vivo', tú: 'vives', 'él/ella': 'vive', nosotros: 'vivimos', vosotros: 'vivís', ellos: 'viven' } },
      { infinitive: 'ser', translation: 'être (permanent)', forms: { yo: 'soy', tú: 'eres', 'él/ella': 'es', nosotros: 'somos', vosotros: 'sois', ellos: 'son' } },
      { infinitive: 'estar', translation: 'être (état)', forms: { yo: 'estoy', tú: 'estás', 'él/ella': 'está', nosotros: 'estamos', vosotros: 'estáis', ellos: 'están' } },
      { infinitive: 'tener', translation: 'avoir', forms: { yo: 'tengo', tú: 'tienes', 'él/ella': 'tiene', nosotros: 'tenemos', vosotros: 'tenéis', ellos: 'tienen' } },
      { infinitive: 'ir', translation: 'aller', forms: { yo: 'voy', tú: 'vas', 'él/ella': 'va', nosotros: 'vamos', vosotros: 'vais', ellos: 'van' } },
      { infinitive: 'hacer', translation: 'faire', forms: { yo: 'hago', tú: 'haces', 'él/ella': 'hace', nosotros: 'hacemos', vosotros: 'hacéis', ellos: 'hacen' } }
    ]
  }

  return [
    { infinitive: 'hablar', translation: 'parler', forms: { yo: 'he hablado', tú: 'has hablado', 'él/ella': 'ha hablado', nosotros: 'hemos hablado', vosotros: 'habéis hablado', ellos: 'han hablado' } },
    { infinitive: 'comer', translation: 'manger', forms: { yo: 'he comido', tú: 'has comido', 'él/ella': 'ha comido', nosotros: 'hemos comido', vosotros: 'habéis comido', ellos: 'han comido' } },
    { infinitive: 'vivir', translation: 'vivre', forms: { yo: 'he vivido', tú: 'has vivido', 'él/ella': 'ha vivido', nosotros: 'hemos vivido', vosotros: 'habéis vivido', ellos: 'han vivido' } }
  ]
})

const getPracticeTenseLabel = (tense: 'present' | 'past') => {
  const lang = learningStore.currentLanguage
  if (lang === 'it') {
    return tense === 'present' ? 'Presente' : 'Passato prossimo'
  }
  return tense === 'present' ? 'Presente' : 'Pretérito perfecto'
}

const practiceTenseLabel = computed(() => getPracticeTenseLabel(practiceSelectedTense.value))

const selectedTense = ref<string | null>(null)

const tenseDetails = computed(() => {
  const lang = learningStore.currentLanguage
  const details: Record<string, { title: string; usage: string; formation: string; examples: string[] }> = {}

  if (lang === 'it') {
    details['Presente'] = {
      title: 'Presente (italien)',
      usage: 'Parler d\'actions actuelles, d\'habitudes et de vérités générales.',
      formation: 'Radical du verbe + terminaisons : -o, -i, -a, -iamo, -ate, -ano pour -ARE ; -o, -i, -e, -iamo, -ete, -ono pour -ERE ; -o, -i, -e, -iamo, -ite, -ono pour -IRE.',
      examples: ['Parlo italiano ogni giorno. (Je parle italien tous les jours.)', 'Vado a scuola in autobus. (Je vais à l\'école en bus.)']
    }
    details['Passato prossimo'] = {
      title: 'Passato prossimo',
      usage: 'Actions passées terminées ayant un lien avec le présent.',
      formation: 'Auxiliaire ESSERE ou AVERE au présent + participe passé (parlato, andato, finito...). Accord du participe avec le sujet quand l\'auxiliaire est ESSERE.',
      examples: ['Ho parlato con lui. (J\'ai parlé avec lui.)', 'Siamo arrivati tardi. (Nous sommes arrivés en retard.)']
    }
    details['Imperfetto'] = {
      title: 'Imperfetto',
      usage: 'Descriptions, habitudes et actions en cours dans le passé.',
      formation: 'Radical de la 1re personne du pluriel au présent + -vo, -vi, -va, -vamo, -vate, -vano.',
      examples: ['Da bambino giocavo in strada. (Quand j\'étais enfant, je jouais dans la rue.)', 'Parlavamo spesso di viaggi. (Nous parlions souvent de voyages.)']
    }
    details['Futuro semplice'] = {
      title: 'Futuro semplice',
      usage: 'Actions futures, promesses, prévisions.',
      formation: 'Infinitif (parfois tronqué) + -ò, -ai, -à, -emo, -ete, -anno.',
      examples: ['Domani andrò a Roma. (Demain j\'irai à Rome.)', 'Vedremo cosa succederà. (Nous verrons ce qui se passera.)']
    }
    details['Condizionale'] = {
      title: 'Condizionale presente',
      usage: 'Politesse, hypothèses, souhaits.',
      formation: 'Même base que le futur + -ei, -esti, -ebbe, -emmo, -este, -ebbero.',
      examples: ['Vorrei un caffè. (Je voudrais un café.)', 'Parleresti più lentamente? (Parlerais-tu plus lentement ?)']
    }
    details['Congiuntivo'] = {
      title: 'Congiuntivo presente',
      usage: 'Après des verbes exprimant le doute, l\'opinion, le souhait, la peur, etc.',
      formation: 'Terminaisons spécifiques : che io parli, che tu parli, che lui/lei parli, che noi parliamo, che voi parliate, che loro parlino.',
      examples: ['Spero che tu stia bene. (J\'espère que tu vas bien.)', 'Penso che sia difficile. (Je pense que c\'est difficile.)']
    }
    details['Imperativo'] = {
      title: 'Imperativo',
      usage: 'Donner des ordres ou des conseils.',
      formation: 'Formes spécifiques : parla!, parli!, parliamo!, parlate!, parlino!, souvent sans sujet exprimé.',
      examples: ['Parla più piano! (Parle plus doucement !)', 'Mangiamo insieme! (Mangeons ensemble !)']
    }
  } else {
    details['Presente'] = {
      title: 'Presente (espagnol)',
      usage: 'Actions actuelles, vérités générales et habitudes.',
      formation: 'Radical + terminaisons : -o, -as, -a, -amos, -áis, -an pour -AR ; -o, -es, -e, -emos, -éis, -en pour -ER ; -o, -es, -e, -imos, -ís, -en pour -IR.',
      examples: ['Hablo español todos los días. (Je parle espagnol tous les jours.)', 'Vivimos en Madrid. (Nous vivons à Madrid.)']
    }
    details['Pretérito perfecto'] = {
      title: 'Pretérito perfecto compuesto',
      usage: 'Parler d\'actions passées récentes ou liées au présent.',
      formation: 'Auxiliaire HABER au présent + participe passé (hablado, comido, vivido...).',
      examples: ['He hablado con ella. (J\'ai parlé avec elle.)', 'Hemos comido ya. (Nous avons déjà mangé.)']
    }
    details['Pretérito indefinido'] = {
      title: 'Pretérito indefinido',
      usage: 'Actions passées, terminées, sans lien direct avec le présent.',
      formation: 'Terminaisons propres : hablé, hablaste, habló, hablamos, hablasteis, hablaron / comí, comiste, comió, etc.',
      examples: ['Ayer hablé con mi jefe. (Hier j\'ai parlé avec mon chef.)', 'El año pasado viajamos a México. (L\'année dernière, nous avons voyagé au Mexique.)']
    }
    details['Pretérito imperfecto'] = {
      title: 'Pretérito imperfecto',
      usage: 'Habitudes, descriptions et actions en cours dans le passé.',
      formation: 'Deux modèles : -aba, -abas, -aba, -ábamos, -abais, -aban pour -AR ; -ía, -ías, -ía, -íamos, -íais, -ían pour -ER/-IR.',
      examples: ['Cuando era niño jugaba en el parque. (Quand j\'étais enfant, je jouais au parc.)', 'Siempre leía antes de dormir. (Je lisais toujours avant de dormir.)']
    }
    details['Futuro simple'] = {
      title: 'Futuro simple',
      usage: 'Parler du futur, des promesses et des suppositions.',
      formation: 'Infinitif + terminaisons : -é, -ás, -á, -emos, -éis, -án.',
      examples: ['Mañana estudiaré más. (Demain j\'étudierai plus.)', 'Veremos qué pasa. (Nous verrons ce qui se passe.)']
    }
    details['Condicional'] = {
      title: 'Condicional simple',
      usage: 'Hypothèses, souhaits, politesse.',
      formation: 'Infinitif + -ía, -ías, -ía, -íamos, -íais, -ían.',
      examples: ['Me gustaría viajar más. (J\'aimerais voyager davantage.)', 'Iríamos contigo, pero estamos ocupados. (Nous irions avec toi, mais nous sommes occupés.)']
    }
    details['Subjuntivo'] = {
      title: 'Subjuntivo presente',
      usage: 'Après des verbes de volonté, doute, émotion, ou certaines conjonctions.',
      formation: 'Changement de terminaison : que yo hable, que tú hables, que él hable, que nosotros hablemos, que vosotros habléis, que ellos hablen.',
      examples: ['Espero que vengas mañana. (J\'espère que tu viendras demain.)', 'Es importante que estudien. (Il est important qu\'ils étudient.)']
    }
    details['Imperativo'] = {
      title: 'Imperativo',
      usage: 'Donner des ordres ou des conseils.',
      formation: 'Formes spécifiques, souvent sans sujet : habla, hable, hablemos, hablad, hablen.',
      examples: ['Habla más despacio. (Parle plus lentement.)', 'Ven aquí, por favor. (Viens ici, s\'il te plaît.)']
    }
  }

  return details
})

const currentTenseInfo = computed(() => {
  if (!selectedTense.value) return null
  const all = tenseDetails.value
  return all[selectedTense.value] || null
})

const tenseExampleConjugations = computed(() => {
  if (!selectedTense.value) return []
  const lang = learningStore.currentLanguage
  let storeTense = selectedTense.value
  if (storeTense === 'Presente') {
    storeTense = 'Présent'
  }
  if (lang === 'it') {
    return filteredConjugations.value
      .filter(conj => conj.tense === storeTense)
      .slice(0, 2)
  }
  if (lang === 'es') {
    return filteredConjugations.value
      .filter(conj => conj.tense === storeTense)
      .slice(0, 2)
  }
  return []
})

const currentPracticeVerb = computed(() => {
  if (!practiceVerb.value) return null
  return practiceVerbs.value.find(v => v.infinitive === practiceVerb.value)
})

const correctAnswer = computed(() => {
  if (!currentPracticeVerb.value || !practicePronoun.value) return ''
  const forms = currentPracticeVerb.value.forms as Record<string, string>
  return forms[practicePronoun.value] || ''
})

const practiceChoices = computed(() => {
  if (!currentPracticeVerb.value || !practicePronoun.value) return []
  const correct = correctAnswer.value
  const forms = currentPracticeVerb.value.forms as Record<string, string>
  const allForms = Object.values(forms).filter(f => f !== correct)
  // Mélanger et prendre 3
  const shuffled = allForms.sort(() => Math.random() - 0.5).slice(0, 3)
  // Ajouter la bonne réponse et mélanger
  const choices = [...shuffled, correct].sort(() => Math.random() - 0.5)
  return choices
})

const practiceHelp = computed(() => {
  const verb = currentPracticeVerb.value
  const pronoun = practicePronoun.value
  if (!verb || !pronoun) return null

  const inf = verb.infinitive
  const lang = learningStore.currentLanguage
  const tense = practiceSelectedTense.value

  if (lang === 'it') {
    if (tense === 'present') {
      if (['essere', 'avere', 'andare', 'fare'].includes(inf)) {
        return {
          title: 'Verbe irrégulier très fréquent',
          description: 'Ce verbe ne suit pas un modèle régulier, il faut mémoriser ses formes au présent.',
          tip: 'Répète la conjugaison à voix haute : io, tu, lui/lei, noi, voi, loro.'
        }
      }

      if (inf.endsWith('are')) {
        return {
          title: '1er groupe italien : verbes en -ARE',
          description: 'Les verbes en -ARE prennent la terminaison -o, -i, -a, -iamo, -ate, -ano au présent.',
          tip: `Ici tu conjugues « ${inf} » avec le pronom « ${pronoun} ». Essaie de retrouver la terminaison correspondante (-i, -a, etc.).`
        }
      }
      if (inf.endsWith('ere')) {
        return {
          title: '2ᵉ groupe italien : verbes en -ERE',
          description: 'Les verbes en -ERE prennent la terminaison -o, -i, -e, -iamo, -ete, -ono au présent.',
          tip: 'Compare les formes avec « vedere » : vedo, vedi, vede, vediamo, vedete, vedono.'
        }
      }
      if (inf.endsWith('ire')) {
        return {
          title: '3ᵉ groupe italien : verbes en -IRE',
          description: 'Deux modèles existent : simple (dormire) et avec -isc- (finire). Les personnes io, tu, lui/lei, loro peuvent prendre -isc-.',
          tip: 'Repère si le verbe utilise -isc- (finisco, finisci, finisce, finiscono) ou non.'
        }
      }

      return {
        title: 'Modèle régulier italien',
        description: 'Ce verbe suit un modèle régulier : observe bien la terminaison liée au pronom pour pouvoir la réutiliser avec d’autres verbes.',
        tip: 'Crée mentalement une mini-table de conjugaison pour ce verbe.'
      }
    }

    const essereVerbs = ['andare', 'venire', 'essere']
    if (essereVerbs.includes(inf)) {
      return {
        title: 'Passato prossimo avec ESSERE',
        description: 'Certains verbes de mouvement et le verbe « essere » se conjuguent au passato prossimo avec l’auxiliaire ESSERE et accord du participe.',
        tip: 'Pense à la structure « sono andato », « siamo arrivati » : auxiliaire + participe passé accordé.'
      }
    }

    return {
      title: 'Passato prossimo avec AVERE',
      description: 'La majorité des verbes italiens forment le passato prossimo avec l’auxiliaire AVERE + participe passé invariable.',
      tip: `Repère la structure « ho/hai/ha... » + participe passé pour « ${inf} ».`
    }
  }

  if (lang === 'es') {
    if (tense === 'present') {
      if (['ser', 'estar', 'tener', 'ir', 'hacer'].includes(inf)) {
        return {
          title: 'Verbe irrégulier clé en espagnol',
          description: 'Ces verbes sont essentiels (être, avoir, aller, faire) et très irréguliers : il faut les connaître par cœur.',
          tip: 'Concentre-toi surtout sur les formes yo, tú et él/ella : elles reviennent tout le temps dans les phrases du quotidien.'
        }
      }

      if (inf.endsWith('ar')) {
        return {
          title: '1er groupe espagnol : verbes en -AR',
          description: 'Au présent : -o, -as, -a, -amos, -áis, -an (hablo, hablas, habla, hablamos, habláis, hablan).',
          tip: `Associe mentalement « ${inf} » à « hablar » et récite la conjugaison complète pour bien fixer le schéma.`
        }
      }
      if (inf.endsWith('er')) {
        return {
          title: '2ᵉ groupe espagnol : verbes en -ER',
          description: 'Au présent : -o, -es, -e, -emos, -éis, -en (como, comes, come...).',
          tip: 'Pense à « comer » comme verbe modèle et compare les terminaisons avec ton verbe.'
        }
      }
      if (inf.endsWith('ir')) {
        return {
          title: '3ᵉ groupe espagnol : verbes en -IR',
          description: 'Au présent : -o, -es, -e, -imos, -ís, -en (vivo, vives, vive, vivimos, vivís, viven).',
          tip: 'Repère la terminaison « -imos / -ís » pour nous / vous, typique des verbes en -IR.'
        }
      }

      return {
        title: 'Modèle régulier espagnol',
        description: 'Ce verbe suit un modèle régulier : une fois la terminaison retenue, tu peux l’appliquer à beaucoup d’autres verbes du même groupe.',
        tip: 'Essaie de deviner les autres formes du verbe à partir de celle que tu viens de pratiquer.'
      }
    }

    return {
      title: 'Pretérito perfecto',
      description: 'On forme ce temps avec l’auxiliaire HABER au présent + participe passé en -ado / -ido pour parler d’actions récentes liées au présent.',
      tip: `Repère bien « he/has/ha/hemos/habéis/han » + participe passé pour le verbe « ${inf} ».`
    }
  }

  return null
})

const generateNewQuestion = () => {
  practiceResult.value = null
  practiceAnswer.value = ''
  
  // Choisir un verbe aléatoire
  const randomVerb = practiceVerbs.value[Math.floor(Math.random() * practiceVerbs.value.length)]
  practiceVerb.value = randomVerb.infinitive
  
  // Choisir un pronom aléatoire
  const pronouns = Object.keys(randomVerb.forms)
  practicePronoun.value = pronouns[Math.floor(Math.random() * pronouns.length)]
}

const checkAnswer = (answer: string) => {
  practiceTotal.value++
  const isCorrect = answer.toLowerCase().trim() === correctAnswer.value.toLowerCase().trim()
  
  if (isCorrect) {
    practiceResult.value = 'correct'
    practiceScore.value++
    practiceStreak.value++
    // Lire la bonne réponse
    speak(correctAnswer.value)
  } else {
    practiceResult.value = 'wrong'
    practiceStreak.value = 0
  }
}

const submitWriteAnswer = () => {
  if (!practiceAnswer.value.trim()) return
  checkAnswer(practiceAnswer.value)
}

const resetPractice = () => {
  practiceScore.value = 0
  practiceTotal.value = 0
  practiceStreak.value = 0
  generateNewQuestion()
}

watch(practiceSelectedTense, () => {
  practiceScore.value = 0
  practiceTotal.value = 0
  practiceStreak.value = 0
  practiceResult.value = null
  practiceAnswer.value = ''
  generateNewQuestion()
})

// Générer une question au démarrage du mode pratique et pré-sélectionner un temps
watch(activeTab, (newTab) => {
  if (newTab === 'pratique' && !practiceVerb.value) {
    generateNewQuestion()
  }
  if (newTab === 'temps' && !selectedTense.value) {
    const firstTense = grammarContent.value.tenses[0]
    selectedTense.value = firstTense ? firstTense.name : null
  }
})

// Regénérer quand on change de langue
watch(() => learningStore.currentLanguage, () => {
  if (activeTab.value === 'pratique') {
    resetPractice()
  }
})

// Données de grammaire complètes
const grammarContent = computed(() => {
  if (learningStore.currentLanguage === 'it') {
    return {
      intro: {
        title: 'La conjugaison italienne',
        description: 'L\'italien possède trois groupes de verbes réguliers, identifiés par leur terminaison à l\'infinitif : -ARE, -ERE et -IRE. Chaque groupe suit des règles de conjugaison spécifiques.'
      },
      groups: [
        {
          name: '1er groupe : -ARE',
          description: 'Le groupe le plus courant. La majorité des verbes italiens appartiennent à ce groupe.',
          examples: ['parlare (parler)', 'mangiare (manger)', 'amare (aimer)', 'lavorare (travailler)'],
          endings: {
            present: { io: '-o', tu: '-i', 'lui/lei': '-a', noi: '-iamo', voi: '-ate', loro: '-ano' }
          },
          conjugation: {
            verb: 'PARLARE',
            forms: { io: 'parlo', tu: 'parli', 'lui/lei': 'parla', noi: 'parliamo', voi: 'parlate', loro: 'parlano' }
          }
        },
        {
          name: '2ème groupe : -ERE',
          description: 'Groupe intermédiaire avec quelques irrégularités fréquentes.',
          examples: ['vedere (voir)', 'leggere (lire)', 'scrivere (écrire)', 'prendere (prendre)'],
          endings: {
            present: { io: '-o', tu: '-i', 'lui/lei': '-e', noi: '-iamo', voi: '-ete', loro: '-ono' }
          },
          conjugation: {
            verb: 'VEDERE',
            forms: { io: 'vedo', tu: 'vedi', 'lui/lei': 'vede', noi: 'vediamo', voi: 'vedete', loro: 'vedono' }
          }
        },
        {
          name: '3ème groupe : -IRE',
          description: 'Ce groupe se divise en deux sous-groupes : les verbes réguliers et ceux qui prennent -isc-.',
          examples: ['dormire (dormir)', 'partire (partir)', 'finire (finir)', 'capire (comprendre)'],
          endings: {
            present: { io: '-o/-isco', tu: '-i/-isci', 'lui/lei': '-e/-isce', noi: '-iamo', voi: '-ite', loro: '-ono/-iscono' }
          },
          conjugation: {
            verb: 'DORMIRE / FINIRE',
            forms: { io: 'dormo / finisco', tu: 'dormi / finisci', 'lui/lei': 'dorme / finisce', noi: 'dormiamo / finiamo', voi: 'dormite / finite', loro: 'dormono / finiscono' }
          }
        }
      ],
      auxiliaries: [
        {
          verb: 'ESSERE (être)',
          usage: 'Auxiliaire pour les verbes de mouvement, les verbes réfléchis et la voix passive.',
          forms: { io: 'sono', tu: 'sei', 'lui/lei': 'è', noi: 'siamo', voi: 'siete', loro: 'sono' },
          examples: ['Sono italiano. (Je suis italien.)', 'Siamo arrivati. (Nous sommes arrivés.)']
        },
        {
          verb: 'AVERE (avoir)',
          usage: 'Auxiliaire pour la plupart des verbes transitifs.',
          forms: { io: 'ho', tu: 'hai', 'lui/lei': 'ha', noi: 'abbiamo', voi: 'avete', loro: 'hanno' },
          examples: ['Ho fame. (J\'ai faim.)', 'Abbiamo mangiato. (Nous avons mangé.)']
        }
      ],
      tenses: [
        { name: 'Presente', description: 'Actions actuelles ou habituelles', example: 'Parlo italiano.' },
        { name: 'Passato prossimo', description: 'Actions passées avec lien au présent', example: 'Ho parlato con lui.' },
        { name: 'Imperfetto', description: 'Actions passées habituelles ou descriptions', example: 'Parlavo spesso con lei.' },
        { name: 'Futuro semplice', description: 'Actions futures', example: 'Parlerò domani.' },
        { name: 'Condizionale', description: 'Actions hypothétiques ou polies', example: 'Parlerei volentieri.' },
        { name: 'Congiuntivo', description: 'Subjonctif - doute, souhait, opinion', example: 'Spero che tu parli.' },
        { name: 'Imperativo', description: 'Ordres et conseils', example: 'Parla! Parliamo!' }
      ],
      irregulars: [
        { verb: 'andare', meaning: 'aller', forms: 'vado, vai, va, andiamo, andate, vanno' },
        { verb: 'venire', meaning: 'venir', forms: 'vengo, vieni, viene, veniamo, venite, vengono' },
        { verb: 'fare', meaning: 'faire', forms: 'faccio, fai, fa, facciamo, fate, fanno' },
        { verb: 'dire', meaning: 'dire', forms: 'dico, dici, dice, diciamo, dite, dicono' },
        { verb: 'stare', meaning: 'rester/être', forms: 'sto, stai, sta, stiamo, state, stanno' },
        { verb: 'dare', meaning: 'donner', forms: 'do, dai, dà, diamo, date, danno' },
        { verb: 'sapere', meaning: 'savoir', forms: 'so, sai, sa, sappiamo, sapete, sanno' },
        { verb: 'potere', meaning: 'pouvoir', forms: 'posso, puoi, può, possiamo, potete, possono' },
        { verb: 'volere', meaning: 'vouloir', forms: 'voglio, vuoi, vuole, vogliamo, volete, vogliono' },
        { verb: 'dovere', meaning: 'devoir', forms: 'devo, devi, deve, dobbiamo, dovete, devono' }
      ],
      pronouns: {
        title: 'Les pronoms personnels',
        subject: [
          { pronoun: 'io', translation: 'je' },
          { pronoun: 'tu', translation: 'tu' },
          { pronoun: 'lui/lei', translation: 'il/elle' },
          { pronoun: 'noi', translation: 'nous' },
          { pronoun: 'voi', translation: 'vous' },
          { pronoun: 'loro', translation: 'ils/elles' }
        ],
        direct: [
          { pronoun: 'mi', translation: 'me' },
          { pronoun: 'ti', translation: 'te' },
          { pronoun: 'lo/la', translation: 'le/la' },
          { pronoun: 'ci', translation: 'nous' },
          { pronoun: 'vi', translation: 'vous' },
          { pronoun: 'li/le', translation: 'les (m/f)' }
        ],
        indirect: [
          { pronoun: 'mi', translation: 'me' },
          { pronoun: 'ti', translation: 'te' },
          { pronoun: 'gli/le', translation: 'lui/elle' },
          { pronoun: 'ci', translation: 'nous' },
          { pronoun: 'vi', translation: 'vous' },
          { pronoun: 'gli', translation: 'leur' }
        ]
      },
      expressions: [
        { phrase: 'In bocca al lupo!', translation: 'Bonne chance!', literal: 'Dans la gueule du loup', response: 'Crepi!' },
        { phrase: 'Che bello!', translation: 'Que c\'est beau!', literal: '' },
        { phrase: 'Non vedo l\'ora!', translation: 'J\'ai hâte!', literal: 'Je ne vois pas l\'heure' },
        { phrase: 'Mamma mia!', translation: 'Mon Dieu!', literal: 'Ma mère!' },
        { phrase: 'Fare bella figura', translation: 'Faire bonne impression', literal: '' },
        { phrase: 'Avere voglia di', translation: 'Avoir envie de', literal: '' },
        { phrase: 'Andare d\'accordo', translation: 'S\'entendre bien', literal: '' },
        { phrase: 'Essere al verde', translation: 'Être fauché', literal: 'Être au vert' }
      ],
      prepositions: [
        { prep: 'a', usage: 'direction, lieu, heure', examples: ['Vado a Roma.', 'Alle tre.'] },
        { prep: 'di', usage: 'possession, matière, origine', examples: ['Il libro di Marco.', 'Sono di Milano.'] },
        { prep: 'da', usage: 'provenance, chez, depuis', examples: ['Vengo da casa.', 'Vado dal dottore.'] },
        { prep: 'in', usage: 'lieu (pays, régions), moyen', examples: ['Vivo in Italia.', 'Vado in macchina.'] },
        { prep: 'con', usage: 'accompagnement, moyen', examples: ['Vado con Maria.', 'Scrivo con la penna.'] },
        { prep: 'su', usage: 'sur, à propos de', examples: ['Il libro è sul tavolo.', 'Un film su Roma.'] },
        { prep: 'per', usage: 'but, durée, destination', examples: ['Studio per l\'esame.', 'Parto per Parigi.'] },
        { prep: 'tra/fra', usage: 'entre, dans (temps)', examples: ['Tra me e te.', 'Arrivo fra un\'ora.'] }
      ]
    }
  } else {
    return {
      intro: {
        title: 'La conjugaison espagnole',
        description: 'L\'espagnol possède trois groupes de verbes réguliers : -AR, -ER et -IR. Une particularité importante est la distinction entre SER et ESTAR pour traduire "être".'
      },
      groups: [
        {
          name: '1er groupe : -AR',
          description: 'Le groupe le plus nombreux en espagnol.',
          examples: ['hablar (parler)', 'trabajar (travailler)', 'estudiar (étudier)', 'comprar (acheter)'],
          endings: {
            present: { yo: '-o', tú: '-as', 'él/ella': '-a', nosotros: '-amos', vosotros: '-áis', ellos: '-an' }
          },
          conjugation: {
            verb: 'HABLAR',
            forms: { yo: 'hablo', tú: 'hablas', 'él/ella': 'habla', nosotros: 'hablamos', vosotros: 'habláis', ellos: 'hablan' }
          }
        },
        {
          name: '2ème groupe : -ER',
          description: 'Groupe avec des verbes très courants.',
          examples: ['comer (manger)', 'beber (boire)', 'leer (lire)', 'aprender (apprendre)'],
          endings: {
            present: { yo: '-o', tú: '-es', 'él/ella': '-e', nosotros: '-emos', vosotros: '-éis', ellos: '-en' }
          },
          conjugation: {
            verb: 'COMER',
            forms: { yo: 'como', tú: 'comes', 'él/ella': 'come', nosotros: 'comemos', vosotros: 'coméis', ellos: 'comen' }
          }
        },
        {
          name: '3ème groupe : -IR',
          description: 'Groupe similaire au 2ème mais avec quelques différences.',
          examples: ['vivir (vivre)', 'escribir (écrire)', 'abrir (ouvrir)', 'subir (monter)'],
          endings: {
            present: { yo: '-o', tú: '-es', 'él/ella': '-e', nosotros: '-imos', vosotros: '-ís', ellos: '-en' }
          },
          conjugation: {
            verb: 'VIVIR',
            forms: { yo: 'vivo', tú: 'vives', 'él/ella': 'vive', nosotros: 'vivimos', vosotros: 'vivís', ellos: 'viven' }
          }
        }
      ],
      auxiliaries: [
        {
          verb: 'SER (être - permanent)',
          usage: 'Pour l\'identité, la nationalité, la profession, les caractéristiques permanentes, l\'heure, les événements.',
          forms: { yo: 'soy', tú: 'eres', 'él/ella': 'es', nosotros: 'somos', vosotros: 'sois', ellos: 'son' },
          examples: ['Soy español. (Je suis espagnol.)', 'Es médico. (Il est médecin.)', 'Son las tres. (Il est trois heures.)']
        },
        {
          verb: 'ESTAR (être - état)',
          usage: 'Pour la localisation, les états temporaires, les émotions, le résultat d\'une action.',
          forms: { yo: 'estoy', tú: 'estás', 'él/ella': 'está', nosotros: 'estamos', vosotros: 'estáis', ellos: 'están' },
          examples: ['Estoy cansado. (Je suis fatigué.)', 'Está en Madrid. (Il est à Madrid.)', 'La puerta está abierta. (La porte est ouverte.)']
        },
        {
          verb: 'HABER (avoir - auxiliaire)',
          usage: 'Uniquement comme auxiliaire pour les temps composés.',
          forms: { yo: 'he', tú: 'has', 'él/ella': 'ha', nosotros: 'hemos', vosotros: 'habéis', ellos: 'han' },
          examples: ['He comido. (J\'ai mangé.)', 'Hemos llegado. (Nous sommes arrivés.)']
        },
        {
          verb: 'TENER (avoir - possession)',
          usage: 'Pour la possession, l\'âge, les sensations physiques.',
          forms: { yo: 'tengo', tú: 'tienes', 'él/ella': 'tiene', nosotros: 'tenemos', vosotros: 'tenéis', ellos: 'tienen' },
          examples: ['Tengo hambre. (J\'ai faim.)', 'Tiene 20 años. (Il a 20 ans.)']
        }
      ],
      tenses: [
        { name: 'Presente', description: 'Actions actuelles ou habituelles', example: 'Hablo español.' },
        { name: 'Pretérito perfecto', description: 'Passé composé - actions récentes', example: 'He hablado con él.' },
        { name: 'Pretérito indefinido', description: 'Passé simple - actions terminées', example: 'Hablé ayer.' },
        { name: 'Pretérito imperfecto', description: 'Imparfait - descriptions, habitudes', example: 'Hablaba mucho.' },
        { name: 'Futuro simple', description: 'Actions futures', example: 'Hablaré mañana.' },
        { name: 'Condicional', description: 'Actions hypothétiques', example: 'Hablaría si pudiera.' },
        { name: 'Subjuntivo', description: 'Subjonctif - doute, souhait', example: 'Espero que hables.' },
        { name: 'Imperativo', description: 'Ordres et conseils', example: '¡Habla! ¡Hablemos!' }
      ],
      irregulars: [
        { verb: 'ir', meaning: 'aller', forms: 'voy, vas, va, vamos, vais, van' },
        { verb: 'venir', meaning: 'venir', forms: 'vengo, vienes, viene, venimos, venís, vienen' },
        { verb: 'hacer', meaning: 'faire', forms: 'hago, haces, hace, hacemos, hacéis, hacen' },
        { verb: 'decir', meaning: 'dire', forms: 'digo, dices, dice, decimos, decís, dicen' },
        { verb: 'poder', meaning: 'pouvoir', forms: 'puedo, puedes, puede, podemos, podéis, pueden' },
        { verb: 'querer', meaning: 'vouloir', forms: 'quiero, quieres, quiere, queremos, queréis, quieren' },
        { verb: 'saber', meaning: 'savoir', forms: 'sé, sabes, sabe, sabemos, sabéis, saben' },
        { verb: 'poner', meaning: 'mettre', forms: 'pongo, pones, pone, ponemos, ponéis, ponen' },
        { verb: 'salir', meaning: 'sortir', forms: 'salgo, sales, sale, salimos, salís, salen' },
        { verb: 'dar', meaning: 'donner', forms: 'doy, das, da, damos, dais, dan' }
      ],
      serEstar: {
        title: 'SER vs ESTAR : La grande différence',
        rules: [
          { use: 'SER', cases: ['Identité et caractéristiques permanentes', 'Nationalité et origine', 'Profession', 'Matière', 'Heure et dates', 'Événements (lieu)'], examples: ['Soy francés.', 'Es de madera.', 'La fiesta es en mi casa.'] },
          { use: 'ESTAR', cases: ['Localisation (personnes/objets)', 'États temporaires', 'Émotions et sentiments', 'Résultat d\'une action', 'Gérondif (estar + -ando/-iendo)'], examples: ['Estoy en casa.', 'Está cansado.', 'La puerta está cerrada.'] }
        ]
      },
      pronouns: {
        title: 'Les pronoms personnels',
        subject: [
          { pronoun: 'yo', translation: 'je' },
          { pronoun: 'tú', translation: 'tu' },
          { pronoun: 'él/ella/usted', translation: 'il/elle/vous (formel)' },
          { pronoun: 'nosotros/as', translation: 'nous' },
          { pronoun: 'vosotros/as', translation: 'vous' },
          { pronoun: 'ellos/ellas/ustedes', translation: 'ils/elles/vous (formel pl.)' }
        ],
        direct: [
          { pronoun: 'me', translation: 'me' },
          { pronoun: 'te', translation: 'te' },
          { pronoun: 'lo/la', translation: 'le/la' },
          { pronoun: 'nos', translation: 'nous' },
          { pronoun: 'os', translation: 'vous' },
          { pronoun: 'los/las', translation: 'les' }
        ],
        indirect: [
          { pronoun: 'me', translation: 'me' },
          { pronoun: 'te', translation: 'te' },
          { pronoun: 'le', translation: 'lui' },
          { pronoun: 'nos', translation: 'nous' },
          { pronoun: 'os', translation: 'vous' },
          { pronoun: 'les', translation: 'leur' }
        ]
      },
      expressions: [
        { phrase: '¡Buena suerte!', translation: 'Bonne chance!', literal: '' },
        { phrase: '¡Qué guay!', translation: 'Trop cool!', literal: '' },
        { phrase: '¡No me digas!', translation: 'Sans blague!', literal: 'Ne me dis pas!' },
        { phrase: 'Tener ganas de', translation: 'Avoir envie de', literal: '' },
        { phrase: 'Echar de menos', translation: 'Manquer (qqn)', literal: 'Jeter de moins' },
        { phrase: 'Llevarse bien', translation: 'S\'entendre bien', literal: '' },
        { phrase: 'Estar hecho polvo', translation: 'Être épuisé', literal: 'Être fait poussière' },
        { phrase: 'Costar un ojo de la cara', translation: 'Coûter les yeux de la tête', literal: 'Coûter un œil du visage' }
      ],
      prepositions: [
        { prep: 'a', usage: 'direction, COD personne, heure', examples: ['Voy a Madrid.', 'Veo a María.', 'A las tres.'] },
        { prep: 'de', usage: 'possession, origine, matière', examples: ['El libro de Juan.', 'Soy de Francia.'] },
        { prep: 'en', usage: 'lieu, moyen de transport', examples: ['Estoy en casa.', 'Voy en coche.'] },
        { prep: 'con', usage: 'accompagnement, moyen', examples: ['Voy con mi amigo.', 'Escribo con bolígrafo.'] },
        { prep: 'por', usage: 'cause, lieu (à travers), durée', examples: ['Por la mañana.', 'Paseo por el parque.'] },
        { prep: 'para', usage: 'but, destination, délai', examples: ['Estudio para el examen.', 'Es para ti.'] },
        { prep: 'sin', usage: 'sans', examples: ['Sin azúcar.', 'Sin ti no puedo.'] },
        { prep: 'entre', usage: 'entre', examples: ['Entre tú y yo.', 'Entre las dos y las tres.'] }
      ]
    }
  }
})
</script>

<template>
  <div class="section-container">
    <header class="section-header">
      <h1>📝 Conjugaison & Grammaire</h1>
      <p class="section-subtitle">Maîtrisez la conjugaison en {{ languageLabel }}</p>
      
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

    <!-- Navigation par onglets -->
    <div class="tabs">
      <button 
        :class="['tab-btn', { active: activeTab === 'regles' }]"
        @click="activeTab = 'regles'"
      >
        📚 Règles
      </button>
      <button 
        :class="['tab-btn', { active: activeTab === 'verbes' }]"
        @click="activeTab = 'verbes'"
      >
        ✏️ Conjugaisons
      </button>
      <button 
        :class="['tab-btn', { active: activeTab === 'temps' }]"
        @click="activeTab = 'temps'"
      >
        ⏰ Temps
      </button>
      <button 
        :class="['tab-btn practice-tab', { active: activeTab === 'pratique' }]"
        @click="activeTab = 'pratique'"
      >
        🎮 Pratique
      </button>
      <button 
        :class="['tab-btn plus-tab', { active: activeTab === 'plus' }]"
        @click="activeTab = 'plus'"
      >
        ➕ Plus
      </button>
    </div>

    <!-- Contenu : Règles de base -->
    <div v-if="activeTab === 'regles'" class="tab-content">
      <!-- Introduction -->
      <section class="intro-section card">
        <h2>{{ grammarContent.intro.title }}</h2>
        <p>{{ grammarContent.intro.description }}</p>
      </section>

      <!-- Les 3 groupes -->
      <section class="groups-section">
        <h2 class="section-title">📖 Les trois groupes de verbes</h2>
        <div class="groups-grid">
          <div v-for="group in grammarContent.groups" :key="group.name" class="group-card card">
            <h3 class="group-name">{{ group.name }}</h3>
            <p class="group-desc">{{ group.description }}</p>
            
            <div class="examples-list">
              <strong>Exemples :</strong>
              <ul>
                <li v-for="ex in group.examples" :key="ex">{{ ex }}</li>
              </ul>
            </div>

            <div class="endings-table">
              <h4>Terminaisons au présent :</h4>
              <div class="endings-grid">
                <div v-for="(ending, pronoun) in group.endings.present" :key="pronoun" class="ending-row">
                  <span class="pronoun">{{ pronoun }}</span>
                  <span class="ending">{{ ending }}</span>
                </div>
              </div>
            </div>

            <div class="model-conjugation">
              <h4>Modèle : {{ group.conjugation.verb }}</h4>
              <div class="conj-grid">
                <div v-for="(form, pronoun) in group.conjugation.forms" :key="pronoun" class="conj-row">
                  <span class="pronoun">{{ pronoun }}</span>
                  <span class="form">{{ form }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Auxiliaires -->
      <section class="auxiliaries-section">
        <h2 class="section-title">🔑 Les verbes auxiliaires essentiels</h2>
        <div class="aux-grid">
          <div v-for="aux in grammarContent.auxiliaries" :key="aux.verb" class="aux-card card">
            <h3 class="aux-name">{{ aux.verb }}</h3>
            <p class="aux-usage">{{ aux.usage }}</p>
            
            <div class="aux-conjugation">
              <div v-for="(form, pronoun) in aux.forms" :key="pronoun" class="aux-row">
                <span class="pronoun">{{ pronoun }}</span>
                <span class="form">{{ form }}</span>
              </div>
            </div>

            <div class="aux-examples">
              <strong>Exemples :</strong>
              <ul>
                <li v-for="ex in aux.examples" :key="ex">{{ ex }}</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      <!-- SER vs ESTAR (espagnol uniquement) -->
      <section v-if="grammarContent.serEstar" class="ser-estar-section card">
        <h2>⚡ {{ grammarContent.serEstar.title }}</h2>
        <div class="ser-estar-grid">
          <div v-for="rule in grammarContent.serEstar.rules" :key="rule.use" class="ser-estar-card">
            <h3 :class="['verb-title', rule.use.toLowerCase()]">{{ rule.use }}</h3>
            <ul class="use-cases">
              <li v-for="c in rule.cases" :key="c">{{ c }}</li>
            </ul>
            <div class="rule-examples">
              <span v-for="ex in rule.examples" :key="ex" class="example-tag">{{ ex }}</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Verbes irréguliers -->
      <section class="irregulars-section">
        <h2 class="section-title">⚠️ Verbes irréguliers courants (Présent)</h2>
        <div class="irregulars-table card">
          <div class="irregular-header">
            <span>Verbe</span>
            <span>Traduction</span>
            <span>Conjugaison</span>
          </div>
          <div v-for="irr in grammarContent.irregulars" :key="irr.verb" class="irregular-row">
            <span class="irr-verb">{{ irr.verb }}</span>
            <span class="irr-meaning">{{ irr.meaning }}</span>
            <span class="irr-forms">{{ irr.forms }}</span>
          </div>
        </div>
      </section>
    </div>

    <!-- Contenu : Tableaux de conjugaison -->
    <div v-if="activeTab === 'verbes'" class="tab-content">
      <div class="conjugation-toolbar">
        <input
          v-model="verbSearch"
          type="text"
          class="verb-search-input"
          placeholder="Rechercher un verbe ou une traduction..."
        />
        <div class="verb-filter-chips">
          <button
            class="verb-filter-chip"
            :class="{ active: verbFilter === 'all' }"
            @click="verbFilter = 'all'"
          >
            Tous
          </button>
          <button
            class="verb-filter-chip"
            :class="{ active: verbFilter === 'aux' }"
            @click="verbFilter = 'aux'"
          >
            Auxiliaires / verbes clés
          </button>
          <button
            class="verb-filter-chip"
            :class="{ active: verbFilter === 'modal' }"
            @click="verbFilter = 'modal'"
          >
            Modaux
          </button>
          <button
            class="verb-filter-chip"
            :class="{ active: verbFilter === 'movement' }"
            @click="verbFilter = 'movement'"
          >
            Mouvement
          </button>
        </div>
      </div>

      <div class="conjugation-list">
        <div 
          v-for="conj in filteredConjugations" 
          :key="conj.id" 
          class="conjugation-card card"
          :class="{ expanded: expandedVerb === conj.id }"
        >
          <div class="verb-header" @click="toggleVerb(conj.id)">
            <h2 class="verb-name">{{ conj.verb }}</h2>
            <button 
              class="audio-btn-mini"
              @click.stop="speak(conj.verb, conj.id)"
              :class="{ playing: currentPlayingId === conj.id }"
              title="Écouter"
            >
              🔊
            </button>
            <span class="verb-tense">{{ conj.tense }}</span>
            <span class="verb-translation">{{ conj.translation }}</span>
            <div v-if="getVerbLabels(conj.verb).length" class="verb-labels">
              <span 
                v-for="label in getVerbLabels(conj.verb)" 
                :key="label" 
                class="verb-label-chip"
              >
                {{ label }}
              </span>
            </div>
            <span class="expand-icon">{{ expandedVerb === conj.id ? '▼' : '▶' }}</span>
          </div>
          
          <div v-show="expandedVerb === conj.id" class="verb-details">
            <p class="verb-description">{{ conj.content }}</p>
            
            <div class="conjugation-table">
              <div 
                v-for="(form, pronoun) in conj.conjugations" 
                :key="pronoun"
                class="conjugation-row"
              >
                <span class="pronoun">{{ pronoun }}</span>
                <span class="form">{{ form }}</span>
                <button 
                  class="audio-btn-tiny"
                  @click="speak(`${pronoun} ${form}`)"
                  title="Écouter"
                >
                  🔊
                </button>
              </div>
            </div>
            
            <div class="listen-all-btn-container">
              <button 
                class="listen-all-btn"
                @click="speakConjugation(conj.verb, conj.conjugations)"
              >
                🔊 Écouter toute la conjugaison
              </button>
            </div>
            
            <div v-if="conj.example" class="example">
              <strong>💡 Exemple :</strong> {{ conj.example }}
              <button 
                class="audio-btn-tiny"
                @click="speak(conj.example.split('(')[0].trim())"
                title="Écouter"
              >
                🔊
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="conjugations.length === 0" class="empty-state">
        <p>Aucune conjugaison disponible pour cette langue.</p>
      </div>
    </div>

    <!-- Contenu : Les temps -->
    <div v-if="activeTab === 'temps'" class="tab-content">
      <section class="tenses-section">
        <h2 class="section-title">⏰ Les temps verbaux</h2>
        <div class="tenses-grid">
          <div 
            v-for="tense in grammarContent.tenses" 
            :key="tense.name" 
            class="tense-card card"
            :class="{ selected: selectedTense === tense.name }"
            @click="selectedTense = selectedTense === tense.name ? null : tense.name"
          >
            <h3 class="tense-name">{{ tense.name }}</h3>
            <p class="tense-desc">{{ tense.description }}</p>
            <div class="tense-example">
              <span class="example-label">Exemple :</span>
              <span class="example-text">{{ tense.example }}</span>
            </div>
          </div>
        </div>
      </section>

      <section v-if="currentTenseInfo" class="tense-detail-section card">
        <h2 class="tense-detail-title">📌 {{ currentTenseInfo.title }}</h2>
        <p class="tense-detail-usage">{{ currentTenseInfo.usage }}</p>
        <p class="tense-detail-formation"><strong>Formation :</strong> {{ currentTenseInfo.formation }}</p>
        <div class="tense-detail-examples">
          <strong>Exemples :</strong>
          <ul>
            <li v-for="ex in currentTenseInfo.examples" :key="ex">{{ ex }}</li>
          </ul>
        </div>

        <div v-if="tenseExampleConjugations.length" class="tense-detail-conjugations">
          <h3>Exemples de conjugaisons</h3>
          <div class="tense-detail-conjugations-list">
            <div 
              v-for="conj in tenseExampleConjugations" 
              :key="conj.id" 
              class="tense-detail-conj-card"
            >
              <div class="tense-detail-conj-header">
                <span class="tense-detail-conj-verb">{{ conj.verb }}</span>
                <span class="tense-detail-conj-translation">{{ conj.translation }}</span>
              </div>
              <div class="tense-detail-conj-table">
                <div 
                  v-for="(form, pronoun) in conj.conjugations" 
                  :key="pronoun" 
                  class="tense-detail-conj-row"
                >
                  <span class="pronoun">{{ pronoun }}</span>
                  <span class="form">{{ form }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Conseils -->
      <section class="tips-section card">
        <h2>💡 Conseils pour apprendre la conjugaison</h2>
        <ul class="tips-list">
          <li><strong>Commencez par les auxiliaires</strong> : Ils sont utilisés partout et forment la base des temps composés.</li>
          <li><strong>Apprenez les terminaisons par groupe</strong> : Une fois maîtrisées, vous pourrez conjuguer la majorité des verbes.</li>
          <li><strong>Pratiquez avec des phrases</strong> : Conjuguer dans un contexte aide à mémoriser.</li>
          <li><strong>Identifiez les patterns</strong> : Les verbes irréguliers suivent souvent des schémas similaires.</li>
          <li><strong>Écoutez et répétez</strong> : La prononciation aide à ancrer les formes en mémoire.</li>
        </ul>
      </section>
    </div>

    <!-- Contenu : Mode Pratique -->
    <div v-if="activeTab === 'pratique'" class="tab-content">
      <!-- Stats -->
      <div class="practice-stats">
        <div class="stat-card">
          <span class="stat-value">{{ practiceScore }}</span>
          <span class="stat-label">Bonnes réponses</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ practiceTotal }}</span>
          <span class="stat-label">Questions</span>
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

      <!-- Mode selector -->
      <div class="mode-selector">
        <button 
          :class="['mode-btn', { active: practiceMode === 'choice' }]"
          @click="practiceMode = 'choice'"
        >
          🎯 Choix multiples
        </button>
        <button 
          :class="['mode-btn', { active: practiceMode === 'write' }]"
          @click="practiceMode = 'write'"
        >
          ✍️ Écriture
        </button>
      </div>

      <!-- Tense selector -->
      <div class="tense-selector">
        <span class="tense-selector-label">Temps :</span>
        <div class="tense-selector-buttons">
          <button
            class="tense-btn"
            :class="{ active: practiceSelectedTense === 'present' }"
            @click="practiceSelectedTense = 'present'"
          >
            {{ getPracticeTenseLabel('present') }}
          </button>
          <button
            class="tense-btn"
            :class="{ active: practiceSelectedTense === 'past' }"
            @click="practiceSelectedTense = 'past'"
          >
            {{ getPracticeTenseLabel('past') }}
          </button>
        </div>
      </div>

      <!-- Question Card -->
      <div v-if="currentPracticeVerb && practicePronoun" class="practice-card card">
        <div class="practice-question">
          <div class="verb-info">
            <span class="practice-verb">{{ currentPracticeVerb.infinitive }}</span>
            <span class="practice-translation">({{ currentPracticeVerb.translation }})</span>
            <button 
              class="audio-btn-small"
              @click="speak(currentPracticeVerb.infinitive, 'verb')"
              :class="{ playing: currentPlayingId === 'verb' }"
            >
              🔊
            </button>
          </div>
          <div class="practice-tense-badge">
            Temps pratiqué : {{ practiceTenseLabel }}
          </div>
          <div class="practice-prompt">
            Conjuguez à <strong>{{ practicePronoun }}</strong>
          </div>
        </div>

        <div v-if="practiceHelp" class="practice-help">
          <h4 class="practice-help-title">{{ practiceHelp.title }}</h4>
          <p class="practice-help-text">{{ practiceHelp.description }}</p>
          <p v-if="practiceHelp.tip" class="practice-help-tip">
            <strong>Astuce :</strong> {{ practiceHelp.tip }}
          </p>
        </div>

        <!-- Mode Choix multiples -->
        <div v-if="practiceMode === 'choice'" class="practice-choices">
          <button
            v-for="(choice, index) in practiceChoices"
            :key="index"
            class="choice-btn"
            :class="{
              correct: practiceResult && choice === correctAnswer,
              wrong: practiceResult === 'wrong' && choice !== correctAnswer,
              disabled: practiceResult !== null
            }"
            :disabled="practiceResult !== null"
            @click="checkAnswer(choice)"
          >
            {{ choice }}
            <button 
              v-if="practiceResult && choice === correctAnswer"
              class="audio-btn-inline"
              @click.stop="speak(choice)"
            >
              🔊
            </button>
          </button>
        </div>

        <!-- Mode Écriture -->
        <div v-else class="practice-write">
          <input
            v-model="practiceAnswer"
            type="text"
            class="write-input"
            placeholder="Tapez votre réponse..."
            :disabled="practiceResult !== null"
            @keyup.enter="submitWriteAnswer"
          />
          <button 
            class="submit-btn"
            :disabled="!practiceAnswer.trim() || practiceResult !== null"
            @click="submitWriteAnswer"
          >
            Valider
          </button>
        </div>

        <!-- Résultat -->
        <div v-if="practiceResult" class="practice-result" :class="practiceResult">
          <div v-if="practiceResult === 'correct'" class="result-message">
            ✅ Excellent ! 
            <span v-if="practiceStreak >= 3">🔥 Série de {{ practiceStreak }} !</span>
          </div>
          <div v-else class="result-message">
            ❌ La bonne réponse était : 
            <strong>{{ correctAnswer }}</strong>
            <button class="audio-btn-inline" @click="speak(correctAnswer)">🔊</button>
          </div>
          <button class="next-btn" @click="generateNewQuestion">
            Question suivante →
          </button>
        </div>
      </div>

      <!-- Liste des verbes pour référence -->
      <section class="practice-verbs-list">
        <h3>📖 Verbes disponibles</h3>
        <div class="verbs-grid">
          <div 
            v-for="verb in practiceVerbs" 
            :key="verb.infinitive" 
            class="verb-chip"
            @click="speakConjugation(verb.infinitive, verb.forms)"
          >
            <span class="verb-text">{{ verb.infinitive }}</span>
            <span class="verb-trans">{{ verb.translation }}</span>
            <span class="audio-icon">🔊</span>
          </div>
        </div>
      </section>

      <!-- Reset button -->
      <div class="practice-actions">
        <button class="reset-btn" @click="resetPractice">
          🔄 Recommencer
        </button>
      </div>
    </div>

    <!-- Contenu : Plus (Pronoms, Expressions, Prépositions) -->
    <div v-if="activeTab === 'plus'" class="tab-content">
      <!-- Pronoms -->
      <section class="pronouns-section">
        <h2 class="section-title">👤 {{ grammarContent.pronouns.title }}</h2>
        <div class="pronouns-grid">
          <div class="pronoun-card card">
            <h3>Pronoms sujets</h3>
            <div class="pronoun-list">
              <div v-for="p in grammarContent.pronouns.subject" :key="p.pronoun" class="pronoun-item">
                <span class="pronoun-native">{{ p.pronoun }}</span>
                <span class="pronoun-trans">{{ p.translation }}</span>
                <button class="audio-btn-tiny" @click="speak(p.pronoun)">🔊</button>
              </div>
            </div>
          </div>
          <div class="pronoun-card card">
            <h3>Pronoms COD</h3>
            <div class="pronoun-list">
              <div v-for="p in grammarContent.pronouns.direct" :key="p.pronoun" class="pronoun-item">
                <span class="pronoun-native">{{ p.pronoun }}</span>
                <span class="pronoun-trans">{{ p.translation }}</span>
                <button class="audio-btn-tiny" @click="speak(p.pronoun)">🔊</button>
              </div>
            </div>
          </div>
          <div class="pronoun-card card">
            <h3>Pronoms COI</h3>
            <div class="pronoun-list">
              <div v-for="p in grammarContent.pronouns.indirect" :key="p.pronoun" class="pronoun-item">
                <span class="pronoun-native">{{ p.pronoun }}</span>
                <span class="pronoun-trans">{{ p.translation }}</span>
                <button class="audio-btn-tiny" @click="speak(p.pronoun)">🔊</button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Expressions idiomatiques -->
      <section class="expressions-section">
        <h2 class="section-title">💬 Expressions idiomatiques</h2>
        <div class="expressions-grid">
          <div v-for="expr in grammarContent.expressions" :key="expr.phrase" class="expression-card card">
            <div class="expression-header">
              <span class="expression-phrase">{{ expr.phrase }}</span>
              <button class="audio-btn-mini" @click="speak(expr.phrase)">🔊</button>
            </div>
            <div class="expression-translation">{{ expr.translation }}</div>
            <div v-if="expr.literal" class="expression-literal">
              <em>Littéralement : {{ expr.literal }}</em>
            </div>
            <div v-if="'response' in expr && expr.response" class="expression-response">
              <strong>Réponse :</strong> {{ expr.response }}
            </div>
          </div>
        </div>
      </section>

      <!-- Prépositions -->
      <section class="prepositions-section">
        <h2 class="section-title">📍 Les prépositions essentielles</h2>
        <div class="prepositions-grid">
          <div v-for="prep in grammarContent.prepositions" :key="prep.prep" class="preposition-card card">
            <div class="prep-header">
              <span class="prep-word">{{ prep.prep }}</span>
              <button class="audio-btn-mini" @click="speak(prep.prep)">🔊</button>
            </div>
            <div class="prep-usage">{{ prep.usage }}</div>
            <div class="prep-examples">
              <div v-for="ex in prep.examples" :key="ex" class="prep-example">
                <span>{{ ex }}</span>
                <button class="audio-btn-tiny" @click="speak(ex)">🔊</button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Nombres -->
      <section class="numbers-section">
        <h2 class="section-title">🔢 Les nombres</h2>
        <div class="numbers-grid">
          <div 
            v-for="num in (learningStore.currentLanguage === 'it' 
              ? [{n: '0', w: 'zero'}, {n: '1', w: 'uno'}, {n: '2', w: 'due'}, {n: '3', w: 'tre'}, {n: '4', w: 'quattro'}, {n: '5', w: 'cinque'}, {n: '6', w: 'sei'}, {n: '7', w: 'sette'}, {n: '8', w: 'otto'}, {n: '9', w: 'nove'}, {n: '10', w: 'dieci'}, {n: '20', w: 'venti'}, {n: '30', w: 'trenta'}, {n: '100', w: 'cento'}, {n: '1000', w: 'mille'}]
              : [{n: '0', w: 'cero'}, {n: '1', w: 'uno'}, {n: '2', w: 'dos'}, {n: '3', w: 'tres'}, {n: '4', w: 'cuatro'}, {n: '5', w: 'cinco'}, {n: '6', w: 'seis'}, {n: '7', w: 'siete'}, {n: '8', w: 'ocho'}, {n: '9', w: 'nueve'}, {n: '10', w: 'diez'}, {n: '20', w: 'veinte'}, {n: '30', w: 'treinta'}, {n: '100', w: 'cien'}, {n: '1000', w: 'mil'}]
            )" 
            :key="num.n" 
            class="number-chip"
            @click="speak(num.w)"
          >
            <span class="number-digit">{{ num.n }}</span>
            <span class="number-word">{{ num.w }}</span>
            <span class="audio-icon">🔊</span>
          </div>
        </div>
      </section>

      <!-- Jours et Mois -->
      <section class="datetime-section">
        <h2 class="section-title">📅 Jours et Mois</h2>
        <div class="datetime-grid">
          <div class="datetime-card card">
            <h3>Jours de la semaine</h3>
            <div class="datetime-list">
              <div 
                v-for="day in (learningStore.currentLanguage === 'it' 
                  ? ['lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica']
                  : ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo']
                )" 
                :key="day" 
                class="datetime-item"
                @click="speak(day)"
              >
                <span>{{ day }}</span>
                <span class="audio-icon">🔊</span>
              </div>
            </div>
          </div>
          <div class="datetime-card card">
            <h3>Mois de l'année</h3>
            <div class="datetime-list months">
              <div 
                v-for="month in (learningStore.currentLanguage === 'it' 
                  ? ['gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', 'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre']
                  : ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre']
                )" 
                :key="month" 
                class="datetime-item"
                @click="speak(month)"
              >
                <span>{{ month }}</span>
                <span class="audio-icon">🔊</span>
              </div>
            </div>
          </div>
        </div>
      </section>
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
  font-size: 2rem;
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
  flex-wrap: wrap;
}

.tab-btn {
  padding: 0.75rem 1.25rem;
  border: none;
  background: #f0f0f0;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 500;
  transition: all 0.2s;
}

.tab-btn:hover {
  background: #e0e0e0;
}

.tab-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.tab-content {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Section titles */
.section-title {
  font-size: 1.4rem;
  color: #2c3e50;
  margin: 2rem 0 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #e0e0e0;
}

/* Introduction */
.intro-section {
  padding: 1.5rem;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8ec 100%);
  margin-bottom: 1.5rem;
}

.intro-section h2 {
  color: #2c3e50;
  margin-bottom: 0.75rem;
}

.intro-section p {
  color: #555;
  line-height: 1.6;
}

/* Groups grid */
.groups-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.group-card {
  padding: 1.5rem;
  border-left: 4px solid #3498db;
}

.group-card:nth-child(2) {
  border-left-color: #27ae60;
}

.group-card:nth-child(3) {
  border-left-color: #e74c3c;
}

.group-name {
  font-size: 1.2rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.group-desc {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 1rem;
}

.practice-tense-badge {
  font-size: 0.9rem;
  color: #667eea;
  margin-bottom: 0.5rem;
}

.examples-list {
  margin-bottom: 1rem;
}

.examples-list ul {
  margin: 0.5rem 0 0 1.25rem;
  padding: 0;
}

.examples-list li {
  color: #555;
  font-size: 0.9rem;
  margin-bottom: 0.25rem;
}

.endings-table, .model-conjugation {
  margin-top: 1rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.endings-table h4, .model-conjugation h4 {
  margin: 0 0 0.75rem;
  font-size: 0.95rem;
  color: #2c3e50;
}

.endings-grid, .conj-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem;
}

.ending-row, .conj-row {
  display: flex;
  justify-content: space-between;
  padding: 0.4rem 0.6rem;
  background: white;
  border-radius: 4px;
}

.ending {
  font-weight: 600;
  color: #3498db;
}

/* Auxiliaries */
.aux-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.aux-card {
  padding: 1.5rem;
}

.aux-name {
  font-size: 1.1rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.aux-usage {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 1rem;
  line-height: 1.5;
}

.aux-conjugation {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.4rem;
  margin-bottom: 1rem;
}

.aux-row {
  display: flex;
  justify-content: space-between;
  padding: 0.4rem 0.6rem;
  background: #f8f9fa;
  border-radius: 4px;
}

.aux-examples ul {
  margin: 0.5rem 0 0 1.25rem;
  padding: 0;
}

.aux-examples li {
  color: #555;
  font-size: 0.9rem;
  margin-bottom: 0.25rem;
}

/* SER vs ESTAR */
.ser-estar-section {
  padding: 1.5rem;
  margin-top: 1.5rem;
}

.ser-estar-section h2 {
  color: #2c3e50;
  margin-bottom: 1rem;
}

.ser-estar-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.ser-estar-card {
  padding: 1rem;
  border-radius: 8px;
  background: #f8f9fa;
}

.verb-title {
  font-size: 1.2rem;
  margin-bottom: 0.75rem;
  padding: 0.5rem;
  border-radius: 4px;
  text-align: center;
}

.verb-title.ser {
  background: #e8f4fc;
  color: #2980b9;
}

.verb-title.estar {
  background: #e8f8f5;
  color: #27ae60;
}

.use-cases {
  margin: 0 0 1rem 1.25rem;
  padding: 0;
}

.use-cases li {
  color: #555;
  font-size: 0.9rem;
  margin-bottom: 0.25rem;
}

.rule-examples {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.example-tag {
  background: white;
  padding: 0.35rem 0.75rem;
  border-radius: 20px;
  font-size: 0.85rem;
  color: #555;
  border: 1px solid #ddd;
}

/* Irregulars table */
.irregulars-table {
  padding: 1rem;
  overflow-x: auto;
}

.irregular-header {
  display: grid;
  grid-template-columns: 1fr 1fr 2fr;
  gap: 1rem;
  padding: 0.75rem;
  background: #2c3e50;
  color: white;
  border-radius: 8px 8px 0 0;
  font-weight: 500;
}

.irregular-row {
  display: grid;
  grid-template-columns: 1fr 1fr 2fr;
  gap: 1rem;
  padding: 0.75rem;
  border-bottom: 1px solid #eee;
}

.irregular-row:nth-child(even) {
  background: #f8f9fa;
}

.irr-verb {
  font-weight: 600;
  color: #2c3e50;
}

.irr-meaning {
  color: #666;
  font-style: italic;
}

.irr-forms {
  font-family: monospace;
  font-size: 0.9rem;
  color: #555;
}

/* Conjugation list */
.conjugation-list {
  display: grid;
  gap: 1rem;
}

.conjugation-toolbar {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.verb-search-input {
  padding: 0.6rem 0.8rem;
  border-radius: 8px;
  border: 1px solid #d0d7de;
  font-size: 0.95rem;
}

.verb-search-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.15);
}

.verb-filter-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.verb-filter-chip {
  padding: 0.3rem 0.75rem;
  border-radius: 999px;
  border: 1px solid #d0d7de;
  background: #f5f5f5;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s;
}

.verb-filter-chip.active {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.conjugation-card {
  padding: 1rem 1.5rem;
  cursor: pointer;
  transition: all 0.2s;
}

.conjugation-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.conjugation-card.expanded {
  border-left: 4px solid #3498db;
}

.verb-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.verb-name {
  font-size: 1.3rem;
  color: #2c3e50;
  margin: 0;
}

.verb-tense {
  background: #e8f4fc;
  color: #3498db;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.85rem;
}

.verb-translation {
  color: #7f8c8d;
  font-style: italic;
  flex: 1;
}

.verb-labels {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem;
}

.verb-label-chip {
  font-size: 0.75rem;
  padding: 0.15rem 0.5rem;
  border-radius: 999px;
  background: #ecf0ff;
  color: #3b4cab;
  border: 1px solid #c7cffd;
}

.expand-icon {
  color: #999;
  font-size: 0.8rem;
}

.verb-details {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #eee;
}

.verb-description {
  color: #666;
  margin-bottom: 1rem;
}

.conjugation-table {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.conjugation-row {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0.75rem;
  background: #f8f9fa;
  border-radius: 4px;
}

.pronoun {
  color: #7f8c8d;
}

.form {
  font-weight: 600;
  color: #2c3e50;
}

.example {
  padding: 0.75rem;
  background: #fff8e1;
  border-radius: 4px;
  color: #856404;
}

/* Tenses */
.tenses-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.tense-card {
  padding: 1.25rem;
  transition: transform 0.2s;
}

.tense-card:hover {
  transform: translateY(-2px);
}

.tense-card.selected {
  border: 2px solid #667eea;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
}

.tense-name {
  font-size: 1.1rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.tense-desc {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 0.75rem;
}

.tense-example {
  padding: 0.5rem;
  background: #f0f7ff;
  border-radius: 4px;
  font-size: 0.9rem;
}

.example-label {
  color: #666;
}

.example-text {
  color: #2980b9;
  font-weight: 500;
  margin-left: 0.25rem;
}

.tense-detail-section {
  margin-top: 1.5rem;
  padding: 1.5rem;
}

.tense-detail-title {
  margin: 0 0 0.75rem;
  font-size: 1.2rem;
  color: #2c3e50;
}

.tense-detail-usage {
  margin: 0 0 0.75rem;
  color: #555;
}

.tense-detail-formation {
  margin: 0 0 0.75rem;
  color: #444;
}

.tense-detail-examples ul {
  margin: 0.5rem 0 0 1.25rem;
  padding: 0;
}

.tense-detail-examples li {
  color: #555;
  margin-bottom: 0.25rem;
}

.tense-detail-conjugations {
  margin-top: 1.25rem;
}

.tense-detail-conjugations-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
  margin-top: 0.5rem;
}

.tense-detail-conj-card {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 0.75rem;
}

.tense-detail-conj-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 0.5rem;
}

.tense-detail-conj-verb {
  font-weight: 600;
  color: #2c3e50;
}

.tense-detail-conj-translation {
  font-size: 0.8rem;
  color: #7f8c8d;
}

.tense-detail-conj-table {
  display: grid;
  grid-template-columns: 1fr;
  gap: 0.25rem;
}

.tense-detail-conj-row {
  display: flex;
  justify-content: space-between;
  padding: 0.25rem 0.5rem;
  background: white;
  border-radius: 4px;
}

/* Tips */
.tips-section {
  padding: 1.5rem;
  margin-top: 2rem;
  background: linear-gradient(135deg, #fff9e6 0%, #fff3cd 100%);
}

.tips-section h2 {
  color: #856404;
  margin-bottom: 1rem;
}

.tips-list {
  margin: 0;
  padding-left: 1.5rem;
}

.tips-list li {
  color: #666;
  margin-bottom: 0.75rem;
  line-height: 1.5;
}

.tips-list strong {
  color: #2c3e50;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #7f8c8d;
}

/* Responsive */
@media (max-width: 768px) {
  .section-container {
    padding: 1.5rem 0.75rem;
  }
  
  .section-header h1 {
    font-size: 1.5rem;
  }
  
  .tabs {
    gap: 0.25rem;
  }
  
  .tab-btn {
    padding: 0.6rem 0.75rem;
    font-size: 0.85rem;
  }
  
  .groups-grid, .aux-grid, .tenses-grid {
    grid-template-columns: 1fr;
  }
  
  .endings-grid, .conj-grid, .aux-conjugation {
    grid-template-columns: 1fr;
  }
  
  .irregular-header, .irregular-row {
    grid-template-columns: 1fr;
    gap: 0.25rem;
  }
  
  .irregular-header span:last-child,
  .irregular-row span:last-child {
    font-size: 0.8rem;
  }
  
  .verb-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .conjugation-table {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .section-container {
    padding: 1rem 0.5rem;
  }
  
  .section-header h1 {
    font-size: 1.3rem;
  }
  
  .language-toggle {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .lang-btn {
    padding: 0.5rem 0.75rem;
    font-size: 0.85rem;
  }
  
  .tabs {
    flex-direction: column;
  }
  
  .tab-btn {
    width: 100%;
  }
  
  .group-card, .aux-card, .tense-card {
    padding: 1rem;
  }
  
  .ser-estar-grid {
    grid-template-columns: 1fr;
  }
}

/* ===== Practice Mode Styles ===== */
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

.mode-selector {
  display: flex;
  justify-content: center;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.mode-btn {
  padding: 0.75rem 1.5rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 25px;
  cursor: pointer;
  font-size: 0.95rem;
  transition: all 0.2s;
}

.mode-btn:hover {
  border-color: #667eea;
}

.mode-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
}

.practice-card {
  padding: 2rem;
  text-align: center;
  margin-bottom: 1.5rem;
}

.practice-help {
  margin: 0 auto 1.5rem;
  max-width: 520px;
  text-align: left;
  padding: 1rem 1.25rem;
  border-radius: 12px;
  background: #f5f7ff;
  border: 1px solid #d6dcff;
}

.practice-help-title {
  margin: 0 0 0.4rem;
  font-size: 1rem;
  color: #2c3e50;
}

.practice-help-text {
  margin: 0 0 0.4rem;
  font-size: 0.9rem;
  color: #555;
  line-height: 1.4;
}

.practice-help-tip {
  margin: 0;
  font-size: 0.9rem;
  color: #4a4a8a;
}

.practice-question {
  margin-bottom: 2rem;
}

.verb-info {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.practice-verb {
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
}

.practice-translation {
  font-size: 1.1rem;
  color: #7f8c8d;
  font-style: italic;
}

.audio-btn-small {
  background: #f0f0f0;
  border: none;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.audio-btn-small:hover {
  background: #e0e0e0;
  transform: scale(1.1);
}

.audio-btn-small.playing {
  background: #667eea;
  animation: pulse 1s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.practice-prompt {
  font-size: 1.2rem;
  color: #555;
}

.practice-prompt strong {
  color: #667eea;
  font-size: 1.4rem;
}

.practice-choices {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  max-width: 500px;
  margin: 0 auto;
}

.practice-choices .choice-btn {
  padding: 1rem 1.5rem;
  border: 2px solid #e0e0e0;
  background: white;
  border-radius: 12px;
  cursor: pointer;
  font-size: 1.1rem;
  font-weight: 500;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.practice-choices .choice-btn:hover:not(:disabled) {
  border-color: #667eea;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.practice-choices .choice-btn.correct {
  background: #d4edda;
  border-color: #28a745;
  color: #155724;
}

.practice-choices .choice-btn.wrong {
  opacity: 0.5;
}

.practice-choices .choice-btn.disabled {
  cursor: default;
}

.audio-btn-inline {
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 1rem;
  padding: 0.25rem;
}

.practice-write {
  display: flex;
  gap: 1rem;
  max-width: 400px;
  margin: 0 auto;
}

.write-input {
  flex: 1;
  padding: 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  font-size: 1.1rem;
  text-align: center;
}

.write-input:focus {
  outline: none;
  border-color: #667eea;
}

.submit-btn {
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.2s;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.submit-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
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

.result-message strong {
  color: #2c3e50;
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

.practice-verbs-list {
  margin-top: 2rem;
}

.practice-verbs-list h3 {
  color: #2c3e50;
  margin-bottom: 1rem;
}

.verbs-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.verb-chip {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 25px;
  cursor: pointer;
  transition: all 0.2s;
}

.verb-chip:hover {
  background: #f0f0f0;
  border-color: #667eea;
}

.verb-text {
  font-weight: 600;
  color: #2c3e50;
}

.verb-trans {
  font-size: 0.85rem;
  color: #7f8c8d;
}

.audio-icon {
  font-size: 0.9rem;
}

.practice-actions {
  text-align: center;
  margin-top: 1.5rem;
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

.practice-tab.active {
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%) !important;
}

/* Audio buttons for conjugation tables */
.audio-btn-mini {
  background: #f0f0f0;
  border: none;
  border-radius: 50%;
  width: 28px;
  height: 28px;
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.2s;
  flex-shrink: 0;
}

.audio-btn-mini:hover {
  background: #667eea;
  transform: scale(1.1);
}

.audio-btn-mini.playing {
  background: #667eea;
  animation: pulse 1s ease-in-out infinite;
}

.audio-btn-tiny {
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 0.75rem;
  padding: 0.2rem;
  opacity: 0.6;
  transition: all 0.2s;
}

.audio-btn-tiny:hover {
  opacity: 1;
  transform: scale(1.2);
}

.listen-all-btn-container {
  text-align: center;
  margin: 1rem 0;
}

.listen-all-btn {
  padding: 0.6rem 1.25rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 25px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
}

.listen-all-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.conjugation-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0.75rem;
  background: #f8f9fa;
  border-radius: 4px;
}

.example {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

/* Practice responsive */
@media (max-width: 768px) {
  .practice-stats {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .practice-choices {
    grid-template-columns: 1fr;
  }
  
  .practice-verb {
    font-size: 1.5rem;
  }
  
  .mode-selector {
    flex-direction: column;
  }
  
  .practice-write {
    flex-direction: column;
  }
}

@media (max-width: 480px) {
  .practice-stats {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.5rem;
  }
  
  .stat-card {
    padding: 0.75rem;
  }
  
  .stat-value {
    font-size: 1.2rem;
  }
  
  .practice-card {
    padding: 1.25rem;
  }
  
  .verb-info {
    flex-wrap: wrap;
  }
}

/* ===== Plus Tab Styles ===== */
.plus-tab.active {
  background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%) !important;
}

/* Pronouns */
.pronouns-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

.pronoun-card {
  padding: 1.25rem;
}

.pronoun-card h3 {
  color: #2c3e50;
  margin-bottom: 1rem;
  font-size: 1rem;
  border-bottom: 2px solid #667eea;
  padding-bottom: 0.5rem;
}

.pronoun-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.pronoun-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.4rem 0.6rem;
  background: #f8f9fa;
  border-radius: 6px;
}

.pronoun-native {
  font-weight: 600;
  color: #667eea;
  min-width: 60px;
}

.pronoun-trans {
  color: #666;
  flex: 1;
}

/* Expressions */
.expressions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1rem;
}

.expression-card {
  padding: 1.25rem;
  transition: transform 0.2s;
}

.expression-card:hover {
  transform: translateY(-3px);
}

.expression-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.expression-phrase {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
}

.expression-translation {
  color: #27ae60;
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.expression-literal {
  font-size: 0.85rem;
  color: #7f8c8d;
  margin-bottom: 0.25rem;
}

.expression-response {
  font-size: 0.9rem;
  color: #e74c3c;
  margin-top: 0.5rem;
  padding: 0.4rem 0.6rem;
  background: #ffeaea;
  border-radius: 4px;
}

/* Prepositions */
.prepositions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
}

.preposition-card {
  padding: 1rem;
}

.prep-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.prep-word {
  font-size: 1.5rem;
  font-weight: 700;
  color: #667eea;
}

.prep-usage {
  font-size: 0.85rem;
  color: #666;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #eee;
}

.prep-examples {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.prep-example {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 0.9rem;
  color: #555;
  padding: 0.3rem 0.5rem;
  background: #f8f9fa;
  border-radius: 4px;
}

/* Numbers */
.numbers-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  justify-content: center;
}

.number-chip {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1rem;
  background: white;
  border: 2px solid #e0e0e0;
  border-radius: 25px;
  cursor: pointer;
  transition: all 0.2s;
}

.number-chip:hover {
  border-color: #667eea;
  background: #f0f4ff;
  transform: translateY(-2px);
}

.number-digit {
  font-weight: 700;
  color: #667eea;
  font-size: 1.1rem;
}

.number-word {
  color: #555;
}

/* DateTime */
.datetime-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
}

.datetime-card {
  padding: 1.25rem;
}

.datetime-card h3 {
  color: #2c3e50;
  margin-bottom: 1rem;
  text-align: center;
}

.datetime-list {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.datetime-list.months {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.4rem;
}

.datetime-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 0.75rem;
  background: #f8f9fa;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.datetime-item:hover {
  background: #e8f4fc;
  transform: translateX(3px);
}

.datetime-item span:first-child {
  font-weight: 500;
  color: #2c3e50;
  text-transform: capitalize;
}

/* Plus tab responsive */
@media (max-width: 768px) {
  .pronouns-grid {
    grid-template-columns: 1fr;
  }
  
  .datetime-grid {
    grid-template-columns: 1fr;
  }
  
  .datetime-list.months {
    grid-template-columns: 1fr;
  }
  
  .expressions-grid, .prepositions-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .numbers-grid {
    gap: 0.5rem;
  }
  
  .number-chip {
    padding: 0.5rem 0.75rem;
    font-size: 0.9rem;
  }
  
  .expression-phrase {
    font-size: 1rem;
  }
  
  .prep-word {
    font-size: 1.2rem;
  }
}

</style>
