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

public struct ConjugationGrammarRule: Identifiable, Codable {
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
            ConjugationGrammarRule(
                title: "1er groupe : -ARE",
                description: "Le groupe le plus courant en italien",
                examples: ["parlare (parler)", "mangiare (manger)", "amare (aimer)", "lavorare (travailler)"],
                category: "Groupes"
            ),
            ConjugationGrammarRule(
                title: "2ème groupe : -ERE",
                description: "Groupe intermédiaire avec quelques irrégularités",
                examples: ["vedere (voir)", "leggere (lire)", "scrivere (écrire)", "prendere (prendre)"],
                category: "Groupes"
            ),
            ConjugationGrammarRule(
                title: "3ème groupe : -IRE",
                description: "Se divise en deux : réguliers et ceux avec -isc-",
                examples: ["dormire (dormir)", "partire (partir)", "finire (finir)", "capire (comprendre)"],
                category: "Groupes"
            ),
            ConjugationGrammarRule(
                title: "Auxiliaire ESSERE",
                description: "Utilisé pour les verbes de mouvement, réfléchis et voix passive",
                examples: ["Sono italiano", "Siamo arrivati", "La porta è aperta"],
                category: "Auxiliaires"
            ),
            ConjugationGrammarRule(
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
