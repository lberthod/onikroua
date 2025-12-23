require('dotenv').config();
const WebSocket = require('ws');
const OpenAI = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const PEDAGOGICAL_INSTRUCTIONS = `You are a kind and encouraging language teacher for A1 level English learners.

SCENARIO: "Se présenter" (Introducing yourself)

YOUR ROLE:
- Ask simple questions about the student's name, age, where they're from
- Keep responses SHORT (1-2 sentences maximum)
- Always be encouraging and positive
- If the student makes a mistake, gently reformulate without saying "wrong" or "incorrect"
- Use simple vocabulary and clear pronunciation
- Stay focused on the introduction topic only

EXAMPLE INTERACTION:
Teacher: "Hello! What is your name?"
Student: "My name Paul" (missing "is")
Teacher: "Nice to meet you, Paul! My name is Teacher. Where are you from?"

IMPORTANT:
- Never criticize directly
- Always validate before correcting
- Keep the conversation natural and flowing
- Be patient and warm`;

class RobotSession {
  constructor(ws) {
    this.ws = ws;
    this.realtimeClient = null;
    this.state = 'idle';
    this.isConnecting = false;
  }

  async connect() {
    if (this.isConnecting || this.realtimeClient) {
      return;
    }

    this.isConnecting = true;
    
    try {
      const response = await fetch('https://api.openai.com/v1/realtime/sessions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-realtime-mini-2025-12-15',
          voice: 'alloy'
        }),
      });

      const data = await response.json();
      
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
        console.log('✅ Connected to OpenAI Realtime API');
        this.isConnecting = false;
        
        this.realtimeClient.send(JSON.stringify({
          type: 'session.update',
          session: {
            modalities: ['text', 'audio'],
            instructions: PEDAGOGICAL_INSTRUCTIONS,
            voice: 'alloy',
            input_audio_format: 'pcm16',
            output_audio_format: 'pcm16',
            input_audio_transcription: {
              model: 'whisper-1'
            },
            turn_detection: {
              type: 'server_vad',
              threshold: 0.5,
              prefix_padding_ms: 300,
              silence_duration_ms: 500
            }
          }
        }));

        this.realtimeClient.send(JSON.stringify({
          type: 'response.create',
          response: {
            modalities: ['text', 'audio'],
            instructions: 'Start by greeting the student and asking their name.'
          }
        }));

        this.setState('idle');
      });

      this.realtimeClient.on('message', (data) => {
        this.handleRealtimeMessage(JSON.parse(data.toString()));
      });

      this.realtimeClient.on('error', (error) => {
        console.error('❌ Realtime API error:', error);
        this.ws.send(JSON.stringify({
          type: 'error',
          error: 'Connection error with AI service'
        }));
      });

      this.realtimeClient.on('close', () => {
        console.log('🔌 Disconnected from OpenAI Realtime API');
        this.realtimeClient = null;
        this.isConnecting = false;
      });

    } catch (error) {
      console.error('❌ Failed to connect to Realtime API:', error);
      this.isConnecting = false;
      this.ws.send(JSON.stringify({
        type: 'error',
        error: 'Failed to initialize AI service'
      }));
    }
  }

  handleRealtimeMessage(message) {
    switch (message.type) {
      case 'session.created':
      case 'session.updated':
        console.log('📝 Session ready');
        break;

      case 'input_audio_buffer.speech_started':
        this.setState('listening');
        this.ws.send(JSON.stringify({
          type: 'state',
          state: 'listening'
        }));
        break;

      case 'input_audio_buffer.speech_stopped':
        this.setState('thinking');
        this.ws.send(JSON.stringify({
          type: 'state',
          state: 'thinking'
        }));
        break;

      case 'conversation.item.input_audio_transcription.completed':
        this.ws.send(JSON.stringify({
          type: 'transcription',
          text: message.transcript,
          role: 'user'
        }));
        break;

      case 'response.audio_transcript.delta':
        this.ws.send(JSON.stringify({
          type: 'transcript_delta',
          delta: message.delta,
          role: 'assistant'
        }));
        break;

      case 'response.audio_transcript.done':
        this.ws.send(JSON.stringify({
          type: 'transcription',
          text: message.transcript,
          role: 'assistant'
        }));
        break;

      case 'response.audio.delta':
        this.setState('speaking');
        this.ws.send(JSON.stringify({
          type: 'audio',
          audio: message.delta
        }));
        break;

      case 'response.audio.done':
        this.setState('idle');
        this.ws.send(JSON.stringify({
          type: 'state',
          state: 'idle'
        }));
        break;

      case 'response.done':
        this.setState('idle');
        break;

      case 'error':
        console.error('❌ Realtime API error:', message.error);
        this.ws.send(JSON.stringify({
          type: 'error',
          error: message.error.message
        }));
        break;
    }
  }

  handleClientMessage(message) {
    if (!this.realtimeClient || this.realtimeClient.readyState !== WebSocket.OPEN) {
      console.warn('⚠️ Realtime client not ready');
      return;
    }

    switch (message.type) {
      case 'audio':
        this.realtimeClient.send(JSON.stringify({
          type: 'input_audio_buffer.append',
          audio: message.audio
        }));
        break;

      case 'interrupt':
        this.realtimeClient.send(JSON.stringify({
          type: 'response.cancel'
        }));
        this.realtimeClient.send(JSON.stringify({
          type: 'input_audio_buffer.clear'
        }));
        this.setState('idle');
        break;
    }
  }

  setState(newState) {
    this.state = newState;
    console.log(`🤖 State: ${newState}`);
  }

  disconnect() {
    if (this.realtimeClient) {
      this.realtimeClient.close();
      this.realtimeClient = null;
    }
  }
}

function createRobotWebSocketServer(server) {
  const wss = new WebSocket.Server({ 
    server,
    path: '/robot'
  });

  wss.on('connection', (ws) => {
    console.log('🔗 New robot client connected');
    const session = new RobotSession(ws);

    session.connect();

    ws.on('message', (data) => {
      try {
        const message = JSON.parse(data.toString());
        session.handleClientMessage(message);
      } catch (error) {
        console.error('❌ Error parsing client message:', error);
      }
    });

    ws.on('close', () => {
      console.log('👋 Robot client disconnected');
      session.disconnect();
    });

    ws.on('error', (error) => {
      console.error('❌ WebSocket error:', error);
    });
  });

  console.log('🤖 Robot WebSocket server ready on /robot');
  return wss;
}

module.exports = { createRobotWebSocketServer };
