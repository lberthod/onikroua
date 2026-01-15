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
import kotlin.random.Random

class PracticeFragment : Fragment() {
    
    private var language: String = "it"
    private var score = 0
    private var total = 0
    private var streak = 0
    private var currentVerb: String? = null
    private var currentPronoun: String? = null
    private var correctAnswer: String = ""
    private var practiceMode = "choice"
    private var selectedTense = "present"
    
    private lateinit var scoreText: TextView
    private lateinit var totalText: TextView
    private lateinit var streakText: TextView
    private lateinit var questionText: TextView
    private lateinit var choicesContainer: LinearLayout
    private lateinit var writeContainer: LinearLayout
    private lateinit var writeInput: EditText
    private lateinit var submitButton: Button
    private lateinit var resultText: TextView
    private lateinit var nextButton: Button
    private lateinit var modeButtons: LinearLayout
    private lateinit var tenseButtons: LinearLayout
    
    companion object {
        fun newInstance(lang: String) = PracticeFragment().apply {
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
        val view = inflater.inflate(R.layout.fragment_practice, container, false)
        
        scoreText = view.findViewById(R.id.scoreText)
        totalText = view.findViewById(R.id.totalText)
        streakText = view.findViewById(R.id.streakText)
        questionText = view.findViewById(R.id.questionText)
        choicesContainer = view.findViewById(R.id.choicesContainer)
        writeContainer = view.findViewById(R.id.writeContainer)
        writeInput = view.findViewById(R.id.writeInput)
        submitButton = view.findViewById(R.id.submitButton)
        resultText = view.findViewById(R.id.resultText)
        nextButton = view.findViewById(R.id.nextButton)
        modeButtons = view.findViewById(R.id.modeButtons)
        tenseButtons = view.findViewById(R.id.tenseButtons)
        
        setupModeButtons()
        setupTenseButtons()
        
        nextButton.setOnClickListener {
            generateQuestion()
        }
        
        submitButton.setOnClickListener {
            checkAnswer(writeInput.text.toString())
        }
        
        generateQuestion()
        
        return view
    }
    
    private fun setupModeButtons() {
        modeButtons.removeAllViews()
        val modes = listOf("choice" to "🎯 Choix multiples", "write" to "✍️ Écriture")
        
        modes.forEach { (mode, label) ->
            val button = Button(requireContext()).apply {
                text = label
                textSize = 14f
                setPadding(24, 12, 24, 12)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 16, 0)
                layoutParams = params
                setBackgroundColor(if (mode == practiceMode) {
                    ContextCompat.getColor(context, android.R.color.holo_blue_light)
                } else {
                    ContextCompat.getColor(context, android.R.color.white)
                })
                setOnClickListener {
                    practiceMode = mode
                    setupModeButtons()
                    generateQuestion()
                }
            }
            modeButtons.addView(button)
        }
    }
    
    private fun setupTenseButtons() {
        tenseButtons.removeAllViews()
        val tenses = listOf(
            "present" to if (language == "it") "Presente" else "Presente",
            "past" to if (language == "it") "Passato prossimo" else "Pretérito perfecto"
        )
        
        tenses.forEach { (tense, label) ->
            val button = Button(requireContext()).apply {
                text = label
                textSize = 14f
                setPadding(24, 12, 24, 12)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 16, 0)
                layoutParams = params
                setBackgroundColor(if (tense == selectedTense) {
                    ContextCompat.getColor(context, android.R.color.holo_blue_light)
                } else {
                    ContextCompat.getColor(context, android.R.color.white)
                })
                setOnClickListener {
                    selectedTense = tense
                    score = 0
                    total = 0
                    streak = 0
                    updateStats()
                    setupTenseButtons()
                    generateQuestion()
                }
            }
            tenseButtons.addView(button)
        }
    }
    
    private fun generateQuestion() {
        resultText.visibility = View.GONE
        nextButton.visibility = View.GONE
        choicesContainer.removeAllViews()
        writeInput.text.clear()
        
        if (practiceMode == "choice") {
            choicesContainer.visibility = View.VISIBLE
            writeContainer.visibility = View.GONE
        } else {
            choicesContainer.visibility = View.GONE
            writeContainer.visibility = View.VISIBLE
        }
        
        val tenseKey = when {
            selectedTense == "present" && language == "it" -> "Présent"
            selectedTense == "present" && language == "es" -> "Presente"
            selectedTense == "past" && language == "it" -> "Passato prossimo"
            else -> "Pretérito perfecto"
        }
        
        val verbs = com.loicberthod.onykroua.VerbData.getVerbsByLanguage(language).filter { verb ->
            verb.conjugations.containsKey(tenseKey)
        }
        
        if (verbs.isEmpty()) {
            questionText.text = "Aucun verbe disponible pour ce temps"
            return
        }
        
        val verb = verbs.random()
        val forms = verb.conjugations[tenseKey] ?: return
        val pronouns = forms.keys.toList()
        
        currentVerb = verb.verb
        currentPronoun = pronouns.random()
        correctAnswer = forms[currentPronoun] ?: ""
        
        val langLabel = if (language == "it") "italien" else "espagnol"
        val tenseName = if (selectedTense == "present") "présent" else tenseKey
        questionText.text = "Conjuguez \"${verb.verb}\" ($langLabel)\navec le pronom \"${currentPronoun}\" au $tenseName"
        
        if (practiceMode == "choice") {
            val wrongAnswers = forms.values.filter { it != correctAnswer }.shuffled().take(3)
            val choicesList = mutableListOf(correctAnswer)
            choicesList.addAll(wrongAnswers)
            val choices = choicesList.shuffled()
            
            choices.forEach { choice ->
                val button = Button(requireContext()).apply {
                    text = choice
                    textSize = 16f
                    layoutParams = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    ).apply {
                        setMargins(0, 8, 0, 8)
                    }
                    setOnClickListener {
                        checkAnswer(choice)
                    }
                }
                choicesContainer.addView(button)
            }
        }
    }
    
    private fun checkAnswer(answer: String) {
        if (answer.trim().isEmpty()) return
        
        total++
        val isCorrect = answer.trim().lowercase() == correctAnswer.trim().lowercase()
        
        if (isCorrect) {
            score++
            streak++
            resultText.text = "✅ Correct ! $correctAnswer"
            resultText.setTextColor(android.graphics.Color.parseColor("#10B981"))
            (activity as? ConjugationActivity)?.speak(correctAnswer)
        } else {
            streak = 0
            resultText.text = "❌ Incorrect. La bonne réponse est : $correctAnswer"
            resultText.setTextColor(android.graphics.Color.parseColor("#EF4444"))
        }
        
        updateStats()
        resultText.visibility = View.VISIBLE
        nextButton.visibility = View.VISIBLE
        
        for (i in 0 until choicesContainer.childCount) {
            choicesContainer.getChildAt(i).isEnabled = false
        }
        submitButton.isEnabled = false
    }
    
    private fun updateStats() {
        scoreText.text = "Score: $score"
        totalText.text = "Total: $total"
        streakText.text = "🔥 $streak"
    }
}
