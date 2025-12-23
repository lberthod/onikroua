require('dotenv').config();

const https = require('https');
const fs = require('fs');
const path = require('path');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-1.5-flash';

if (!GEMINI_API_KEY) {
  console.error('Erreur: GEMINI_API_KEY manquant dans le fichier .env');
  process.exit(1);
}

const FRONTEND_ROOT = path.resolve(__dirname, '../frontend/src/data');
const OUTPUT_IT = path.join(FRONTEND_ROOT, 'vocabulary_it.json');
const OUTPUT_ES = path.join(FRONTEND_ROOT, 'vocabulary_es.json');

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

async function generateVocabularyForLanguage(langCode, languageLabel, outputPath) {
  console.log(`\nGénération du vocabulaire pour ${languageLabel} (${langCode})...`);

  const prompt = `Tu es un expert en didactique des langues.\n\nGénère un fichier JSON de vocabulaire pour des francophones qui apprennent la langue suivante: ${languageLabel}.\n\nCONTRAINTES TRÈS IMPORTANTES:\n- Langue cible: ${languageLabel} (code: ${langCode}).\n- La langue d'explication (traduction, exemples en français) est le FRANÇAIS.\n- Le résultat DOIT être un JSON STRICT, SANS aucun texte avant/après, SANS commentaire, SANS Markdown.\n- Forme EXACTE attendue: un tableau au format suivant:\n  [\n    {\n      \"name\": \"Nom de la catégorie en français (ex: Salutations)\",\n      \"icon\": \"UN ÉMOJI PERTINENT\",\n      \"words\": [\n        {\n          \"word\": \"mot dans la langue cible\",\n          \"translation\": \"traduction française du mot\",\n          \"example\": \"phrase d'exemple dans la langue cible\",\n          \"exampleTranslation\": \"traduction française de la phrase\"\n        }\n      ]\n    }\n  ]\n- Il doit y avoir AU MOINS 500 entrées de mots au total (somme de tous les éléments dans tous les tableaux \\"words\\").\n- Utilise des thèmes simples et utiles (salutations, famille, nourriture, maison, corps, vêtements, transports, couleurs, travail, animaux, santé, loisirs, école, temps/météo, ville, pays/voyages, etc.).\n- Assure-toi que toutes les chaînes sont en UTF-8 valide.\n- AUCUN doublon exact dans le champ \\"word\\" à l'intérieur de chaque langue.\n\nRéponds UNIQUEMENT par le JSON, sans explication.`;

  const rawText = await callGemini(prompt);
  const cleaned = sanitizeJsonText(rawText);

  let vocabulary;
  try {
    vocabulary = JSON.parse(cleaned);
  } catch (err) {
    throw new Error(`Erreur parsing JSON pour ${languageLabel}: ${err.message}`);
  }

  if (!Array.isArray(vocabulary)) {
    throw new Error(`Le JSON généré pour ${languageLabel} doit être un tableau (array) racine.`);
  }

  let totalWords = 0;
  for (const category of vocabulary) {
    if (Array.isArray(category.words)) {
      totalWords += category.words.length;
    }
  }

  console.log(`Nombre total de mots générés pour ${languageLabel}: ${totalWords}`);

  fs.writeFileSync(outputPath, JSON.stringify(vocabulary, null, 2), 'utf8');
  console.log(`Fichier écrit: ${outputPath}`);
}

(async () => {
  try {
    console.log('Début de la génération de vocabulaire via Gemini...');

    await generateVocabularyForLanguage('it', 'italien', OUTPUT_IT);
    await generateVocabularyForLanguage('es', 'espagnol', OUTPUT_ES);

    console.log('\nGénération terminée avec succès pour les deux langues.');
  } catch (err) {
    console.error('\nErreur pendant la génération du vocabulaire:', err.message);
    process.exit(1);
  }
})();
