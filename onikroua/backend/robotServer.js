/**
 * robotGeminiLiveServer.js
 * ------------------------------------------------------------
 * WebSocket server (/robot) that bridges a browser client to
 * Gemini Live (Vertex AI LlmBidiService) for real-time AUDIO.
 *
 * ✅ Uses OAuth via google-auth-library (ADC):
 *   - Dev (Mac):  gcloud auth application-default login
 *   - Prod (VPS): export GOOGLE_APPLICATION_CREDENTIALS=/path/sa-key.json
 *
 * ENV:
 *   GOOGLE_CLOUD_PROJECT / FIREBASE_PROJECT_ID
 *   GOOGLE_CLOUD_LOCATION (default us-central1)
 *
 * Notes:
 * - Gemini Live WS headers contain Bearer token => when token expires (~1h),
 *   we reconnect the Gemini WS automatically.
 * - We never log tokens.
 */

require('dotenv').config();
const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');
const { GoogleAuth } = require('google-auth-library');

// -----------------------------
// Prompts
// -----------------------------
const ROBOT_PROMPTS = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'robotPrompts.json'), 'utf8')
);

// -----------------------------
// Limits / metrics
// -----------------------------
const MAX_AUDIO_DURATION_MS = 12000;
const MAX_TURNS_PER_MINUTE = 20;

const MAX_USER_AUDIO_PER_MINUTE_MS = 45000;
const MAX_AI_AUDIO_PER_MINUTE_MS = 45000;

const AUDIO_TOKENS_PER_SECOND = 10; // heuristic
const COST_PER_1M_INPUT_TOKENS = 0.60;
const COST_PER_1M_OUTPUT_TOKENS = 2.40;

const AI_SAMPLE_RATE = 24000;
const BYTES_PER_SAMPLE = 2;
const CHANNELS = 1;

const MIN_TURN_DURATION_MS = 800;
const COOLDOWN_DURATION_MS = 3000;

// -----------------------------
// Google Cloud config
// -----------------------------
const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || process.env.FIREBASE_PROJECT_ID;
const LOCATION = process.env.GOOGLE_CLOUD_LOCATION || 'us-central1';
const MODEL_ID = process.env.GEMINI_LIVE_MODEL || 'gemini-live-2.5-flash-native-audio';

if (!PROJECT_ID) {
  console.warn(
    '⚠️ PROJECT_ID missing. Set GOOGLE_CLOUD_PROJECT or FIREBASE_PROJECT_ID in .env'
  );
}

// OAuth (ADC)
const auth = new GoogleAuth({
  scopes: ['https://www.googleapis.com/auth/cloud-platform'],
});

async function getBearerToken() {
  const client = await auth.getClient();
  const at = await client.getAccessToken(); // string OR { token }
  const token = typeof at === 'string' ? at : at?.token;
  if (!token) throw new Error('Failed to obtain OAuth access token (empty token).');
  return token;
}

// -----------------------------
// Metrics
// -----------------------------
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

  resetMinuteCountersIfNeeded() {
    const now = Date.now();
    if (now - this.lastMinuteStartTime >= 60000) {
      this.lastMinuteStartTime = now;
      this.userAudioThisMinuteMs = 0;
      this.aiAudioThisMinuteMs = 0;
    }
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
    const userCost = (userTokens / 1_000_000) * COST_PER_1M_INPUT_TOKENS;
    const aiCost = (aiTokens / 1_000_000) * COST_PER_1M_OUTPUT_TOKENS;
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
      aiChunks: this.aiAudioChunks,
    };
  }
}

// -----------------------------
// Robot Session
// -----------------------------
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

    // reconnect guard
    this._reconnectTimer = null;
    this._closedByUs = false;
  }

  // -----------------------------
  // Connection to Gemini Live
  // -----------------------------
  async connect() {
    if (this.isConnecting || this.realtimeClient) return;
    if (!PROJECT_ID) throw new Error('Missing PROJECT_ID (GOOGLE_CLOUD_PROJECT/FIREBASE_PROJECT_ID).');

    this.isConnecting = true;
    this._closedByUs = false;

    try {
      const accessToken = await getBearerToken();

      const modelPath = `projects/${PROJECT_ID}/locations/${LOCATION}/publishers/google/models/${MODEL_ID}`;
      const wsUrl = `wss://${LOCATION}-aiplatform.googleapis.com/ws/google.cloud.aiplatform.v1beta1.LlmBidiService/BidiGenerateContent`;

      this.realtimeClient = new WebSocket(wsUrl, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
      });

      this.realtimeClient.on('open', () => {
        console.log(`✅ [${this.clientId}] Connected to Gemini Live API`);
        this.isConnecting = false;

        const promptConfig = ROBOT_PROMPTS[this.language] || ROBOT_PROMPTS.en;
        const voiceName = this.language === 'fr' ? 'Charon' : 'Puck';

        const setupMessage = {
          setup: {
            model: modelPath,
            generation_config: {
              response_modalities: ['AUDIO'],
              speech_config: {
                voice_config: {
                  prebuilt_voice_config: { voice_name: voiceName },
                },
              },
              temperature: 0.7,
              max_output_tokens: 220,
            },
            system_instruction: {
              parts: [{ text: promptConfig.instructions }],
            },
            realtime_input_config: {
              automatic_activity_detection: {},
              activity_handling: 'START_OF_ACTIVITY_INTERRUPTS',
            },
            input_audio_transcription: {},
            output_audio_transcription: {},
          },
        };

        console.log(`📤 [${this.clientId}] Sending setup...`);
        // tiny delay helps avoid edge buffering issues
        setTimeout(() => {
          if (this.realtimeClient && this.realtimeClient.readyState === WebSocket.OPEN) {
            this.realtimeClient.send(JSON.stringify(setupMessage));
          }
        }, 50);
      });

      this.realtimeClient.on('message', (data) => {
        try {
          const message = JSON.parse(data.toString());
          this.handleRealtimeMessage(message);
        } catch (error) {
          console.error(`❌ [${this.clientId}] Message parse error:`, error);
        }
      });

      this.realtimeClient.on('error', (error) => {
        console.error(`❌ [${this.clientId}] Gemini WS error:`, error?.message || error);
        this.sendToClient({ type: 'error', error: 'Connection error with AI service' });
      });

      this.realtimeClient.on('close', (code, reason) => {
        const r = reason?.toString?.() || '';
        console.log(`🔌 [${this.clientId}] Gemini WS closed - Code: ${code}, Reason: ${r}`);

        this.realtimeClient = null;
        this.isConnecting = false;

        // If we purposely closed, do not reconnect
        if (this._closedByUs) {
          this._closedByUs = false;
          return;
        }

        // Reconnect on auth/network-ish closes
        const looksLikeAuth =
          code === 1008 || code === 4401 || code === 4403 ||
          /UNAUTHENTICATED|CREDENTIALS|access token|permission|denied|Forbidden|Unauthorized/i.test(r);

        const looksLikeTransient =
          code === 1006 || code === 1011 || /goAway|internal|timeout|temporarily/i.test(r);

        if (looksLikeAuth || looksLikeTransient) {
          this.scheduleReconnect(looksLikeAuth ? 800 : 1200);
        }
      });
    } catch (error) {
      console.error(`❌ [${this.clientId}] Failed to connect to Gemini Live:`, error);
      this.isConnecting = false;
      this.sendToClient({ type: 'error', error: 'Failed to initialize AI service' });
      this.scheduleReconnect(1500);
    }
  }

  scheduleReconnect(delayMs = 1000) {
    if (this._reconnectTimer) return;
    console.log(`🔁 [${this.clientId}] Reconnecting in ${delayMs}ms...`);
    this._reconnectTimer = setTimeout(async () => {
      this._reconnectTimer = null;
      try {
        await this.connect();
      } catch (e) {
        console.error(`❌ [${this.clientId}] Reconnect failed:`, e);
      }
    }, delayMs);
  }

  // -----------------------------
  // Gemini message handling
  // -----------------------------
  handleRealtimeMessage(message) {
    // Setup done
    if (message.setupComplete) {
      console.log(`📝 [${this.clientId}] Session setup complete`);
      this.sendToClient({ type: 'session_ready' });

      const promptConfig = ROBOT_PROMPTS[this.language] || ROBOT_PROMPTS.en;

      // Send a greeting as an initial user turn (text)
      this.safeSendGemini({
        clientContent: {
          turns: [
            {
              role: 'user',
              parts: [{ text: promptConfig.greeting }],
            },
          ],
          turn_complete: true,
        },
      });

      this.setState('idle');
      return;
    }

    // Server content (audio chunks etc.)
    if (message.serverContent) {
      const content = message.serverContent;

      if (content.interrupted) {
        console.log(`🛑 [${this.clientId}] Response interrupted`);
        this.clearResponseTimeout();
        this.cancelling = false;
        this.responseActive = false;
        this.setState('idle');
        this.sendToClient({ type: 'stop_output' });
        return;
      }

      if (content.model_turn?.parts?.length) {
        for (const part of content.model_turn.parts) {
          // audio inline_data
          if (part.inline_data?.data) {
            if (this.state !== 'speaking') {
              this.setState('speaking');
              this.currentResponseStartTime = Date.now();
              this.startResponseTimeout();
              this.sendToClient({ type: 'ai_response_start' });
            }

            if (!this.cancelling && this.metrics.isAiAudioLimitReached()) {
              console.warn(`⚠️ [${this.clientId}] AI audio limit reached this minute`);
              this.handleBargein('ai_limit');
              return;
            }

            const base64Audio = part.inline_data.data;
            const pcmBytes = Buffer.from(base64Audio, 'base64').length;
            const audioDurationMs =
              (pcmBytes / (AI_SAMPLE_RATE * BYTES_PER_SAMPLE * CHANNELS)) * 1000;

            this.metrics.addAiAudio(audioDurationMs);

            this.sendToClient({ type: 'audio', audio: base64Audio });
          }
        }
      }

      if (content.turn_complete) {
        this.clearResponseTimeout();
        this.responseActive = false;
        this.cancelling = false;
        this.setState('idle');
        this.metrics.incrementTurn();
        this.sendToClient({ type: 'state', state: 'idle' });
        this.sendToClient({ type: 'ai_turn_end' });
      }
    }

    // Transcriptions
    if (message.inputTranscription?.text) {
      this.sendToClient({
        type: 'transcription',
        text: message.inputTranscription.text,
        role: 'user',
      });
    }

    if (message.outputTranscription?.text) {
      this.sendToClient({
        type: 'transcription',
        text: message.outputTranscription.text,
        role: 'assistant',
      });
    }

    if (message.usageMetadata) {
      // keep short log
      console.log(`📊 [${this.clientId}] Usage:`, {
        promptTokenCount: message.usageMetadata.promptTokenCount,
        candidatesTokenCount: message.usageMetadata.candidatesTokenCount,
        totalTokenCount: message.usageMetadata.totalTokenCount,
      });
    }

    if (message.goAway) {
      console.warn(`⚠️ [${this.clientId}] Server goAway:`, message.goAway);
    }
  }

  safeSendGemini(payload) {
    if (!this.realtimeClient || this.realtimeClient.readyState !== WebSocket.OPEN) return false;
    try {
      this.realtimeClient.send(JSON.stringify(payload));
      return true;
    } catch (e) {
      console.error(`❌ [${this.clientId}] Failed to send to Gemini:`, e);
      return false;
    }
  }

  // -----------------------------
  // Client message handling
  // -----------------------------
  handleClientMessage(message) {
    if (!this.realtimeClient || this.realtimeClient.readyState !== WebSocket.OPEN) {
      console.warn(`⚠️ [${this.clientId}] Gemini WS not ready`);
      return;
    }

    switch (message.type) {
      case 'user_audio_start': {
        const now = Date.now();

        if (now < this.cooldownUntil) {
          this.sendToClient({ type: 'error', error: "Let's pause one second." });
          return;
        }

        if (this.metrics.isUserAudioLimitReached()) {
          console.warn(`⚠️ [${this.clientId}] User audio limit reached this minute`);
          this.cooldownUntil = now + COOLDOWN_DURATION_MS;
          this.sendToClient({ type: 'error', error: "Let's pause one second." });
          return;
        }

        this.isReceivingUserAudio = true;
        this.userAudioStartTime = now;
        this.userAudioChunksThisTurn = 0;

        console.log(`🎤 [${this.clientId}] User audio started`);
        this.setState('listening');
        this.sendToClient({ type: 'state', state: 'listening' });
        break;
      }

      case 'user_audio_stop':
      case 'user_turn_end': {
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
          console.warn(
            `⚠️ [${this.clientId}] Rate limit: ${this.metrics.getTurnsPerMinute().toFixed(1)} turns/min`
          );
          this.sendToClient({
            type: 'error',
            error: 'Please slow down. Too many turns per minute.',
          });
          return;
        }

        if (message.type === 'user_turn_end') {
          if (turnDuration < MIN_TURN_DURATION_MS || turnChunks === 0) {
            console.warn(
              `⚠️ [${this.clientId}] Turn too short (${turnDuration}ms) or empty (${turnChunks} chunks) - ignoring`
            );
            this.setState('idle');
            this.sendToClient({ type: 'state', state: 'idle' });
            return;
          }

          console.log(
            `✅ [${this.clientId}] Committing user turn (${turnDuration}ms, ${turnChunks} chunks)`
          );

          this.setState('thinking');
          this.sendToClient({ type: 'state', state: 'thinking' });

          if (this.responseActive) {
            console.warn(`⚠️ [${this.clientId}] Response already active`);
            return;
          }

          // Commit: tell Gemini the turn is complete.
          // NOTE: For Live, server uses VAD too; but we keep an explicit end.
          this.safeSendGemini({
            clientContent: { turn_complete: true },
          });

          this.responseActive = true;
        }
        break;
      }

      case 'audio': {
        if (!this.isReceivingUserAudio) {
          console.warn(`⚠️ [${this.clientId}] Audio received without user_audio_start`);
          return;
        }

        this.userAudioChunksThisTurn++;

        // message.audio expected base64 PCM16 mono 16k or 24k depending on your client.
        // You set mime_type audio/pcm; ensure your client actually sends PCM16 little-endian.
        this.safeSendGemini({
          realtimeInput: {
            media_chunks: [
              {
                mime_type: 'audio/pcm',
                data: message.audio,
              },
            ],
          },
        });
        break;
      }

      case 'barge_in':
        this.handleBargein('client');
        break;

      case 'get_metrics':
        this.sendToClient({ type: 'metrics', data: this.metrics.getSummary() });
        break;

      default:
        // ignore
        break;
    }
  }

  // -----------------------------
  // Barge-in / cancel
  // -----------------------------
  handleBargein(source) {
    if (this.cancelling) return;

    console.log(`🛑 [${this.clientId}] Barge-in triggered (${source})`);
    this.cancelling = true;

    this.clearResponseTimeout();

    // Stop local playback immediately
    this.sendToClient({ type: 'stop_output' });

    // For Gemini Live, easiest “stop” is to interrupt turn flow.
    // We send an empty client content to trigger interruption behavior.
    this.safeSendGemini({
      clientContent: {
        turns: [
          {
            role: 'user',
            parts: [{ text: '' }],
          },
        ],
        turn_complete: false,
      },
    });

    this.responseActive = false;
    this.setState('idle');
  }

  // -----------------------------
  // Timeouts
  // -----------------------------
  startResponseTimeout() {
    this.clearResponseTimeout();
    this.responseTimeoutId = setTimeout(() => {
      const elapsed = Date.now() - (this.currentResponseStartTime || Date.now());
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

  // -----------------------------
  // State + client sending
  // -----------------------------
  setState(newState) {
    this.state = newState;
    console.log(`🤖 [${this.clientId}] State: ${newState}`);
  }

  sendToClient(message) {
    if (this.ws.readyState === WebSocket.OPEN) {
      try {
        this.ws.send(JSON.stringify(message));
      } catch (e) {
        // ignore
      }
    }
  }

  // -----------------------------
  // Disconnect
  // -----------------------------
  logMetrics() {
    const summary = this.metrics.getSummary();
    console.log(`\n📊 [${this.clientId}] Session Metrics:`);
    console.log(`   User Audio: ${summary.userAudioSeconds}s (${summary.userChunks} chunks)`);
    console.log(`   AI Audio:   ${summary.aiAudioSeconds}s (${summary.aiChunks} chunks)`);
    console.log(`   Turns:      ${summary.turnCount} (${summary.turnsPerMinute}/min)`);
    console.log(`   Duration:   ${summary.sessionDurationSeconds}s`);
    console.log(`   Est. Cost:  $${summary.estimatedCostUSD}\n`);
  }

  disconnect() {
    this.clearResponseTimeout();
    this.logMetrics();

    if (this._reconnectTimer) {
      clearTimeout(this._reconnectTimer);
      this._reconnectTimer = null;
    }

    if (this.realtimeClient) {
      this._closedByUs = true;
      try {
        this.realtimeClient.close();
      } catch (e) {
        // ignore
      }
      this.realtimeClient = null;
    }
  }
}

// -----------------------------
// Public: createRobotWebSocketServer
// -----------------------------
let clientIdCounter = 0;

function createRobotWebSocketServer(server) {
  const wss = new WebSocket.Server({
    server,
    path: '/robot',
  });

  wss.on('connection', async (ws, req) => {
    const clientId = `client-${++clientIdCounter}`;
    const url = new URL(req.url, `http://${req.headers.host}`);
    const language = url.searchParams.get('lang') || 'en';

    console.log(`🔗 [${clientId}] New robot client connected (language: ${language})`);
    const session = new RobotSession(ws, clientId, language);

    try {
      await session.connect();
    } catch (error) {
      console.error(`❌ [${clientId}] Failed to connect to Gemini Live:`, error);
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
      console.error(`❌ [${clientId}] Client WS error:`, error);
    });
  });

  console.log('🤖 Robot WebSocket server ready on /robot');
  return wss;
}

module.exports = { createRobotWebSocketServer };
