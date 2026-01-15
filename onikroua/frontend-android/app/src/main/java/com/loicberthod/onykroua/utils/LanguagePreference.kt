package com.loicberthod.onykroua.utils

import android.content.Context
import android.content.SharedPreferences

object LanguagePreference {
    
    private const val PREF_NAME = "language_settings"
    private const val KEY_LANGUAGE = "learning_language"
    private const val DEFAULT_LANGUAGE = "it"
    
    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }
    
    fun getLanguage(context: Context): String {
        return getPrefs(context).getString(KEY_LANGUAGE, DEFAULT_LANGUAGE) ?: DEFAULT_LANGUAGE
    }
    
    fun setLanguage(context: Context, language: String) {
        getPrefs(context).edit()
            .putString(KEY_LANGUAGE, language)
            .apply()
    }
    
    fun isItalian(context: Context): Boolean {
        return getLanguage(context) == "it"
    }
    
    fun isSpanish(context: Context): Boolean {
        return getLanguage(context) == "es"
    }
    
    fun getLanguageName(context: Context): String {
        return if (isItalian(context)) "Italien" else "Espagnol"
    }
    
    fun getLanguageFlag(context: Context): String {
        return if (isItalian(context)) "🇮🇹" else "🇪🇸"
    }
}
