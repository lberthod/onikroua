package com.loicberthod.onykroua.vocabulary

import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.loicberthod.onykroua.R
import com.loicberthod.onykroua.VocabularyActivity

class DictionaryFragment : Fragment() {
    
    private var language: String = "it"
    private lateinit var searchInput: EditText
    private lateinit var dictionaryContainer: LinearLayout
    private var allWords: Map<Char, List<VocabWord>> = emptyMap()
    
    companion object {
        fun newInstance(lang: String) = DictionaryFragment().apply {
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
        val view = inflater.inflate(R.layout.fragment_dictionary, container, false)
        
        searchInput = view.findViewById(R.id.searchInput)
        dictionaryContainer = view.findViewById(R.id.dictionaryContainer)
        
        allWords = VocabularyData.getWordsSortedAlphabetically(language)
        
        searchInput.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                filterWords(s.toString())
            }
        })
        
        displayDictionary()
        
        return view
    }
    
    private fun displayDictionary() {
        dictionaryContainer.removeAllViews()
        
        allWords.keys.sorted().forEach { letter ->
            val words = allWords[letter] ?: emptyList()
            if (words.isNotEmpty()) {
                dictionaryContainer.addView(createLetterHeader(letter))
                words.forEach { word ->
                    dictionaryContainer.addView(createWordCard(word))
                }
            }
        }
    }
    
    private fun filterWords(query: String) {
        dictionaryContainer.removeAllViews()
        
        if (query.trim().isEmpty()) {
            displayDictionary()
            return
        }
        
        val filtered = allWords.values.flatten().filter { word ->
            word.word.lowercase().contains(query.lowercase()) ||
            word.translation.lowercase().contains(query.lowercase())
        }
        
        if (filtered.isEmpty()) {
            dictionaryContainer.addView(TextView(requireContext()).apply {
                text = "Aucun résultat trouvé"
                textSize = 16f
                setPadding(32, 32, 32, 32)
                setTextColor(android.graphics.Color.parseColor("#999999"))
            })
        } else {
            filtered.forEach { word ->
                dictionaryContainer.addView(createWordCard(word))
            }
        }
    }
    
    private fun createLetterHeader(letter: Char): View {
        return TextView(requireContext()).apply {
            text = letter.toString()
            textSize = 24f
            setTextColor(android.graphics.Color.parseColor("#4F46E5"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(24, 24, 24, 12)
            setBackgroundColor(android.graphics.Color.parseColor("#F0F4FF"))
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 16, 0, 0)
            layoutParams = params
        }
    }
    
    private fun createWordCard(word: VocabWord): LinearLayout {
        val container = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        val card = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(24, 16, 24, 16)
            setBackgroundColor(android.graphics.Color.WHITE)
            isClickable = true
            isFocusable = true
            setOnClickListener {
                (activity as? VocabularyActivity)?.speak(word.word)
            }
        }
        
        val headerRow = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        headerRow.addView(TextView(requireContext()).apply {
            text = "${word.categoryIcon} ${word.word}"
            textSize = 18f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        })
        
        headerRow.addView(TextView(requireContext()).apply {
            text = "🔊"
            textSize = 16f
            setPadding(8, 0, 0, 0)
        })
        
        card.addView(headerRow)
        
        card.addView(TextView(requireContext()).apply {
            text = word.translation
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#666666"))
            setPadding(0, 4, 0, 0)
        })
        
        if (!word.example.isNullOrEmpty()) {
            val exampleContainer = LinearLayout(requireContext()).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(0, 8, 0, 4)
                isClickable = true
                setOnClickListener {
                    (activity as? VocabularyActivity)?.speak(word.example)
                }
            }
            
            exampleContainer.addView(TextView(requireContext()).apply {
                text = "💡 ${word.example}"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#4F46E5"))
                setTypeface(null, android.graphics.Typeface.ITALIC)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
            })
            
            exampleContainer.addView(TextView(requireContext()).apply {
                text = "🔊"
                textSize = 12f
                setPadding(8, 0, 0, 0)
            })
            
            card.addView(exampleContainer)
            
            if (!word.exampleTranslation.isNullOrEmpty()) {
                card.addView(TextView(requireContext()).apply {
                    text = word.exampleTranslation
                    textSize = 13f
                    setTextColor(android.graphics.Color.parseColor("#999999"))
                    setTypeface(null, android.graphics.Typeface.ITALIC)
                    setPadding(0, 0, 0, 0)
                })
            }
        }
        
        container.addView(card)
        
        val separator = View(requireContext()).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                1
            )
            setBackgroundColor(android.graphics.Color.parseColor("#15000000"))
        }
        container.addView(separator)
        
        return container
    }
}
