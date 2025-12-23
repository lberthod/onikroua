const express = require('express');
const router = express.Router();

// Gemini API configuration
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-3-flash-preview';
const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

// System prompts for different modes
const systemPrompts = {
  tutor: {
    it: `Tu es un tuteur d'italien bienveillant et patient. Tu aides les francophones à apprendre l'italien.
- Réponds toujours en français avec des exemples en italien
- Corrige les erreurs avec gentillesse et explique pourquoi
- Donne des exemples pratiques et des phrases utiles
- Utilise des emojis pour rendre l'apprentissage fun
- Si l'utilisateur écrit en italien, corrige ses erreurs et félicite-le
- Propose des exercices simples quand c'est pertinent`,
    es: `Tu es un tuteur d'espagnol bienveillant et patient. Tu aides les francophones à apprendre l'espagnol.
- Réponds toujours en français avec des exemples en espagnol
- Corrige les erreurs avec gentillesse et explique pourquoi
- Donne des exemples pratiques et des phrases utiles
- Utilise des emojis pour rendre l'apprentissage fun
- Si l'utilisateur écrit en espagnol, corrige ses erreurs et félicite-le
- Propose des exercices simples quand c'est pertinent`
  },
  translate: {
    it: `Tu es un traducteur français-italien expert. Traduis le texte demandé et explique les nuances si nécessaire.`,
    es: `Tu es un traducteur français-espagnol expert. Traduis le texte demandé et explique les nuances si nécessaire.`
  },
  grammar: {
    it: `Tu es un expert en grammaire italienne. Explique les règles de grammaire de manière claire et simple avec des exemples.`,
    es: `Tu es un expert en grammaire espagnole. Explique les règles de grammaire de manière claire et simple avec des exemples.`
  },
  practice: {
    it: `Tu es un partenaire de conversation italien. Engage une conversation simple en italien avec l'utilisateur, corrige ses erreurs gentiment, et aide-le à progresser. Adapte ton niveau à celui de l'utilisateur.`,
    es: `Tu es un partenaire de conversation espagnol. Engage une conversation simple en espagnol avec l'utilisateur, corrige ses erreurs gentiment, et aide-le à progresser. Adapte ton niveau à celui de l'utilisateur.`
  },
  quiz: {
    it: `Tu es un créateur de quiz d'italien. Génère des questions de quiz variées (vocabulaire, conjugaison, grammaire) avec 4 choix de réponses. Indique la bonne réponse et explique pourquoi.`,
    es: `Tu es un créateur de quiz d'espagnol. Génère des questions de quiz variées (vocabulaire, conjugaison, grammaire) avec 4 choix de réponses. Indique la bonne réponse et explique pourquoi.`
  }
};

// Chat with AI tutor
router.post('/chat', async (req, res) => {
  try {
    const { message, language = 'it', mode = 'tutor', history = [] } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message requis' });
    }

    if (!GEMINI_API_KEY) {
      return res.status(500).json({ error: 'Clé API Gemini non configurée' });
    }

    const systemPrompt = systemPrompts[mode]?.[language] || systemPrompts.tutor[language];
    
    // Build conversation history for context
    const contents = [];
    
    // Add system instruction as first user message
    contents.push({
      role: 'user',
      parts: [{ text: `Instructions système: ${systemPrompt}` }]
    });
    contents.push({
      role: 'model',
      parts: [{ text: 'Compris ! Je suis prêt à t\'aider. 😊' }]
    });

    // Add conversation history
    for (const msg of history.slice(-10)) { // Keep last 10 messages for context
      contents.push({
        role: msg.role === 'user' ? 'user' : 'model',
        parts: [{ text: msg.content }]
      });
    }

    // Add current message
    contents.push({
      role: 'user',
      parts: [{ text: message }]
    });

    const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents,
        generationConfig: {
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        },
        safetySettings: [
          { category: 'HARM_CATEGORY_HARASSMENT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
          { category: 'HARM_CATEGORY_HATE_SPEECH', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
          { category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
          { category: 'HARM_CATEGORY_DANGEROUS_CONTENT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' }
        ]
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('Gemini API error:', errorData);
      return res.status(500).json({ error: 'Erreur API Gemini', details: errorData });
    }

    const data = await response.json();
    
    if (!data.candidates || !data.candidates[0]?.content?.parts?.[0]?.text) {
      return res.status(500).json({ error: 'Réponse invalide de Gemini' });
    }

    const aiResponse = data.candidates[0].content.parts[0].text;

    res.json({
      response: aiResponse,
      mode,
      language
    });

  } catch (error) {
    console.error('AI Chat error:', error);
    res.status(500).json({ error: 'Erreur lors de la communication avec l\'IA' });
  }
});

// Generate a quick exercise
router.post('/exercise', async (req, res) => {
  try {
    const { type = 'vocabulary', language = 'it', level = 'beginner' } = req.body;

    if (!GEMINI_API_KEY) {
      return res.status(500).json({ error: 'Clé API Gemini non configurée' });
    }

    const langName = language === 'it' ? 'italien' : 'espagnol';
    const levelName = level === 'beginner' ? 'débutant' : level === 'intermediate' ? 'intermédiaire' : 'avancé';

    const prompts = {
      vocabulary: `Génère un exercice de vocabulaire ${langName} niveau ${levelName}. 
Format JSON: { "word": "mot en ${langName}", "hint": "indice en français", "answer": "traduction", "example": "phrase exemple" }`,
      conjugation: `Génère un exercice de conjugaison ${langName} niveau ${levelName}.
Format JSON: { "verb": "infinitif", "tense": "temps", "subject": "sujet", "answer": "forme conjuguée", "hint": "indice" }`,
      fillblank: `Génère une phrase à trous en ${langName} niveau ${levelName}.
Format JSON: { "sentence": "phrase avec ___ pour le trou", "answer": "mot manquant", "hint": "indice", "translation": "traduction complète" }`
    };

    const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{
          role: 'user',
          parts: [{ text: prompts[type] || prompts.vocabulary }]
        }],
        generationConfig: {
          temperature: 0.9,
          maxOutputTokens: 256,
        }
      })
    });

    if (!response.ok) {
      return res.status(500).json({ error: 'Erreur API Gemini' });
    }

    const data = await response.json();
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text || '';

    // Try to parse JSON from response
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      try {
        const exercise = JSON.parse(jsonMatch[0]);
        return res.json({ exercise, type, language, level });
      } catch (e) {
        // If JSON parsing fails, return raw text
      }
    }

    res.json({ exercise: { raw: text }, type, language, level });

  } catch (error) {
    console.error('Exercise generation error:', error);
    res.status(500).json({ error: 'Erreur lors de la génération de l\'exercice' });
  }
});

module.exports = router;
