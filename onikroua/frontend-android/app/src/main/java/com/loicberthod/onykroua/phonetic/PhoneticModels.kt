package com.loicberthod.onykroua.phonetic

data class PhoneticSound(
    val id: String,
    val language: String,
    val category: String,
    val graphie: String,
    val phonetic: String,
    val description: String,
    val examples: List<String>,
    val position: String? = null,
    val difficulty: String,
    val tips: String? = null,
    val commonMistakes: String? = null
)

data class PracticeWord(
    val word: String,
    val phonetic: String?,
    val translation: String,
    val soundIds: List<String>? = null
)

data class PhoneticCategory(
    val id: String,
    val name: String,
    val icon: String
)
