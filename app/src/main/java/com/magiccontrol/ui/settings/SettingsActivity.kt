package com.magiccontrol.ui.settings

import android.os.Bundle
import android.view.ViewGroup
import android.view.LayoutInflater
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import androidx.viewpager.widget.ViewPager
import com.google.android.material.tabs.TabLayout

class SettingsActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val viewPager = ViewPager(this)
        viewPager.id = android.R.id.content
        setContentView(viewPager)
        
        val tabLayout = TabLayout(this)
        addContentView(tabLayout, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        
        val adapter = SettingsPagerAdapter(supportFragmentManager)
        viewPager.adapter = adapter
        tabLayout.setupWithViewPager(viewPager)
    }
    
    private inner class SettingsPagerAdapter(fm: FragmentManager) : 
        FragmentPagerAdapter(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {
        
        private val fragments = listOf(GeneralSettingsFragment(), LanguagesSettingsFragment())
        private val titles = listOf("Général", "Langues")
        
        override fun getItem(position: Int): Fragment = fragments[position]
        override fun getCount(): Int = fragments.size
        override fun getPageTitle(position: Int): CharSequence = titles[position]
    }
}

}
