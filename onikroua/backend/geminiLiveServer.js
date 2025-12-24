const WebSocket = require('ws');

function createGeminiLiveWebSocketServer(server) {
  const wss = new WebSocket.Server({ 
    server,
    path: '/gemini-live'
  });

  console.log('🎤 Gemini Live WebSocket server ready on /gemini-live');

  wss.on('connection', async (ws) => {
    console.log('🔌 Client connected to Gemini Live');

    if (!process.env.GEMINI_API_KEY) {
      ws.send(JSON.stringify({ 
        type: 'error', 
        error: 'GEMINI_API_KEY not configured. Get it from https://aistudio.google.com/apikey' 
      }));
      ws.close();
      return;
    }

    let audioBuffer = [];
    let isProcessing = false;

    ws.send(JSON.stringify({ type: 'ready' }));
    console.log('✅ Gemini Live ready (using text-based simulation)');

    ws.on('message', async (message) => {
      try {
        const data = JSON.parse(message);

        if (data.type === 'audio') {
          audioBuffer.push(data.audio);
          
          if (!isProcessing && audioBuffer.length > 10) {
            isProcessing = true;
            
            setTimeout(async () => {
              ws.send(JSON.stringify({
                type: 'text',
                text: 'Audio reçu. Pour utiliser Gemini Live avec audio natif, vous devez configurer le WebSocket client-side avec le SDK @google/genai côté frontend.'
              }));
              
              audioBuffer = [];
              isProcessing = false;
            }, 1000);
          }
        } else if (data.type === 'text') {
          ws.send(JSON.stringify({
            type: 'text',
            text: `Echo: ${data.text}`
          }));
        }
      } catch (err) {
        console.error('Error processing message:', err);
        ws.send(JSON.stringify({ 
          type: 'error', 
          error: err.message 
        }));
      }
    });

    ws.on('close', () => {
      console.log('🔌 Client disconnected from Gemini Live');
    });

    ws.on('error', (error) => {
      console.error('WebSocket error:', error);
    });
  });

  return wss;
}

module.exports = { createGeminiLiveWebSocketServer };
