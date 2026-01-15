package com.loicberthod.onykroua

import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.viewpager2.widget.ViewPager2
import com.loicberthod.onykroua.feed.*
import com.loicberthod.onykroua.vocabulary.VocabularyData
import java.util.Locale

class FeedActivity : AppCompatActivity(), TextToSpeech.OnInitListener {
    
    private var language: String = "it"
    private var tts: TextToSpeech? = null
    private var isTtsReady = false
    
    private lateinit var languageButtonIt: Button
    private lateinit var languageButtonEs: Button
    private lateinit var viewPager: ViewPager2
    private lateinit var loadingIndicator: ProgressBar
    
    private val feedItems = mutableListOf<FeedItem>()
    private var isLoading = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_feed)
        
        language = intent.getStringExtra("language") ?: "it"
        
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = "📱 Feed"
        
        // Charger le vocabulaire pour les deux langues
        loadVocabularyData()
        
        languageButtonIt = findViewById(R.id.languageButtonIt)
        languageButtonEs = findViewById(R.id.languageButtonEs)
        viewPager = findViewById(R.id.feedViewPager)
        loadingIndicator = findViewById(R.id.loadingIndicator)
        
        tts = TextToSpeech(this, this)
        
        updateLanguageButtons()
        setupViewPager()
        
        languageButtonIt.setOnClickListener {
            language = "it"
            updateLanguageButtons()
            reloadFeed()
        }
        
        languageButtonEs.setOnClickListener {
            language = "es"
            updateLanguageButtons()
            reloadFeed()
        }
        
        loadInitialFeed()
    }
    
    private fun loadVocabularyData() {
        try {
            // Charger italien
            val jsonStringIt = assets.open("vocabulary_it.json").bufferedReader().use { it.readText() }
            VocabularyData.loadVocabulary(jsonStringIt, "it")
            android.util.Log.d("FeedActivity", "Loaded Italian vocabulary")
            
            // Charger espagnol
            val jsonStringEs = assets.open("vocabulary_es.json").bufferedReader().use { it.readText() }
            VocabularyData.loadVocabulary(jsonStringEs, "es")
            android.util.Log.d("FeedActivity", "Loaded Spanish vocabulary")
        } catch (e: Exception) {
            android.util.Log.e("FeedActivity", "Error loading vocabulary", e)
            e.printStackTrace()
        }
    }
    
    private fun setupViewPager() {
        viewPager.orientation = ViewPager2.ORIENTATION_VERTICAL
        viewPager.offscreenPageLimit = 2
        
        viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageScrollStateChanged(state: Int) {
                super.onPageScrollStateChanged(state)
                // Stop TTS when scrolling starts
                if (state == ViewPager2.SCROLL_STATE_DRAGGING || state == ViewPager2.SCROLL_STATE_SETTLING) {
                    tts?.stop()
                }
            }
            
            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)
                
                // Stop TTS when changing page
                tts?.stop()
                
                // Charger plus tôt pour scroll fluide (5 items avant la fin)
                if (position >= feedItems.size - 5 && !isLoading && FeedService.hasMore()) {
                    loadMoreItems()
                }
            }
        })
    }
    
    private fun updateLanguageButtons() {
        val activeColor = ContextCompat.getColor(this, android.R.color.holo_red_light)
        val inactiveColor = ContextCompat.getColor(this, android.R.color.darker_gray)
        
        languageButtonIt.setBackgroundColor(if (language == "it") activeColor else inactiveColor)
        languageButtonEs.setBackgroundColor(if (language == "es") activeColor else inactiveColor)
    }
    
    private fun loadInitialFeed() {
        isLoading = true
        loadingIndicator.visibility = View.VISIBLE
        
        FeedService.setLanguage(language)
        
        // Charger 2 pages au démarrage pour meilleure expérience
        val items1 = FeedService.getNextPage()
        val items2 = FeedService.getNextPage()
        feedItems.addAll(items1)
        feedItems.addAll(items2)
        
        android.util.Log.d("FeedActivity", "Loaded ${feedItems.size} items")
        feedItems.forEach { item ->
            android.util.Log.d("FeedActivity", "Item type: ${item.type}, id: ${item.id}")
        }
        
        val adapter = FeedPagerAdapter(this, feedItems, tts, ::handleLike, ::handleBookmark)
        viewPager.adapter = adapter
        
        isLoading = false
        loadingIndicator.visibility = View.GONE
    }
    
    private fun reloadFeed() {
        feedItems.clear()
        FeedService.reset()
        FeedService.setLanguage(language)
        loadInitialFeed()
    }
    
    private fun loadMoreItems() {
        if (isLoading || !FeedService.hasMore()) return
        
        isLoading = true
        
        val newItems = FeedService.getNextPage()
        val startPosition = feedItems.size
        feedItems.addAll(newItems)
        
        viewPager.adapter?.notifyItemRangeInserted(startPosition, newItems.size)
        
        isLoading = false
    }
    
    private fun handleLike(itemId: String, liked: Boolean) {
        val item = feedItems.find { it.id == itemId }
        item?.let {
            it.liked = liked
            it.likeCount += if (liked) 1 else -1
        }
    }
    
    private fun handleBookmark(itemId: String, bookmarked: Boolean) {
        val item = feedItems.find { it.id == itemId }
        item?.bookmarked = bookmarked
        
        Toast.makeText(
            this,
            if (bookmarked) "Ajouté aux favoris" else "Retiré des favoris",
            Toast.LENGTH_SHORT
        ).show()
    }
    
    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val locale = if (language == "it") Locale.ITALIAN else Locale("es", "ES")
            val result = tts?.setLanguage(locale)
            isTtsReady = result != TextToSpeech.LANG_MISSING_DATA && result != TextToSpeech.LANG_NOT_SUPPORTED
            tts?.setSpeechRate(0.85f)
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
