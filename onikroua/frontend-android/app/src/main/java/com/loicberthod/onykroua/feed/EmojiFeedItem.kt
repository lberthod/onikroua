package com.loicberthod.onykroua.feed

data class EmojiFeedItem(
    val itemId: String,
    val emoji: String,
    val word: String,
    val translation: String,
    val category: String
) : FeedItem(itemId, "emoji")
