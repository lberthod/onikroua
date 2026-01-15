package com.loicberthod.onykroua.vocabulary

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.loicberthod.onykroua.R
import com.loicberthod.onykroua.VocabularyActivity

class VocabularyPracticeFragment : Fragment() {
    
    private var language: String = "it"
    private var practiceMode = "choice" // choice, write, listen
    private var practiceDirection = "toFr" // toFr, fromFr
    private var score = 0
    private var total = 0
    private var streak = 0
    private var currentWord: VocabWord? = null
    private var correctAnswer: String = ""
    
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
    private lateinit var directionButtons: LinearLayout
    
    companion object {
        fun newInstance(lang: String) = VocabularyPracticeFragment().apply {
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
        val view = inflater.inflate(R.layout.fragment_vocabulary_practice, container, false)
        
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
        directionButtons = view.findViewById(R.id.directionButtons)
        
        setupModeButtons()
        setupDirectionButtons()
        
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
        val modes = listOf(
            "choice" to "🎯",
            "write" to "✍️",
            "listen" to "👂"
        )
        
        modes.forEach { (mode, label) ->
            val button = Button(requireContext()).apply {
                text = label
                textSize = 16f
                setPadding(8, 8, 8, 8)
                val params = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
                params.setMargins(0, 0, 4, 0)
                layoutParams = params
                setBackgroundColor(if (mode == practiceMode) {
                    ContextCompat.getColor(context, android.R.color.holo_blue_light)
                } else {
                    ContextCompat.getColor(context, android.R.color.darker_gray)
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
    
    private fun setupDirectionButtons() {
        directionButtons.removeAllViews()
        val directions = listOf(
            "toFr" to "→🇫🇷",
            "fromFr" to "🇫🇷→"
        )
        
        directions.forEach { (dir, label) ->
            val button = Button(requireContext()).apply {
                text = label
                textSize = 12f
                setPadding(8, 8, 8, 8)
                val params = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
                params.setMargins(0, 0, 4, 0)
                layoutParams = params
                setBackgroundColor(if (dir == practiceDirection) {
                    ContextCompat.getColor(context, android.R.color.holo_orange_light)
                } else {
                    ContextCompat.getColor(context, android.R.color.darker_gray)
                })
                setOnClickListener {
                    practiceDirection = dir
                    setupDirectionButtons()
                    generateQuestion()
                }
            }
            directionButtons.addView(button)
        }
    }
    
    private fun generateQuestion() {
        resultText.visibility = View.GONE
        nextButton.visibility = View.GONE
        choicesContainer.removeAllViews()
        writeInput.text.clear()
        submitButton.isEnabled = true
        
        val allWords = VocabularyData.getAllWords(language)
        if (allWords.isEmpty()) {
            questionText.text = "Aucun mot disponible"
            return
        }
        
        currentWord = allWords.random()
        
        when {
            practiceMode == "choice" && practiceDirection == "toFr" -> {
                choicesContainer.visibility = View.VISIBLE
                writeContainer.visibility = View.GONE
                correctAnswer = currentWord!!.translation
                questionText.text = "Que signifie \"${currentWord!!.word}\" ?"
                generateChoices(currentWord!!.translation, allWords.map { it.translation })
            }
            practiceMode == "choice" && practiceDirection == "fromFr" -> {
                choicesContainer.visibility = View.VISIBLE
                writeContainer.visibility = View.GONE
                correctAnswer = currentWord!!.word
                questionText.text = "Comment dit-on \"${currentWord!!.translation}\" ?"
                generateChoices(currentWord!!.word, allWords.map { it.word })
            }
            practiceMode == "write" && practiceDirection == "toFr" -> {
                choicesContainer.visibility = View.GONE
                writeContainer.visibility = View.VISIBLE
                correctAnswer = currentWord!!.translation
                questionText.text = "Traduisez \"${currentWord!!.word}\" en français"
            }
            practiceMode == "write" && practiceDirection == "fromFr" -> {
                choicesContainer.visibility = View.GONE
                writeContainer.visibility = View.VISIBLE
                correctAnswer = currentWord!!.word
                val langName = if (language == "it") "italien" else "espagnol"
                questionText.text = "Traduisez \"${currentWord!!.translation}\" en $langName"
            }
            practiceMode == "listen" -> {
                choicesContainer.visibility = View.VISIBLE
                writeContainer.visibility = View.GONE
                correctAnswer = currentWord!!.translation
                questionText.text = "🔊 Écoutez et choisissez la traduction"
                
                // Ajouter bouton de réécoute
                val replayButton = Button(requireContext()).apply {
                    text = "🔊 Réécouter"
                    textSize = 14f
                    setPadding(16, 12, 16, 12)
                    setBackgroundColor(android.graphics.Color.parseColor("#3498DB"))
                    setTextColor(android.graphics.Color.WHITE)
                    setOnClickListener {
                        (activity as? VocabularyActivity)?.speak(currentWord!!.word)
                    }
                }
                choicesContainer.addView(replayButton, 0)
                
                (activity as? VocabularyActivity)?.speak(currentWord!!.word)
                generateChoices(currentWord!!.translation, allWords.map { it.translation })
            }
        }
    }
    
    private fun generateChoices(correct: String, allOptions: List<String>) {
        val wrong = allOptions.filter { it != correct }.shuffled().take(3)
        val choices = (listOf(correct) + wrong).shuffled()
        
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
    
    private fun checkAnswer(answer: String) {
        if (answer.trim().isEmpty()) return
        
        total++
        val isCorrect = answer.trim().lowercase() == correctAnswer.trim().lowercase()
        
        if (isCorrect) {
            score++
            streak++
            // Afficher le mot dans la langue cible
            val wordDisplay = if (practiceDirection == "toFr") {
                "✅ Correct ! ${currentWord!!.word} = $correctAnswer"
            } else {
                "✅ Correct ! $correctAnswer = ${currentWord!!.translation}"
            }
            resultText.text = wordDisplay
            resultText.setTextColor(android.graphics.Color.parseColor("#10B981"))
            // Prononcer le mot dans la langue cible
            if (practiceDirection == "toFr") {
                (activity as? VocabularyActivity)?.speak(currentWord!!.word)
            } else {
                (activity as? VocabularyActivity)?.speak(currentWord!!.word)
            }
        } else {
            streak = 0
            // Afficher le mot dans la langue cible
            val wordDisplay = if (practiceDirection == "toFr") {
                "❌ Incorrect. ${currentWord!!.word} = $correctAnswer"
            } else {
                "❌ Incorrect. $correctAnswer = ${currentWord!!.translation}"
            }
            resultText.text = wordDisplay
            resultText.setTextColor(android.graphics.Color.parseColor("#EF4444"))
            // Prononcer le mot correct
            (activity as? VocabularyActivity)?.speak(currentWord!!.word)
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
        scoreText.text = score.toString()
        totalText.text = total.toString()
        streakText.text = "🔥$streak"
    }
}
