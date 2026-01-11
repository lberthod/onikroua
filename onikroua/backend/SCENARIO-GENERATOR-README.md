# 🎯 Générateur de Scénarios - Guide d'Utilisation

Script Node.js pour générer automatiquement des scénarios de chatbot vocal italien selon des règles strictes.

## 📋 Prérequis

- Node.js installé
- Fichier `scenarios.json` dans `frontend/src/data/`

## 🚀 Utilisation

### Mode 1 : Interactif (Recommandé pour débuter)

```bash
node generateScenario.js
```

Le script vous guidera étape par étape pour créer votre scénario.

### Mode 2 : Depuis un fichier JSON

```bash
node generateScenario.js --file scenario-example.json
```

### Mode 3 : JSON direct en ligne de commande

```bash
node generateScenario.js --json '{"id":"pizzeria","titre":"Commander une pizza",...}'
```

## 📝 Format d'Entrée JSON

```json
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
```

## ⚙️ Paramètres Requis

| Paramètre | Type | Description | Exemple |
|-----------|------|-------------|---------|
| `id` | string | Identifiant unique du scénario | `"pizzeria"` |
| `titre` | string | Titre du scénario | `"Commander une pizza"` |
| `icone` | string | Emoji représentatif | `"🍕"` |
| `description` | string | Description courte (1 phrase) | `"Apprends à commander..."` |
| `difficulte` | string | Niveau de difficulté | `"débutant"` ou `"intermédiaire"` |
| `themeLieu` | string | Description du contexte | `"Commander dans une pizzeria"` |
| `nombreEtapes` | number | Nombre d'étapes (3-5) | `4` |
| `vocabulaireAutorise` | array | Liste fermée de mots italiens autorisés | `["Ciao .", "pizza"]` |
| `etapes` | array | Définition de chaque étape | Voir ci-dessous |
| `phraseFinale` | string | Phrase récapitulative complète | `"Buongiorno . Una pizza..."` |

### Structure d'une Étape

```json
{
  "objectif": "Description de l'objectif",
  "phraseCible": "Phrase en italien à dire",
  "validation": "Message de validation en français"
}
```

## ✅ Règles de Génération Automatiques

Le script génère automatiquement un `systemPrompt` qui respecte **TOUTES** les contraintes suivantes :

### 🚨 Contraintes Critiques

1. **Format audio uniquement** : STT + TTS
2. **Balises italiennes strictes** : Chaque mot italien doit être dans `[it]...[/it]` (ponctuation incluse)
3. **Vocabulaire fermé** : Seuls les mots de `vocabulaireAutorise` sont permis
4. **Progression linéaire** : 3-5 étapes fixes, ordre immuable
5. **Règle d'or** : Une validation = on avance / Jamais répéter une phrase validée
6. **Corrections minimales** : Corriger seulement si le sens est perdu
7. **Gestion chaos STT** : Ignorer l'incohérent, recentrer sur un mot simple
8. **Réponses courtes** : 3-8 mots maximum, pas d'emoji, pas d'explications longues
9. **Phrase finale obligatoire** : Récap complète + "Bravo . Tu l'as fait ."

### 📐 Structure du systemPrompt Généré

Le script génère automatiquement un `systemPrompt` structuré dans cet ordre exact :

1. Introduction (rôle, mode, objectif, priorité)
2. FORMAT CRITIQUE – NON NÉGOCIABLE
3. COMPORTEMENT AUDIO
4. RÈGLE D'OR
5. GESTION CHAOS STT
6. VOCABULAIRE AUTORISÉ (SEUL)
7. SCÉNARIO EN X ÉTAPES FIXES
8. PHRASE FINALE + BRAVO (OBLIGATOIRE)
9. FORMAT DES RÉPONSES

## 💡 Conseils

- **Vocabulaire** : Toujours inclure la ponctuation dans les phrases italiennes (`"Ciao ."` pas `"Ciao"`)
- **Étapes** : Garder 3-5 étapes pour maintenir l'attention
- **Validations** : Courts et encourageants (ex: `"Super . Continue ."`)
- **Phrase finale** : Doit utiliser UNIQUEMENT le vocabulaire autorisé
- **Difficulté** : 
  - `débutant` : 3-4 étapes, vocabulaire simple
  - `intermédiaire` : 4-5 étapes, phrases plus longues

## 🎨 Exemples de Thèmes

- 🍕 Pizzeria
- 🏨 Hôtel
- 💊 Pharmacie
- 🚂 Gare
- 🏛️ Musée
- ⛪ Église
- 🍦 Glacier
- 🏖️ Plage
- 🚕 Taxi
- 🏪 Supermarché

## 🔍 Vérification

Après génération, le script :
- ✅ Vérifie si l'ID existe déjà
- ✅ Met à jour ou ajoute le scénario
- ✅ Sauvegarde dans `scenarios.json`
- ✅ Préserve le formatage JSON

## 🛠️ Dépannage

**Le script ne trouve pas scenarios.json ?**
- Vérifiez le chemin : `frontend/src/data/scenarios.json`
- Le script doit être exécuté depuis `backend/`

**Erreur de parsing JSON ?**
- Vérifiez que tous les guillemets sont bien fermés
- Utilisez un validateur JSON en ligne

**Le vocabulaire n'est pas reconnu ?**
- Assurez-vous d'inclure la ponctuation : `"Ciao ."` pas `"Ciao"`
- Un mot par élément du tableau

## 📚 Ressources

Fichier exemple fourni : `scenario-example.json`

Pour toute question, consultez le code source : `generateScenario.js`
