package com.loicberthod.onykroua.feed

import android.content.Context
import android.speech.tts.TextToSpeech
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.loicberthod.onykroua.R
import com.loicberthod.onykroua.utils.VocabularyFormatter
import android.view.Gravity

class FeedPagerAdapter(
    private val context: Context,
    private val items: List<FeedItem>,
    private val tts: TextToSpeech?,
    private val onLike: (String, Boolean) -> Unit,
    private val onBookmark: (String, Boolean) -> Unit
) : RecyclerView.Adapter<FeedPagerAdapter.FeedViewHolder>() {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): FeedViewHolder {
        val view = LayoutInflater.from(context).inflate(R.layout.item_feed_card, parent, false)
        return FeedViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: FeedViewHolder, position: Int) {
        holder.bind(items[position])
    }
    
    override fun getItemCount() = items.size
    
    inner class FeedViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val cardContainer: LinearLayout = itemView.findViewById(R.id.cardContainer)
        private val likeButton: ImageButton = itemView.findViewById(R.id.likeButton)
        private val likeCount: TextView = itemView.findViewById(R.id.likeCount)
        private val bookmarkButton: ImageButton = itemView.findViewById(R.id.bookmarkButton)
        private val shareButton: ImageButton = itemView.findViewById(R.id.shareButton)
        
        fun bind(item: FeedItem) {
            cardContainer.removeAllViews()
            
            when (item) {
                is GrammarFeedItem -> createGrammarCard(item)
                is VocabularyFeedItem -> createVocabularyCard(item)
                is PhoneticFeedItem -> createPhoneticCard(item)
                is ConjugationFeedItem -> createConjugationCard(item)
                is QuizFeedItem -> createQuizCard(item)
                is FlashcardVocabularyFeedItem -> createFlashcardCard(item)
                is FlashcardPhoneticFeedItem -> createFlashcardPhoneticCard(item)
                is QuickChallengeFeedItem -> createQuickChallengeCard(item)
                is ConjugationQuizFeedItem -> createConjugationQuizCard(item)
                is EmojiFeedItem -> createEmojiCard(item)
            }
            
            setupSocialActions(item)
        }
        
        private fun createGrammarCard(item: GrammarFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.parseColor("#F8F9FF"))
            }
            
            card.addView(TextView(context).apply {
                text = "📖 Grammaire"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#4F46E5"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            card.addView(TextView(context).apply {
                text = item.title
                textSize = 28f
                setTextColor(ContextCompat.getColor(context, android.R.color.black))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            card.addView(TextView(context).apply {
                text = getDifficultyBadge(item.difficulty)
                textSize = 12f
                setPadding(16, 6, 16, 6)
                setTextColor(android.graphics.Color.WHITE)
                setBackgroundColor(getDifficultyColor(item.difficulty))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 16)
                layoutParams = params
            })
            
            card.addView(TextView(context).apply {
                text = item.rule
                textSize = 18f
                setTextColor(ContextCompat.getColor(context, android.R.color.holo_blue_dark))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 12)
            })
            
            card.addView(TextView(context).apply {
                text = item.explanation
                textSize = 16f
                setTextColor(android.graphics.Color.parseColor("#666666"))
                setPadding(0, 0, 0, 16)
            })
            
            card.addView(TextView(context).apply {
                text = "📝 Exemples:"
                textSize = 15f
                setTextColor(ContextCompat.getColor(context, android.R.color.black))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 8)
            })
            
            item.examples.forEach { example ->
                card.addView(TextView(context).apply {
                    text = "• $example"
                    textSize = 15f
                    setTextColor(android.graphics.Color.parseColor("#333333"))
                    setPadding(12, 4, 0, 4)
                })
            }
            
            cardContainer.addView(card)
        }
        
        private fun createVocabularyCard(item: VocabularyFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.parseColor("#FFF8F0"))
            }
            
            val vocabHeaderRow = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(0, 0, 0, 16)
            }
            
            vocabHeaderRow.addView(TextView(context).apply {
                text = "📚 Vocabulaire"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#F39C12"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
            })
            
            val formattedWord = VocabularyFormatter.formatWord(item.word)
            
            vocabHeaderRow.addView(ImageButton(context).apply {
                setImageResource(android.R.drawable.ic_lock_silent_mode_off)
                setBackgroundColor(android.graphics.Color.parseColor("#F39C12"))
                setPadding(12, 12, 12, 12)
                setOnClickListener {
                    tts?.speak(formattedWord, TextToSpeech.QUEUE_FLUSH, null, null)
                }
            })
            
            card.addView(vocabHeaderRow)
            
            val wordRow = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(0, 8, 0, 16)
                setBackgroundColor(android.graphics.Color.WHITE)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 16)
                layoutParams = params
            }
            
            wordRow.addView(TextView(context).apply {
                text = formattedWord
                textSize = 36f
                setTextColor(android.graphics.Color.parseColor("#2C3E50"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(20, 20, 20, 20)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
            })
            
            card.addView(wordRow)
            
            card.addView(TextView(context).apply {
                text = "→ ${item.translation}"
                textSize = 24f
                setTextColor(android.graphics.Color.parseColor("#666666"))
                setPadding(0, 0, 0, 24)
            })
            
            card.addView(TextView(context).apply {
                text = "Exemple:"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#999999"))
                setPadding(0, 0, 0, 8)
            })
            
            card.addView(TextView(context).apply {
                text = item.example
                textSize = 16f
                setTextColor(android.graphics.Color.parseColor("#333333"))
                setTypeface(null, android.graphics.Typeface.ITALIC)
                setPadding(12, 0, 0, 4)
            })
            
            card.addView(TextView(context).apply {
                text = item.exampleTranslation
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#666666"))
                setPadding(12, 0, 0, 0)
            })
            
            cardContainer.addView(card)
        }
        
        private fun createPhoneticCard(item: PhoneticFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.parseColor("#F5F0FF"))
            }
            
            card.addView(TextView(context).apply {
                text = "🎵 Phonétique"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#6C3FB5"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            val headerRow = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(24, 24, 24, 24)
                setBackgroundColor(android.graphics.Color.parseColor("#6C3FB5"))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 16)
                layoutParams = params
            }
            
            headerRow.addView(TextView(context).apply {
                text = item.graphie
                textSize = 44f
                setTextColor(android.graphics.Color.WHITE)
                setTypeface(null, android.graphics.Typeface.BOLD)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
            })
            
            headerRow.addView(TextView(context).apply {
                text = item.phonetic
                textSize = 32f
                setTextColor(android.graphics.Color.parseColor("#FFD700"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setShadowLayer(2f, 0f, 0f, android.graphics.Color.parseColor("#000000"))
            })
            
            card.addView(headerRow)
            
            card.addView(TextView(context).apply {
                text = item.description
                textSize = 16f
                setTextColor(android.graphics.Color.parseColor("#666666"))
                setPadding(0, 0, 0, 16)
            })
            
            card.addView(TextView(context).apply {
                text = "📝 Exemples:"
                textSize = 15f
                setTextColor(ContextCompat.getColor(context, android.R.color.black))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 8)
            })
            
            item.examples.forEach { example ->
                val exampleRow = LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    setPadding(16, 12, 16, 12)
                    setBackgroundColor(android.graphics.Color.WHITE)
                    val params = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                    params.setMargins(0, 8, 0, 8)
                    layoutParams = params
                    elevation = 2f
                }
                
                exampleRow.addView(TextView(context).apply {
                    text = example
                    textSize = 18f
                    setTextColor(android.graphics.Color.parseColor("#2C3E50"))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(
                        0,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                        1f
                    )
                })
                
                exampleRow.addView(ImageButton(context).apply {
                    setImageResource(android.R.drawable.ic_lock_silent_mode_off)
                    setBackgroundColor(android.graphics.Color.parseColor("#6C3FB5"))
                    setPadding(16, 16, 16, 16)
                    elevation = 2f
                    setOnClickListener {
                        tts?.speak(example, TextToSpeech.QUEUE_FLUSH, null, null)
                    }
                })
                
                card.addView(exampleRow)
            }
            
            item.tips?.let { tips ->
                card.addView(TextView(context).apply {
                    text = "💡 $tips"
                    textSize = 15f
                    setTextColor(android.graphics.Color.parseColor("#1E3A8A"))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    setPadding(20, 20, 20, 20)
                    setBackgroundColor(android.graphics.Color.parseColor("#DBEAFE"))
                    val params = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                    params.setMargins(0, 16, 0, 0)
                    layoutParams = params
                    elevation = 2f
                })
            }
            
            cardContainer.addView(card)
        }
        
        private fun createConjugationCard(item: ConjugationFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.WHITE)
            }
            
            val conjugHeaderRow = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(0, 0, 0, 16)
            }
            
            conjugHeaderRow.addView(TextView(context).apply {
                text = "✏️ Conjugaison"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#E74C3C"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
            })
            
            conjugHeaderRow.addView(ImageButton(context).apply {
                setImageResource(android.R.drawable.ic_lock_silent_mode_off)
                setBackgroundColor(android.graphics.Color.parseColor("#E74C3C"))
                setPadding(12, 12, 12, 12)
                setOnClickListener {
                    val textToSpeak = "${item.verb} ${item.tense}"
                    tts?.speak(textToSpeak, TextToSpeech.QUEUE_FLUSH, null, null)
                }
            })
            
            card.addView(conjugHeaderRow)
            
            val headerBox = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(24, 24, 24, 24)
                setBackgroundColor(android.graphics.Color.parseColor("#E74C3C"))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 20)
                layoutParams = params
                elevation = 4f
            }
            
            headerBox.addView(TextView(context).apply {
                text = item.verb
                textSize = 36f
                setTextColor(android.graphics.Color.WHITE)
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 8)
            })
            
            headerBox.addView(TextView(context).apply {
                text = item.tense
                textSize = 20f
                setTextColor(android.graphics.Color.parseColor("#FFEBEE"))
                setTypeface(null, android.graphics.Typeface.BOLD)
            })
            
            card.addView(headerBox)
            
            item.conjugations.forEach { (pronoun, conjugation) ->
                val row = LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    setPadding(16, 12, 16, 12)
                    setBackgroundColor(android.graphics.Color.parseColor("#F5F5F5"))
                    val params = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                    params.setMargins(0, 0, 0, 8)
                    layoutParams = params
                    elevation = 1f
                }
                
                row.addView(TextView(context).apply {
                    text = pronoun
                    textSize = 16f
                    setTextColor(android.graphics.Color.parseColor("#666666"))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(120, LinearLayout.LayoutParams.WRAP_CONTENT)
                })
                
                row.addView(TextView(context).apply {
                    text = conjugation
                    textSize = 20f
                    setTextColor(android.graphics.Color.parseColor("#E74C3C"))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(
                        0,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                        1f
                    )
                })
                
                row.addView(ImageButton(context).apply {
                    setImageResource(android.R.drawable.ic_lock_silent_mode_off)
                    setBackgroundColor(android.graphics.Color.parseColor("#E74C3C"))
                    setPadding(16, 16, 16, 16)
                    setOnClickListener {
                        tts?.speak("$pronoun $conjugation", TextToSpeech.QUEUE_FLUSH, null, null)
                    }
                })
                
                card.addView(row)
            }
            
            cardContainer.addView(card)
        }
        
        private fun createQuizCard(item: QuizFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.parseColor("#FFFEF0"))
            }
            
            card.addView(TextView(context).apply {
                text = "🎯 Quiz"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#F39C12"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            card.addView(TextView(context).apply {
                text = item.question
                textSize = 22f
                setTextColor(android.graphics.Color.parseColor("#2C3E50"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(16, 20, 16, 20)
                setBackgroundColor(android.graphics.Color.WHITE)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 24)
                layoutParams = params
            })
            
            var selectedOption = -1
            val optionButtons = mutableListOf<Button>()
            
            item.options.forEachIndexed { index, option ->
                val button = Button(context).apply {
                    text = option
                    textSize = 18f
                    setPadding(24, 20, 24, 20)
                    setBackgroundColor(android.graphics.Color.WHITE)
                    setTextColor(android.graphics.Color.parseColor("#2C3E50"))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    val params = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                    params.setMargins(0, 0, 0, 16)
                    layoutParams = params
                    elevation = 4f
                    
                    setOnClickListener {
                        selectedOption = index
                        optionButtons.forEach { btn ->
                            btn.setBackgroundColor(android.graphics.Color.parseColor("#F5F5F5"))
                        }
                        
                        if (index == item.correctAnswer) {
                            setBackgroundColor(android.graphics.Color.parseColor("#27AE60"))
                            setTextColor(android.graphics.Color.WHITE)
                        } else {
                            setBackgroundColor(android.graphics.Color.parseColor("#E74C3C"))
                            setTextColor(android.graphics.Color.WHITE)
                            optionButtons[item.correctAnswer].setBackgroundColor(android.graphics.Color.parseColor("#27AE60"))
                            optionButtons[item.correctAnswer].setTextColor(android.graphics.Color.WHITE)
                        }
                    }
                }
                optionButtons.add(button)
                card.addView(button)
            }
            
            cardContainer.addView(card)
        }
        
        private fun createFlashcardCard(item: FlashcardVocabularyFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.parseColor("#F0F9FF"))
            }
            
            card.addView(TextView(context).apply {
                text = "🎴 Flashcard"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#0284C7"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            var isRevealed = false
            
            // Carte flip avec le mot
            val flashcardBox = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(32, 48, 32, 48)
                setBackgroundColor(android.graphics.Color.parseColor("#0284C7"))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    400
                )
                params.setMargins(0, 0, 0, 20)
                layoutParams = params
                elevation = 8f
                isClickable = true
            }
            
            val formattedWord = VocabularyFormatter.formatWord(item.word)
            
            val wordText = TextView(context).apply {
                text = formattedWord
                textSize = 48f
                setTextColor(android.graphics.Color.WHITE)
                setTypeface(null, android.graphics.Typeface.BOLD)
                gravity = Gravity.CENTER
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
            }
            
            flashcardBox.addView(wordText)
            
            // Bouton audio pour le mot
            flashcardBox.addView(ImageButton(context).apply {
                setImageResource(android.R.drawable.ic_lock_silent_mode_off)
                setBackgroundColor(android.graphics.Color.parseColor("#F97316"))
                setPadding(16, 16, 16, 16)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.gravity = Gravity.CENTER
                params.setMargins(0, 16, 0, 0)
                layoutParams = params
                setOnClickListener {
                    tts?.speak(formattedWord, TextToSpeech.QUEUE_FLUSH, null, null)
                }
            })
            
            val translationText = TextView(context).apply {
                text = "→ ${item.translation}"
                textSize = 28f
                setTextColor(android.graphics.Color.parseColor("#0284C7"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                gravity = Gravity.CENTER
                setPadding(20, 20, 20, 20)
                visibility = View.GONE
            }
            
            val exampleContainer = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(16, 16, 16, 8)
                setBackgroundColor(android.graphics.Color.WHITE)
                visibility = View.GONE
            }
            
            val exampleRow = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
            }
            
            exampleRow.addView(TextView(context).apply {
                text = "📝 ${item.example}"
                textSize = 16f
                setTextColor(android.graphics.Color.parseColor("#334155"))
                setTypeface(null, android.graphics.Typeface.ITALIC)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
            })
            
            exampleRow.addView(ImageButton(context).apply {
                setImageResource(android.R.drawable.ic_lock_silent_mode_off)
                setBackgroundColor(android.graphics.Color.parseColor("#F97316"))
                setPadding(12, 12, 12, 12)
                setOnClickListener {
                    tts?.speak(item.example, TextToSpeech.QUEUE_FLUSH, null, null)
                }
            })
            
            exampleContainer.addView(exampleRow)
            
            exampleContainer.addView(TextView(context).apply {
                text = item.exampleTranslation
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#64748B"))
                setPadding(0, 8, 0, 0)
            })
            
            // Bouton révéler
            val revealButton = Button(context).apply {
                text = "👆 Toucher pour révéler"
                textSize = 18f
                setPadding(24, 20, 24, 20)
                setBackgroundColor(android.graphics.Color.parseColor("#0EA5E9"))
                setTextColor(android.graphics.Color.WHITE)
                setTypeface(null, android.graphics.Typeface.BOLD)
                elevation = 4f
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 16)
                layoutParams = params
            }
            
            revealButton.setOnClickListener {
                isRevealed = !isRevealed
                if (isRevealed) {
                    translationText.visibility = View.VISIBLE
                    exampleContainer.visibility = View.VISIBLE
                    revealButton.text = "🔄 Masquer"
                    revealButton.setBackgroundColor(android.graphics.Color.parseColor("#64748B"))
                } else {
                    translationText.visibility = View.GONE
                    exampleContainer.visibility = View.GONE
                    revealButton.text = "👆 Toucher pour révéler"
                    revealButton.setBackgroundColor(android.graphics.Color.parseColor("#0EA5E9"))
                }
            }
            
            card.addView(flashcardBox)
            card.addView(revealButton)
            card.addView(translationText)
            card.addView(exampleContainer)
            
            cardContainer.addView(card)
        }
        
        private fun createFlashcardPhoneticCard(item: FlashcardPhoneticFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.parseColor("#F5F0FF"))
            }
            
            card.addView(TextView(context).apply {
                text = "🎵 Flashcard Phonétique"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#6C3FB5"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            // Grande carte violette avec le son (toujours visible)
            val flashcardBox = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(40, 60, 40, 60)
                setBackgroundColor(android.graphics.Color.parseColor("#6C3FB5"))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 24)
                layoutParams = params
                elevation = 8f
            }
            
            val soundText = TextView(context).apply {
                text = item.graphie
                textSize = 72f
                setTextColor(android.graphics.Color.WHITE)
                setTypeface(null, android.graphics.Typeface.BOLD)
                gravity = Gravity.CENTER
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
            }
            
            val phoneticText = TextView(context).apply {
                text = item.phonetic
                textSize = 48f
                setTextColor(android.graphics.Color.parseColor("#FFD700"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                gravity = Gravity.CENTER
                setPadding(0, 24, 0, 0)
                setShadowLayer(3f, 0f, 2f, android.graphics.Color.parseColor("#000000"))
            }
            
            flashcardBox.addView(soundText)
            flashcardBox.addView(phoneticText)
            
            val descriptionText = TextView(context).apply {
                text = item.description
                textSize = 18f
                setTextColor(android.graphics.Color.parseColor("#2C3E50"))
                setPadding(20, 20, 20, 20)
                setBackgroundColor(android.graphics.Color.WHITE)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 16)
                layoutParams = params
                visibility = View.VISIBLE
            }
            
            val examplesContainer = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                visibility = View.VISIBLE
            }
            
            item.examples.forEach { example ->
                val exampleRow = LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    setPadding(16, 12, 16, 12)
                    setBackgroundColor(android.graphics.Color.WHITE)
                    val params = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                    params.setMargins(0, 0, 0, 8)
                    layoutParams = params
                    elevation = 2f
                }
                
                exampleRow.addView(TextView(context).apply {
                    text = example
                    textSize = 18f
                    setTextColor(android.graphics.Color.parseColor("#2C3E50"))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    layoutParams = LinearLayout.LayoutParams(
                        0,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                        1f
                    )
                })
                
                exampleRow.addView(ImageButton(context).apply {
                    setImageResource(android.R.drawable.ic_lock_silent_mode_off)
                    setBackgroundColor(android.graphics.Color.parseColor("#6C3FB5"))
                    setPadding(16, 16, 16, 16)
                    setOnClickListener {
                        tts?.speak(example, TextToSpeech.QUEUE_FLUSH, null, null)
                    }
                })
                
                examplesContainer.addView(exampleRow)
            }
            
            val tipsText = TextView(context).apply {
                text = "💡 ${item.tips ?: ""}"
                textSize = 15f
                setTextColor(android.graphics.Color.parseColor("#1E3A8A"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(20, 20, 20, 20)
                setBackgroundColor(android.graphics.Color.parseColor("#DBEAFE"))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 16)
                layoutParams = params
                elevation = 2f
                visibility = if (item.tips.isNullOrEmpty()) View.GONE else View.VISIBLE
            }
            
            card.addView(flashcardBox)
            card.addView(descriptionText)
            card.addView(examplesContainer)
            card.addView(tipsText)
            
            cardContainer.addView(card)
        }
        
        private fun createQuickChallengeCard(item: QuickChallengeFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.parseColor("#FFF4E6"))
            }
            
            card.addView(TextView(context).apply {
                text = "⚡ Défi Rapide"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#F97316"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            // Type de défi
            val typeLabel = when (item.challengeType) {
                "speed_translation" -> "🚀 Traduction rapide"
                "audio_match" -> "🔊 Écoute active"
                else -> "✏️ Complète"
            }
            
            card.addView(TextView(context).apply {
                text = typeLabel
                textSize = 12f
                setTextColor(android.graphics.Color.parseColor("#F97316"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            // Question
            card.addView(TextView(context).apply {
                text = item.question
                textSize = 20f
                setTextColor(android.graphics.Color.parseColor("#1F2937"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(16, 24, 16, 24)
                setBackgroundColor(android.graphics.Color.WHITE)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 20)
                layoutParams = params
                elevation = 2f
            })
            
            // Audio button si nécessaire
            if (item.audioWord != null) {
                card.addView(Button(context).apply {
                    text = "🔊 Écouter"
                    textSize = 16f
                    setPadding(20, 16, 20, 16)
                    setBackgroundColor(android.graphics.Color.parseColor("#F97316"))
                    setTextColor(android.graphics.Color.WHITE)
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    elevation = 4f
                    val params = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                    params.setMargins(0, 0, 0, 16)
                    layoutParams = params
                    setOnClickListener {
                        tts?.speak(item.audioWord, TextToSpeech.QUEUE_FLUSH, null, null)
                    }
                })
            }
            
            // Options
            var answered = false
            item.options.forEach { option ->
                val button = Button(context).apply {
                    text = option
                    textSize = 18f
                    setPadding(20, 20, 20, 20)
                    setBackgroundColor(android.graphics.Color.parseColor("#FFFFFF"))
                    setTextColor(android.graphics.Color.parseColor("#1F2937"))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    elevation = 2f
                    val params = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                    params.setMargins(0, 0, 0, 12)
                    layoutParams = params
                    
                    setOnClickListener {
                        if (!answered) {
                            answered = true
                            val isCorrect = option == item.correctAnswer
                            
                            setBackgroundColor(
                                if (isCorrect) 
                                    android.graphics.Color.parseColor("#10B981")
                                else 
                                    android.graphics.Color.parseColor("#EF4444")
                            )
                            setTextColor(android.graphics.Color.WHITE)
                            
                            // Montrer le mot dans la langue (toujours, même si correct)
                            val wordInLanguage = if (item.audioWord != null) item.audioWord else ""
                            if (wordInLanguage.isNotEmpty()) {
                                card.addView(TextView(context).apply {
                                    text = if (isCorrect) "✅ $wordInLanguage" else "✅ Bonne réponse: ${item.correctAnswer} ($wordInLanguage)"
                                    textSize = 16f
                                    setTextColor(android.graphics.Color.parseColor("#10B981"))
                                    setTypeface(null, android.graphics.Typeface.BOLD)
                                    setPadding(16, 16, 16, 16)
                                    setBackgroundColor(android.graphics.Color.parseColor("#ECFDF5"))
                                    val params = LinearLayout.LayoutParams(
                                        LinearLayout.LayoutParams.MATCH_PARENT,
                                        LinearLayout.LayoutParams.WRAP_CONTENT
                                    )
                                    params.setMargins(0, 16, 0, 0)
                                    layoutParams = params
                                })
                            } else if (!isCorrect) {
                                // Si pas de mot audio, montrer juste la réponse correcte quand faux
                                card.addView(TextView(context).apply {
                                    text = "✅ Bonne réponse: ${item.correctAnswer}"
                                    textSize = 16f
                                    setTextColor(android.graphics.Color.parseColor("#10B981"))
                                    setTypeface(null, android.graphics.Typeface.BOLD)
                                    setPadding(16, 16, 16, 16)
                                    setBackgroundColor(android.graphics.Color.parseColor("#ECFDF5"))
                                    val params = LinearLayout.LayoutParams(
                                        LinearLayout.LayoutParams.MATCH_PARENT,
                                        LinearLayout.LayoutParams.WRAP_CONTENT
                                    )
                                    params.setMargins(0, 16, 0, 0)
                                    layoutParams = params
                                })
                            }
                            
                            // Désactiver tous les boutons
                            for (i in 0 until card.childCount) {
                                val child = card.getChildAt(i)
                                if (child is Button) {
                                    child.isEnabled = false
                                }
                            }
                        }
                    }
                }
                card.addView(button)
            }
            
            cardContainer.addView(card)
        }
        
        private fun createConjugationQuizCard(item: ConjugationQuizFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.parseColor("#FEF2F2"))
            }
            
            card.addView(TextView(context).apply {
                text = "✏️ Quiz Conjugaison"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#DC2626"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            // Verbe et temps
            val verbBox = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(24, 20, 24, 20)
                setBackgroundColor(android.graphics.Color.parseColor("#DC2626"))
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 16)
                layoutParams = params
                elevation = 4f
            }
            
            verbBox.addView(TextView(context).apply {
                text = item.verb
                textSize = 32f
                setTextColor(android.graphics.Color.WHITE)
                setTypeface(null, android.graphics.Typeface.BOLD)
                gravity = Gravity.CENTER
            })
            
            verbBox.addView(TextView(context).apply {
                text = item.tense
                textSize = 16f
                setTextColor(android.graphics.Color.parseColor("#FEE2E2"))
                gravity = Gravity.CENTER
                setPadding(0, 8, 0, 0)
            })
            
            card.addView(verbBox)
            
            // Question
            card.addView(TextView(context).apply {
                text = "Comment conjuguer avec \"${item.pronoun}\" ?"
                textSize = 18f
                setTextColor(android.graphics.Color.parseColor("#1F2937"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(16, 16, 16, 16)
                setBackgroundColor(android.graphics.Color.WHITE)
                val params = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                params.setMargins(0, 0, 0, 16)
                layoutParams = params
                elevation = 2f
            })
            
            // Options
            var answered = false
            item.options.forEach { option ->
                val button = Button(context).apply {
                    text = "${item.pronoun} $option"
                    textSize = 18f
                    setPadding(20, 20, 20, 20)
                    setBackgroundColor(android.graphics.Color.parseColor("#FFFFFF"))
                    setTextColor(android.graphics.Color.parseColor("#1F2937"))
                    setTypeface(null, android.graphics.Typeface.BOLD)
                    elevation = 2f
                    val params = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                    params.setMargins(0, 0, 0, 12)
                    layoutParams = params
                    
                    setOnClickListener {
                        if (!answered) {
                            answered = true
                            val isCorrect = option == item.correctAnswer
                            
                            setBackgroundColor(
                                if (isCorrect) 
                                    android.graphics.Color.parseColor("#10B981")
                                else 
                                    android.graphics.Color.parseColor("#EF4444")
                            )
                            setTextColor(android.graphics.Color.WHITE)
                            
                            // Montrer la bonne réponse si faux
                            if (!isCorrect) {
                                card.addView(TextView(context).apply {
                                    text = "✅ Bonne réponse: ${item.pronoun} ${item.correctAnswer}"
                                    textSize = 16f
                                    setTextColor(android.graphics.Color.parseColor("#10B981"))
                                    setTypeface(null, android.graphics.Typeface.BOLD)
                                    setPadding(16, 16, 16, 16)
                                    setBackgroundColor(android.graphics.Color.parseColor("#ECFDF5"))
                                    val params = LinearLayout.LayoutParams(
                                        LinearLayout.LayoutParams.MATCH_PARENT,
                                        LinearLayout.LayoutParams.WRAP_CONTENT
                                    )
                                    params.setMargins(0, 16, 0, 0)
                                    layoutParams = params
                                })
                            }
                            
                            // Audio de la bonne réponse
                            if (item.explanation != null) {
                                card.addView(TextView(context).apply {
                                    text = "💡 ${item.explanation}"
                                    textSize = 14f
                                    setTextColor(android.graphics.Color.parseColor("#6B7280"))
                                    setTypeface(null, android.graphics.Typeface.ITALIC)
                                    setPadding(16, 8, 16, 8)
                                    val params = LinearLayout.LayoutParams(
                                        LinearLayout.LayoutParams.MATCH_PARENT,
                                        LinearLayout.LayoutParams.WRAP_CONTENT
                                    )
                                    params.setMargins(0, 8, 0, 0)
                                    layoutParams = params
                                })
                            }
                            
                            // Désactiver tous les boutons
                            for (i in 0 until card.childCount) {
                                val child = card.getChildAt(i)
                                if (child is Button) {
                                    child.isEnabled = false
                                }
                            }
                        }
                    }
                }
                card.addView(button)
            }
            
            cardContainer.addView(card)
        }
        
        private fun setupSocialActions(item: FeedItem) {
            likeCount.text = item.likeCount.toString()
            
            updateLikeButton(item.liked)
            updateBookmarkButton(item.bookmarked)
            
            likeButton.setOnClickListener {
                item.liked = !item.liked
                updateLikeButton(item.liked)
                onLike(item.id, item.liked)
                likeCount.text = item.likeCount.toString()
            }
            
            bookmarkButton.setOnClickListener {
                item.bookmarked = !item.bookmarked
                updateBookmarkButton(item.bookmarked)
                onBookmark(item.id, item.bookmarked)
            }
            
            shareButton.setOnClickListener {
                Toast.makeText(context, "Partager ${item.type}", Toast.LENGTH_SHORT).show()
            }
        }
        
        private fun updateLikeButton(liked: Boolean) {
            likeButton.setImageResource(
                if (liked) android.R.drawable.star_big_on else android.R.drawable.star_big_off
            )
        }
        
        private fun updateBookmarkButton(bookmarked: Boolean) {
            bookmarkButton.setImageResource(
                if (bookmarked) android.R.drawable.btn_star_big_on else android.R.drawable.btn_star_big_off
            )
        }
        
        private fun createEmojiCard(item: EmojiFeedItem) {
            val card = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(28, 28, 28, 28)
                setBackgroundColor(android.graphics.Color.parseColor("#FFF9E6"))
            }
            
            card.addView(TextView(context).apply {
                text = "😊 Emoji"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#F59E0B"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 0, 0, 16)
            })
            
            card.addView(TextView(context).apply {
                text = item.emoji
                textSize = 96f
                gravity = Gravity.CENTER
                setPadding(0, 24, 0, 24)
            })
            
            card.addView(TextView(context).apply {
                text = item.word
                textSize = 32f
                setTextColor(android.graphics.Color.parseColor("#F59E0B"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                gravity = Gravity.CENTER
                setPadding(0, 0, 0, 12)
            })
            
            card.addView(TextView(context).apply {
                text = item.translation
                textSize = 20f
                setTextColor(android.graphics.Color.parseColor("#92400E"))
                gravity = Gravity.CENTER
                setPadding(0, 0, 0, 24)
            })
            
            val speakButton = Button(context).apply {
                text = "🔊 Écouter"
                textSize = 18f
                setPadding(24, 16, 24, 16)
                setBackgroundColor(android.graphics.Color.parseColor("#F59E0B"))
                setTextColor(android.graphics.Color.WHITE)
                setTypeface(null, android.graphics.Typeface.BOLD)
                elevation = 2f
                setOnClickListener {
                    tts?.speak(item.word, TextToSpeech.QUEUE_FLUSH, null, null)
                }
            }
            
            card.addView(speakButton)
            cardContainer.addView(card)
        }
        
        private fun getDifficultyBadge(difficulty: String): String {
            return when (difficulty) {
                "débutant", "easy" -> "FACILE"
                "intermédiaire", "medium" -> "MOYEN"
                "avancé", "hard" -> "DIFFICILE"
                else -> difficulty.uppercase()
            }
        }
        
        private fun getDifficultyColor(difficulty: String): Int {
            return when (difficulty) {
                "débutant", "easy" -> android.graphics.Color.parseColor("#27AE60")
                "intermédiaire", "medium" -> android.graphics.Color.parseColor("#F39C12")
                "avancé", "hard" -> android.graphics.Color.parseColor("#E74C3C")
                else -> android.graphics.Color.parseColor("#95A5A6")
            }
        }
    }
}
