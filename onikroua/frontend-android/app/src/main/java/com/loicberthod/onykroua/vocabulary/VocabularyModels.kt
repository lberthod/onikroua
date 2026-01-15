package com.loicberthod.onykroua.vocabulary

data class VocabWord(
    val word: String,
    val translation: String,
    val gender: String? = null,
    val example: String? = null,
    val exampleTranslation: String? = null,
    val category: String = "",
    val categoryIcon: String = "",
    val mainCategory: String? = null,
    val subCategory: String? = null
)

data class VocabCategory(
    val name: String,
    val icon: String,
    val words: List<VocabWord>,
    val mainCategory: String? = null,
    val subCategory: String? = null
)
