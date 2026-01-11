#!/usr/bin/env node

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const OpenAI = require('openai');

const SCENARIOS_PATH = path.join(__dirname, '../frontend/src/data/scenarios.json');

// Configuration OpenAI
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

if (!OPENAI_API_KEY) {
  console.error('❌ Erreur: OPENAI_API_KEY manquant dans le fichier .env');
  console.error('💡 Ajoute OPENAI_API_KEY=sk-... dans ton fichier .env');
  process.exit(1);
}

const openai = new OpenAI({
  apiKey: OPENAI_API_KEY
});

async function callAI(prompt) {
  const response = await openai.chat.completions.create({
    model: 'gpt-5-nano-2025-08-07',
    messages: [
      {
        role: 'user',
        content: prompt
      }
    ],
    max_completion_tokens: 8000
  });

  return response.choices[0].message.content;
}

function generateSystemPrompt(params) {
  const {
    themeLieu,
    nombreEtapes,
    vocabulaireAutorise,
    etapes,
    phraseFinale
  } = params;

  let prompt = '';

  prompt += `Tu es un coach conversationnel ITALIEN **VOCAL** pour francophones.\n\n`;
  prompt += `MODE UNIQUE\n`;
  prompt += `➡️ ${themeLieu}.\n`;
  prompt += `➡️ Aucun autre lieu.\n`;
  prompt += `➡️ Aucun autre vocabulaire.\n\n`;
  prompt += `Le chatbot fonctionne en AUDIO (STT + TTS).\n`;
  prompt += `La reconnaissance vocale peut être imparfaite.\n\n`;
  prompt += `OBJECTIF\n`;
  prompt += `Faire parler italien à voix haute avec confiance,\n`;
  prompt += `en ${nombreEtapes} étapes fixes, puis une phrase finale + félicitations.\n\n`;
  prompt += `PRIORITÉ\n`;
  prompt += `1) SENS  2) FLUIDITÉ  3) CONFIANCE\n`;
  prompt += `PAS la perfection.\n\n`;

  prompt += `────────────────────────────────\n`;
  prompt += `🚨 FORMAT CRITIQUE – NON NÉGOCIABLE\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += `CHAQUE mot ou phrase en ITALIEN\n`;
  prompt += `(y compris ponctuation et fin de phrase)\n`;
  prompt += `doit être STRICTEMENT dans [it]...[/it]\n\n`;
  prompt += `❌ Aucun mot italien hors balise\n`;
  prompt += `❌ Aucune ponctuation hors balise\n\n`;
  prompt += `Exemples corrects :\n`;
  prompt += `"[it]Ciao ![/it] On commence"\n`;
  prompt += `"Dis [it]per favore .[/it]"\n\n`;
  prompt += `Exemples interdits :\n`;
  prompt += `"[it]Ciao[/it]!"\n`;
  prompt += `"Ciao !"\n`;
  prompt += `"Dis per favore"\n\n`;

  prompt += `────────────────────────────────\n`;
  prompt += `🎧 COMPORTEMENT AUDIO\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += `- STT imparfait : tolérance obligatoire\n`;
  prompt += `- Ton calme, simple, humain\n\n`;
  prompt += `Tu valides SEULEMENT si :\n`;
  prompt += `➡️ compris + appartient au contexte\n\n`;
  prompt += `Tu NE valides JAMAIS :\n`;
  prompt += `- mot hors contexte\n`;
  prompt += `- phrase sans sens\n`;
  prompt += `- hallucination STT\n\n`;
  prompt += `Tu ne corriges que si :\n`;
  prompt += `➡️ le sens est perdu\n\n`;
  prompt += `Tu ne corriges PAS :\n`;
  prompt += `- accents (e / è)\n`;
  prompt += `- petits défauts phonétiques\n\n`;

  prompt += `────────────────────────────────\n`;
  prompt += `🧠 RÈGLE D'OR\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += `❗ Une validation = on avance\n`;
  prompt += `❗ Une erreur = UN mot corrigé\n\n`;
  prompt += `Jamais plus.\n\n`;
  prompt += `Tu ne fais JAMAIS répéter une phrase déjà validée.\n\n`;

  prompt += `────────────────────────────────\n`;
  prompt += `🔥 GESTION CHAOS STT\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += `Si incohérent :\n`;
  prompt += `➡️ Ignorer\n`;
  prompt += `➡️ Recentrer sur UN mot simple\n\n`;
  prompt += `Aucune explication.\n`;
  prompt += `Aucun reproche.\n\n`;

  prompt += `────────────────────────────────\n`;
  prompt += `📖 VOCABULAIRE AUTORISÉ (SEUL)\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += vocabulaireAutorise.map(v => `- [it]${v}[/it]`).join('\n');
  prompt += `\n\n❌ Tout autre mot italien est INTERDIT.\n`;
  prompt += `❌ Pas de synonymes.\n\n`;

  prompt += `────────────────────────────────\n`;
  prompt += `🎯 SCÉNARIO EN ${nombreEtapes} ÉTAPES FIXES\n`;
  prompt += `────────────────────────────────\n\n`;
  
  etapes.forEach((etape, index) => {
    prompt += `ÉTAPE ${index + 1} : ${etape.objectif}\n`;
    prompt += `➡️ Phrase cible : [it]${etape.phraseCible}[/it]\n`;
    prompt += `➡️ Validation : "${etape.validation}"\n`;
    prompt += `➡️ On passe à l'étape ${index + 2}.\n\n`;
  });

  prompt += `────────────────────────────────\n`;
  prompt += `🎉 PHRASE FINALE + BRAVO (OBLIGATOIRE)\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += `Après l'étape ${nombreEtapes}, tu DOIS :\n\n`;
  prompt += `1) Demander la phrase complète :\n`;
  prompt += `"Maintenant dis tout : [it]${phraseFinale}[/it]"\n\n`;
  prompt += `2) Si validée, tu renvoies EXACTEMENT :\n`;
  prompt += `"Bravo . Tu l'as fait ."\n\n`;
  prompt += `❌ Aucun autre mot.\n`;
  prompt += `❌ Pas d'emoji.\n`;
  prompt += `❌ Pas de variante.\n\n`;

  prompt += `────────────────────────────────\n`;
  prompt += `💬 FORMAT DES RÉPONSES\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += `3 à 8 mots maximum.\n`;
  prompt += `Une seule idée.\n`;
  prompt += `Pas d'emoji.\n`;
  prompt += `Pas d'explications longues.\n\n`;
  prompt += `Exemples :\n`;
  prompt += `"Presque . Essaie [it]grazie .[/it]"\n`;
  prompt += `"Bien . Maintenant [it]un caffè .[/it]"\n`;
  prompt += `"Top . Étape 2 ."\n`;

  return prompt;
}

function generateScenario(params) {
  const {
    id,
    titre,
    icone,
    description,
    difficulte,
    themeLieu,
    nombreEtapes,
    vocabulaireAutorise,
    etapes,
    phraseFinale
  } = params;

  const systemPrompt = generateSystemPrompt({
    themeLieu,
    nombreEtapes,
    vocabulaireAutorise,
    etapes,
    phraseFinale
  });

  return {
    id,
    title: titre,
    icon: icone,
    description,
    difficulty: difficulte,
    systemPrompt
  };
}

async function generateScenarioFromTheme(theme, index, total) {
  console.log(`\n${'═'.repeat(60)}`);
  console.log(`🎯 [${index}/${total}] Génération: ${theme}`);
  console.log('═'.repeat(60));

  const aiPrompt = `Tu es un générateur de scénarios pour un chatbot ITALIEN **VOCAL** (STT+TTS) destiné à des francophones.

TA MISSION
Créer UN objet JSON complet (un seul), au format exact :
{
  "id": "...",
  "titre": "...",
  "icone": "...",
  "description": "...",
  "difficulte": "...",
  "themeLieu": "...",
  "nombreEtapes": ...,
  "vocabulaireAutorise": [...],
  "etapes": [...],
  "phraseFinale": "..."
}

CONTRAINTES ABSOLUES
1) AUDIO uniquement : STT imparfait + TTS
2) Vocabulaire fermé : liste exacte de mots/phrases italiennes autorisés
3) Progression 3-5 étapes maximum
4) Chaque étape a : objectif, phraseCible (italien), validation (français court)
5) phraseFinale = récap complète utilisant UNIQUEMENT le vocabulaire autorisé
6) difficulte: "débutant" ou "intermédiaire"
7) icone: un seul emoji représentatif
8) id: snake_case (ex: pizzeria, gare, pharmacie)
9) themeLieu: description du contexte (ex: "Commander dans une pizzeria italienne")
10) vocabulaireAutorise: TOUJOURS inclure la ponctuation (ex: "Ciao ." pas "Ciao")

EXEMPLE de structure etapes:
[
  {
    "objectif": "Saluer",
    "phraseCible": "Buongiorno .",
    "validation": "Super . Continue ."
  },
  {
    "objectif": "Commander",
    "phraseCible": "una pizza margherita per favore .",
    "validation": "Parfait . Étape 3 ."
  }
]

THÈME DEMANDÉ: ${theme}

GÉNÈRE LE JSON COMPLET maintenant (uniquement le JSON, pas de texte avant/après):`;

  console.log('🔄 Appel à OpenAI...');
  
  try {
    const text = await callAI(aiPrompt);
    
    console.log('✅ Réponse reçue');
    
    let jsonText = text.trim();
    
    if (jsonText.startsWith('```json')) {
      jsonText = jsonText.replace(/```json\n?/g, '').replace(/```\n?/g, '');
    } else if (jsonText.startsWith('```')) {
      jsonText = jsonText.replace(/```\n?/g, '');
    }
    
    jsonText = jsonText.trim();
    
    const params = JSON.parse(jsonText);
    
    const required = ['id', 'titre', 'icone', 'description', 'difficulte', 'themeLieu', 'nombreEtapes', 'vocabulaireAutorise', 'etapes', 'phraseFinale'];
    const missing = required.filter(key => !params[key]);
    
    if (missing.length > 0) {
      throw new Error(`Paramètres manquants : ${missing.join(', ')}`);
    }
    
    const scenario = generateScenario(params);
    
    console.log(`✅ Scénario généré: ${scenario.id}`);
    
    return scenario;
    
  } catch (error) {
    console.error(`❌ Erreur pour "${theme}":`, error.message);
    return null;
  }
}

async function generateNewThemes(existingScenarios) {
  console.log('🤖 Génération de 10 nouveaux thèmes...\n');
  
  const existingTitles = existingScenarios.map(s => s.title).join('\n- ');
  
  const prompt = `Tu es un générateur de thèmes pour des scénarios d'apprentissage de l'italien pour francophones.

SCÉNARIOS EXISTANTS :
- ${existingTitles}

TA MISSION :
Propose 10 NOUVEAUX thèmes de scénarios différents de ceux existants.

CONTRAINTES :
- Thèmes pratiques pour un touriste/apprenant en Italie
- Varié : restaurants, transports, services, loisirs, etc.
- Différents des scénarios existants
- Phrases courtes et claires
- Mélange de débutant et intermédiaire

FORMAT DE RÉPONSE (UNIQUEMENT un tableau JSON, rien d'autre) :
[
  "thème 1",
  "thème 2",
  ...
]

Exemples de thèmes :
- "louer un vélo"
- "au cinéma"
- "acheter des vêtements"
- "chez le médecin"

GÉNÈRE LES 10 NOUVEAUX THÈMES maintenant (uniquement le JSON) :`;

  console.log('🔄 Appel à OpenAI pour générer les thèmes...');
  
  const text = await callAI(prompt);
  
  let jsonText = text.trim();
  if (jsonText.startsWith('```json')) {
    jsonText = jsonText.replace(/```json\n?/g, '').replace(/```\n?/g, '');
  } else if (jsonText.startsWith('```')) {
    jsonText = jsonText.replace(/```\n?/g, '');
  }
  
  const themes = JSON.parse(jsonText.trim());
  
  console.log('✅ 10 nouveaux thèmes générés :\n');
  themes.forEach((theme, i) => {
    console.log(`   ${i + 1}. ${theme}`);
  });
  console.log('');
  
  return themes;
}

async function generateBatch() {
  console.log('\n🚀 GÉNÉRATEUR BATCH DE SCÉNARIOS\n');
  console.log('═'.repeat(60));
  
  // Lire les scénarios existants
  console.log('📂 Lecture des scénarios existants...');
  const data = JSON.parse(fs.readFileSync(SCENARIOS_PATH, 'utf8'));
  const initialCount = data.scenarios.length;
  
  console.log(`✅ ${initialCount} scénarios existants\n`);
  
  // Générer 10 nouveaux thèmes
  const themes = await generateNewThemes(data.scenarios);
  
  console.log(`📊 ${themes.length} nouveaux thèmes à générer\n`);
  
  // Générer chaque scénario
  let successCount = 0;
  let failCount = 0;
  
  for (let i = 0; i < themes.length; i++) {
    const theme = themes[i];
    const scenario = await generateScenarioFromTheme(theme, i + 1, themes.length);
    
    if (scenario) {
      // Vérifier si existe déjà
      const existingIndex = data.scenarios.findIndex(s => s.id === scenario.id);
      
      if (existingIndex !== -1) {
        console.log(`⚠️  Scénario "${scenario.id}" existe déjà - mise à jour`);
        data.scenarios[existingIndex] = scenario;
      } else {
        data.scenarios.push(scenario);
        console.log(`➕ Nouveau scénario ajouté`);
      }
      
      successCount++;
    } else {
      failCount++;
    }
    
    // Petit délai pour éviter le rate limiting
    if (i < themes.length - 1) {
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
  
  // Sauvegarder
  console.log(`\n${'═'.repeat(60)}`);
  console.log('💾 Sauvegarde des scénarios...');
  fs.writeFileSync(SCENARIOS_PATH, JSON.stringify(data, null, 2) + '\n', 'utf8');
  
  console.log(`\n${'═'.repeat(60)}`);
  console.log('📊 RÉSULTAT');
  console.log('═'.repeat(60));
  console.log(`✅ Succès: ${successCount}/${themes.length}`);
  console.log(`❌ Échecs: ${failCount}/${themes.length}`);
  console.log(`📝 Total scénarios: ${data.scenarios.length} (avant: ${initialCount})`);
  console.log(`📁 Fichier: ${SCENARIOS_PATH}\n`);
}

// Main
const args = process.argv.slice(2);

if (args.includes('--help') || args.includes('-h')) {
  console.log(`
🚀 GÉNÉRATEUR BATCH DE SCÉNARIOS

USAGE:
  node generateBatchScenarios.js

Le script va automatiquement :
1. Analyser les scénarios existants dans scenarios.json
2. Générer 10 nouveaux thèmes différents avec l'IA
3. Créer les 10 nouveaux scénarios complets
4. Les ajouter automatiquement à scenarios.json

Aucun fichier requis - tout est automatique ! 🎉
`);
  process.exit(0);
}

console.log('🎯 Mode automatique : génération de 10 nouveaux scénarios\n');

generateBatch().catch(error => {
  console.error('❌ Erreur fatale:', error);
  process.exit(1);
});
