export interface QuizQuestion {
  id: string
  language: 'it' | 'es'
  category: 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics'
  subCategory: string
  difficulty: 'beginner' | 'intermediate' | 'advanced'
  type: 'choice' | 'write' | 'listen'
  prompt: string
  choices?: string[]
  correctIndex?: number
  correctAnswer?: string
  explanation?: string
  audio?: string
  audioText?: string // Texte à lire pour les questions listen
}

export const quizQuestions: QuizQuestion[] = [
  // ==================== ITALIEN ====================
  
  // --- VOCABULAIRE ITALIEN ---
  // Salutations (15 questions)
  { id: 'it-voc-1', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Bonjour" (formel) ?', choices: ['Ciao', 'Buongiorno', 'Arrivederci', 'Salve'], correctIndex: 1, explanation: 'Buongiorno est la forme formelle de bonjour.' },
  { id: 'it-voc-2', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Salut" (informel) ?', choices: ['Buongiorno', 'Ciao', 'Buonasera', 'Arrivederci'], correctIndex: 1, explanation: 'Ciao est informel, utilisé entre amis.' },
  { id: 'it-voc-3', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Bonsoir" ?', choices: ['Buongiorno', 'Buonanotte', 'Buonasera', 'Ciao'], correctIndex: 2, explanation: 'Buonasera = bonsoir, Buonanotte = bonne nuit.' },
  { id: 'it-voc-4', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Au revoir" (formel) ?', choices: ['Ciao', 'Addio', 'Arrivederci', 'A presto'], correctIndex: 2, explanation: 'Arrivederci est formel, Ciao est informel.' },
  { id: 'it-voc-5', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "Merci" en italien', correctAnswer: 'grazie', explanation: 'Grazie = merci.' },
  { id: 'it-voc-5b', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Bonne nuit" ?', choices: ['Buonasera', 'Buonanotte', 'Buongiorno', 'Addio'], correctIndex: 1 },
  { id: 'it-voc-5c', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "S\'il vous plaît" ?', choices: ['Grazie', 'Prego', 'Per favore', 'Scusi'], correctIndex: 2 },
  { id: 'it-voc-5d', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "De rien" ?', choices: ['Grazie', 'Prego', 'Scusa', 'Ciao'], correctIndex: 1 },
  { id: 'it-voc-5e', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Excusez-moi" (formel) ?', choices: ['Scusa', 'Scusi', 'Prego', 'Grazie'], correctIndex: 1 },
  { id: 'it-voc-5f', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "À bientôt" en italien', correctAnswer: 'a presto' },
  { id: 'it-voc-5g', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "Comment allez-vous ?" (formel) ?', choices: ['Come stai?', 'Come va?', 'Come sta?', 'Che fai?'], correctIndex: 2 },
  { id: 'it-voc-5h', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Comment ça va ?" (informel) ?', choices: ['Come sta?', 'Come stai?', 'Cosa fai?', 'Chi sei?'], correctIndex: 1 },
  { id: 'it-voc-5i', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Que signifie "Piacere" ?', choices: ['Plaisir', 'Enchanté', 'Merci', 'Pardon'], correctIndex: 1 },
  { id: 'it-voc-5j', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "Bienvenue" en italien', correctAnswer: 'benvenuto' },
  { id: 'it-voc-5k', language: 'it', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "Félicitations" ?', choices: ['Auguri', 'Complimenti', 'Bravo', 'Grazie'], correctIndex: 1 },
  
  // Nombres (20 questions)
  { id: 'it-voc-6', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "trois" ?', choices: ['due', 'tre', 'quattro', 'cinque'], correctIndex: 1 },
  { id: 'it-voc-7', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "dix" ?', choices: ['otto', 'nove', 'dieci', 'undici'], correctIndex: 2 },
  { id: 'it-voc-8', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "vingt" ?', choices: ['trenta', 'venti', 'quindici', 'dodici'], correctIndex: 1 },
  { id: 'it-voc-9', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "cent" en italien', correctAnswer: 'cento' },
  { id: 'it-voc-9a', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "un" ?', choices: ['uno', 'due', 'zero', 'tre'], correctIndex: 0 },
  { id: 'it-voc-9b', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "deux" ?', choices: ['uno', 'due', 'tre', 'quattro'], correctIndex: 1 },
  { id: 'it-voc-9c', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "quatre" ?', choices: ['tre', 'cinque', 'quattro', 'sei'], correctIndex: 2 },
  { id: 'it-voc-9d', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "cinq" ?', choices: ['quattro', 'cinque', 'sei', 'sette'], correctIndex: 1 },
  { id: 'it-voc-9e', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "six" ?', choices: ['cinque', 'sei', 'sette', 'otto'], correctIndex: 1 },
  { id: 'it-voc-9f', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "sept" ?', choices: ['sei', 'sette', 'otto', 'nove'], correctIndex: 1 },
  { id: 'it-voc-9g', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "huit" ?', choices: ['sette', 'otto', 'nove', 'dieci'], correctIndex: 1 },
  { id: 'it-voc-9h', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "neuf" ?', choices: ['otto', 'nove', 'dieci', 'undici'], correctIndex: 1 },
  { id: 'it-voc-9i', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "zéro" en italien', correctAnswer: 'zero' },
  { id: 'it-voc-9j', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "onze" ?', choices: ['dieci', 'undici', 'dodici', 'tredici'], correctIndex: 1 },
  { id: 'it-voc-9k', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "douze" ?', choices: ['undici', 'dodici', 'tredici', 'quattordici'], correctIndex: 1 },
  { id: 'it-voc-9l', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "quinze" ?', choices: ['tredici', 'quattordici', 'quindici', 'sedici'], correctIndex: 2 },
  { id: 'it-voc-9m', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "trente" ?', choices: ['venti', 'trenta', 'quaranta', 'cinquanta'], correctIndex: 1 },
  { id: 'it-voc-9n', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cinquante" ?', choices: ['quaranta', 'cinquanta', 'sessanta', 'settanta'], correctIndex: 1 },
  { id: 'it-voc-9o', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "mille" en italien', correctAnswer: 'mille' },
  { id: 'it-voc-9p', language: 'it', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "premier" ?', choices: ['primo', 'secondo', 'terzo', 'uno'], correctIndex: 0 },
  
  // Couleurs (15 questions)
  { id: 'it-voc-10', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "rouge" ?', choices: ['blu', 'verde', 'rosso', 'giallo'], correctIndex: 2 },
  { id: 'it-voc-11', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "bleu" ?', choices: ['blu', 'bianco', 'nero', 'rosa'], correctIndex: 0 },
  { id: 'it-voc-12', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "vert" ?', choices: ['giallo', 'arancione', 'verde', 'viola'], correctIndex: 2 },
  { id: 'it-voc-13', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "noir" en italien', correctAnswer: 'nero' },
  { id: 'it-voc-13a', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "blanc" ?', choices: ['nero', 'bianco', 'grigio', 'marrone'], correctIndex: 1 },
  { id: 'it-voc-13b', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "jaune" ?', choices: ['rosso', 'arancione', 'giallo', 'verde'], correctIndex: 2 },
  { id: 'it-voc-13c', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "orange" ?', choices: ['arancione', 'rosso', 'giallo', 'marrone'], correctIndex: 0 },
  { id: 'it-voc-13d', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "violet" ?', choices: ['rosa', 'viola', 'blu', 'azzurro'], correctIndex: 1 },
  { id: 'it-voc-13e', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "rose" ?', choices: ['viola', 'rosa', 'rosso', 'arancione'], correctIndex: 1 },
  { id: 'it-voc-13f', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "gris" ?', choices: ['nero', 'bianco', 'grigio', 'marrone'], correctIndex: 2 },
  { id: 'it-voc-13g', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "marron" ?', choices: ['nero', 'grigio', 'marrone', 'beige'], correctIndex: 2 },
  { id: 'it-voc-13h', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "bleu clair" en italien', correctAnswer: 'azzurro' },
  { id: 'it-voc-13i', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "doré" ?', choices: ['argentato', 'dorato', 'bronzato', 'colorato'], correctIndex: 1 },
  { id: 'it-voc-13j', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "argenté" ?', choices: ['dorato', 'argentato', 'grigio', 'bianco'], correctIndex: 1 },
  { id: 'it-voc-13k', language: 'it', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "vert foncé" en italien', correctAnswer: 'verde scuro' },
  
  // Famille (20 questions)
  { id: 'it-voc-14', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "mère" ?', choices: ['padre', 'madre', 'sorella', 'fratello'], correctIndex: 1 },
  { id: 'it-voc-15', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "frère" ?', choices: ['fratello', 'sorella', 'zio', 'nonno'], correctIndex: 0 },
  { id: 'it-voc-15a', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "père" ?', choices: ['madre', 'padre', 'figlio', 'figlia'], correctIndex: 1 },
  { id: 'it-voc-15b', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "fils" ?', choices: ['figlia', 'figlio', 'nipote', 'cugino'], correctIndex: 1 },
  { id: 'it-voc-15c', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "fille" (enfant) ?', choices: ['figlio', 'figlia', 'sorella', 'nipote'], correctIndex: 1 },
  { id: 'it-voc-15d', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "oncle" ?', choices: ['nonno', 'zio', 'cugino', 'nipote'], correctIndex: 1 },
  { id: 'it-voc-15e', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "tante" ?', choices: ['nonna', 'zia', 'cugina', 'nipote'], correctIndex: 1 },
  { id: 'it-voc-15f', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cousin" (masculin) ?', choices: ['cugino', 'cugina', 'nipote', 'zio'], correctIndex: 0 },
  { id: 'it-voc-15g', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cousine" ?', choices: ['cugino', 'cugina', 'nipote', 'zia'], correctIndex: 1 },
  { id: 'it-voc-15h', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "grand-mère" ?', choices: ['nonno', 'nonna', 'zia', 'madre'], correctIndex: 1 },
  { id: 'it-voc-15i', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "petit-fils" en italien', correctAnswer: 'nipote' },
  { id: 'it-voc-15j', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "mari" ?', choices: ['moglie', 'marito', 'fidanzato', 'amico'], correctIndex: 1 },
  { id: 'it-voc-15k', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "femme" (épouse) ?', choices: ['marito', 'moglie', 'fidanzata', 'amica'], correctIndex: 1 },
  { id: 'it-voc-15l', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "beau-père" ?', choices: ['suocero', 'patrigno', 'cognato', 'genero'], correctIndex: 0 },
  { id: 'it-voc-15m', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "belle-mère" ?', choices: ['suocera', 'matrigna', 'cognata', 'nuora'], correctIndex: 0 },
  { id: 'it-voc-15n', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "beau-frère" ?', choices: ['cognato', 'genero', 'suocero', 'nipote'], correctIndex: 0 },
  { id: 'it-voc-15o', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "belle-sœur" en italien', correctAnswer: 'cognata' },
  { id: 'it-voc-15p', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "parents" ?', choices: ['parenti', 'genitori', 'figli', 'nonni'], correctIndex: 1 },
  { id: 'it-voc-15q', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "enfants" ?', choices: ['genitori', 'figli', 'bambini', 'ragazzi'], correctIndex: 1 },
  { id: 'it-voc-15r', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "jumeaux" ?', choices: ['gemelli', 'fratelli', 'cugini', 'nipoti'], correctIndex: 0 },
  { id: 'it-voc-16', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "grand-père" ?', choices: ['nipote', 'nonno', 'zio', 'cugino'], correctIndex: 1 },
  { id: 'it-voc-17', language: 'it', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "sœur" en italien', correctAnswer: 'sorella' },
  
  // Nourriture (30 questions)
  { id: 'it-voc-18', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pain" ?', choices: ['pane', 'pasta', 'pizza', 'pesce'], correctIndex: 0 },
  { id: 'it-voc-19', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "eau" ?', choices: ['vino', 'latte', 'acqua', 'caffè'], correctIndex: 2 },
  { id: 'it-voc-20', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pomme" ?', choices: ['arancia', 'mela', 'banana', 'pera'], correctIndex: 1 },
  { id: 'it-voc-21', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "fromage" en italien', correctAnswer: 'formaggio' },
  { id: 'it-voc-21a', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "lait" ?', choices: ['acqua', 'latte', 'succo', 'tè'], correctIndex: 1 },
  { id: 'it-voc-21b', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "café" ?', choices: ['tè', 'caffè', 'latte', 'succo'], correctIndex: 1 },
  { id: 'it-voc-21c', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "vin" ?', choices: ['birra', 'vino', 'acqua', 'succo'], correctIndex: 1 },
  { id: 'it-voc-21d', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "bière" ?', choices: ['vino', 'birra', 'acqua', 'succo'], correctIndex: 1 },
  { id: 'it-voc-21e', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "viande" ?', choices: ['pesce', 'carne', 'pollo', 'maiale'], correctIndex: 1 },
  { id: 'it-voc-21f', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "poisson" ?', choices: ['carne', 'pesce', 'pollo', 'maiale'], correctIndex: 1 },
  { id: 'it-voc-21g', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "poulet" ?', choices: ['carne', 'pesce', 'pollo', 'maiale'], correctIndex: 2 },
  { id: 'it-voc-21h', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "porc" ?', choices: ['manzo', 'maiale', 'agnello', 'vitello'], correctIndex: 1 },
  { id: 'it-voc-21i', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "bœuf" ?', choices: ['manzo', 'maiale', 'agnello', 'vitello'], correctIndex: 0 },
  { id: 'it-voc-21j', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "œuf" ?', choices: ['uovo', 'latte', 'burro', 'formaggio'], correctIndex: 0 },
  { id: 'it-voc-21k', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "beurre" en italien', correctAnswer: 'burro' },
  { id: 'it-voc-21l', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "orange" (fruit) ?', choices: ['mela', 'arancia', 'banana', 'limone'], correctIndex: 1 },
  { id: 'it-voc-21m', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "banane" ?', choices: ['mela', 'arancia', 'banana', 'pera'], correctIndex: 2 },
  { id: 'it-voc-21n', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "citron" ?', choices: ['arancia', 'limone', 'pompelmo', 'lime'], correctIndex: 1 },
  { id: 'it-voc-21o', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "fraise" ?', choices: ['fragola', 'lampone', 'mirtillo', 'ciliegia'], correctIndex: 0 },
  { id: 'it-voc-21p', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "tomate" ?', choices: ['patata', 'pomodoro', 'carota', 'cipolla'], correctIndex: 1 },
  { id: 'it-voc-21q', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pomme de terre" ?', choices: ['pomodoro', 'patata', 'carota', 'cipolla'], correctIndex: 1 },
  { id: 'it-voc-21r', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "carotte" ?', choices: ['patata', 'pomodoro', 'carota', 'cipolla'], correctIndex: 2 },
  { id: 'it-voc-21s', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "oignon" ?', choices: ['aglio', 'cipolla', 'peperone', 'zucchina'], correctIndex: 1 },
  { id: 'it-voc-21t', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "ail" en italien', correctAnswer: 'aglio' },
  { id: 'it-voc-21u', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "riz" ?', choices: ['pasta', 'riso', 'pane', 'farina'], correctIndex: 1 },
  { id: 'it-voc-21v', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pâtes" ?', choices: ['riso', 'pasta', 'pane', 'pizza'], correctIndex: 1 },
  { id: 'it-voc-21w', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "sucre" ?', choices: ['sale', 'zucchero', 'pepe', 'olio'], correctIndex: 1 },
  { id: 'it-voc-21x', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "sel" ?', choices: ['zucchero', 'sale', 'pepe', 'olio'], correctIndex: 1 },
  { id: 'it-voc-21y', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "huile" en italien', correctAnswer: 'olio' },
  { id: 'it-voc-21z', language: 'it', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "vinaigre" ?', choices: ['olio', 'aceto', 'salsa', 'maionese'], correctIndex: 1 },
  
  // Corps (20 questions)
  { id: 'it-voc-22', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "tête" ?', choices: ['mano', 'testa', 'piede', 'braccio'], correctIndex: 1 },
  { id: 'it-voc-23', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "main" ?', choices: ['mano', 'gamba', 'occhio', 'orecchio'], correctIndex: 0 },
  { id: 'it-voc-24', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "œil" en italien', correctAnswer: 'occhio' },
  { id: 'it-voc-24a', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pied" ?', choices: ['mano', 'gamba', 'piede', 'braccio'], correctIndex: 2 },
  { id: 'it-voc-24b', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "jambe" ?', choices: ['braccio', 'gamba', 'mano', 'piede'], correctIndex: 1 },
  { id: 'it-voc-24c', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "bras" ?', choices: ['gamba', 'braccio', 'mano', 'spalla'], correctIndex: 1 },
  { id: 'it-voc-24d', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "nez" ?', choices: ['bocca', 'naso', 'orecchio', 'occhio'], correctIndex: 1 },
  { id: 'it-voc-24e', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "bouche" ?', choices: ['naso', 'bocca', 'lingua', 'dente'], correctIndex: 1 },
  { id: 'it-voc-24f', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "oreille" ?', choices: ['occhio', 'naso', 'orecchio', 'bocca'], correctIndex: 2 },
  { id: 'it-voc-24g', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "épaule" ?', choices: ['braccio', 'spalla', 'schiena', 'collo'], correctIndex: 1 },
  { id: 'it-voc-24h', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "dos" ?', choices: ['petto', 'schiena', 'pancia', 'collo'], correctIndex: 1 },
  { id: 'it-voc-24i', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cou" ?', choices: ['testa', 'collo', 'spalla', 'petto'], correctIndex: 1 },
  { id: 'it-voc-24j', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "ventre" en italien', correctAnswer: 'pancia' },
  { id: 'it-voc-24k', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "cheveux" ?', choices: ['capelli', 'occhi', 'denti', 'orecchie'], correctIndex: 0 },
  { id: 'it-voc-24l', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "doigt" ?', choices: ['mano', 'dito', 'unghia', 'polso'], correctIndex: 1 },
  { id: 'it-voc-24m', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "genou" ?', choices: ['gamba', 'piede', 'ginocchio', 'caviglia'], correctIndex: 2 },
  { id: 'it-voc-24n', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "coude" ?', choices: ['polso', 'gomito', 'spalla', 'braccio'], correctIndex: 1 },
  { id: 'it-voc-24o', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "poignet" en italien', correctAnswer: 'polso' },
  { id: 'it-voc-24p', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cœur" ?', choices: ['cuore', 'fegato', 'polmone', 'stomaco'], correctIndex: 0 },
  { id: 'it-voc-24q', language: 'it', category: 'vocabulary', subCategory: 'Corps', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "poumon" ?', choices: ['cuore', 'polmone', 'fegato', 'rene'], correctIndex: 1 },

  // Animaux (15 questions)
  { id: 'it-voc-ani1', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chien" ?', choices: ['gatto', 'cane', 'cavallo', 'uccello'], correctIndex: 1 },
  { id: 'it-voc-ani2', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chat" ?', choices: ['cane', 'gatto', 'topo', 'coniglio'], correctIndex: 1 },
  { id: 'it-voc-ani3', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "oiseau" ?', choices: ['pesce', 'uccello', 'farfalla', 'ape'], correctIndex: 1 },
  { id: 'it-voc-ani4', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "cheval" ?', choices: ['mucca', 'cavallo', 'asino', 'maiale'], correctIndex: 1 },
  { id: 'it-voc-ani5', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "vache" en italien', correctAnswer: 'mucca' },
  { id: 'it-voc-ani6', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "lapin" ?', choices: ['topo', 'coniglio', 'scoiattolo', 'riccio'], correctIndex: 1 },
  { id: 'it-voc-ani7', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "souris" ?', choices: ['ratto', 'topo', 'coniglio', 'talpa'], correctIndex: 1 },
  { id: 'it-voc-ani8', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "lion" ?', choices: ['tigre', 'leone', 'leopardo', 'ghepardo'], correctIndex: 1 },
  { id: 'it-voc-ani9', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "éléphant" ?', choices: ['giraffa', 'elefante', 'ippopotamo', 'rinoceronte'], correctIndex: 1 },
  { id: 'it-voc-ani10', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "serpent" en italien', correctAnswer: 'serpente' },
  { id: 'it-voc-ani11', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "papillon" ?', choices: ['ape', 'farfalla', 'mosca', 'zanzara'], correctIndex: 1 },
  { id: 'it-voc-ani12', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "abeille" ?', choices: ['vespa', 'ape', 'mosca', 'formica'], correctIndex: 1 },
  { id: 'it-voc-ani13', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "mouton" ?', choices: ['capra', 'pecora', 'agnello', 'montone'], correctIndex: 1 },
  { id: 'it-voc-ani14', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "loup" ?', choices: ['volpe', 'lupo', 'orso', 'cervo'], correctIndex: 1 },
  { id: 'it-voc-ani15', language: 'it', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "renard" en italien', correctAnswer: 'volpe' },

  // Vêtements (15 questions)
  { id: 'it-voc-vet1', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chemise" ?', choices: ['pantaloni', 'camicia', 'gonna', 'vestito'], correctIndex: 1 },
  { id: 'it-voc-vet2', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pantalon" ?', choices: ['camicia', 'pantaloni', 'gonna', 'jeans'], correctIndex: 1 },
  { id: 'it-voc-vet3', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "robe" ?', choices: ['gonna', 'vestito', 'camicia', 'maglietta'], correctIndex: 1 },
  { id: 'it-voc-vet4', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "jupe" ?', choices: ['vestito', 'gonna', 'pantaloni', 'shorts'], correctIndex: 1 },
  { id: 'it-voc-vet5', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "chaussures" en italien', correctAnswer: 'scarpe' },
  { id: 'it-voc-vet6', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "t-shirt" ?', choices: ['camicia', 'maglietta', 'maglione', 'giacca'], correctIndex: 1 },
  { id: 'it-voc-vet7', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "pull" ?', choices: ['maglietta', 'maglione', 'giacca', 'cappotto'], correctIndex: 1 },
  { id: 'it-voc-vet8', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "veste" ?', choices: ['maglione', 'giacca', 'cappotto', 'giubbotto'], correctIndex: 1 },
  { id: 'it-voc-vet9', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "manteau" ?', choices: ['giacca', 'cappotto', 'giubbotto', 'impermeabile'], correctIndex: 1 },
  { id: 'it-voc-vet10', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "chapeau" en italien', correctAnswer: 'cappello' },
  { id: 'it-voc-vet11', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chaussettes" ?', choices: ['scarpe', 'calzini', 'stivali', 'sandali'], correctIndex: 1 },
  { id: 'it-voc-vet12', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cravate" ?', choices: ['cintura', 'cravatta', 'sciarpa', 'foulard'], correctIndex: 1 },
  { id: 'it-voc-vet13', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "ceinture" ?', choices: ['cravatta', 'cintura', 'bretelle', 'fibbia'], correctIndex: 1 },
  { id: 'it-voc-vet14', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "écharpe" ?', choices: ['cravatta', 'foulard', 'sciarpa', 'guanti'], correctIndex: 2 },
  { id: 'it-voc-vet15', language: 'it', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "gants" en italien', correctAnswer: 'guanti' },

  // Maison (15 questions)
  { id: 'it-voc-mai1', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "maison" ?', choices: ['appartamento', 'casa', 'villa', 'palazzo'], correctIndex: 1 },
  { id: 'it-voc-mai2', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chambre" ?', choices: ['cucina', 'camera', 'bagno', 'salotto'], correctIndex: 1 },
  { id: 'it-voc-mai3', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "cuisine" ?', choices: ['camera', 'cucina', 'bagno', 'salotto'], correctIndex: 1 },
  { id: 'it-voc-mai4', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "salle de bain" ?', choices: ['cucina', 'camera', 'bagno', 'salotto'], correctIndex: 2 },
  { id: 'it-voc-mai5', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "salon" en italien', correctAnswer: 'salotto' },
  { id: 'it-voc-mai6', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "porte" ?', choices: ['finestra', 'porta', 'muro', 'tetto'], correctIndex: 1 },
  { id: 'it-voc-mai7', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "fenêtre" ?', choices: ['porta', 'finestra', 'balcone', 'terrazza'], correctIndex: 1 },
  { id: 'it-voc-mai8', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "escalier" ?', choices: ['ascensore', 'scala', 'corridoio', 'ingresso'], correctIndex: 1 },
  { id: 'it-voc-mai9', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "jardin" ?', choices: ['balcone', 'giardino', 'terrazza', 'cortile'], correctIndex: 1 },
  { id: 'it-voc-mai10', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "toit" en italien', correctAnswer: 'tetto' },
  { id: 'it-voc-mai11', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "lit" ?', choices: ['sedia', 'letto', 'tavolo', 'armadio'], correctIndex: 1 },
  { id: 'it-voc-mai12', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "table" ?', choices: ['sedia', 'letto', 'tavolo', 'divano'], correctIndex: 2 },
  { id: 'it-voc-mai13', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chaise" ?', choices: ['sedia', 'poltrona', 'divano', 'sgabello'], correctIndex: 0 },
  { id: 'it-voc-mai14', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "armoire" ?', choices: ['cassettiera', 'armadio', 'scaffale', 'comodino'], correctIndex: 1 },
  { id: 'it-voc-mai15', language: 'it', category: 'vocabulary', subCategory: 'Maison', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "canapé" en italien', correctAnswer: 'divano' },
  
  // --- GRAMMAIRE ITALIEN ---
  // Articles (20 questions)
  { id: 'it-gram-1', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'choice', prompt: 'Quel article pour "libro" (livre) ?', choices: ['la', 'il', 'lo', 'l\''], correctIndex: 1, explanation: 'Il devant consonne simple masculine.' },
  { id: 'it-gram-2', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'choice', prompt: 'Quel article pour "casa" (maison) ?', choices: ['il', 'lo', 'la', 'le'], correctIndex: 2, explanation: 'La devant nom féminin.' },
  { id: 'it-gram-3', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'intermediate', type: 'choice', prompt: 'Quel article pour "studente" (étudiant) ?', choices: ['il', 'lo', 'la', 'l\''], correctIndex: 1, explanation: 'Lo devant s + consonne.' },
  { id: 'it-gram-4', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'intermediate', type: 'choice', prompt: 'Quel article pour "amico" (ami) ?', choices: ['il', 'lo', 'la', 'l\''], correctIndex: 3, explanation: 'L\' devant voyelle.' },
  { id: 'it-gram-4a', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'choice', prompt: 'Quel article pour "ragazza" (fille) ?', choices: ['il', 'lo', 'la', 'le'], correctIndex: 2 },
  { id: 'it-gram-4b', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'choice', prompt: 'Quel article pour "ragazzo" (garçon) ?', choices: ['la', 'il', 'lo', 'i'], correctIndex: 1 },
  { id: 'it-gram-4c', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'intermediate', type: 'choice', prompt: 'Quel article pour "zaino" (sac à dos) ?', choices: ['il', 'lo', 'la', 'l\''], correctIndex: 1, explanation: 'Lo devant z.' },
  { id: 'it-gram-4d', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'intermediate', type: 'choice', prompt: 'Quel article pour "amica" (amie) ?', choices: ['il', 'lo', 'la', 'l\''], correctIndex: 3, explanation: 'L\' devant voyelle féminin.' },
  { id: 'it-gram-4e', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'choice', prompt: 'Quel article pluriel pour "libri" (livres) ?', choices: ['i', 'gli', 'le', 'la'], correctIndex: 0 },
  { id: 'it-gram-4f', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'choice', prompt: 'Quel article pluriel pour "case" (maisons) ?', choices: ['i', 'gli', 'le', 'la'], correctIndex: 2 },
  { id: 'it-gram-4g', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'intermediate', type: 'choice', prompt: 'Quel article pluriel pour "studenti" ?', choices: ['i', 'gli', 'le', 'lo'], correctIndex: 1, explanation: 'Gli devant s + consonne au pluriel.' },
  { id: 'it-gram-4h', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'intermediate', type: 'choice', prompt: 'Quel article pluriel pour "amici" ?', choices: ['i', 'gli', 'le', 'l\''], correctIndex: 1, explanation: 'Gli devant voyelle au pluriel.' },
  { id: 'it-gram-4i', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'advanced', type: 'choice', prompt: 'Quel article pour "psicologo" ?', choices: ['il', 'lo', 'la', 'l\''], correctIndex: 1, explanation: 'Lo devant ps.' },
  { id: 'it-gram-4j', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'advanced', type: 'choice', prompt: 'Quel article pour "gnomo" ?', choices: ['il', 'lo', 'la', 'l\''], correctIndex: 1, explanation: 'Lo devant gn.' },
  { id: 'it-gram-4k', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'write', prompt: 'Complétez: ___ pizza è buona', correctAnswer: 'la' },
  { id: 'it-gram-4l', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'write', prompt: 'Complétez: ___ vino è rosso', correctAnswer: 'il' },
  { id: 'it-gram-5', language: 'it', category: 'grammar', subCategory: 'Articles', difficulty: 'advanced', type: 'choice', prompt: 'Quel article pour "zio" (oncle) ?', choices: ['il', 'lo', 'la', 'l\''], correctIndex: 1, explanation: 'Lo devant z.' },
  
  // Pluriel
  { id: 'it-gram-6', language: 'it', category: 'grammar', subCategory: 'Pluriel', difficulty: 'beginner', type: 'choice', prompt: 'Quel est le pluriel de "libro" ?', choices: ['libri', 'libre', 'libros', 'libra'], correctIndex: 0, explanation: '-o devient -i au pluriel.' },
  { id: 'it-gram-7', language: 'it', category: 'grammar', subCategory: 'Pluriel', difficulty: 'beginner', type: 'choice', prompt: 'Quel est le pluriel de "casa" ?', choices: ['casi', 'case', 'casas', 'casa'], correctIndex: 1, explanation: '-a devient -e au pluriel.' },
  { id: 'it-gram-8', language: 'it', category: 'grammar', subCategory: 'Pluriel', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez le pluriel de "amico"', correctAnswer: 'amici', explanation: '-co devient -ci.' },
  
  // Négation
  { id: 'it-gram-9', language: 'it', category: 'grammar', subCategory: 'Négation', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je ne parle pas" ?', choices: ['Io parlo non', 'Io non parlo', 'Non io parlo', 'Parlo non io'], correctIndex: 1, explanation: 'Non se place avant le verbe.' },
  { id: 'it-gram-10', language: 'it', category: 'grammar', subCategory: 'Négation', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "Je n\'ai rien" ?', choices: ['Non ho niente', 'Ho non niente', 'Niente ho non', 'Non niente ho'], correctIndex: 0 },
  
  // Possessifs
  { id: 'it-gram-11', language: 'it', category: 'grammar', subCategory: 'Possessifs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "mon livre" ?', choices: ['mio libro', 'il mio libro', 'libro mio', 'mia libro'], correctIndex: 1, explanation: 'Article + possessif + nom.' },
  { id: 'it-gram-12', language: 'it', category: 'grammar', subCategory: 'Possessifs', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "ma mère" ?', choices: ['la mia madre', 'mia madre', 'madre mia', 'il mio madre'], correctIndex: 1, explanation: 'Pas d\'article avec les membres de la famille au singulier.' },
  
  // --- CONJUGAISON ITALIEN ---
  // Essere
  { id: 'it-conj-1', language: 'it', category: 'conjugation', subCategory: 'Essere', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je suis" ?', choices: ['Io ho', 'Io sono', 'Io sto', 'Io faccio'], correctIndex: 1 },
  { id: 'it-conj-2', language: 'it', category: 'conjugation', subCategory: 'Essere', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Tu es" ?', choices: ['Tu sei', 'Tu è', 'Tu sono', 'Tu siamo'], correctIndex: 0 },
  { id: 'it-conj-3', language: 'it', category: 'conjugation', subCategory: 'Essere', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Il/Elle est" ?', choices: ['Lui sei', 'Lei sono', 'Lui/Lei è', 'Loro è'], correctIndex: 2 },
  { id: 'it-conj-4', language: 'it', category: 'conjugation', subCategory: 'Essere', difficulty: 'intermediate', type: 'write', prompt: 'Conjuguez "essere" à "noi"', correctAnswer: 'siamo' },
  
  // Avere
  { id: 'it-conj-5', language: 'it', category: 'conjugation', subCategory: 'Avere', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "J\'ai" ?', choices: ['Io sono', 'Io ho', 'Io faccio', 'Io vado'], correctIndex: 1 },
  { id: 'it-conj-6', language: 'it', category: 'conjugation', subCategory: 'Avere', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Nous avons" ?', choices: ['Noi abbiamo', 'Noi avete', 'Noi hanno', 'Noi ho'], correctIndex: 0 },
  { id: 'it-conj-7', language: 'it', category: 'conjugation', subCategory: 'Avere', difficulty: 'intermediate', type: 'write', prompt: 'Conjuguez "avere" à "loro"', correctAnswer: 'hanno' },
  
  // Verbes réguliers -are
  { id: 'it-conj-8', language: 'it', category: 'conjugation', subCategory: 'Verbes -are', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je parle" (parlare) ?', choices: ['Io parlo', 'Io parli', 'Io parla', 'Io parlare'], correctIndex: 0 },
  { id: 'it-conj-9', language: 'it', category: 'conjugation', subCategory: 'Verbes -are', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Tu manges" (mangiare) ?', choices: ['Tu mangio', 'Tu mangi', 'Tu mangia', 'Tu mangiate'], correctIndex: 1 },
  { id: 'it-conj-10', language: 'it', category: 'conjugation', subCategory: 'Verbes -are', difficulty: 'intermediate', type: 'write', prompt: 'Conjuguez "amare" (aimer) à "lui"', correctAnswer: 'ama' },
  
  // Verbes réguliers -ere
  { id: 'it-conj-11', language: 'it', category: 'conjugation', subCategory: 'Verbes -ere', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je lis" (leggere) ?', choices: ['Io leggo', 'Io leggi', 'Io legge', 'Io leggere'], correctIndex: 0 },
  { id: 'it-conj-12', language: 'it', category: 'conjugation', subCategory: 'Verbes -ere', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "Ils écrivent" (scrivere) ?', choices: ['Loro scrivo', 'Loro scrive', 'Loro scrivono', 'Loro scrivete'], correctIndex: 2 },
  
  // Verbes réguliers -ire
  { id: 'it-conj-13', language: 'it', category: 'conjugation', subCategory: 'Verbes -ire', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je dors" (dormire) ?', choices: ['Io dormo', 'Io dormi', 'Io dorme', 'Io dormire'], correctIndex: 0 },
  { id: 'it-conj-14', language: 'it', category: 'conjugation', subCategory: 'Verbes -ire', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "Je finis" (finire) ?', choices: ['Io fino', 'Io finisco', 'Io finisce', 'Io fini'], correctIndex: 1, explanation: 'Finire prend -isc- aux personnes du singulier et 3e pluriel.' },
  
  // --- PHONÉTIQUE ITALIEN ---
  { id: 'it-phon-1', language: 'it', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'beginner', type: 'choice', prompt: 'Comment se prononce "gn" en italien ?', choices: ['Comme "gn" français', 'Comme "n"', 'Comme "g"', 'Comme "ny"'], correctIndex: 0, explanation: 'gn = ɲ comme dans "montagne".' },
  { id: 'it-phon-2', language: 'it', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'beginner', type: 'choice', prompt: 'Comment se prononce "gli" ?', choices: ['Comme "gli" français', 'Comme "li"', 'Comme "lli" mouillé', 'Comme "yi"'], correctIndex: 2, explanation: 'gli = ʎ son mouillé.' },
  { id: 'it-phon-3', language: 'it', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'intermediate', type: 'choice', prompt: 'Comment se prononce "ch" devant e/i ?', choices: ['Comme "ch" français', 'Comme "k"', 'Comme "tch"', 'Comme "sh"'], correctIndex: 1, explanation: 'ch = k devant e/i.' },
  { id: 'it-phon-4', language: 'it', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'intermediate', type: 'choice', prompt: 'Comment se prononce "c" devant e/i ?', choices: ['Comme "k"', 'Comme "s"', 'Comme "tch"', 'Comme "ch"'], correctIndex: 2, explanation: 'c = tʃ devant e/i.' },
  { id: 'it-phon-5', language: 'it', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'advanced', type: 'choice', prompt: 'Comment se prononce "sc" devant e/i ?', choices: ['Comme "sk"', 'Comme "ch" français', 'Comme "s"', 'Comme "sch"'], correctIndex: 1, explanation: 'sc = ʃ devant e/i.' },

  // Questions d'écoute italien (listen)
  { id: 'it-listen-1', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'beginner', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Buongiorno, come stai?', choices: ['Buongiorno, come stai?', 'Buonasera, come sta?', 'Buonanotte, come vai?', 'Buongiorno, cosa fai?'], correctIndex: 0 },
  { id: 'it-listen-2', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'beginner', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Mi chiamo Marco', choices: ['Mi chiamo Marco', 'Ti chiami Marco', 'Si chiama Marco', 'Ci chiamiamo Marco'], correctIndex: 0 },
  { id: 'it-listen-3', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'beginner', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Grazie mille', choices: ['Grazie tante', 'Grazie mille', 'Prego mille', 'Scusa mille'], correctIndex: 1 },
  { id: 'it-listen-4', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'intermediate', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Vorrei un caffè, per favore', choices: ['Vorrei un tè, per favore', 'Voglio un caffè, per favore', 'Vorrei un caffè, per favore', 'Vorrei un latte, per favore'], correctIndex: 2 },
  { id: 'it-listen-5', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'intermediate', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Quanto costa questo?', choices: ['Quanto costa quello?', 'Quanto costa questo?', 'Quando costa questo?', 'Quanto costano questi?'], correctIndex: 1 },
  { id: 'it-listen-6', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'intermediate', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Dove si trova la stazione?', choices: ['Dove si trova la stazione?', 'Dove si trova la fermata?', 'Come si trova la stazione?', 'Dove sta la stazione?'], correctIndex: 0 },
  { id: 'it-listen-7', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'advanced', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Potrebbe ripetere, per cortesia?', choices: ['Potrebbe ripetere, per favore?', 'Potrebbe ripetere, per cortesia?', 'Può ripetere, per cortesia?', 'Potrei ripetere, per cortesia?'], correctIndex: 1 },
  { id: 'it-listen-8', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'advanced', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Non ho capito, può parlare più lentamente?', choices: ['Non ho capito, può parlare più velocemente?', 'Non ho sentito, può parlare più lentamente?', 'Non ho capito, può parlare più lentamente?', 'Non ho capito, puoi parlare più lentamente?'], correctIndex: 2 },
  { id: 'it-listen-9', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'beginner', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Piacere di conoscerti', choices: ['Piacere di conoscerti', 'Piacere di conoscerla', 'Piacere di vederti', 'Piacere di incontrarti'], correctIndex: 0 },
  { id: 'it-listen-10', language: 'it', category: 'phonetics', subCategory: 'Écoute', difficulty: 'intermediate', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Che ore sono?', choices: ['Che ora è?', 'Che ore sono?', 'Quante ore sono?', 'A che ora?'], correctIndex: 1 },

  // ==================== ESPAGNOL ====================
  
  // --- VOCABULAIRE ESPAGNOL ---
  // Salutations
  { id: 'es-voc-1', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Bonjour" (matin) ?', choices: ['Hola', 'Buenos días', 'Buenas tardes', 'Buenas noches'], correctIndex: 1 },
  { id: 'es-voc-2', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Salut" ?', choices: ['Buenos días', 'Hola', 'Adiós', 'Gracias'], correctIndex: 1 },
  { id: 'es-voc-3', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Au revoir" ?', choices: ['Hola', 'Hasta luego', 'Adiós', 'Gracias'], correctIndex: 2 },
  { id: 'es-voc-4', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "Merci" en espagnol', correctAnswer: 'gracias' },
  { id: 'es-voc-5', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "S\'il vous plaît" ?', choices: ['Gracias', 'De nada', 'Por favor', 'Perdón'], correctIndex: 2 },
  
  // Nombres
  { id: 'es-voc-6', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "cinq" ?', choices: ['cuatro', 'cinco', 'seis', 'siete'], correctIndex: 1 },
  { id: 'es-voc-7', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "dix" ?', choices: ['nueve', 'diez', 'once', 'doce'], correctIndex: 1 },
  { id: 'es-voc-8', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "vingt" en espagnol', correctAnswer: 'veinte' },
  
  // Couleurs
  { id: 'es-voc-9', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "rouge" ?', choices: ['azul', 'verde', 'rojo', 'amarillo'], correctIndex: 2 },
  { id: 'es-voc-10', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "blanc" ?', choices: ['negro', 'blanco', 'gris', 'marrón'], correctIndex: 1 },
  { id: 'es-voc-11', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "bleu" en espagnol', correctAnswer: 'azul' },
  
  // Famille
  { id: 'es-voc-12', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "père" ?', choices: ['madre', 'padre', 'hermano', 'hijo'], correctIndex: 1 },
  { id: 'es-voc-13', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "sœur" ?', choices: ['hermano', 'hermana', 'prima', 'tía'], correctIndex: 1 },
  { id: 'es-voc-14', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "grand-mère" en espagnol', correctAnswer: 'abuela' },
  
  // Nourriture
  { id: 'es-voc-15', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "eau" ?', choices: ['leche', 'agua', 'vino', 'café'], correctIndex: 1 },
  { id: 'es-voc-16', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pain" ?', choices: ['pan', 'carne', 'pescado', 'arroz'], correctIndex: 0 },
  { id: 'es-voc-17', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "poulet" en espagnol', correctAnswer: 'pollo' },
  
  // Corps
  { id: 'es-voc-18', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "tête" ?', choices: ['mano', 'cabeza', 'pie', 'brazo'], correctIndex: 1 },
  { id: 'es-voc-19', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "œil" ?', choices: ['oreja', 'nariz', 'ojo', 'boca'], correctIndex: 2 },
  { id: 'es-voc-20', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "main" en espagnol', correctAnswer: 'mano' },
  
  // --- GRAMMAIRE ESPAGNOL ---
  // Articles
  { id: 'es-gram-1', language: 'es', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'choice', prompt: 'Quel article pour "libro" (livre) ?', choices: ['la', 'el', 'los', 'las'], correctIndex: 1 },
  { id: 'es-gram-2', language: 'es', category: 'grammar', subCategory: 'Articles', difficulty: 'beginner', type: 'choice', prompt: 'Quel article pour "casa" (maison) ?', choices: ['el', 'la', 'los', 'un'], correctIndex: 1 },
  { id: 'es-gram-3', language: 'es', category: 'grammar', subCategory: 'Articles', difficulty: 'intermediate', type: 'choice', prompt: 'Quel article pour "agua" (eau) ?', choices: ['la', 'el', 'los', 'las'], correctIndex: 1, explanation: 'El agua - article masculin devant a- tonique féminin.' },
  
  // Ser vs Estar
  { id: 'es-gram-4', language: 'es', category: 'grammar', subCategory: 'Ser vs Estar', difficulty: 'beginner', type: 'choice', prompt: '"Je suis français" - Ser ou Estar ?', choices: ['Soy francés', 'Estoy francés', 'Tengo francés', 'Hago francés'], correctIndex: 0, explanation: 'Ser pour nationalité/identité permanente.' },
  { id: 'es-gram-5', language: 'es', category: 'grammar', subCategory: 'Ser vs Estar', difficulty: 'beginner', type: 'choice', prompt: '"Je suis fatigué" - Ser ou Estar ?', choices: ['Soy cansado', 'Estoy cansado', 'Tengo cansado', 'Hago cansado'], correctIndex: 1, explanation: 'Estar pour état temporaire.' },
  { id: 'es-gram-6', language: 'es', category: 'grammar', subCategory: 'Ser vs Estar', difficulty: 'intermediate', type: 'choice', prompt: '"La pomme est verte" (couleur naturelle) ?', choices: ['La manzana es verde', 'La manzana está verde', 'La manzana tiene verde', 'La manzana hace verde'], correctIndex: 0, explanation: 'Ser pour caractéristique inhérente.' },
  { id: 'es-gram-7', language: 'es', category: 'grammar', subCategory: 'Ser vs Estar', difficulty: 'advanced', type: 'choice', prompt: '"La pomme est verte" (pas mûre) ?', choices: ['La manzana es verde', 'La manzana está verde', 'La manzana tiene verde', 'La manzana hace verde'], correctIndex: 1, explanation: 'Estar pour état résultant/temporaire.' },
  
  // Négation
  { id: 'es-gram-8', language: 'es', category: 'grammar', subCategory: 'Négation', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je ne parle pas" ?', choices: ['Yo hablo no', 'Yo no hablo', 'No yo hablo', 'Hablo no yo'], correctIndex: 1 },
  { id: 'es-gram-9', language: 'es', category: 'grammar', subCategory: 'Négation', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "Je n\'ai rien" ?', choices: ['No tengo nada', 'Tengo no nada', 'Nada tengo no', 'No nada tengo'], correctIndex: 0 },
  
  // Possessifs
  { id: 'es-gram-10', language: 'es', category: 'grammar', subCategory: 'Possessifs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "mon livre" ?', choices: ['el mi libro', 'mi libro', 'libro mi', 'mío libro'], correctIndex: 1 },
  { id: 'es-gram-11', language: 'es', category: 'grammar', subCategory: 'Possessifs', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "mes amis" ?', choices: ['mi amigos', 'mis amigos', 'mío amigos', 'los mi amigos'], correctIndex: 1 },
  
  // --- CONJUGAISON ESPAGNOL ---
  // Ser
  { id: 'es-conj-1', language: 'es', category: 'conjugation', subCategory: 'Ser', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je suis" (ser) ?', choices: ['Yo estoy', 'Yo soy', 'Yo tengo', 'Yo hago'], correctIndex: 1 },
  { id: 'es-conj-2', language: 'es', category: 'conjugation', subCategory: 'Ser', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Tu es" (ser) ?', choices: ['Tú eres', 'Tú es', 'Tú soy', 'Tú somos'], correctIndex: 0 },
  { id: 'es-conj-3', language: 'es', category: 'conjugation', subCategory: 'Ser', difficulty: 'intermediate', type: 'write', prompt: 'Conjuguez "ser" à "nosotros"', correctAnswer: 'somos' },
  
  // Estar
  { id: 'es-conj-4', language: 'es', category: 'conjugation', subCategory: 'Estar', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je suis" (estar) ?', choices: ['Yo soy', 'Yo estoy', 'Yo tengo', 'Yo hago'], correctIndex: 1 },
  { id: 'es-conj-5', language: 'es', category: 'conjugation', subCategory: 'Estar', difficulty: 'intermediate', type: 'write', prompt: 'Conjuguez "estar" à "ellos"', correctAnswer: 'están' },
  
  // Tener
  { id: 'es-conj-6', language: 'es', category: 'conjugation', subCategory: 'Tener', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "J\'ai" ?', choices: ['Yo soy', 'Yo estoy', 'Yo tengo', 'Yo hago'], correctIndex: 2 },
  { id: 'es-conj-7', language: 'es', category: 'conjugation', subCategory: 'Tener', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Il/Elle a" ?', choices: ['Él tiene', 'Él tienes', 'Él tengo', 'Él tenemos'], correctIndex: 0 },
  { id: 'es-conj-8', language: 'es', category: 'conjugation', subCategory: 'Tener', difficulty: 'intermediate', type: 'write', prompt: 'Conjuguez "tener" à "vosotros"', correctAnswer: 'tenéis' },
  
  // Verbes réguliers -ar
  { id: 'es-conj-9', language: 'es', category: 'conjugation', subCategory: 'Verbes -ar', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je parle" (hablar) ?', choices: ['Yo hablo', 'Yo hablas', 'Yo habla', 'Yo hablar'], correctIndex: 0 },
  { id: 'es-conj-10', language: 'es', category: 'conjugation', subCategory: 'Verbes -ar', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Nous travaillons" (trabajar) ?', choices: ['Nosotros trabajo', 'Nosotros trabajas', 'Nosotros trabajamos', 'Nosotros trabajan'], correctIndex: 2 },
  { id: 'es-conj-11', language: 'es', category: 'conjugation', subCategory: 'Verbes -ar', difficulty: 'intermediate', type: 'write', prompt: 'Conjuguez "cantar" (chanter) à "ellos"', correctAnswer: 'cantan' },
  
  // Verbes réguliers -er
  { id: 'es-conj-12', language: 'es', category: 'conjugation', subCategory: 'Verbes -er', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je mange" (comer) ?', choices: ['Yo como', 'Yo comes', 'Yo come', 'Yo comer'], correctIndex: 0 },
  { id: 'es-conj-13', language: 'es', category: 'conjugation', subCategory: 'Verbes -er', difficulty: 'intermediate', type: 'write', prompt: 'Conjuguez "beber" (boire) à "tú"', correctAnswer: 'bebes' },
  
  // Verbes réguliers -ir
  { id: 'es-conj-14', language: 'es', category: 'conjugation', subCategory: 'Verbes -ir', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Je vis" (vivir) ?', choices: ['Yo vivo', 'Yo vives', 'Yo vive', 'Yo vivir'], correctIndex: 0 },
  { id: 'es-conj-15', language: 'es', category: 'conjugation', subCategory: 'Verbes -ir', difficulty: 'intermediate', type: 'write', prompt: 'Conjuguez "escribir" (écrire) à "nosotros"', correctAnswer: 'escribimos' },
  
  // --- PHONÉTIQUE ESPAGNOL ---
  { id: 'es-phon-1', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'beginner', type: 'choice', prompt: 'Comment se prononce "j" en espagnol ?', choices: ['Comme "j" français', 'Comme "r" raclé', 'Comme "y"', 'Comme "ch"'], correctIndex: 1, explanation: 'j = son guttural comme "jota".' },
  { id: 'es-phon-2', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'beginner', type: 'choice', prompt: 'Comment se prononce "ll" ?', choices: ['Comme "l"', 'Comme "y"', 'Comme "li"', 'Comme "ch"'], correctIndex: 1, explanation: 'll = y dans la plupart des régions.' },
  { id: 'es-phon-3', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'intermediate', type: 'choice', prompt: 'Comment se prononce "ñ" ?', choices: ['Comme "n"', 'Comme "gn" français', 'Comme "ny"', 'Comme "ni"'], correctIndex: 1, explanation: 'ñ = ɲ comme dans "montagne".' },
  { id: 'es-phon-4', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'intermediate', type: 'choice', prompt: 'Comment se prononce "z" en Espagne ?', choices: ['Comme "s"', 'Comme "th" anglais', 'Comme "z" français', 'Comme "ts"'], correctIndex: 1, explanation: 'z = θ (th) en Espagne, s en Amérique latine.' },
  { id: 'es-phon-5', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'advanced', type: 'choice', prompt: 'Comment se prononce "rr" ?', choices: ['Comme "r" français', 'Roulé fortement', 'Comme "l"', 'Comme "r" anglais'], correctIndex: 1, explanation: 'rr = r roulé multiple.' },
  { id: 'es-phon-6', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'beginner', type: 'choice', prompt: 'Comment se prononce "h" en espagnol ?', choices: ['Comme "h" aspiré', 'Muet', 'Comme "j"', 'Comme "r"'], correctIndex: 1, explanation: 'h est toujours muet en espagnol.' },
  { id: 'es-phon-7', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'intermediate', type: 'choice', prompt: 'Comment se prononce "c" devant e/i ?', choices: ['Comme "k"', 'Comme "s" ou "th"', 'Comme "ch"', 'Comme "g"'], correctIndex: 1, explanation: 'c = s (Amérique) ou th (Espagne) devant e/i.' },
  { id: 'es-phon-8', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'intermediate', type: 'choice', prompt: 'Comment se prononce "g" devant e/i ?', choices: ['Comme "g" dur', 'Comme "j" espagnol', 'Comme "gu"', 'Comme "y"'], correctIndex: 1, explanation: 'g = j (son guttural) devant e/i.' },
  { id: 'es-phon-9', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'advanced', type: 'choice', prompt: 'Comment se prononce "qu" ?', choices: ['Comme "ku"', 'Comme "k"', 'Comme "kw"', 'Comme "gw"'], correctIndex: 1, explanation: 'qu = k, le u est muet.' },
  { id: 'es-phon-10', language: 'es', category: 'phonetics', subCategory: 'Prononciation', difficulty: 'advanced', type: 'choice', prompt: 'Comment se prononce "güe/güi" ?', choices: ['Comme "ge/gi"', 'Comme "gwe/gwi"', 'Comme "we/wi"', 'Comme "ue/ui"'], correctIndex: 1, explanation: 'Le tréma indique que le u se prononce.' },

  // Questions d'écoute espagnol (listen)
  { id: 'es-listen-1', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'beginner', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Buenos días, ¿cómo estás?', choices: ['Buenos días, ¿cómo estás?', 'Buenas tardes, ¿cómo está?', 'Buenas noches, ¿cómo vas?', 'Buenos días, ¿qué haces?'], correctIndex: 0 },
  { id: 'es-listen-2', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'beginner', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Me llamo María', choices: ['Me llamo María', 'Te llamas María', 'Se llama María', 'Nos llamamos María'], correctIndex: 0 },
  { id: 'es-listen-3', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'beginner', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Muchas gracias', choices: ['Muchas gracias', 'Mucho gusto', 'De nada', 'Por favor'], correctIndex: 0 },
  { id: 'es-listen-4', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'intermediate', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Quisiera un café, por favor', choices: ['Quiero un té, por favor', 'Quisiera un café, por favor', 'Querría un café, por favor', 'Quisiera un agua, por favor'], correctIndex: 1 },
  { id: 'es-listen-5', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'intermediate', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: '¿Cuánto cuesta esto?', choices: ['¿Cuánto cuesta eso?', '¿Cuánto cuesta esto?', '¿Cuándo cuesta esto?', '¿Cuánto cuestan estos?'], correctIndex: 1 },
  { id: 'es-listen-6', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'intermediate', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: '¿Dónde está la estación?', choices: ['¿Dónde está la estación?', '¿Dónde está la parada?', '¿Cómo está la estación?', '¿Dónde queda la estación?'], correctIndex: 0 },
  { id: 'es-listen-7', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'advanced', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: '¿Podría repetir, por favor?', choices: ['¿Puede repetir, por favor?', '¿Podría repetir, por favor?', '¿Puedes repetir, por favor?', '¿Podría hablar, por favor?'], correctIndex: 1 },
  { id: 'es-listen-8', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'advanced', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'No entiendo, ¿puede hablar más despacio?', choices: ['No entiendo, ¿puede hablar más rápido?', 'No escucho, ¿puede hablar más despacio?', 'No entiendo, ¿puede hablar más despacio?', 'No entiendo, ¿puedes hablar más despacio?'], correctIndex: 2 },
  { id: 'es-listen-9', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'beginner', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: 'Mucho gusto en conocerte', choices: ['Mucho gusto en conocerte', 'Mucho gusto en conocerle', 'Mucho gusto en verte', 'Mucho gusto en encontrarte'], correctIndex: 0 },
  { id: 'es-listen-10', language: 'es', category: 'phonetics', subCategory: 'Écoute', difficulty: 'intermediate', type: 'listen', prompt: 'Écoutez et choisissez la bonne transcription', audioText: '¿Qué hora es?', choices: ['¿Qué hora era?', '¿Qué hora es?', '¿Cuántas horas son?', '¿A qué hora?'], correctIndex: 1 },

  // Plus de vocabulaire espagnol - Salutations étendues
  { id: 'es-voc-21', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Bonsoir" ?', choices: ['Buenos días', 'Buenas tardes', 'Buenas noches', 'Hola'], correctIndex: 1 },
  { id: 'es-voc-22', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Bonne nuit" ?', choices: ['Buenos días', 'Buenas tardes', 'Buenas noches', 'Hasta mañana'], correctIndex: 2 },
  { id: 'es-voc-23', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "De rien" ?', choices: ['Gracias', 'De nada', 'Por favor', 'Perdón'], correctIndex: 1 },
  { id: 'es-voc-24', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Pardon" ?', choices: ['Gracias', 'De nada', 'Perdón', 'Por favor'], correctIndex: 2 },
  { id: 'es-voc-25', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "Comment allez-vous ?" (formel) ?', choices: ['¿Cómo estás?', '¿Cómo está usted?', '¿Qué tal?', '¿Cómo te va?'], correctIndex: 1 },
  { id: 'es-voc-26', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "Comment ça va ?" (informel) ?', choices: ['¿Cómo está?', '¿Cómo estás?', '¿Cómo están?', '¿Cómo estamos?'], correctIndex: 1 },
  { id: 'es-voc-27', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "À bientôt" en espagnol', correctAnswer: 'hasta pronto' },
  { id: 'es-voc-28', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "Enchanté" ?', choices: ['Mucho gusto', 'Con gusto', 'Buen provecho', 'Buena suerte'], correctIndex: 0 },
  { id: 'es-voc-29', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "Bienvenue" en espagnol', correctAnswer: 'bienvenido' },
  { id: 'es-voc-30', language: 'es', category: 'vocabulary', subCategory: 'Salutations', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "Félicitations" ?', choices: ['Felicidades', 'Enhorabuena', 'Les deux sont corrects', 'Buena suerte'], correctIndex: 2 },

  // Plus de nombres espagnol
  { id: 'es-voc-31', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "un" ?', choices: ['uno', 'dos', 'cero', 'tres'], correctIndex: 0 },
  { id: 'es-voc-32', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "deux" ?', choices: ['uno', 'dos', 'tres', 'cuatro'], correctIndex: 1 },
  { id: 'es-voc-33', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "trois" ?', choices: ['dos', 'tres', 'cuatro', 'cinco'], correctIndex: 1 },
  { id: 'es-voc-34', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "quatre" ?', choices: ['tres', 'cuatro', 'cinco', 'seis'], correctIndex: 1 },
  { id: 'es-voc-35', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "six" ?', choices: ['cinco', 'seis', 'siete', 'ocho'], correctIndex: 1 },
  { id: 'es-voc-36', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "sept" ?', choices: ['seis', 'siete', 'ocho', 'nueve'], correctIndex: 1 },
  { id: 'es-voc-37', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "huit" ?', choices: ['siete', 'ocho', 'nueve', 'diez'], correctIndex: 1 },
  { id: 'es-voc-38', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "neuf" ?', choices: ['ocho', 'nueve', 'diez', 'once'], correctIndex: 1 },
  { id: 'es-voc-39', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "zéro" en espagnol', correctAnswer: 'cero' },
  { id: 'es-voc-40', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "onze" ?', choices: ['diez', 'once', 'doce', 'trece'], correctIndex: 1 },
  { id: 'es-voc-41', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "douze" ?', choices: ['once', 'doce', 'trece', 'catorce'], correctIndex: 1 },
  { id: 'es-voc-42', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "quinze" ?', choices: ['trece', 'catorce', 'quince', 'dieciséis'], correctIndex: 2 },
  { id: 'es-voc-43', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "trente" ?', choices: ['veinte', 'treinta', 'cuarenta', 'cincuenta'], correctIndex: 1 },
  { id: 'es-voc-44', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cinquante" ?', choices: ['cuarenta', 'cincuenta', 'sesenta', 'setenta'], correctIndex: 1 },
  { id: 'es-voc-45', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "cent" en espagnol', correctAnswer: 'cien' },
  { id: 'es-voc-46', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "mille" ?', choices: ['cien', 'mil', 'millón', 'ciento'], correctIndex: 1 },
  { id: 'es-voc-47', language: 'es', category: 'vocabulary', subCategory: 'Nombres', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "premier" ?', choices: ['primero', 'segundo', 'tercero', 'uno'], correctIndex: 0 },

  // Plus de couleurs espagnol
  { id: 'es-voc-48', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "vert" ?', choices: ['rojo', 'verde', 'azul', 'amarillo'], correctIndex: 1 },
  { id: 'es-voc-49', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "jaune" ?', choices: ['rojo', 'verde', 'azul', 'amarillo'], correctIndex: 3 },
  { id: 'es-voc-50', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "noir" ?', choices: ['blanco', 'negro', 'gris', 'marrón'], correctIndex: 1 },
  { id: 'es-voc-51', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "orange" ?', choices: ['rojo', 'naranja', 'amarillo', 'marrón'], correctIndex: 1 },
  { id: 'es-voc-52', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "violet" ?', choices: ['rosa', 'morado', 'azul', 'púrpura'], correctIndex: 1 },
  { id: 'es-voc-53', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "rose" ?', choices: ['morado', 'rosa', 'rojo', 'naranja'], correctIndex: 1 },
  { id: 'es-voc-54', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "gris" ?', choices: ['negro', 'blanco', 'gris', 'marrón'], correctIndex: 2 },
  { id: 'es-voc-55', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "marron" en espagnol', correctAnswer: 'marrón' },
  { id: 'es-voc-56', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "doré" ?', choices: ['plateado', 'dorado', 'bronceado', 'colorido'], correctIndex: 1 },
  { id: 'es-voc-57', language: 'es', category: 'vocabulary', subCategory: 'Couleurs', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "argenté" en espagnol', correctAnswer: 'plateado' },

  // Plus de famille espagnol
  { id: 'es-voc-58', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "mère" ?', choices: ['padre', 'madre', 'hermana', 'hija'], correctIndex: 1 },
  { id: 'es-voc-59', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "frère" ?', choices: ['hermano', 'hermana', 'primo', 'tío'], correctIndex: 0 },
  { id: 'es-voc-60', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "fils" ?', choices: ['hija', 'hijo', 'sobrino', 'nieto'], correctIndex: 1 },
  { id: 'es-voc-61', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "fille" (enfant) ?', choices: ['hijo', 'hija', 'hermana', 'sobrina'], correctIndex: 1 },
  { id: 'es-voc-62', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "grand-père" ?', choices: ['abuela', 'abuelo', 'tío', 'primo'], correctIndex: 1 },
  { id: 'es-voc-63', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "oncle" ?', choices: ['abuelo', 'tío', 'primo', 'sobrino'], correctIndex: 1 },
  { id: 'es-voc-64', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "tante" ?', choices: ['abuela', 'tía', 'prima', 'sobrina'], correctIndex: 1 },
  { id: 'es-voc-65', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cousin" (masculin) ?', choices: ['primo', 'prima', 'sobrino', 'tío'], correctIndex: 0 },
  { id: 'es-voc-66', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "cousine" en espagnol', correctAnswer: 'prima' },
  { id: 'es-voc-67', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "mari" ?', choices: ['esposa', 'marido', 'novio', 'amigo'], correctIndex: 1 },
  { id: 'es-voc-68', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "femme" (épouse) ?', choices: ['marido', 'esposa', 'novia', 'amiga'], correctIndex: 1 },
  { id: 'es-voc-69', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "beau-père" ?', choices: ['suegro', 'padrastro', 'cuñado', 'yerno'], correctIndex: 0 },
  { id: 'es-voc-70', language: 'es', category: 'vocabulary', subCategory: 'Famille', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "belle-mère" en espagnol', correctAnswer: 'suegra' },

  // Plus de nourriture espagnol
  { id: 'es-voc-71', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "lait" ?', choices: ['agua', 'leche', 'zumo', 'té'], correctIndex: 1 },
  { id: 'es-voc-72', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "café" ?', choices: ['té', 'café', 'leche', 'zumo'], correctIndex: 1 },
  { id: 'es-voc-73', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "vin" ?', choices: ['cerveza', 'vino', 'agua', 'zumo'], correctIndex: 1 },
  { id: 'es-voc-74', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "bière" ?', choices: ['vino', 'cerveza', 'agua', 'zumo'], correctIndex: 1 },
  { id: 'es-voc-75', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "viande" ?', choices: ['pescado', 'carne', 'pollo', 'cerdo'], correctIndex: 1 },
  { id: 'es-voc-76', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "poisson" ?', choices: ['carne', 'pescado', 'pollo', 'cerdo'], correctIndex: 1 },
  { id: 'es-voc-77', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "porc" ?', choices: ['ternera', 'cerdo', 'cordero', 'pavo'], correctIndex: 1 },
  { id: 'es-voc-78', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "bœuf" ?', choices: ['ternera', 'cerdo', 'cordero', 'pavo'], correctIndex: 0 },
  { id: 'es-voc-79', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "œuf" ?', choices: ['huevo', 'leche', 'mantequilla', 'queso'], correctIndex: 0 },
  { id: 'es-voc-80', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "fromage" en espagnol', correctAnswer: 'queso' },
  { id: 'es-voc-81', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pomme" ?', choices: ['naranja', 'manzana', 'plátano', 'pera'], correctIndex: 1 },
  { id: 'es-voc-82', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "orange" (fruit) ?', choices: ['manzana', 'naranja', 'plátano', 'limón'], correctIndex: 1 },
  { id: 'es-voc-83', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "banane" ?', choices: ['manzana', 'naranja', 'plátano', 'pera'], correctIndex: 2 },
  { id: 'es-voc-84', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "citron" ?', choices: ['naranja', 'limón', 'pomelo', 'lima'], correctIndex: 1 },
  { id: 'es-voc-85', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "tomate" ?', choices: ['patata', 'tomate', 'zanahoria', 'cebolla'], correctIndex: 1 },
  { id: 'es-voc-86', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pomme de terre" ?', choices: ['tomate', 'patata', 'zanahoria', 'cebolla'], correctIndex: 1 },
  { id: 'es-voc-87', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "riz" en espagnol', correctAnswer: 'arroz' },
  { id: 'es-voc-88', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "sucre" ?', choices: ['sal', 'azúcar', 'pimienta', 'aceite'], correctIndex: 1 },
  { id: 'es-voc-89', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "sel" ?', choices: ['azúcar', 'sal', 'pimienta', 'aceite'], correctIndex: 1 },
  { id: 'es-voc-90', language: 'es', category: 'vocabulary', subCategory: 'Nourriture', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "huile" en espagnol', correctAnswer: 'aceite' },

  // Plus de corps espagnol
  { id: 'es-voc-91', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pied" ?', choices: ['mano', 'pierna', 'pie', 'brazo'], correctIndex: 2 },
  { id: 'es-voc-92', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "jambe" ?', choices: ['brazo', 'pierna', 'mano', 'pie'], correctIndex: 1 },
  { id: 'es-voc-93', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "bras" ?', choices: ['pierna', 'brazo', 'mano', 'hombro'], correctIndex: 1 },
  { id: 'es-voc-94', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "nez" ?', choices: ['boca', 'nariz', 'oreja', 'ojo'], correctIndex: 1 },
  { id: 'es-voc-95', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "bouche" ?', choices: ['nariz', 'boca', 'lengua', 'diente'], correctIndex: 1 },
  { id: 'es-voc-96', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "oreille" ?', choices: ['ojo', 'nariz', 'oreja', 'boca'], correctIndex: 2 },
  { id: 'es-voc-97', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "épaule" ?', choices: ['brazo', 'hombro', 'espalda', 'cuello'], correctIndex: 1 },
  { id: 'es-voc-98', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "dos" ?', choices: ['pecho', 'espalda', 'barriga', 'cuello'], correctIndex: 1 },
  { id: 'es-voc-99', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "cou" en espagnol', correctAnswer: 'cuello' },
  { id: 'es-voc-100', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "cheveux" ?', choices: ['pelo', 'ojos', 'dientes', 'orejas'], correctIndex: 0 },
  { id: 'es-voc-101', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "doigt" ?', choices: ['mano', 'dedo', 'uña', 'muñeca'], correctIndex: 1 },
  { id: 'es-voc-102', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "genou" ?', choices: ['pierna', 'pie', 'rodilla', 'tobillo'], correctIndex: 2 },
  { id: 'es-voc-103', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "coude" en espagnol', correctAnswer: 'codo' },
  { id: 'es-voc-104', language: 'es', category: 'vocabulary', subCategory: 'Corps', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cœur" ?', choices: ['corazón', 'hígado', 'pulmón', 'estómago'], correctIndex: 0 },

  // Animaux espagnol
  { id: 'es-voc-105', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chien" ?', choices: ['gato', 'perro', 'caballo', 'pájaro'], correctIndex: 1 },
  { id: 'es-voc-106', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chat" ?', choices: ['perro', 'gato', 'ratón', 'conejo'], correctIndex: 1 },
  { id: 'es-voc-107', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "oiseau" ?', choices: ['pez', 'pájaro', 'mariposa', 'abeja'], correctIndex: 1 },
  { id: 'es-voc-108', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "cheval" ?', choices: ['vaca', 'caballo', 'burro', 'cerdo'], correctIndex: 1 },
  { id: 'es-voc-109', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "vache" en espagnol', correctAnswer: 'vaca' },
  { id: 'es-voc-110', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "lapin" ?', choices: ['ratón', 'conejo', 'ardilla', 'erizo'], correctIndex: 1 },
  { id: 'es-voc-111', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "lion" ?', choices: ['tigre', 'león', 'leopardo', 'guepardo'], correctIndex: 1 },
  { id: 'es-voc-112', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "éléphant" ?', choices: ['jirafa', 'elefante', 'hipopótamo', 'rinoceronte'], correctIndex: 1 },
  { id: 'es-voc-113', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "serpent" en espagnol', correctAnswer: 'serpiente' },
  { id: 'es-voc-114', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'advanced', type: 'choice', prompt: 'Comment dit-on "papillon" ?', choices: ['abeja', 'mariposa', 'mosca', 'mosquito'], correctIndex: 1 },
  { id: 'es-voc-115', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "mouton" ?', choices: ['cabra', 'oveja', 'cordero', 'carnero'], correctIndex: 1 },
  { id: 'es-voc-116', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "loup" ?', choices: ['zorro', 'lobo', 'oso', 'ciervo'], correctIndex: 1 },
  { id: 'es-voc-117', language: 'es', category: 'vocabulary', subCategory: 'Animaux', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "renard" en espagnol', correctAnswer: 'zorro' },

  // Vêtements espagnol
  { id: 'es-voc-118', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chemise" ?', choices: ['pantalones', 'camisa', 'falda', 'vestido'], correctIndex: 1 },
  { id: 'es-voc-119', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "pantalon" ?', choices: ['camisa', 'pantalones', 'falda', 'vaqueros'], correctIndex: 1 },
  { id: 'es-voc-120', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "robe" ?', choices: ['falda', 'vestido', 'camisa', 'camiseta'], correctIndex: 1 },
  { id: 'es-voc-121', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "jupe" ?', choices: ['vestido', 'falda', 'pantalones', 'shorts'], correctIndex: 1 },
  { id: 'es-voc-122', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "chaussures" en espagnol', correctAnswer: 'zapatos' },
  { id: 'es-voc-123', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "t-shirt" ?', choices: ['camisa', 'camiseta', 'jersey', 'chaqueta'], correctIndex: 1 },
  { id: 'es-voc-124', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "pull" ?', choices: ['camiseta', 'jersey', 'chaqueta', 'abrigo'], correctIndex: 1 },
  { id: 'es-voc-125', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "veste" ?', choices: ['jersey', 'chaqueta', 'abrigo', 'cazadora'], correctIndex: 1 },
  { id: 'es-voc-126', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "manteau" ?', choices: ['chaqueta', 'abrigo', 'cazadora', 'impermeable'], correctIndex: 1 },
  { id: 'es-voc-127', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "chapeau" en espagnol', correctAnswer: 'sombrero' },
  { id: 'es-voc-128', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chaussettes" ?', choices: ['zapatos', 'calcetines', 'botas', 'sandalias'], correctIndex: 1 },
  { id: 'es-voc-129', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "cravate" ?', choices: ['cinturón', 'corbata', 'bufanda', 'pañuelo'], correctIndex: 1 },
  { id: 'es-voc-130', language: 'es', category: 'vocabulary', subCategory: 'Vêtements', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "gants" en espagnol', correctAnswer: 'guantes' },

  // Maison espagnol
  { id: 'es-voc-131', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "maison" ?', choices: ['apartamento', 'casa', 'piso', 'edificio'], correctIndex: 1 },
  { id: 'es-voc-132', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chambre" ?', choices: ['cocina', 'habitación', 'baño', 'salón'], correctIndex: 1 },
  { id: 'es-voc-133', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "cuisine" ?', choices: ['habitación', 'cocina', 'baño', 'salón'], correctIndex: 1 },
  { id: 'es-voc-134', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "salle de bain" ?', choices: ['cocina', 'habitación', 'baño', 'salón'], correctIndex: 2 },
  { id: 'es-voc-135', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'write', prompt: 'Écrivez "salon" en espagnol', correctAnswer: 'salón' },
  { id: 'es-voc-136', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "porte" ?', choices: ['ventana', 'puerta', 'pared', 'techo'], correctIndex: 1 },
  { id: 'es-voc-137', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "fenêtre" ?', choices: ['puerta', 'ventana', 'balcón', 'terraza'], correctIndex: 1 },
  { id: 'es-voc-138', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "escalier" ?', choices: ['ascensor', 'escalera', 'pasillo', 'entrada'], correctIndex: 1 },
  { id: 'es-voc-139', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "jardin" ?', choices: ['balcón', 'jardín', 'terraza', 'patio'], correctIndex: 1 },
  { id: 'es-voc-140', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'intermediate', type: 'write', prompt: 'Écrivez "toit" en espagnol', correctAnswer: 'techo' },
  { id: 'es-voc-141', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "lit" ?', choices: ['silla', 'cama', 'mesa', 'armario'], correctIndex: 1 },
  { id: 'es-voc-142', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "table" ?', choices: ['silla', 'cama', 'mesa', 'sofá'], correctIndex: 2 },
  { id: 'es-voc-143', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'beginner', type: 'choice', prompt: 'Comment dit-on "chaise" ?', choices: ['silla', 'sillón', 'sofá', 'taburete'], correctIndex: 0 },
  { id: 'es-voc-144', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'intermediate', type: 'choice', prompt: 'Comment dit-on "armoire" ?', choices: ['cómoda', 'armario', 'estantería', 'mesita'], correctIndex: 1 },
  { id: 'es-voc-145', language: 'es', category: 'vocabulary', subCategory: 'Maison', difficulty: 'advanced', type: 'write', prompt: 'Écrivez "canapé" en espagnol', correctAnswer: 'sofá' }
]

// Fonction pour obtenir les questions par critères
export const getQuestionsByFilter = (
  language: 'it' | 'es',
  category?: 'vocabulary' | 'grammar' | 'conjugation' | 'phonetics' | 'all',
  subCategory?: string,
  difficulty?: 'beginner' | 'intermediate' | 'advanced' | 'all',
  count?: number
): QuizQuestion[] => {
  let filtered = quizQuestions.filter(q => q.language === language)
  
  if (category && category !== 'all') {
    filtered = filtered.filter(q => q.category === category)
  }
  
  if (subCategory) {
    filtered = filtered.filter(q => q.subCategory === subCategory)
  }
  
  if (difficulty && difficulty !== 'all') {
    filtered = filtered.filter(q => q.difficulty === difficulty)
  }
  
  // Mélanger les questions
  filtered = filtered.sort(() => Math.random() - 0.5)
  
  // Limiter le nombre
  if (count && count > 0) {
    filtered = filtered.slice(0, count)
  }
  
  return filtered
}

// Obtenir les sous-catégories disponibles
export const getSubCategories = (language: 'it' | 'es', category: string): string[] => {
  const subs = new Set<string>()
  quizQuestions
    .filter(q => q.language === language && q.category === category)
    .forEach(q => subs.add(q.subCategory))
  return Array.from(subs)
}

// Catégories principales
export const quizCategories = [
  { id: 'all', label: 'Tout', icon: '📚' },
  { id: 'vocabulary', label: 'Vocabulaire', icon: '📖' },
  { id: 'grammar', label: 'Grammaire', icon: '📝' },
  { id: 'conjugation', label: 'Conjugaison', icon: '✍️' },
  { id: 'phonetics', label: 'Phonétique', icon: '🎵' }
]
