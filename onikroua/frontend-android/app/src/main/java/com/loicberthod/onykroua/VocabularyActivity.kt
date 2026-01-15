package com.loicberthod.onykroua

import android.os.Bundle
import android.speech.tts.TextToSpeech
import androidx.appcompat.app.AppCompatActivity
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.tabs.TabLayout
import com.google.android.material.tabs.TabLayoutMediator
import com.loicberthod.onykroua.utils.LanguagePreference
import com.loicberthod.onykroua.vocabulary.VocabularyData
import com.loicberthod.onykroua.vocabulary.VocabularyPagerAdapter
import java.util.Locale

class VocabularyActivity : AppCompatActivity(), TextToSpeech.OnInitListener {
    
    private var tts: TextToSpeech? = null
    private var isTtsReady = false
    
    private lateinit var viewPager: ViewPager2
    private lateinit var tabLayout: TabLayout
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_vocabulary)
        
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        
        viewPager = findViewById(R.id.viewPager)
        tabLayout = findViewById(R.id.tabLayout)
        
        loadVocabularyData()
        updateTitle()
        
        tts = TextToSpeech(this, this)
        
        setupViewPager()
    }
    
    private fun updateTitle() {
        val language = LanguagePreference.getLanguage(this)
        val totalWords = VocabularyData.getAllWords(language).size
        supportActionBar?.title = "📚 Vocabulaire ($totalWords mots)"
    }
    
    private fun loadVocabularyData() {
        try {
            val language = LanguagePreference.getLanguage(this)
            val fileName = if (language == "it") "vocabulary_it.json" else "vocabulary_es.json"
            val jsonString = assets.open(fileName).bufferedReader().use { it.readText() }
            VocabularyData.loadVocabulary(jsonString, language)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun setupViewPager() {
        val language = LanguagePreference.getLanguage(this)
        val adapter = VocabularyPagerAdapter(this, language)
        viewPager.adapter = adapter
        
        TabLayoutMediator(tabLayout, viewPager) { tab, position ->
            tab.text = when (position) {
                0 -> "📖 Dictionnaire"
                1 -> "🗂️ Catégories"
                2 -> "🎯 Pratique"
                else -> ""
            }
        }.attach()
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
    
    fun getCurrentLanguage(): String = LanguagePreference.getLanguage(this)
    
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
