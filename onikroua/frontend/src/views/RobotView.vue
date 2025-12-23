<template>
  <div class="robot-view">
    <div class="robot-container">
      <div class="robot-header">
        <h1>🤖 Robot Pédagogique (Cost-Friendly)</h1>
        <p class="scenario">Scénario : Se présenter (A1)</p>
      </div>

      <div class="robot-visual" :class="robotState">
        <div class="robot-avatar">
          <div class="robot-face">
            <div class="robot-eyes">
              <div class="eye left" :class="{ blinking: isBlinking }"></div>
              <div class="eye right" :class="{ blinking: isBlinking }"></div>
            </div>
            <div class="robot-mouth" :class="robotState"></div>
          </div>
          <div class="sound-waves" v-if="robotState === 'speaking'">
            <div class="wave"></div>
            <div class="wave"></div>
            <div class="wave"></div>
          </div>
        </div>
        
        <div class="state-indicator">
          <span class="state-dot" :class="robotState"></span>
          <span class="state-text">{{ stateText }}</span>
        </div>

        <div v-if="vadActive" class="vad-indicator">
          <span class="vad-dot"></span>
          <span>Voix détectée</span>
        </div>
      </div>

      <div class="conversation-display">
        <div class="transcript-box">
          <div v-if="currentTranscript.user" class="transcript-item user">
            <strong>Vous :</strong> {{ currentTranscript.user }}
          </div>
          <div v-if="currentTranscript.assistant" class="transcript-item assistant">
            <strong>Robot :</strong> {{ currentTranscript.assistant }}
          </div>
          <div v-if="!currentTranscript.user && !currentTranscript.assistant" class="transcript-placeholder">
            La conversation apparaîtra ici...
          </div>
        </div>

        <div v-if="correctedSentence" class="correction-box">
          <div class="correction-label">✅ Phrase correcte :</div>
          <div class="correction-text">{{ correctedSentence }}</div>
        </div>
      </div>

      <div v-if="metrics" class="metrics-box">
        <h3>📊 Métriques de session</h3>
        <div class="metrics-grid">
          <div class="metric">
            <span class="metric-label">Audio utilisateur</span>
            <span class="metric-value">{{ metrics.userAudioSeconds }}s</span>
          </div>
          <div class="metric">
            <span class="metric-label">Audio IA</span>
            <span class="metric-value">{{ metrics.aiAudioSeconds }}s</span>
          </div>
          <div class="metric">
            <span class="metric-label">Tours</span>
            <span class="metric-value">{{ metrics.turnCount }}</span>
          </div>
          <div class="metric">
            <span class="metric-label">Coût estimé</span>
            <span class="metric-value">${{ metrics.estimatedCostUSD }}</span>
          </div>
        </div>
      </div>

      <div class="controls">
        <button 
          v-if="!isConnected" 
          @click="connect" 
          class="btn-primary"
          :disabled="isConnecting"
        >
          {{ isConnecting ? 'Connexion...' : '🎤 Démarrer la conversation' }}
        </button>
        
        <button 
          v-if="isConnected" 
          @click="disconnect" 
          class="btn-danger"
        >
          🛑 Terminer
        </button>

        <button 
          v-if="isConnected" 
          @click="requestMetrics" 
          class="btn-secondary"
        >
          📊 Voir métriques
        </button>
      </div>

      <div v-if="error" class="error-message">
        ⚠️ {{ error }}
      </div>

      <div class="instructions">
        <h3>💡 Optimisations Cost-Friendly</h3>
        <ul>
          <li>✅ VAD local : seule la voix est envoyée (pas le silence)</li>
          <li>✅ Barge-in : interrompez le robot instantanément</li>
          <li>✅ Réponses courtes : max 8 secondes</li>
          <li>✅ Session persistante : même conversation continue</li>
          <li>✅ Métriques en temps réel : durée audio + coût estimé</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onUnmounted } from 'vue'

const VAD_CONFIG = {
  thresholdOn: 0.015,
  thresholdOff: 0.010,
  silenceDurationMs: 400,
  minSpeechDurationMs: 200,
  minRestartDelayMs: 300,
  bufferSizeMs: 100,
  prefixPaddingMs: 200
}

const ws = ref<WebSocket | null>(null)
const isConnected = ref(false)
const isConnecting = ref(false)
const robotState = ref<'idle' | 'listening' | 'thinking' | 'speaking'>('idle')
const error = ref('')
const isBlinking = ref(false)
const vadActive = ref(false)

const currentTranscript = ref({
  user: '',
  assistant: ''
})
const correctedSentence = ref('')
const metrics = ref<any>(null)

const audioContext = ref<AudioContext | null>(null)
const mediaStream = ref<MediaStream | null>(null)
const audioWorkletNode = ref<AudioWorkletNode | null>(null)
const audioQueue = ref<Float32Array[]>([])
const isPlaying = ref(false)
const currentSourceNode = ref<AudioBufferSourceNode | null>(null)
const playbackToken = ref(0)
const prefixPaddingSent = ref(false)
const lastSpeechEndTime = ref(0)

const isSpeechActive = ref(false)
const lastSpeechTime = ref<number | null>(null)
const silenceCheckInterval = ref<number | null>(null)

const stateText = computed(() => {
  switch (robotState.value) {
    case 'idle': return 'Prêt'
    case 'listening': return 'Écoute...'
    case 'thinking': return 'Réfléchit...'
    case 'speaking': return 'Parle...'
    default: return ''
  }
})

let blinkInterval: number | null = null

const startBlinking = () => {
  if (blinkInterval) return
  blinkInterval = window.setInterval(() => {
    isBlinking.value = true
    setTimeout(() => {
      isBlinking.value = false
    }, 150)
  }, 3000)
}

const stopBlinking = () => {
  if (blinkInterval) {
    clearInterval(blinkInterval)
    blinkInterval = null
  }
}

const connect = async () => {
  if (isConnecting.value || isConnected.value) return
  
  isConnecting.value = true
  error.value = ''

  try {
    audioContext.value = new AudioContext({ sampleRate: 24000 })

    mediaStream.value = await navigator.mediaDevices.getUserMedia({ 
      audio: {
        channelCount: 1,
        sampleRate: 24000,
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl: true
      } 
    })

    const source = audioContext.value.createMediaStreamSource(mediaStream.value)
    
    await audioContext.value.audioWorklet.addModule(
      URL.createObjectURL(new Blob([`
        class VADProcessor extends AudioWorkletProcessor {
          constructor() {
            super();
            this.thresholdOn = ${VAD_CONFIG.thresholdOn};
            this.thresholdOff = ${VAD_CONFIG.thresholdOff};
            this.bufferSize = Math.floor(${VAD_CONFIG.bufferSizeMs} * sampleRate / 1000);
            this.buffer = new Float32Array(this.bufferSize);
            this.bufferIndex = 0;
            this.ringBuffer = [];
            this.ringBufferMaxSize = ${Math.ceil(VAD_CONFIG.prefixPaddingMs / VAD_CONFIG.bufferSizeMs)};
            this.isSpeechActive = false;
            this.prefixSent = false;
          }

          process(inputs, outputs, parameters) {
            const input = inputs[0];
            if (input.length > 0) {
              const inputChannel = input[0];
              
              let sum = 0;
              let maxAmplitude = 0;
              
              for (let i = 0; i < inputChannel.length; i++) {
                const sample = inputChannel[i];
                this.buffer[this.bufferIndex++] = sample;
                sum += Math.abs(sample);
                maxAmplitude = Math.max(maxAmplitude, Math.abs(sample));
              }
              
              const avgAmplitude = sum / inputChannel.length;
              
              const threshold = this.isSpeechActive ? this.thresholdOff : this.thresholdOn;
              const isSpeech = avgAmplitude > threshold || maxAmplitude > threshold * 2;
              
              if (isSpeech && !this.isSpeechActive) {
                this.isSpeechActive = true;
                this.port.postMessage({ 
                  type: 'speech_start',
                  prefixBuffer: this.ringBuffer.length > 0 ? this.ringBuffer.slice() : []
                });
              } else if (!isSpeech && this.isSpeechActive) {
                this.isSpeechActive = false;
                this.port.postMessage({ type: 'speech_stop' });
              }
              
              this.port.postMessage({ 
                type: 'vad', 
                isSpeech: this.isSpeechActive,
                amplitude: avgAmplitude 
              });

              if (this.bufferIndex >= this.bufferSize) {
                const audioData = new Float32Array(this.buffer);
                
                if (!this.isSpeechActive) {
                  this.ringBuffer.push(audioData);
                  if (this.ringBuffer.length > this.ringBufferMaxSize) {
                    this.ringBuffer.shift();
                  }
                }
                
                if (this.isSpeechActive) {
                  this.port.postMessage({ 
                    type: 'audio', 
                    data: audioData
                  });
                }
                
                this.bufferIndex = 0;
              }
            }
            return true;
          }
        }
        registerProcessor('vad-processor', VADProcessor);
      `], { type: 'application/javascript' }))
    )

    audioWorkletNode.value = new AudioWorkletNode(audioContext.value, 'vad-processor')
    
    audioWorkletNode.value.port.onmessage = (event) => {
      if (event.data.type === 'vad') {
        handleVAD(event.data.isSpeech)
      } else if (event.data.type === 'speech_start') {
        handleSpeechStart(event.data.prefixBuffer)
      } else if (event.data.type === 'speech_stop') {
        handleSpeechStop()
      } else if (event.data.type === 'audio') {
        if (isSpeechActive.value && ws.value?.readyState === WebSocket.OPEN) {
          const pcm16 = float32ToPCM16(event.data.data)
          const base64 = arrayBufferToBase64(pcm16)
          ws.value.send(JSON.stringify({
            type: 'audio',
            audio: base64
          }))
        }
      }
    }

    source.connect(audioWorkletNode.value)

    const wsUrl = `ws://localhost:3001/robot`
    ws.value = new WebSocket(wsUrl)

    ws.value.onopen = () => {
      console.log('✅ Connected to robot server')
      isConnected.value = true
      isConnecting.value = false
      startBlinking()
      startSilenceCheck()
    }

    ws.value.onmessage = async (event) => {
      const message = JSON.parse(event.data)
      handleServerMessage(message)
    }

    ws.value.onerror = (err) => {
      console.error('WebSocket error:', err)
      error.value = 'Erreur de connexion au serveur'
      isConnecting.value = false
    }

    ws.value.onclose = () => {
      console.log('Disconnected from robot server')
      isConnected.value = false
      stopBlinking()
      stopSilenceCheck()
    }

  } catch (err: any) {
    console.error('Connection error:', err)
    error.value = err.message || 'Erreur lors de la connexion'
    isConnecting.value = false
  }
}

const handleVAD = (isSpeech: boolean) => {
  vadActive.value = isSpeech
  if (isSpeech) {
    lastSpeechTime.value = Date.now()
  }
}

const handleSpeechStart = (prefixBuffer: Float32Array[]) => {
  const now = Date.now()
  
  if (now - lastSpeechEndTime.value < VAD_CONFIG.minRestartDelayMs) {
    console.log(`⏸️ Ignoring speech start (too soon after last end: ${now - lastSpeechEndTime.value}ms)`)
    return
  }
  
  if (isSpeechActive.value) return
  
  console.log('🎤 Speech started')
  isSpeechActive.value = true
  prefixPaddingSent.value = false
  
  if (robotState.value === 'speaking') {
    triggerBargein()
  }
  
  if (ws.value?.readyState === WebSocket.OPEN) {
    ws.value.send(JSON.stringify({ type: 'user_audio_start' }))
    
    if (prefixBuffer.length > 0 && !prefixPaddingSent.value) {
      console.log(`📦 Sending ${prefixBuffer.length} prefix padding chunks (${VAD_CONFIG.prefixPaddingMs}ms)`)
      for (const chunk of prefixBuffer) {
        const pcm16 = float32ToPCM16(chunk)
        const base64 = arrayBufferToBase64(pcm16)
        ws.value.send(JSON.stringify({
          type: 'audio',
          audio: base64
        }))
      }
      prefixPaddingSent.value = true
    }
  }
}

const handleSpeechStop = () => {
  lastSpeechEndTime.value = Date.now()
}


const stopSpeech = () => {
  if (!isSpeechActive.value) return
  
  console.log('🎤 Speech stopped')
  isSpeechActive.value = false
  
  if (ws.value?.readyState === WebSocket.OPEN) {
    ws.value.send(JSON.stringify({ type: 'user_turn_end' }))
  }
}

const startSilenceCheck = () => {
  stopSilenceCheck()
  silenceCheckInterval.value = window.setInterval(() => {
    if (isSpeechActive.value && lastSpeechTime.value) {
      const silenceDuration = Date.now() - lastSpeechTime.value
      if (silenceDuration >= VAD_CONFIG.silenceDurationMs) {
        stopSpeech()
      }
    }
  }, 50)
}

const stopSilenceCheck = () => {
  if (silenceCheckInterval.value) {
    clearInterval(silenceCheckInterval.value)
    silenceCheckInterval.value = null
  }
}

const triggerBargein = () => {
  console.log('🛑 Barge-in triggered')
  
  playbackToken.value++
  
  if (currentSourceNode.value) {
    try {
      currentSourceNode.value.stop()
      currentSourceNode.value = null
    } catch (e) {
      console.warn('Source already stopped')
    }
  }
  
  audioQueue.value = []
  isPlaying.value = false
  
  if (ws.value?.readyState === WebSocket.OPEN) {
    ws.value.send(JSON.stringify({ type: 'barge_in' }))
  }
}

const handleServerMessage = async (message: any) => {
  switch (message.type) {
    case 'state':
      robotState.value = message.state
      break

    case 'stop_output':
      playbackToken.value++
      
      if (currentSourceNode.value) {
        try {
          currentSourceNode.value.stop()
          currentSourceNode.value = null
        } catch (e) {
          console.warn('Source already stopped')
        }
      }
      audioQueue.value = []
      isPlaying.value = false
      robotState.value = 'idle'
      break

    case 'transcription':
      if (message.role === 'user') {
        currentTranscript.value.user = message.text
      } else if (message.role === 'assistant') {
        currentTranscript.value.assistant = message.text
        correctedSentence.value = message.text
      }
      break

    case 'transcript_delta':
      if (message.role === 'assistant') {
        currentTranscript.value.assistant += message.delta
      }
      break

    case 'audio':
      if (audioContext.value) {
        const audioData = base64ToArrayBuffer(message.audio)
        const float32Array = pcm16ToFloat32(audioData)
        audioQueue.value.push(float32Array)
        
        if (!isPlaying.value) {
          playAudioQueue()
        }
      }
      break

    case 'ai_turn_end':
      console.log('✅ AI turn ended')
      break

    case 'metrics':
      metrics.value = message.data
      break

    case 'error':
      error.value = message.error
      break
  }
}

const playAudioQueue = async () => {
  if (!audioContext.value || isPlaying.value) return
  
  const currentToken = playbackToken.value
  isPlaying.value = true
  
  while (audioQueue.value.length > 0) {
    if (playbackToken.value !== currentToken) {
      console.log('⏹️ Playback stopped (token changed)')
      break
    }
    
    if (isSpeechActive.value) {
      audioQueue.value = []
      break
    }
    
    const audioData = audioQueue.value.shift()
    if (audioData) {
      await playAudioChunk(audioData, currentToken)
    }
  }
  
  isPlaying.value = false
}

const playAudioChunk = (float32Array: Float32Array, expectedToken: number): Promise<void> => {
  return new Promise((resolve) => {
    if (!audioContext.value || playbackToken.value !== expectedToken) {
      resolve()
      return
    }

    const audioBuffer = audioContext.value.createBuffer(1, float32Array.length, 24000)
    audioBuffer.getChannelData(0).set(float32Array)
    
    const source = audioContext.value.createBufferSource()
    source.buffer = audioBuffer
    source.connect(audioContext.value.destination)
    source.onended = () => {
      if (currentSourceNode.value === source) {
        currentSourceNode.value = null
      }
      resolve()
    }
    
    currentSourceNode.value = source
    source.start()
  })
}

const requestMetrics = () => {
  if (ws.value?.readyState === WebSocket.OPEN) {
    ws.value.send(JSON.stringify({ type: 'get_metrics' }))
  }
}

const float32ToPCM16 = (float32Array: Float32Array): ArrayBuffer => {
  const pcm16 = new Int16Array(float32Array.length)
  for (let i = 0; i < float32Array.length; i++) {
    const s = Math.max(-1, Math.min(1, float32Array[i]))
    pcm16[i] = s < 0 ? s * 0x8000 : s * 0x7FFF
  }
  return pcm16.buffer
}

const pcm16ToFloat32 = (arrayBuffer: ArrayBuffer): Float32Array => {
  const pcm16 = new Int16Array(arrayBuffer)
  const float32 = new Float32Array(pcm16.length)
  for (let i = 0; i < pcm16.length; i++) {
    float32[i] = pcm16[i] / (pcm16[i] < 0 ? 0x8000 : 0x7FFF)
  }
  return float32
}

const arrayBufferToBase64 = (buffer: ArrayBuffer): string => {
  const bytes = new Uint8Array(buffer)
  let binary = ''
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i])
  }
  return btoa(binary)
}

const base64ToArrayBuffer = (base64: string): ArrayBuffer => {
  const binary = atob(base64)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return bytes.buffer
}

const disconnect = () => {
  if (ws.value) {
    ws.value.close()
    ws.value = null
  }
  
  stopSilenceCheck()
  
  if (audioWorkletNode.value) {
    audioWorkletNode.value.disconnect()
    audioWorkletNode.value = null
  }
  
  if (mediaStream.value) {
    mediaStream.value.getTracks().forEach(track => track.stop())
    mediaStream.value = null
  }
  
  if (audioContext.value) {
    audioContext.value.close()
    audioContext.value = null
  }
  
  stopBlinking()
  isConnected.value = false
  robotState.value = 'idle'
  audioQueue.value = []
  isPlaying.value = false
  isSpeechActive.value = false
  vadActive.value = false
}

onUnmounted(() => {
  disconnect()
})
</script>

<style scoped>
.robot-view {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem;
  display: flex;
  justify-content: center;
  align-items: center;
}

.robot-container {
  max-width: 900px;
  width: 100%;
  background: white;
  border-radius: 24px;
  padding: 2rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.robot-header {
  text-align: center;
  margin-bottom: 2rem;
}

.robot-header h1 {
  font-size: 2.5rem;
  margin: 0 0 0.5rem 0;
  color: #333;
}

.scenario {
  color: #666;
  font-size: 1.1rem;
}

.robot-visual {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 2rem;
  background: #f8f9fa;
  border-radius: 16px;
  margin-bottom: 2rem;
  transition: all 0.3s ease;
  position: relative;
}

.robot-visual.listening {
  background: #e3f2fd;
}

.robot-visual.thinking {
  background: #fff3e0;
}

.robot-visual.speaking {
  background: #e8f5e9;
}

.robot-avatar {
  position: relative;
  width: 200px;
  height: 200px;
  margin-bottom: 1rem;
}

.robot-face {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.robot-eyes {
  display: flex;
  gap: 40px;
  margin-bottom: 20px;
}

.eye {
  width: 30px;
  height: 30px;
  background: white;
  border-radius: 50%;
  position: relative;
  transition: all 0.15s ease;
}

.eye::after {
  content: '';
  position: absolute;
  width: 15px;
  height: 15px;
  background: #333;
  border-radius: 50%;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.eye.blinking {
  height: 3px;
}

.robot-mouth {
  width: 60px;
  height: 30px;
  border: 4px solid white;
  border-top: none;
  border-radius: 0 0 60px 60px;
  transition: all 0.3s ease;
}

.robot-mouth.speaking {
  animation: talking 0.3s infinite alternate;
}

@keyframes talking {
  from { height: 30px; }
  to { height: 15px; }
}

.sound-waves {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  gap: 10px;
}

.wave {
  width: 4px;
  height: 20px;
  background: rgba(102, 126, 234, 0.6);
  border-radius: 2px;
  animation: wave 0.6s infinite ease-in-out;
}

.wave:nth-child(2) {
  animation-delay: 0.2s;
}

.wave:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes wave {
  0%, 100% { height: 20px; }
  50% { height: 60px; }
}

.state-indicator {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.2rem;
  font-weight: 600;
}

.state-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #ccc;
}

.state-dot.idle {
  background: #9e9e9e;
}

.state-dot.listening {
  background: #2196f3;
  animation: pulse 1s infinite;
}

.state-dot.thinking {
  background: #ff9800;
  animation: pulse 1s infinite;
}

.state-dot.speaking {
  background: #4caf50;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.vad-indicator {
  position: absolute;
  top: 1rem;
  right: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: rgba(244, 67, 54, 0.1);
  border-radius: 20px;
  font-size: 0.9rem;
  color: #f44336;
}

.vad-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #f44336;
  animation: pulse 1s infinite;
}

.conversation-display {
  margin-bottom: 2rem;
}

.transcript-box {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1.5rem;
  min-height: 120px;
  margin-bottom: 1rem;
}

.transcript-item {
  margin-bottom: 1rem;
  padding: 0.75rem;
  border-radius: 8px;
}

.transcript-item.user {
  background: #e3f2fd;
  color: #1565c0;
}

.transcript-item.assistant {
  background: #e8f5e9;
  color: #2e7d32;
}

.transcript-placeholder {
  color: #999;
  text-align: center;
  padding: 2rem;
}

.correction-box {
  background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
  color: white;
  padding: 1rem;
  border-radius: 12px;
}

.correction-label {
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.correction-text {
  font-size: 1.1rem;
}

.metrics-box {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.metrics-box h3 {
  margin: 0 0 1rem 0;
  color: #333;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.metric {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.metric-label {
  font-size: 0.85rem;
  color: #666;
}

.metric-value {
  font-size: 1.5rem;
  font-weight: 600;
  color: #667eea;
}

.controls {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 2rem;
}

.btn-primary, .btn-danger, .btn-secondary {
  padding: 1rem 2rem;
  font-size: 1.2rem;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  min-width: 200px;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-danger {
  background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%);
  color: white;
}

.btn-danger:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(244, 67, 54, 0.3);
}

.btn-secondary {
  background: linear-gradient(135deg, #9e9e9e 0%, #757575 100%);
  color: white;
}

.btn-secondary:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(158, 158, 158, 0.3);
}

.error-message {
  background: #ffebee;
  color: #c62828;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  text-align: center;
}

.instructions {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 12px;
}

.instructions h3 {
  margin-top: 0;
  color: #333;
}

.instructions ul {
  margin: 0;
  padding-left: 1.5rem;
}

.instructions li {
  margin-bottom: 0.5rem;
  color: #666;
}
</style>
