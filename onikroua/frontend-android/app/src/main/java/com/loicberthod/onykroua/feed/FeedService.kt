package com.loicberthod.onykroua.feed

import com.loicberthod.onykroua.grammar.GrammarData
import com.loicberthod.onykroua.vocabulary.VocabularyData
import com.loicberthod.onykroua.phonetic.PhoneticData
import com.loicberthod.onykroua.VerbData
import com.loicberthod.onykroua.emoji.EmojiData
import kotlin.random.Random

object FeedService {
    private var currentLanguage: String = "it"
    private var currentPage = 0
    private val pageSize = 15
    private val allItems = mutableListOf<FeedItem>()
    private val maxItemsBeforeRegenerate = 100
    
    fun setLanguage(language: String) {
        currentLanguage = language
        currentPage = 0
        allItems.clear()
        generateFeedItems()
    }
    
    private fun generateFeedItems(count: Int = 50) {
        val items = mutableListOf<FeedItem>()
        
        // Mélange de différents types de contenu
        val types = listOf("grammar", "vocabulary", "phonetic", "conjugation", "quiz", "flashcard", "flashcard", "flashcard_phonetic", "flashcard_phonetic", "quick_challenge", "quick_challenge", "conjugation_quiz", "conjugation_quiz", "emoji", "emoji")
        
        android.util.Log.d("FeedService", "Generating $count new items for language: $currentLanguage")
        
        val startIndex = allItems.size
        for (i in startIndex until startIndex + count) {
            val type = types.random()
            android.util.Log.d("FeedService", "Generating type: $type")
            when (type) {
                "grammar" -> {
                    val rules = GrammarData.getGrammarRules(currentLanguage)
                    if (rules.isNotEmpty()) {
                        val rule = rules.random()
                        val item = GrammarFeedItem(
                            itemId = "grammar_$i",
                            title = rule.subCategory,
                            rule = rule.rule,
                            explanation = rule.content,
                            examples = listOfNotNull(rule.example),
                            difficulty = rule.difficulty
                        )
                        item.likeCount = Random.nextInt(10, 500)
                        item.commentCount = Random.nextInt(0, 50)
                        items.add(item)
                    }
                }
                "vocabulary" -> {
                    val words = VocabularyData.getAllWords(currentLanguage)
                    android.util.Log.d("FeedService", "Vocabulary words count: ${words.size}")
                    if (words.isNotEmpty()) {
                        val word = words.random()
                        val item = VocabularyFeedItem(
                            itemId = "vocab_$i",
                            word = word.word,
                            translation = word.translation,
                            example = word.example ?: "",
                            exampleTranslation = word.exampleTranslation ?: "",
                            category = "vocabulaire"
                        )
                        item.likeCount = Random.nextInt(10, 500)
                        item.commentCount = Random.nextInt(0, 50)
                        items.add(item)
                        android.util.Log.d("FeedService", "Added vocabulary item")
                    } else {
                        android.util.Log.e("FeedService", "No vocabulary words available!")
                    }
                }
                "phonetic" -> {
                    val sounds = PhoneticData.getSounds(currentLanguage)
                    if (sounds.isNotEmpty()) {
                        val sound = sounds.random()
                        val item = PhoneticFeedItem(
                            itemId = "phonetic_$i",
                            graphie = sound.graphie,
                            phonetic = sound.phonetic,
                            description = sound.description,
                            examples = sound.examples,
                            tips = sound.tips,
                            difficulty = sound.difficulty
                        )
                        item.likeCount = Random.nextInt(10, 500)
                        item.commentCount = Random.nextInt(0, 50)
                        items.add(item)
                    }
                }
                "conjugation" -> {
                    val verbs = VerbData.getVerbsByLanguage(currentLanguage)
                    if (verbs.isNotEmpty()) {
                        val verb = verbs.random()
                        val tenses = verb.conjugations.keys.toList()
                        if (tenses.isNotEmpty()) {
                            val tense = tenses.random()
                            val conjugations: Map<String, String> = verb.conjugations[tense] ?: emptyMap()
                            val item = ConjugationFeedItem(
                                itemId = "conjugation_$i",
                                verb = verb.verb,
                                tense = tense,
                                conjugations = conjugations
                            )
                            item.likeCount = Random.nextInt(10, 500)
                            item.commentCount = Random.nextInt(0, 50)
                            items.add(item)
                        }
                    }
                }
                "quiz" -> {
                    val words = VocabularyData.getAllWords(currentLanguage)
                    android.util.Log.d("FeedService", "Quiz words count: ${words.size}")
                    if (words.size >= 4) {
                        val correctWord = words.random()
                        val wrongWords = words.filter { it.word != correctWord.word }.shuffled().take(3)
                        val allOptions = (listOf(correctWord) + wrongWords).shuffled()
                        
                        val item = QuizFeedItem(
                            itemId = "quiz_$i",
                            question = "Quelle est la traduction de \"${correctWord.word}\" ?",
                            options = allOptions.map { it.translation },
                            correctAnswer = allOptions.indexOf(correctWord),
                            explanation = correctWord.example ?: ""
                        )
                        item.likeCount = Random.nextInt(10, 500)
                        item.commentCount = Random.nextInt(0, 50)
                        items.add(item)
                        android.util.Log.d("FeedService", "Added quiz item")
                    } else {
                        android.util.Log.e("FeedService", "Not enough words for quiz: ${words.size}")
                    }
                }
                "flashcard" -> {
                    val words = VocabularyData.getAllWords(currentLanguage)
                    android.util.Log.d("FeedService", "Flashcard words count: ${words.size}")
                    if (words.isNotEmpty()) {
                        val word = words.random()
                        val item = FlashcardVocabularyFeedItem(
                            itemId = "flashcard_$i",
                            word = word.word,
                            translation = word.translation,
                            example = word.example ?: "",
                            exampleTranslation = word.exampleTranslation ?: ""
                        )
                        item.likeCount = Random.nextInt(10, 500)
                        item.commentCount = Random.nextInt(0, 50)
                        items.add(item)
                        android.util.Log.d("FeedService", "Added flashcard item")
                    } else {
                        android.util.Log.e("FeedService", "No words for flashcard!")
                    }
                }
                "flashcard_phonetic" -> {
                    val sounds = PhoneticData.getSounds(currentLanguage)
                    android.util.Log.d("FeedService", "Flashcard phonetic sounds count: ${sounds.size}")
                    if (sounds.isNotEmpty()) {
                        val sound = sounds.random()
                        val item = FlashcardPhoneticFeedItem(
                            itemId = "flashcard_phonetic_$i",
                            graphie = sound.graphie,
                            phonetic = sound.phonetic,
                            description = sound.description,
                            examples = sound.examples,
                            tips = sound.tips
                        )
                        item.likeCount = Random.nextInt(10, 500)
                        item.commentCount = Random.nextInt(0, 50)
                        items.add(item)
                        android.util.Log.d("FeedService", "Added flashcard phonetic item")
                    } else {
                        android.util.Log.e("FeedService", "No sounds for flashcard phonetic!")
                    }
                }
                "quick_challenge" -> {
                    val words = VocabularyData.getAllWords(currentLanguage)
                    if (words.size >= 4) {
                        val challengeTypes = listOf("speed_translation", "audio_match", "fill_blank")
                        val challengeType = challengeTypes.random()
                        
                        val correctWord = words.random()
                        val wrongWords = words.filter { it.word != correctWord.word }.shuffled().take(3)
                        
                        val item = when (challengeType) {
                            "speed_translation" -> QuickChallengeFeedItem(
                                itemId = "challenge_$i",
                                challengeType = challengeType,
                                question = "Traduction rapide de \"${correctWord.word}\" ?",
                                correctAnswer = correctWord.translation,
                                options = (listOf(correctWord.translation) + wrongWords.map { it.translation }).shuffled(),
                                timeLimit = 5
                            )
                            "audio_match" -> QuickChallengeFeedItem(
                                itemId = "challenge_$i",
                                challengeType = challengeType,
                                question = "🔊 Écoute et choisis la bonne réponse",
                                correctAnswer = correctWord.translation,
                                options = (listOf(correctWord.translation) + wrongWords.map { it.translation }).shuffled(),
                                audioWord = correctWord.word,
                                timeLimit = 8
                            )
                            else -> QuickChallengeFeedItem(
                                itemId = "challenge_$i",
                                challengeType = challengeType,
                                question = "Complète: ${correctWord.example?.replace(correctWord.word, "___") ?: "Le mot correct est..."}",
                                correctAnswer = correctWord.word,
                                options = (listOf(correctWord.word) + wrongWords.map { it.word }).shuffled(),
                                timeLimit = 10
                            )
                        }
                        
                        item.likeCount = Random.nextInt(10, 500)
                        item.commentCount = Random.nextInt(0, 50)
                        items.add(item)
                        android.util.Log.d("FeedService", "Added quick challenge item: $challengeType")
                    }
                }
                "conjugation_quiz" -> {
                    val verbs = VerbData.getVerbsByLanguage(currentLanguage)
                    if (verbs.isNotEmpty()) {
                        val verbObj = verbs.random()
                        val tenses = verbObj.conjugations.keys.toList()
                        if (tenses.isNotEmpty()) {
                            val tense = tenses.random()
                            val conjugationsMap = verbObj.conjugations[tense]
                            if (conjugationsMap != null && conjugationsMap.isNotEmpty()) {
                                val pronouns = listOf("io", "tu", "lui/lei", "noi", "voi", "loro")
                                val pronoun = pronouns.random()
                                val correctAnswer = conjugationsMap[pronoun]
                                
                                if (correctAnswer != null) {
                                    // Générer de mauvaises réponses
                                    val wrongAnswers = mutableListOf<String>()
                                    
                                    // Prendre d'autres conjugaisons du même verbe
                                    conjugationsMap.forEach { (p, conj) ->
                                        if (p != pronoun && wrongAnswers.size < 2) {
                                            wrongAnswers.add(conj)
                                        }
                                    }
                                    
                                    // Compléter avec un autre verbe si nécessaire
                                    if (wrongAnswers.size < 3 && verbs.size > 1) {
                                        val otherVerb = verbs.filter { it.verb != verbObj.verb }.random()
                                        val otherConj = otherVerb.conjugations[tense]?.get(pronoun)
                                        if (otherConj != null) {
                                            wrongAnswers.add(otherConj)
                                        }
                                    }
                                    
                                    if (wrongAnswers.size >= 3) {
                                        val item = ConjugationQuizFeedItem(
                                            itemId = "conj_quiz_$i",
                                            verb = verbObj.verb,
                                            tense = tense,
                                            pronoun = pronoun,
                                            correctAnswer = correctAnswer,
                                            options = (listOf(correctAnswer) + wrongAnswers.take(3)).shuffled(),
                                            explanation = "Conjugaison de \"${verbObj.verb}\" au $tense"
                                        )
                                        item.likeCount = Random.nextInt(10, 500)
                                        item.commentCount = Random.nextInt(0, 50)
                                        items.add(item)
                                        android.util.Log.d("FeedService", "Added conjugation quiz item")
                                    }
                                }
                            }
                        }
                    }
                }
                "emoji" -> {
                    val categories = EmojiData.getEmojiCategories(currentLanguage)
                    if (categories.isNotEmpty()) {
                        val category = categories.random()
                        if (category.items.isNotEmpty()) {
                            val emojiWord = category.items.random()
                            val item = EmojiFeedItem(
                                itemId = "emoji_$i",
                                emoji = emojiWord.emoji,
                                word = emojiWord.word,
                                translation = emojiWord.fr,
                                category = category.name
                            )
                            item.likeCount = Random.nextInt(10, 500)
                            item.commentCount = Random.nextInt(0, 50)
                            items.add(item)
                            android.util.Log.d("FeedService", "Added emoji item")
                        }
                    }
                }
            }
        }
        
        android.util.Log.d("FeedService", "Generated ${items.size} items, total now: ${allItems.size + items.size}")
        allItems.addAll(items.shuffled())
        
        // Nettoyer les vieux items si la liste devient trop longue (garder les 200 derniers)
        if (allItems.size > maxItemsBeforeRegenerate * 2) {
            val itemsToKeep = allItems.size - maxItemsBeforeRegenerate
            allItems.subList(0, itemsToKeep).clear()
            currentPage = (allItems.size / pageSize) - 5 // Ajuster la page courante
            android.util.Log.d("FeedService", "Cleaned old items, keeping last $maxItemsBeforeRegenerate")
        }
    }
    
    fun getNextPage(): List<FeedItem> {
        // Générer contenu initial si vide
        if (allItems.isEmpty()) {
            generateFeedItems(50)
        }
        
        val start = currentPage * pageSize
        
        // Si on approche de la fin, générer plus de contenu
        if (start + pageSize * 2 >= allItems.size) {
            android.util.Log.d("FeedService", "Approaching end, generating more items...")
            generateFeedItems(50)
        }
        
        val end = minOf(start + pageSize, allItems.size)
        
        if (start >= allItems.size) {
            // Ne devrait jamais arriver maintenant
            return emptyList()
        }
        
        currentPage++
        return allItems.subList(start, end)
    }
    
    fun hasMore(): Boolean {
        // Toujours vrai maintenant car on régénère automatiquement
        return true
    }
    
    fun reset() {
        currentPage = 0
        allItems.clear()
    }
}
