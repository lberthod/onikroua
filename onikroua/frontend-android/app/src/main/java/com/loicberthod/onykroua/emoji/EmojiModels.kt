package com.loicberthod.onykroua.emoji

data class EmojiWord(
    val emoji: String,
    val fr: String,
    val word: String,
    var category: String = "",
    var categoryIcon: String = ""
)

data class EmojiCategory(
    val name: String,
    val icon: String,
    val items: List<EmojiWord>
)

data class EmojiStory(
    val id: String,
    val emojis: String,
    val fr: String,
    val sentence: String
)
