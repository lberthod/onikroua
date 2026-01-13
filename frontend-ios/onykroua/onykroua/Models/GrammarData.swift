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
    public let id: String = UUID().uuidString
    public let name: String
    public let description: String
    public let example: String
}

public struct GrammarRule: Identifiable, Codable {
    public let id: String = UUID().uuidString
    public let title: String
    public let description: String
    public let examples: [String]
    public let category: String
}

public struct Pronoun: Identifiable, Codable {
    public let id: String = UUID().uuidString
    public let pronoun: String
    public let translation: String
    public let type: String // "subject", "direct", "indirect"
}

public class GrammarData: ObservableObject {
    
    public init() {}
    
    public func getVerbs(language: String) -> [Verb] {
        return language == "it" ? getItalianVerbs() : getSpanishVerbs()
    }
    
    public func getTenses(language: String) -> [TenseInfo] {
        return language == "it" ? getItalianTenses() : getSpanishTenses()
    }
    
    public func getGrammarRules(language: String) -> [GrammarRule] {
        return language == "it" ? getItalianRules() : getSpanishRules()
    }
    
    public func getPronouns(language: String) -> [Pronoun] {
        return language == "it" ? getItalianPronouns() : getSpanishPronouns()
    }
    
    // MARK: - Italian Data
    
    private func getItalianVerbs() -> [Verb] {
        return [
            Verb(
                verb: "essere",
                translation: "être",
                conjugations: [
                    "Présent": ["io": "sono", "tu": "sei", "lui/lei": "è", "noi": "siamo", "voi": "siete", "loro": "sono"],
                    "Passé composé": ["io": "sono stato/a", "tu": "sei stato/a", "lui/lei": "è stato/a", "noi": "siamo stati/e", "voi": "siete stati/e", "loro": "sono stati/e"],
                    "Futur": ["io": "sarò", "tu": "sarai", "lui/lei": "sarà", "noi": "saremo", "voi": "sarete", "loro": "saranno"],
                    "Imparfait": ["io": "ero", "tu": "eri", "lui/lei": "era", "noi": "eravamo", "voi": "eravate", "loro": "erano"],
                    "Conditionnel": ["io": "sarei", "tu": "saresti", "lui/lei": "sarebbe", "noi": "saremmo", "voi": "sareste", "loro": "sarebbero"]
                ],
                group: "Auxiliaire",
                isIrregular: true
            ),
            Verb(
                verb: "avere",
                translation: "avoir",
                conjugations: [
                    "Présent": ["io": "ho", "tu": "hai", "lui/lei": "ha", "noi": "abbiamo", "voi": "avete", "loro": "hanno"],
                    "Passé composé": ["io": "ho avuto", "tu": "hai avuto", "lui/lei": "ha avuto", "noi": "abbiamo avuto", "voi": "avete avuto", "loro": "hanno avuto"],
                    "Futur": ["io": "avrò", "tu": "avrai", "lui/lei": "avrà", "noi": "avremo", "voi": "avrete", "loro": "avranno"],
                    "Imparfait": ["io": "avevo", "tu": "avevi", "lui/lei": "aveva", "noi": "avevamo", "voi": "avevate", "loro": "avevano"],
                    "Conditionnel": ["io": "avrei", "tu": "avresti", "lui/lei": "avrebbe", "noi": "avremmo", "voi": "avreste", "loro": "avrebbero"]
                ],
                group: "Auxiliaire",
                isIrregular: true
            ),
            Verb(
                verb: "parlare",
                translation: "parler",
                conjugations: [
                    "Présent": ["io": "parlo", "tu": "parli", "lui/lei": "parla", "noi": "parliamo", "voi": "parlate", "loro": "parlano"],
                    "Passé composé": ["io": "ho parlato", "tu": "hai parlato", "lui/lei": "ha parlato", "noi": "abbiamo parlato", "voi": "avete parlato", "loro": "hanno parlato"],
                    "Futur": ["io": "parlerò", "tu": "parlerai", "lui/lei": "parlerà", "noi": "parleremo", "voi": "parlerete", "loro": "parleranno"],
                    "Imparfait": ["io": "parlavo", "tu": "parlavi", "lui/lei": "parlava", "noi": "parlavamo", "voi": "parlavate", "loro": "parlavano"],
                    "Conditionnel": ["io": "parlerei", "tu": "parleresti", "lui/lei": "parlerebbe", "noi": "parleremmo", "voi": "parlereste", "loro": "parlerebbero"]
                ],
                group: "-ARE",
                isIrregular: false
            ),
            Verb(
                verb: "andare",
                translation: "aller",
                conjugations: [
                    "Présent": ["io": "vado", "tu": "vai", "lui/lei": "va", "noi": "andiamo", "voi": "andate", "loro": "vanno"],
                    "Passé composé": ["io": "sono andato/a", "tu": "sei andato/a", "lui/lei": "è andato/a", "noi": "siamo andati/e", "voi": "siete andati/e", "loro": "sono andati/e"],
                    "Futur": ["io": "andrò", "tu": "andrai", "lui/lei": "andrà", "noi": "andremo", "voi": "andrete", "loro": "andranno"],
                    "Imparfait": ["io": "andavo", "tu": "andavi", "lui/lei": "andava", "noi": "andavamo", "voi": "andavate", "loro": "andavano"],
                    "Conditionnel": ["io": "andrei", "tu": "andresti", "lui/lei": "andrebbe", "noi": "andremmo", "voi": "andreste", "loro": "andrebbero"]
                ],
                group: "Mouvement",
                isIrregular: true
            ),
            Verb(
                verb: "fare",
                translation: "faire",
                conjugations: [
                    "Présent": ["io": "faccio", "tu": "fai", "lui/lei": "fa", "noi": "facciamo", "voi": "fate", "loro": "fanno"],
                    "Passé composé": ["io": "ho fatto", "tu": "hai fatto", "lui/lei": "ha fatto", "noi": "abbiamo fatto", "voi": "avete fatto", "loro": "hanno fatto"],
                    "Futur": ["io": "farò", "tu": "farai", "lui/lei": "farà", "noi": "faremo", "voi": "farete", "loro": "faranno"],
                    "Imparfait": ["io": "facevo", "tu": "facevi", "lui/lei": "faceva", "noi": "facevamo", "voi": "facevate", "loro": "facevano"],
                    "Conditionnel": ["io": "farei", "tu": "faresti", "lui/lei": "farebbe", "noi": "faremmo", "voi": "fareste", "loro": "farebbero"]
                ],
                group: "Irregulier",
                isIrregular: true
            )
        ]
    }
    
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
    
    private func getItalianRules() -> [GrammarRule] {
        return [
            GrammarRule(
                title: "1er groupe : -ARE",
                description: "Le groupe le plus courant en italien",
                examples: ["parlare (parler)", "mangiare (manger)", "amare (aimer)", "lavorare (travailler)"],
                category: "Groupes"
            ),
            GrammarRule(
                title: "2ème groupe : -ERE",
                description: "Groupe intermédiaire avec quelques irrégularités",
                examples: ["vedere (voir)", "leggere (lire)", "scrivere (écrire)", "prendere (prendre)"],
                category: "Groupes"
            ),
            GrammarRule(
                title: "3ème groupe : -IRE",
                description: "Se divise en deux : réguliers et ceux avec -isc-",
                examples: ["dormire (dormir)", "partire (partir)", "finire (finir)", "capire (comprendre)"],
                category: "Groupes"
            ),
            GrammarRule(
                title: "Auxiliaire ESSERE",
                description: "Utilisé pour les verbes de mouvement, réfléchis et voix passive",
                examples: ["Sono italiano", "Siamo arrivati", "La porta è aperta"],
                category: "Auxiliaires"
            ),
            GrammarRule(
                title: "Auxiliaire AVERE",
                description: "Utilisé pour la plupart des verbes transitifs",
                examples: ["Ho fame", "Abbiamo mangiato", "Ho un libro"],
                category: "Auxiliaires"
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
    
    private func getSpanishVerbs() -> [Verb] {
        return [
            Verb(
                verb: "ser",
                translation: "être (permanent)",
                conjugations: [
                    "Présent": ["yo": "soy", "tú": "eres", "él/ella": "es", "nosotros": "somos", "vosotros": "sois", "ellos": "son"],
                    "Passé composé": ["yo": "he sido", "tú": "has sido", "él/ella": "ha sido", "nosotros": "hemos sido", "vosotros": "habéis sido", "ellos": "han sido"],
                    "Futur": ["yo": "seré", "tú": "serás", "él/ella": "será", "nosotros": "seremos", "vosotros": "seréis", "ellos": "serán"],
                    "Imparfait": ["yo": "era", "tú": "eras", "él/ella": "era", "nosotros": "éramos", "vosotros": "erais", "ellos": "eran"],
                    "Conditionnel": ["yo": "sería", "tú": "serías", "él/ella": "sería", "nosotros": "seríamos", "vosotros": "seríais", "ellos": "serían"]
                ],
                group: "Auxiliaire",
                isIrregular: true
            ),
            Verb(
                verb: "estar",
                translation: "être (état)",
                conjugations: [
                    "Présent": ["yo": "estoy", "tú": "estás", "él/ella": "está", "nosotros": "estamos", "vosotros": "estáis", "ellos": "están"],
                    "Passé composé": ["yo": "he estado", "tú": "has estado", "él/ella": "ha estado", "nosotros": "hemos estado", "vosotros": "habéis estado", "ellos": "han estado"],
                    "Futur": ["yo": "estaré", "tú": "estarás", "él/ella": "estará", "nosotros": "estaremos", "vosotros": "estaréis", "ellos": "estarán"],
                    "Imparfait": ["yo": "estaba", "tú": "estabas", "él/ella": "estaba", "nosotros": "estábamos", "vosotros": "estabais", "ellos": "estaban"],
                    "Conditionnel": ["yo": "estaría", "tú": "estarías", "él/ella": "estaría", "nosotros": "estaríamos", "vosotros": "estaríais", "ellos": "estarían"]
                ],
                group: "Auxiliaire",
                isIrregular: true
            ),
            Verb(
                verb: "hablar",
                translation: "parler",
                conjugations: [
                    "Présent": ["yo": "hablo", "tú": "hablas", "él/ella": "habla", "nosotros": "hablamos", "vosotros": "habláis", "ellos": "hablan"],
                    "Passé composé": ["yo": "he hablado", "tú": "has hablado", "él/ella": "ha hablado", "nosotros": "hemos hablado", "vosotros": "habéis hablado", "ellos": "han hablado"],
                    "Futur": ["yo": "hablaré", "tú": "hablarás", "él/ella": "hablará", "nosotros": "hablaremos", "vosotros": "hablaréis", "ellos": "hablarán"],
                    "Imparfait": ["yo": "hablaba", "tú": "hablabas", "él/ella": "hablaba", "nosotros": "hablábamos", "vosotros": "hablabais", "ellos": "hablaban"],
                    "Conditionnel": ["yo": "hablaría", "tú": "hablarías", "él/ella": "hablaría", "nosotros": "hablaríamos", "vosotros": "hablaríais", "ellos": "hablarían"]
                ],
                group: "-AR",
                isIrregular: false
            ),
            Verb(
                verb: "ir",
                translation: "aller",
                conjugations: [
                    "Présent": ["yo": "voy", "tú": "vas", "él/ella": "va", "nosotros": "vamos", "vosotros": "vais", "ellos": "van"],
                    "Passé composé": ["yo": "he ido", "tú": "has ido", "él/ella": "ha ido", "nosotros": "hemos ido", "vosotros": "habéis ido", "ellos": "han ido"],
                    "Futur": ["yo": "iré", "tú": "irás", "él/ella": "irá", "nosotros": "iremos", "vosotros": "iréis", "ellos": "irán"],
                    "Imparfait": ["yo": "iba", "tú": "ibas", "él/ella": "iba", "nosotros": "íbamos", "vosotros": "ibais", "ellos": "iban"],
                    "Conditionnel": ["yo": "iría", "tú": "irías", "él/ella": "iría", "nosotros": "iríamos", "vosotros": "iríais", "ellos": "irían"]
                ],
                group: "Mouvement",
                isIrregular: true
            )
        ]
    }
    
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
    
    private func getSpanishRules() -> [GrammarRule] {
        return [
            GrammarRule(
                title: "1er groupe : -AR",
                description: "Le groupe le plus nombreux en espagnol",
                examples: ["hablar (parler)", "trabajar (travailler)", "estudiar (étudier)", "comprar (acheter)"],
                category: "Groupes"
            ),
            GrammarRule(
                title: "2ème groupe : -ER",
                description: "Groupe avec verbes très courants",
                examples: ["comer (manger)", "beber (boire)", "leer (lire)", "aprender (apprendre)"],
                category: "Groupes"
            ),
            GrammarRule(
                title: "3ème groupe : -IR",
                description: "Similaire au 2ème mais avec différences",
                examples: ["vivir (vivre)", "escribir (écrire)", "abrir (ouvrir)", "subir (monter)"],
                category: "Groupes"
            ),
            GrammarRule(
                title: "SER vs ESTAR",
                description: "Deux verbes pour 'être' avec usages différents",
                examples: ["Soy español (SER)", "Estoy cansado (ESTAR)", "Es médico (SER)", "Está en casa (ESTAR)"],
                category: "Auxiliaires"
            ),
            GrammarRule(
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
