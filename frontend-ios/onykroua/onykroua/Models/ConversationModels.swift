import Foundation

struct ConversationScenario: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let messages: [ConversationMessage]
}

struct ConversationMessage: Identifiable {
    let id = UUID()
    let text: String
    let translation: String
    let isUser: Bool
}

struct ConversationDataSource {
    static func getAllScenarios() -> [ConversationScenario] {
        return [
            ConversationScenario(
                name: "Restaurant",
                icon: "🍽️",
                color: "orange",
                messages: [
                    ConversationMessage(text: "Buongiorno! Avete un tavolo per due?", translation: "Bonjour! Avez-vous une table pour deux?", isUser: false),
                    ConversationMessage(text: "Sì, certo! Seguitemi.", translation: "Oui, bien sûr! Suivez-moi.", isUser: false),
                    ConversationMessage(text: "Il menu, per favore.", translation: "Le menu, s'il vous plaît.", isUser: true),
                    ConversationMessage(text: "Ecco il menu. Cosa desiderate da bere?", translation: "Voici le menu. Que désirez-vous boire?", isUser: false),
                    ConversationMessage(text: "Un bicchiere di vino rosso, per favore.", translation: "Un verre de vin rouge, s'il vous plaît.", isUser: true),
                    ConversationMessage(text: "Perfetto! E per mangiare?", translation: "Parfait! Et pour manger?", isUser: false),
                    ConversationMessage(text: "Vorrei la pasta al pomodoro.", translation: "Je voudrais les pâtes à la tomate.", isUser: true),
                    ConversationMessage(text: "Ottima scelta! Arrivo subito.", translation: "Excellent choix! J'arrive tout de suite.", isUser: false),
                    ConversationMessage(text: "Il conto, per favore.", translation: "L'addition, s'il vous plaît.", isUser: true),
                    ConversationMessage(text: "Sono 25 euro. Grazie mille!", translation: "Ça fait 25 euros. Merci beaucoup!", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Hôtel",
                icon: "🏨",
                color: "blue",
                messages: [
                    ConversationMessage(text: "Buonasera! Ho una prenotazione.", translation: "Bonsoir! J'ai une réservation.", isUser: true),
                    ConversationMessage(text: "Benvenuto! A che nome?", translation: "Bienvenue! À quel nom?", isUser: false),
                    ConversationMessage(text: "Il mio nome è Marco.", translation: "Mon nom est Marco.", isUser: true),
                    ConversationMessage(text: "Perfetto! Camera 205, secondo piano.", translation: "Parfait! Chambre 205, deuxième étage.", isUser: false),
                    ConversationMessage(text: "A che ora è la colazione?", translation: "À quelle heure est le petit-déjeuner?", isUser: true),
                    ConversationMessage(text: "Dalle 7 alle 10. Buon soggiorno!", translation: "De 7h à 10h. Bon séjour!", isUser: false),
                    ConversationMessage(text: "Dov'è la palestra?", translation: "Où est la salle de sport?", isUser: true),
                    ConversationMessage(text: "Al primo piano, accanto alla piscina.", translation: "Au premier étage, à côté de la piscine.", isUser: false),
                    ConversationMessage(text: "Il Wi-Fi funziona?", translation: "Le Wi-Fi fonctionne?", isUser: true),
                    ConversationMessage(text: "Sì, la password è: hotel2024", translation: "Oui, le mot de passe est: hotel2024", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Gare",
                icon: "🚂",
                color: "green",
                messages: [
                    ConversationMessage(text: "Buongiorno! Un biglietto per Roma, per favore.", translation: "Bonjour! Un billet pour Rome, s'il vous plaît.", isUser: true),
                    ConversationMessage(text: "Andata o andata e ritorno?", translation: "Aller simple ou aller-retour?", isUser: false),
                    ConversationMessage(text: "Andata e ritorno.", translation: "Aller-retour.", isUser: true),
                    ConversationMessage(text: "Quando parte?", translation: "Quand partez-vous?", isUser: false),
                    ConversationMessage(text: "Domani mattina.", translation: "Demain matin.", isUser: true),
                    ConversationMessage(text: "Il treno parte alle 9:15. Binario 3.", translation: "Le train part à 9h15. Quai 3.", isUser: false),
                    ConversationMessage(text: "Quanto costa?", translation: "Combien ça coûte?", isUser: true),
                    ConversationMessage(text: "45 euro. Carta o contanti?", translation: "45 euros. Carte ou espèces?", isUser: false),
                    ConversationMessage(text: "Carta, per favore.", translation: "Carte, s'il vous plaît.", isUser: true),
                    ConversationMessage(text: "Ecco il biglietto. Buon viaggio!", translation: "Voici le billet. Bon voyage!", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Shopping",
                icon: "🛍️",
                color: "purple",
                messages: [
                    ConversationMessage(text: "Buongiorno! Posso aiutarla?", translation: "Bonjour! Puis-je vous aider?", isUser: false),
                    ConversationMessage(text: "Sì, cerco una camicia.", translation: "Oui, je cherche une chemise.", isUser: true),
                    ConversationMessage(text: "Che taglia?", translation: "Quelle taille?", isUser: false),
                    ConversationMessage(text: "Taglia media.", translation: "Taille moyenne.", isUser: true),
                    ConversationMessage(text: "Che colore preferisce?", translation: "Quelle couleur préférez-vous?", isUser: false),
                    ConversationMessage(text: "Blu o bianca.", translation: "Bleu ou blanc.", isUser: true),
                    ConversationMessage(text: "Ecco, questa è molto bella!", translation: "Voilà, celle-ci est très belle!", isUser: false),
                    ConversationMessage(text: "Posso provare?", translation: "Puis-je essayer?", isUser: true),
                    ConversationMessage(text: "Certo! Il camerino è là.", translation: "Bien sûr! La cabine d'essayage est là.", isUser: false),
                    ConversationMessage(text: "Va bene! Quanto costa?", translation: "Ça va bien! Combien ça coûte?", isUser: true),
                    ConversationMessage(text: "35 euro. La prendo?", translation: "35 euros. Vous la prenez?", isUser: false),
                    ConversationMessage(text: "Sì, la prendo!", translation: "Oui, je la prends!", isUser: true)
                ]
            )
        ]
    }
}
