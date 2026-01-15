package com.loicberthod.onykroua

import android.os.Bundle
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import com.google.firebase.auth.FirebaseAuth
import com.loicberthod.onykroua.utils.LanguagePreference

class ProfileActivity : AppCompatActivity() {
    
    private lateinit var auth: FirebaseAuth
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_profile)
        
        auth = FirebaseAuth.getInstance()
        
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = "👤 Profil"
        
        setupUserInfo()
        setupSettings()
        setupStats()
    }
    
    private fun setupUserInfo() {
        val userEmail = findViewById<TextView>(R.id.profileEmail)
        val userName = findViewById<TextView>(R.id.profileName)
        
        userEmail.text = auth.currentUser?.email ?: "Non connecté"
        userName.text = auth.currentUser?.displayName ?: "Utilisateur"
    }
    
    private fun setupSettings() {
        val languageSpinner = findViewById<Spinner>(R.id.languageSpinner)
        val darkModeSwitch = findViewById<Switch>(R.id.darkModeSwitch)
        val notificationsSwitch = findViewById<Switch>(R.id.notificationsSwitch)
        val soundSwitch = findViewById<Switch>(R.id.soundSwitch)
        val autoPlaySwitch = findViewById<Switch>(R.id.autoPlaySwitch)
        
        val languages = arrayOf("🇮🇹 Italien", "🇪🇸 Espagnol")
        val languageCodes = arrayOf("it", "es")
        
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, languages)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        languageSpinner.adapter = adapter
        
        val currentLanguage = LanguagePreference.getLanguage(this)
        languageSpinner.setSelection(if (currentLanguage == "it") 0 else 1)
        
        languageSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                val selectedLanguage = languageCodes[position]
                if (selectedLanguage != LanguagePreference.getLanguage(this@ProfileActivity)) {
                    LanguagePreference.setLanguage(this@ProfileActivity, selectedLanguage)
                    Toast.makeText(
                        this@ProfileActivity,
                        "Langue d'apprentissage changée : ${languages[position]}",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }
            
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
        
        // Dark mode
        val isDarkMode = getSharedPreferences("settings", MODE_PRIVATE)
            .getBoolean("dark_mode", false)
        darkModeSwitch.isChecked = isDarkMode
        
        darkModeSwitch.setOnCheckedChangeListener { _, isChecked ->
            getSharedPreferences("settings", MODE_PRIVATE)
                .edit()
                .putBoolean("dark_mode", isChecked)
                .apply()
            
            AppCompatDelegate.setDefaultNightMode(
                if (isChecked) AppCompatDelegate.MODE_NIGHT_YES
                else AppCompatDelegate.MODE_NIGHT_NO
            )
        }
        
        // Notifications
        notificationsSwitch.isChecked = getSharedPreferences("settings", MODE_PRIVATE)
            .getBoolean("notifications", true)
        notificationsSwitch.setOnCheckedChangeListener { _, isChecked ->
            getSharedPreferences("settings", MODE_PRIVATE)
                .edit()
                .putBoolean("notifications", isChecked)
                .apply()
        }
        
        // Sound
        soundSwitch.isChecked = getSharedPreferences("settings", MODE_PRIVATE)
            .getBoolean("sound", true)
        soundSwitch.setOnCheckedChangeListener { _, isChecked ->
            getSharedPreferences("settings", MODE_PRIVATE)
                .edit()
                .putBoolean("sound", isChecked)
                .apply()
        }
        
        // Auto-play
        autoPlaySwitch.isChecked = getSharedPreferences("settings", MODE_PRIVATE)
            .getBoolean("auto_play", false)
        autoPlaySwitch.setOnCheckedChangeListener { _, isChecked ->
            getSharedPreferences("settings", MODE_PRIVATE)
                .edit()
                .putBoolean("auto_play", isChecked)
                .apply()
        }
    }
    
    private fun setupStats() {
        val wordsLearnedText = findViewById<TextView>(R.id.wordsLearnedCount)
        val lessonsCompletedText = findViewById<TextView>(R.id.lessonsCompletedCount)
        val streakDaysText = findViewById<TextView>(R.id.streakDaysCount)
        val totalTimeText = findViewById<TextView>(R.id.totalTimeCount)
        
        val prefs = getSharedPreferences("stats", MODE_PRIVATE)
        wordsLearnedText.text = prefs.getInt("words_learned", 0).toString()
        lessonsCompletedText.text = prefs.getInt("lessons_completed", 0).toString()
        streakDaysText.text = prefs.getInt("streak_days", 0).toString()
        totalTimeText.text = "${prefs.getInt("total_minutes", 0)} min"
    }
    
    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
