const fs = require('fs');
const https = require('https');

// Liste de mots italiens de base à chercher (A1-B1)
const baseWords = [
  // Verbes communs
  'essere', 'avere', 'fare', 'dire', 'andare', 'potere', 'dovere', 'volere', 'sapere', 'vedere',
  'venire', 'prendere', 'dare', 'stare', 'uscire', 'parlare', 'mangiare', 'bere', 'dormire', 'leggere',
  'scrivere', 'aprire', 'chiudere', 'capire', 'sentire', 'ascoltare', 'guardare', 'cercare', 'trovare', 'lasciare',
  'mettere', 'portare', 'chiamare', 'amare', 'credere', 'pensare', 'vivere', 'morire', 'nascere', 'crescere',
  'cambiare', 'rimanere', 'tornare', 'arrivare', 'partire', 'entrare', 'salire', 'scendere', 'correre', 'camminare',
  
  // Noms communs
  'casa', 'famiglia', 'persona', 'uomo', 'donna', 'bambino', 'ragazzo', 'ragazza', 'amico', 'tempo',
  'giorno', 'anno', 'mese', 'settimana', 'ora', 'mattina', 'sera', 'notte', 'città', 'paese',
  'strada', 'piazza', 'chiesa', 'scuola', 'università', 'ufficio', 'negozio', 'mercato', 'ristorante', 'bar',
  'lavoro', 'vita', 'morte', 'amore', 'pace', 'guerra', 'mondo', 'terra', 'cielo', 'mare',
  'montagna', 'fiume', 'lago', 'albero', 'fiore', 'animale', 'cane', 'gatto', 'uccello', 'pesce',
  'libro', 'giornale', 'lettera', 'parola', 'lingua', 'nome', 'numero', 'colore', 'forma', 'cosa',
  'acqua', 'fuoco', 'aria', 'pane', 'vino', 'cibo', 'carne', 'frutta', 'verdura', 'pizza',
  
  // Adjectifs
  'bello', 'buono', 'grande', 'piccolo', 'nuovo', 'vecchio', 'giovane', 'alto', 'basso', 'lungo',
  'corto', 'largo', 'stretto', 'forte', 'debole', 'ricco', 'povero', 'felice', 'triste', 'allegro',
  'difficile', 'facile', 'importante', 'interessante', 'caldo', 'freddo', 'nero', 'bianco', 'rosso', 'blu',
  'verde', 'giallo', 'azzurro', 'chiaro', 'scuro', 'primo', 'ultimo', 'migliore', 'peggiore', 'maggiore',
  
  // Adverbes
  'molto', 'poco', 'troppo', 'abbastanza', 'sempre', 'mai', 'spesso', 'raramente', 'ancora', 'già',
  'qui', 'là', 'dove', 'quando', 'come', 'perché', 'bene', 'male', 'presto', 'tardi',
  
  // Autres mots fréquents
  'anche', 'ma', 'però', 'quindi', 'allora', 'poi', 'prima', 'dopo', 'durante', 'mentre',
  'oggi', 'domani', 'ieri', 'adesso', 'ora', 'subito', 'insieme', 'solo', 'tutti', 'niente'
];

// Fonction pour faire une requête HTTP GET
function httpsGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

// Fonction pour récupérer les traductions depuis Wiktionary
async function getWiktionaryData(word) {
  try {
    const url = `https://it.wiktionary.org/w/api.php?action=parse&page=${encodeURIComponent(word)}&prop=wikitext&format=json&origin=*`;
    const data = await httpsGet(url);
    
    if (data.error) {
      console.log(`❌ Mot "${word}" non trouvé`);
      return null;
    }

    const wikitext = data.parse?.wikitext?.['*'] || '';
    return parseWikitext(word, wikitext);
  } catch (error) {
    console.error(`Erreur pour "${word}":`, error.message);
    return null;
  }
}

// Parser le wikitext pour extraire les informations
function parseWikitext(word, wikitext) {
  const result = {
    it: word,
    fr: '',
    es: '',
    category: 'nom',
    definitions: {
      fr: [],
      es: []
    }
  };

  // Déterminer la catégorie grammaticale
  if (wikitext.includes('{{-verb-}}') || wikitext.includes('{{-verbo-}}')) {
    result.category = 'verbe';
  } else if (wikitext.includes('{{-adj-}}') || wikitext.includes('{{-agg-}}')) {
    result.category = 'adjectif';
  } else if (wikitext.includes('{{-adv-}}') || wikitext.includes('{{-avv-}}')) {
    result.category = 'adverbe';
  } else if (wikitext.includes('{{-noun-}}') || wikitext.includes('{{-sost-}}') || wikitext.includes('{{-nome-}}')) {
    result.category = 'nom';
  } else if (wikitext.includes('{{-prep-}}')) {
    result.category = 'préposition';
  } else if (wikitext.includes('{{-conj-}}')) {
    result.category = 'conjonction';
  }

  // Chercher les traductions françaises
  const frMatch = wikitext.match(/{{-trad-}}\s*\n[^]*?==\s*{{[Ff]rancese}}\s*==\s*\n[^]*?\*\s*{{Trad\|fr\|([^}]+)}}/);
  if (frMatch) {
    result.fr = frMatch[1].trim();
  } else {
    // Autre pattern pour français
    const frMatch2 = wikitext.match(/\*\s*{{[Ff]rancese}}:\s*\[\[([^\]]+)\]\]/);
    if (frMatch2) {
      result.fr = frMatch2[1].trim();
    }
  }

  // Chercher les traductions espagnoles
  const esMatch = wikitext.match(/{{-trad-}}\s*\n[^]*?==\s*{{[Ss]pagnolo}}\s*==\s*\n[^]*?\*\s*{{Trad\|es\|([^}]+)}}/);
  if (esMatch) {
    result.es = esMatch[1].trim();
  } else {
    // Autre pattern pour espagnol
    const esMatch2 = wikitext.match(/\*\s*{{[Ss]pagnolo}}:\s*\[\[([^\]]+)\]\]/);
    if (esMatch2) {
      result.es = esMatch2[1].trim();
    }
  }

  return result;
}

// Traductions manuelles de secours (pour les mots très courants)
const manualTranslations = {
  // Verbes
  'essere': { fr: 'être', es: 'ser', category: 'verbe' },
  'avere': { fr: 'avoir', es: 'tener', category: 'verbe' },
  'fare': { fr: 'faire', es: 'hacer', category: 'verbe' },
  'dire': { fr: 'dire', es: 'decir', category: 'verbe' },
  'andare': { fr: 'aller', es: 'ir', category: 'verbe' },
  'potere': { fr: 'pouvoir', es: 'poder', category: 'verbe' },
  'dovere': { fr: 'devoir', es: 'deber', category: 'verbe' },
  'volere': { fr: 'vouloir', es: 'querer', category: 'verbe' },
  'sapere': { fr: 'savoir', es: 'saber', category: 'verbe' },
  'vedere': { fr: 'voir', es: 'ver', category: 'verbe' },
  'venire': { fr: 'venir', es: 'venir', category: 'verbe' },
  'prendere': { fr: 'prendre', es: 'tomar', category: 'verbe' },
  'dare': { fr: 'donner', es: 'dar', category: 'verbe' },
  'stare': { fr: 'rester', es: 'estar', category: 'verbe' },
  'parlare': { fr: 'parler', es: 'hablar', category: 'verbe' },
  'mangiare': { fr: 'manger', es: 'comer', category: 'verbe' },
  'bere': { fr: 'boire', es: 'beber', category: 'verbe' },
  'dormire': { fr: 'dormir', es: 'dormir', category: 'verbe' },
  'leggere': { fr: 'lire', es: 'leer', category: 'verbe' },
  'scrivere': { fr: 'écrire', es: 'escribir', category: 'verbe' },
  
  // Noms
  'casa': { fr: 'maison', es: 'casa', category: 'nom' },
  'uomo': { fr: 'homme', es: 'hombre', category: 'nom' },
  'donna': { fr: 'femme', es: 'mujer', category: 'nom' },
  'bambino': { fr: 'enfant', es: 'niño', category: 'nom' },
  'amico': { fr: 'ami', es: 'amigo', category: 'nom' },
  'tempo': { fr: 'temps', es: 'tiempo', category: 'nom' },
  'giorno': { fr: 'jour', es: 'día', category: 'nom' },
  'anno': { fr: 'année', es: 'año', category: 'nom' },
  'città': { fr: 'ville', es: 'ciudad', category: 'nom' },
  'scuola': { fr: 'école', es: 'escuela', category: 'nom' },
  'libro': { fr: 'livre', es: 'libro', category: 'nom' },
  'acqua': { fr: 'eau', es: 'agua', category: 'nom' },
  'pane': { fr: 'pain', es: 'pan', category: 'nom' },
  
  // Adjectifs
  'bello': { fr: 'beau', es: 'bonito', category: 'adjectif' },
  'buono': { fr: 'bon', es: 'bueno', category: 'adjectif' },
  'grande': { fr: 'grand', es: 'grande', category: 'adjectif' },
  'piccolo': { fr: 'petit', es: 'pequeño', category: 'adjectif' },
  'nuovo': { fr: 'nouveau', es: 'nuevo', category: 'adjectif' },
  'vecchio': { fr: 'vieux', es: 'viejo', category: 'adjectif' },
  
  // Adverbes
  'molto': { fr: 'beaucoup', es: 'muy', category: 'adverbe' },
  'poco': { fr: 'peu', es: 'poco', category: 'adverbe' },
  'sempre': { fr: 'toujours', es: 'siempre', category: 'adverbe' },
  'mai': { fr: 'jamais', es: 'nunca', category: 'adverbe' },
  'bene': { fr: 'bien', es: 'bien', category: 'adverbe' },
  'male': { fr: 'mal', es: 'mal', category: 'adverbe' }
};

// Fonction principale
async function generateDictionary() {
  console.log('🚀 Génération du dictionnaire depuis Wiktionary...\n');
  
  const dictionary = [];
  const processed = new Set();
  
  for (let i = 0; i < baseWords.length; i++) {
    const word = baseWords[i];
    
    if (processed.has(word)) continue;
    processed.add(word);
    
    console.log(`[${i + 1}/${baseWords.length}] Traitement de "${word}"...`);
    
    // Essayer d'abord les traductions manuelles
    if (manualTranslations[word]) {
      const manual = manualTranslations[word];
      dictionary.push({
        it: word,
        fr: manual.fr,
        es: manual.es,
        category: manual.category
      });
      console.log(`✅ "${word}" (manuel) → FR: ${manual.fr}, ES: ${manual.es}`);
    } else {
      // Sinon, essayer Wiktionary
      const data = await getWiktionaryData(word);
      
      if (data && data.fr && data.es) {
        dictionary.push({
          it: data.it,
          fr: data.fr,
          es: data.es,
          category: data.category
        });
        console.log(`✅ "${word}" → FR: ${data.fr}, ES: ${data.es}`);
      } else {
        console.log(`⚠️  "${word}" - traductions incomplètes, ignoré`);
      }
      
      // Pause pour ne pas surcharger l'API
      await new Promise(resolve => setTimeout(resolve, 500));
    }
  }
  
  // Trier par ordre alphabétique
  dictionary.sort((a, b) => a.it.localeCompare(b.it));
  
  // Sauvegarder le fichier JSON
  const outputPath = '../frontend/src/data/dictionary.json';
  const jsonContent = {
    words: dictionary,
    metadata: {
      generated: new Date().toISOString(),
      total: dictionary.length,
      source: 'Wiktionary API + Manual'
    }
  };
  
  fs.writeFileSync(outputPath, JSON.stringify(jsonContent, null, 2), 'utf-8');
  
  console.log(`\n✨ Dictionnaire généré avec succès !`);
  console.log(`📊 ${dictionary.length} mots enregistrés`);
  console.log(`📁 Fichier: ${outputPath}`);
  
  // Statistiques par catégorie
  const stats = {};
  dictionary.forEach(word => {
    stats[word.category] = (stats[word.category] || 0) + 1;
  });
  
  console.log('\n📈 Statistiques:');
  Object.entries(stats).forEach(([cat, count]) => {
    console.log(`   ${cat}: ${count} mots`);
  });
}

// Exécuter le script
generateDictionary().catch(console.error);
