package com.loicberthod.onykroua.conjugation

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.loicberthod.onykroua.R

class TensesFragment : Fragment() {
    
    private var language: String = "it"
    private var selectedTense: String? = null
    
    companion object {
        fun newInstance(lang: String) = TensesFragment().apply {
            arguments = Bundle().apply { putString("lang", lang) }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        language = arguments?.getString("lang") ?: "it"
    }
    
    private lateinit var tensesContainer: LinearLayout
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val scrollView = inflater.inflate(R.layout.fragment_tenses, container, false)
        tensesContainer = scrollView.findViewById(R.id.tensesContainer)
        
        displayTenses()
        
        return scrollView
    }
    
    private fun displayTenses() {
        tensesContainer.removeAllViews()
        
        val data = GrammarData.getData(language)
        
        data.tenses.forEach { tense ->
            tensesContainer.addView(createTenseCard(tense))
            
            if (selectedTense == tense.name) {
                tensesContainer.addView(createTenseDetails(tense.name))
            }
        }
    }
    
    private fun createTenseDetails(tenseName: String): LinearLayout {
        val details = getTenseDetails(tenseName)!!
        
        val card = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(32, 16, 32, 24)
            setBackgroundColor(android.graphics.Color.parseColor("#F0F4FF"))
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 16)
            layoutParams = params
        }
        
        card.addView(TextView(requireContext()).apply {
            text = "📚 Utilisation"
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#4F46E5"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 0, 0, 8)
        })
        
        card.addView(TextView(requireContext()).apply {
            text = details.usage
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setPadding(0, 0, 0, 12)
        })
        
        card.addView(TextView(requireContext()).apply {
            text = "🔧 Formation"
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#4F46E5"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 8, 0, 8)
        })
        
        card.addView(TextView(requireContext()).apply {
            text = details.formation
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#555555"))
            setPadding(0, 0, 0, 12)
        })
        
        card.addView(TextView(requireContext()).apply {
            text = "💡 Exemples"
            textSize = 16f
            setTextColor(android.graphics.Color.parseColor("#4F46E5"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 8, 0, 8)
        })
        
        details.examples.forEach { example ->
            card.addView(TextView(requireContext()).apply {
                text = "• $example"
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#333333"))
                setPadding(8, 4, 0, 4)
            })
        }
        
        if (details.tip.isNotEmpty()) {
            card.addView(TextView(requireContext()).apply {
                text = "💭 Conseil"
                textSize = 16f
                setTextColor(android.graphics.Color.parseColor("#10B981"))
                setTypeface(null, android.graphics.Typeface.BOLD)
                setPadding(0, 12, 0, 8)
            })
            
            card.addView(TextView(requireContext()).apply {
                text = details.tip
                textSize = 14f
                setTextColor(android.graphics.Color.parseColor("#166534"))
                setTypeface(null, android.graphics.Typeface.ITALIC)
                setPadding(0, 0, 0, 4)
            })
        }
        
        return card
    }
    
    private fun getTenseDetails(tenseName: String): TenseDetail? {
        return when {
            language == "it" && tenseName == "Presente" -> TenseDetail(
                "Presente (italien)",
                "Parler d'actions actuelles, d'habitudes et de vérités générales.",
                "Radical du verbe + terminaisons : -o, -i, -a, -iamo, -ate, -ano pour -ARE ; -o, -i, -e, -iamo, -ete, -ono pour -ERE ; -o, -i, -e, -iamo, -ite, -ono pour -IRE.",
                listOf("Parlo italiano ogni giorno. (Je parle italien tous les jours.)", "Vado a scuola in autobus. (Je vais à l'école en bus.)"),
                "C'est le temps le plus utilisé en italien ! Maîtrise d'abord les verbes réguliers avant de t'attaquer aux irréguliers."
            )
            language == "it" && tenseName == "Passato prossimo" -> TenseDetail(
                "Passato prossimo",
                "Actions passées terminées ayant un lien avec le présent.",
                "Auxiliaire ESSERE ou AVERE au présent + participe passé (parlato, andato, finito...). Accord du participe avec le sujet quand l'auxiliaire est ESSERE.",
                listOf("Ho parlato con lui. (J'ai parlé avec lui.)", "Siamo arrivati tardi. (Nous sommes arrivés en retard.)"),
                "Astuce : Les verbes de mouvement (andare, venire...) et réfléchis utilisent ESSERE. La plupart des autres utilisent AVERE."
            )
            language == "it" && tenseName == "Imperfetto" -> TenseDetail(
                "Imperfetto",
                "Descriptions, habitudes et actions en cours dans le passé.",
                "Radical de la 1re personne du pluriel au présent + -vo, -vi, -va, -vamo, -vate, -vano.",
                listOf("Da bambino giocavo in strada. (Quand j'étais enfant, je jouais dans la rue.)", "Parlavamo spesso di viaggi. (Nous parlions souvent de voyages.)"),
                "Pense à l'imparfait français : c'était, il faisait, je parlais... C'est pareil en italien !"
            )
            language == "it" && tenseName == "Futuro semplice" -> TenseDetail(
                "Futuro semplice",
                "Actions futures, promesses, prévisions.",
                "Infinitif (parfois tronqué) + -ò, -ai, -à, -emo, -ete, -anno.",
                listOf("Domani andrò a Roma. (Demain j'irai à Rome.)", "Vedremo cosa succederà. (Nous verrons ce qui se passera.)"),
                "Attention : certains verbes perdent la voyelle de l'infinitif (andare → andrò, avere → avrò)."
            )
            language == "it" && tenseName == "Condizionale" -> TenseDetail(
                "Condizionale presente",
                "Exprimer la politesse, les hypothèses, les souhaits et les conseils.",
                "Même base que le futur + -ei, -esti, -ebbe, -emmo, -este, -ebbero.",
                listOf("Vorrei un caffè. (Je voudrais un café.)", "Dovresti studiare di più. (Tu devrais étudier davantage.)"),
                "Très utilisé pour être poli ! 'Vorrei' (je voudrais) est bien plus doux que 'Voglio' (je veux)."
            )
            language == "it" && tenseName == "Congiuntivo" -> TenseDetail(
                "Congiuntivo presente",
                "Exprimer le doute, l'opinion, le souhait, la peur après certains verbes.",
                "Terminaisons spécifiques : che io parli, che tu parli, che lui/lei parli, che noi parliamo, che voi parliate, che loro parlino.",
                listOf("Spero che tu stia bene. (J'espère que tu vas bien.)", "Penso che sia difficile. (Je pense que c'est difficile.)"),
                "Le subjonctif italien s'utilise après : sperare (espérer), pensare (penser), credere (croire), temere (craindre)..."
            )
            language == "it" && tenseName == "Imperativo" -> TenseDetail(
                "Imperativo",
                "Donner des ordres, des conseils ou des instructions.",
                "Formes spécifiques : parla!, parli!, parliamo!, parlate!, parlino! (souvent sans sujet exprimé).",
                listOf("Parla più piano! (Parle plus doucement!)", "Mangiamo insieme! (Mangeons ensemble!)"),
                "Pour la forme de politesse (Lei), on utilise le subjonctif : 'Parli!' au lieu de 'Parla!'."
            )
            language == "es" && tenseName == "Presente" -> TenseDetail(
                "Presente (espagnol)",
                "Actions actuelles, vérités générales et habitudes.",
                "Radical + terminaisons : -o, -as, -a, -amos, -áis, -an pour -AR ; -o, -es, -e, -emos, -éis, -en pour -ER ; -o, -es, -e, -imos, -ís, -en pour -IR.",
                listOf("Hablo español todos los días. (Je parle espagnol tous les jours.)", "Vivimos en Madrid. (Nous vivons à Madrid.)"),
                "Commence par les verbes réguliers en -AR (les plus nombreux) avant les irréguliers comme ser, estar, ir."
            )
            language == "es" && tenseName == "Pretérito perfecto" -> TenseDetail(
                "Pretérito perfecto compuesto",
                "Parler d'actions passées récentes ou liées au présent.",
                "Auxiliaire HABER au présent + participe passé (hablado, comido, vivido...).",
                listOf("He hablado con ella. (J'ai parlé avec elle.)", "Hemos comido ya. (Nous avons déjà mangé.)"),
                "Très utilisé en Espagne pour parler du passé récent. En Amérique latine, on préfère le pretérito indefinido."
            )
            language == "es" && tenseName == "Pretérito indefinido" -> TenseDetail(
                "Pretérito indefinido",
                "Actions passées, terminées, sans lien direct avec le présent.",
                "Terminaisons propres : hablé, hablaste, habló, hablamos, hablasteis, hablaron / comí, comiste, comió, etc.",
                listOf("Ayer hablé con mi jefe. (Hier j'ai parlé avec mon chef.)", "El año pasado viajamos a México. (L'année dernière, nous avons voyagé au Mexique.)"),
                "Marqueurs temporels typiques : ayer (hier), anoche (hier soir), el año pasado (l'année dernière)."
            )
            language == "es" && tenseName == "Pretérito imperfecto" -> TenseDetail(
                "Pretérito imperfecto",
                "Habitudes, descriptions et actions en cours dans le passé.",
                "Deux modèles : -aba, -abas, -aba, -ábamos, -abais, -aban pour -AR ; -ía, -ías, -ía, -íamos, -íais, -ían pour -ER/-IR.",
                listOf("Cuando era niño jugaba en el parque. (Quand j'étais enfant, je jouais au parc.)", "Siempre leía antes de dormir. (Je lisais toujours avant de dormir.)"),
                "Comme l'imparfait français : décrit le décor, les habitudes passées. Souvent avec 'cuando era...' (quand j'étais)."
            )
            language == "es" && tenseName == "Futuro simple" -> TenseDetail(
                "Futuro simple",
                "Parler du futur, des promesses et des suppositions.",
                "Infinitif + terminaisons : -é, -ás, -á, -emos, -éis, -án.",
                listOf("Mañana estudiaré más. (Demain j'étudierai plus.)", "Veremos qué pasa. (Nous verrons ce qui se passe.)"),
                "Super simple : tu gardes l'infinitif complet et tu ajoutes les terminaisons ! Pas de changement de radical."
            )
            language == "es" && tenseName == "Condicional" -> TenseDetail(
                "Condicional simple",
                "Exprimer des hypothèses, des souhaits et la politesse.",
                "Infinitif + -ía, -ías, -ía, -íamos, -íais, -ían.",
                listOf("Me gustaría viajar más. (J'aimerais voyager davantage.)", "¿Podrías ayudarme? (Pourrais-tu m'aider?)"),
                "Très utile pour être poli ! 'Me gustaría...' (j'aimerais) est beaucoup plus doux que 'Quiero' (je veux)."
            )
            language == "es" && tenseName == "Subjuntivo" -> TenseDetail(
                "Subjuntivo presente",
                "Après des verbes de volonté, doute, émotion ou certaines conjonctions.",
                "Changement de terminaison : que yo hable, que tú hables, que él hable, que nosotros hablemos, que vosotros habléis, que ellos hablen.",
                listOf("Espero que vengas mañana. (J'espère que tu viendras demain.)", "Es importante que estudien. (Il est important qu'ils étudient.)"),
                "Déclenché par : esperar (espérer), querer (vouloir), dudar (douter), es importante que... Apprends ces verbes déclencheurs !"
            )
            language == "es" && tenseName == "Imperativo" -> TenseDetail(
                "Imperativo",
                "Donner des ordres, des conseils ou des instructions.",
                "Formes spécifiques, souvent sans sujet : habla, hable, hablemos, hablad, hablen.",
                listOf("Habla más despacio. (Parle plus lentement.)", "Ven aquí, por favor. (Viens ici, s'il te plaît.)"),
                "Pour la forme négative (ne fais pas), on utilise le subjonctif : 'No hables' au lieu de 'Habla'."
            )
            else -> null
        }
    }
    
    data class TenseDetail(val title: String, val usage: String, val formation: String, val examples: List<String>, val tip: String = "")
    
    private fun addSpacer(container: LinearLayout) {
        container.addView(View(requireContext()).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                16
            )
        })
    }
    
    private fun createTenseCard(tense: GrammarData.Tense): LinearLayout {
        val isSelected = selectedTense == tense.name
        val card = LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(24, 24, 24, 24)
            setBackgroundColor(if (isSelected) {
                ContextCompat.getColor(context, android.R.color.holo_blue_light)
            } else {
                ContextCompat.getColor(context, android.R.color.white)
            })
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(0, 0, 0, 16)
            layoutParams = params
            isClickable = true
            isFocusable = true
            setOnClickListener {
                selectedTense = if (selectedTense == tense.name) null else tense.name
                displayTenses()
            }
        }
        
        card.addView(TextView(requireContext()).apply {
            text = tense.name
            textSize = 20f
            setTextColor(android.graphics.Color.parseColor("#4F46E5"))
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 0, 0, 8)
        })
        
        card.addView(TextView(requireContext()).apply {
            text = tense.description
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#666666"))
            setPadding(0, 0, 0, 8)
        })
        
        card.addView(TextView(requireContext()).apply {
            text = "Exemple : ${tense.example}"
            textSize = 14f
            setTextColor(android.graphics.Color.parseColor("#333333"))
            setTypeface(null, android.graphics.Typeface.ITALIC)
        })
        
        return card
    }
}
