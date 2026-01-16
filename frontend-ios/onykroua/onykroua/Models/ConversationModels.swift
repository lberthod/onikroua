import Foundation

public struct ConversationScenario: Identifiable {
    public let id = UUID()
    public let name: String
    public let icon: String
    public let color: String
    public let messages: [ConversationMessage]
    
    public init(name: String, icon: String, color: String, messages: [ConversationMessage]) {
        self.name = name
        self.icon = icon
        self.color = color
        self.messages = messages
    }
}

public struct ConversationMessage: Identifiable {
    public let id = UUID()
    public let text: String
    public let translation: String
    public let isUser: Bool
    
    public init(text: String, translation: String, isUser: Bool) {
        self.text = text
        self.translation = translation
        self.isUser = isUser
    }
}

// Alias pour compatibilité avec le code existant
public struct ConversationData {
    public static func getScenarios(for language: String) -> [ConversationScenario] {
        // Pour l'instant, on retourne toujours les scénarios italiens
        // Plus tard, on pourra filtrer par langue
        return ConversationDataSource.getAllScenarios()
    }
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
            ),
            
            // NOUVEAUX SCÉNARIOS - VOYAGE
            ConversationScenario(
                name: "Aéroport - Check-in",
                icon: "✈️",
                color: "cyan",
                messages: [
                    ConversationMessage(text: "Buongiorno! Il suo passaporto e biglietto, per favore.", translation: "Bonjour! Votre passeport et billet, s'il vous plaît.", isUser: false),
                    ConversationMessage(text: "Ecco. Vado a Parigi.", translation: "Voici. Je vais à Paris.", isUser: true),
                    ConversationMessage(text: "Ha bagagli da imbarcare?", translation: "Avez-vous des bagages à enregistrer?", isUser: false),
                    ConversationMessage(text: "Sì, una valigia.", translation: "Oui, une valise.", isUser: true),
                    ConversationMessage(text: "Perfetto. Metta la valigia qui sulla bilancia.", translation: "Parfait. Mettez la valise ici sur la balance.", isUser: false),
                    ConversationMessage(text: "Va bene così?", translation: "C'est bon comme ça?", isUser: true),
                    ConversationMessage(text: "Sì, 18 chili. Posto finestrino o corridoio?", translation: "Oui, 18 kilos. Place fenêtre ou couloir?", isUser: false),
                    ConversationMessage(text: "Finestrino, per favore.", translation: "Fenêtre, s'il vous plaît.", isUser: true),
                    ConversationMessage(text: "Ecco la sua carta d'imbarco. Imbarco alle 10:45, uscita 24.", translation: "Voici votre carte d'embarquement. Embarquement à 10h45, porte 24.", isUser: false),
                    ConversationMessage(text: "Grazie mille! Buona giornata!", translation: "Merci beaucoup! Bonne journée!", isUser: true)
                ]
            ),
            ConversationScenario(
                name: "Douane",
                icon: "🛃",
                color: "red",
                messages: [
                    ConversationMessage(text: "Benvenuto in Italia! Passaporto, per favore.", translation: "Bienvenue en Italie! Passeport, s'il vous plaît.", isUser: false),
                    ConversationMessage(text: "Ecco il mio passaporto.", translation: "Voici mon passeport.", isUser: true),
                    ConversationMessage(text: "Qual è il motivo del suo viaggio?", translation: "Quel est le motif de votre voyage?", isUser: false),
                    ConversationMessage(text: "Turismo. Visito Roma per una settimana.", translation: "Tourisme. Je visite Rome pendant une semaine.", isUser: true),
                    ConversationMessage(text: "Dove alloggia?", translation: "Où logez-vous?", isUser: false),
                    ConversationMessage(text: "In un hotel vicino al Colosseo.", translation: "Dans un hôtel près du Colisée.", isUser: true),
                    ConversationMessage(text: "Ha qualcosa da dichiarare?", translation: "Avez-vous quelque chose à déclarer?", isUser: false),
                    ConversationMessage(text: "No, niente da dichiarare.", translation: "Non, rien à déclarer.", isUser: true),
                    ConversationMessage(text: "Perfetto. Benvenuto e buona permanenza!", translation: "Parfait. Bienvenue et bon séjour!", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Taxi",
                icon: "🚕",
                color: "yellow",
                messages: [
                    ConversationMessage(text: "Buongiorno! Dove andiamo?", translation: "Bonjour! Où allons-nous?", isUser: false),
                    ConversationMessage(text: "All'Hotel Venezia, per favore.", translation: "À l'Hôtel Venezia, s'il vous plaît.", isUser: true),
                    ConversationMessage(text: "Va bene. Sa l'indirizzo esatto?", translation: "D'accord. Vous connaissez l'adresse exacte?", isUser: false),
                    ConversationMessage(text: "Sì, è in Via Roma, numero 45.", translation: "Oui, c'est au 45 Via Roma.", isUser: true),
                    ConversationMessage(text: "Perfetto! Ci vogliono circa 15 minuti.", translation: "Parfait! Il faut environ 15 minutes.", isUser: false),
                    ConversationMessage(text: "Quanto costa più o meno?", translation: "Combien ça coûte à peu près?", isUser: true),
                    ConversationMessage(text: "Circa 20 euro con il traffico.", translation: "Environ 20 euros avec le trafic.", isUser: false),
                    ConversationMessage(text: "Accettate carte di credito?", translation: "Vous acceptez les cartes de crédit?", isUser: true),
                    ConversationMessage(text: "Sì, certo! Anche Apple Pay.", translation: "Oui, bien sûr! Aussi Apple Pay.", isUser: false),
                    ConversationMessage(text: "Siamo arrivati! Sono 22 euro.", translation: "Nous sommes arrivés! Ça fait 22 euros.", isUser: false),
                    ConversationMessage(text: "Ecco 25 euro. Tenga il resto!", translation: "Voici 25 euros. Gardez la monnaie!", isUser: true)
                ]
            ),
            ConversationScenario(
                name: "Informations Touristiques",
                icon: "🗺️",
                color: "teal",
                messages: [
                    ConversationMessage(text: "Buongiorno! Come posso aiutarla?", translation: "Bonjour! Comment puis-je vous aider?", isUser: false),
                    ConversationMessage(text: "Vorrei visitare i principali monumenti. Cosa mi consiglia?", translation: "Je voudrais visiter les principaux monuments. Que me conseillez-vous?", isUser: true),
                    ConversationMessage(text: "Le consiglio il Colosseo, i Fori Romani e il Vaticano.", translation: "Je vous conseille le Colisée, les Forums romains et le Vatican.", isUser: false),
                    ConversationMessage(text: "Quanto tempo serve per visitare tutto?", translation: "Combien de temps faut-il pour tout visiter?", isUser: true),
                    ConversationMessage(text: "Almeno 2-3 giorni per vedere bene tutto.", translation: "Au moins 2-3 jours pour bien tout voir.", isUser: false),
                    ConversationMessage(text: "C'è una card turistica?", translation: "Y a-t-il une carte touristique?", isUser: true),
                    ConversationMessage(text: "Sì! La Roma Pass costa 52 euro per 3 giorni.", translation: "Oui! La Roma Pass coûte 52 euros pour 3 jours.", isUser: false),
                    ConversationMessage(text: "Include i trasporti pubblici?", translation: "Elle inclut les transports publics?", isUser: true),
                    ConversationMessage(text: "Sì, metro, autobus e tram illimitati!", translation: "Oui, métro, bus et tram illimités!", isUser: false),
                    ConversationMessage(text: "Perfetto! Ne prendo una. Grazie!", translation: "Parfait! J'en prends une. Merci!", isUser: true)
                ]
            ),
            ConversationScenario(
                name: "Musée - Billets",
                icon: "🎫",
                color: "brown",
                messages: [
                    ConversationMessage(text: "Buongiorno! Quanti biglietti?", translation: "Bonjour! Combien de billets?", isUser: false),
                    ConversationMessage(text: "Due adulti, per favore.", translation: "Deux adultes, s'il vous plaît.", isUser: true),
                    ConversationMessage(text: "Volete l'audioguida?", translation: "Voulez-vous l'audioguide?", isUser: false),
                    ConversationMessage(text: "Sì, in francese se possibile.", translation: "Oui, en français si possible.", isUser: true),
                    ConversationMessage(text: "Certo! Sono 12 euro per biglietto, più 5 euro per audioguida.", translation: "Bien sûr! C'est 12 euros par billet, plus 5 euros pour l'audioguide.", isUser: false),
                    ConversationMessage(text: "Ci sono sconti per studenti?", translation: "Y a-t-il des réductions pour étudiants?", isUser: true),
                    ConversationMessage(text: "Sì, 50% con la carta studente.", translation: "Oui, 50% avec la carte étudiante.", isUser: false),
                    ConversationMessage(text: "Perfetto! Ecco le nostre carte.", translation: "Parfait! Voici nos cartes.", isUser: true),
                    ConversationMessage(text: "Benissimo! Totale: 22 euro. La mostra è al secondo piano.", translation: "Très bien! Total: 22 euros. L'exposition est au deuxième étage.", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Plage - Location",
                icon: "🏖️",
                color: "orange",
                messages: [
                    ConversationMessage(text: "Buongiorno! Volete un ombrellone?", translation: "Bonjour! Voulez-vous un parasol?", isUser: false),
                    ConversationMessage(text: "Sì, un ombrellone e due lettini.", translation: "Oui, un parasol et deux transats.", isUser: true),
                    ConversationMessage(text: "Per tutta la giornata?", translation: "Pour toute la journée?", isUser: false),
                    ConversationMessage(text: "Sì, fino a che ora?", translation: "Oui, jusqu'à quelle heure?", isUser: true),
                    ConversationMessage(text: "Fino alle 19. Costa 25 euro.", translation: "Jusqu'à 19h. Ça coûte 25 euros.", isUser: false),
                    ConversationMessage(text: "Va bene. La doccia è vicina?", translation: "D'accord. La douche est proche?", isUser: true),
                    ConversationMessage(text: "Sì, a destra, vicino al bar.", translation: "Oui, à droite, près du bar.", isUser: false),
                    ConversationMessage(text: "C'è un ristorante qui?", translation: "Y a-t-il un restaurant ici?", isUser: true),
                    ConversationMessage(text: "Sì, il nostro ristorante serve pranzo dalle 12 alle 15.", translation: "Oui, notre restaurant sert le déjeuner de 12h à 15h.", isUser: false)
                ]
            ),
            
            // VIE QUOTIDIENNE
            ConversationScenario(
                name: "Supermarché",
                icon: "🏪",
                color: "green",
                messages: [
                    ConversationMessage(text: "Buongiorno! Ha bisogno di aiuto?", translation: "Bonjour! Avez-vous besoin d'aide?", isUser: false),
                    ConversationMessage(text: "Sì, dove trovo il pane?", translation: "Oui, où puis-je trouver le pain?", isUser: true),
                    ConversationMessage(text: "Il reparto panetteria è in fondo a sinistra.", translation: "Le rayon boulangerie est au fond à gauche.", isUser: false),
                    ConversationMessage(text: "E il latte?", translation: "Et le lait?", isUser: true),
                    ConversationMessage(text: "I latticini sono al corridoio 5.", translation: "Les produits laitiers sont au couloir 5.", isUser: false),
                    ConversationMessage(text: "Avete frutta biologica?", translation: "Avez-vous des fruits bio?", isUser: true),
                    ConversationMessage(text: "Sì, nel reparto frutta e verdura, sezione bio.", translation: "Oui, au rayon fruits et légumes, section bio.", isUser: false),
                    ConversationMessage(text: "Quanto costa questo vino?", translation: "Combien coûte ce vin?", isUser: true),
                    ConversationMessage(text: "8,50 euro. È un Chianti molto buono!", translation: "8,50 euros. C'est un Chianti très bon!", isUser: false),
                    ConversationMessage(text: "Perfetto! Dove pago?", translation: "Parfait! Où je paie?", isUser: true),
                    ConversationMessage(text: "Le casse sono là in fondo. Buona giornata!", translation: "Les caisses sont là au fond. Bonne journée!", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Pharmacie",
                icon: "💊",
                color: "red",
                messages: [
                    ConversationMessage(text: "Buongiorno! Come posso aiutarla?", translation: "Bonjour! Comment puis-je vous aider?", isUser: false),
                    ConversationMessage(text: "Ho mal di testa. Ha qualcosa?", translation: "J'ai mal à la tête. Avez-vous quelque chose?", isUser: true),
                    ConversationMessage(text: "Sì, le consiglio questo. Due pastiglie ogni 6 ore.", translation: "Oui, je vous conseille ceci. Deux comprimés toutes les 6 heures.", isUser: false),
                    ConversationMessage(text: "Ha anche qualcosa per la tosse?", translation: "Avez-vous aussi quelque chose pour la toux?", isUser: true),
                    ConversationMessage(text: "Questo sciroppo è molto efficace.", translation: "Ce sirop est très efficace.", isUser: false),
                    ConversationMessage(text: "Ho bisogno di una ricetta medica?", translation: "Ai-je besoin d'une ordonnance médicale?", isUser: true),
                    ConversationMessage(text: "No, questi sono farmaci da banco.", translation: "Non, ce sont des médicaments en vente libre.", isUser: false),
                    ConversationMessage(text: "Perfetto! Quanto costa il totale?", translation: "Parfait! Combien coûte le total?", isUser: true),
                    ConversationMessage(text: "15,50 euro. Si senta meglio presto!", translation: "15,50 euros. Sentez-vous mieux bientôt!", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Coiffeur",
                icon: "✂️",
                color: "pink",
                messages: [
                    ConversationMessage(text: "Buongiorno! Ha un appuntamento?", translation: "Bonjour! Avez-vous un rendez-vous?", isUser: false),
                    ConversationMessage(text: "No, è possibile senza appuntamento?", translation: "Non, est-ce possible sans rendez-vous?", isUser: true),
                    ConversationMessage(text: "Sì, ma deve aspettare circa 20 minuti.", translation: "Oui, mais vous devez attendre environ 20 minutes.", isUser: false),
                    ConversationMessage(text: "Va bene, aspetto. Quanto costa un taglio?", translation: "D'accord, j'attends. Combien coûte une coupe?", isUser: true),
                    ConversationMessage(text: "Taglio uomo 25 euro, donna 35 euro.", translation: "Coupe homme 25 euros, femme 35 euros.", isUser: false),
                    ConversationMessage(text: "E con shampoo?", translation: "Et avec shampooing?", isUser: true),
                    ConversationMessage(text: "Con shampoo sono 5 euro in più.", translation: "Avec shampooing c'est 5 euros de plus.", isUser: false),
                    ConversationMessage(text: "Perfetto! Vorrei solo spuntare i capelli.", translation: "Parfait! Je voudrais juste couper les pointes.", isUser: true),
                    ConversationMessage(text: "Benissimo! Si accomodi pure. Caffè?", translation: "Très bien! Installez-vous. Un café?", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Poste",
                icon: "📦",
                color: "blue",
                messages: [
                    ConversationMessage(text: "Buongiorno! Cosa desidera?", translation: "Bonjour! Que désirez-vous?", isUser: false),
                    ConversationMessage(text: "Vorrei spedire questo pacco in Francia.", translation: "Je voudrais envoyer ce colis en France.", isUser: true),
                    ConversationMessage(text: "Quanto pesa?", translation: "Combien pèse-t-il?", isUser: false),
                    ConversationMessage(text: "Circa 2 chili.", translation: "Environ 2 kilos.", isUser: true),
                    ConversationMessage(text: "Posta ordinaria o prioritaria?", translation: "Courrier ordinaire ou prioritaire?", isUser: false),
                    ConversationMessage(text: "Prioritaria. Quanto tempo ci vuole?", translation: "Prioritaire. Combien de temps faut-il?", isUser: true),
                    ConversationMessage(text: "3-5 giorni lavorativi. Costa 18 euro.", translation: "3-5 jours ouvrables. Ça coûte 18 euros.", isUser: false),
                    ConversationMessage(text: "Vorrei anche un'assicurazione.", translation: "Je voudrais aussi une assurance.", isUser: true),
                    ConversationMessage(text: "Perfetto! Assicurazione fino a 100 euro, più 3 euro.", translation: "Parfait! Assurance jusqu'à 100 euros, plus 3 euros.", isUser: false),
                    ConversationMessage(text: "Va bene. Ecco il contenuto del pacco.", translation: "D'accord. Voici le contenu du colis.", isUser: true)
                ]
            ),
            ConversationScenario(
                name: "Banque",
                icon: "🏦",
                color: "indigo",
                messages: [
                    ConversationMessage(text: "Buongiorno! Come posso aiutarla?", translation: "Bonjour! Comment puis-je vous aider?", isUser: false),
                    ConversationMessage(text: "Vorrei aprire un conto corrente.", translation: "Je voudrais ouvrir un compte courant.", isUser: true),
                    ConversationMessage(text: "Certo! È residente in Italia?", translation: "Bien sûr! Êtes-vous résident en Italie?", isUser: false),
                    ConversationMessage(text: "Sì, da tre mesi. Ho un permesso di soggiorno.", translation: "Oui, depuis trois mois. J'ai un permis de séjour.", isUser: true),
                    ConversationMessage(text: "Perfetto! Ha con sé il passaporto e il codice fiscale?", translation: "Parfait! Avez-vous votre passeport et code fiscal avec vous?", isUser: false),
                    ConversationMessage(text: "Sì, ecco i documenti.", translation: "Oui, voici les documents.", isUser: true),
                    ConversationMessage(text: "Benissimo! Vuole anche una carta di credito?", translation: "Très bien! Voulez-vous aussi une carte de crédit?", isUser: false),
                    ConversationMessage(text: "Sì, quali sono le opzioni?", translation: "Oui, quelles sont les options?", isUser: true),
                    ConversationMessage(text: "Carta di debito gratuita, credito 30 euro all'anno.", translation: "Carte de débit gratuite, crédit 30 euros par an.", isUser: false),
                    ConversationMessage(text: "Prendo la carta di debito, grazie.", translation: "Je prends la carte de débit, merci.", isUser: true)
                ]
            ),
            ConversationScenario(
                name: "Service Client Téléphone",
                icon: "📞",
                color: "purple",
                messages: [
                    ConversationMessage(text: "Servizio clienti, buongiorno! Come posso aiutarla?", translation: "Service client, bonjour! Comment puis-je vous aider?", isUser: false),
                    ConversationMessage(text: "Ho un problema con la mia connessione internet.", translation: "J'ai un problème avec ma connexion internet.", isUser: true),
                    ConversationMessage(text: "Mi dispiace. Da quanto tempo?", translation: "Je suis désolé. Depuis combien de temps?", isUser: false),
                    ConversationMessage(text: "Da ieri sera. Non funziona più.", translation: "Depuis hier soir. Ça ne fonctionne plus.", isUser: true),
                    ConversationMessage(text: "Ha provato a riavviare il modem?", translation: "Avez-vous essayé de redémarrer le modem?", isUser: false),
                    ConversationMessage(text: "Sì, tre volte, ma niente.", translation: "Oui, trois fois, mais rien.", isUser: true),
                    ConversationMessage(text: "Qual è il suo numero cliente?", translation: "Quel est votre numéro client?", isUser: false),
                    ConversationMessage(text: "IT45789321.", translation: "IT45789321.", isUser: true),
                    ConversationMessage(text: "Vedo che c'è un guasto nella sua zona. Risolveremo entro 24 ore.", translation: "Je vois qu'il y a une panne dans votre zone. Nous résoudrons sous 24 heures.", isUser: false),
                    ConversationMessage(text: "Va bene, grazie per l'informazione!", translation: "D'accord, merci pour l'information!", isUser: true)
                ]
            ),
            
            // PROFESSIONNEL
            ConversationScenario(
                name: "Entretien d'embauche",
                icon: "💼",
                color: "gray",
                messages: [
                    ConversationMessage(text: "Buongiorno! Si accomodi pure.", translation: "Bonjour! Installez-vous.", isUser: false),
                    ConversationMessage(text: "Grazie mille per questa opportunità.", translation: "Merci beaucoup pour cette opportunité.", isUser: true),
                    ConversationMessage(text: "Allora, ci parli un po' di lei.", translation: "Alors, parlez-nous un peu de vous.", isUser: false),
                    ConversationMessage(text: "Ho 5 anni di esperienza nel marketing digitale.", translation: "J'ai 5 ans d'expérience en marketing digital.", isUser: true),
                    ConversationMessage(text: "Interessante! Quali sono i suoi punti di forza?", translation: "Intéressant! Quels sont vos points forts?", isUser: false),
                    ConversationMessage(text: "Sono creativo, organizzato e lavoro bene in squadra.", translation: "Je suis créatif, organisé et je travaille bien en équipe.", isUser: true),
                    ConversationMessage(text: "Perché vuole lavorare per noi?", translation: "Pourquoi voulez-vous travailler pour nous?", isUser: false),
                    ConversationMessage(text: "Ammiro molto la vostra innovazione e cultura aziendale.", translation: "J'admire beaucoup votre innovation et culture d'entreprise.", isUser: true),
                    ConversationMessage(text: "Ha domande per noi?", translation: "Avez-vous des questions pour nous?", isUser: false),
                    ConversationMessage(text: "Sì, quali sono le opportunità di crescita?", translation: "Oui, quelles sont les opportunités de croissance?", isUser: true),
                    ConversationMessage(text: "Ottime possibilità! Le faremo sapere entro una settimana.", translation: "Excellentes possibilités! Nous vous ferons savoir sous une semaine.", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Réunion de travail",
                icon: "🤝",
                color: "teal",
                messages: [
                    ConversationMessage(text: "Buongiorno a tutti! Iniziamo la riunione.", translation: "Bonjour à tous! Commençons la réunion.", isUser: false),
                    ConversationMessage(text: "Buongiorno! Ho preparato i dati di vendita.", translation: "Bonjour! J'ai préparé les données de vente.", isUser: true),
                    ConversationMessage(text: "Ottimo! Quali sono i risultati del trimestre?", translation: "Excellent! Quels sont les résultats du trimestre?", isUser: false),
                    ConversationMessage(text: "Abbiamo aumentato le vendite del 15%.", translation: "Nous avons augmenté les ventes de 15%.", isUser: true),
                    ConversationMessage(text: "Fantastico! Come avete fatto?", translation: "Fantastique! Comment avez-vous fait?", isUser: false),
                    ConversationMessage(text: "Nuova strategia di marketing sui social media.", translation: "Nouvelle stratégie marketing sur les réseaux sociaux.", isUser: true),
                    ConversationMessage(text: "Quali sono i prossimi obiettivi?", translation: "Quels sont les prochains objectifs?", isUser: false),
                    ConversationMessage(text: "Vogliamo raggiungere il 20% entro giugno.", translation: "Nous voulons atteindre 20% d'ici juin.", isUser: true),
                    ConversationMessage(text: "Serve budget aggiuntivo?", translation: "Faut-il un budget supplémentaire?", isUser: false),
                    ConversationMessage(text: "Sì, circa 10.000 euro per le campagne.", translation: "Oui, environ 10 000 euros pour les campagnes.", isUser: true)
                ]
            ),
            
            // SOCIAL
            ConversationScenario(
                name: "Invitation à une fête",
                icon: "🎉",
                color: "pink",
                messages: [
                    ConversationMessage(text: "Ciao! Sabato organizzo una festa a casa mia.", translation: "Salut! Samedi j'organise une fête chez moi.", isUser: false),
                    ConversationMessage(text: "Che bello! A che ora?", translation: "Génial! À quelle heure?", isUser: true),
                    ConversationMessage(text: "Dalle 20:00. Puoi venire?", translation: "À partir de 20h. Tu peux venir?", isUser: false),
                    ConversationMessage(text: "Sì, con piacere! Posso portare qualcuno?", translation: "Oui, avec plaisir! Puis-je amener quelqu'un?", isUser: true),
                    ConversationMessage(text: "Certo! Più siamo, meglio è!", translation: "Bien sûr! Plus on est, mieux c'est!", isUser: false),
                    ConversationMessage(text: "Devo portare qualcosa?", translation: "Dois-je apporter quelque chose?", isUser: true),
                    ConversationMessage(text: "Se vuoi, porta una bottiglia di vino o un dolce.", translation: "Si tu veux, apporte une bouteille de vin ou un dessert.", isUser: false),
                    ConversationMessage(text: "Perfetto! Qual è l'indirizzo?", translation: "Parfait! Quelle est l'adresse?", isUser: true),
                    ConversationMessage(text: "Via Garibaldi 12, terzo piano.", translation: "Via Garibaldi 12, troisième étage.", isUser: false),
                    ConversationMessage(text: "Ci vediamo sabato allora! Non vedo l'ora!", translation: "On se voit samedi alors! J'ai hâte!", isUser: true)
                ]
            ),
            ConversationScenario(
                name: "Au Café",
                icon: "☕",
                color: "brown",
                messages: [
                    ConversationMessage(text: "Ciao! Come va?", translation: "Salut! Comment ça va?", isUser: false),
                    ConversationMessage(text: "Tutto bene, grazie! E tu?", translation: "Tout va bien, merci! Et toi?", isUser: true),
                    ConversationMessage(text: "Benissimo! Prendiamo un caffè?", translation: "Très bien! On prend un café?", isUser: false),
                    ConversationMessage(text: "Sì, volentieri! Dove andiamo?", translation: "Oui, volontiers! Où allons-nous?", isUser: true),
                    ConversationMessage(text: "C'è un bar carino qui vicino.", translation: "Il y a un bar sympa tout près.", isUser: false),
                    ConversationMessage(text: "Perfetto! Cosa prendi?", translation: "Parfait! Qu'est-ce que tu prends?", isUser: true),
                    ConversationMessage(text: "Un cappuccino e un cornetto.", translation: "Un cappuccino et un croissant.", isUser: false),
                    ConversationMessage(text: "Io prendo un caffè macchiato.", translation: "Moi je prends un café macchiato.", isUser: true),
                    ConversationMessage(text: "Allora, com'è andato il weekend?", translation: "Alors, comment s'est passé le week-end?", isUser: false),
                    ConversationMessage(text: "Benissimo! Sono andato al mare con amici.", translation: "Très bien! Je suis allé à la mer avec des amis.", isUser: true)
                ]
            ),
            ConversationScenario(
                name: "Rendez-vous",
                icon: "❤️",
                color: "red",
                messages: [
                    ConversationMessage(text: "Ciao! Che piacere vederti!", translation: "Salut! Quel plaisir de te voir!", isUser: false),
                    ConversationMessage(text: "Anche per me! Sei bellissima stasera.", translation: "Moi aussi! Tu es magnifique ce soir.", isUser: true),
                    ConversationMessage(text: "Grazie! Tu sei molto elegante.", translation: "Merci! Tu es très élégant.", isUser: false),
                    ConversationMessage(text: "Ho prenotato in un ristorante speciale.", translation: "J'ai réservé dans un restaurant spécial.", isUser: true),
                    ConversationMessage(text: "Davvero? Quale?", translation: "Vraiment? Lequel?", isUser: false),
                    ConversationMessage(text: "È una sorpresa! Ti piacerà sicuramente.", translation: "C'est une surprise! Tu aimeras certainement.", isUser: true),
                    ConversationMessage(text: "Non vedo l'ora! Cosa cucina?", translation: "J'ai hâte! Qu'est-ce qu'il cuisine?", isUser: false),
                    ConversationMessage(text: "Cucina italiana tradizionale, molto romantica.", translation: "Cuisine italienne traditionnelle, très romantique.", isUser: true),
                    ConversationMessage(text: "Perfetto! Mi piacciono le sorprese.", translation: "Parfait! J'aime les surprises.", isUser: false),
                    ConversationMessage(text: "Allora andiamo! La serata è tutta per noi.", translation: "Alors allons-y! La soirée est toute à nous.", isUser: true)
                ]
            ),
            
            // URGENCES
            ConversationScenario(
                name: "Médecin - Urgence",
                icon: "🏥",
                color: "red",
                messages: [
                    ConversationMessage(text: "Buongiorno, cosa non va?", translation: "Bonjour, qu'est-ce qui ne va pas?", isUser: false),
                    ConversationMessage(text: "Mi fa molto male lo stomaco da ieri.", translation: "J'ai très mal au ventre depuis hier.", isUser: true),
                    ConversationMessage(text: "Ha anche febbre o nausea?", translation: "Avez-vous aussi de la fièvre ou des nausées?", isUser: false),
                    ConversationMessage(text: "Sì, un po' di nausea e mal di testa.", translation: "Oui, un peu de nausée et mal de tête.", isUser: true),
                    ConversationMessage(text: "Ha mangiato qualcosa di particolare?", translation: "Avez-vous mangé quelque chose de particulier?", isUser: false),
                    ConversationMessage(text: "Pesce al ristorante due giorni fa.", translation: "Du poisson au restaurant il y a deux jours.", isUser: true),
                    ConversationMessage(text: "Potrebbe essere un'intossicazione alimentare.", translation: "Ça pourrait être une intoxication alimentaire.", isUser: false),
                    ConversationMessage(text: "È grave? Cosa devo fare?", translation: "C'est grave? Que dois-je faire?", isUser: true),
                    ConversationMessage(text: "Le prescrivo delle medicine. Beva molta acqua e riposi.", translation: "Je vous prescris des médicaments. Buvez beaucoup d'eau et reposez-vous.", isUser: false),
                    ConversationMessage(text: "Se peggiora, devo tornare?", translation: "Si ça empire, dois-je revenir?", isUser: true),
                    ConversationMessage(text: "Sì, o vada al pronto soccorso. Si senta meglio!", translation: "Oui, ou allez aux urgences. Sentez-vous mieux!", isUser: false)
                ]
            ),
            ConversationScenario(
                name: "Commissariat",
                icon: "🚔",
                color: "blue",
                messages: [
                    ConversationMessage(text: "Buongiorno, come posso aiutarla?", translation: "Bonjour, comment puis-je vous aider?", isUser: false),
                    ConversationMessage(text: "Vorrei denunciare un furto.", translation: "Je voudrais déclarer un vol.", isUser: true),
                    ConversationMessage(text: "Mi dispiace. Quando è successo?", translation: "Je suis désolé. Quand est-ce arrivé?", isUser: false),
                    ConversationMessage(text: "Stamattina, sulla metro. Hanno rubato il mio portafoglio.", translation: "Ce matin, dans le métro. On a volé mon portefeuille.", isUser: true),
                    ConversationMessage(text: "Cosa c'era dentro?", translation: "Qu'est-ce qu'il y avait dedans?", isUser: false),
                    ConversationMessage(text: "Documenti, carte di credito e 50 euro.", translation: "Documents, cartes de crédit et 50 euros.", isUser: true),
                    ConversationMessage(text: "Ha già bloccato le carte?", translation: "Avez-vous déjà bloqué les cartes?", isUser: false),
                    ConversationMessage(text: "Sì, ho chiamato la banca.", translation: "Oui, j'ai appelé la banque.", isUser: true),
                    ConversationMessage(text: "Bene. Compili questo modulo per la denuncia.", translation: "Bien. Remplissez ce formulaire pour la déclaration.", isUser: false),
                    ConversationMessage(text: "Quanto tempo serve per i documenti nuovi?", translation: "Combien de temps faut-il pour les nouveaux documents?", isUser: true),
                    ConversationMessage(text: "Circa due settimane. Le daremo una ricevuta temporanea.", translation: "Environ deux semaines. Nous vous donnerons un reçu temporaire.", isUser: false)
                ]
            )
        ]
    }
}
