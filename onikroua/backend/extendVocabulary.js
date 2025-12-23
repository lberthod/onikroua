require('dotenv').config();

const https = require('https');
const fs = require('fs');
const path = require('path');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-3-flash-preview';

if (!GEMINI_API_KEY) {
  console.error('Erreur: GEMINI_API_KEY manquant dans le fichier .env');
  process.exit(1);
}

const FRONTEND_ROOT = path.resolve(__dirname, '../frontend/src/data');
const INPUT_IT = path.join(FRONTEND_ROOT, 'vocabulary_it.json');
const INPUT_ES = path.join(FRONTEND_ROOT, 'vocabulary_es.json');

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
          return reject(new Error(`Appel Gemini échoué (${res.statusCode}): ${data}`));
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
            return reject(new Error('Réponse Gemini invalide: pas de texte dans candidates[0].content.parts[0].text'));
          }

          resolve(text);
        } catch (err) {
          reject(new Error(`Erreur parsing réponse Gemini: ${err.message}\nBrut: ${data}`));
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

function sanitizeJsonText(text) {
  let cleaned = text.trim();

  if (cleaned.startsWith('```')) {
    const firstNewline = cleaned.indexOf('\n');
    if (firstNewline !== -1) {
      cleaned = cleaned.slice(firstNewline + 1);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.slice(0, -3);
    }
    cleaned = cleaned.trim();
  }

  return cleaned;
}

function buildExistingWordSet(vocabulary) {
  const set = new Set();
  for (const category of vocabulary) {
    if (Array.isArray(category.words)) {
      for (const entry of category.words) {
        if (entry && typeof entry.word === 'string') {
          set.add(entry.word.trim().toLowerCase());
        }
      }
    }
  }
  return set;
}

function mergeNewVocabulary(existing, generated, existingWordsSet, targetNewCount) {
  let addedCount = 0;

  for (const newCategory of generated) {
    if (!Array.isArray(newCategory.words) || !newCategory.name) continue;

    let existingCategory = existing.find(c => c.name === newCategory.name && c.icon === newCategory.icon);
    if (!existingCategory) {
      existingCategory = {
        name: newCategory.name,
        icon: newCategory.icon || '📚',
        words: []
      };
      existing.push(existingCategory);
    }

    for (const wordEntry of newCategory.words) {
      if (!wordEntry || typeof wordEntry.word !== 'string') continue;
      const key = wordEntry.word.trim().toLowerCase();
      if (existingWordsSet.has(key)) continue;

      existingCategory.words.push(wordEntry);
      existingWordsSet.add(key);
      addedCount++;

      if (addedCount >= targetNewCount) {
        return addedCount;
      }
    }
  }

  return addedCount;
}

async function extendVocabularyForLanguage(langCode, languageLabel, inputPath, targetNewCount) {
  console.log(`\nExtension du vocabulaire pour ${languageLabel} (${langCode})...`);

  if (!fs.existsSync(inputPath)) {
    throw new Error(`Fichier de vocabulaire introuvable: ${inputPath}`);
  }

  const raw = fs.readFileSync(inputPath, 'utf8');
  let existing;
  try {
    existing = JSON.parse(raw);
  } catch (err) {
    throw new Error(`JSON invalide dans ${inputPath}: ${err.message}`);
  }

  if (!Array.isArray(existing)) {
    throw new Error(`Le fichier ${inputPath} doit contenir un tableau JSON racine.`);
  }

  const existingWordsSet = buildExistingWordSet(existing);
  console.log(`Mots existants pour ${languageLabel}: ${existingWordsSet.size}`);

  const prompt = `Tu es un expert en didactique des langues.\n\nJe dispose déjà d'un grand vocabulaire pour des francophones qui apprennent la langue suivante: ${languageLabel}.\nJe veux maintenant AJOUTER environ ${targetNewCount} nouveaux mots UTILES, différents des plus usuels déjà vus (salutations de base, membres de la famille les plus classiques, couleurs de base, etc.).\n\nCONTRAINTES TRÈS IMPORTANTES:\n- Langue cible: ${languageLabel} (code: ${langCode}).\n- Langue d'explication: français.\n- Structure EXACTE attendue: un tableau JSON au format suivant:\n  [\n    {\n      \"name\": \"Nom de la catégorie en français\",\n      \"icon\": \"UN ÉMOJI\",\n      \"words\": [\n        {\n          \"word\": \"mot dans la langue cible\",\n          \"translation\": \"traduction française\",\n          \"example\": \"phrase d'exemple dans la langue cible\",\n          \"exampleTranslation\": \"traduction française de la phrase\"\n        }\n      ]\n    }\n  ]\n- Il doit y avoir AU MOINS ${targetNewCount + 40} entrées de mots au total (pour compenser les doublons éventuels).\n- Utilise des thèmes variés mais concrets: vie quotidienne, émotions un peu plus avancées, loisirs, travail, ville, école, voyages, santé, technologie, etc.\n- Évite les mots déjà ultra basiques (bonjour, merci, oui, non, rouge, bleu, père, mère, etc.). Cherche plutôt des mots de niveau A2/B1 utiles.\n- Le JSON doit être STRICT, sans texte avant/après, sans Markdown, sans commentaire.\n\nRéponds UNIQUEMENT par ce JSON.`;

  const rawText = await callGemini(prompt);
  const cleaned = sanitizeJsonText(rawText);

  let generated;
  try {
    generated = JSON.parse(cleaned);
  } catch (err) {
    throw new Error(`Erreur parsing JSON généré pour ${languageLabel}: ${err.message}`);
  }

  if (!Array.isArray(generated)) {
    throw new Error(`Le JSON généré pour ${languageLabel} doit être un tableau racine.`);
  }

  const added = mergeNewVocabulary(existing, generated, existingWordsSet, targetNewCount);
  console.log(`Nouveaux mots effectivement ajoutés pour ${languageLabel}: ${added}`);

  fs.writeFileSync(inputPath, JSON.stringify(existing, null, 2), 'utf8');
  console.log(`Fichier mis à jour: ${inputPath}`);
}

(async () => {
  try {
    const TARGET_NEW_PER_LANGUAGE = 500;
    console.log('Début de l\'extension du vocabulaire via Gemini...');

    await extendVocabularyForLanguage('it', 'italien', INPUT_IT, TARGET_NEW_PER_LANGUAGE);
    await extendVocabularyForLanguage('es', 'espagnol', INPUT_ES, TARGET_NEW_PER_LANGUAGE);

    console.log('\nExtension terminée avec succès pour les deux langues.');
  } catch (err) {
    console.error('\nErreur pendant l\'extension du vocabulaire:', err.message);
    process.exit(1);
  }
})();
