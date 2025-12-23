import type { GrammarCategory, GrammarSubCategory } from '../stores/learning'

export interface GrammarCategoryConfig {
  id: GrammarCategory | 'all'
  label: string
  icon: string
}

// Catégories affichées dans la vue Grammaire
export const grammarCategories: GrammarCategoryConfig[] = [
  { id: 'all', label: 'Tout', icon: '📋' },
  { id: 'bases', label: 'Bases', icon: '🔤' },
  { id: 'adjectifs', label: 'Adjectifs', icon: '✨' },
  { id: 'pronoms', label: 'Pronoms', icon: '👤' },
  { id: 'verbes', label: 'Verbes', icon: '⚡' },
  { id: 'syntaxe', label: 'Syntaxe', icon: '📝' },
  { id: 'prepositions', label: 'Prépositions', icon: '🔗' },
  { id: 'orthographe', label: 'Orthographe', icon: '✏️' }
]

// Labels lisibles pour chaque sous-catégorie de grammaire
export const grammarSubCategoryLabels: Record<GrammarSubCategory | string, string> = {
  'articles-definis': 'Articles définis',
  'articles-indefinis': 'Articles indéfinis',
  'pluriel': 'Formation du pluriel',
  'genre': 'Genre des noms',
  'accord-adjectifs': 'Accord des adjectifs',
  'possessifs': 'Adjectifs possessifs',
  'demonstratifs': 'Adjectifs démonstratifs',
  'comparatifs': 'Comparatifs et superlatifs',
  'pronoms-sujets': 'Pronoms sujets',
  'pronoms-cod': 'Pronoms COD',
  'pronoms-coi': 'Pronoms COI',
  'pronoms-reflexifs': 'Pronoms réfléchis',
  'present': 'Présent',
  'passe-compose': 'Passé composé',
  'imparfait': 'Imparfait',
  'futur': 'Futur',
  'conditionnel': 'Conditionnel',
  'subjonctif': 'Subjonctif',
  'imperatif': 'Impératif',
  'verbes-irreguliers': 'Verbes irréguliers',
  'ser-estar': 'Ser vs Estar',
  'negation': 'Négation',
  'questions': 'Questions',
  'ordre-mots': 'Ordre des mots',
  'prepositions-base': 'Prépositions de base',
  'prepositions-articulees': 'Prépositions articulées',
  'por-para': 'Por vs Para',
  'orthographe': 'Orthographe et accentuation'
}
