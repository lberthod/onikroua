package com.loicberthod.onykroua.vocabulary

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter

class VocabularyPagerAdapter(
    fragmentActivity: FragmentActivity,
    private val language: String
) : FragmentStateAdapter(fragmentActivity) {
    
    override fun getItemCount(): Int = 3
    
    override fun createFragment(position: Int): Fragment {
        return when (position) {
            0 -> DictionaryFragment.newInstance(language)
            1 -> CategoriesFragment.newInstance(language)
            2 -> VocabularyPracticeFragment.newInstance(language)
            else -> DictionaryFragment.newInstance(language)
        }
    }
}
