package com.loicberthod.onykroua

data class Verb(
    val id: String,
    val verb: String,
    val translation: String,
    val language: String,
    val type: String = "regular",
    val conjugations: Map<String, Map<String, String>>
)

object VerbData {
    fun getVerbsByLanguage(language: String): List<Verb> {
        return if (language == "it") getItalianVerbs() else getSpanishVerbs()
    }
    
    fun getItalianVerbs(): List<Verb> {
        return listOf(
            Verb(
                id = "it-essere",
                verb = "essere --",
                translation = "être",
                language = "it",
                type = "auxiliaire",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "sono",
                        "tu" to "sei",
                        "lui/lei" to "è",
                        "noi" to "siamo",
                        "voi" to "siete",
                        "loro" to "sono"
                    ),
                    "Imparfait" to mapOf(
                        "io" to "ero",
                        "tu" to "eri",
                        "lui/lei" to "era",
                        "noi" to "eravamo",
                        "voi" to "eravate",
                        "loro" to "erano"
                    ),
                    "Futur" to mapOf(
                        "io" to "sarò",
                        "tu" to "sarai",
                        "lui/lei" to "sarà",
                        "noi" to "saremo",
                        "voi" to "sarete",
                        "loro" to "saranno"
                    )
                )
            ),
            Verb(
                id = "it-avere",
                verb = "avere",
                translation = "avoir",
                language = "it",
                type = "auxiliaire",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "ho",
                        "tu" to "hai",
                        "lui/lei" to "ha",
                        "noi" to "abbiamo",
                        "voi" to "avete",
                        "loro" to "hanno"
                    ),
                    "Imparfait" to mapOf(
                        "io" to "avevo",
                        "tu" to "avevi",
                        "lui/lei" to "aveva",
                        "noi" to "avevamo",
                        "voi" to "avevate",
                        "loro" to "avevano"
                    ),
                    "Futur" to mapOf(
                        "io" to "avrò",
                        "tu" to "avrai",
                        "lui/lei" to "avrà",
                        "noi" to "avremo",
                        "voi" to "avrete",
                        "loro" to "avranno"
                    )
                )
            ),
            Verb(
                id = "it-andare",
                verb = "andare",
                translation = "aller",
                language = "it",
                type = "mouvement",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "vado",
                        "tu" to "vai",
                        "lui/lei" to "va",
                        "noi" to "andiamo",
                        "voi" to "andate",
                        "loro" to "vanno"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "sono andato",
                        "tu" to "sei andato",
                        "lui/lei" to "è andato",
                        "noi" to "siamo andati",
                        "voi" to "siete andati",
                        "loro" to "sono andati"
                    ),
                    "Futur" to mapOf(
                        "io" to "andrò",
                        "tu" to "andrai",
                        "lui/lei" to "andrà",
                        "noi" to "andremo",
                        "voi" to "andrete",
                        "loro" to "andranno"
                    )
                )
            ),
            Verb(
                id = "it-fare",
                verb = "fare",
                translation = "faire",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "faccio",
                        "tu" to "fai",
                        "lui/lei" to "fa",
                        "noi" to "facciamo",
                        "voi" to "fate",
                        "loro" to "fanno"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho fatto",
                        "tu" to "hai fatto",
                        "lui/lei" to "ha fatto",
                        "noi" to "abbiamo fatto",
                        "voi" to "avete fatto",
                        "loro" to "hanno fatto"
                    )
                )
            ),
            Verb(
                id = "it-parlare",
                verb = "parlare",
                translation = "parler",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "parlo",
                        "tu" to "parli",
                        "lui/lei" to "parla",
                        "noi" to "parliamo",
                        "voi" to "parlate",
                        "loro" to "parlano"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho parlato",
                        "tu" to "hai parlato",
                        "lui/lei" to "ha parlato",
                        "noi" to "abbiamo parlato",
                        "voi" to "avete parlato",
                        "loro" to "hanno parlato"
                    )
                )
            ),
            Verb(
                id = "it-mangiare",
                verb = "mangiare",
                translation = "manger",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "mangio",
                        "tu" to "mangi",
                        "lui/lei" to "mangia",
                        "noi" to "mangiamo",
                        "voi" to "mangiate",
                        "loro" to "mangiano"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho mangiato",
                        "tu" to "hai mangiato",
                        "lui/lei" to "ha mangiato",
                        "noi" to "abbiamo mangiato",
                        "voi" to "avete mangiato",
                        "loro" to "hanno mangiato"
                    )
                )
            ),
            Verb(
                id = "it-vedere",
                verb = "vedere",
                translation = "voir",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "vedo",
                        "tu" to "vedi",
                        "lui/lei" to "vede",
                        "noi" to "vediamo",
                        "voi" to "vedete",
                        "loro" to "vedono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho visto",
                        "tu" to "hai visto",
                        "lui/lei" to "ha visto",
                        "noi" to "abbiamo visto",
                        "voi" to "avete visto",
                        "loro" to "hanno visto"
                    )
                )
            ),
            Verb(
                id = "it-dormire",
                verb = "dormire",
                translation = "dormir",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "dormo",
                        "tu" to "dormi",
                        "lui/lei" to "dorme",
                        "noi" to "dormiamo",
                        "voi" to "dormite",
                        "loro" to "dormono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho dormito",
                        "tu" to "hai dormito",
                        "lui/lei" to "ha dormito",
                        "noi" to "abbiamo dormito",
                        "voi" to "avete dormito",
                        "loro" to "hanno dormito"
                    )
                )
            ),
            Verb(
                id = "it-venire",
                verb = "venire",
                translation = "venir",
                language = "it",
                type = "mouvement",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "vengo",
                        "tu" to "vieni",
                        "lui/lei" to "viene",
                        "noi" to "veniamo",
                        "voi" to "venite",
                        "loro" to "vengono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "sono venuto",
                        "tu" to "sei venuto",
                        "lui/lei" to "è venuto",
                        "noi" to "siamo venuti",
                        "voi" to "siete venuti",
                        "loro" to "sono venuti"
                    )
                )
            ),
            Verb(
                id = "it-potere",
                verb = "potere",
                translation = "pouvoir",
                language = "it",
                type = "modal",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "posso",
                        "tu" to "puoi",
                        "lui/lei" to "può",
                        "noi" to "possiamo",
                        "voi" to "potete",
                        "loro" to "possono"
                    )
                )
            ),
            Verb(
                id = "it-volere",
                verb = "volere",
                translation = "vouloir",
                language = "it",
                type = "modal",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "voglio",
                        "tu" to "vuoi",
                        "lui/lei" to "vuole",
                        "noi" to "vogliamo",
                        "voi" to "volete",
                        "loro" to "vogliono"
                    )
                )
            ),
            Verb(
                id = "it-dovere",
                verb = "dovere",
                translation = "devoir",
                language = "it",
                type = "modal",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "devo",
                        "tu" to "devi",
                        "lui/lei" to "deve",
                        "noi" to "dobbiamo",
                        "voi" to "dovete",
                        "loro" to "devono"
                    )
                )
            ),
            Verb(
                id = "it-sapere",
                verb = "sapere",
                translation = "savoir",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "so",
                        "tu" to "sai",
                        "lui/lei" to "sa",
                        "noi" to "sappiamo",
                        "voi" to "sapete",
                        "loro" to "sanno"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho saputo",
                        "tu" to "hai saputo",
                        "lui/lei" to "ha saputo",
                        "noi" to "abbiamo saputo",
                        "voi" to "avete saputo",
                        "loro" to "hanno saputo"
                    )
                )
            ),
            Verb(
                id = "it-dire",
                verb = "dire",
                translation = "dire",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "dico",
                        "tu" to "dici",
                        "lui/lei" to "dice",
                        "noi" to "diciamo",
                        "voi" to "dite",
                        "loro" to "dicono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho detto",
                        "tu" to "hai detto",
                        "lui/lei" to "ha detto",
                        "noi" to "abbiamo detto",
                        "voi" to "avete detto",
                        "loro" to "hanno detto"
                    )
                )
            ),
            Verb(
                id = "it-stare",
                verb = "stare",
                translation = "rester / être",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "sto",
                        "tu" to "stai",
                        "lui/lei" to "sta",
                        "noi" to "stiamo",
                        "voi" to "state",
                        "loro" to "stanno"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "sono stato",
                        "tu" to "sei stato",
                        "lui/lei" to "è stato",
                        "noi" to "siamo stati",
                        "voi" to "siete stati",
                        "loro" to "sono stati"
                    )
                )
            ),
            Verb(
                id = "it-dare",
                verb = "dare",
                translation = "donner",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "do",
                        "tu" to "dai",
                        "lui/lei" to "dà",
                        "noi" to "diamo",
                        "voi" to "date",
                        "loro" to "danno"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho dato",
                        "tu" to "hai dato",
                        "lui/lei" to "ha dato",
                        "noi" to "abbiamo dato",
                        "voi" to "avete dato",
                        "loro" to "hanno dato"
                    )
                )
            ),
            Verb(
                id = "it-bere",
                verb = "bere",
                translation = "boire",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "bevo",
                        "tu" to "bevi",
                        "lui/lei" to "beve",
                        "noi" to "beviamo",
                        "voi" to "bevete",
                        "loro" to "bevono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho bevuto",
                        "tu" to "hai bevuto",
                        "lui/lei" to "ha bevuto",
                        "noi" to "abbiamo bevuto",
                        "voi" to "avete bevuto",
                        "loro" to "hanno bevuto"
                    )
                )
            ),
            Verb(
                id = "it-scrivere",
                verb = "scrivere",
                translation = "écrire",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "scrivo",
                        "tu" to "scrivi",
                        "lui/lei" to "scrive",
                        "noi" to "scriviamo",
                        "voi" to "scrivete",
                        "loro" to "scrivono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho scritto",
                        "tu" to "hai scritto",
                        "lui/lei" to "ha scritto",
                        "noi" to "abbiamo scritto",
                        "voi" to "avete scritto",
                        "loro" to "hanno scritto"
                    )
                )
            ),
            Verb(
                id = "it-leggere",
                verb = "leggere",
                translation = "lire",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "leggo",
                        "tu" to "leggi",
                        "lui/lei" to "legge",
                        "noi" to "leggiamo",
                        "voi" to "leggete",
                        "loro" to "leggono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho letto",
                        "tu" to "hai letto",
                        "lui/lei" to "ha letto",
                        "noi" to "abbiamo letto",
                        "voi" to "avete letto",
                        "loro" to "hanno letto"
                    )
                )
            ),
            Verb(
                id = "it-prendere",
                verb = "prendere",
                translation = "prendre",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "prendo",
                        "tu" to "prendi",
                        "lui/lei" to "prende",
                        "noi" to "prendiamo",
                        "voi" to "prendete",
                        "loro" to "prendono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho preso",
                        "tu" to "hai preso",
                        "lui/lei" to "ha preso",
                        "noi" to "abbiamo preso",
                        "voi" to "avete preso",
                        "loro" to "hanno preso"
                    )
                )
            ),
            Verb(
                id = "it-capire",
                verb = "capire",
                translation = "comprendre",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "capisco",
                        "tu" to "capisci",
                        "lui/lei" to "capisce",
                        "noi" to "capiamo",
                        "voi" to "capite",
                        "loro" to "capiscono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho capito",
                        "tu" to "hai capito",
                        "lui/lei" to "ha capito",
                        "noi" to "abbiamo capito",
                        "voi" to "avete capito",
                        "loro" to "hanno capito"
                    )
                )
            ),
            Verb(
                id = "it-finire",
                verb = "finire",
                translation = "finir",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "finisco",
                        "tu" to "finisci",
                        "lui/lei" to "finisce",
                        "noi" to "finiamo",
                        "voi" to "finite",
                        "loro" to "finiscono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho finito",
                        "tu" to "hai finito",
                        "lui/lei" to "ha finito",
                        "noi" to "abbiamo finito",
                        "voi" to "avete finito",
                        "loro" to "hanno finito"
                    )
                )
            ),
            Verb(
                id = "it-partire",
                verb = "partire",
                translation = "partir",
                language = "it",
                type = "mouvement",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "parto",
                        "tu" to "parti",
                        "lui/lei" to "parte",
                        "noi" to "partiamo",
                        "voi" to "partite",
                        "loro" to "partono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "sono partito",
                        "tu" to "sei partito",
                        "lui/lei" to "è partito",
                        "noi" to "siamo partiti",
                        "voi" to "siete partiti",
                        "loro" to "sono partiti"
                    )
                )
            ),
            Verb(
                id = "it-uscire",
                verb = "uscire",
                translation = "sortir",
                language = "it",
                type = "mouvement",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "esco",
                        "tu" to "esci",
                        "lui/lei" to "esce",
                        "noi" to "usciamo",
                        "voi" to "uscite",
                        "loro" to "escono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "sono uscito",
                        "tu" to "sei uscito",
                        "lui/lei" to "è uscito",
                        "noi" to "siamo usciti",
                        "voi" to "siete usciti",
                        "loro" to "sono usciti"
                    )
                )
            ),
            Verb(
                id = "it-conoscere",
                verb = "conoscere",
                translation = "connaître",
                language = "it",
                conjugations = mapOf(
                    "Présent" to mapOf(
                        "io" to "conosco",
                        "tu" to "conosci",
                        "lui/lei" to "conosce",
                        "noi" to "conosciamo",
                        "voi" to "conoscete",
                        "loro" to "conoscono"
                    ),
                    "Passato prossimo" to mapOf(
                        "io" to "ho conosciuto",
                        "tu" to "hai conosciuto",
                        "lui/lei" to "ha conosciuto",
                        "noi" to "abbiamo conosciuto",
                        "voi" to "avete conosciuto",
                        "loro" to "hanno conosciuto"
                    )
                )
            )
        )
    }
    
    fun getSpanishVerbs(): List<Verb> {
        return listOf(
            Verb(
                id = "es-ser",
                verb = "ser",
                translation = "être (permanent)",
                language = "es",
                type = "verbe clé",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "soy",
                        "tú" to "eres",
                        "él/ella" to "es",
                        "nosotros" to "somos",
                        "vosotros" to "sois",
                        "ellos" to "son"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he sido",
                        "tú" to "has sido",
                        "él/ella" to "ha sido",
                        "nosotros" to "hemos sido",
                        "vosotros" to "habéis sido",
                        "ellos" to "han sido"
                    ),
                    "Imparfait" to mapOf(
                        "yo" to "era",
                        "tú" to "eras",
                        "él/ella" to "era",
                        "nosotros" to "éramos",
                        "vosotros" to "erais",
                        "ellos" to "eran"
                    )
                )
            ),
            Verb(
                id = "es-estar",
                verb = "estar",
                translation = "être (temporaire)",
                language = "es",
                type = "verbe clé",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "estoy",
                        "tú" to "estás",
                        "él/ella" to "está",
                        "nosotros" to "estamos",
                        "vosotros" to "estáis",
                        "ellos" to "están"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he estado",
                        "tú" to "has estado",
                        "él/ella" to "ha estado",
                        "nosotros" to "hemos estado",
                        "vosotros" to "habéis estado",
                        "ellos" to "han estado"
                    )
                )
            ),
            Verb(
                id = "es-ir",
                verb = "ir",
                translation = "aller",
                language = "es",
                type = "mouvement",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "voy",
                        "tú" to "vas",
                        "él/ella" to "va",
                        "nosotros" to "vamos",
                        "vosotros" to "vais",
                        "ellos" to "van"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he ido",
                        "tú" to "has ido",
                        "él/ella" to "ha ido",
                        "nosotros" to "hemos ido",
                        "vosotros" to "habéis ido",
                        "ellos" to "han ido"
                    )
                )
            ),
            Verb(
                id = "es-haber",
                verb = "haber",
                translation = "avoir (auxiliaire)",
                language = "es",
                type = "verbe clé",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "he",
                        "tú" to "has",
                        "él/ella" to "ha",
                        "nosotros" to "hemos",
                        "vosotros" to "habéis",
                        "ellos" to "han"
                    )
                )
            ),
            Verb(
                id = "es-tener",
                verb = "tener",
                translation = "avoir (posséder)",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "tengo",
                        "tú" to "tienes",
                        "él/ella" to "tiene",
                        "nosotros" to "tenemos",
                        "vosotros" to "tenéis",
                        "ellos" to "tienen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he tenido",
                        "tú" to "has tenido",
                        "él/ella" to "ha tenido",
                        "nosotros" to "hemos tenido",
                        "vosotros" to "habéis tenido",
                        "ellos" to "han tenido"
                    )
                )
            ),
            Verb(
                id = "es-hablar",
                verb = "hablar",
                translation = "parler",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "hablo",
                        "tú" to "hablas",
                        "él/ella" to "habla",
                        "nosotros" to "hablamos",
                        "vosotros" to "habláis",
                        "ellos" to "hablan"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he hablado",
                        "tú" to "has hablado",
                        "él/ella" to "ha hablado",
                        "nosotros" to "hemos hablado",
                        "vosotros" to "habéis hablado",
                        "ellos" to "han hablado"
                    )
                )
            ),
            Verb(
                id = "es-comer",
                verb = "comer",
                translation = "manger",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "como",
                        "tú" to "comes",
                        "él/ella" to "come",
                        "nosotros" to "comemos",
                        "vosotros" to "coméis",
                        "ellos" to "comen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he comido",
                        "tú" to "has comido",
                        "él/ella" to "ha comido",
                        "nosotros" to "hemos comido",
                        "vosotros" to "habéis comido",
                        "ellos" to "han comido"
                    )
                )
            ),
            Verb(
                id = "es-vivir",
                verb = "vivir",
                translation = "vivre",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "vivo",
                        "tú" to "vives",
                        "él/ella" to "vive",
                        "nosotros" to "vivimos",
                        "vosotros" to "vivís",
                        "ellos" to "viven"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he vivido",
                        "tú" to "has vivido",
                        "él/ella" to "ha vivido",
                        "nosotros" to "hemos vivido",
                        "vosotros" to "habéis vivido",
                        "ellos" to "han vivido"
                    )
                )
            ),
            Verb(
                id = "es-hacer",
                verb = "hacer",
                translation = "faire",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "hago",
                        "tú" to "haces",
                        "él/ella" to "hace",
                        "nosotros" to "hacemos",
                        "vosotros" to "hacéis",
                        "ellos" to "hacen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he hecho",
                        "tú" to "has hecho",
                        "él/ella" to "ha hecho",
                        "nosotros" to "hemos hecho",
                        "vosotros" to "habéis hecho",
                        "ellos" to "han hecho"
                    )
                )
            ),
            Verb(
                id = "es-venir",
                verb = "venir",
                translation = "venir",
                language = "es",
                type = "mouvement",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "vengo",
                        "tú" to "vienes",
                        "él/ella" to "viene",
                        "nosotros" to "venimos",
                        "vosotros" to "venís",
                        "ellos" to "vienen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he venido",
                        "tú" to "has venido",
                        "él/ella" to "ha venido",
                        "nosotros" to "hemos venido",
                        "vosotros" to "habéis venido",
                        "ellos" to "han venido"
                    )
                )
            ),
            Verb(
                id = "es-poder",
                verb = "poder",
                translation = "pouvoir",
                language = "es",
                type = "modal",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "puedo",
                        "tú" to "puedes",
                        "él/ella" to "puede",
                        "nosotros" to "podemos",
                        "vosotros" to "podéis",
                        "ellos" to "pueden"
                    )
                )
            ),
            Verb(
                id = "es-querer",
                verb = "querer",
                translation = "vouloir",
                language = "es",
                type = "modal",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "quiero",
                        "tú" to "quieres",
                        "él/ella" to "quiere",
                        "nosotros" to "queremos",
                        "vosotros" to "queréis",
                        "ellos" to "quieren"
                    )
                )
            ),
            Verb(
                id = "es-saber",
                verb = "saber",
                translation = "savoir",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "sé",
                        "tú" to "sabes",
                        "él/ella" to "sabe",
                        "nosotros" to "sabemos",
                        "vosotros" to "sabéis",
                        "ellos" to "saben"
                    )
                )
            ),
            Verb(
                id = "es-dar",
                verb = "dar",
                translation = "donner",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "doy",
                        "tú" to "das",
                        "él/ella" to "da",
                        "nosotros" to "damos",
                        "vosotros" to "dais",
                        "ellos" to "dan"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he dado",
                        "tú" to "has dado",
                        "él/ella" to "ha dado",
                        "nosotros" to "hemos dado",
                        "vosotros" to "habéis dado",
                        "ellos" to "han dado"
                    )
                )
            ),
            Verb(
                id = "es-decir",
                verb = "decir",
                translation = "dire",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "digo",
                        "tú" to "dices",
                        "él/ella" to "dice",
                        "nosotros" to "decimos",
                        "vosotros" to "decís",
                        "ellos" to "dicen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he dicho",
                        "tú" to "has dicho",
                        "él/ella" to "ha dicho",
                        "nosotros" to "hemos dicho",
                        "vosotros" to "habéis dicho",
                        "ellos" to "han dicho"
                    )
                )
            ),
            Verb(
                id = "es-poner",
                verb = "poner",
                translation = "mettre",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "pongo",
                        "tú" to "pones",
                        "él/ella" to "pone",
                        "nosotros" to "ponemos",
                        "vosotros" to "ponéis",
                        "ellos" to "ponen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he puesto",
                        "tú" to "has puesto",
                        "él/ella" to "ha puesto",
                        "nosotros" to "hemos puesto",
                        "vosotros" to "habéis puesto",
                        "ellos" to "han puesto"
                    )
                )
            ),
            Verb(
                id = "es-salir",
                verb = "salir",
                translation = "sortir",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "salgo",
                        "tú" to "sales",
                        "él/ella" to "sale",
                        "nosotros" to "salimos",
                        "vosotros" to "salís",
                        "ellos" to "salen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he salido",
                        "tú" to "has salido",
                        "él/ella" to "ha salido",
                        "nosotros" to "hemos salido",
                        "vosotros" to "habéis salido",
                        "ellos" to "han salido"
                    )
                )
            ),
            Verb(
                id = "es-ver",
                verb = "ver",
                translation = "voir",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "veo",
                        "tú" to "ves",
                        "él/ella" to "ve",
                        "nosotros" to "vemos",
                        "vosotros" to "veis",
                        "ellos" to "ven"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he visto",
                        "tú" to "has visto",
                        "él/ella" to "ha visto",
                        "nosotros" to "hemos visto",
                        "vosotros" to "habéis visto",
                        "ellos" to "han visto"
                    )
                )
            ),
            Verb(
                id = "es-traer",
                verb = "traer",
                translation = "apporter",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "traigo",
                        "tú" to "traes",
                        "él/ella" to "trae",
                        "nosotros" to "traemos",
                        "vosotros" to "traéis",
                        "ellos" to "traen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he traído",
                        "tú" to "has traído",
                        "él/ella" to "ha traído",
                        "nosotros" to "hemos traído",
                        "vosotros" to "habéis traído",
                        "ellos" to "han traído"
                    )
                )
            ),
            Verb(
                id = "es-leer",
                verb = "leer",
                translation = "lire",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "leo",
                        "tú" to "lees",
                        "él/ella" to "lee",
                        "nosotros" to "leemos",
                        "vosotros" to "leéis",
                        "ellos" to "leen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he leído",
                        "tú" to "has leído",
                        "él/ella" to "ha leído",
                        "nosotros" to "hemos leído",
                        "vosotros" to "habéis leído",
                        "ellos" to "han leído"
                    )
                )
            ),
            Verb(
                id = "es-escribir",
                verb = "escribir",
                translation = "écrire",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "escribo",
                        "tú" to "escribes",
                        "él/ella" to "escribe",
                        "nosotros" to "escribimos",
                        "vosotros" to "escribís",
                        "ellos" to "escriben"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he escrito",
                        "tú" to "has escrito",
                        "él/ella" to "ha escrito",
                        "nosotros" to "hemos escrito",
                        "vosotros" to "habéis escrito",
                        "ellos" to "han escrito"
                    )
                )
            ),
            Verb(
                id = "es-beber",
                verb = "beber",
                translation = "boire",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "bebo",
                        "tú" to "bebes",
                        "él/ella" to "bebe",
                        "nosotros" to "bebemos",
                        "vosotros" to "bebéis",
                        "ellos" to "beben"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he bebido",
                        "tú" to "has bebido",
                        "él/ella" to "ha bebido",
                        "nosotros" to "hemos bebido",
                        "vosotros" to "habéis bebido",
                        "ellos" to "han bebido"
                    )
                )
            ),
            Verb(
                id = "es-conocer",
                verb = "conocer",
                translation = "connaître",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "conozco",
                        "tú" to "conoces",
                        "él/ella" to "conoce",
                        "nosotros" to "conocemos",
                        "vosotros" to "conocéis",
                        "ellos" to "conocen"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he conocido",
                        "tú" to "has conocido",
                        "él/ella" to "ha conocido",
                        "nosotros" to "hemos conocido",
                        "vosotros" to "habéis conocido",
                        "ellos" to "han conocido"
                    )
                )
            ),
            Verb(
                id = "es-entender",
                verb = "entender",
                translation = "comprendre",
                language = "es",
                conjugations = mapOf(
                    "Presente" to mapOf(
                        "yo" to "entiendo",
                        "tú" to "entiendes",
                        "él/ella" to "entiende",
                        "nosotros" to "entendemos",
                        "vosotros" to "entendéis",
                        "ellos" to "entienden"
                    ),
                    "Pretérito perfecto" to mapOf(
                        "yo" to "he entendido",
                        "tú" to "has entendido",
                        "él/ella" to "ha entendido",
                        "nosotros" to "hemos entendido",
                        "vosotros" to "habéis entendido",
                        "ellos" to "han entendido"
                    )
                )
            )
        )
    }
}
