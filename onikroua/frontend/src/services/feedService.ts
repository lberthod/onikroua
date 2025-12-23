import { useLearningStore, type GrammarItem, type ConjugationItem } from '../stores/learning'
import { usePhonetiqueStore, type PhoneticSound } from '../stores/phonetique'
import type { QuizQuestion } from '../data/quizQuestions'
import vocabularyItData from '../data/vocabulary_it.json'
import vocabularyEsData from '../data/vocabulary_es.json'
import { quizQuestions } from '../data/quizQuestions'

export type FeedItemType = 'grammar' | 'vocabulary' | 'phonetic' | 'conjugation' | 'quiz'

export interface BaseFeedItem {
  id: string
  type: FeedItemType
  language: 'it' | 'es'
  difficulty: 'beginner' | 'intermediate' | 'advanced'
  timestamp: number
  liked?: boolean
  bookmarked?: boolean
  likeCount?: number
  commentCount?: number
}

export interface GrammarFeedItem extends BaseFeedItem {
  type: 'grammar'
  data: GrammarItem
}

export interface VocabularyFeedItem extends BaseFeedItem {
  type: 'vocabulary'
  data: {
    word: string
    translation: string
    example?: string
    exampleTranslation?: string
    gender?: string
    category: string
    categoryIcon: string
  }
}

export interface PhoneticFeedItem extends BaseFeedItem {
  type: 'phonetic'
  data: PhoneticSound
}

export interface ConjugationFeedItem extends BaseFeedItem {
  type: 'conjugation'
  data: ConjugationItem
}

export interface QuizFeedItem extends BaseFeedItem {
  type: 'quiz'
  data: QuizQuestion
}

export type FeedItem = GrammarFeedItem | VocabularyFeedItem | PhoneticFeedItem | ConjugationFeedItem | QuizFeedItem

class FeedService {
  private currentLanguage: 'it' | 'es' = 'it'
  private pageSize = 10
  private allItems: FeedItem[] = []
  private currentPage = 0

  setLanguage(language: 'it' | 'es') {
    this.currentLanguage = language
    this.currentPage = 0
    this.generateAllItems()
  }

  private generateAllItems() {
    this.allItems = []
    
    // Initialiser les stores
    const learningStore = useLearningStore()
    const phonetiqueStore = usePhonetiqueStore()
    
    learningStore.initDemoData()
    phonetiqueStore.loadPhoneticData()

    // Récupérer toutes les données
    const grammarItems = learningStore.getGrammarByLanguage.filter(item => item.language === this.currentLanguage)
    const conjugationItems = learningStore.getConjugationsByLanguage.filter(item => item.language === this.currentLanguage)
    const phoneticItems = phonetiqueStore.sounds.filter((item: PhoneticSound) => item.language === this.currentLanguage)
    const vocabularyData = this.currentLanguage === 'it' ? vocabularyItData : vocabularyEsData
    const quizItems = quizQuestions.filter(item => item.language === this.currentLanguage)

    let itemId = 0

    // Ajouter les items de grammaire
    grammarItems.forEach(grammar => {
      this.allItems.push({
        id: `grammar-${itemId++}`,
        type: 'grammar',
        language: this.currentLanguage,
        difficulty: grammar.difficulty,
        timestamp: Date.now() + Math.random() * 1000000,
        data: grammar
      })
    })

    // Ajouter les items de conjugaison
    conjugationItems.forEach(conjugation => {
      this.allItems.push({
        id: `conjugation-${itemId++}`,
        type: 'conjugation',
        language: this.currentLanguage,
        difficulty: conjugation.difficulty,
        timestamp: Date.now() + Math.random() * 1000000,
        data: conjugation
      })
    })

    // Ajouter les items phonétiques
    phoneticItems.forEach((phonetic: PhoneticSound) => {
      const difficulty = phonetic.difficulty === 'easy' ? 'beginner' : 
                        phonetic.difficulty === 'medium' ? 'intermediate' : 'advanced'
      
      this.allItems.push({
        id: `phonetic-${itemId++}`,
        type: 'phonetic',
        language: this.currentLanguage,
        difficulty,
        timestamp: Date.now() + Math.random() * 1000000,
        data: phonetic
      })
    })

    // Ajouter les items de vocabulaire
    vocabularyData.forEach((category: any) => {
      category.words.forEach((word: any) => {
        const difficulty: 'beginner' | 'intermediate' | 'advanced' = 
          word.word.length <= 5 ? 'beginner' : 
          word.word.length <= 8 ? 'intermediate' : 'advanced'

        this.allItems.push({
          id: `vocabulary-${itemId++}`,
          type: 'vocabulary',
          language: this.currentLanguage,
          difficulty,
          timestamp: Date.now() + Math.random() * 1000000,
          data: {
            word: word.word,
            translation: word.translation,
            example: word.example,
            exampleTranslation: word.exampleTranslation,
            gender: word.gender || undefined,
            category: category.name,
            categoryIcon: category.icon
          }
        })
      })
    })

    // Ajouter les items de quiz
    quizItems.forEach(quiz => {
      const difficulty = quiz.difficulty || 'beginner'
      this.allItems.push({
        id: `quiz-${itemId++}`,
        type: 'quiz',
        language: this.currentLanguage,
        difficulty,
        timestamp: Date.now() + Math.random() * 1000000,
        data: quiz
      })
    })

    // Mélanger les items aléatoirement
    this.allItems = this.shuffleArray(this.allItems)
  }

  private shuffleArray<T>(array: T[]): T[] {
    const shuffled = [...array]
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      ;[shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
    }
    return shuffled
  }

  getNextPage(): FeedItem[] {
    const startIndex = this.currentPage * this.pageSize
    const endIndex = startIndex + this.pageSize
    const pageItems = this.allItems.slice(startIndex, endIndex)
    
    if (pageItems.length > 0) {
      this.currentPage++
    }
    
    return pageItems
  }

  hasMore(): boolean {
    return this.currentPage * this.pageSize < this.allItems.length
  }

  reset() {
    this.currentPage = 0
    this.generateAllItems()
  }

  getTotalItems(): number {
    return this.allItems.length
  }
}

export const feedService = new FeedService()
