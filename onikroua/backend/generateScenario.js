#!/usr/bin/env node

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const https = require('https');
const readline = require('readline');
const OpenAI = require('openai');

/**
 * Générateur de scénarios pour chatbot ITALIEN VOCAL (STT+TTS)
 * 
 * Ce script génère un objet JSON complet de scénario selon des règles strictes
 * et l'ajoute au fichier scenarios.json
 */

const SCENARIOS_PATH = path.join(__dirname, '../frontend/src/data/scenarios.json');

// Configuration OpenAI (plus fiable que Gemini pour les clés API)
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

if (!OPENAI_API_KEY) {
  console.error('❌ Erreur: OPENAI_API_KEY manquant dans le fichier .env');
  console.error('💡 Ajoute OPENAI_API_KEY=sk-... dans ton fichier .env');
  process.exit(1);
}

const openai = new OpenAI({
  apiKey: OPENAI_API_KEY
});

// Interface pour lire les entrées utilisateur
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(query) {
  return new Promise(resolve => rl.question(query, resolve));
}

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
  console.log('🔧 Génération du systemPrompt...');
  
  const {
    themeLieu,
    nombreEtapes,
    vocabulaireAutorise,
    etapes,
    phraseFinale
  } = params;

  let prompt = '';

  console.log('  ✓ Génération Introduction...');
  // Introduction
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

  console.log('  ✓ Génération FORMAT CRITIQUE...');
  // FORMAT CRITIQUE
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

  console.log('  ✓ Génération COMPORTEMENT AUDIO...');
  // COMPORTEMENT AUDIO
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

  console.log('  ✓ Génération RÈGLE D\'OR...');
  // RÈGLE D'OR
  prompt += `────────────────────────────────\n`;
  prompt += `🧠 RÈGLE D'OR\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += `❗ Une validation = on avance\n`;
  prompt += `❗ Une erreur = UN mot corrigé\n\n`;
  prompt += `Jamais plus.\n\n`;
  prompt += `Tu ne fais JAMAIS répéter une phrase déjà validée.\n\n`;

  console.log('  ✓ Génération GESTION CHAOS STT...');
  // GESTION CHAOS STT
  prompt += `────────────────────────────────\n`;
  prompt += `🔥 GESTION CHAOS STT\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += `Si incohérent :\n`;
  prompt += `➡️ Ignorer\n`;
  prompt += `➡️ Recentrer sur UN mot simple\n\n`;
  prompt += `Aucune explication.\n`;
  prompt += `Aucun reproche.\n\n`;

  console.log(`  ✓ Génération VOCABULAIRE (${vocabulaireAutorise.length} mots)...`);
  // VOCABULAIRE AUTORISÉ
  prompt += `────────────────────────────────\n`;
  prompt += `📖 VOCABULAIRE AUTORISÉ (SEUL)\n`;
  prompt += `────────────────────────────────\n\n`;
  prompt += vocabulaireAutorise.map(v => `- [it]${v}[/it]`).join('\n');
  prompt += `\n\n❌ Tout autre mot italien est INTERDIT.\n`;
  prompt += `❌ Pas de synonymes.\n\n`;

  console.log(`  ✓ Génération SCÉNARIO (${nombreEtapes} étapes)...`);
  // SCÉNARIO EN X ÉTAPES
  prompt += `────────────────────────────────\n`;
  prompt += `🎯 SCÉNARIO EN ${nombreEtapes} ÉTAPES FIXES\n`;
  prompt += `────────────────────────────────\n\n`;
  
  etapes.forEach((etape, index) => {
    prompt += `ÉTAPE ${index + 1} : ${etape.objectif}\n`;
    prompt += `➡️ Phrase cible : [it]${etape.phraseCible}[/it]\n`;
    prompt += `➡️ Validation : "${etape.validation}"\n`;
    prompt += `➡️ On passe à l'étape ${index + 2}.\n\n`;
  });

  console.log('  ✓ Génération PHRASE FINALE + BRAVO...');
  // PHRASE FINALE + BRAVO
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

  console.log('  ✓ Génération FORMAT DES RÉPONSES...');
  // FORMAT DES RÉPONSES
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

  console.log('✅ SystemPrompt généré (' + prompt.length + ' caractères)\n');
  return prompt;
}

function generateScenario(params) {
  console.log('\n📦 Création de l\'objet scénario...');
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

  console.log(`  ✓ ID: ${id}`);
  console.log(`  ✓ Titre: ${titre}`);
  console.log(`  ✓ Difficulté: ${difficulte}`);
  console.log('✅ Objet scénario créé\n');

  return {
    id,
    title: titre,
    icon: icone,
    description,
    difficulty: difficulte,
    systemPrompt
  };
}

function addScenarioToFile(scenario) {
  console.log('📂 Lecture du fichier scenarios.json...');
  // Lire le fichier existant
  const data = JSON.parse(fs.readFileSync(SCENARIOS_PATH, 'utf8'));
  console.log(`  ✓ ${data.scenarios.length} scénarios existants`);
  
  // Vérifier si l'ID existe déjà
  console.log(`\n🔍 Vérification de l'ID "${scenario.id}"...`);
  const existingIndex = data.scenarios.findIndex(s => s.id === scenario.id);
  
  if (existingIndex !== -1) {
    console.log(`\n⚠️  Un scénario avec l'ID "${scenario.id}" existe déjà.`);
    data.scenarios[existingIndex] = scenario;
    console.log(`✅ Scénario mis à jour.`);
  } else {
    data.scenarios.push(scenario);
    console.log(`✅ Nouveau scénario ajouté.`);
  }
  
  // Écrire le fichier
  console.log('\n💾 Écriture du fichier...');
  fs.writeFileSync(SCENARIOS_PATH, JSON.stringify(data, null, 2) + '\n', 'utf8');
  console.log(`📝 Fichier sauvegardé : ${SCENARIOS_PATH}\n`);
}

async function interactiveMode() {
  console.log('\n🎯 GÉNÉRATEUR DE SCÉNARIOS - Mode Interactif\n');
  console.log('═'.repeat(60));
  
  const id = await question('ID du scénario (ex: pizzeria) : ');
  const titre = await question('TITRE (ex: Commander une pizza) : ');
  const icone = await question('ICÔNE (emoji, ex: 🍕) : ');
  const description = await question('DESCRIPTION (1 phrase) : ');
  const difficulte = await question('DIFFICULTÉ (débutant/intermédiaire) : ');
  const themeLieu = await question('THEME_LIEU (ex: Commander dans une pizzeria italienne) : ');
  const nombreEtapes = parseInt(await question('NOMBRE D\'ÉTAPES (3-5) : '));
  
  console.log('\n📖 VOCABULAIRE AUTORISÉ');
  console.log('Entrez les mots/phrases italiens (un par ligne, ligne vide pour terminer) :');
  const vocabulaireAutorise = [];
  while (true) {
    const mot = await question('> ');
    if (!mot.trim()) break;
    vocabulaireAutorise.push(mot.trim());
  }
  
  console.log('\n🎯 ÉTAPES');
  const etapes = [];
  for (let i = 1; i <= nombreEtapes; i++) {
    console.log(`\n--- Étape ${i} ---`);
    const objectif = await question(`Objectif de l'étape ${i} : `);
    const phraseCible = await question(`Phrase cible (italien) : `);
    const validation = await question(`Validation (français) : `);
    etapes.push({ objectif, phraseCible, validation });
  }
  
  const phraseFinale = await question('\nPHRASE FINALE (récap complète en italien) : ');
  
  console.log('\n═'.repeat(60));
  console.log('🔧 Génération du scénario...\n');
  
  const scenario = generateScenario({
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
  });
  
  console.log('✅ Scénario généré !\n');
  console.log('Prévisualisation :');
  console.log('─'.repeat(60));
  console.log(JSON.stringify(scenario, null, 2));
  console.log('─'.repeat(60));
  
  const confirm = await question('\nAjouter ce scénario au fichier ? (oui/non) : ');
  
  if (confirm.toLowerCase() === 'oui' || confirm.toLowerCase() === 'o' || confirm.toLowerCase() === 'y' || confirm.toLowerCase() === 'yes') {
    addScenarioToFile(scenario);
  } else {
    console.log('\n❌ Annulé. Scénario non ajouté.\n');
  }
  
  rl.close();
}

async function aiMode(theme) {
  console.log('\n🤖 Mode Génération AI\n');
  console.log('═'.repeat(60));
  console.log(`🎯 Thème: ${theme}\n`);

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
    
    console.log('✅ Réponse reçue de l\'IA\n');
    
    // Afficher la réponse brute pour debug
    console.log('📝 Réponse brute (premiers 500 caractères):');
    console.log(text.substring(0, 500));
    console.log('...\n');
    
    // Extraire le JSON de la réponse
    let jsonText = text.trim();
    
    // Retirer les balises markdown si présentes
    if (jsonText.startsWith('```json')) {
      jsonText = jsonText.replace(/```json\n?/g, '').replace(/```\n?/g, '');
    } else if (jsonText.startsWith('```')) {
      jsonText = jsonText.replace(/```\n?/g, '');
    }
    
    jsonText = jsonText.trim();
    
    console.log('🔍 Parsing du JSON généré...');
    console.log(`📏 Taille du JSON: ${jsonText.length} caractères\n`);
    
    if (jsonText.length === 0) {
      console.error('❌ La réponse de l\'IA est vide');
      console.log('\n📄 Réponse complète:');
      console.log(text);
      rl.close();
      process.exit(1);
    }
    
    const params = JSON.parse(jsonText);
    console.log('  ✓ JSON valide');
    
    // Validation des paramètres requis
    console.log('\n🔍 Validation des paramètres...');
    const required = ['id', 'titre', 'icone', 'description', 'difficulte', 'themeLieu', 'nombreEtapes', 'vocabulaireAutorise', 'etapes', 'phraseFinale'];
    const missing = required.filter(key => !params[key]);
    console.log(`  ✓ ${required.length - missing.length}/${required.length} paramètres présents`);
    
    if (missing.length > 0) {
      console.error(`❌ Paramètres manquants : ${missing.join(', ')}`);
      console.log('\n📄 Réponse brute de l\'IA:');
      console.log(text);
      process.exit(1);
    }
    
    const scenario = generateScenario(params);
    
    console.log('\n═'.repeat(60));
    console.log('📄 SCÉNARIO GÉNÉRÉ PAR IA');
    console.log('═'.repeat(60));
    console.log(JSON.stringify(scenario, null, 2));
    console.log('\n═'.repeat(60));
    
    // Demander confirmation avant d'ajouter
    const confirm = await question('\nAjouter ce scénario au fichier ? (oui/non) : ');
    
    if (confirm.toLowerCase() === 'oui' || confirm.toLowerCase() === 'o' || confirm.toLowerCase() === 'y' || confirm.toLowerCase() === 'yes') {
      addScenarioToFile(scenario);
      console.log('\n🎉 Scénario ajouté avec succès !\n');
    } else {
      console.log('\n❌ Annulé. Scénario non ajouté.\n');
    }
    
    rl.close();
    
  } catch (error) {
    console.error('❌ Erreur lors de la génération avec l\'IA :', error.message);
    if (error.response) {
      console.error('Réponse:', error.response);
    }
    rl.close();
    process.exit(1);
  }
}

function jsonMode(jsonInput) {
  console.log('\n📥 Mode JSON Direct\n');
  console.log('═'.repeat(60));
  try {
    console.log('🔍 Parsing du JSON...');
    const params = JSON.parse(jsonInput);
    console.log('  ✓ JSON valide');
    
    // Validation des paramètres requis
    console.log('\n🔍 Validation des paramètres...');
    const required = ['id', 'titre', 'icone', 'description', 'difficulte', 'themeLieu', 'nombreEtapes', 'vocabulaireAutorise', 'etapes', 'phraseFinale'];
    const missing = required.filter(key => !params[key]);
    console.log(`  ✓ ${required.length - missing.length}/${required.length} paramètres présents`);
    
    if (missing.length > 0) {
      console.error(`❌ Paramètres manquants : ${missing.join(', ')}`);
      process.exit(1);
    }
    
    const scenario = generateScenario(params);
    
    console.log('\n═'.repeat(60));
    console.log('📄 SCÉNARIO GÉNÉRÉ');
    console.log('═'.repeat(60));
    // Afficher le JSON généré
    console.log(JSON.stringify(scenario, null, 2));
    console.log('\n═'.repeat(60));
    
  } catch (error) {
    console.error('❌ Erreur lors du parsing JSON :', error.message);
    process.exit(1);
  }
}

function fileMode(filePath) {
  console.log('\n📁 Mode Fichier\n');
  console.log('═'.repeat(60));
  try {
    console.log(`📂 Lecture du fichier: ${filePath}`);
    const jsonInput = fs.readFileSync(filePath, 'utf8');
    console.log('  ✓ Fichier lu');
    console.log('\n🔍 Parsing du JSON...');
    const params = JSON.parse(jsonInput);
    console.log('  ✓ JSON valide');
    
    const scenario = generateScenario(params);
    
    console.log('✅ Scénario généré depuis le fichier !\n');
    
    addScenarioToFile(scenario);
    
  } catch (error) {
    console.error('❌ Erreur :', error.message);
    process.exit(1);
  }
}

// Main
const args = process.argv.slice(2);

if (args.length === 0) {
  // Mode interactif
  interactiveMode();
} else if (args[0] === '--gemini' && args[1]) {
  // Mode AI (OpenAI)
  const theme = args.slice(1).join(' ');
  aiMode(theme);
} else if (args[0] === '--json') {
  // Mode JSON direct
  const jsonInput = args.slice(1).join(' ');
  jsonMode(jsonInput);
} else if (args[0] === '--file' && args[1]) {
  // Mode fichier
  fileMode(args[1]);
} else if (args[0] === '--help' || args[0] === '-h') {
  console.log(`
🎯 GÉNÉRATEUR DE SCÉNARIOS ITALIEN VOCAL

USAGE:
  node generateScenario.js                         # Mode interactif
  node generateScenario.js --gemini "pizzeria"     # Génération avec IA (OpenAI)
  node generateScenario.js --file input.json       # Depuis un fichier
  node generateScenario.js --json '{...}'          # JSON direct
  node generateScenario.js --help                  # Afficher l'aide

MODE IA (RECOMMANDÉ):
  node generateScenario.js --gemini "pharmacie"
  node generateScenario.js --gemini "à l'hôtel"
  node generateScenario.js --gemini "prendre le train"
  
  L'IA générera automatiquement:
  - L'ID, titre, description, icône
  - Le vocabulaire italien approprié
  - Les étapes pédagogiques
  - La phrase finale récapitulative

EXEMPLE DE FICHIER JSON:
{
  "id": "pizzeria",
  "titre": "Commander une pizza",
  "icone": "🍕",
  "description": "Apprends à commander une pizza en italien",
  "difficulte": "débutant",
  "themeLieu": "Commander dans une pizzeria italienne",
  "nombreEtapes": 4,
  "vocabulaireAutorise": [
    "Buongiorno .",
    "una pizza margherita",
    "per favore .",
    "Grazie ."
  ],
  "etapes": [
    {
      "objectif": "Saluer",
      "phraseCible": "Buongiorno .",
      "validation": "Super . Continue ."
    },
    {
      "objectif": "Commander la pizza",
      "phraseCible": "una pizza margherita per favore .",
      "validation": "Parfait . Étape 3 ."
    }
  ],
  "phraseFinale": "Buongiorno . Una pizza margherita per favore . Grazie ."
}
`);
} else {
  console.error('❌ Arguments invalides. Utilisez --help pour l\'aide.');
  process.exit(1);
}
