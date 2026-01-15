package com.loicberthod.onykroua.conjugation

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.loicberthod.onykroua.ConjugationActivity
import com.loicberthod.onykroua.R

class VerbsFragment : Fragment() {
    
    private var language: String = "it"
    private var expandedVerbId: String? = null
    private var selectedTense: String? = null
    
    companion object {
        fun newInstance(lang: String) = VerbsFragment().apply {
            arguments = Bundle().apply { putString("lang", lang) }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        language = arguments?.getString("lang") ?: "it"
    }
    
    private var currentFilter = "all"
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val scrollView = inflater.inflate(R.layout.fragment_verbs, container, false)
        val verbsContainer: LinearLayout = scrollView.findViewById(R.id.verbsContainer)
        val searchInput: EditText = scrollView.findViewById(R.id.searchInput)
        val filterChips: LinearLayout = scrollView.findViewById(R.id.filterChips)
        
        setupFilterChips(filterChips, verbsContainer, searchInput)
        displayVerbs(verbsContainer, "", currentFilter)
        
        searchInput.addTextChangedListener(object : android.text.TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                displayVerbs(verbsContainer, s.toString(), currentFilter)
            }
            override fun afterTextChanged(s: android.text.Editable?) {}
        })
        
        return scrollView
    }
    
    private fun setupFilterChips(container: LinearLayout, verbsContainer: LinearLayout, searchInput: EditText) {
        val filters = listOf(
            "all" to "Tous",
            "aux" to "Auxiliaires",
            "modal" to "Modaux",
            "movement" to "Mouvement"
        )
        
        filters.forEach { (key, label) ->
            val chip = Button(requireContext()).apply {
                text = label
                textSize = 14f
                setPadding(24, 12, 24, 12)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 16, 0)
                layoutParams = params
                
                setBackgroundColor(if (key == currentFilter) {
                    ContextCompat.getColor(context, android.R.color.holo_blue_light)
                } else {
                    ContextCompat.getColor(context, android.R.color.white)
                })
                
                setOnClickListener {
                    currentFilter = key
                    setupFilterChips(container, verbsContainer, searchInput)
                    displayVerbs(verbsContainer, searchInput.text.toString(), currentFilter)
                }
            }
            container.addView(chip)
        }
    }
    
    private fun displayVerbs(container: LinearLayout, search: String, filter: String) {
        container.removeAllViews()
        
        val verbs = com.loicberthod.onykroua.VerbData.getVerbsByLanguage(language)
        var filtered = verbs.filter { verb ->
            search.isEmpty() || 
            verb.verb.contains(search, true) || 
            verb.translation.contains(search, true)
        }
        
        if (filter != "all") {
            filtered = filtered.filter { verb ->
                val labels = getVerbLabels(verb.verb)
                when (filter) {
                    "aux" -> labels.contains("auxiliaire") || labels.contains("verbe clé")
                    "modal" -> labels.contains("modal")
                    "movement" -> labels.contains("mouvement")
                    else -> true
                }
            }
        }
        
        filtered.forEach { verb ->
            val card = createVerbCard(verb)
            container.addView(card)
        }
    }
    
    private fun getVerbLabels(verb: String): List<String> {
        val labels = mutableListOf<String>()
        val cleanVerb = verb.replace(" --", "").trim()
        
        if (language == "it") {
            if (listOf("essere", "avere").contains(cleanVerb)) labels.add("auxiliaire")
            if (listOf("potere", "volere", "dovere").contains(cleanVerb)) labels.add("modal")
            if (listOf("andare", "venire").contains(cleanVerb)) labels.add("mouvement")
        } else {
            if (listOf("ser", "estar", "haber").contains(cleanVerb)) labels.add("verbe clé")
            if (listOf("poder", "querer", "tener").contains(cleanVerb)) labels.add("modal")
            if (listOf("ir", "venir").contains(cleanVerb)) labels.add("mouvement")
        }
        
        return labels
    }
    
    private fun createVerbCard(verb: com.loicberthod.onykroua.Verb): LinearLayout {
        val card = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(24, 16, 24, 16)
            setBackgroundColor(ContextCompat.getColor(context, android.R.color.white))
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 16)
            layoutParams = params
            isClickable = true
            isFocusable = true
        }
        
        val header = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        val verbTitle = TextView(requireContext()).apply {
            text = verb.verb
            textSize = 22f
            setTextColor(ContextCompat.getColor(context, android.R.color.black))
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        }
        
        val speakerBtn = Button(requireContext()).apply {
            text = "🔊"
            textSize = 16f
            setPadding(16, 8, 16, 8)
            setOnClickListener {
                (activity as? ConjugationActivity)?.speak(verb.verb)
            }
        }
        
        header.addView(verbTitle)
        header.addView(speakerBtn)
        card.addView(header)
        
        val translation = TextView(requireContext()).apply {
            text = "→ ${verb.translation}"
            textSize = 16f
            setTextColor(ContextCompat.getColor(context, android.R.color.darker_gray))
            setPadding(0, 4, 0, 12)
        }
        card.addView(translation)
        
        val detailsContainer = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            visibility = if (expandedVerbId == verb.id) View.VISIBLE else View.GONE
        }
        
        val tenseNames = verb.conjugations.keys.toList()
        if (selectedTense == null && tenseNames.isNotEmpty()) {
            selectedTense = tenseNames[0]
        }
        
        val tenseTabsScroll = HorizontalScrollView(requireContext()).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            setPadding(0, 12, 0, 12)
        }
        
        val tenseTabsContainer = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.HORIZONTAL
        }
        
        val formsContainer = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, 8, 0, 8)
        }
        
        tenseNames.forEach { tense ->
            val tenseTab = Button(requireContext()).apply {
                text = tense
                textSize = 13f
                setPadding(20, 10, 20, 10)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 8, 0)
                layoutParams = params
                setBackgroundColor(if (tense == selectedTense) {
                    ContextCompat.getColor(context, android.R.color.holo_blue_light)
                } else {
                    ContextCompat.getColor(context, android.R.color.darker_gray)
                })
                setOnClickListener {
                    selectedTense = tense
                    updateFormsDisplay(formsContainer, verb)
                    updateTenseTabsColors(tenseTabsContainer, tenseNames)
                }
            }
            tenseTabsContainer.addView(tenseTab)
        }
        
        tenseTabsScroll.addView(tenseTabsContainer)
        detailsContainer.addView(tenseTabsScroll)
        
        selectedTense?.let { tense ->
            verb.conjugations[tense]?.forEach { (pronoun, conjugation) ->
                val row = LinearLayout(requireContext()).apply {
                    orientation = LinearLayout.HORIZONTAL
                    setPadding(0, 4, 0, 4)
                }
                
                row.addView(TextView(requireContext()).apply {
                    text = pronoun
                    textSize = 14f
                    setTextColor(ContextCompat.getColor(context, android.R.color.darker_gray))
                    layoutParams = LinearLayout.LayoutParams(120, LinearLayout.LayoutParams.WRAP_CONTENT)
                })
                
                row.addView(TextView(requireContext()).apply {
                    text = conjugation
                    textSize = 14f
                    setTextColor(ContextCompat.getColor(context, android.R.color.black))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
                })
                
                row.addView(Button(requireContext()).apply {
                    text = "🔊"
                    textSize = 12f
                    setPadding(8, 4, 8, 4)
                    setOnClickListener {
                        (activity as? ConjugationActivity)?.speak("$pronoun $conjugation")
                    }
                })
                
                formsContainer.addView(row)
            }
        }
        
        detailsContainer.addView(formsContainer)
        
        card.addView(detailsContainer)
        
        card.setOnClickListener {
            val wasExpanded = expandedVerbId == verb.id
            expandedVerbId = if (wasExpanded) null else verb.id
            if (!wasExpanded) {
                selectedTense = verb.conjugations.keys.firstOrNull()
            }
            detailsContainer.visibility = if (expandedVerbId == verb.id) View.VISIBLE else View.GONE
        }
        
        return card
    }
    
    private fun updateFormsDisplay(formsContainer: LinearLayout, verb: com.loicberthod.onykroua.Verb) {
        formsContainer.removeAllViews()
        
        selectedTense?.let { tense ->
            verb.conjugations[tense]?.forEach { (pronoun, conjugation) ->
                val row = LinearLayout(requireContext()).apply {
                    orientation = LinearLayout.HORIZONTAL
                    setPadding(0, 4, 0, 4)
                }
                
                row.addView(TextView(requireContext()).apply {
                    text = pronoun
                    textSize = 14f
                    setTextColor(ContextCompat.getColor(context, android.R.color.darker_gray))
                    layoutParams = LinearLayout.LayoutParams(120, LinearLayout.LayoutParams.WRAP_CONTENT)
                })
                
                row.addView(TextView(requireContext()).apply {
                    text = conjugation
                    textSize = 14f
                    setTextColor(ContextCompat.getColor(context, android.R.color.black))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
                })
                
                row.addView(Button(requireContext()).apply {
                    text = "🔊"
                    textSize = 12f
                    setPadding(8, 4, 8, 4)
                    setOnClickListener {
                        (activity as? ConjugationActivity)?.speak("$pronoun $conjugation")
                    }
                })
                
                formsContainer.addView(row)
            }
        }
    }
    
    private fun updateTenseTabsColors(tabsContainer: LinearLayout, tenseNames: List<String>) {
        for (i in 0 until tabsContainer.childCount) {
            val button = tabsContainer.getChildAt(i) as? Button
            val tense = tenseNames.getOrNull(i)
            button?.setBackgroundColor(if (tense == selectedTense) {
                ContextCompat.getColor(requireContext(), android.R.color.holo_blue_light)
            } else {
                ContextCompat.getColor(requireContext(), android.R.color.darker_gray)
            })
        }
    }
}
