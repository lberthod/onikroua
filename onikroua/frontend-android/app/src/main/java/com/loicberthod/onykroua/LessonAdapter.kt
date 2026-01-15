package com.loicberthod.onykroua

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class LessonAdapter(private val lessons: List<Lesson>) : 
    RecyclerView.Adapter<LessonAdapter.ViewHolder>() {

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val title: TextView = view.findViewById(R.id.lessonTitle)
        val description: TextView = view.findViewById(R.id.lessonDescription)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_lesson, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val lesson = lessons[position]
        holder.title.text = lesson.title
        holder.description.text = lesson.description
    }

    override fun getItemCount() = lessons.size
}
