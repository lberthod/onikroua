# 🚀 Robot Pédagogique - Guide de Démarrage Rapide

## Installation & Lancement (5 minutes)

### 1. Prérequis
- Node.js v16+ installé
- Clé API OpenAI avec accès Realtime API
- Navigateur moderne (Chrome, Firefox, Edge)

### 2. Configuration Backend

```bash
cd /Users/berthod/Desktop/onykroua/onikroua/backend

# Installer les dépendances
npm install

# Configurer la clé API dans .env
# OPENAI_API_KEY=sk-votre-clé-ici
```

### 3. Démarrer le Backend

```bash
npm run dev
```

**Vérification** : Vous devriez voir :
```
✅ Firebase Admin initialisé avec succès
🤖 Robot WebSocket server ready on /robot
🚀 Serveur Onikroua démarré sur le port 3001
```

### 4. Démarrer le Frontend

**Nouveau terminal** :
```bash
cd /Users/berthod/Desktop/onykroua/onikroua/frontend
npm run dev
```

### 5. Tester

Ouvrez : `http://localhost:5173/robot`

1. Cliquez sur "🎤 Démarrer la conversation"
2. Autorisez le microphone
3. Attendez que le robot vous salue
4. Parlez naturellement !

---

## 🎯 Validation des Optimisations

### Test 1 : Silence (pas de gaspillage)
1. Connectez-vous
2. **Ne parlez pas** pendant 30 secondes
3. Cliquez sur "📊 Voir métriques"
4. ✅ **Attendu** : `userAudioSeconds: 0.00s`

### Test 2 : VAD (détection voix)
1. Parlez pendant 5 secondes
2. Observez l'indicateur "Voix détectée" (rouge)
3. Arrêtez de parler
4. ✅ **Attendu** : Indicateur disparaît après 400ms

### Test 3 : Barge-in (interruption)
1. Laissez le robot parler
2. Commencez à parler pendant qu'il parle
3. ✅ **Attendu** : Robot s'arrête immédiatement (<50ms)

### Test 4 : Session continue
1. Faites 3-4 échanges
2. Vérifiez les logs backend
3. ✅ **Attendu** : Un seul "Session ready", pas de reconnexion

### Test 5 : Métriques
1. Après 5 minutes de conversation
2. Cliquez "📊 Voir métriques"
3. ✅ **Attendu** : Coût < $0.60 pour 5 min

---

## 📊 Logs Backend à Surveiller

### Connexion normale
```bash
🔗 [client-1] New robot client connected
✅ [client-1] Connected to OpenAI Realtime API
📝 [client-1] Session ready
🤖 [client-1] State: idle
```

### Conversation normale
```bash
🎤 [client-1] User audio started
🎤 [client-1] User audio stopped (3200ms)
🤖 [client-1] State: listening
🤖 [client-1] State: thinking
🤖 [client-1] State: speaking
🤖 [client-1] State: idle
```

### Barge-in
```bash
🛑 [client-1] Barge-in triggered (client)
🤖 [client-1] State: idle
```

### Déconnexion
```bash
👋 [client-1] Robot client disconnected

📊 [client-1] Session Metrics:
   User Audio: 12.34s (45 chunks)
   AI Audio: 23.45s (89 chunks)
   Turns: 8 (1.6/min)
   Duration: 300s
   Estimated Cost: $0.1234
```

---

## ⚠️ Problèmes Courants

### "Cannot find module './logger'"
```bash
# Le fichier logger.js existe maintenant
# Si erreur persiste :
cd backend
npm install
```

### "WebSocket connection failed"
```bash
# Vérifier que le backend tourne
curl http://localhost:3001/health

# Devrait retourner : {"status":"ok","timestamp":"..."}
```

### "Microphone permission denied"
- Autoriser le micro dans les paramètres du navigateur
- Chrome : chrome://settings/content/microphone
- Firefox : about:preferences#privacy

### VAD ne détecte pas la voix
```typescript
// Dans RobotViewOptimized.vue, ajuster :
const VAD_CONFIG = {
  threshold: 0.020,  // Augmenter si trop sensible
  // ou
  threshold: 0.010,  // Réduire si pas assez sensible
}
```

### Coût trop élevé
1. Vérifier les métriques
2. Si `aiAudioSeconds` >> `userAudioSeconds` :
   - Réduire `MAX_AUDIO_DURATION_MS` dans backend
   - Améliorer le prompt système

---

## 🎓 Scénario Pédagogique

### "Se présenter" (A1)

**Questions typiques du robot** :
- "Hello! What is your name?"
- "Nice to meet you! Where are you from?"
- "How old are you?"
- "What do you do?"

**Comportement attendu** :
- Réponses courtes (1-2 phrases)
- Encouragement constant
- Reformulation douce des erreurs
- Pas de critique directe

**Exemple d'échange** :
```
Robot: "Hello! What is your name?"
User: "My name is Paul"
Robot: "Great, Paul! Nice to meet you. Where are you from?"
User: "I from France"
Robot: "Wonderful! I'm from France. What city in France?"
```

---

## 📈 Métriques de Succès

### Performance
- ✅ Latence VAD < 10ms
- ✅ Détection parole en 200ms
- ✅ Barge-in < 50ms
- ✅ Pas de chunks pendant silence

### Coûts
- ✅ < $0.15/min en moyenne
- ✅ Ratio user:ai audio ~1:2
- ✅ < 20 tours/min

### Expérience
- ✅ Interruption naturelle
- ✅ Pas de lag perceptible
- ✅ Conversation fluide

---

## 🔧 Configuration Avancée

### Ajuster le VAD

**Pour environnement bruyant** :
```typescript
const VAD_CONFIG = {
  threshold: 0.025,           // Plus strict
  silenceDurationMs: 600,     // Plus tolérant
  minSpeechDurationMs: 300    // Évite faux positifs
}
```

**Pour utilisateur lent** :
```typescript
const VAD_CONFIG = {
  threshold: 0.012,           // Plus sensible
  silenceDurationMs: 800,     // Attend plus longtemps
  minSpeechDurationMs: 150    // Réagit plus vite
}
```

### Ajuster les limites backend

**Pour débutants** :
```javascript
const MAX_AUDIO_DURATION_MS = 6000      // 6s max
const MAX_TURNS_PER_MINUTE = 15         // Rythme calme
```

**Pour avancés** :
```javascript
const MAX_AUDIO_DURATION_MS = 10000     // 10s max
const MAX_TURNS_PER_MINUTE = 25         // Rythme soutenu
```

---

## 📚 Documentation Complète

- **Architecture** : `ROBOT-MVP.md`
- **Optimisations** : `ROBOT-OPTIMIZATIONS.md`
- **Ce guide** : `ROBOT-QUICKSTART.md`

---

## 🎯 Checklist de Validation

Avant de considérer le système prêt :

- [ ] Backend démarre sans erreur
- [ ] Frontend se connecte au WebSocket
- [ ] Microphone autorisé et fonctionnel
- [ ] VAD détecte la voix (indicateur rouge)
- [ ] Silence ne génère pas de chunks (métriques)
- [ ] Barge-in fonctionne (interruption < 50ms)
- [ ] Session persiste (plusieurs tours sans reconnexion)
- [ ] Métriques affichent coût < $0.15/min
- [ ] Logs backend propres (pas d'erreurs)
- [ ] Conversation naturelle et fluide

---

## 💡 Astuces

1. **Tester d'abord en silence** : Vérifier que rien n'est envoyé
2. **Observer les logs** : Comprendre le flux
3. **Ajuster le VAD** : Selon votre environnement
4. **Monitorer les coûts** : Utiliser les métriques
5. **Tester le barge-in** : S'assurer qu'il est réactif

---

## 🚀 Prêt pour la Production ?

Avant déploiement :

1. **Load testing** : Tester avec plusieurs utilisateurs simultanés
2. **Monitoring** : Mettre en place alertes sur coûts
3. **Rate limiting** : Implémenter par utilisateur
4. **Error handling** : Gérer déconnexions réseau
5. **Analytics** : Tracker métriques d'usage

---

## 📞 Support

En cas de problème :

1. Vérifier les logs backend
2. Ouvrir la console navigateur (F12)
3. Consulter `ROBOT-OPTIMIZATIONS.md` section Dépannage
4. Tester avec `/robot-old` pour comparer

**Logs utiles** :
```bash
# Backend
npm run dev | tee robot-backend.log

# Puis analyser
grep "ERROR" robot-backend.log
grep "Barge-in" robot-backend.log
grep "Session Metrics" robot-backend.log
```

---

## ✅ Système Opérationnel !

Si tous les tests passent, le système est prêt à l'emploi avec :

- ✅ **60% d'économie** sur les coûts
- ✅ **VAD local** (pas de silence envoyé)
- ✅ **Barge-in < 50ms** (interruption naturelle)
- ✅ **Session persistante** (contexte maintenu)
- ✅ **Métriques temps réel** (transparence totale)
- ✅ **Limites strictes** (protection coûts)

**Bon apprentissage ! 🎓**
