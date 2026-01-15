package com.loicberthod.onykroua.vocabulary

import org.json.JSONArray
import org.json.JSONObject

object VocabularyData {
    
    private val italianVocabulary = mutableListOf<VocabCategory>()
    private val spanishVocabulary = mutableListOf<VocabCategory>()
    
    fun loadVocabulary(jsonString: String, language: String) {
        val categories = mutableListOf<VocabCategory>()
        val jsonArray = JSONArray(jsonString)
        
        for (i in 0 until jsonArray.length()) {
            val categoryObj = jsonArray.getJSONObject(i)
            val name = categoryObj.getString("name")
            val icon = categoryObj.getString("icon")
            val mainCat = if (categoryObj.has("main_category")) categoryObj.getString("main_category") else null
            val subCat = if (categoryObj.has("sub_category")) categoryObj.getString("sub_category") else null
            val wordsArray = categoryObj.getJSONArray("words")
            
            val words = mutableListOf<VocabWord>()
            for (j in 0 until wordsArray.length()) {
                val wordObj = wordsArray.getJSONObject(j)
                val word = VocabWord(
                    word = wordObj.getString("word"),
                    translation = wordObj.getString("translation"),
                    gender = if (wordObj.has("gender")) wordObj.getString("gender") else null,
                    example = if (wordObj.has("example")) wordObj.getString("example") else null,
                    exampleTranslation = if (wordObj.has("exampleTranslation")) wordObj.getString("exampleTranslation") else null,
                    category = name,
                    categoryIcon = icon,
                    mainCategory = mainCat,
                    subCategory = subCat
                )
                words.add(word)
            }
            
            categories.add(VocabCategory(name, icon, words, mainCat, subCat))
        }
        
        if (language == "it") {
            italianVocabulary.clear()
            italianVocabulary.addAll(categories)
        } else {
            spanishVocabulary.clear()
            spanishVocabulary.addAll(categories)
        }
    }
    
    fun getVocabularyByLanguage(language: String): List<VocabCategory> {
        return if (language == "it") italianVocabulary else spanishVocabulary
    }
    
    fun getAllWords(language: String): List<VocabWord> {
        return getVocabularyByLanguage(language).flatMap { it.words }
            .distinctBy { it.word.lowercase().trim() }
    }
    
    fun getCategories(language: String): List<VocabCategory> {
        return getVocabularyByLanguage(language)
    }
    
    fun getWordsByCategory(language: String, categoryName: String): List<VocabWord> {
        return getVocabularyByLanguage(language)
            .find { it.name == categoryName }
            ?.words ?: emptyList()
    }
    
    fun getWordsSortedAlphabetically(language: String): Map<Char, List<VocabWord>> {
        return getAllWords(language)
            .distinctBy { it.word.lowercase().trim() }
            .sortedBy { it.word.lowercase() }
            .groupBy { it.word.first().uppercaseChar() }
    }
    
    fun getMainCategories(language: String): List<String> {
        return getVocabularyByLanguage(language)
            .mapNotNull { it.mainCategory }
            .distinct()
            .sorted()
    }
    
    fun getSubCategoriesByMainCategory(language: String, mainCategory: String): List<VocabCategory> {
        return getVocabularyByLanguage(language)
            .filter { it.mainCategory == mainCategory }
    }
    
    fun getCategoriesGroupedByMain(language: String): Map<String, List<VocabCategory>> {
        return getVocabularyByLanguage(language)
            .filter { it.mainCategory != null }
            .groupBy { it.mainCategory!! }
    }
}
