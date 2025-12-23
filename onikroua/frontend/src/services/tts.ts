/**
 * Service Text-to-Speech (TTS) pour la prononciation
 * Utilise l'API Web Speech du navigateur
 */

export interface TTSOptions {
  lang: 'it-IT' | 'es-ES' | 'fr-FR'
  rate?: number      // Vitesse (0.1 - 10, défaut: 1)
  pitch?: number     // Hauteur (0 - 2, défaut: 1)
  volume?: number    // Volume (0 - 1, défaut: 1)
}

class TTSService {
  private synth: SpeechSynthesis | null = null
  private voices: SpeechSynthesisVoice[] = []
  private isReady = false

  constructor() {
    if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
      this.synth = window.speechSynthesis
      this.loadVoices()
      
      // Les voix peuvent se charger de manière asynchrone
      if (this.synth.onvoiceschanged !== undefined) {
        this.synth.onvoiceschanged = () => this.loadVoices()
      }
    }
  }

  private loadVoices(): void {
    if (this.synth) {
      this.voices = this.synth.getVoices()
      this.isReady = this.voices.length > 0
    }
  }

  /**
   * Vérifie si le TTS est disponible
   */
  isAvailable(): boolean {
    return this.synth !== null
  }

  /**
   * Vérifie si les voix sont chargées
   */
  isVoicesReady(): boolean {
    return this.isReady
  }

  /**
   * Obtenir les voix disponibles pour une langue
   */
  getVoicesForLanguage(lang: string): SpeechSynthesisVoice[] {
    const langCode = lang.split('-')[0]
    return this.voices.filter(voice => 
      voice.lang.startsWith(langCode) || voice.lang.startsWith(lang)
    )
  }

  /**
   * Obtenir la meilleure voix pour une langue
   */
  getBestVoice(lang: string): SpeechSynthesisVoice | null {
    const voices = this.getVoicesForLanguage(lang)
    
    // Préférer les voix natives/locales
    const localVoice = voices.find(v => v.localService)
    if (localVoice) return localVoice
    
    // Sinon prendre la première disponible
    return voices[0] || null
  }

  /**
   * Prononcer un texte
   */
  speak(text: string, options: TTSOptions): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.synth) {
        reject(new Error('TTS non disponible sur ce navigateur'))
        return
      }

      // Annuler toute lecture en cours
      this.synth.cancel()

      const utterance = new SpeechSynthesisUtterance(text)
      
      // Configurer la langue
      utterance.lang = options.lang
      
      // Trouver la meilleure voix
      const voice = this.getBestVoice(options.lang)
      if (voice) {
        utterance.voice = voice
      }

      // Configurer les options
      utterance.rate = options.rate ?? 0.9  // Un peu plus lent par défaut pour l'apprentissage
      utterance.pitch = options.pitch ?? 1
      utterance.volume = options.volume ?? 1

      // Événements
      utterance.onend = () => resolve()
      utterance.onerror = (event) => reject(new Error(event.error))

      // Lancer la lecture
      this.synth.speak(utterance)
    })
  }

  /**
   * Prononcer en italien
   */
  speakItalian(text: string, rate?: number): Promise<void> {
    return this.speak(text, { lang: 'it-IT', rate })
  }

  /**
   * Prononcer en espagnol
   */
  speakSpanish(text: string, rate?: number): Promise<void> {
    return this.speak(text, { lang: 'es-ES', rate })
  }

  /**
   * Prononcer en français
   */
  speakFrench(text: string, rate?: number): Promise<void> {
    return this.speak(text, { lang: 'fr-FR', rate })
  }

  /**
   * Arrêter la lecture en cours
   */
  stop(): void {
    if (this.synth) {
      this.synth.cancel()
    }
  }

  /**
   * Vérifier si une lecture est en cours
   */
  isSpeaking(): boolean {
    return this.synth?.speaking ?? false
  }

  /**
   * Obtenir toutes les voix disponibles
   */
  getAllVoices(): SpeechSynthesisVoice[] {
    return this.voices
  }
}

// Instance singleton
export const ttsService = new TTSService()

// Helper pour obtenir le code langue TTS
export const getTTSLang = (lang: 'it' | 'es'): 'it-IT' | 'es-ES' => {
  return lang === 'it' ? 'it-IT' : 'es-ES'
}
