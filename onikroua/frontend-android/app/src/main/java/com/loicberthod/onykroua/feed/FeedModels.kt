package com.loicberthod.onykroua.feed

sealed class FeedItem(
    val id: String,
    val type: String,
    var liked: Boolean = false,
    var bookmarked: Boolean = false,
    var likeCount: Int = 0,
    var commentCount: Int = 0
)

data class GrammarFeedItem(
    val itemId: String,
    val title: String,
    val rule: String,
    val explanation: String,
    val examples: List<String>,
    val difficulty: String
) : FeedItem(itemId, "grammar")

data class VocabularyFeedItem(
    val itemId: String,
    val word: String,
    val translation: String,
    val example: String,
    val exampleTranslation: String,
    val category: String
) : FeedItem(itemId, "vocabulary")

data class PhoneticFeedItem(
    val itemId: String,
    val graphie: String,
    val phonetic: String,
    val description: String,
    val examples: List<String>,
    val tips: String?,
    val difficulty: String
) : FeedItem(itemId, "phonetic")

data class ConjugationFeedItem(
    val itemId: String,
    val verb: String,
    val tense: String,
    val conjugations: Map<String, String>
) : FeedItem(itemId, "conjugation")

data class QuizFeedItem(
    val itemId: String,
    val question: String,
    val options: List<String>,
    val correctAnswer: Int,
    val explanation: String
) : FeedItem(itemId, "quiz")

data class FlashcardVocabularyFeedItem(
    val itemId: String,
    val word: String,
    val translation: String,
    val example: String,
    val exampleTranslation: String,
    val showAnswer: Boolean = false
) : FeedItem(itemId, "flashcard")

data class FlashcardPhoneticFeedItem(
    val itemId: String,
    val graphie: String,
    val phonetic: String,
    val description: String,
    val examples: List<String>,
    val tips: String?
) : FeedItem(itemId, "flashcard_phonetic")

data class QuickChallengeFeedItem(
    val itemId: String,
    val challengeType: String, // "speed_translation", "audio_match", "fill_blank"
    val question: String,
    val correctAnswer: String,
    val options: List<String> = emptyList(),
    val audioWord: String? = null,
    val timeLimit: Int = 10 // secondes
) : FeedItem(itemId, "quick_challenge")

data class ConjugationQuizFeedItem(
    val itemId: String,
    val verb: String,
    val tense: String,
    val pronoun: String,
    val correctAnswer: String,
    val options: List<String>,
    val explanation: String? = null
) : FeedItem(itemId, "conjugation_quiz")
