import Foundation

public struct Verb: Identifiable, Codable {
    public let id: String
    public let verb: String
    public let translation: String
    public let conjugations: [String: [String: String]]
    public let group: String
    public let isIrregular: Bool
    
    public init(id: String = UUID().uuidString, verb: String, translation: String, conjugations: [String: [String: String]], group: String, isIrregular: Bool = false) {
        self.id = id
        self.verb = verb
        self.translation = translation
        self.conjugations = conjugations
        self.group = group
        self.isIrregular = isIrregular
    }
}

public struct TenseInfo: Identifiable, Codable {
    public var id: String = UUID().uuidString
    public let name: String
    public let description: String
    public let example: String
}

public struct ConjugationGrammarRule: Identifiable, Codable {
    public var id: String = UUID().uuidString
    public let title: String
    public let description: String
    public let examples: [String]
    public let category: String
}

public struct Pronoun: Identifiable, Codable {
    public var id: String = UUID().uuidString
    public let pronoun: String
    public let translation: String
    public let type: String // "subject", "direct", "indirect"
}

public class GrammarData: ObservableObject {
    
    public init() {}
    
    public func getVerbs(language: String) -> [Verb] {
        return VerbData.getVerbsByLanguage(language)
    }
    
    public func getTenses(language: String) -> [TenseInfo] {
        return language == "it" ? getItalianTenses() : getSpanishTenses()
    }
    
    public func getGrammarRules(language: String) -> [ConjugationGrammarRule] {
        return language == "it" ? getItalianRules() : getSpanishRules()
    }
    
    public func getPronouns(language: String) -> [Pronoun] {
        return language == "it" ? getItalianPronouns() : getSpanishPronouns()
    }
    
    // MARK: - Italian Data
    
    private func getItalianTenses() -> [TenseInfo] {
        return [
            TenseInfo(name: "Présent", description: "Actions actuelles ou habituelles", example: "Parlo italiano."),
            TenseInfo(name: "Passé composé", description: "Actions passées avec lien au présent", example: "Ho parlato con lui."),
            TenseInfo(name: "Imparfait", description: "Actions passées habituelles ou descriptions", example: "Parlavo spesso con lei."),
            TenseInfo(name: "Futur simple", description: "Actions futures", example: "Parlerò domani."),
            TenseInfo(name: "Conditionnel", description: "Actions hypothétiques ou polies", example: "Parlerei volentieri."),
            TenseInfo(name: "Subjonctif", description: "Doute, souhait, opinion", example: "Spero che tu parli."),
            TenseInfo(name: "Impératif", description: "Ordres et conseils", example: "Parla! Parliamo!")
        ]
    }
    
    private func getItalianRules() -> [ConjugationGrammarRule] {
        return [
            // GROUPES VERBAUX
            ConjugationGrammarRule(
                title: "1er groupe : -ARE",
                description: "Le groupe le plus courant en italien (90% des verbes réguliers)",
                examples: ["parlare → parlo, parli, parla", "mangiare → mangio, mangi, mangia", "amare → amo, ami, ama"],
                category: "Groupes"
            ),
            ConjugationGrammarRule(
                title: "2ème groupe : -ERE",
                description: "Groupe intermédiaire avec quelques irrégularités",
                examples: ["vedere → vedo, vedi, vede", "leggere → leggo, leggi, legge", "prendere → prendo, prendi, prende"],
                category: "Groupes"
            ),
            ConjugationGrammarRule(
                title: "3ème groupe : -IRE (type 1)",
                description: "Verbes réguliers sans -isc-",
                examples: ["dormire → dormo, dormi, dorme", "partire → parto, parti, parte"],
                category: "Groupes"
            ),
            ConjugationGrammarRule(
                title: "3ème groupe : -IRE (type 2)",
                description: "Verbes avec insertion de -isc- aux 3 personnes du singulier et 3e du pluriel",
                examples: ["finire → finisco, finisci, finisce", "capire → capisco, capisci, capisce"],
                category: "Groupes"
            ),
            
            // AUXILIAIRES
            ConjugationGrammarRule(
                title: "Auxiliaire ESSERE",
                description: "Utilisé pour: verbes de mouvement, réfléchis, intransitifs, passif",
                examples: ["Sono andato a Roma", "Mi sono lavato", "La porta è stata aperta"],
                category: "Auxiliaires"
            ),
            ConjugationGrammarRule(
                title: "Auxiliaire AVERE",
                description: "Utilisé pour la plupart des verbes transitifs et intransitifs d'état",
                examples: ["Ho mangiato la pizza", "Abbiamo parlato molto", "Ha dormito bene"],
                category: "Auxiliaires"
            ),
            ConjugationGrammarRule(
                title: "Accord du participe avec ESSERE",
                description: "Le participe passé s'accorde en genre et nombre avec le sujet",
                examples: ["Maria è andata (fém.)", "I ragazzi sono partiti (masc. pl.)", "Le ragazze sono arrivate (fém. pl.)"],
                category: "Auxiliaires"
            ),
            
            // ARTICLES
            ConjugationGrammarRule(
                title: "Articles définis (le, la, les)",
                description: "il (masc. sing.), lo (masc. s-impure), la (fém.), i (masc. pl.), gli (masc. pl.), le (fém. pl.)",
                examples: ["il libro", "lo studente", "la casa", "i libri", "gli studenti", "le case"],
                category: "Articles"
            ),
            ConjugationGrammarRule(
                title: "Articles indéfinis (un, une)",
                description: "un (masc.), uno (masc. s-impure/z), una (fém.), un' (fém. voyelle)",
                examples: ["un libro", "uno studente", "una casa", "un'amica"],
                category: "Articles"
            ),
            ConjugationGrammarRule(
                title: "Articles partitifs",
                description: "del, dello, della, dei, degli, delle (du, de la, des)",
                examples: ["del pane", "dell'acqua", "della pizza", "dei libri", "degli studenti"],
                category: "Articles"
            ),
            ConjugationGrammarRule(
                title: "Prépositions articulées",
                description: "Fusion de préposition + article: di+il=del, a+il=al, da+il=dal, in+il=nel, su+il=sul",
                examples: ["del ragazzo", "al cinema", "dal medico", "nel parco", "sul tavolo"],
                category: "Articles"
            ),
            
            // PRÉPOSITIONS
            ConjugationGrammarRule(
                title: "Préposition DI",
                description: "Possession, origine, matière, complément de nom",
                examples: ["Il libro di Marco", "Sono di Roma", "Una borsa di pelle", "Una tazza di caffè"],
                category: "Prépositions"
            ),
            ConjugationGrammarRule(
                title: "Préposition A",
                description: "Direction, lieu, heure, complément d'objet indirect",
                examples: ["Vado a Roma", "Abito a Milano", "Alle tre", "Parlo a Maria"],
                category: "Prépositions"
            ),
            ConjugationGrammarRule(
                title: "Préposition DA",
                description: "Provenance, chez quelqu'un, à partir de, usage",
                examples: ["Vengo da Parigi", "Vado dal medico", "Dalle 9 alle 5", "Occhiali da sole"],
                category: "Prépositions"
            ),
            ConjugationGrammarRule(
                title: "Préposition IN",
                description: "Lieu (pays, régions), moyen de transport, temps",
                examples: ["Vivo in Italia", "Vado in treno", "In estate", "In centro"],
                category: "Prépositions"
            ),
            ConjugationGrammarRule(
                title: "Prépositions CON, SU, PER",
                description: "CON (avec), SU (sur), PER (pour, pendant)",
                examples: ["Vado con Maria", "Sul tavolo", "Per te", "Per due ore"],
                category: "Prépositions"
            ),
            ConjugationGrammarRule(
                title: "Prépositions TRA/FRA",
                description: "Entre (deux éléments), dans (temps futur)",
                examples: ["Tra Roma e Milano", "Fra amici", "Tra due ore"],
                category: "Prépositions"
            ),
            
            // TEMPS & MODES
            ConjugationGrammarRule(
                title: "Passé composé vs Imparfait",
                description: "Passé composé: action ponctuelle terminée. Imparfait: action habituelle, description",
                examples: ["Ho mangiato (j'ai mangé)", "Mangiavo ogni giorno (je mangeais)", "Era bello (c'était beau)"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Passé simple (Passato remoto)",
                description: "Actions passées sans lien avec le présent, surtout dans le sud et à l'écrit",
                examples: ["Dante nacque nel 1265", "Colombo scoprì l'America", "Andai a Roma"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Plus-que-parfait (Trapassato prossimo)",
                description: "Action passée avant une autre action passée",
                examples: ["Avevo già mangiato quando sei arrivato", "Era già partito"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Futur simple",
                description: "Actions futures, hypothèses sur le présent",
                examples: ["Domani andrò a Roma", "Sarà vero? (Ce sera vrai?)", "Avrà 30 anni (Il doit avoir 30 ans)"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Futur antérieur",
                description: "Action future antérieure à une autre action future",
                examples: ["Quando avrò finito, uscirò", "Sarà già partito"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Conditionnel présent",
                description: "Politesse, hypothèse, désir, conseil",
                examples: ["Vorrei un caffè", "Dovresti studiare", "Sarebbe bello", "Andrei volentieri"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Conditionnel passé",
                description: "Hypothèse non réalisée dans le passé",
                examples: ["Sarei venuto ma ero malato", "Avrei voluto partire"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Subjonctif présent",
                description: "Après verbes de doute, souhait, opinion, émotion",
                examples: ["Penso che sia vero", "Voglio che tu venga", "Spero che faccia bel tempo"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Subjonctif imparfait",
                description: "Dans les hypothèses avec 'se', concordance des temps",
                examples: ["Se avessi tempo, verrei", "Pensavo che fosse vero", "Vorrei che venisse"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Gérondif",
                description: "Exprime la simultanéité, la manière, la cause",
                examples: ["Camminando ho incontrato Marco", "Mangiando si ingrassa", "Studiando imparerai"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Participe passé",
                description: "Formation: -ato, -uto, -ito. Nombreuses formes irrégulières",
                examples: ["parlato", "veduto/visto", "finito", "fatto", "detto", "scritto", "aperto"],
                category: "Temps"
            ),
            ConjugationGrammarRule(
                title: "Impératif",
                description: "Ordres et conseils. 2e sing. = infinitif sans -re pour -ARE/-ERE",
                examples: ["Parla! (tu)", "Parlate! (voi)", "Parliamo! (nous)", "Non parlare! (négatif tu)"],
                category: "Temps"
            ),
            
            // PRONOMS
            ConjugationGrammarRule(
                title: "Pronoms COD (Compléments d'Objet Direct)",
                description: "mi, ti, lo/la, ci, vi, li/le - placés avant le verbe conjugué",
                examples: ["Mi vedi? (Tu me vois?)", "Lo conosco (Je le connais)", "Le compro (Je les achète)"],
                category: "Pronoms"
            ),
            ConjugationGrammarRule(
                title: "Pronoms COI (Compléments d'Objet Indirect)",
                description: "mi, ti, gli/le, ci, vi, gli (loro) - à qui?",
                examples: ["Gli parlo (Je lui parle)", "Le telefono (Je lui téléphone)", "Ci scrive (Il nous écrit)"],
                category: "Pronoms"
            ),
            ConjugationGrammarRule(
                title: "Pronoms combinés",
                description: "COI + COD = me lo, te la, glielo, gliene, etc.",
                examples: ["Me lo dai? (Tu me le donnes?)", "Glielo dico (Je le lui dis)", "Te ne parlo (Je t'en parle)"],
                category: "Pronoms"
            ),
            ConjugationGrammarRule(
                title: "Pronom relatif CHE",
                description: "Qui/que invariable, remplace sujet ou COD",
                examples: ["Il ragazzo che parla", "La pizza che mangio", "Le persone che conosco"],
                category: "Pronoms"
            ),
            ConjugationGrammarRule(
                title: "Pronom relatif CUI",
                description: "Avec préposition (di cui, a cui, con cui, in cui)",
                examples: ["La persona di cui parlo", "La casa in cui abito", "L'amico con cui studio"],
                category: "Pronoms"
            ),
            ConjugationGrammarRule(
                title: "Pronom NE partitif",
                description: "En - remplace un complément avec 'di' ou une quantité",
                examples: ["Ne voglio due (J'en veux deux)", "Ne parliamo (Nous en parlons)", "Ne ho molti"],
                category: "Pronoms"
            ),
            ConjugationGrammarRule(
                title: "Pronom CI locatif",
                description: "Y - lieu où l'on est ou va",
                examples: ["Ci vado domani (J'y vais demain)", "Ci abito (J'y habite)", "Ci penso (J'y pense)"],
                category: "Pronoms"
            ),
            
            // ADJECTIFS
            ConjugationGrammarRule(
                title: "Accord des adjectifs",
                description: "L'adjectif s'accorde en genre et nombre avec le nom",
                examples: ["ragazzo alto / ragazza alta", "ragazzi alti / ragazze alte", "un bel libro / una bella casa"],
                category: "Adjectifs"
            ),
            ConjugationGrammarRule(
                title: "Position des adjectifs",
                description: "Généralement après le nom, mais certains avant (bello, buono, grande, piccolo...)",
                examples: ["un libro interessante", "una bella ragazza", "un buon amico", "una grande città"],
                category: "Adjectifs"
            ),
            ConjugationGrammarRule(
                title: "Adjectifs possessifs",
                description: "mio, tuo, suo, nostro, vostro, loro - avec article sauf famille singulier",
                examples: ["il mio libro", "la tua casa", "mio padre", "i nostri amici", "la loro macchina"],
                category: "Adjectifs"
            ),
            ConjugationGrammarRule(
                title: "Adjectifs démonstratifs",
                description: "questo (ce...ci, cet, cette) / quello (ce...là, cet, cette) - s'accorde",
                examples: ["questo libro", "questa casa", "quel ragazzo", "quella ragazza", "quei libri"],
                category: "Adjectifs"
            ),
            ConjugationGrammarRule(
                title: "Comparatif de supériorité",
                description: "più... di/che (plus... que)",
                examples: ["Marco è più alto di Paolo", "Più veloce che forte", "È più facile di quanto pensi"],
                category: "Adjectifs"
            ),
            ConjugationGrammarRule(
                title: "Comparatif d'infériorité",
                description: "meno... di/che (moins... que)",
                examples: ["Meno caro di quello", "Meno bello che utile", "Meno difficile di prima"],
                category: "Adjectifs"
            ),
            ConjugationGrammarRule(
                title: "Comparatif d'égalité",
                description: "così/tanto... come/quanto (aussi... que)",
                examples: ["Così alto come te", "Tanto bello quanto buono", "Alto quanto me"],
                category: "Adjectifs"
            ),
            ConjugationGrammarRule(
                title: "Superlatif relatif",
                description: "il più / il meno + adj. (le plus / le moins)",
                examples: ["Il più alto della classe", "La più bella città", "Il meno caro"],
                category: "Adjectifs"
            ),
            ConjugationGrammarRule(
                title: "Superlatif absolu",
                description: "Suffixe -issimo (très, extrêmement)",
                examples: ["bellissimo (très beau)", "facilissimo", "carissimo", "velocissimo"],
                category: "Adjectifs"
            ),
            ConjugationGrammarRule(
                title: "Comparatifs irréguliers",
                description: "buono→migliore, cattivo→peggiore, grande→maggiore, piccolo→minore",
                examples: ["È migliore di quello (meilleur)", "La peggiore idea", "Il maggiore problema"],
                category: "Adjectifs"
            ),
            
            // NÉGATION
            ConjugationGrammarRule(
                title: "Négation simple: NON",
                description: "Se place toujours devant le verbe conjugué",
                examples: ["Non parlo italiano", "Non è vero", "Non ho capito", "Non lo so"],
                category: "Négation"
            ),
            ConjugationGrammarRule(
                title: "NON... MAI",
                description: "Ne... jamais",
                examples: ["Non vado mai al cinema", "Non l'ho mai visto", "Non sono mai stato a Roma"],
                category: "Négation"
            ),
            ConjugationGrammarRule(
                title: "NON... NIENTE / NULLA",
                description: "Ne... rien",
                examples: ["Non ho niente", "Non capisco nulla", "Non fa niente (Ça ne fait rien)"],
                category: "Négation"
            ),
            ConjugationGrammarRule(
                title: "NON... NESSUNO",
                description: "Ne... personne / aucun",
                examples: ["Non c'è nessuno", "Non conosco nessuno", "Nessun problema"],
                category: "Négation"
            ),
            ConjugationGrammarRule(
                title: "NON... PIÙ",
                description: "Ne... plus",
                examples: ["Non studio più", "Non lo vedo più", "Non c'è più tempo"],
                category: "Négation"
            ),
            ConjugationGrammarRule(
                title: "NON... ANCORA",
                description: "Ne... pas encore",
                examples: ["Non è ancora arrivato", "Non ho ancora finito", "Non ancora"],
                category: "Négation"
            ),
            
            // AUTRES
            ConjugationGrammarRule(
                title: "Verbes réfléchis",
                description: "Se conjuguent avec mi, ti, si, ci, vi, si + auxiliaire ESSERE",
                examples: ["Mi lavo", "Ti vesti", "Si sveglia", "Ci divertiamo", "Si sono alzati"],
                category: "Autres"
            ),
            ConjugationGrammarRule(
                title: "Expression du temps qui passe",
                description: "Da + présent = depuis (action continue)",
                examples: ["Studio italiano da tre anni", "Abito qui dal 2020", "Aspetto da un'ora"],
                category: "Autres"
            ),
            ConjugationGrammarRule(
                title: "Expression de l'obligation",
                description: "Dovere + infinitif / Bisogna + infinitif",
                examples: ["Devo studiare", "Bisogna partire", "Si deve fare così"],
                category: "Autres"
            ),
            ConjugationGrammarRule(
                title: "Expression de la capacité",
                description: "Potere / Sapere + infinitif / Riuscire a + infinitif",
                examples: ["Posso parlare", "So nuotare", "Riesco a capire"],
                category: "Autres"
            ),
            ConjugationGrammarRule(
                title: "C'È / CI SONO",
                description: "Il y a (singulier / pluriel)",
                examples: ["C'è un problema", "Ci sono molte persone", "C'era una volta...", "Ci saranno problemi"],
                category: "Autres"
            )
        ]
    }
    
    private func getItalianPronouns() -> [Pronoun] {
        return [
            Pronoun(pronoun: "io", translation: "je", type: "subject"),
            Pronoun(pronoun: "tu", translation: "tu", type: "subject"),
            Pronoun(pronoun: "lui/lei", translation: "il/elle", type: "subject"),
            Pronoun(pronoun: "noi", translation: "nous", type: "subject"),
            Pronoun(pronoun: "voi", translation: "vous", type: "subject"),
            Pronoun(pronoun: "loro", translation: "ils/elles", type: "subject"),
            Pronoun(pronoun: "mi", translation: "me", type: "direct"),
            Pronoun(pronoun: "ti", translation: "te", type: "direct"),
            Pronoun(pronoun: "lo/la", translation: "le/la", type: "direct"),
            Pronoun(pronoun: "ci", translation: "nous", type: "direct"),
            Pronoun(pronoun: "vi", translation: "vous", type: "direct"),
            Pronoun(pronoun: "li/le", translation: "les", type: "direct")
        ]
    }
    
    // MARK: - Spanish Data
    
    private func getSpanishTenses() -> [TenseInfo] {
        return [
            TenseInfo(name: "Présent", description: "Actions actuelles ou habituelles", example: "Hablo español."),
            TenseInfo(name: "Passé composé", description: "Actions récentes avec lien au présent", example: "He hablado con él."),
            TenseInfo(name: "Passé simple", description: "Actions terminées dans le passé", example: "Hablé ayer."),
            TenseInfo(name: "Imparfait", description: "Descriptions ou actions passées habituelles", example: "Hablaba mucho."),
            TenseInfo(name: "Futur simple", description: "Actions futures", example: "Hablaré mañana."),
            TenseInfo(name: "Conditionnel", description: "Actions hypothétiques", example: "Hablaría si pudiera."),
            TenseInfo(name: "Subjonctif", description: "Doute, souhait, opinion", example: "Espero que hables."),
            TenseInfo(name: "Impératif", description: "Ordres et conseils", example: "¡Habla! ¡Hablemos!")
        ]
    }
    
    private func getSpanishRules() -> [ConjugationGrammarRule] {
        return [
            ConjugationGrammarRule(
                title: "1er groupe : -AR",
                description: "Le groupe le plus nombreux en espagnol",
                examples: ["hablar (parler)", "trabajar (travailler)", "estudiar (étudier)", "comprar (acheter)"],
                category: "Groupes"
            ),
            ConjugationGrammarRule(
                title: "2ème groupe : -ER",
                description: "Groupe avec verbes très courants",
                examples: ["comer (manger)", "beber (boire)", "leer (lire)", "aprender (apprendre)"],
                category: "Groupes"
            ),
            ConjugationGrammarRule(
                title: "3ème groupe : -IR",
                description: "Similaire au 2ème mais avec différences",
                examples: ["vivir (vivre)", "escribir (écrire)", "abrir (ouvrir)", "subir (monter)"],
                category: "Groupes"
            ),
            ConjugationGrammarRule(
                title: "SER vs ESTAR",
                description: "Deux verbes pour 'être' avec usages différents",
                examples: ["Soy español (SER)", "Estoy cansado (ESTAR)", "Es médico (SER)", "Está en casa (ESTAR)"],
                category: "Auxiliaires"
            ),
            ConjugationGrammarRule(
                title: "HABER vs TENER",
                description: "HABER comme auxiliaire, TENER pour possession",
                examples: ["He comido (HABER)", "Tengo hambre (TENER)", "Hemos llegado (HABER)", "Tiene 20 años (TENER)"],
                category: "Auxiliaires"
            )
        ]
    }
    
    private func getSpanishPronouns() -> [Pronoun] {
        return [
            Pronoun(pronoun: "yo", translation: "je", type: "subject"),
            Pronoun(pronoun: "tú", translation: "tu", type: "subject"),
            Pronoun(pronoun: "él/ella/usted", translation: "il/elle/vous", type: "subject"),
            Pronoun(pronoun: "nosotros/as", translation: "nous", type: "subject"),
            Pronoun(pronoun: "vosotros/as", translation: "vous", type: "subject"),
            Pronoun(pronoun: "ellos/ellas/ustedes", translation: "ils/elles/vous", type: "subject"),
            Pronoun(pronoun: "me", translation: "me", type: "direct"),
            Pronoun(pronoun: "te", translation: "te", type: "direct"),
            Pronoun(pronoun: "lo/la", translation: "le/la", type: "direct"),
            Pronoun(pronoun: "nos", translation: "nous", type: "direct"),
            Pronoun(pronoun: "os", translation: "vous", type: "direct"),
            Pronoun(pronoun: "los/las", translation: "les", type: "direct")
        ]
    }
}
