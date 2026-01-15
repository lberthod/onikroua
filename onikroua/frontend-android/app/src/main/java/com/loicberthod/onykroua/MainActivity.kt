package com.loicberthod.onykroua

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.firebase.auth.FirebaseAuth

class MainActivity : AppCompatActivity() {
    
    private lateinit var auth: FirebaseAuth

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        auth = FirebaseAuth.getInstance()
        
        if (auth.currentUser == null) {
            startActivity(Intent(this, LoginActivity::class.java))
            finish()
            return
        }
        
        setContentView(R.layout.activity_main)
        
        val emailText: TextView = findViewById(R.id.userEmailText)
        val profileButton: ImageView = findViewById(R.id.profileButton)
        val continueCard: View = findViewById(R.id.continueCard)
        val conjugationButton: View = findViewById(R.id.conjugationButton)
        val logoutButton: TextView = findViewById(R.id.logoutButton)
        val lessonsRecycler: RecyclerView = findViewById(R.id.lessonsRecycler)
        val vocabularyButton: View = findViewById(R.id.vocabularyButton)
        val emojiButton: View = findViewById(R.id.emojiButton)
        val conversationButton: View = findViewById(R.id.conversationButton)
        val grammarButton: View = findViewById(R.id.grammarButton)
        val phoneticButton: View = findViewById(R.id.phoneticButton)
        val feedButton: View = findViewById(R.id.feedButton)
        val geminiLiveButton: View = findViewById(R.id.geminiLiveButton)
        
        emailText.text = "${auth.currentUser?.email ?: "Utilisateur"}"
        
        profileButton.setOnClickListener {
            val intent = Intent(this, ProfileActivity::class.java)
            startActivity(intent)
        }
        
        continueCard.setOnClickListener {
            val intent = Intent(this, FeedActivity::class.java)
            startActivity(intent)
        }
        
        conjugationButton.setOnClickListener {
            val intent = Intent(this, ConjugationActivity::class.java)
            startActivity(intent)
        }
        
        vocabularyButton.setOnClickListener {
            val intent = Intent(this, VocabularyActivity::class.java)
            startActivity(intent)
        }
        
        emojiButton.setOnClickListener {
            val intent = Intent(this, EmojiActivity::class.java)
            startActivity(intent)
        }
        
        conversationButton.setOnClickListener {
            val intent = Intent(this, ConversationActivity::class.java)
            startActivity(intent)
        }
        
        grammarButton.setOnClickListener {
            val intent = Intent(this, GrammarActivity::class.java)
            startActivity(intent)
        }
        
        phoneticButton.setOnClickListener {
            val intent = Intent(this, PhoneticActivity::class.java)
            startActivity(intent)
        }
        
        feedButton.setOnClickListener {
            val intent = Intent(this, FeedActivity::class.java)
            startActivity(intent)
        }
        
        geminiLiveButton.setOnClickListener {
            val intent = Intent(this, GeminiLiveActivity::class.java)
            startActivity(intent)
        }
        
        logoutButton.setOnClickListener {
            auth.signOut()
            startActivity(Intent(this, LoginActivity::class.java))
            finish()
        }
        
        lessonsRecycler.layoutManager = LinearLayoutManager(this)
        lessonsRecycler.adapter = LessonAdapter(getDemoLessons())
    }
    
    private fun getDemoLessons(): List<Lesson> {
        return listOf(
            Lesson("Leçon 1", "Les bases de l'italien"),
            Lesson("Leçon 2", "Les nombres"),
            Lesson("Leçon 3", "Les salutations"),
            Lesson("Leçon 4", "La famille"),
            Lesson("Leçon 5", "La nourriture")
        )
    }
}
