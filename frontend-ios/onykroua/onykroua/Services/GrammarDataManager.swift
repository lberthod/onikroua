import Foundation

class GrammarDataManager: ObservableObject {
    static let shared = GrammarDataManager()
    
    // Cache pour les groupes de règles
    private var groupedRulesCache: [String: [GrammarGroup]] = [:]
    
    private init() {}
    
    func getCategories() -> [GrammarCategory] {
        return [
            GrammarCategory(id: "all", label: "Toutes", icon: "📚", color: "#3498DB"),
            GrammarCategory(id: "articles", label: "Articles", icon: "📰", color: "#9B59B6"),
            GrammarCategory(id: "pronouns", label: "Pronoms", icon: "👤", color: "#E74C3C"),
            GrammarCategory(id: "verbs", label: "Verbes", icon: "⚡", color: "#27AE60"),
            GrammarCategory(id: "adjectives", label: "Adjectifs", icon: "✨", color: "#F39C12"),
            GrammarCategory(id: "adverbs", label: "Adverbes", icon: "🎯", color: "#E67E22"),
            GrammarCategory(id: "prepositions", label: "Prépositions", icon: "🔗", color: "#1ABC9C"),
            GrammarCategory(id: "conjunctions", label: "Conjonctions", icon: "🔀", color: "#16A085"),
            GrammarCategory(id: "nouns", label: "Noms", icon: "📝", color: "#8E44AD"),
            GrammarCategory(id: "syntax", label: "Syntaxe", icon: "🔧", color: "#34495E")
        ]
    }
    
    func getGrammarRules(language: String) -> [GrammarRule] {
        return language == "it" ? getItalianGrammar() : getSpanishGrammar()
    }
    
    func getSubCategoryLabel(_ subCategory: String) -> String {
        let labels: [String: String] = [
            "definite": "Articles définis",
            "indefinite": "Articles indéfinis",
            "partitive": "Articles partitifs",
            "contractions": "Contractions",
            "subject": "Pronoms sujets",
            "object": "Pronoms compléments d'objet",
            "indirect": "Pronoms compléments indirects",
            "reflexive": "Pronoms réfléchis",
            "possessive": "Pronoms/Adjectifs possessifs",
            "demonstrative": "Pronoms/Adjectifs démonstratifs",
            "relative": "Pronoms relatifs",
            "interrogative": "Pronoms interrogatifs",
            "indefinite_pronouns": "Pronoms indéfinis",
            "present": "Présent de l'indicatif",
            "past": "Temps du passé",
            "imperfect": "Imparfait",
            "preterite": "Passé simple",
            "perfect": "Passé composé",
            "pluperfect": "Plus-que-parfait",
            "future": "Futur",
            "conditional": "Conditionnel",
            "subjunctive": "Subjonctif",
            "imperative": "Impératif",
            "gerund": "Gérondif",
            "participle": "Participes",
            "infinitive": "Infinitif",
            "modal": "Verbes modaux",
            "auxiliary": "Auxiliaires",
            "irregular": "Verbes irréguliers",
            "agreement": "Accord des adjectifs",
            "position": "Position des adjectifs",
            "comparison": "Comparatif et superlatif",
            "demonstrative_adj": "Adjectifs démonstratifs",
            "possessive_adj": "Adjectifs possessifs",
            "numeral": "Adjectifs numéraux",
            "manner": "Adverbes de manière",
            "time": "Adverbes de temps",
            "place": "Adverbes de lieu",
            "quantity": "Adverbes de quantité",
            "affirmation": "Adverbes d'affirmation/négation",
            "formation": "Formation des adverbes",
            "simple": "Prépositions simples",
            "common": "Prépositions courantes",
            "combined": "Prépositions articulées",
            "location": "Prépositions de lieu",
            "time_prep": "Prépositions de temps",
            "usage": "Usages particuliers",
            "coordination": "Conjonctions de coordination",
            "subordination": "Conjonctions de subordination",
            "gender": "Genre des noms",
            "plural": "Formation du pluriel",
            "diminutive": "Diminutifs et augmentatifs",
            "word_order": "Ordre des mots",
            "negation": "La négation",
            "questions": "Formation des questions",
            "reported_speech": "Discours indirect",
            "passive": "Voix passive"
        ]
        return labels[subCategory] ?? subCategory
    }
    
    func filterRules(_ rules: [GrammarRule], category: String, difficulty: String, searchQuery: String) -> [GrammarRule] {
        var filtered = rules
        
        if category != "all" {
            filtered = filtered.filter { $0.category == category }
        }
        
        if difficulty != "all" {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            filtered = filtered.filter { rule in
                rule.rule.lowercased().contains(query) ||
                rule.content.lowercased().contains(query) ||
                (rule.example?.lowercased().contains(query) ?? false) ||
                (rule.translation?.lowercased().contains(query) ?? false)
            }
        }
        
        return filtered
    }
    
    func groupRules(_ rules: [GrammarRule]) -> [GrammarGroup] {
        // Créer une clé de cache basée sur les IDs des règles
        let cacheKey = rules.map { $0.id }.joined(separator: ",")
        
        // Vérifier le cache
        if let cached = groupedRulesCache[cacheKey] {
            return cached
        }
        
        // Calculer et mettre en cache
        let grouped = Dictionary(grouping: rules, by: { $0.subCategory })
        let result = grouped.map { subCategory, rules in
            GrammarGroup(
                subCategory: subCategory,
                label: getSubCategoryLabel(subCategory),
                rules: rules
            )
        }.sorted { $0.label < $1.label }
        
        groupedRulesCache[cacheKey] = result
        return result
    }
    
    private func getItalianGrammar() -> [GrammarRule] {
        return [
            GrammarRule(
                id: "it_art_1",
                category: "articles",
                subCategory: "definite",
                rule: "Articles définis masculin singulier",
                content: "IL : devant consonne (sauf s+cons, z, gn, ps, x, y)\nLO : devant s+consonne, z, gn, ps, x, y, i+voyelle\nL' : devant voyelle (a, e, i, o, u)",
                example: "il libro (le livre), il ragazzo (le garçon), lo studente (l'étudiant), lo zio (l'oncle), l'amico (l'ami)",
                translation: "LO s'utilise pour faciliter la prononciation",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "it_art_2",
                category: "articles",
                subCategory: "definite",
                rule: "Articles définis masculin pluriel",
                content: "I : devant consonne (sauf s+cons, z, gn, ps, x, y)\nGLI : devant s+consonne, z, gn, ps, x, y, voyelle",
                example: "i libri (les livres), i ragazzi (les garçons), gli studenti (les étudiants), gli amici (les amis)",
                translation: "GLI = pluriel de LO et L' masculin",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "it_art_3",
                category: "articles",
                subCategory: "definite",
                rule: "Articles définis féminin",
                content: "LA : devant consonne\nL' : devant voyelle\nLE : pluriel (toujours)",
                example: "la casa (la maison), la ragazza (la fille), l'amica (l'amie), le case (les maisons)",
                translation: "Plus simple que le masculin : seulement 3 formes",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "it_pro_1",
                category: "pronouns",
                subCategory: "subject",
                rule: "Pronoms sujets personnels",
                content: "1ʳᵉ pers. : io (je), noi (nous)\n2ᵉ pers. : tu (tu), voi (vous)\n3ᵉ pers. : lui (il), lei (elle), Lei (vous formel), loro (ils/elles)",
                example: "Io parlo italiano. (Je parle italien.)\nTu sei gentile. (Tu es gentil.)\nLei lavora a Roma. (Vous travaillez à Rome - formel)",
                translation: "Souvent omis car la terminaison verbale suffit",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "it_verb_1",
                category: "verbs",
                subCategory: "present",
                rule: "Présent - Verbes en -ARE",
                content: "Terminaisons : -o, -i, -a, -iamo, -ate, -ano\nExemple avec PARLARE (parler) :\nparlo, parli, parla, parliamo, parlate, parlano",
                example: "Io parlo italiano. (Je parle italien.)\nTu parli francese. (Tu parles français.)",
                translation: "Groupe le plus régulier",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "it_verb_2",
                category: "verbs",
                subCategory: "present",
                rule: "Présent - Verbes en -ERE",
                content: "Terminaisons : -o, -i, -e, -iamo, -ete, -ono\nExemple avec VEDERE (voir) :\nvedo, vedi, vede, vediamo, vedete, vedono",
                example: "Vedo la casa. (Je vois la maison.)\nLoro vedono il film. (Ils voient le film.)",
                translation: "Attention à l'accent tonique variable",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "it_verb_3",
                category: "verbs",
                subCategory: "present",
                rule: "Présent - Verbes en -IRE (type 1)",
                content: "Terminaisons : -o, -i, -e, -iamo, -ite, -ono\nExemple avec PARTIRE (partir) :\nparto, parti, parte, partiamo, partite, partono",
                example: "Parto domani. (Je pars demain.)\nPartiamo insieme. (Nous partons ensemble.)",
                translation: "Verbes sans -isc-",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "it_verb_4",
                category: "verbs",
                subCategory: "present",
                rule: "Présent - Verbes en -IRE (type 2)",
                content: "Terminaisons avec -isc- : -isco, -isci, -isce, -iamo, -ite, -iscono\nExemple avec FINIRE (finir) :\nfinisco, finisci, finisce, finiamo, finite, finiscono",
                example: "Finisco il lavoro. (Je finis le travail.)\nCapisco l'italiano. (Je comprends l'italien.)",
                translation: "La majorité des verbes en -IRE",
                difficulty: "intermédiaire"
            ),
            GrammarRule(
                id: "it_adj_1",
                category: "adjectives",
                subCategory: "agreement",
                rule: "Accord des adjectifs",
                content: "Masculin -o → Féminin -a\nMasculin -o → Pluriel -i\nFéminin -a → Pluriel -e\nAdjectifs en -e : même forme masc/fém, pluriel -i",
                example: "il ragazzo bello → la ragazza bella\ni ragazzi belli → le ragazze belle\nil libro grande → la casa grande → i libri grandi",
                translation: "Les adjectifs s'accordent toujours",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "it_prep_1",
                category: "prepositions",
                subCategory: "simple",
                rule: "Prépositions simples",
                content: "di (de), a (à), da (de/depuis), in (dans), con (avec), su (sur), per (pour), tra/fra (entre)",
                example: "Vado a Roma. (Je vais à Rome.)\nVengo da Milano. (Je viens de Milan.)\nCon gli amici. (Avec les amis.)",
                translation: "Base de la grammaire italienne",
                difficulty: "débutant"
            )
        ]
    }
    
    private func getSpanishGrammar() -> [GrammarRule] {
        return [
            GrammarRule(
                id: "es_art_1",
                category: "articles",
                subCategory: "definite",
                rule: "Articles définis",
                content: "Masculin : el (sing.), los (plur.)\nFéminin : la (sing.), las (plur.)",
                example: "el libro (le livre), la casa (la maison), los libros (les livres), las casas (les maisons)",
                translation: "Plus simple qu'en italien",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "es_art_2",
                category: "articles",
                subCategory: "indefinite",
                rule: "Articles indéfinis",
                content: "Masculin : un (sing.), unos (plur.)\nFéminin : una (sing.), unas (plur.)",
                example: "un libro (un livre), una casa (une maison), unos libros (des livres), unas casas (des maisons)",
                translation: "Système régulier",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "es_verb_1",
                category: "verbs",
                subCategory: "present",
                rule: "Présent - Verbes en -AR",
                content: "Terminaisons : -o, -as, -a, -amos, -áis, -an\nExemple avec HABLAR (parler) :\nhablo, hablas, habla, hablamos, habláis, hablan",
                example: "Yo hablo español. (Je parle espagnol.)\nTú hablas francés. (Tu parles français.)",
                translation: "Groupe majoritaire",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "es_verb_2",
                category: "verbs",
                subCategory: "present",
                rule: "Présent - Verbes en -ER",
                content: "Terminaisons : -o, -es, -e, -emos, -éis, -en\nExemple avec COMER (manger) :\ncomo, comes, come, comemos, coméis, comen",
                example: "Como pan. (Je mange du pain.)\nEllos comen fruta. (Ils mangent des fruits.)",
                translation: "Réguliers et fréquents",
                difficulty: "débutant"
            ),
            GrammarRule(
                id: "es_verb_3",
                category: "verbs",
                subCategory: "present",
                rule: "Présent - Verbes en -IR",
                content: "Terminaisons : -o, -es, -e, -imos, -ís, -en\nExemple avec VIVIR (vivre) :\nvivo, vives, vive, vivimos, vivís, viven",
                example: "Vivo en Madrid. (Je vis à Madrid.)\nVivimos juntos. (Nous vivons ensemble.)",
                translation: "Similaire aux verbes en -ER",
                difficulty: "débutant"
            )
        ]
    }
}
