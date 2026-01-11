const fs = require('fs');
const path = require('path');

const INPUT_DIR = '../frontend/src/data/wordItalian';
const OUTPUT_FILE = '../frontend/src/data/italian_words_consolidated.json';

const CSV_FILES = {
  verbs: 'itwac_verbs_lemmas_notail_2_1_0.csv',
  nouns: 'itwac_nouns_lemmas_notail_2_0_0.csv',
  adjectives: 'itwac_adj_lemmas_notail_2_1_0.csv'
};

function parseCSVLine(line) {
  const values = [];
  let current = '';
  let inQuotes = false;
  
  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    
    if (char === '"') {
      inQuotes = !inQuotes;
    } else if (char === ',' && !inQuotes) {
      values.push(current.trim());
      current = '';
    } else {
      current += char;
    }
  }
  
  values.push(current.trim());
  return values;
}

function parseCSVFile(filePath, category) {
  console.log(`\n📖 Parsing ${category}...`);
  
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');
  
  const words = new Map();
  let skipped = 0;
  
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;
    
    const values = parseCSVLine(line);
    
    if (values.length < 6) {
      skipped++;
      continue;
    }
    
    const form = values[0];
    const freq = parseInt(values[1]) || 0;
    const lemma = values[2];
    const pos = values[3];
    
    if (!lemma || lemma === 'lemma') continue;
    
    const cleanLemma = lemma.replace(/"/g, '').trim().toLowerCase();
    
    if (cleanLemma.length === 0 || cleanLemma.includes('�')) {
      skipped++;
      continue;
    }
    
    if (!words.has(cleanLemma) || words.get(cleanLemma).freq < freq) {
      words.set(cleanLemma, {
        lemma: cleanLemma,
        category: category,
        pos: pos,
        freq: freq,
        form: form.replace(/"/g, '').trim()
      });
    }
  }
  
  console.log(`   ✅ ${words.size} mots uniques extraits`);
  console.log(`   ⚠️  ${skipped} lignes ignorées`);
  
  return Array.from(words.values());
}

function consolidateWords() {
  console.log('🚀 Consolidation des mots italiens depuis les CSV\n');
  console.log('════════════════════════════════════════════════\n');
  
  const allWords = [];
  const stats = {
    total: 0,
    verbs: 0,
    nouns: 0,
    adjectives: 0
  };
  
  for (const [category, filename] of Object.entries(CSV_FILES)) {
    const filePath = path.join(__dirname, INPUT_DIR, filename);
    
    if (!fs.existsSync(filePath)) {
      console.error(`❌ Fichier non trouvé: ${filePath}`);
      continue;
    }
    
    const words = parseCSVFile(filePath, category);
    
    for (const word of words) {
      allWords.push(word);
    }
    
    stats[category] = words.length;
    stats.total += words.length;
  }
  
  allWords.sort((a, b) => b.freq - a.freq);
  
  const uniqueLemmas = new Map();
  allWords.forEach(word => {
    if (!uniqueLemmas.has(word.lemma)) {
      uniqueLemmas.set(word.lemma, word);
    }
  });
  
  const finalWords = Array.from(uniqueLemmas.values());
  
  const outputData = {
    metadata: {
      generated: new Date().toISOString(),
      source: 'ItWaC Corpus',
      total: finalWords.length,
      categories: {
        verbs: stats.verbs,
        nouns: stats.nouns,
        adjectives: stats.adjectives
      }
    },
    words: finalWords
  };
  
  const outputPath = path.join(__dirname, OUTPUT_FILE);
  fs.writeFileSync(outputPath, JSON.stringify(outputData, null, 2), 'utf-8');
  
  console.log('\n════════════════════════════════════════════════');
  console.log('✨ CONSOLIDATION TERMINÉE\n');
  console.log('📊 Statistiques:');
  console.log(`   • Verbes: ${stats.verbs.toLocaleString()} mots`);
  console.log(`   • Noms: ${stats.nouns.toLocaleString()} mots`);
  console.log(`   • Adjectifs: ${stats.adjectives.toLocaleString()} mots`);
  console.log(`   • TOTAL: ${finalWords.length.toLocaleString()} mots uniques`);
  console.log(`\n📁 Fichier généré: ${outputPath}`);
  console.log('════════════════════════════════════════════════\n');
  
  console.log('🔝 Top 20 mots les plus fréquents:\n');
  finalWords.slice(0, 20).forEach((word, index) => {
    console.log(`   ${(index + 1).toString().padStart(2)}. ${word.lemma.padEnd(20)} [${word.category.padEnd(10)}] - ${word.freq.toLocaleString()} occ.`);
  });
}

consolidateWords();
