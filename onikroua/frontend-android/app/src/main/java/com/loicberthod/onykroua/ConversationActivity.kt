package com.loicberthod.onykroua

import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.loicberthod.onykroua.conversation.Conversation
import com.loicberthod.onykroua.conversation.ConversationData
import com.loicberthod.onykroua.conversation.Message
import com.loicberthod.onykroua.utils.LanguagePreference
import java.util.Locale

class ConversationActivity : AppCompatActivity(), TextToSpeech.OnInitListener {
    
    private var tts: TextToSpeech? = null
    private var isTtsReady = false
    private var expandedConversation: Int? = null
    private var selectedDifficulty: String = "all"
    
    private lateinit var difficultyContainer: LinearLayout
    private lateinit var conversationsContainer: LinearLayout
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_conversation)
        
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = "💬 Conversations"
        
        difficultyContainer = findViewById(R.id.difficultyContainer)
        conversationsContainer = findViewById(R.id.conversationsContainer)
        
        tts = TextToSpeech(this, this)
        
        displayDifficultyFilters()
        displayConversations()
    }
    
    private fun displayDifficultyFilters() {
        difficultyContainer.removeAllViews()
        
        val difficulties = listOf(
            "all" to "Tous",
            "débutant" to "🟢 Débutant",
            "intermédiaire" to "🟡 Intermédiaire",
            "avancé" to "🔴 Avancé"
        )
        
        difficulties.forEach { (id, label) ->
            val button = createDifficultyButton(id, label)
            difficultyContainer.addView(button)
        }
    }
    
    private fun createDifficultyButton(id: String, label: String): TextView {
        val isSelected = selectedDifficulty == id
        val color = when (id) {
            "débutant" -> "#27AE60"
            "intermédiaire" -> "#F39C12"
            "avancé" -> "#E74C3C"
            else -> "#667EEA"
        }
        
        return TextView(this).apply {
            text = label
            textSize = 13f
            setPadding(20, 12, 20, 12)
            setBackgroundColor(if (isSelected) {
                android.graphics.Color.parseColor(color)
            } else {
                android.graphics.Color.parseColor("#F5F5F5")
            })
            setTextColor(if (isSelected) {
                android.graphics.Color.WHITE
            } else {
                android.graphics.Color.parseColor("#666666")
            })
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(4, 4, 4, 4)
            layoutParams = params
            isClickable = true
            setOnClickListener {
                selectedDifficulty = id
                displayDifficultyFilters()
                displayConversations()
            }
        }
    }
    
    private fun displayConversations() {
        conversationsContainer.removeAllViews()
        
        val language = LanguagePreference.getLanguage(this)
        var conversations = ConversationData.getConversations(language)
        
        if (selectedDifficulty != "all") {
            conversations = conversations.filter { it.difficulty == selectedDifficulty }
        }
        
        if (conversations.isEmpty()) {
            conversationsContainer.addView(TextView(this).apply {
                text = "Aucune conversation pour ce niveau"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#999999"))
                gravity = android.view.Gravity.CENTER
                setPadding(32, 64, 32, 64)
            })
            return
        }
        
        conversations.forEachIndexed { index, conversation ->
            conversationsContainer.addView(createConversationCard(conversation, index))
        }
    }
    
    private fun createConversationCard(conversation: Conversation, index: Int): LinearLayout {
        val isExpanded = expandedConversation == index
        
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(android.graphics.Color.WHITE)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 12)
            layoutParams = params
        }
        
        // Header
        val header = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(20, 20, 20, 20)
            isClickable = true
            setOnClickListener {
                expandedConversation = if (isExpanded) null else index
                displayConversations()
            }
        }
        
        header.addView(TextView(this).apply {
            text = conversation.icon
            textSize = 32f
            val params = LinearLayout.LayoutParams(80, LinearLayout.LayoutParams.WRAP_CONTENT)
            layoutParams = params
        })
        
        val infoContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        }
        
        infoContainer.addView(TextView(this).apply {
            text = conversation.title
            textSize = 18f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
        })
        
        infoContainer.addView(TextView(this).apply {
            text = conversation.scenario
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#999999"))
            setPadding(0, 4, 0, 0)
        })
        
        header.addView(infoContainer)
        
        header.addView(TextView(this).apply {
            text = conversation.difficulty
            textSize = 12f
            setTextColor(android.graphics.Color.WHITE)
            setPadding(16, 8, 16, 8)
            setBackgroundColor(getDifficultyColor(conversation.difficulty))
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(8, 0, 8, 0)
            layoutParams = params
        })
        
        header.addView(TextView(this).apply {
            text = if (isExpanded) "▼" else "▶"
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#666666"))
        })
        
        card.addView(header)
        
        // Expanded content
        if (isExpanded) {
            card.addView(createExpandedContent(conversation, index))
        }
        
        return card
    }
    
    private fun createExpandedContent(conversation: Conversation, index: Int): LinearLayout {
        val content = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(20, 0, 20, 20)
        }
        
        // Play all button
        content.addView(TextView(this).apply {
            text = "🔊 Écouter toute la conversation"
            textSize = 14f
            setPadding(16, 12, 16, 12)
            setBackgroundColor(android.graphics.Color.parseColor("#667EEA"))
            setTextColor(android.graphics.Color.WHITE)
            isClickable = true
            setOnClickListener {
                speakConversation(conversation.messages)
            }
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 16)
            layoutParams = params
        })
        
        // Messages
        conversation.messages.forEachIndexed { msgIndex, message ->
            content.addView(createMessageBubble(message, msgIndex))
        }
        
        // Vocabulary
        content.addView(TextView(this).apply {
            text = "📚 Vocabulaire clé"
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 24, 0, 12)
        })
        
        conversation.vocabulary.forEach { vocab ->
            content.addView(LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(16, 12, 16, 12)
                setBackgroundColor(android.graphics.Color.parseColor("#F8F9FA"))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 8)
                layoutParams = params
                isClickable = true
                setOnClickListener {
                    speak(vocab.word)
                }
                
                addView(TextView(this@ConversationActivity).apply {
                    text = vocab.word
                    textSize = 14f
                    setTextColor(android.graphics.Color.parseColor("#4F46E5"))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(
                        0,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                        1f
                    )
                })
                
                addView(TextView(this@ConversationActivity).apply {
                    text = vocab.translation
                    textSize = 14f
                    setTextColor(android.graphics.Color.parseColor("#666666"))
                })
                
                addView(TextView(this@ConversationActivity).apply {
                    text = "🔊"
                    textSize = 14f
                    setPadding(8, 0, 0, 0)
                })
            })
        }
        
        // Tips
        content.addView(TextView(this).apply {
            text = "💡 Conseils"
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 24, 0, 12)
        })
        
        conversation.tips.forEach { tip ->
            content.addView(TextView(this).apply {
                text = "• $tip"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#666666"))
                setPadding(0, 4, 0, 4)
            })
        }
        
        return content
    }
    
    private fun createMessageBubble(message: Message, index: Int): LinearLayout {
        val bubble = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 8, 0, 8)
            layoutParams = params
        }
        
        val isA = message.speaker == "A"
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = if (isA) android.view.Gravity.START else android.view.Gravity.END
        }
        
        val messageContent = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(16, 12, 16, 12)
            setBackgroundColor(if (isA) {
                android.graphics.Color.parseColor("#E3F2FD")
            } else {
                android.graphics.Color.parseColor("#F3E5F5")
            })
            val params = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                0.8f
            )
            layoutParams = params
        }
        
        messageContent.addView(TextView(this).apply {
            text = message.text
            textSize = 15f
            setTextColor(android.graphics.Color.parseColor("#333333"))
        })
        
        messageContent.addView(TextView(this).apply {
            text = message.translation
            textSize = 13f
            setTextColor(android.graphics.Color.parseColor("#666666"))
            setPadding(0, 6, 0, 0)
            setTypeface(null, android.graphics.Typeface.ITALIC)
        })
        
        messageContent.addView(TextView(this).apply {
            text = "🔊"
            textSize = 12f
            setPadding(0, 8, 0, 0)
            isClickable = true
            setOnClickListener {
                speak(message.text)
            }
        })
        
        container.addView(messageContent)
        bubble.addView(container)
        
        bubble.addView(TextView(this).apply {
            text = if (isA) "👤 A" else "👥 B"
            textSize = 11f
            setTextColor(android.graphics.Color.parseColor("#999999"))
            gravity = if (isA) android.view.Gravity.START else android.view.Gravity.END
            setPadding(4, 4, 4, 0)
        })
        
        return bubble
    }
    
    private fun getDifficultyColor(difficulty: String): Int {
        return when (difficulty) {
            "débutant" -> android.graphics.Color.parseColor("#27AE60")
            "intermédiaire" -> android.graphics.Color.parseColor("#F39C12")
            "avancé" -> android.graphics.Color.parseColor("#E74C3C")
            else -> android.graphics.Color.parseColor("#7F8C8D")
        }
    }
    
    private fun speakConversation(messages: List<Message>) {
        if (!isTtsReady) return
        
        messages.forEach { message ->
            tts?.speak(message.text, TextToSpeech.QUEUE_ADD, null, null)
            Thread.sleep(200)
        }
    }
    
    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val language = LanguagePreference.getLanguage(this)
            val locale = if (language == "it") Locale.ITALIAN else Locale("es", "ES")
            val result = tts?.setLanguage(locale)
            isTtsReady = result != TextToSpeech.LANG_MISSING_DATA && result != TextToSpeech.LANG_NOT_SUPPORTED
        }
    }
    
    fun speak(text: String) {
        if (isTtsReady) {
            tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
        }
    }
    
    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
    
    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
