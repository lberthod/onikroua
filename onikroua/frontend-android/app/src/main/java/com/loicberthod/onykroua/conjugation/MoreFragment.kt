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

class MoreFragment : Fragment() {
    
    private var language: String = "it"
    
    companion object {
        fun newInstance(lang: String) = MoreFragment().apply {
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
        val scrollView = inflater.inflate(R.layout.fragment_more, container, false)
        val moreContainer: LinearLayout = scrollView.findViewById(R.id.moreContainer)
        
        displayMore(moreContainer)
        
        return scrollView
    }
    
    private fun displayMore(container: LinearLayout) {
        container.removeAllViews()
        
        val data = GrammarData.getData(language)
        
        addPronounsSection(container, data)
        addExpressionsSection(container, data)
        addPrepositionsSection(container, data)
    }
    
    private fun addPronounsSection(container: LinearLayout, data: GrammarData.Grammar) {
        val card = createCard()
        addTitle(card, data.pronouns.title)
        
        addSubtitle(card, "Pronoms sujets")
        data.pronouns.subject.forEach { p ->
            addRow(card, p.pronoun, p.translation)
        }
        
        addSubtitle(card, "Pronoms COD")
        data.pronouns.direct.forEach { p ->
            addRow(card, p.pronoun, p.translation)
        }
        
        addSubtitle(card, "Pronoms COI")
        data.pronouns.indirect.forEach { p ->
            addRow(card, p.pronoun, p.translation)
        }
        
        container.addView(card)
        addSpacer(container)
    }
    
    private fun addExpressionsSection(container: LinearLayout, data: GrammarData.Grammar) {
        val card = createCard()
        addTitle(card, "💬 Expressions courantes")
        
        data.expressions.forEach { expr ->
            val row = LinearLayout(requireContext()).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(0, 8, 0, 8)
            }
            
            row.addView(TextView(requireContext()).apply {
                text = expr.phrase
                textSize = 16f
                setTextColor(android.graphics.Color.parseColor("#4F46E5"))
                setTypeface(null, android.graphics.Typeface.BOLD)
            })
            
            row.addView(TextView(requireContext()).apply {
                text = "→ ${expr.translation}"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#666666"))
                setPadding(8, 2, 0, 0)
            })
            
            if (expr.literal.isNotEmpty()) {
                row.addView(TextView(requireContext()).apply {
                    text = "(Littéral : ${expr.literal})"
                    textSize = 12f
                    setTextColor(android.graphics.Color.parseColor("#999999"))
                    setTypeface(null, android.graphics.Typeface.ITALIC)
                    setPadding(8, 2, 0, 0)
                })
            }
            
            card.addView(row)
        }
        
        container.addView(card)
        addSpacer(container)
    }
    
    private fun addPrepositionsSection(container: LinearLayout, data: GrammarData.Grammar) {
        val card = createCard()
        addTitle(card, "📍 Prépositions")
        
        data.prepositions.forEach { prep ->
            val row = LinearLayout(requireContext()).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(0, 12, 0, 12)
            }
            
            row.addView(TextView(requireContext()).apply {
                text = prep.prep
                textSize = 18f
                setTextColor(android.graphics.Color.parseColor("#EF4444"))
                setTypeface(null, android.graphics.Typeface.BOLD)
            })
            
            row.addView(TextView(requireContext()).apply {
                text = prep.usage
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#666666"))
                setPadding(8, 4, 0, 4)
            })
            
            row.addView(TextView(requireContext()).apply {
                text = "Ex: ${prep.examples.joinToString(", ")}"
                textSize = 13f
                setTextColor(android.graphics.Color.parseColor("#999999"))
                setPadding(8, 2, 0, 0)
            })
            
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
    
    private fun addTitle(container: LinearLayout, text: String) {
        container.addView(TextView(requireContext()).apply {
            this.text = text
            textSize = 20f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 0, 0, 16)
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
    
    private fun addRow(container: LinearLayout, left: String, right: String) {
        val row = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(8, 4, 8, 4)
        }
        
        row.addView(TextView(requireContext()).apply {
            text = left
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(120, LinearLayout.LayoutParams.WRAP_CONTENT)
        })
        
        row.addView(TextView(requireContext()).apply {
            text = right
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#666666"))
        })
        
        container.addView(row)
    }
    
    private fun addSpacer(container: LinearLayout) {
        container.addView(View(requireContext()).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                16
            )
        })
    }
}
