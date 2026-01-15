package com.loicberthod.onykroua.conversation

data class Message(
    val speaker: String, // "A" ou "B"
    val text: String,
    val translation: String
)

data class VocabItem(
    val word: String,
    val translation: String
)

data class Conversation(
    val title: String,
    val icon: String,
    val scenario: String,
    val difficulty: String, // débutant, intermédiaire, avancé
    val messages: List<Message>,
    val vocabulary: List<VocabItem>,
    val tips: List<String>
)
