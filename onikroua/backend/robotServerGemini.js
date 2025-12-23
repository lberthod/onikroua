require('dotenv').config();
const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const ROBOT_PROMPTS = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'robotPrompts.json'), 'utf8')
);

const MAX_AUDIO_DURATION_MS = 12000;
const MAX_TURNS_PER_MINUTE = 20;
const MAX_USER_AUDIO_PER_MINUTE_MS = 45000;
const MAX_AI_AUDIO_PER_MINUTE_MS = 45000;
const AUDIO_TOKENS_PER_SECOND = 10;
const COST_PER_1M_INPUT_TOKENS = 0.10;
const COST_PER_1M_OUTPUT_TOKENS = 0.10;
const AI_SAMPLE_RATE = 16000; // Gemini uses 16kHz
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

class GeminiRobotSession {
  constructor(ws, clientId, language = 'en') {
    this.ws = ws;
    this.clientId = clientId;
    this.language = language;
    this.genAI = null;
    this.model = null;
    this.liveSession = null;
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
    this.audioBuffer = [];
  }

  async connect() {
    if (this.isConnecting || this.liveSession) {
      return;
    }

    this.isConnecting = true;
    
    try {
      this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      this.model = this.genAI.getGenerativeModel({ 
        model: 'gemini-2.0-flash-exp',
        systemInstruction: this.getSystemInstruction()
      });

      this.liveSession = await this.model.startChat({
        generationConfig: {
          responseModalities: 'audio',
          speechConfig: {
            voiceConfig: { prebuiltVoiceConfig: { voiceName: 'Puck' } }
          }
        }
      });

      console.log(`✅ [${this.clientId}] Connected to Gemini Live API`);
      this.isConnecting = false;
      this.setState('idle');
      
      this.sendToClient({
        type: 'session_ready'
      });

      // Send initial greeting
      await this.sendGreeting();

    } catch (error) {
      console.error(`❌ [${this.clientId}] Gemini connection error:`, error);
      this.isConnecting = false;
      this.sendToClient({
        type: 'error',
        error: 'Failed to connect to Gemini'
      });
    }
  }

  getSystemInstruction() {
    const promptConfig = ROBOT_PROMPTS[this.language] || ROBOT_PROMPTS.en;
    return promptConfig.instructions;
  }

  async sendGreeting() {
    try {
      const promptConfig = ROBOT_PROMPTS[this.language] || ROBOT_PROMPTS.en;
      const result = await this.liveSession.sendMessage(promptConfig.greeting);
      
      this.setState('speaking');
      
      for await (const chunk of result.stream) {
        const audioData = chunk.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
        if (audioData) {
          const audioDurationMs = (Buffer.from(audioData, 'base64').length / (AI_SAMPLE_RATE * BYTES_PER_SAMPLE * CHANNELS)) * 1000;
          this.metrics.addAiAudio(audioDurationMs);
          
          this.sendToClient({
            type: 'audio',
            audio: audioData
          });
        }
      }
      
      this.setState('idle');
    } catch (error) {
      console.error(`❌ [${this.clientId}] Greeting error:`, error);
    }
  }

  setState(newState) {
    this.state = newState;
    console.log(`🤖 [${this.clientId}] State: ${newState}`);
  }

  async handleClientMessage(message) {
    switch (message.type) {
      case 'user_audio_start':
        if (Date.now() < this.cooldownUntil) {
          console.warn(`⏳ [${this.clientId}] Cooldown active, ignoring audio start`);
          return;
        }

        if (this.metrics.isUserAudioLimitReached()) {
          console.warn(`⚠️ [${this.clientId}] User audio limit reached this minute`);
          this.cooldownUntil = Date.now() + COOLDOWN_DURATION_MS;
          this.sendToClient({
            type: 'error',
            error: 'Audio limit reached. Please wait.'
          });
          return;
        }

        console.log(`🎤 [${this.clientId}] User audio started`);
        this.isReceivingUserAudio = true;
        this.userAudioStartTime = Date.now();
        this.userAudioChunksThisTurn = 0;
        this.audioBuffer = [];
        this.setState('listening');
        this.sendToClient({
          type: 'state',
          state: 'listening'
        });
        break;

      case 'audio':
        if (!this.isReceivingUserAudio) {
          console.warn(`⚠️ [${this.clientId}] Audio received without user_audio_start`);
          return;
        }

        const audioData = Buffer.from(message.audio, 'base64');
        const audioDurationMs = (audioData.length / (AI_SAMPLE_RATE * BYTES_PER_SAMPLE * CHANNELS)) * 1000;
        this.metrics.addUserAudio(audioDurationMs);
        this.userAudioChunksThisTurn++;
        this.audioBuffer.push(message.audio);
        break;

      case 'user_turn_end':
        if (!this.isReceivingUserAudio) {
          return;
        }

        const turnEnd = Date.now();
        const turnDuration = this.userAudioStartTime ? turnEnd - this.userAudioStartTime : 0;
        const turnChunks = this.userAudioChunksThisTurn;

        this.isReceivingUserAudio = false;
        this.userAudioStartTime = null;
        this.userAudioChunksThisTurn = 0;

        console.log(`🎤 [${this.clientId}] User audio stopped (${turnDuration}ms)`);

        if (turnDuration < MIN_TURN_DURATION_MS || turnChunks === 0) {
          console.warn(`⚠️ [${this.clientId}] Turn too short (${turnDuration}ms) or empty (${turnChunks} chunks) - ignoring`);
          this.setState('idle');
          this.audioBuffer = [];
          return;
        }

        if (this.metrics.getTurnsPerMinute() >= MAX_TURNS_PER_MINUTE) {
          console.warn(`⚠️ [${this.clientId}] Rate limit: ${this.metrics.getTurnsPerMinute().toFixed(1)} turns/min`);
          this.cooldownUntil = Date.now() + COOLDOWN_DURATION_MS;
          this.setState('idle');
          this.audioBuffer = [];
          return;
        }

        console.log(`✅ [${this.clientId}] Committing user turn (${turnDuration}ms, ${turnChunks} chunks)`);
        this.setState('thinking');
        this.sendToClient({
          type: 'state',
          state: 'thinking'
        });

        await this.processUserAudio();
        break;

      case 'get_metrics':
        this.sendToClient({
          type: 'metrics',
          data: this.metrics.getSummary()
        });
        break;
    }
  }

  async processUserAudio() {
    if (this.audioBuffer.length === 0) return;

    try {
      // Concatenate all audio chunks
      const combinedAudio = Buffer.concat(
        this.audioBuffer.map(base64 => Buffer.from(base64, 'base64'))
      ).toString('base64');

      this.audioBuffer = [];
      this.responseActive = true;

      const result = await this.liveSession.sendMessage([
        {
          inlineData: {
            mimeType: 'audio/pcm',
            data: combinedAudio
          }
        }
      ]);

      this.setState('speaking');
      this.sendToClient({
        type: 'ai_response_start'
      });

      for await (const chunk of result.stream) {
        if (this.cancelling) break;

        const audioData = chunk.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
        if (audioData) {
          if (this.metrics.isAiAudioLimitReached()) {
            console.warn(`⚠️ [${this.clientId}] AI audio limit reached this minute`);
            break;
          }

          const audioDurationMs = (Buffer.from(audioData, 'base64').length / (AI_SAMPLE_RATE * BYTES_PER_SAMPLE * CHANNELS)) * 1000;
          this.metrics.addAiAudio(audioDurationMs);

          this.sendToClient({
            type: 'audio',
            audio: audioData
          });
        }

        const text = chunk.candidates?.[0]?.content?.parts?.[0]?.text;
        if (text) {
          this.sendToClient({
            type: 'transcription',
            text: text,
            role: 'assistant'
          });
        }
      }

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

    } catch (error) {
      console.error(`❌ [${this.clientId}] Gemini processing error:`, error);
      this.responseActive = false;
      this.cancelling = false;
      this.setState('idle');
      this.sendToClient({
        type: 'error',
        error: 'Failed to process audio'
      });
    }
  }

  sendToClient(message) {
    if (this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    }
  }

  logMetrics() {
    const summary = this.metrics.getSummary();
    console.log(`\n📊 [${this.clientId}] Session Metrics (Gemini):`);
    console.log(`   User Audio: ${summary.userAudioSeconds}s (${summary.userChunks} chunks)`);
    console.log(`   AI Audio: ${summary.aiAudioSeconds}s (${summary.aiChunks} chunks)`);
    console.log(`   Turns: ${summary.turnCount} (${summary.turnsPerMinute}/min)`);
    console.log(`   Duration: ${summary.sessionDurationSeconds}s`);
    console.log(`   Estimated Cost: $${summary.estimatedCostUSD}\n`);
  }

  disconnect() {
    this.logMetrics();
    
    if (this.liveSession) {
      this.liveSession = null;
    }
  }
}

let clientIdCounter = 0;

function createGeminiRobotWebSocketServer(server) {
  const wss = new WebSocket.Server({ 
    server,
    path: '/robot-gemini'
  });

  wss.on('connection', (ws, req) => {
    const clientId = `gemini-${++clientIdCounter}`;
    const url = new URL(req.url, `http://${req.headers.host}`);
    const language = url.searchParams.get('lang') || 'en';
    
    console.log(`🔗 [${clientId}] New Gemini robot client connected (language: ${language})`);
    
    const session = new GeminiRobotSession(ws, clientId, language);
    session.connect();

    ws.on('message', (data) => {
      try {
        const message = JSON.parse(data.toString());
        session.handleClientMessage(message);
      } catch (error) {
        console.error(`❌ [${clientId}] Error parsing client message:`, error);
      }
    });

    ws.on('close', () => {
      console.log(`👋 [${clientId}] Gemini robot client disconnected`);
      session.disconnect();
    });

    ws.on('error', (error) => {
      console.error(`❌ [${clientId}] WebSocket error:`, error);
    });
  });

  console.log('🤖 Gemini Robot WebSocket server ready on /robot-gemini');
}

module.exports = { createGeminiRobotWebSocketServer };
