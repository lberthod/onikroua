package com.loicberthod.onykroua.vocabulary

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.loicberthod.onykroua.R
import com.loicberthod.onykroua.VocabularyActivity

class CategoriesFragment : Fragment() {
    
    private var language: String = "it"
    private lateinit var categoriesContainer: LinearLayout
    private var expandedMainCategories = mutableSetOf<String>()
    private var selectedSubCategory: String? = null
    
    companion object {
        fun newInstance(lang: String) = CategoriesFragment().apply {
            arguments = Bundle().apply { putString("lang", lang) }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        language = arguments?.getString("lang") ?: "it"
    }
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val view = inflater.inflate(R.layout.fragment_categories, container, false)
        
        categoriesContainer = view.findViewById(R.id.categoriesContainer)
        
        displayCategories()
        
        return view
    }
    
    private fun displayCategories() {
        categoriesContainer.removeAllViews()
        
        val categoriesGrouped = VocabularyData.getCategoriesGroupedByMain(language)
        val categoriesWithoutMain = VocabularyData.getCategories(language).filter { it.mainCategory == null }
        
        // Afficher les catégories sans main_category en premier
        if (categoriesWithoutMain.isNotEmpty()) {
            categoriesWithoutMain.forEach { category ->
                categoriesContainer.addView(createLegacyCategoryCard(category))
            }
        }
        
        // Afficher les catégories groupées par main_category
        categoriesGrouped.entries.sortedBy { it.key }.forEach { (mainCategory, subCategories) ->
            categoriesContainer.addView(createMainCategoryCard(mainCategory, subCategories))
        }
    }
    
    private fun createMainCategoryCard(mainCategory: String, subCategories: List<VocabCategory>): LinearLayout {
        val isExpanded = expandedMainCategories.contains(mainCategory)
        
        val mainCard = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, 0, 0, 0)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 16)
            layoutParams = params
        }
        
        // Header de la catégorie principale
        val header = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(24, 20, 24, 20)
            setBackgroundColor(android.graphics.Color.parseColor("#4F46E5"))
            isClickable = true
            isFocusable = true
            elevation = 4f
            setOnClickListener {
                if (isExpanded) {
                    expandedMainCategories.remove(mainCategory)
                } else {
                    expandedMainCategories.add(mainCategory)
                }
                displayCategories()
            }
        }
        
        header.addView(TextView(requireContext()).apply {
            text = if (isExpanded) "▼" else "▶"
            textSize = 16f
            setTextColor(android.graphics.Color.WHITE)
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 0, 16, 0)
        })
        
        header.addView(TextView(requireContext()).apply {
            text = mainCategory
            textSize = 20f
            setTextColor(android.graphics.Color.WHITE)
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        })
        
        val totalWords = subCategories.sumOf { it.words.size }
        header.addView(TextView(requireContext()).apply {
            text = "${subCategories.size} catégories · $totalWords mots"
            textSize = 12f
            setTextColor(android.graphics.Color.parseColor("#E0E7FF"))
        })
        
        mainCard.addView(header)
        
        // Sous-catégories
        if (isExpanded) {
            val subContainer = LinearLayout(requireContext()).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(12, 12, 12, 12)
                setBackgroundColor(android.graphics.Color.parseColor("#F8F9FF"))
            }
            
            subCategories.forEach { subCategory ->
                subContainer.addView(createSubCategoryCard(subCategory))
            }
            
            mainCard.addView(subContainer)
        }
        
        return mainCard
    }
    
    private fun createSubCategoryCard(category: VocabCategory): LinearLayout {
        val isSelected = selectedSubCategory == category.name
        
        val card = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(20, 16, 20, 16)
            setBackgroundColor(if (isSelected) {
                android.graphics.Color.parseColor("#E0E7FF")
            } else {
                android.graphics.Color.WHITE
            })
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 8)
            layoutParams = params
            isClickable = true
            isFocusable = true
            elevation = 2f
            setOnClickListener {
                selectedSubCategory = if (isSelected) null else category.name
                displayCategories()
            }
        }
        
        val headerRow = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.HORIZONTAL
        }
        
        headerRow.addView(TextView(requireContext()).apply {
            text = "${category.icon} ${category.subCategory ?: category.name}"
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#4F46E5"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        })
        
        headerRow.addView(TextView(requireContext()).apply {
            text = "${category.words.size} mots"
            textSize = 12f
            setTextColor(android.graphics.Color.parseColor("#9CA3AF"))
            setPadding(8, 0, 0, 0)
        })
        
        card.addView(headerRow)
        
        if (isSelected) {
            category.words.forEach { word ->
                card.addView(createWordItem(word))
            }
        }
        
        return card
    }
    
    private fun createWordItem(word: VocabWord): LinearLayout {
        val item = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(16, 12, 16, 12)
            setBackgroundColor(android.graphics.Color.WHITE)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 8, 0, 0)
            layoutParams = params
        }
        
        val headerRow = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.HORIZONTAL
            isClickable = true
            setOnClickListener {
                (activity as? VocabularyActivity)?.speak(word.word)
            }
        }
        
        headerRow.addView(TextView(requireContext()).apply {
            text = word.word
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#4F46E5"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        })
        
        headerRow.addView(TextView(requireContext()).apply {
            text = "🔊"
            textSize = 14f
        })
        
        item.addView(headerRow)
        
        item.addView(TextView(requireContext()).apply {
            text = word.translation
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#666666"))
            setPadding(0, 4, 0, 0)
        })
        
        if (!word.example.isNullOrEmpty()) {
            val exampleRow = LinearLayout(requireContext()).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(0, 8, 0, 4)
                isClickable = true
                setOnClickListener {
                    (activity as? VocabularyActivity)?.speak(word.example)
                }
            }
            
            exampleRow.addView(TextView(requireContext()).apply {
                text = "💡 ${word.example}"
                textSize = 13f
                setTextColor(android.graphics.Color.parseColor("#4F46E5"))
                setTypeface(null, android.graphics.Typeface.ITALIC)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
            })
            
            exampleRow.addView(TextView(requireContext()).apply {
                text = "🔊"
                textSize = 12f
                setPadding(8, 0, 0, 0)
            })
            
            item.addView(exampleRow)
            
            if (!word.exampleTranslation.isNullOrEmpty()) {
                item.addView(TextView(requireContext()).apply {
                    text = word.exampleTranslation
                    textSize = 12f
                    setTextColor(android.graphics.Color.parseColor("#999999"))
                    setTypeface(null, android.graphics.Typeface.ITALIC)
                    setPadding(0, 0, 0, 0)
                })
            }
        }
        
        return item
    }
    
    private fun createLegacyCategoryCard(category: VocabCategory): LinearLayout {
        val isSelected = selectedSubCategory == category.name
        
        val card = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(24, 20, 24, 20)
            setBackgroundColor(if (isSelected) {
                android.graphics.Color.parseColor("#FEF3C7")
            } else {
                android.graphics.Color.parseColor("#FFFBEB")
            })
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 12)
            layoutParams = params
            isClickable = true
            isFocusable = true
            elevation = 2f
            setOnClickListener {
                selectedSubCategory = if (isSelected) null else category.name
                displayCategories()
            }
        }
        
        card.addView(TextView(requireContext()).apply {
            text = "${category.icon} ${category.name}"
            textSize = 18f
            setTextColor(android.graphics.Color.parseColor("#92400E"))
            setTypeface(null, android.graphics.Typeface.BOLD)
        })
        
        card.addView(TextView(requireContext()).apply {
            text = "${category.words.size} mots"
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#B45309"))
            setPadding(0, 4, 0, 0)
        })
        
        if (isSelected) {
            category.words.forEach { word ->
                card.addView(createWordItem(word))
            }
        }
        
        return card
    }
}
