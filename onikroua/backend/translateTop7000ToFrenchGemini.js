require('dotenv').config();
const fs = require('fs');
const path = require('path');
const https = require('https');

const INPUT_FILE = '../frontend/src/data/italian_words_top7000.json';
const OUTPUT_FILE = '../frontend/src/data/italian_words_top7000_translated.json';
const BATCH_SIZE = 100;
const DELAY_MS = 1500;

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = 'gemini-2.0-flash';

if (!GEMINI_API_KEY) {
  console.error('❌ Erreur: GEMINI_API_KEY manquant dans le fichier .env');
  process.exit(1);
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function callGemini(prompt) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ]
    });

    const options = {
      hostname: 'generativelanguage.googleapis.com',
      path: `/v1beta/models/${GEMINI_MODEL}:generateContent?key=${encodeURIComponent(GEMINI_API_KEY)}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode && res.statusCode >= 400) {
          return reject(new Error(`API Gemini erreur (${res.statusCode}): ${data}`));
        }

        try {
          const json = JSON.parse(data);
          const text = json.candidates &&
            json.candidates[0] &&
            json.candidates[0].content &&
            json.candidates[0].content.parts &&
            json.candidates[0].content.parts[0] &&
            json.candidates[0].content.parts[0].text;

          if (!text) {
            return reject(new Error('Réponse Gemini invalide: pas de texte'));
          }

          resolve(text);
        } catch (err) {
          reject(new Error(`Erreur parsing réponse: ${err.message}`));
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.write(payload);
    req.end();
  });
}

async function translateBatch(words) {
  const wordsToTranslate = words.map(w => w.lemma).join('\n');
  
  const prompt = `Traduis ces mots italiens en français. Réponds uniquement avec les traductions, une par ligne, dans le même ordre.
Ne traduis que le mot principal (pas de définitions, pas d'explications).
Pour les verbes, donne l'infinitif français.
Pour les noms, donne le singulier avec l'article (le/la).
Pour les adjectifs, donne la forme masculine singulier.

Mots italiens:
${wordsToTranslate}`;

  try {
    const responseText = await callGemini(prompt);
    
    const translations = responseText
      .trim()
      .split('\n')
      .map(t => t.trim())
      .filter(t => t.length > 0);

    if (translations.length !== words.length) {
      console.warn(`   ⚠️  Nombre de traductions (${translations.length}) != nombre de mots (${words.length})`);
    }

    const results = [];
    for (let i = 0; i < words.length; i++) {
      results.push({
        ...words[i],
        translation_fr: translations[i] || '???'
      });
    }

    return results;
  } catch (error) {
    console.error(`   ❌ Erreur API: ${error.message}`);
    return words.map(w => ({
      ...w,
      translation_fr: '???'
    }));
  }
}

async function translateAll() {
  console.log('🌍 Traduction des 7000 mots italiens en français (Gemini)\n');
  console.log('════════════════════════════════════════════════════════════════════\n');
  
  const inputPath = path.join(__dirname, INPUT_FILE);
  const data = JSON.parse(fs.readFileSync(inputPath, 'utf-8'));
  
  console.log(`📚 ${data.words.length} mots à traduire\n`);
  console.log(`🤖 Modèle: ${GEMINI_MODEL}\n`);
  console.log(`📦 Taille des batches: ${BATCH_SIZE} mots\n`);
  console.log(`⏱️  Délai entre batches: ${DELAY_MS}ms\n`);
  
  const totalBatches = Math.ceil(data.words.length / BATCH_SIZE);
  let translatedWords = [];
  let successCount = 0;
  let errorCount = 0;
  
  for (let i = 0; i < data.words.length; i += BATCH_SIZE) {
    const batchNum = Math.floor(i / BATCH_SIZE) + 1;
    const batch = data.words.slice(i, i + BATCH_SIZE);
    
    console.log(`🔄 Batch ${batchNum}/${totalBatches} (mots ${i + 1}-${Math.min(i + BATCH_SIZE, data.words.length)})...`);
    
    const translatedBatch = await translateBatch(batch);
    translatedWords.push(...translatedBatch);
    
    const batchErrors = translatedBatch.filter(w => w.translation_fr === '???').length;
    successCount += translatedBatch.length - batchErrors;
    errorCount += batchErrors;
    
    console.log(`   ✓ Traductions: ${translatedBatch.length - batchErrors}/${translatedBatch.length}`);
    
    if (batchNum % 10 === 0) {
      const tempOutputPath = path.join(__dirname, OUTPUT_FILE);
      const tempData = {
        ...data,
        words: translatedWords
      };
      fs.writeFileSync(tempOutputPath, JSON.stringify(tempData, null, 2), 'utf-8');
      console.log(`   💾 Sauvegarde intermédiaire (${translatedWords.length} mots)...\n`);
    }
    
    if (i + BATCH_SIZE < data.words.length) {
      await sleep(DELAY_MS);
    }
  }
  
  data.words = translatedWords;
  data.metadata.translated = true;
  data.metadata.translation_date = new Date().toISOString();
  data.metadata.translation_model = GEMINI_MODEL;
  data.metadata.translation_stats = {
    total: translatedWords.length,
    success: successCount,
    errors: errorCount
  };
  
  const outputPath = path.join(__dirname, OUTPUT_FILE);
  fs.writeFileSync(outputPath, JSON.stringify(data, null, 2), 'utf-8');
  
  console.log('\n════════════════════════════════════════════════════════════════════');
  console.log('✨ TRADUCTION TERMINÉE\n');
  console.log('📊 Statistiques:');
  console.log(`   • Total: ${translatedWords.length} mots`);
  console.log(`   • Succès: ${successCount} traductions`);
  console.log(`   • Erreurs: ${errorCount} mots non traduits`);
  console.log(`   • Taux de réussite: ${((successCount / translatedWords.length) * 100).toFixed(1)}%`);
  console.log(`\n📁 Fichier généré: ${outputPath}`);
  console.log('════════════════════════════════════════════════════════════════════\n');
  
  console.log('📝 Exemples de traductions:\n');
  for (let i = 0; i < Math.min(20, translatedWords.length); i++) {
    const word = translatedWords[i];
    console.log(`   ${(i + 1).toString().padStart(2)}. ${word.lemma.padEnd(20)} → ${word.translation_fr}`);
  }
}

translateAll().catch(error => {
  console.error('❌ Erreur fatale:', error);
  process.exit(1);
});
