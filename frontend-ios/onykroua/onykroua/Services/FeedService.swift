import Foundation

class FeedService: ObservableObject {
    @Published var items: [FeedItem] = []
    
    private var currentPage = 0
    private let itemsPerPage = 10
    private var allGeneratedItems: [FeedItem] = []
    
    init() {
        generateInitialContent()
    }
    
    private func generateInitialContent() {
        allGeneratedItems = []
        
        for _ in 0..<50 {
            let type = FeedItemType.allCases.randomElement()!
            allGeneratedItems.append(generateItem(type: type))
        }
        
        allGeneratedItems.shuffle()
    }
    
    func loadNextPage() -> [FeedItem] {
        let startIndex = currentPage * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, allGeneratedItems.count)
        
        guard startIndex < allGeneratedItems.count else {
            return []
        }
        
        let newItems = Array(allGeneratedItems[startIndex..<endIndex])
        currentPage += 1
        items.append(contentsOf: newItems)
        
        return newItems
    }
    
    func hasMore() -> Bool {
        return currentPage * itemsPerPage < allGeneratedItems.count
    }
    
    func reset() {
        currentPage = 0
        items = []
        generateInitialContent()
    }
    
    private func generateItem(type: FeedItemType) -> FeedItem {
        switch type {
        case .vocabulary:
            return generateVocabularyItem()
        case .conjugation:
            return generateConjugationItem()
        case .expression:
            return generateExpressionItem()
        case .culture:
            return generateCultureItem()
        case .quiz:
            return generateQuizItem()
        }
    }
    
    private func generateVocabularyItem() -> FeedItem {
        let words = [
            ("Ciao", "Salut", "Ciao, come stai?"),
            ("Grazie", "Merci", "Grazie mille!"),
            ("Buongiorno", "Bonjour", "Buongiorno, signora."),
            ("Amore", "Amour", "Ti voglio bene, amore mio."),
            ("Famiglia", "Famille", "La mia famiglia è grande."),
            ("Cibo", "Nourriture", "Il cibo italiano è delizioso."),
            ("Bella", "Belle", "Che bella giornata!"),
            ("Città", "Ville", "Roma è una città bellissima."),
            ("Viaggiare", "Voyager", "Mi piace viaggiare in Italia."),
            ("Musica", "Musique", "Ascolto la musica italiana.")
        ]
        
        let word = words.randomElement()!
        return FeedItem(
            type: .vocabulary,
            title: "📚 Mot du jour",
            content: word.0,
            translation: word.1,
            example: word.2,
            audioText: word.0
        )
    }
    
    private func generateConjugationItem() -> FeedItem {
        let verbs = [
            ("essere", "être", "io sono, tu sei, lui/lei è"),
            ("avere", "avoir", "io ho, tu hai, lui/lei ha"),
            ("fare", "faire", "io faccio, tu fai, lui/lei fa"),
            ("andare", "aller", "io vado, tu vai, lui/lei va"),
            ("venire", "venir", "io vengo, tu vieni, lui/lei viene")
        ]
        
        let verb = verbs.randomElement()!
        return FeedItem(
            type: .conjugation,
            title: "📖 Conjugaison",
            content: verb.0,
            translation: verb.1,
            example: verb.2,
            audioText: verb.2
        )
    }
    
    private func generateExpressionItem() -> FeedItem {
        let expressions = [
            ("In bocca al lupo!", "Bonne chance!", "Expression avant un examen ou événement important"),
            ("Mamma mia!", "Mon Dieu!", "Exclamation de surprise"),
            ("Che bello!", "Que c'est beau!", "Expression de joie"),
            ("Va bene!", "D'accord!", "Accord ou acceptation"),
            ("Non ci posso credere!", "Je n'y crois pas!", "Incrédulité")
        ]
        
        let expr = expressions.randomElement()!
        return FeedItem(
            type: .expression,
            title: "💬 Expression",
            content: expr.0,
            translation: expr.1,
            example: expr.2,
            audioText: expr.0
        )
    }
    
    private func generateCultureItem() -> FeedItem {
        let facts = [
            ("La Dolce Vita", "Le style de vie italien met l'accent sur la famille, la bonne nourriture et profiter de la vie.", "🇮🇹"),
            ("Le Colisée", "Monument emblématique de Rome, construit il y a 2000 ans.", "🏛️"),
            ("La Pizza", "Originaire de Naples, c'est un symbole de la cuisine italienne.", "🍕"),
            ("L'Opéra", "L'Italie est le berceau de l'opéra avec des compositeurs comme Verdi.", "🎭"),
            ("Les Vespas", "Scooter iconique italien, symbole de liberté.", "🛵")
        ]
        
        let fact = facts.randomElement()!
        return FeedItem(
            type: .culture,
            title: "\(fact.2) Culture",
            content: fact.0,
            translation: fact.1,
            example: nil,
            audioText: fact.0
        )
    }
    
    private func generateQuizItem() -> FeedItem {
        let quizzes = [
            ("Comment dit-on 'Bonjour' en italien?", "Buongiorno", "Ciao signifie 'Salut' de manière informelle"),
            ("Conjugue 'essere' (être) à la 1ère personne", "Io sono", "Essere est le verbe être en italien"),
            ("Quelle est la capitale de l'Italie?", "Roma", "Rome est la capitale et une ville historique"),
            ("Comment dit-on 'Merci beaucoup'?", "Grazie mille", "Expression courante de gratitude"),
            ("Quel est le pluriel de 'la casa'?", "Le case", "Le féminin pluriel prend 'le'")
        ]
        
        let quiz = quizzes.randomElement()!
        return FeedItem(
            type: .quiz,
            title: "🎯 Quiz",
            content: quiz.0,
            translation: quiz.1,
            example: quiz.2,
            audioText: quiz.1
        )
    }
    
    func toggleLike(itemId: String) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items[index].liked.toggle()
            items[index].likeCount += items[index].liked ? 1 : -1
        }
    }
    
    func toggleBookmark(itemId: String) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items[index].bookmarked.toggle()
        }
    }
}
