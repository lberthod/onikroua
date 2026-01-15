package com.loicberthod.onykroua.grammar

data class GrammarRule(
    val id: String,
    val category: String,
    val subCategory: String,
    val rule: String,
    val content: String,
    val example: String?,
    val translation: String?,
    val difficulty: String // débutant, intermédiaire, avancé
)

data class GrammarCategory(
    val id: String,
    val label: String,
    val icon: String,
    val color: String
)

data class GrammarGroup(
    val subCategory: String,
    val label: String,
    val rules: List<GrammarRule>
)
