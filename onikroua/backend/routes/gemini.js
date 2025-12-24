const express = require('express');
const { GoogleAuth } = require('google-auth-library');
const textToSpeech = require('@google-cloud/text-to-speech');
const router = express.Router();

const GEMINI_ENDPOINT = 'https://us-central1-aiplatform.googleapis.com/v1/projects/instantdecision-d851c/locations/us-central1/publishers/google/models/gemini-2.5-flash-lite:streamGenerateContent';

const ttsClient = new textToSpeech.TextToSpeechClient({
  keyFilename: process.env.GOOGLE_APPLICATION_CREDENTIALS
});

let authClient = null;

async function getAuthClient() {
  if (!authClient) {
    const auth = new GoogleAuth({
      scopes: 'https://www.googleapis.com/auth/cloud-platform',
      keyFilename: process.env.GOOGLE_APPLICATION_CREDENTIALS
    });
    authClient = await auth.getClient();
  }
  return authClient;
}

router.post('/chat', async (req, res) => {
  try {
    const { message, conversationHistory = [] } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    const contents = [
      ...conversationHistory.map(msg => ({
        role: msg.role,
        parts: [{ text: msg.text }]
      })),
      {
        role: 'user',
        parts: [{ text: message }]
      }
    ];

    const client = await getAuthClient();
    const token = await client.getAccessToken();

    const response = await fetch(GEMINI_ENDPOINT, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token.token}`,
        'Content-Type': 'application/json'
      },
body: JSON.stringify({
  contents,
  generationConfig: {
    maxOutputTokens: 1000,
    temperature: 0.7,
    topP: 0.9,
    topK: 40
  }
})
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Gemini API error:', errorText);
      return res.status(response.status).json({ 
        error: 'Gemini API error', 
        details: errorText 
      });
    }

    const data = await response.json();
    
    const candidates = data[0]?.candidates || [];
    const responseText = candidates[0]?.content?.parts?.[0]?.text || '';

    res.json({
      response: responseText,
      candidates: candidates
    });

  } catch (error) {
    console.error('Error in Gemini chat:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
});

router.post('/stream', async (req, res) => {
  try {
    const { message, conversationHistory = [] } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    const contents = [
      ...conversationHistory.map(msg => ({
        role: msg.role,
        parts: [{ text: msg.text }]
      })),
      {
        role: 'user',
        parts: [{ text: message }]
      }
    ];

    const client = await getAuthClient();
    const token = await client.getAccessToken();

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.setHeader('X-Accel-Buffering', 'no');

    const response = await fetch(GEMINI_ENDPOINT, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token.token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents,
        generationConfig: {
          maxOutputTokens: 2000,
          temperature: 0.7,
          topP: 0.9,
          topK: 40
        }
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Gemini API error:', errorText);
      res.write(`data: ${JSON.stringify({ error: 'Gemini API error', details: errorText })}\n\n`);
      res.end();
      return;
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let fullText = '';

    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;

      fullText += decoder.decode(value, { stream: true });
    }

    try {
      const jsonData = JSON.parse(fullText);
      let fullResponse = '';
      
      if (Array.isArray(jsonData)) {
        for (const chunk of jsonData) {
          const text = chunk.candidates?.[0]?.content?.parts?.[0]?.text;
          if (text) {
            fullResponse += text;
          }
        }
      }

      if (fullResponse) {
        const words = fullResponse.split(/(\s+)/);
        
        for (let i = 0; i < words.length; i++) {
          res.write(`data: ${JSON.stringify({ text: words[i], chunk: true })}\n\n`);
          await new Promise(resolve => setTimeout(resolve, 30));
        }
      }
    } catch (parseError) {
      console.error('Error parsing response:', parseError);
      res.write(`data: ${JSON.stringify({ error: 'Parse error' })}\n\n`);
    }

    res.write(`data: ${JSON.stringify({ done: true })}\n\n`);
    res.end();

  } catch (error) {
    console.error('Error in Gemini stream:', error);
    res.write(`data: ${JSON.stringify({ error: error.message })}\n\n`);
    res.end();
  }
});

router.post('/stream-audio', async (req, res) => {
  try {
    const { message, conversationHistory = [] } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    const contents = [
      ...conversationHistory.map(msg => ({
        role: msg.role,
        parts: [{ text: msg.text }]
      })),
      {
        role: 'user',
        parts: [{ text: message }]
      }
    ];

    const client = await getAuthClient();
    const token = await client.getAccessToken();

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.setHeader('X-Accel-Buffering', 'no');

    const response = await fetch(GEMINI_ENDPOINT, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token.token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents,
        generationConfig: {
          maxOutputTokens: 2000,
          temperature: 0.7,
          topP: 0.9,
          topK: 40
        }
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Gemini API error:', errorText);
      res.write(`data: ${JSON.stringify({ error: 'Gemini API error', details: errorText })}\n\n`);
      res.end();
      return;
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let fullText = '';

    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;

      fullText += decoder.decode(value, { stream: true });
    }

    try {
      const jsonData = JSON.parse(fullText);
      let fullResponse = '';
      
      if (Array.isArray(jsonData)) {
        for (const chunk of jsonData) {
          const text = chunk.candidates?.[0]?.content?.parts?.[0]?.text;
          if (text) {
            fullResponse += text;
          }
        }
      }

      if (fullResponse) {
        const words = fullResponse.split(/(\s+)/);
        
        for (let i = 0; i < words.length; i++) {
          res.write(`data: ${JSON.stringify({ text: words[i], chunk: true })}\n\n`);
          await new Promise(resolve => setTimeout(resolve, 30));
        }

        res.write(`data: ${JSON.stringify({ fullText: fullResponse, chunk: true })}\n\n`);
      }
    } catch (parseError) {
      console.error('Error parsing response:', parseError);
      res.write(`data: ${JSON.stringify({ error: 'Parse error' })}\n\n`);
    }

    res.write(`data: ${JSON.stringify({ done: true })}\n\n`);
    res.end();

  } catch (error) {
    console.error('Error in Gemini audio stream:', error);
    res.write(`data: ${JSON.stringify({ error: error.message })}\n\n`);
    res.end();
  }
});

module.exports = router;
