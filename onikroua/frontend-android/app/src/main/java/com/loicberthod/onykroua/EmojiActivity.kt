package com.loicberthod.onykroua

import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.loicberthod.onykroua.emoji.EmojiData
import com.loicberthod.onykroua.emoji.EmojiWord
import com.loicberthod.onykroua.utils.LanguagePreference
import java.util.Locale

class EmojiActivity : AppCompatActivity(), TextToSpeech.OnInitListener {
    
    private var tts: TextToSpeech? = null
    private var isTtsReady = false
    private var selectedCategory: String? = null
    
    private lateinit var categoriesContainer: LinearLayout
    private lateinit var emojisContainer: LinearLayout
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_emoji)
        
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = "😊 Apprendre avec les Emojis"
        
        categoriesContainer = findViewById(R.id.categoriesContainer)
        emojisContainer = findViewById(R.id.emojisContainer)
        
        tts = TextToSpeech(this, this)
        
        displayCategories()
        displayEmojis()
    }
    
    private fun displayCategories() {
        categoriesContainer.removeAllViews()
        
        val language = LanguagePreference.getLanguage(this)
        val categories = EmojiData.getEmojiCategories(language)
        
        val allButton = createCategoryButton("Tous", "🌍", null)
        categoriesContainer.addView(allButton)
        
        categories.forEach { category ->
            val button = createCategoryButton(category.name, category.icon, category.name)
            categoriesContainer.addView(button)
        }
    }
    
    private fun createCategoryButton(name: String, icon: String, categoryName: String?): TextView {
        val isSelected = selectedCategory == categoryName
        return TextView(this).apply {
            text = "$icon $name"
            textSize = 14f
            setPadding(24, 16, 24, 16)
            setBackgroundColor(if (isSelected) {
                android.graphics.Color.parseColor("#E0E7FF")
            } else {
                android.graphics.Color.WHITE
            })
            setTextColor(android.graphics.Color.parseColor(if (isSelected) "#4F46E5" else "#333333"))
            if (isSelected) setTypeface(null, android.graphics.Typeface.BOLD)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 8, 0)
            layoutParams = params
            isClickable = true
            setOnClickListener {
                selectedCategory = categoryName
                displayCategories()
                displayEmojis()
            }
        }
    }
    
    private fun displayEmojis() {
        emojisContainer.removeAllViews()
        
        val language = LanguagePreference.getLanguage(this)
        val categories = EmojiData.getEmojiCategories(language)
        
        val filtered = if (selectedCategory == null) {
            categories
        } else {
            categories.filter { it.name == selectedCategory }
        }
        
        filtered.forEach { category ->
            emojisContainer.addView(createCategoryHeader(category.name, category.icon))
            
            val grid = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
            }
            
            var row: LinearLayout? = null
            category.items.forEachIndexed { index, emoji ->
                if (index % 3 == 0) {
                    row = LinearLayout(this).apply {
                        orientation = LinearLayout.HORIZONTAL
                        weightSum = 3f
                        layoutParams = LinearLayout.LayoutParams(
                            LinearLayout.LayoutParams.MATCH_PARENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT
                        )
                    }
                    grid.addView(row)
                }
                row?.addView(createEmojiCard(emoji))
            }
            
            emojisContainer.addView(grid)
        }
    }
    
    private fun createCategoryHeader(name: String, icon: String): TextView {
        return TextView(this).apply {
            text = "$icon $name"
            textSize = 20f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(16, 24, 16, 12)
            setBackgroundColor(android.graphics.Color.parseColor("#F0F4FF"))
        }
    }
    
    private fun createEmojiCard(emoji: EmojiWord): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(16, 16, 16, 16)
            setBackgroundColor(android.graphics.Color.WHITE)
            val params = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
            params.setMargins(4, 4, 4, 4)
            layoutParams = params
            isClickable = true
            setOnClickListener {
                speak(emoji.word)
            }
        }
        
        card.addView(TextView(this).apply {
            text = emoji.emoji
            textSize = 48f
            gravity = android.view.Gravity.CENTER
        })
        
        card.addView(TextView(this).apply {
            text = emoji.word
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#4F46E5"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            gravity = android.view.Gravity.CENTER
            setPadding(0, 8, 0, 4)
        })
        
        card.addView(TextView(this).apply {
            text = emoji.fr
            textSize = 12f
            setTextColor(android.graphics.Color.parseColor("#999999"))
            gravity = android.view.Gravity.CENTER
        })
        
        card.addView(TextView(this).apply {
            text = "🔊"
            textSize = 12f
            gravity = android.view.Gravity.CENTER
            setPadding(0, 4, 0, 0)
        })
        
        return card
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
