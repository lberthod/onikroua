package com.loicberthod.onykroua

import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.util.Log
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.tabs.TabLayout
import com.google.android.material.tabs.TabLayoutMediator
import com.loicberthod.onykroua.conjugation.*
import com.loicberthod.onykroua.utils.LanguagePreference
import java.util.*

class ConjugationActivity : AppCompatActivity(), TextToSpeech.OnInitListener {
    
    private lateinit var tabLayout: TabLayout
    private lateinit var viewPager: ViewPager2
    private var tts: TextToSpeech? = null
    private var ttsReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        try {
            setContentView(R.layout.activity_conjugation)
            
            supportActionBar?.title = "Conjugaison & Grammaire"
            supportActionBar?.setDisplayHomeAsUpEnabled(true)
            
            tabLayout = findViewById(R.id.tabLayout)
            viewPager = findViewById(R.id.viewPager)
            
            setupViewPager()
            
            // Initialiser TTS en dernier
            try {
                tts = TextToSpeech(this, this)
            } catch (e: Exception) {
                Log.e("ConjugationActivity", "TTS init failed", e)
            }
            
        } catch (e: Exception) {
            Log.e("ConjugationActivity", "Error in onCreate", e)
            Toast.makeText(this, "Erreur de chargement", Toast.LENGTH_SHORT).show()
            finish()
        }
    }
    
    private fun setupViewPager() {
        try {
            val currentLanguage = LanguagePreference.getLanguage(this)
            val adapter = ConjugationPagerAdapter(this, currentLanguage)
            viewPager.adapter = adapter
            
            TabLayoutMediator(tabLayout, viewPager) { tab, position ->
                tab.text = when(position) {
                    0 -> "📚 Règles"
                    1 -> "✏️ Verbes"
                    2 -> "⏰ Temps"
                    3 -> "🎮 Pratique"
                    4 -> "➕ Plus"
                    else -> ""
                }
            }.attach()
        } catch (e: Exception) {
            Log.e("ConjugationActivity", "Error in setupViewPager", e)
        }
    }
    
    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            try {
                val currentLanguage = LanguagePreference.getLanguage(this)
                val locale = if (currentLanguage == "it") Locale.ITALIAN else Locale("es", "ES")
                val result = tts?.setLanguage(locale)
                ttsReady = result != TextToSpeech.LANG_MISSING_DATA && result != TextToSpeech.LANG_NOT_SUPPORTED
                tts?.setSpeechRate(0.85f)
            } catch (e: Exception) {
                Log.e("ConjugationActivity", "Error in onInit", e)
            }
        }
    }
    
    fun speak(text: String) {
        try {
            if (ttsReady && tts != null) {
                tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
            }
        } catch (e: Exception) {
            Log.e("ConjugationActivity", "Error in speak", e)
        }
    }
    
    fun getCurrentLanguage() = LanguagePreference.getLanguage(this)
    
    override fun onDestroy() {
        try {
            tts?.stop()
            tts?.shutdown()
        } catch (e: Exception) {
            Log.e("ConjugationActivity", "Error in onDestroy", e)
        }
        super.onDestroy()
    }
    
    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
