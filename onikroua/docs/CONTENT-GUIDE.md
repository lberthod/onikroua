# 📖 Guide de Création de Contenu - Onikroua

Ce guide explique comment ajouter du contenu d'apprentissage à Onikroua.

## 📝 Structure du Contenu

### Format JSON pour Conjugaisons

```json
{
  "id": "it-parlare-present",
  "language": "it",
  "difficulty": "beginner",
  "verb": "parlare",
  "tense": "Présent",
  "content": "Conjugaison du verbe parler en italien",
  "translation": "parler",
  "conjugations": {
    "io": "parlo",
    "tu": "parli",
    "lui/lei": "parla",
    "noi": "parliamo",
    "voi": "parlate",
    "loro": "parlano"
  },
  "example": "Io parlo italiano. (Je parle italien.)"
}
```

### Format JSON pour Vocabulaire

```json
{
  "id": "it-casa",
  "language": "it",
  "difficulty": "beginner",
  "category": "Maison",
  "content": "Casa",
  "translation": "Maison",
  "gender": "f",
  "plural": "Case",
  "example": "La mia casa è grande. (Ma maison est grande.)"
}
```

### Format JSON pour Grammaire

```json
{
  "id": "it-articles-definis",
  "language": "it",
  "difficulty": "beginner",
  "rule": "Articles définis",
  "content": "Les articles définis en italien varient selon le genre et le nombre",
  "translation": "il, lo, la, i, gli, le",
  "example": "il libro (le livre), la casa (la maison)",
  "exceptions": ["lo devant s+consonne, z, gn", "l' devant voyelle"]
}
```

### Format JSON pour Phonétique

```json
{
  "id": "it-ch",
  "language": "it",
  "difficulty": "beginner",
  "content": "CH",
  "phonetic": "/k/",
  "translation": "Se prononce comme 'k' en français",
  "example": "che (ke), chi (ki), chiesa (kiéza)",
  "audioUrl": "/audio/it/ch.mp3"
}
```

## 🇮🇹 Contenu Italien à Ajouter

### Conjugaisons Prioritaires

**Verbes du 1er groupe (-are):**
- parlare, mangiare, amare, cantare, lavorare, abitare, arrivare, chiamare, comprare, guardare

**Verbes du 2ème groupe (-ere):**
- vedere, leggere, scrivere, prendere, mettere, vivere, credere, vendere, correre, sapere

**Verbes du 3ème groupe (-ire):**
- dormire, partire, finire, capire, preferire, aprire, offrire, sentire, servire, venire

**Verbes irréguliers essentiels:**
- essere, avere, fare, andare, stare, venire, dire, dare, potere, volere, dovere, sapere

**Temps à couvrir:**
1. Présent (Presente)
2. Passé composé (Passato prossimo)
3. Imparfait (Imperfetto)
4. Futur simple (Futuro semplice)
5. Conditionnel (Condizionale presente)

### Catégories de Vocabulaire

1. **Salutations & Politesse** - ciao, buongiorno, grazie, prego, scusi
2. **Famille** - madre, padre, figlio, figlia, fratello, sorella
3. **Nourriture** - pane, acqua, vino, pasta, pizza, carne, pesce
4. **Maison** - casa, camera, cucina, bagno, giardino
5. **Ville** - strada, piazza, chiesa, museo, ristorante
6. **Transports** - treno, autobus, macchina, bicicletta, aereo
7. **Corps** - testa, mano, piede, occhio, bocca
8. **Couleurs** - rosso, blu, verde, giallo, bianco, nero
9. **Nombres** - uno, due, tre, quattro, cinque...
10. **Temps** - oggi, domani, ieri, settimana, mese, anno

### Règles de Grammaire

1. Articles définis et indéfinis
2. Formation du pluriel
3. Accord des adjectifs
4. Pronoms personnels
5. Négation
6. Comparatifs et superlatifs
7. Prépositions articulées
8. Passé composé (auxiliaires essere/avere)
9. Pronoms relatifs
10. Subjonctif présent

## 🇪🇸 Contenu Espagnol à Ajouter

### Conjugaisons Prioritaires

**Verbes du 1er groupe (-ar):**
- hablar, trabajar, amar, cantar, llamar, comprar, llegar, mirar, estudiar, viajar

**Verbes du 2ème groupe (-er):**
- comer, beber, leer, correr, vender, aprender, comprender, creer, ver, saber

**Verbes du 3ème groupe (-ir):**
- vivir, escribir, abrir, subir, recibir, partir, decidir, dormir, pedir, sentir

**Verbes irréguliers essentiels:**
- ser, estar, tener, hacer, ir, venir, decir, poder, querer, saber, conocer, dar

**Temps à couvrir:**
1. Présent (Presente)
2. Passé simple (Pretérito indefinido)
3. Imparfait (Pretérito imperfecto)
4. Futur simple (Futuro simple)
5. Conditionnel (Condicional simple)

### Catégories de Vocabulaire

1. **Salutations** - hola, buenos días, gracias, de nada, por favor
2. **Famille** - madre, padre, hijo, hija, hermano, hermana
3. **Nourriture** - pan, agua, vino, paella, tapas, carne, pescado
4. **Maison** - casa, habitación, cocina, baño, jardín
5. **Ville** - calle, plaza, iglesia, museo, restaurante
6. **Transports** - tren, autobús, coche, bicicleta, avión
7. **Corps** - cabeza, mano, pie, ojo, boca
8. **Couleurs** - rojo, azul, verde, amarillo, blanco, negro
9. **Nombres** - uno, dos, tres, cuatro, cinco...
10. **Temps** - hoy, mañana, ayer, semana, mes, año

### Règles de Grammaire

1. Ser vs Estar
2. Articles définis et indéfinis
3. Formation du pluriel
4. Accord des adjectifs
5. Pronoms personnels
6. Négation
7. Gustar et verbes similaires
8. Comparatifs et superlatifs
9. Passé simple vs imparfait
10. Subjonctif présent

## 🎵 Phonétique

### Italien - Sons Spécifiques

| Son | Graphie | Prononciation | Exemples |
|-----|---------|---------------|----------|
| /k/ | ch | comme "k" | che, chi |
| /g/ | gh | comme "g" dur | ghiaccio, spaghetti |
| /ʎ/ | gl+i | comme "ill" | famiglia, figlio |
| /ɲ/ | gn | comme "gn" français | gnocchi, bagno |
| /tʃ/ | c+e,i | comme "tch" | ciao, cinema |
| /dʒ/ | g+e,i | comme "dj" | gelato, giro |
| /ʃ/ | sc+e,i | comme "ch" | pesce, uscire |
| /sk/ | sc+a,o,u | comme "sk" | scuola, scarpa |

### Espagnol - Sons Spécifiques

| Son | Graphie | Prononciation | Exemples |
|-----|---------|---------------|----------|
| /x/ | j, g+e,i | guttural | jamón, gente |
| /ʝ/ | ll, y | comme "y" | llamar, yo |
| /ɲ/ | ñ | comme "gn" | España, niño |
| /r/ | rr, r initial | r roulé fort | perro, rosa |
| /θ/ | c+e,i, z | comme "th" anglais (Espagne) | cinco, zapato |
| /β/ | b, v | entre b et v | beber, vivir |

## 📋 Checklist de Contenu

### Pour chaque verbe:
- [ ] Infinitif et traduction
- [ ] Toutes les personnes
- [ ] Au moins un exemple d'utilisation
- [ ] Niveau de difficulté approprié

### Pour chaque mot de vocabulaire:
- [ ] Mot et traduction
- [ ] Catégorie
- [ ] Genre (si applicable)
- [ ] Exemple d'utilisation
- [ ] Prononciation (si spéciale)

### Pour chaque règle de grammaire:
- [ ] Nom de la règle
- [ ] Explication claire
- [ ] Format/structure
- [ ] Exemples
- [ ] Exceptions (si applicables)

### Pour chaque son phonétique:
- [ ] Graphie
- [ ] Symbole phonétique
- [ ] Explication en français
- [ ] Exemples multiples
- [ ] Audio (optionnel)

## 🔄 Processus d'Ajout

1. **Préparer les données** en format JSON
2. **Ajouter au store** `learning.ts` dans la fonction appropriée
3. **Tester** l'affichage sur la page correspondante
4. **Vérifier** les traductions et exemples
5. **Commit** avec message descriptif

## 📊 Objectifs de Contenu

| Section | Italien | Espagnol |
|---------|---------|----------|
| Conjugaisons | 50 verbes x 5 temps | 50 verbes x 5 temps |
| Vocabulaire | 500 mots | 500 mots |
| Grammaire | 30 règles | 30 règles |
| Phonétique | 15 sons | 15 sons |

## 💡 Conseils

- **Cohérence** : Utiliser le même format pour tous les éléments
- **Progressivité** : Commencer par le niveau débutant
- **Exemples** : Toujours inclure des exemples contextuels
- **Révision** : Faire relire par un locuteur natif si possible
