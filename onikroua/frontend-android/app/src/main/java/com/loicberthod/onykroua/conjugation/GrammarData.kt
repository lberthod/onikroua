package com.loicberthod.onykroua.conjugation

object GrammarData {
    
    data class Grammar(
        val intro: Intro,
        val groups: List<Group>,
        val auxiliaries: List<Auxiliary>,
        val tenses: List<Tense>,
        val irregulars: List<Irregular>,
        val pronouns: Pronouns,
        val expressions: List<Expression>,
        val prepositions: List<Preposition>,
        val serEstar: SerEstar? = null
    )
    
    data class Intro(val title: String, val description: String)
    
    data class Group(
        val name: String,
        val description: String,
        val examples: List<String>,
        val endings: Map<String, Map<String, String>>,
        val conjugation: Conjugation
    )
    
    data class Conjugation(val verb: String, val forms: Map<String, String>)
    
    data class Auxiliary(
        val verb: String,
        val usage: String,
        val forms: Map<String, String>,
        val examples: List<String>
    )
    
    data class Tense(val name: String, val description: String, val example: String)
    
    data class Irregular(val verb: String, val meaning: String, val forms: String)
    
    data class Pronouns(
        val title: String,
        val subject: List<Pronoun>,
        val direct: List<Pronoun>,
        val indirect: List<Pronoun>
    )
    
    data class Pronoun(val pronoun: String, val translation: String)
    
    data class Expression(
        val phrase: String,
        val translation: String,
        val literal: String = ""
    )
    
    data class Preposition(
        val prep: String,
        val usage: String,
        val examples: List<String>
    )
    
    data class SerEstar(val title: String, val rules: List<SerEstarRule>)
    data class SerEstarRule(val use: String, val cases: List<String>, val examples: List<String>)
    
    fun getData(language: String): Grammar {
        return if (language == "it") getItalianData() else getSpanishData()
    }
    
    private fun getItalianData() = Grammar(
        intro = Intro(
            title = "La conjugaison italienne",
            description = "L'italien possède trois groupes de verbes réguliers : -ARE, -ERE et -IRE. Chaque groupe suit des règles spécifiques."
        ),
        groups = listOf(
            Group(
                name = "1er groupe : -ARE",
                description = "Le groupe le plus courant en italien.",
                examples = listOf("parlare (parler)", "mangiare (manger)", "amare (aimer)", "lavorare (travailler)"),
                endings = mapOf(
                    "present" to mapOf("io" to "-o", "tu" to "-i", "lui/lei" to "-a", "noi" to "-iamo", "voi" to "-ate", "loro" to "-ano")
                ),
                conjugation = Conjugation(
                    verb = "PARLARE",
                    forms = mapOf("io" to "parlo", "tu" to "parli", "lui/lei" to "parla", "noi" to "parliamo", "voi" to "parlate", "loro" to "parlano")
                )
            ),
            Group(
                name = "2ème groupe : -ERE",
                description = "Groupe intermédiaire avec quelques irrégularités.",
                examples = listOf("vedere (voir)", "leggere (lire)", "scrivere (écrire)", "prendere (prendre)"),
                endings = mapOf(
                    "present" to mapOf("io" to "-o", "tu" to "-i", "lui/lei" to "-e", "noi" to "-iamo", "voi" to "-ete", "loro" to "-ono")
                ),
                conjugation = Conjugation(
                    verb = "VEDERE",
                    forms = mapOf("io" to "vedo", "tu" to "vedi", "lui/lei" to "vede", "noi" to "vediamo", "voi" to "vedete", "loro" to "vedono")
                )
            ),
            Group(
                name = "3ème groupe : -IRE",
                description = "Se divise en deux : réguliers et ceux avec -isc-.",
                examples = listOf("dormire (dormir)", "partire (partir)", "finire (finir)", "capire (comprendre)"),
                endings = mapOf(
                    "present" to mapOf("io" to "-o/-isco", "tu" to "-i/-isci", "lui/lei" to "-e/-isce", "noi" to "-iamo", "voi" to "-ite", "loro" to "-ono/-iscono")
                ),
                conjugation = Conjugation(
                    verb = "DORMIRE / FINIRE",
                    forms = mapOf("io" to "dormo / finisco", "tu" to "dormi / finisci", "lui/lei" to "dorme / finisce", "noi" to "dormiamo / finiamo", "voi" to "dormite / finite", "loro" to "dormono / finiscono")
                )
            )
        ),
        auxiliaries = listOf(
            Auxiliary(
                verb = "ESSERE (être)",
                usage = "Auxiliaire pour verbes de mouvement, réfléchis et voix passive.",
                forms = mapOf("io" to "sono", "tu" to "sei", "lui/lei" to "è", "noi" to "siamo", "voi" to "siete", "loro" to "sono"),
                examples = listOf("Sono italiano.", "Siamo arrivati.")
            ),
            Auxiliary(
                verb = "AVERE (avoir)",
                usage = "Auxiliaire pour la plupart des verbes transitifs.",
                forms = mapOf("io" to "ho", "tu" to "hai", "lui/lei" to "ha", "noi" to "abbiamo", "voi" to "avete", "loro" to "hanno"),
                examples = listOf("Ho fame.", "Abbiamo mangiato.")
            )
        ),
        tenses = listOf(
            Tense("Presente", "Actions actuelles ou habituelles", "Parlo italiano."),
            Tense("Passato prossimo", "Actions passées avec lien au présent", "Ho parlato con lui."),
            Tense("Imperfetto", "Actions passées habituelles ou descriptions", "Parlavo spesso con lei."),
            Tense("Futuro semplice", "Actions futures", "Parlerò domani."),
            Tense("Condizionale", "Actions hypothétiques ou polies", "Parlerei volentieri."),
            Tense("Congiuntivo", "Subjonctif - doute, souhait", "Spero che tu parli."),
            Tense("Imperativo", "Ordres et conseils", "Parla! Parliamo!")
        ),
        irregulars = listOf(
            Irregular("andare", "aller", "vado, vai, va, andiamo, andate, vanno"),
            Irregular("venire", "venir", "vengo, vieni, viene, veniamo, venite, vengono"),
            Irregular("fare", "faire", "faccio, fai, fa, facciamo, fate, fanno"),
            Irregular("dire", "dire", "dico, dici, dice, diciamo, dite, dicono"),
            Irregular("stare", "rester/être", "sto, stai, sta, stiamo, state, stanno"),
            Irregular("dare", "donner", "do, dai, dà, diamo, date, danno"),
            Irregular("sapere", "savoir", "so, sai, sa, sappiamo, sapete, sanno"),
            Irregular("potere", "pouvoir", "posso, puoi, può, possiamo, potete, possono"),
            Irregular("volere", "vouloir", "voglio, vuoi, vuole, vogliamo, volete, vogliono"),
            Irregular("dovere", "devoir", "devo, devi, deve, dobbiamo, dovete, devono")
        ),
        pronouns = Pronouns(
            title = "Les pronoms personnels",
            subject = listOf(
                Pronoun("io", "je"), Pronoun("tu", "tu"), Pronoun("lui/lei", "il/elle"),
                Pronoun("noi", "nous"), Pronoun("voi", "vous"), Pronoun("loro", "ils/elles")
            ),
            direct = listOf(
                Pronoun("mi", "me"), Pronoun("ti", "te"), Pronoun("lo/la", "le/la"),
                Pronoun("ci", "nous"), Pronoun("vi", "vous"), Pronoun("li/le", "les (m/f)")
            ),
            indirect = listOf(
                Pronoun("mi", "me"), Pronoun("ti", "te"), Pronoun("gli/le", "lui/elle"),
                Pronoun("ci", "nous"), Pronoun("vi", "vous"), Pronoun("gli", "leur")
            )
        ),
        expressions = listOf(
            Expression("In bocca al lupo!", "Bonne chance!", "Dans la gueule du loup"),
            Expression("Che bello!", "Que c'est beau!"),
            Expression("Non vedo l'ora!", "J'ai hâte!", "Je ne vois pas l'heure"),
            Expression("Mamma mia!", "Mon Dieu!", "Ma mère!"),
            Expression("Fare bella figura", "Faire bonne impression"),
            Expression("Avere voglia di", "Avoir envie de"),
            Expression("Andare d'accordo", "S'entendre bien"),
            Expression("Essere al verde", "Être fauché", "Être au vert")
        ),
        prepositions = listOf(
            Preposition("a", "direction, lieu, heure", listOf("Vado a Roma.", "Alle tre.")),
            Preposition("di", "possession, matière, origine", listOf("Il libro di Marco.", "Sono di Milano.")),
            Preposition("da", "provenance, chez, depuis", listOf("Vengo da casa.", "Vado dal dottore.")),
            Preposition("in", "lieu (pays), moyen", listOf("Vivo in Italia.", "Vado in macchina.")),
            Preposition("con", "accompagnement, moyen", listOf("Vado con Maria.", "Scrivo con la penna.")),
            Preposition("su", "sur, à propos de", listOf("Il libro è sul tavolo.", "Un film su Roma.")),
            Preposition("per", "but, durée, destination", listOf("Studio per l'esame.", "Parto per Parigi.")),
            Preposition("tra/fra", "entre, dans (temps)", listOf("Tra me e te.", "Arrivo fra un'ora."))
        )
    )
    
    private fun getSpanishData() = Grammar(
        intro = Intro(
            title = "La conjugaison espagnole",
            description = "L'espagnol possède trois groupes : -AR, -ER et -IR. Particularité : SER et ESTAR pour 'être'."
        ),
        groups = listOf(
            Group(
                name = "1er groupe : -AR",
                description = "Le groupe le plus nombreux.",
                examples = listOf("hablar (parler)", "trabajar (travailler)", "estudiar (étudier)", "comprar (acheter)"),
                endings = mapOf(
                    "present" to mapOf("yo" to "-o", "tú" to "-as", "él/ella" to "-a", "nosotros" to "-amos", "vosotros" to "-áis", "ellos" to "-an")
                ),
                conjugation = Conjugation(
                    verb = "HABLAR",
                    forms = mapOf("yo" to "hablo", "tú" to "hablas", "él/ella" to "habla", "nosotros" to "hablamos", "vosotros" to "habláis", "ellos" to "hablan")
                )
            ),
            Group(
                name = "2ème groupe : -ER",
                description = "Groupe avec verbes très courants.",
                examples = listOf("comer (manger)", "beber (boire)", "leer (lire)", "aprender (apprendre)"),
                endings = mapOf(
                    "present" to mapOf("yo" to "-o", "tú" to "-es", "él/ella" to "-e", "nosotros" to "-emos", "vosotros" to "-éis", "ellos" to "-en")
                ),
                conjugation = Conjugation(
                    verb = "COMER",
                    forms = mapOf("yo" to "como", "tú" to "comes", "él/ella" to "come", "nosotros" to "comemos", "vosotros" to "coméis", "ellos" to "comen")
                )
            ),
            Group(
                name = "3ème groupe : -IR",
                description = "Similaire au 2ème mais avec différences.",
                examples = listOf("vivir (vivre)", "escribir (écrire)", "abrir (ouvrir)", "subir (monter)"),
                endings = mapOf(
                    "present" to mapOf("yo" to "-o", "tú" to "-es", "él/ella" to "-e", "nosotros" to "-imos", "vosotros" to "-ís", "ellos" to "-en")
                ),
                conjugation = Conjugation(
                    verb = "VIVIR",
                    forms = mapOf("yo" to "vivo", "tú" to "vives", "él/ella" to "vive", "nosotros" to "vivimos", "vosotros" to "vivís", "ellos" to "viven")
                )
            )
        ),
        auxiliaries = listOf(
            Auxiliary(
                verb = "SER (être - permanent)",
                usage = "Identité, nationalité, profession, caractéristiques permanentes.",
                forms = mapOf("yo" to "soy", "tú" to "eres", "él/ella" to "es", "nosotros" to "somos", "vosotros" to "sois", "ellos" to "son"),
                examples = listOf("Soy español.", "Es médico.", "Son las tres.")
            ),
            Auxiliary(
                verb = "ESTAR (être - état)",
                usage = "Localisation, états temporaires, émotions.",
                forms = mapOf("yo" to "estoy", "tú" to "estás", "él/ella" to "está", "nosotros" to "estamos", "vosotros" to "estáis", "ellos" to "están"),
                examples = listOf("Estoy cansado.", "Está en Madrid.", "La puerta está abierta.")
            ),
            Auxiliary(
                verb = "HABER (avoir - auxiliaire)",
                usage = "Uniquement auxiliaire pour temps composés.",
                forms = mapOf("yo" to "he", "tú" to "has", "él/ella" to "ha", "nosotros" to "hemos", "vosotros" to "habéis", "ellos" to "han"),
                examples = listOf("He comido.", "Hemos llegado.")
            ),
            Auxiliary(
                verb = "TENER (avoir - possession)",
                usage = "Possession, âge, sensations physiques.",
                forms = mapOf("yo" to "tengo", "tú" to "tienes", "él/ella" to "tiene", "nosotros" to "tenemos", "vosotros" to "tenéis", "ellos" to "tienen"),
                examples = listOf("Tengo hambre.", "Tiene 20 años.")
            )
        ),
        tenses = listOf(
            Tense("Presente", "Actions actuelles ou habituelles", "Hablo español."),
            Tense("Pretérito perfecto", "Passé composé - actions récentes", "He hablado con él."),
            Tense("Pretérito indefinido", "Passé simple - actions terminées", "Hablé ayer."),
            Tense("Pretérito imperfecto", "Imparfait - descriptions", "Hablaba mucho."),
            Tense("Futuro simple", "Actions futures", "Hablaré mañana."),
            Tense("Condicional", "Actions hypothétiques", "Hablaría si pudiera."),
            Tense("Subjuntivo", "Subjonctif - doute, souhait", "Espero que hables."),
            Tense("Imperativo", "Ordres et conseils", "¡Habla! ¡Hablemos!")
        ),
        irregulars = listOf(
            Irregular("ir", "aller", "voy, vas, va, vamos, vais, van"),
            Irregular("venir", "venir", "vengo, vienes, viene, venimos, venís, vienen"),
            Irregular("hacer", "faire", "hago, haces, hace, hacemos, hacéis, hacen"),
            Irregular("decir", "dire", "digo, dices, dice, decimos, decís, dicen"),
            Irregular("poder", "pouvoir", "puedo, puedes, puede, podemos, podéis, pueden"),
            Irregular("querer", "vouloir", "quiero, quieres, quiere, queremos, queréis, quieren"),
            Irregular("saber", "savoir", "sé, sabes, sabe, sabemos, sabéis, saben"),
            Irregular("poner", "mettre", "pongo, pones, pone, ponemos, ponéis, ponen"),
            Irregular("salir", "sortir", "salgo, sales, sale, salimos, salís, salen"),
            Irregular("dar", "donner", "doy, das, da, damos, dais, dan")
        ),
        pronouns = Pronouns(
            title = "Les pronoms personnels",
            subject = listOf(
                Pronoun("yo", "je"), Pronoun("tú", "tu"), Pronoun("él/ella/usted", "il/elle/vous"),
                Pronoun("nosotros/as", "nous"), Pronoun("vosotros/as", "vous"), Pronoun("ellos/ellas/ustedes", "ils/elles/vous")
            ),
            direct = listOf(
                Pronoun("me", "me"), Pronoun("te", "te"), Pronoun("lo/la", "le/la"),
                Pronoun("nos", "nous"), Pronoun("os", "vous"), Pronoun("los/las", "les")
            ),
            indirect = listOf(
                Pronoun("me", "me"), Pronoun("te", "te"), Pronoun("le", "lui"),
                Pronoun("nos", "nous"), Pronoun("os", "vous"), Pronoun("les", "leur")
            )
        ),
        expressions = listOf(
            Expression("¡Buena suerte!", "Bonne chance!"),
            Expression("¡Qué guay!", "Trop cool!"),
            Expression("¡No me digas!", "Sans blague!", "Ne me dis pas!"),
            Expression("Tener ganas de", "Avoir envie de"),
            Expression("Echar de menos", "Manquer (qqn)", "Jeter de moins"),
            Expression("Llevarse bien", "S'entendre bien"),
            Expression("Estar hecho polvo", "Être épuisé", "Être fait poussière"),
            Expression("Costar un ojo de la cara", "Coûter les yeux de la tête", "Coûter un œil du visage")
        ),
        prepositions = listOf(
            Preposition("a", "direction, COD personne, heure", listOf("Voy a Madrid.", "Veo a María.", "A las tres.")),
            Preposition("de", "possession, origine, matière", listOf("El libro de Juan.", "Soy de Francia.")),
            Preposition("en", "lieu, moyen de transport", listOf("Estoy en casa.", "Voy en coche.")),
            Preposition("con", "accompagnement, moyen", listOf("Voy con mi amigo.", "Escribo con bolígrafo.")),
            Preposition("por", "cause, lieu, durée", listOf("Por la mañana.", "Paseo por el parque.")),
            Preposition("para", "but, destination, délai", listOf("Estudio para el examen.", "Es para ti.")),
            Preposition("sin", "sans", listOf("Sin azúcar.", "Sin ti no puedo.")),
            Preposition("entre", "entre", listOf("Entre tú y yo.", "Entre las dos y las tres."))
        ),
        serEstar = SerEstar(
            title = "SER vs ESTAR : La grande différence",
            rules = listOf(
                SerEstarRule(
                    use = "SER",
                    cases = listOf("Identité permanente", "Nationalité", "Profession", "Heure et dates"),
                    examples = listOf("Soy francés.", "Es de madera.", "La fiesta es en mi casa.")
                ),
                SerEstarRule(
                    use = "ESTAR",
                    cases = listOf("Localisation", "États temporaires", "Émotions", "Résultat d'action"),
                    examples = listOf("Estoy en casa.", "Está cansado.", "La puerta está cerrada.")
                )
            )
        )
    )
}
