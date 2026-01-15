package com.loicberthod.onykroua

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import kotlinx.coroutines.*
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.util.*

data class Scenario(
    val id: String,
    val title: String,
    val icon: String,
    val description: String,
    val difficulty: String,
    val systemPrompt: String
)

data class ScenariosData(
    val scenarios: List<Scenario>
)

data class Message(
    val role: String,
    val text: String
)

class GeminiLiveActivity : AppCompatActivity(), TextToSpeech.OnInitListener {
    
    companion object {
        private const val TAG = "GeminiLive"
    }
    
    private val REQUEST_RECORD_AUDIO_PERMISSION = 200
    private val GEMINI_API_KEY = BuildConfig.GEMINI_API_KEY
    
    private var scenarios: List<Scenario> = emptyList()
    private var selectedScenario: Scenario? = null
    private val messages = mutableListOf<Message>()
    
    private lateinit var scenarioSelectionLayout: LinearLayout
    private lateinit var conversationLayout: LinearLayout
    private lateinit var scenariosRecyclerView: RecyclerView
    private lateinit var statusText: TextView
    private lateinit var transcriptRecyclerView: RecyclerView
    private lateinit var btnConnect: Button
    private lateinit var btnMute: Button
    private lateinit var btnToggleLanguage: Button
    private lateinit var btnDisconnect: Button
    private lateinit var controlsContainer: LinearLayout
    private lateinit var activeControlsContainer: LinearLayout
    private lateinit var debugInput: EditText
    private lateinit var btnDebugSend: Button
    
    private var speechRecognizer: SpeechRecognizer? = null
    private var tts: TextToSpeech? = null
    private var isConnected = false
    private var isMuted = false
    private var isSpeaking = false
    private var recognitionLang = "fr-FR"
    private var isListening = false
    
    private val client = OkHttpClient()
    private val scope = CoroutineScope(Dispatchers.Main + Job())
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_gemini_live)
        
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = "🎤 Gemini Tutor"
        
        initViews()
        loadScenarios()
        checkPermissions()
        
        tts = TextToSpeech(this, this)
        setupTTSListener()
    }
    
    private fun setupTTSListener() {
        tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) {
                Log.d(TAG, "🗣️ Lecture segment: $utteranceId")
            }
            
            override fun onDone(utteranceId: String?) {
                val parts = utteranceId?.split("_")
                if (parts?.size == 3 && parts[0] == "utterance") {
                    val index = parts[2].toInt()
                    // Récupérer les segments stockés temporairement pour la synthèse en cours
                    // Note: on utilise Handler pour revenir sur le thread principal si nécessaire
                    Handler(Looper.getMainLooper()).postDelayed({
                        currentSegments?.let { segments ->
                            speakSegments(segments, index + 1)
                        }
                    }, 300)
                }
            }
            
            override fun onError(utteranceId: String?) {
                Log.e(TAG, "❌ Erreur TTS sur segment: $utteranceId")
                val parts = utteranceId?.split("_")
                if (parts?.size == 3 && parts[0] == "utterance") {
                    val index = parts[2].toInt()
                    Handler(Looper.getMainLooper()).postDelayed({
                        currentSegments?.let { segments ->
                            speakSegments(segments, index + 1)
                        }
                    }, 300)
                }
            }
        })
    }
    
    private var currentSegments: List<Pair<String, String>>? = null
    
    private fun initViews() {
        scenarioSelectionLayout = findViewById(R.id.scenarioSelectionLayout)
        conversationLayout = findViewById(R.id.conversationLayout)
        scenariosRecyclerView = findViewById(R.id.scenariosRecyclerView)
        statusText = findViewById(R.id.statusText)
        transcriptRecyclerView = findViewById(R.id.transcriptRecyclerView)
        btnConnect = findViewById(R.id.btnConnect)
        btnMute = findViewById(R.id.btnMute)
        btnToggleLanguage = findViewById(R.id.btnToggleLanguage)
        btnDisconnect = findViewById(R.id.btnDisconnect)
        controlsContainer = findViewById(R.id.controlsContainer)
        activeControlsContainer = findViewById(R.id.activeControlsContainer)
        debugInput = findViewById(R.id.debugInput)
        btnDebugSend = findViewById(R.id.btnDebugSend)
        
        scenariosRecyclerView.layoutManager = GridLayoutManager(this, 2)
        transcriptRecyclerView.layoutManager = LinearLayoutManager(this)
        
        btnConnect.setOnClickListener { connect() }
        btnMute.setOnClickListener { toggleMute() }
        btnToggleLanguage.setOnClickListener { toggleLanguage() }
        btnDisconnect.setOnClickListener { disconnect() }
        
        btnDebugSend.setOnClickListener { sendDebugMessage() }
        debugInput.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_SEND) {
                sendDebugMessage()
                true
            } else false
        }
        
        findViewById<Button>(R.id.btnBack).setOnClickListener { backToScenarios() }
    }
    
    private fun loadScenarios() {
        try {
            val json = assets.open("scenarios.json").bufferedReader().use { it.readText() }
            val scenariosData = Gson().fromJson(json, ScenariosData::class.java)
            scenarios = scenariosData.scenarios
            setupScenariosAdapter()
        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(this, "Erreur chargement scénarios", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun setupScenariosAdapter() {
        scenariosRecyclerView.adapter = ScenarioAdapter(scenarios) { scenario ->
            selectScenario(scenario)
        }
    }
    
    private fun selectScenario(scenario: Scenario) {
        selectedScenario = scenario
        supportActionBar?.title = "${scenario.icon} ${scenario.title}"
        scenarioSelectionLayout.visibility = View.GONE
        conversationLayout.visibility = View.VISIBLE
        messages.clear()
        updateTranscript()
    }
    
    private fun backToScenarios() {
        if (isConnected) {
            cleanup()
        }
        selectedScenario = null
        messages.clear()
        scenarioSelectionLayout.visibility = View.VISIBLE
        conversationLayout.visibility = View.GONE
        supportActionBar?.title = "🎤 Gemini Tutor"
    }
    
    private fun checkPermissions() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                REQUEST_RECORD_AUDIO_PERMISSION
            )
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_RECORD_AUDIO_PERMISSION) {
            if (grantResults.isEmpty() || grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "Permission micro requise", Toast.LENGTH_SHORT).show()
            }
        }
    }
    
    private fun connect() {
        Log.d(TAG, "🟢 Tentative de connexion...")
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            Toast.makeText(this, "Reconnaissance vocale non disponible", Toast.LENGTH_SHORT).show()
            Log.e(TAG, "❌ Reconnaissance vocale non disponible")
            return
        }
        
        if (GEMINI_API_KEY == "YOUR_GEMINI_API_KEY_HERE" || GEMINI_API_KEY.isEmpty()) {
            Toast.makeText(this, "Configurer GEMINI_API_KEY", Toast.LENGTH_LONG).show()
            Log.e(TAG, "❌ GEMINI_API_KEY manquante")
            return
        }
        
        Log.d(TAG, "✅ API Key présente: ${GEMINI_API_KEY.take(10)}...")
        
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                Log.d(TAG, "👂 Prêt à écouter")
                isListening = true
            }
            override fun onBeginningOfSpeech() {
                Log.d(TAG, "🎤 Début de parole")
            }
            override fun onRmsChanged(rmsdB: Float) {
                // Volume micro trop bruyant sinon
            }
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {
                Log.d(TAG, "🔇 Fin de parole")
                isListening = false
            }
            
            override fun onError(error: Int) {
                isListening = false
                val message = when (error) {
                    SpeechRecognizer.ERROR_AUDIO -> "Erreur audio"
                    SpeechRecognizer.ERROR_CLIENT -> "Erreur client"
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Permissions insuffisantes"
                    SpeechRecognizer.ERROR_NETWORK -> "Erreur réseau"
                    SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "Timeout réseau"
                    SpeechRecognizer.ERROR_NO_MATCH -> "Aucun résultat (parlez plus fort ou plus clairement)"
                    SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "Service occupé"
                    SpeechRecognizer.ERROR_SERVER -> "Erreur serveur"
                    SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "Aucune parole détectée"
                    else -> "Erreur inconnue ($error)"
                }
                Log.d(TAG, "⚠️ Erreur reconnaissance: $message ($error)")
                
                runOnUiThread {
                    // Pour ERROR_NO_MATCH et SPEECH_TIMEOUT, continuer d'écouter sans afficher d'erreur
                    if (error == SpeechRecognizer.ERROR_NO_MATCH || error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT) {
                        statusText.text = "👂 J'écoute... (rien détecté, réessayez)"
                    } else if (error == SpeechRecognizer.ERROR_NETWORK || error == SpeechRecognizer.ERROR_SERVER) {
                        statusText.text = "⚠️ Problème réseau - vérifiez votre connexion"
                    } else {
                        statusText.text = "⚠️ $message"
                    }
                }

                if (isConnected && !isMuted && !isSpeaking) {
                    // Délai adapté selon le type d'erreur
                    val delay = when (error) {
                        SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> 1000L
                        SpeechRecognizer.ERROR_NO_MATCH -> 300L  // Redémarrer rapidement si pas de match
                        SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> 300L
                        else -> 500L
                    }
                    Handler(Looper.getMainLooper()).postDelayed({
                        startListening()
                    }, delay)
                }
            }
            
            override fun onResults(results: Bundle?) {
                isListening = false
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (!matches.isNullOrEmpty()) {
                    val transcript = matches[0]
                    Log.d(TAG, "👤 Utilisateur dit: $transcript")
                    handleUserSpeech(transcript)
                }
            }
            
            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (!matches.isNullOrEmpty()) {
                    val partial = matches[0]
                    runOnUiThread {
                        statusText.text = "👂 $partial..."
                    }
                }
            }
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })
        
        isConnected = true
        updateUIForConnection()
        startListening()
    }
    
    private fun startListening() {
        if (!isConnected || isMuted || isSpeaking || isListening) {
            Log.d(TAG, "⏸️ Écoute bloquée - connected:$isConnected muted:$isMuted speaking:$isSpeaking listening:$isListening")
            return
        }
        
        runOnUiThread {
            if (statusText.text.contains("Erreur") || statusText.text.contains("Aucun") || statusText.text.contains("Connecté")) {
                statusText.text = "👂 J'écoute..."
            }
        }
        
        Log.d(TAG, "🎤 Démarrage écoute ($recognitionLang)...")
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, recognitionLang)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
            
            // Paramètres pour améliorer la reconnaissance
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, false)
            putExtra("android.speech.extra.DICTATION_MODE", true)
            
            // Temps de silence plus courts pour éviter les timeouts
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 1500L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 1500L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 3000L)
        }
        
        try {
            speechRecognizer?.cancel() // Nettoyage avant démarrage
            speechRecognizer?.startListening(intent)
            Log.d(TAG, "✅ Reconnaissance démarrée")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Erreur démarrage reconnaissance", e)
            isListening = false
        }
    }
    
    private fun handleUserSpeech(transcript: String) {
        Log.d(TAG, "📝 Traitement parole utilisateur: $transcript")
        
        runOnUiThread {
            statusText.text = "🧠 Réflexion..."
        }
        
        messages.add(Message("user", transcript))
        updateTranscript()
        
        speechRecognizer?.stopListening()
        Log.d(TAG, "⏸️ Micro arrêté pour traitement")
        
        scope.launch {
            try {
                Log.d(TAG, "🌐 Envoi à Gemini...")
                val response = sendToGemini(transcript)
                Log.d(TAG, "🤖 Réponse Gemini: $response")
                val fixedResponse = fixPunctuationInItTags(response)
                Log.d(TAG, "✏️ Après correction ponctuation: $fixedResponse")
                
                messages.add(Message("assistant", fixedResponse))
                updateTranscript()
                
                speakBilingualText(fixedResponse)
            } catch (e: Exception) {
                Log.e(TAG, "❌ Erreur Gemini", e)
                e.printStackTrace()
                Toast.makeText(
                    this@GeminiLiveActivity,
                    "Erreur Gemini: ${e.message}",
                    Toast.LENGTH_SHORT
                ).show()
                startListening()
            }
        }
    }
    
    private suspend fun sendToGemini(userText: String): String = withContext(Dispatchers.IO) {
        val model = "gemini-2.5-flash-lite"
        val url = "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$GEMINI_API_KEY"
        Log.d(TAG, "📡 URL Gemini: ${url.substringBefore("?key=")}")
        
        val contents = JSONArray()
        messages.forEach { msg ->
            contents.put(JSONObject().apply {
                put("role", if (msg.role == "user") "user" else "model")
                put("parts", JSONArray().apply {
                    put(JSONObject().put("text", msg.text))
                })
            })
        }
        
        val requestBody = JSONObject().apply {
            put("system_instruction", JSONObject().apply {
                put("parts", JSONArray().apply {
                    put(JSONObject().put("text", selectedScenario?.systemPrompt ?: ""))
                })
            })
            put("contents", contents)
            
            // Ajout de la configuration de génération (match Vue.js)
            put("generationConfig", JSONObject().apply {
                put("temperature", 0.7)
                put("topK", 40)
                put("topP", 0.95)
                put("maxOutputTokens", 1024)
            })
            
            // Ajout des filtres de sécurité (match Vue.js)
            put("safetySettings", JSONArray().apply {
                put(JSONObject().apply {
                    put("category", "HARM_CATEGORY_HARASSMENT")
                    put("threshold", "BLOCK_MEDIUM_AND_ABOVE")
                })
                put(JSONObject().apply {
                    put("category", "HARM_CATEGORY_HATE_SPEECH")
                    put("threshold", "BLOCK_MEDIUM_AND_ABOVE")
                })
                put(JSONObject().apply {
                    put("category", "HARM_CATEGORY_SEXUALLY_EXPLICIT")
                    put("threshold", "BLOCK_MEDIUM_AND_ABOVE")
                })
                put(JSONObject().apply {
                    put("category", "HARM_CATEGORY_DANGEROUS_CONTENT")
                    put("threshold", "BLOCK_MEDIUM_AND_ABOVE")
                })
            })
        }
        
        val request = Request.Builder()
            .url(url)
            .post(requestBody.toString().toRequestBody("application/json".toMediaType()))
            .build()
        
        Log.d(TAG, "📤 Requête envoyée, attente réponse...")
        val response = client.newCall(request).execute()
        val responseBody = response.body?.string() ?: throw IOException("Empty response")
        
        Log.d(TAG, "📥 Réponse HTTP ${response.code}")
        if (!response.isSuccessful) {
            Log.e(TAG, "❌ HTTP ${response.code}: $responseBody")
            throw IOException("HTTP ${response.code}: $responseBody")
        }
        
        Log.d(TAG, "📦 Réponse brute (premiers 200 chars): ${responseBody.take(200)}")
        
        val json = JSONObject(responseBody)
        json.getJSONArray("candidates")
            .getJSONObject(0)
            .getJSONObject("content")
            .getJSONArray("parts")
            .getJSONObject(0)
            .getString("text")
    }
    
    private fun speakBilingualText(text: String) {
        if (tts == null) {
            Log.e(TAG, "❌ TTS non initialisé")
            return
        }
        
        // Forcer l'arrêt de toute lecture en cours (comme Vue avec speechSynthesis.cancel())
        tts?.stop()
        
        runOnUiThread {
            statusText.text = "🗣️ Gemini parle..."
        }
        
        Log.d(TAG, "🗣️ Début synthèse vocale: $text")
        isSpeaking = true
        speechRecognizer?.stopListening()
        isListening = false
        
        // Petit délai pour s'assurer que stop() est terminé (comme dans Vue : 100ms)
        Handler(Looper.getMainLooper()).postDelayed({
            currentSegments = splitByItTags(text)
            speakSegments(currentSegments!!, 0)
        }, 100)
    }
    
    private fun splitByItTags(text: String): List<Pair<String, String>> {
        Log.d(TAG, "✂️ Découpage texte en segments...")
        val segments = mutableListOf<Pair<String, String>>()
        val regex = """\[it\]([\s\S]*?)\[/it\]""".toRegex()
        
        var lastIndex = 0
        regex.findAll(text).forEach { match ->
            val before = text.substring(lastIndex, match.range.first).trim()
            if (before.isNotEmpty()) {
                segments.add(Pair("fr-FR", before))
            }
            
            val itText = match.groupValues[1].trim()
            if (itText.isNotEmpty()) {
                segments.add(Pair("it-IT", itText))
            }
            
            lastIndex = match.range.last + 1
        }
        
        val after = text.substring(lastIndex).trim()
        if (after.isNotEmpty()) {
            segments.add(Pair("fr-FR", after))
        }
        
        Log.d(TAG, "📊 Total segments: ${segments.size} | FR: ${segments.count { it.first == "fr-FR" }} | IT: ${segments.count { it.first == "it-IT" }}")
        segments.forEachIndexed { i, (lang, txt) -> 
            Log.d(TAG, "  [$i] $lang: ${txt.take(50)}${if(txt.length > 50) "..." else ""}")
        }
        return segments
    }
    
    private fun speakSegments(segments: List<Pair<String, String>>, index: Int) {
        if (index >= segments.size) {
            Log.d(TAG, "✅ Synthèse vocale terminée")
            isSpeaking = false
            currentSegments = null
            if (isConnected && !isMuted) {
                Log.d(TAG, "⏳ Attente 2s avant redémarrage micro (éviter capture audio résiduel)")
                Handler(Looper.getMainLooper()).postDelayed({
                    Log.d(TAG, "▶️ Redémarrage reconnaissance après synthèse")
                    startListening()
                }, 2000)
            }
            return
        }
        
        val (lang, text) = segments[index]
        val locale = if (lang == "it-IT") Locale.ITALIAN else Locale.FRENCH
        
        Log.d(TAG, "🎯 Segment ${index + 1}/${segments.size} ($lang): $text")
        
        tts?.language = locale
        tts?.setSpeechRate(0.85f)
        
        val utteranceId = "utterance_segment_$index"
        // CRITIQUE: Utiliser QUEUE_FLUSH uniquement pour le premier segment
        // puis QUEUE_ADD pour les suivants afin de les jouer en séquence
        val queueMode = if (index == 0) TextToSpeech.QUEUE_FLUSH else TextToSpeech.QUEUE_ADD
        Log.d(TAG, "🎤 Mode queue: ${if (queueMode == TextToSpeech.QUEUE_FLUSH) "FLUSH" else "ADD"}")
        tts?.speak(text, queueMode, null, utteranceId)
    }
    
    private fun toggleMute() {
        isMuted = !isMuted
        btnMute.text = if (isMuted) "🔇 Micro coupé" else "🎤 Micro actif"
        
        if (isMuted) {
            speechRecognizer?.stopListening()
        } else {
            startListening()
        }
    }
    
    private fun toggleLanguage() {
        recognitionLang = if (recognitionLang == "fr-FR") "it-IT" else "fr-FR"
        btnToggleLanguage.text = if (recognitionLang == "fr-FR") "🇫🇷 FR" else "🇮🇹 IT"
        
        if (isConnected) {
            speechRecognizer?.stopListening()
            Handler(Looper.getMainLooper()).postDelayed({
                startListening()
            }, 100)
        }
    }
    
    private fun sendDebugMessage() {
        val text = debugInput.text.toString().trim()
        if (text.isNotEmpty()) {
            Log.d(TAG, "🛠️ Envoi message de debug: $text")
            debugInput.setText("")
            handleUserSpeech(text)
        }
    }

    private fun disconnect() {
        cleanup()
    }
    
    private fun cleanup() {
        speechRecognizer?.stopListening()
        speechRecognizer?.destroy()
        speechRecognizer = null
        
        tts?.stop()
        
        isConnected = false
        isMuted = false
        isSpeaking = false
        
        updateUIForConnection()
    }
    
    private fun updateUIForConnection() {
        runOnUiThread {
            if (isConnected) {
                statusText.text = "🟢 Connecté"
                controlsContainer.visibility = View.GONE
                activeControlsContainer.visibility = View.VISIBLE
                
                // Si on vient de se connecter, lancer un petit toast pour confirmer
                Toast.makeText(this, "Conversation démarrée. Parlez maintenant !", Toast.LENGTH_SHORT).show()
            } else {
                statusText.text = "⚪ Déconnecté"
                controlsContainer.visibility = View.VISIBLE
                activeControlsContainer.visibility = View.GONE
            }
        }
    }
    
    private fun updateTranscript() {
        runOnUiThread {
            transcriptRecyclerView.adapter = TranscriptAdapter(messages)
            transcriptRecyclerView.scrollToPosition(messages.size - 1)
        }
    }
    
    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            tts?.language = Locale.FRENCH
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        cleanup()
        tts?.shutdown()
        scope.cancel()
    }
    
    override fun onSupportNavigateUp(): Boolean {
        onBackPressed()
        return true
    }
    
    private fun fixPunctuationInItTags(text: String): String {
        // Déplacer la ponctuation qui suit [/it] à l'intérieur des balises
        // "[it]Ciao[/it]!" devient "[it]Ciao![/it]"
        return text.replace("""\[/it\]\s*([.,!?;:]+)""".toRegex(), "$1[/it]")
    }

    inner class ScenarioAdapter(
        private val scenarios: List<Scenario>,
        private val onScenarioClick: (Scenario) -> Unit
    ) : RecyclerView.Adapter<ScenarioAdapter.ViewHolder>() {
        
        inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            val icon: TextView = view.findViewById(R.id.scenarioIcon)
            val title: TextView = view.findViewById(R.id.scenarioTitle)
            val description: TextView = view.findViewById(R.id.scenarioDescription)
            val difficulty: TextView = view.findViewById(R.id.scenarioDifficulty)
        }
        
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.item_scenario, parent, false)
            return ViewHolder(view)
        }
        
        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            val scenario = scenarios[position]
            holder.icon.text = scenario.icon
            holder.title.text = scenario.title
            holder.description.text = scenario.description
            holder.difficulty.text = scenario.difficulty
            holder.itemView.setOnClickListener { onScenarioClick(scenario) }
        }
        
        override fun getItemCount() = scenarios.size
    }
    
    inner class TranscriptAdapter(
        private val messages: List<Message>
    ) : RecyclerView.Adapter<TranscriptAdapter.ViewHolder>() {
        
        inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            val role: TextView = view.findViewById(R.id.messageRole)
            val text: TextView = view.findViewById(R.id.messageText)
        }
        
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.item_message, parent, false)
            return ViewHolder(view)
        }
        
        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            val message = messages[position]
            holder.role.text = if (message.role == "user") "👤 Vous" else "🤖 Gemini"
            holder.text.text = formatMessageText(message.text)
        }
        
        private fun formatMessageText(text: String): String {
            return fixPunctuationInItTags(text.replace("""\[it\]([\s\S]*?)\[/it\]""".toRegex(), "$1"))
        }
        
        override fun getItemCount() = messages.size
    }
}
