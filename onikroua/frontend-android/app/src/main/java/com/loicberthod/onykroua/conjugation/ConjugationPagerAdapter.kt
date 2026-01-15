package com.loicberthod.onykroua.conjugation

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter

class ConjugationPagerAdapter(
    activity: FragmentActivity,
    private val language: String
) : FragmentStateAdapter(activity) {
    
    override fun getItemCount(): Int = 5
    
    override fun createFragment(position: Int): Fragment {
        return when(position) {
            0 -> RulesFragment.newInstance(language)
            1 -> VerbsFragment.newInstance(language)
            2 -> TensesFragment.newInstance(language)
            3 -> PracticeFragment.newInstance(language)
            4 -> MoreFragment.newInstance(language)
            else -> RulesFragment.newInstance(language)
        }
    }
}
