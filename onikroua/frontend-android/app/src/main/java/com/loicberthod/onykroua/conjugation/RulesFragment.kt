package com.loicberthod.onykroua.conjugation

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.loicberthod.onykroua.R

class RulesFragment : Fragment() {
    
    private var language: String = "it"
    
    companion object {
        fun newInstance(lang: String) = RulesFragment().apply {
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
        val scrollView = inflater.inflate(R.layout.fragment_rules, container, false)
        val contentContainer: LinearLayout = scrollView.findViewById(R.id.rulesContent)
        
        displayRules(contentContainer)
        
        return scrollView
    }
    
    private fun displayRules(container: LinearLayout) {
        container.removeAllViews()
        
        val data = GrammarData.getData(language)
        
        addIntroSection(container, data)
        addGroupsSection(container, data)
        addAuxiliariesSection(container, data)
        if (language == "es") addSerEstarSection(container, data)
        addIrregularsSection(container, data)
    }
    
    private fun addIntroSection(container: LinearLayout, data: GrammarData.Grammar) {
        val card = createCard()
        addTitle(card, data.intro.title, 20f)
        addText(card, data.intro.description)
        container.addView(card)
        addSpacer(container)
    }
    
    private fun addGroupsSection(container: LinearLayout, data: GrammarData.Grammar) {
        addSectionTitle(container, "📖 Les trois groupes de verbes")
        
        data.groups.forEach { group ->
            val card = createCard()
            addTitle(card, group.name, 18f, "#4F46E5")
            addText(card, group.description)
            
            addSubtitle(card, "Exemples :")
            group.examples.forEach { addBullet(card, it) }
            
            addSubtitle(card, "Terminaisons au présent :")
            group.endings["present"]?.forEach { (pronoun, ending) ->
                addConjugationRow(card, pronoun, ending)
            }
            
            addSubtitle(card, "Modèle : ${group.conjugation.verb}")
            group.conjugation.forms.forEach { (pronoun, form) ->
                addConjugationRow(card, pronoun, form, true)
            }
            
            container.addView(card)
            addSpacer(container)
        }
    }
    
    private fun addAuxiliariesSection(container: LinearLayout, data: GrammarData.Grammar) {
        addSectionTitle(container, "🔑 Les verbes auxiliaires essentiels")
        
        data.auxiliaries.forEach { aux ->
            val card = createCard()
            addTitle(card, aux.verb, 18f, "#10B981")
            addText(card, aux.usage)
            
            aux.forms.forEach { (pronoun, form) ->
                addConjugationRow(card, pronoun, form, true)
            }
            
            addSubtitle(card, "Exemples :")
            aux.examples.forEach { addBullet(card, it) }
            
            container.addView(card)
            addSpacer(container)
        }
    }
    
    private fun addSerEstarSection(container: LinearLayout, data: GrammarData.Grammar) {
        if (data.serEstar == null) return
        
        val card = createCard()
        addTitle(card, data.serEstar.title, 18f, "#EF4444")
        
        data.serEstar.rules.forEach { rule ->
            addSubtitle(card, rule.use)
            rule.cases.forEach { addBullet(card, it) }
            addText(card, "Ex: ${rule.examples.joinToString(", ")}", 14f, "#666666")
            addSpacer(card, 8)
        }
        
        container.addView(card)
        addSpacer(container)
    }
    
    private fun addIrregularsSection(container: LinearLayout, data: GrammarData.Grammar) {
        addSectionTitle(container, "⚠️ Verbes irréguliers courants")
        
        val card = createCard()
        data.irregulars.forEach { irr ->
            val row = LinearLayout(requireContext()).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(0, 8, 0, 8)
            }
            
            addTextToRow(row, irr.verb, 1f, true)
            addTextToRow(row, irr.meaning, 1f)
            addTextToRow(row, irr.forms, 2f, false, 12f)
            
            card.addView(row)
        }
        
        container.addView(card)
    }
    
    private fun createCard(): LinearLayout {
        return LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(24, 24, 24, 24)
            setBackgroundColor(ContextCompat.getColor(context, android.R.color.white))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
    }
    
    private fun addTitle(container: LinearLayout, text: String, size: Float = 18f, color: String = "#333333") {
        container.addView(TextView(requireContext()).apply {
            this.text = text
            textSize = size
            setTextColor(android.graphics.Color.parseColor(color))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 0, 0, 16)
        })
    }
    
    private fun addSectionTitle(container: LinearLayout, text: String) {
        container.addView(TextView(requireContext()).apply {
            this.text = text
            textSize = 20f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(16, 16, 16, 8)
        })
    }
    
    private fun addSubtitle(container: LinearLayout, text: String) {
        container.addView(TextView(requireContext()).apply {
            this.text = text
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#4F46E5"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 12, 0, 8)
        })
    }
    
    private fun addText(container: LinearLayout, text: String, size: Float = 14f, color: String = "#666666") {
        container.addView(TextView(requireContext()).apply {
            this.text = text
            textSize = size
            setTextColor(android.graphics.Color.parseColor(color))
            setPadding(0, 0, 0, 8)
        })
    }
    
    private fun addBullet(container: LinearLayout, text: String) {
        container.addView(TextView(requireContext()).apply {
            this.text = "• $text"
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#666666"))
            setPadding(16, 4, 0, 4)
        })
    }
    
    private fun addConjugationRow(container: LinearLayout, pronoun: String, form: String, bold: Boolean = false) {
        val row = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, 4, 0, 4)
        }
        
        row.addView(TextView(requireContext()).apply {
            text = pronoun
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#999999"))
            layoutParams = LinearLayout.LayoutParams(150, LinearLayout.LayoutParams.WRAP_CONTENT)
        })
        
        row.addView(TextView(requireContext()).apply {
            text = form
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor(if (bold) "#333333" else "#666666"))
            if (bold) setTypeface(null, android.graphics.Typeface.BOLD)
        })
        
        container.addView(row)
    }
    
    private fun addTextToRow(row: LinearLayout, text: String, weight: Float, bold: Boolean = false, size: Float = 14f) {
        row.addView(TextView(requireContext()).apply {
            this.text = text
            textSize = size
            setTextColor(android.graphics.Color.parseColor(if (bold) "#333333" else "#666666"))
            if (bold) setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, weight)
            setPadding(8, 0, 8, 0)
        })
    }
    
    private fun addSpacer(container: LinearLayout, height: Int = 16) {
        container.addView(View(requireContext()).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                height
            )
        })
    }
}
