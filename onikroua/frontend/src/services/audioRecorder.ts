/**
 * Service d'enregistrement audio pour la pratique de la prononciation
 * Utilise l'API MediaRecorder
 */

export interface AudioRecording {
  blob: Blob
  url: string
  duration: number
}

class AudioRecorderService {
  private mediaRecorder: MediaRecorder | null = null
  private chunks: Blob[] = []
  private startTime: number = 0
  private stream: MediaStream | null = null

  /**
   * Vérifie si l'enregistrement audio est supporté
   */
  isSupported(): boolean {
    return !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia)
  }

  /**
   * Demande la permission d'accès au microphone
   */
  async requestPermission(): Promise<boolean> {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      return true
    } catch (error) {
      console.error('Erreur accès micro:', error)
      return false
    }
  }

  /**
   * Démarre l'enregistrement
   */
  startRecording(): void {
    if (!this.stream) {
      throw new Error('Microphone non initialisé')
    }

    this.mediaRecorder = new MediaRecorder(this.stream)
    this.chunks = []
    this.startTime = Date.now()

    this.mediaRecorder.ondataavailable = (e) => {
      if (e.data.size > 0) {
        this.chunks.push(e.data)
      }
    }

    this.mediaRecorder.start()
  }

  /**
   * Arrête l'enregistrement et retourne le résultat
   */
  stopRecording(): Promise<AudioRecording> {
    return new Promise((resolve, reject) => {
      if (!this.mediaRecorder) {
        reject(new Error('Aucun enregistrement en cours'))
        return
      }

      this.mediaRecorder.onstop = () => {
        const blob = new Blob(this.chunks, { type: 'audio/webm' })
        const url = URL.createObjectURL(blob)
        const duration = Date.now() - this.startTime

        resolve({
          blob,
          url,
          duration
        })
      }

      this.mediaRecorder.stop()
    })
  }

  /**
   * Libère les ressources
   */
  release(): void {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }
    this.mediaRecorder = null
    this.chunks = []
  }
}

export const audioRecorder = new AudioRecorderService()
