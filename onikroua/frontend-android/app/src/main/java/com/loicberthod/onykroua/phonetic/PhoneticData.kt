package com.loicberthod.onykroua.phonetic

object PhoneticData {
    
    fun getCategories(): List<PhoneticCategory> {
        return listOf(
            PhoneticCategory("all", "Tous", "📚"),
            PhoneticCategory("vowels", "Voyelles", "🔤"),
            PhoneticCategory("consonants", "Consonnes", "🔠"),
            PhoneticCategory("combinations", "Combinaisons", "🔗"),
            PhoneticCategory("accent", "Accent", "🎵"),
            PhoneticCategory("special", "Spéciaux", "⭐")
        )
    }
    
    fun getSounds(language: String, category: String = "all"): List<PhoneticSound> {
        val allSounds = if (language == "it") getItalianSounds() else getSpanishSounds()
        return if (category == "all") allSounds else allSounds.filter { it.category == category }
    }
    
    fun getPracticeWords(language: String): List<PracticeWord> {
        return if (language == "it") getItalianPracticeWords() else getSpanishPracticeWords()
    }
    
    private fun getItalianSounds(): List<PhoneticSound> {
        return listOf(
            PhoneticSound("it-a", "it", "vowels", "A", "/a/", 
                "Voyelle ouverte, comme le \"a\" français dans \"patte\"",
                listOf("casa", "amare", "strada"), difficulty = "easy",
                tips = "Prononcez comme en français, bouche bien ouverte"),
            
            PhoneticSound("it-e-open", "it", "vowels", "E (ouvert)", "/ɛ/",
                "E ouvert, comme dans \"père\" en français",
                listOf("bello", "festa", "tempo"), difficulty = "medium",
                tips = "Bouche plus ouverte que pour le E fermé",
                commonMistakes = "Confusion avec le E fermé"),
            
            PhoneticSound("it-e-closed", "it", "vowels", "E (fermé)", "/e/",
                "E fermé, comme dans \"été\" en français",
                listOf("sera", "verde", "pesce"), difficulty = "medium",
                tips = "Lèvres légèrement étirées"),
            
            PhoneticSound("it-i", "it", "vowels", "I", "/i/",
                "Voyelle fermée, comme le \"i\" français",
                listOf("libro", "vino", "finire"), difficulty = "easy"),
            
            PhoneticSound("it-o-open", "it", "vowels", "O (ouvert)", "/ɔ/",
                "O ouvert, comme dans \"mort\" en français",
                listOf("cosa", "porta", "forte"), difficulty = "medium"),
            
            PhoneticSound("it-o-closed", "it", "vowels", "O (fermé)", "/o/",
                "O fermé, comme dans \"beau\" en français",
                listOf("sole", "nome", "poco"), difficulty = "medium"),
            
            PhoneticSound("it-u", "it", "vowels", "U", "/u/",
                "Voyelle fermée arrondie, comme le \"ou\" français",
                listOf("uno", "luna", "muro"), difficulty = "easy",
                tips = "Lèvres arrondies et projetées"),
            
            PhoneticSound("it-c-hard", "it", "consonants", "C + a/o/u", "/k/",
                "C dur devant a, o, u - comme le \"k\" français",
                listOf("casa", "cosa", "cuore"), difficulty = "easy"),
            
            PhoneticSound("it-c-soft", "it", "consonants", "C + e/i", "/tʃ/",
                "C doux devant e, i - comme \"tch\" français",
                listOf("cena", "cinema", "cielo"), difficulty = "easy",
                tips = "Pensez au son \"tch\" de \"tchèque\""),
            
            PhoneticSound("it-g-hard", "it", "consonants", "G + a/o/u", "/g/",
                "G dur devant a, o, u - comme le \"g\" de \"gare\"",
                listOf("gatto", "gonna", "gusto"), difficulty = "easy"),
            
            PhoneticSound("it-g-soft", "it", "consonants", "G + e/i", "/dʒ/",
                "G doux devant e, i - comme \"dj\" français",
                listOf("gelato", "giro", "gente"), difficulty = "easy",
                tips = "Comme le \"j\" anglais dans \"job\""),
            
            PhoneticSound("it-r", "it", "consonants", "R", "/r/",
                "R roulé avec la pointe de la langue",
                listOf("Roma", "caro", "treno"), difficulty = "hard",
                tips = "Faites vibrer la pointe de la langue contre le palais",
                commonMistakes = "Ne pas utiliser le R français de gorge"),
            
            PhoneticSound("it-ch", "it", "combinations", "CH", "/k/",
                "CH devant e/i se prononce \"k\" (dur)",
                listOf("che", "chi", "chiesa", "perché"), difficulty = "medium",
                tips = "CH = K, contrairement au français !",
                commonMistakes = "Ne pas prononcer comme le \"ch\" français"),
            
            PhoneticSound("it-gh", "it", "combinations", "GH", "/g/",
                "GH devant e/i se prononce \"g\" dur",
                listOf("ghiaccio", "spaghetti", "laghi"), difficulty = "medium"),
            
            PhoneticSound("it-gli", "it", "combinations", "GLI", "/ʎ/",
                "GLI se prononce comme \"lli\" mouillé (comme \"ill\" dans \"fille\")",
                listOf("famiglia", "figlio", "moglie", "aglio"), difficulty = "hard",
                tips = "Langue contre le palais, son mouillé"),
            
            PhoneticSound("it-gn", "it", "combinations", "GN", "/ɲ/",
                "GN se prononce comme en français dans \"agneau\"",
                listOf("gnocchi", "bagno", "montagna", "ognuno"), difficulty = "easy",
                tips = "Identique au français !"),
            
            PhoneticSound("it-sc-soft", "it", "combinations", "SC + e/i", "/ʃ/",
                "SC devant e/i se prononce \"ch\" français",
                listOf("pesce", "uscire", "scena", "sciare"), difficulty = "medium"),
            
            PhoneticSound("it-double", "it", "special", "Doubles consonnes", "/CC/",
                "Les doubles consonnes sont prononcées plus longtemps",
                listOf("pizza", "cappuccino", "mamma", "bello"), difficulty = "hard",
                tips = "Allongez le son de la consonne, faites une petite pause",
                commonMistakes = "pala ≠ palla, caro ≠ carro")
        )
    }
    
    private fun getSpanishSounds(): List<PhoneticSound> {
        return listOf(
            PhoneticSound("es-a", "es", "vowels", "A", "/a/",
                "Voyelle ouverte, comme le \"a\" français",
                listOf("casa", "agua", "mañana"), difficulty = "easy"),
            
            PhoneticSound("es-e", "es", "vowels", "E", "/e/",
                "E toujours fermé en espagnol (pas de distinction ouvert/fermé)",
                listOf("verde", "leche", "tres"), difficulty = "easy"),
            
            PhoneticSound("es-i", "es", "vowels", "I", "/i/",
                "Voyelle fermée, comme le \"i\" français",
                listOf("libro", "vino", "isla"), difficulty = "easy"),
            
            PhoneticSound("es-o", "es", "vowels", "O", "/o/",
                "O toujours fermé en espagnol",
                listOf("solo", "como", "poco"), difficulty = "easy"),
            
            PhoneticSound("es-u", "es", "vowels", "U", "/u/",
                "Voyelle fermée arrondie, comme \"ou\" français",
                listOf("uno", "luna", "mundo"), difficulty = "easy"),
            
            PhoneticSound("es-b-v", "es", "consonants", "B / V", "/b/ ou /β/",
                "B et V se prononcent de la même façon en espagnol",
                listOf("bien", "vino", "beber", "vivir"), difficulty = "medium",
                tips = "Entre deux voyelles, son plus doux (entre b et v)",
                commonMistakes = "Ne faites pas de différence b/v comme en français"),
            
            PhoneticSound("es-h", "es", "consonants", "H", "∅ (muet)",
                "H est toujours muet en espagnol",
                listOf("hola", "hora", "hacer"), difficulty = "easy",
                tips = "Ne prononcez jamais le H !"),
            
            PhoneticSound("es-j", "es", "consonants", "J", "/x/",
                "J = son guttural (comme le \"ch\" allemand)",
                listOf("jamón", "julio", "rojo"), difficulty = "hard",
                tips = "Son qui vient du fond de la gorge",
                commonMistakes = "Ce n'est pas le \"j\" français !"),
            
            PhoneticSound("es-r", "es", "consonants", "R", "/ɾ/",
                "R simple: un seul battement de langue",
                listOf("pero", "caro", "tres"), difficulty = "medium"),
            
            PhoneticSound("es-rr", "es", "consonants", "RR", "/r/",
                "RR roulé: plusieurs battements de langue",
                listOf("perro", "carro", "correo"), difficulty = "hard",
                tips = "Faites vibrer la langue plusieurs fois",
                commonMistakes = "pero (mais) ≠ perro (chien)"),
            
            PhoneticSound("es-ll", "es", "combinations", "LL", "/ʝ/ ou /ʃ/",
                "LL: \"y\" ou \"ch\" selon les régions",
                listOf("llamar", "calle", "lluvia"), difficulty = "medium",
                tips = "En Argentine: proche du \"ch\" français"),
            
            PhoneticSound("es-n-tilde", "es", "combinations", "Ñ", "/ɲ/",
                "Ñ = comme \"gn\" français dans \"agneau\"",
                listOf("España", "niño", "año", "mañana"), difficulty = "easy",
                tips = "Identique au \"gn\" français !"),
            
            PhoneticSound("es-qu", "es", "combinations", "QU", "/k/",
                "QU devant e/i = \"k\" (U muet)",
                listOf("que", "quiero", "pequeño"), difficulty = "easy",
                tips = "Le U ne se prononce pas"),
            
            PhoneticSound("es-accent", "es", "accent", "Accent tonique", "ˈ",
                "L'accent écrit indique la syllabe accentuée",
                listOf("música", "teléfono", "rápido", "café"), difficulty = "medium",
                tips = "L'accent change parfois le sens: si/sí, el/él")
        )
    }
    
    private fun getItalianPracticeWords(): List<PracticeWord> {
        return listOf(
            PracticeWord("ciao", "/tʃao/", "salut"),
            PracticeWord("grazie", "/ˈgrattsje/", "merci"),
            PracticeWord("prego", "/ˈprɛːgo/", "de rien"),
            PracticeWord("buongiorno", "/bwonˈdʒorno/", "bonjour"),
            PracticeWord("arrivederci", "/arriˈvedertʃi/", "au revoir"),
            PracticeWord("famiglia", "/faˈmiʎʎa/", "famille"),
            PracticeWord("spaghetti", "/spaˈgetti/", "spaghetti"),
            PracticeWord("cappuccino", "/kappuˈtʃiːno/", "cappuccino"),
            PracticeWord("pizza", "/ˈpittsa/", "pizza"),
            PracticeWord("gelato", "/dʒeˈlaːto/", "glace")
        )
    }
    
    private fun getSpanishPracticeWords(): List<PracticeWord> {
        return listOf(
            PracticeWord("hola", "/ˈola/", "salut"),
            PracticeWord("gracias", "/ˈgɾaθjas/", "merci"),
            PracticeWord("buenos días", "/ˈbwenos ˈdias/", "bonjour"),
            PracticeWord("adiós", "/aˈðjos/", "au revoir"),
            PracticeWord("por favor", "/poɾ faˈβoɾ/", "s'il vous plaît"),
            PracticeWord("España", "/esˈpaɲa/", "Espagne"),
            PracticeWord("mañana", "/maˈɲana/", "demain"),
            PracticeWord("cerveza", "/θerˈβeθa/", "bière"),
            PracticeWord("paella", "/paˈeʎa/", "paella"),
            PracticeWord("jamón", "/xaˈmon/", "jambon")
        )
    }
}
