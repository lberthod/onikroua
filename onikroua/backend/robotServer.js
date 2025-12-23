require('dotenv').config();
const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');

const ROBOT_PROMPTS = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'robotPrompts.json'), 'utf8')
);

const MAX_AUDIO_DURATION_MS = 12000;
const MAX_TURNS_PER_MINUTE = 20;
const MAX_USER_AUDIO_PER_MINUTE_MS = 45000;
const MAX_AI_AUDIO_PER_MINUTE_MS = 45000;
const AUDIO_TOKENS_PER_SECOND = 10;
const COST_PER_1M_INPUT_TOKENS = 0.60;
const COST_PER_1M_OUTPUT_TOKENS = 2.40;
const AI_SAMPLE_RATE = 24000;
const BYTES_PER_SAMPLE = 2;
const CHANNELS = 1;
const MIN_TURN_DURATION_MS = 800;
const COOLDOWN_DURATION_MS = 3000;

class SessionMetrics {
  constructor() {
    this.userAudioDurationMs = 0;
    this.aiAudioDurationMs = 0;
    this.turnCount = 0;
    this.startTime = Date.now();
    this.lastTurnTime = Date.now();
    this.userAudioChunks = 0;
    this.aiAudioChunks = 0;
    this.lastMinuteStartTime = Date.now();
    this.userAudioThisMinuteMs = 0;
    this.aiAudioThisMinuteMs = 0;
  }

  addUserAudio(durationMs) {
    this.resetMinuteCountersIfNeeded();
    this.userAudioDurationMs += durationMs;
    this.userAudioThisMinuteMs += durationMs;
    this.userAudioChunks++;
  }

  addAiAudio(durationMs) {
    this.resetMinuteCountersIfNeeded();
    this.aiAudioDurationMs += durationMs;
    this.aiAudioThisMinuteMs += durationMs;
    this.aiAudioChunks++;
  }

  resetMinuteCountersIfNeeded() {
    const now = Date.now();
    if (now - this.lastMinuteStartTime >= 60000) {
      this.lastMinuteStartTime = now;
      this.userAudioThisMinuteMs = 0;
      this.aiAudioThisMinuteMs = 0;
    }
  }

  isUserAudioLimitReached() {
    this.resetMinuteCountersIfNeeded();
    return this.userAudioThisMinuteMs >= MAX_USER_AUDIO_PER_MINUTE_MS;
  }

  isAiAudioLimitReached() {
    this.resetMinuteCountersIfNeeded();
    return this.aiAudioThisMinuteMs >= MAX_AI_AUDIO_PER_MINUTE_MS;
  }

  incrementTurn() {
    this.turnCount++;
    this.lastTurnTime = Date.now();
  }

  getTurnsPerMinute() {
    const elapsedMinutes = (Date.now() - this.startTime) / 60000;
    const safeMinutes = Math.max(elapsedMinutes, 1);
    return this.turnCount / safeMinutes;
  }

  getEstimatedCost() {
    const userTokens = (this.userAudioDurationMs / 1000) * AUDIO_TOKENS_PER_SECOND;
    const aiTokens = (this.aiAudioDurationMs / 1000) * AUDIO_TOKENS_PER_SECOND;
    const userCost = (userTokens / 1000000) * COST_PER_1M_INPUT_TOKENS;
    const aiCost = (aiTokens / 1000000) * COST_PER_1M_OUTPUT_TOKENS;
    return userCost + aiCost;
  }

  getSummary() {
    return {
      userAudioSeconds: (this.userAudioDurationMs / 1000).toFixed(2),
      aiAudioSeconds: (this.aiAudioDurationMs / 1000).toFixed(2),
      turnCount: this.turnCount,
      turnsPerMinute: this.getTurnsPerMinute().toFixed(2),
      estimatedCostUSD: this.getEstimatedCost().toFixed(4),
      sessionDurationSeconds: ((Date.now() - this.startTime) / 1000).toFixed(0),
      userChunks: this.userAudioChunks,
      aiChunks: this.aiAudioChunks
    };
  }
}

class RobotSession {
  constructor(ws, clientId, language = 'en') {
    this.ws = ws;
    this.clientId = clientId;
    this.language = language;
    this.realtimeClient = null;
    this.state = 'idle';
    this.isConnecting = false;
    this.metrics = new SessionMetrics();
    this.currentResponseStartTime = null;
    this.responseTimeoutId = null;
    this.isReceivingUserAudio = false;
    this.userAudioStartTime = null;
    this.userAudioChunksThisTurn = 0;
    this.cooldownUntil = 0;
    this.responseActive = false;
    this.cancelling = false;
  }

  async connect() {
    if (this.isConnecting || this.realtimeClient) {
      return;
    }

    this.isConnecting = true;
    
    try {
      this.realtimeClient = new WebSocket(
        `wss://api.openai.com/v1/realtime?model=gpt-realtime-mini-2025-12-15`,
        {
          headers: {
            'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
            'OpenAI-Beta': 'realtime=v1'
          }
        }
      );

      this.realtimeClient.on('open', () => {
        console.log(`✅ [${this.clientId}] Connected to OpenAI Realtime API`);
        this.isConnecting = false;
        
        const promptConfig = ROBOT_PROMPTS[this.language] || ROBOT_PROMPTS.en;
        
        this.realtimeClient.send(JSON.stringify({
          type: 'session.update',
          session: {
            modalities: ['text', 'audio'],
            instructions: promptConfig.instructions,
            voice: 'alloy',
            input_audio_format: 'pcm16',
            output_audio_format: 'pcm16',
            input_audio_transcription: {
              model: 'whisper-1',
              language: promptConfig.transcriptionLanguage
            },
            turn_detection: null,
            temperature: 0.7,
            max_response_output_tokens: 220
          }
        }));

        this.sendToClient({
          type: 'session_ready'
        });

        this.realtimeClient.send(JSON.stringify({
          type: 'response.create',
          response: {
            modalities: ['text', 'audio'],
            instructions: promptConfig.greeting
          }
        }));

        this.setState('idle');
      });

      this.realtimeClient.on('message', (data) => {
        this.handleRealtimeMessage(JSON.parse(data.toString()));
      });

      this.realtimeClient.on('error', (error) => {
        console.error(`❌ [${this.clientId}] Realtime API error:`, error);
        this.sendToClient({
          type: 'error',
          error: 'Connection error with AI service'
        });
      });

      this.realtimeClient.on('close', () => {
        console.log(`🔌 [${this.clientId}] Disconnected from OpenAI Realtime API`);
        this.logMetrics();
        this.realtimeClient = null;
        this.isConnecting = false;
      });

    } catch (error) {
      console.error(`❌ [${this.clientId}] Failed to connect to Realtime API:`, error);
      this.isConnecting = false;
      this.sendToClient({
        type: 'error',
        error: 'Failed to initialize AI service'
      });
    }
  }

  handleRealtimeMessage(message) {
    switch (message.type) {
      case 'session.created':
      case 'session.updated':
        console.log(`📝 [${this.clientId}] Session ready`);
        break;

      case 'input_audio_buffer.speech_started':
        if (this.state === 'speaking') {
          this.handleBargein('server_vad');
        }
        break;

      case 'input_audio_buffer.speech_stopped':
        break;

      case 'conversation.item.input_audio_transcription.completed':
        this.sendToClient({
          type: 'transcription',
          text: message.transcript,
          role: 'user'
        });
        break;

      case 'response.audio_transcript.delta':
        this.sendToClient({
          type: 'transcript_delta',
          delta: message.delta,
          role: 'assistant'
        });
        break;

      case 'response.audio_transcript.done':
        this.sendToClient({
          type: 'transcription',
          text: message.transcript,
          role: 'assistant'
        });
        break;

      case 'response.audio.delta':
        if (this.state !== 'speaking') {
          this.setState('speaking');
          this.currentResponseStartTime = Date.now();
          this.startResponseTimeout();
          
          this.sendToClient({
            type: 'ai_response_start'
          });
        }
        
        if (!this.cancelling && this.metrics.isAiAudioLimitReached()) {
          console.warn(`⚠️ [${this.clientId}] AI audio limit reached this minute`);
          this.handleBargein('ai_limit');
          return;
        }
        
        const base64Audio = message.delta;
        const pcmBytes = Buffer.from(base64Audio, 'base64').length;
        const audioDurationMs = (pcmBytes / (AI_SAMPLE_RATE * BYTES_PER_SAMPLE * CHANNELS)) * 1000;
        this.metrics.addAiAudio(audioDurationMs);
        
        this.sendToClient({
          type: 'audio',
          audio: message.delta
        });
        break;

      case 'response.audio.done':
      case 'response.done':
        this.clearResponseTimeout();
        this.responseActive = false;
        this.cancelling = false;
        this.setState('idle');
        this.sendToClient({
          type: 'state',
          state: 'idle'
        });
        this.sendToClient({
          type: 'ai_turn_end'
        });
        break;

      case 'response.done':
        this.clearResponseTimeout();
        this.setState('idle');
        this.metrics.incrementTurn();
        break;

      case 'error':
        console.error(`❌ [${this.clientId}] Realtime API error:`, message.error);
        this.sendToClient({
          type: 'error',
          error: message.error.message
        });
        break;
    }
  }

  handleClientMessage(message) {
    if (!this.realtimeClient || this.realtimeClient.readyState !== WebSocket.OPEN) {
      console.warn(`⚠️ [${this.clientId}] Realtime client not ready`);
      return;
    }

    switch (message.type) {
      case 'user_audio_start':
        const now = Date.now();
        
        if (now < this.cooldownUntil) {
          const remainingMs = this.cooldownUntil - now;
          console.warn(`⚠️ [${this.clientId}] In cooldown (${remainingMs}ms remaining)`);
          this.sendToClient({
            type: 'error',
            error: 'Let\'s pause one second.'
          });
          return;
        }
        
        if (this.metrics.isUserAudioLimitReached()) {
          console.warn(`⚠️ [${this.clientId}] User audio limit reached this minute`);
          this.cooldownUntil = now + COOLDOWN_DURATION_MS;
          this.sendToClient({
            type: 'error',
            error: 'Let\'s pause one second.'
          });
          return;
        }
        
        this.realtimeClient.send(JSON.stringify({
          type: 'input_audio_buffer.clear'
        }));
        
        this.isReceivingUserAudio = true;
        this.userAudioStartTime = now;
        this.userAudioChunksThisTurn = 0;
        console.log(`🎤 [${this.clientId}] User audio started`);
        
        this.setState('listening');
        this.sendToClient({
          type: 'state',
          state: 'listening'
        });
        break;

      case 'user_audio_stop':
      case 'user_turn_end':
        const turnEnd = Date.now();
        const turnStart = this.userAudioStartTime;
        const turnChunks = this.userAudioChunksThisTurn;
        const turnDuration = turnStart ? turnEnd - turnStart : 0;
        
        if (this.isReceivingUserAudio && turnStart) {
          this.metrics.addUserAudio(turnDuration);
          console.log(`🎤 [${this.clientId}] User audio stopped (${turnDuration}ms)`);
        }
        
        this.isReceivingUserAudio = false;
        this.userAudioStartTime = null;
        
        if (this.metrics.getTurnsPerMinute() > MAX_TURNS_PER_MINUTE) {
          console.warn(`⚠️ [${this.clientId}] Rate limit: ${this.metrics.getTurnsPerMinute().toFixed(1)} turns/min`);
          this.sendToClient({
            type: 'error',
            error: 'Please slow down. Too many turns per minute.'
          });
          return;
        }
        
        if (message.type === 'user_turn_end') {
          
          if (turnDuration < MIN_TURN_DURATION_MS || turnChunks === 0) {
            console.warn(`⚠️ [${this.clientId}] Turn too short (${turnDuration}ms) or empty (${turnChunks} chunks) - ignoring`);
            this.realtimeClient.send(JSON.stringify({
              type: 'input_audio_buffer.clear'
            }));
            this.setState('idle');
            this.sendToClient({
              type: 'state',
              state: 'idle'
            });
            return;
          }
          
          console.log(`✅ [${this.clientId}] Committing user turn (${turnDuration}ms, ${turnChunks} chunks)`);
          this.setState('thinking');
          this.sendToClient({
            type: 'state',
            state: 'thinking'
          });
          
          this.realtimeClient.send(JSON.stringify({
            type: 'input_audio_buffer.commit'
          }));
          
          if (this.responseActive) {
            console.warn(`⚠️ [${this.clientId}] Response already active, skipping response.create`);
            return;
          }
          
          this.responseActive = true;
          this.realtimeClient.send(JSON.stringify({
            type: 'response.create',
            response: {
              modalities: ['text', 'audio']
            }
          }));
        }
        break;

      case 'audio':
        if (!this.isReceivingUserAudio) {
          console.warn(`⚠️ [${this.clientId}] Audio received without user_audio_start`);
          return;
        }
        
        this.userAudioChunksThisTurn++;
        
        this.realtimeClient.send(JSON.stringify({
          type: 'input_audio_buffer.append',
          audio: message.audio
        }));
        break;

      case 'barge_in':
        this.handleBargein('client');
        break;

      case 'get_metrics':
        this.sendToClient({
          type: 'metrics',
          data: this.metrics.getSummary()
        });
        break;
    }
  }

  handleBargein(source) {
    if (this.cancelling) return;
    
    console.log(`🛑 [${this.clientId}] Barge-in triggered (${source})`);
    this.cancelling = true;
    
    this.clearResponseTimeout();
    
    this.sendToClient({
      type: 'stop_output'
    });
    
    if (this.realtimeClient && this.realtimeClient.readyState === WebSocket.OPEN) {
      if (this.responseActive) {
        this.realtimeClient.send(JSON.stringify({
          type: 'response.cancel'
        }));
      }
      
      this.realtimeClient.send(JSON.stringify({
        type: 'input_audio_buffer.clear'
      }));
    }
    
    this.responseActive = false;
    this.setState('idle');
  }

  startResponseTimeout() {
    this.clearResponseTimeout();
    this.responseTimeoutId = setTimeout(() => {
      const elapsed = Date.now() - this.currentResponseStartTime;
      console.warn(`⏱️ [${this.clientId}] Response timeout after ${elapsed}ms`);
      this.handleBargein('timeout');
    }, MAX_AUDIO_DURATION_MS);
  }

  clearResponseTimeout() {
    if (this.responseTimeoutId) {
      clearTimeout(this.responseTimeoutId);
      this.responseTimeoutId = null;
    }
  }

  setState(newState) {
    this.state = newState;
    console.log(`🤖 [${this.clientId}] State: ${newState}`);
  }

  sendToClient(message) {
    if (this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    }
  }

  logMetrics() {
    const summary = this.metrics.getSummary();
    console.log(`\n📊 [${this.clientId}] Session Metrics:`);
    console.log(`   User Audio: ${summary.userAudioSeconds}s (${summary.userChunks} chunks)`);
    console.log(`   AI Audio: ${summary.aiAudioSeconds}s (${summary.aiChunks} chunks)`);
    console.log(`   Turns: ${summary.turnCount} (${summary.turnsPerMinute}/min)`);
    console.log(`   Duration: ${summary.sessionDurationSeconds}s`);
    console.log(`   Estimated Cost: $${summary.estimatedCostUSD}\n`);
  }

  disconnect() {
    this.clearResponseTimeout();
    this.logMetrics();
    
    if (this.realtimeClient) {
      this.realtimeClient.close();
      this.realtimeClient = null;
    }
  }
}

let clientIdCounter = 0;

function createRobotWebSocketServer(server) {
  const wss = new WebSocket.Server({ 
    server,
    path: '/robot'
  });

  wss.on('connection', async (ws, req) => {
    const clientId = `client-${++clientIdCounter}`;
    const url = new URL(req.url, `http://${req.headers.host}`);
    const language = url.searchParams.get('lang') || 'en';
    
    console.log(`🔗 [${clientId}] New robot client connected (language: ${language})`);
    
    const session = new RobotSession(ws, clientId, language);
    
    // Attendre que la connexion OpenAI soit établie
    try {
      await session.connect();
    } catch (error) {
      console.error(`❌ [${clientId}] Failed to connect to OpenAI:`, error);
      ws.close();
      return;
    }

    ws.on('message', (data) => {
      try {
        const message = JSON.parse(data.toString());
        session.handleClientMessage(message);
      } catch (error) {
        console.error(`❌ [${clientId}] Error parsing client message:`, error);
      }
    });

    ws.on('close', () => {
      console.log(`👋 [${clientId}] Robot client disconnected`);
      session.disconnect();
    });

    ws.on('error', (error) => {
      console.error(`❌ [${clientId}] WebSocket error:`, error);
    });
  });

  console.log('🤖 Robot WebSocket server ready on /robot');
  return wss;
}

module.exports = { createRobotWebSocketServer };
