package com.loicberthod.onykroua

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.loicberthod.onykroua.grammar.GrammarData
import com.loicberthod.onykroua.grammar.GrammarRule

class GrammarActivity : AppCompatActivity() {
    
    private var language: String = "it"
    private var selectedCategory: String = "all"
    private var selectedDifficulty: String = "all"
    private var searchQuery: String = ""
    
    private lateinit var languageButton: ImageButton
    private lateinit var languageLabel: TextView
    private lateinit var searchInput: EditText
    private lateinit var categoryContainer: LinearLayout
    private lateinit var difficultyContainer: LinearLayout
    private lateinit var grammarContainer: LinearLayout
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_grammar)
        
        language = intent.getStringExtra("language") ?: "it"
        
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = "📖 Grammaire"
        
        languageButton = findViewById(R.id.languageButton)
        languageLabel = findViewById(R.id.languageLabel)
        searchInput = findViewById(R.id.searchInput)
        categoryContainer = findViewById(R.id.categoryContainer)
        difficultyContainer = findViewById(R.id.difficultyContainer)
        grammarContainer = findViewById(R.id.grammarContainer)
        
        updateLanguageLabel()
        
        languageButton.setOnClickListener {
            language = if (language == "it") "es" else "it"
            updateLanguageLabel()
            displayGrammar()
        }
        
        searchInput.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                searchQuery = s.toString().trim().lowercase()
                displayGrammar()
            }
        })
        
        displayCategoryFilters()
        displayDifficultyFilters()
        displayGrammar()
    }
    
    private fun displayCategoryFilters() {
        categoryContainer.removeAllViews()
        
        val categories = GrammarData.getCategories()
        
        categories.forEach { category ->
            val button = createCategoryButton(category.id, category.icon, category.label, category.color)
            categoryContainer.addView(button)
        }
    }
    
    private fun createCategoryButton(id: String, icon: String, label: String, color: String): TextView {
        val isSelected = selectedCategory == id
        return TextView(this).apply {
            text = "$icon $label"
            textSize = 13f
            setPadding(20, 12, 20, 12)
            setBackgroundColor(if (isSelected) {
                android.graphics.Color.parseColor(color)
            } else {
                android.graphics.Color.WHITE
            })
            setTextColor(if (isSelected) {
                android.graphics.Color.WHITE
            } else {
                android.graphics.Color.parseColor("#333333")
            })
            if (isSelected) setTypeface(null, android.graphics.Typeface.BOLD)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(4, 4, 4, 4)
            layoutParams = params
            isClickable = true
            setOnClickListener {
                selectedCategory = id
                displayCategoryFilters()
                displayGrammar()
            }
        }
    }
    
    private fun displayDifficultyFilters() {
        difficultyContainer.removeAllViews()
        
        val difficulties = listOf(
            Triple("all", "Tous niveaux", "#95A5A6"),
            Triple("débutant", "Débutant", "#27AE60"),
            Triple("intermédiaire", "Intermédiaire", "#F39C12"),
            Triple("avancé", "Avancé", "#E74C3C")
        )
        
        difficulties.forEach { (id, label, color) ->
            val button = createDifficultyButton(id, label, color)
            difficultyContainer.addView(button)
        }
    }
    
    private fun createDifficultyButton(id: String, label: String, color: String): TextView {
        val isSelected = selectedDifficulty == id
        return TextView(this).apply {
            text = label
            textSize = 12f
            setPadding(16, 10, 16, 10)
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
                displayGrammar()
            }
        }
    }
    
    private fun displayGrammar() {
        grammarContainer.removeAllViews()
        
        val allRules = GrammarData.getGrammarRules(language)
        
        // Filtrer par catégorie
        var filteredRules = if (selectedCategory == "all") {
            allRules
        } else {
            allRules.filter { it.category == selectedCategory }
        }
        
        // Filtrer par difficulté
        if (selectedDifficulty != "all") {
            filteredRules = filteredRules.filter { it.difficulty == selectedDifficulty }
        }
        
        // Filtrer par recherche
        if (searchQuery.isNotEmpty()) {
            filteredRules = filteredRules.filter { rule ->
                rule.rule.lowercase().contains(searchQuery) ||
                rule.content.lowercase().contains(searchQuery) ||
                rule.example?.lowercase()?.contains(searchQuery) == true ||
                rule.translation?.lowercase()?.contains(searchQuery) == true
            }
        }
        
        // Grouper par sous-catégorie
        val groupedRules = filteredRules.groupBy { it.subCategory }
        
        if (groupedRules.isEmpty()) {
            grammarContainer.addView(TextView(this).apply {
                text = "Aucune règle trouvée pour ces filtres"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#999999"))
                gravity = android.view.Gravity.CENTER
                setPadding(32, 64, 32, 64)
            })
            return
        }
        
        groupedRules.forEach { (subCategory, rules) ->
            grammarContainer.addView(createGroupHeader(subCategory))
            
            rules.forEach { rule ->
                grammarContainer.addView(createRuleCard(rule))
            }
        }
    }
    
    private fun createGroupHeader(subCategory: String): TextView {
        val label = GrammarData.getSubCategoryLabel(subCategory)
        return TextView(this).apply {
            text = label
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#2C3E50"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(16, 24, 16, 12)
            setBackgroundColor(android.graphics.Color.parseColor("#F0F4FF"))
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 8, 0, 0)
            layoutParams = params
        }
    }
    
    private fun createRuleCard(rule: GrammarRule): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(20, 16, 20, 16)
            setBackgroundColor(android.graphics.Color.WHITE)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 8)
            layoutParams = params
        }
        
        // Titre avec badge difficulté
        val headerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        headerRow.addView(TextView(this).apply {
            text = rule.rule
            textSize = 15f
            setTextColor(android.graphics.Color.parseColor("#2C3E50"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        })
        
        headerRow.addView(TextView(this).apply {
            text = rule.difficulty
            textSize = 10f
            setTextColor(android.graphics.Color.WHITE)
            setPadding(12, 6, 12, 6)
            setBackgroundColor(getDifficultyColor(rule.difficulty))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        })
        
        card.addView(headerRow)
        
        // Contenu
        card.addView(TextView(this).apply {
            text = rule.content
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#555555"))
            setPadding(0, 12, 0, 0)
            setLineSpacing(4f, 1f)
        })
        
        // Exemple
        if (!rule.example.isNullOrEmpty()) {
            card.addView(TextView(this).apply {
                text = "💡 ${rule.example}"
                textSize = 13f
                setTextColor(android.graphics.Color.parseColor("#667EEA"))
                setPadding(12, 12, 12, 8)
                setBackgroundColor(android.graphics.Color.parseColor("#F0F4FF"))
                setLineSpacing(4f, 1f)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 12, 0, 0)
                layoutParams = params
            })
        }
        
        // Note/traduction
        if (!rule.translation.isNullOrEmpty()) {
            card.addView(TextView(this).apply {
                text = "ℹ️ ${rule.translation}"
                textSize = 12f
                setTextColor(android.graphics.Color.parseColor("#7F8C8D"))
                setPadding(0, 8, 0, 0)
                setTypeface(null, android.graphics.Typeface.ITALIC)
            })
        }
        
        return card
    }
    
    private fun getDifficultyColor(difficulty: String): Int {
        return when (difficulty) {
            "débutant" -> android.graphics.Color.parseColor("#27AE60")
            "intermédiaire" -> android.graphics.Color.parseColor("#F39C12")
            "avancé" -> android.graphics.Color.parseColor("#E74C3C")
            else -> android.graphics.Color.parseColor("#95A5A6")
        }
    }
    
    private fun updateLanguageLabel() {
        languageLabel.text = if (language == "it") "🇮🇹 Italien" else "🇪🇸 Espagnol"
    }
    
    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
