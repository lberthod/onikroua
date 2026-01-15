package com.loicberthod.onykroua

import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.loicberthod.onykroua.phonetic.PhoneticData
import com.loicberthod.onykroua.phonetic.PhoneticSound
import com.loicberthod.onykroua.phonetic.PracticeWord
import com.loicberthod.onykroua.utils.LanguagePreference
import java.util.Locale

class PhoneticActivity : AppCompatActivity(), TextToSpeech.OnInitListener {
    
    private var selectedCategory: String = "all"
    private var activeTab: String = "learn"
    private var tts: TextToSpeech? = null
    private var isTtsReady = false
    
    private lateinit var tabLearn: Button
    private lateinit var tabPractice: Button
    private lateinit var categoryContainer: LinearLayout
    private lateinit var learnContent: ScrollView
    private lateinit var practiceContent: ScrollView
    private lateinit var soundsContainer: LinearLayout
    private lateinit var practiceContainer: LinearLayout
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_phonetic)
        
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = "🎵 Phonétique"
        
        tabLearn = findViewById(R.id.tabLearn)
        tabPractice = findViewById(R.id.tabPractice)
        categoryContainer = findViewById(R.id.categoryContainer)
        learnContent = findViewById(R.id.learnContent)
        practiceContent = findViewById(R.id.practiceContent)
        soundsContainer = findViewById(R.id.soundsContainer)
        practiceContainer = findViewById(R.id.practiceContainer)
        
        tts = TextToSpeech(this, this)
        
        tabLearn.setOnClickListener {
            activeTab = "learn"
            updateTabs()
            updateContent()
        }
        
        tabPractice.setOnClickListener {
            activeTab = "practice"
            updateTabs()
            updateContent()
        }
        
        displayCategories()
        updateTabs()
        updateContent()
    }
    
    private fun displayCategories() {
        categoryContainer.removeAllViews()
        
        val language = LanguagePreference.getLanguage(this)
        PhoneticData.getCategories().forEach { category ->
            val count = PhoneticData.getSounds(language, category.id).size
            val button = createCategoryButton(category.id, category.icon, category.name, count)
            categoryContainer.addView(button)
        }
    }
    
    private fun createCategoryButton(id: String, icon: String, label: String, count: Int): TextView {
        val isSelected = selectedCategory == id
        return TextView(this).apply {
            text = "$icon $label ($count)"
            textSize = 13f
            setPadding(20, 12, 20, 12)
            setBackgroundColor(if (isSelected) {
                ContextCompat.getColor(context, android.R.color.holo_blue_light)
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
                selectedCategory = id
                displayCategories()
                updateContent()
            }
        }
    }
    
    private fun updateTabs() {
        tabLearn.setBackgroundColor(if (activeTab == "learn") {
            ContextCompat.getColor(this, android.R.color.holo_purple)
        } else {
            android.graphics.Color.TRANSPARENT
        })
        tabLearn.setTextColor(if (activeTab == "learn") {
            android.graphics.Color.WHITE
        } else {
            android.graphics.Color.parseColor("#7F8C8D")
        })
        
        tabPractice.setBackgroundColor(if (activeTab == "practice") {
            ContextCompat.getColor(this, android.R.color.holo_purple)
        } else {
            android.graphics.Color.TRANSPARENT
        })
        tabPractice.setTextColor(if (activeTab == "practice") {
            android.graphics.Color.WHITE
        } else {
            android.graphics.Color.parseColor("#7F8C8D")
        })
    }
    
    private fun updateContent() {
        if (activeTab == "learn") {
            learnContent.visibility = ScrollView.VISIBLE
            practiceContent.visibility = ScrollView.GONE
            displaySounds()
        } else {
            learnContent.visibility = ScrollView.GONE
            practiceContent.visibility = ScrollView.VISIBLE
            displayPractice()
        }
    }
    
    private fun displaySounds() {
        soundsContainer.removeAllViews()
        
        val language = LanguagePreference.getLanguage(this)
        val sounds = PhoneticData.getSounds(language, selectedCategory)
        
        if (sounds.isEmpty()) {
            soundsContainer.addView(TextView(this).apply {
                text = "Aucun son disponible pour cette catégorie"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#999999"))
                gravity = android.view.Gravity.CENTER
                setPadding(32, 64, 32, 64)
            })
            return
        }
        
        sounds.forEach { sound ->
            soundsContainer.addView(createSoundCard(sound))
        }
    }
    
    private fun createSoundCard(sound: PhoneticSound): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(20, 16, 20, 16)
            setBackgroundColor(android.graphics.Color.WHITE)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 12)
            layoutParams = params
        }
        
        val header = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        header.addView(TextView(this).apply {
            text = sound.graphie
            textSize = 24f
            setTextColor(android.graphics.Color.parseColor("#9B59B6"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        })
        
        header.addView(TextView(this).apply {
            text = sound.phonetic
            textSize = 20f
            setTextColor(android.graphics.Color.parseColor("#667EEA"))
            setTypeface(null, android.graphics.Typeface.BOLD)
        })
        
        header.addView(TextView(this).apply {
            text = getDifficultyBadge(sound.difficulty)
            textSize = 10f
            setPadding(12, 6, 12, 6)
            setTextColor(android.graphics.Color.WHITE)
            setBackgroundColor(getDifficultyColor(sound.difficulty))
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(8, 0, 0, 0)
            layoutParams = params
        })
        
        card.addView(header)
        
        card.addView(TextView(this).apply {
            text = sound.description
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#555555"))
            setPadding(0, 12, 0, 12)
        })
        
        card.addView(TextView(this).apply {
            text = "📝 Exemples:"
            textSize = 13f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 8, 0, 4)
        })
        
        sound.examples.forEach { example ->
            val exampleRow = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(12, 8, 12, 8)
                setBackgroundColor(android.graphics.Color.parseColor("#F8F9FA"))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 4, 0, 4)
                layoutParams = params
                isClickable = true
                setOnClickListener {
                    speak(example)
                }
            }
            
            exampleRow.addView(TextView(this).apply {
                text = example
                textSize = 15f
                setTextColor(android.graphics.Color.parseColor("#4F46E5"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
            })
            
            exampleRow.addView(TextView(this).apply {
                text = "🔊"
                textSize = 14f
            })
            
            card.addView(exampleRow)
        }
        
        if (!sound.tips.isNullOrEmpty()) {
            card.addView(TextView(this).apply {
                text = "💡 ${sound.tips}"
                textSize = 13f
                setTextColor(android.graphics.Color.parseColor("#667EEA"))
                setPadding(12, 12, 12, 12)
                setBackgroundColor(android.graphics.Color.parseColor("#F0F4FF"))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 12, 0, 0)
                layoutParams = params
            })
        }
        
        if (!sound.commonMistakes.isNullOrEmpty()) {
            card.addView(TextView(this).apply {
                text = "⚠️ ${sound.commonMistakes}"
                textSize = 12f
                setTextColor(android.graphics.Color.parseColor("#E74C3C"))
                setPadding(0, 8, 0, 0)
                setTypeface(null, android.graphics.Typeface.ITALIC)
            })
        }
        
        return card
    }
    
    private fun displayPractice() {
        practiceContainer.removeAllViews()
        
        val language = LanguagePreference.getLanguage(this)
        val words = PhoneticData.getPracticeWords(language)
        
        practiceContainer.addView(TextView(this).apply {
            text = "🎧 Cliquez sur les mots pour entendre la prononciation"
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#666666"))
            gravity = android.view.Gravity.CENTER
            setPadding(16, 16, 16, 24)
        })
        
        words.forEach { word ->
            practiceContainer.addView(createPracticeCard(word))
        }
    }
    
    private fun createPracticeCard(word: PracticeWord): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(20, 16, 20, 16)
            setBackgroundColor(android.graphics.Color.WHITE)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 12)
            layoutParams = params
            isClickable = true
            setOnClickListener {
                speak(word.word)
            }
        }
        
        val row = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        val textContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        }
        
        textContainer.addView(TextView(this).apply {
            text = word.word
            textSize = 20f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
        })
        
        if (!word.phonetic.isNullOrEmpty()) {
            textContainer.addView(TextView(this).apply {
                text = word.phonetic
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#9B59B6"))
                setPadding(0, 4, 0, 0)
            })
        }
        
        textContainer.addView(TextView(this).apply {
            text = "→ ${word.translation}"
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#666666"))
            setPadding(0, 4, 0, 0)
        })
        
        row.addView(textContainer)
        
        row.addView(TextView(this).apply {
            text = "🔊"
            textSize = 32f
            setPadding(16, 0, 0, 0)
        })
        
        card.addView(row)
        
        return card
    }
    
    private fun getDifficultyBadge(difficulty: String): String {
        return when (difficulty) {
            "easy" -> "FACILE"
            "medium" -> "MOYEN"
            "hard" -> "DIFFICILE"
            else -> difficulty.uppercase()
        }
    }
    
    private fun getDifficultyColor(difficulty: String): Int {
        return when (difficulty) {
            "easy" -> android.graphics.Color.parseColor("#27AE60")
            "medium" -> android.graphics.Color.parseColor("#F39C12")
            "hard" -> android.graphics.Color.parseColor("#E74C3C")
            else -> android.graphics.Color.parseColor("#95A5A6")
        }
    }
    
    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val language = LanguagePreference.getLanguage(this)
            val locale = if (language == "it") Locale.ITALIAN else Locale("es", "ES")
            val result = tts?.setLanguage(locale)
            isTtsReady = result != TextToSpeech.LANG_MISSING_DATA && result != TextToSpeech.LANG_NOT_SUPPORTED
            tts?.setSpeechRate(0.75f)
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
