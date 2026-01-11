const fs = require('fs');
const path = require('path');

const INPUT_DIR = '../frontend/src/data/wordItalian';
const OUTPUT_FILE = '../frontend/src/data/italian_words_top7000.json';

const DATA_FILES = {
  verbs: { file: 'itwac_verbs_lemmas_notail_2_1_0.csv', count: 2000 },
  nouns: { file: 'itwac_nouns_lemmas_notail_2_0_0.csv', count: 3000 },
  adjectives: { file: 'itwac_adj_lemmas_notail_2_1_0.csv', count: 2000 }
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

function extractTopLemmasFromFile(filePath, category, maxCount) {
  console.log(`   📖 Extraction des ${maxCount} premiers ${category}...`);
  
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');
  
  const lemmaMap = new Map();
  
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;
    
    const values = parseCSVLine(line);
    if (values.length < 6) continue;
    
    const form = values[0].replace(/"/g, '').trim();
    const freq = parseInt(values[1]) || 0;
    const lemma = values[2].replace(/"/g, '').trim().toLowerCase();
    const pos = values[3].replace(/"/g, '').trim();
    const mode = values[4] ? values[4].replace(/"/g, '').trim() : '';
    
    if (!lemma || lemma === 'lemma' || lemma.includes('�')) continue;
    
    if (!lemmaMap.has(lemma)) {
      lemmaMap.set(lemma, {
        lemma: lemma,
        totalFreq: 0,
        forms: []
      });
    }
    
    const lemmaData = lemmaMap.get(lemma);
    lemmaData.totalFreq += freq;
    lemmaData.forms.push({
      form: form,
      freq: freq,
      pos: pos,
      mode: mode,
      category: category
    });
  }
  
  const sortedLemmas = Array.from(lemmaMap.values())
    .sort((a, b) => b.totalFreq - a.totalFreq)
    .slice(0, maxCount);
  
  console.log(`      ✓ ${sortedLemmas.length} lemmes uniques extraits\n`);
  return sortedLemmas;
}


function consolidateWords(wordsByCategory) {
  console.log('🔗 Consolidation des mots...\n');
  
  const allWords = [];
  
  for (const [category, words] of Object.entries(wordsByCategory)) {
    console.log(`   ✓ ${category}: ${words.length} mots`);
    
    for (const wordData of words) {
      const pos_tags = new Set();
      const modes = new Set();
      
      for (const form of wordData.forms) {
        pos_tags.add(form.pos);
        if (form.mode) modes.add(form.mode);
      }
      
      wordData.forms.sort((a, b) => b.freq - a.freq);
      
      allWords.push({
        lemma: wordData.lemma,
        category: category,
        total_freq: wordData.totalFreq,
        pos_tags: Array.from(pos_tags),
        modes: Array.from(modes),
        forms_count: wordData.forms.length,
        forms: wordData.forms
      });
    }
  }
  
  console.log(`\n   ✅ Total: ${allWords.length} mots consolidés\n`);
  return allWords;
}

function generateTop7000() {
  console.log('🚀 Génération du dictionnaire des 7000 mots italiens les plus fréquents\n');
  console.log('════════════════════════════════════════════════════════════════════\n');
  
  console.log('📚 Extraction des mots par catégorie...\n');
  
  const wordsByCategory = {};
  
  for (const [category, config] of Object.entries(DATA_FILES)) {
    const filePath = path.join(__dirname, INPUT_DIR, config.file);
    
    if (!fs.existsSync(filePath)) {
      console.error(`   ❌ Fichier non trouvé: ${filePath}\n`);
      continue;
    }
    
    wordsByCategory[category] = extractTopLemmasFromFile(filePath, category, config.count);
  }
  
  const allWords = consolidateWords(wordsByCategory);
  
  const stats = {
    total: allWords.length,
    by_category: {}
  };
  
  for (const word of allWords) {
    stats.by_category[word.category] = (stats.by_category[word.category] || 0) + 1;
  }
  
  const outputData = {
    metadata: {
      generated: new Date().toISOString(),
      source: 'ItWaC Corpus - Top 7000 words',
      description: '2000 verbes + 2000 adjectifs + 3000 noms italiens les plus fréquents',
      composition: {
        verbs: 2000,
        adjectives: 2000,
        nouns: 3000
      },
      total: allWords.length,
      stats: stats
    },
    words: allWords
  };
  
  const outputPath = path.join(__dirname, OUTPUT_FILE);
  fs.writeFileSync(outputPath, JSON.stringify(outputData, null, 2), 'utf-8');
  
  console.log('════════════════════════════════════════════════════════════════════');
  console.log('✨ GÉNÉRATION TERMINÉE\n');
  console.log('📊 Statistiques finales:');
  console.log(`   • Total de mots: ${stats.total}`);
  console.log('\n   📚 Répartition par catégories:');
  for (const [cat, count] of Object.entries(stats.by_category)) {
    console.log(`      • ${cat}: ${count} mots`);
  }
  console.log(`\n📁 Fichier généré: ${outputPath}`);
  console.log('════════════════════════════════════════════════════════════════════\n');
  
  console.log('🔝 Top 10 par catégorie:\n');
  
  for (const category of ['verbs', 'nouns', 'adjectives']) {
    const categoryWords = allWords.filter(w => w.category === category).slice(0, 10);
    console.log(`   ${category.toUpperCase()}:`);
    categoryWords.forEach((word, index) => {
      console.log(`      ${(index + 1).toString().padStart(2)}. ${word.lemma.padEnd(20)} - ${word.forms_count} formes (freq: ${word.total_freq})`);
    });
    console.log('');
  }
  
  console.log('\n📝 Exemple de mot enrichi (premier verbe):\n');
  const firstVerb = allWords.find(w => w.category === 'verbs');
  if (firstVerb) {
    console.log(JSON.stringify(firstVerb, null, 2));
  }
}

generateTop7000();
