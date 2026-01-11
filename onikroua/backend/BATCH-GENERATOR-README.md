# 🚀 Générateur Batch de Scénarios

Génère automatiquement 10 (ou plus) scénarios en une seule commande à partir d'une liste de thèmes.

## 📋 Prérequis

- Node.js installé
- `OPENAI_API_KEY` configuré dans `.env`
- Fichier `themes.json` avec la liste des thèmes

## 🎯 Utilisation Rapide

### 1. Créer un fichier de thèmes

Crée un fichier JSON avec un tableau de thèmes :

```json
[
  "à l'hôtel",
  "à la gare",
  "au musée",
  "louer une voiture",
  "chez le coiffeur",
  "au marché",
  "réserver une table au restaurant",
  "à la poste",
  "demander son chemin dans la rue",
  "à la plage"
]
```

### 2. Lancer la génération

```bash
node generateBatchScenarios.js themes-example.json
```

## ✨ Ce que fait le script

Pour chaque thème dans le fichier :
1. 🤖 Appelle OpenAI pour générer le scénario complet
2. 📝 Génère automatiquement :
   - L'ID, titre, description, icône
   - Le vocabulaire italien approprié
   - Les 3-5 étapes pédagogiques
   - La phrase finale récapitulative
3. 🔧 Crée le `systemPrompt` complet selon toutes les règles
4. 💾 Ajoute automatiquement au fichier `scenarios.json`
5. ⏱️ Attend 1 seconde entre chaque génération (rate limiting)

## 📊 Sortie Console

Le script affiche :
- ✅ Progression pour chaque thème
- 📊 Statistiques de réussite/échec
- 💾 Confirmation de sauvegarde
- 📝 Nombre total de scénarios

## 🎨 Exemples de Thèmes

### Niveau Débutant
- `"commander une glace"`
- `"acheter des tickets de bus"`
- `"saluer des amis"`
- `"commander un café"`

### Niveau Intermédiaire
- `"réserver un billet de train"`
- `"expliquer un problème de santé"`
- `"négocier un prix au marché"`
- `"demander des recommandations touristiques"`

## ⚙️ Configuration

Le script utilise automatiquement :
- **Modèle IA** : `gpt-5-nano-2025-08-07`
- **Tokens max** : 8000 par génération
- **Délai** : 1 seconde entre chaque génération

## 🔍 Gestion des Erreurs

- Si un thème échoue, le script continue avec les suivants
- Les scénarios existants sont mis à jour (basé sur l'ID)
- Les statistiques finales montrent le nombre de succès/échecs

## 💡 Conseils

1. **Thèmes clairs** : Sois précis (ex: "à l'hôtel" plutôt que "hôtel")
2. **Variété** : Mélange débutant et intermédiaire
3. **Vérification** : Vérifie les scénarios générés dans `scenarios.json`
4. **Backup** : Fais une copie de `scenarios.json` avant de lancer

## 📝 Format du Fichier de Thèmes

```json
[
  "thème 1",
  "thème 2",
  "thème 3"
]
```

**Règles :**
- Tableau JSON simple
- Un thème par ligne
- En français
- Court et descriptif

## 🎯 Résultat

Tous les scénarios sont automatiquement ajoutés à :
```
frontend/src/data/scenarios.json
```

Chaque scénario respecte automatiquement :
- ✅ Format audio (STT + TTS)
- ✅ Balises `[it]...[/it]` strictes
- ✅ Vocabulaire fermé
- ✅ Progression 3-5 étapes
- ✅ Phrase finale + "Bravo . Tu l'as fait ."

## 🚨 Dépannage

**Erreur "OPENAI_API_KEY manquant"**
- Vérifie que tu as bien `OPENAI_API_KEY=sk-...` dans `.env`

**Erreur "Fichier introuvable"**
- Utilise le chemin complet ou vérifie que le fichier existe

**Trop d'échecs**
- Vérifie ta connexion internet
- Vérifie les crédits OpenAI
- Essaie avec moins de thèmes

## 📚 Fichiers Créés

- `generateBatchScenarios.js` - Script principal
- `themes-example.json` - Fichier exemple avec 10 thèmes
- `BATCH-GENERATOR-README.md` - Ce fichier

## 🎉 Exemple Complet

```bash
# 1. Créer ton fichier de thèmes
cat > mes-themes.json << EOF
[
  "à l'aéroport",
  "louer un vélo",
  "commander un dessert"
]
EOF

# 2. Générer les scénarios
node generateBatchScenarios.js mes-themes.json

# 3. Vérifier le résultat
cat ../frontend/src/data/scenarios.json
```

## 🔗 Voir Aussi

- `generateScenario.js` - Générateur manuel (un seul scénario)
- `SCENARIO-GENERATOR-README.md` - Guide du générateur manuel
