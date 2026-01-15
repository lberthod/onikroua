package com.loicberthod.onykroua.utils

object VocabularyFormatter {
    
    /**
     * Transforme "gesto (il)" en "il gesto"
     * Transforme "casa (la)" en "la casa"
     */
    fun formatWord(word: String): String {
        val regex = Regex("""^(.+?)\s*\(([^)]+)\)$""")
        val match = regex.find(word)
        
        return if (match != null) {
            val mainWord = match.groupValues[1].trim()
            val article = match.groupValues[2].trim()
            "$article $mainWord"
        } else {
            word
        }
    }
    
    /**
     * Extrait juste le mot sans l'article pour certains contextes
     */
    fun getWordOnly(word: String): String {
        val regex = Regex("""^(.+?)\s*\([^)]+\)$""")
        val match = regex.find(word)
        
        return if (match != null) {
            match.groupValues[1].trim()
        } else {
            word
        }
    }
}
