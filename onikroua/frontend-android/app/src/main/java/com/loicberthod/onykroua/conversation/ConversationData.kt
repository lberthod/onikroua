package com.loicberthod.onykroua.conversation

object ConversationData {
    
    fun getConversations(language: String): List<Conversation> {
        return if (language == "it") getItalianConversations() else getSpanishConversations()
    }
    
    private fun getItalianConversations(): List<Conversation> {
        return listOf(
            Conversation(
                title = "Au café",
                icon = "☕",
                scenario = "Commander au café",
                difficulty = "débutant",
                messages = listOf(
                    Message("A", "Buongiorno! Cosa desidera?", "Bonjour ! Que désirez-vous ?"),
                    Message("B", "Buongiorno! Vorrei un caffè, per favore.", "Bonjour ! Je voudrais un café, s'il vous plaît."),
                    Message("A", "Espresso o cappuccino?", "Espresso ou cappuccino ?"),
                    Message("B", "Un cappuccino, grazie.", "Un cappuccino, merci."),
                    Message("A", "Desidera qualcos'altro?", "Désirez-vous autre chose ?"),
                    Message("B", "Sì, anche un cornetto.", "Oui, aussi un croissant."),
                    Message("A", "Perfetto. Sono tre euro e cinquanta.", "Parfait. Ça fait trois euros cinquante."),
                    Message("B", "Ecco a lei. Grazie!", "Voilà. Merci !")
                ),
                vocabulary = listOf(
                    VocabItem("il caffè", "le café"),
                    VocabItem("il cappuccino", "le cappuccino"),
                    VocabItem("il cornetto", "le croissant"),
                    VocabItem("desiderare", "désirer"),
                    VocabItem("qualcos'altro", "autre chose")
                ),
                tips = listOf(
                    "En Italie, le cappuccino se boit généralement le matin.",
                    "\"Ecco\" est très utilisé pour dire \"voilà\" ou \"voici\"."
                )
            ),
            Conversation(
                title = "Au restaurant",
                icon = "🍝",
                scenario = "Réserver et commander",
                difficulty = "intermédiaire",
                messages = listOf(
                    Message("A", "Buonasera, avete una prenotazione?", "Bonsoir, avez-vous une réservation ?"),
                    Message("B", "Sì, a nome Rossi per due persone.", "Oui, au nom de Rossi pour deux personnes."),
                    Message("A", "Perfetto, seguitemi. Ecco il menu.", "Parfait, suivez-moi. Voici le menu."),
                    Message("B", "Grazie. Cosa ci consiglia?", "Merci. Que nous conseillez-vous ?"),
                    Message("A", "Le tagliatelle al ragù sono ottime oggi.", "Les tagliatelles à la bolognaise sont excellentes aujourd'hui."),
                    Message("B", "Perfetto, le prendo. E per secondo?", "Parfait, je les prends. Et en plat principal ?"),
                    Message("A", "Abbiamo un'ottima bistecca alla fiorentina.", "Nous avons une excellente côte de bœuf à la florentine."),
                    Message("B", "Va bene. E una bottiglia di vino rosso, per favore.", "D'accord. Et une bouteille de vin rouge, s'il vous plaît.")
                ),
                vocabulary = listOf(
                    VocabItem("la prenotazione", "la réservation"),
                    VocabItem("il menu", "le menu"),
                    VocabItem("consigliare", "conseiller"),
                    VocabItem("il primo", "l'entrée/premier plat"),
                    VocabItem("il secondo", "le plat principal"),
                    VocabItem("la bistecca", "le steak")
                ),
                tips = listOf(
                    "En Italie, le repas se compose souvent de: antipasto, primo, secondo, contorno, dolce.",
                    "\"A nome di...\" signifie \"au nom de...\"."
                )
            ),
            Conversation(
                title = "À l'hôtel",
                icon = "🏨",
                scenario = "Check-in à l'hôtel",
                difficulty = "intermédiaire",
                messages = listOf(
                    Message("A", "Buongiorno, benvenuto all'Hotel Roma.", "Bonjour, bienvenue à l'Hôtel Roma."),
                    Message("B", "Buongiorno, ho una prenotazione a nome Bianchi.", "Bonjour, j'ai une réservation au nom de Bianchi."),
                    Message("A", "Sì, una camera doppia per tre notti, giusto?", "Oui, une chambre double pour trois nuits, c'est bien ça ?"),
                    Message("B", "Esatto. La camera ha il bagno privato?", "Exact. La chambre a une salle de bain privée ?"),
                    Message("A", "Certo, con doccia e vasca. Ecco la chiave, camera 305.", "Bien sûr, avec douche et baignoire. Voici la clé, chambre 305."),
                    Message("B", "A che ora è la colazione?", "À quelle heure est le petit-déjeuner ?"),
                    Message("A", "Dalle sette alle dieci, al primo piano.", "De sept heures à dix heures, au premier étage."),
                    Message("B", "Perfetto, grazie mille!", "Parfait, merci beaucoup !")
                ),
                vocabulary = listOf(
                    VocabItem("la camera", "la chambre"),
                    VocabItem("doppia/singola", "double/simple"),
                    VocabItem("la chiave", "la clé"),
                    VocabItem("la colazione", "le petit-déjeuner"),
                    VocabItem("il bagno", "la salle de bain"),
                    VocabItem("la doccia", "la douche")
                ),
                tips = listOf(
                    "\"Dalle... alle...\" signifie \"de... à...\" pour les horaires.",
                    "En Italie, le premier étage est \"il primo piano\" (pas le rez-de-chaussée)."
                )
            ),
            Conversation(
                title = "Demander son chemin",
                icon = "🗺️",
                scenario = "Se repérer en ville",
                difficulty = "débutant",
                messages = listOf(
                    Message("B", "Scusi, sa dov'è la stazione?", "Excusez-moi, savez-vous où est la gare ?"),
                    Message("A", "Sì, è abbastanza vicina. Vada sempre dritto.", "Oui, elle est assez proche. Allez tout droit."),
                    Message("B", "E poi?", "Et ensuite ?"),
                    Message("A", "Alla piazza, giri a sinistra.", "À la place, tournez à gauche."),
                    Message("B", "A sinistra, ho capito.", "À gauche, j'ai compris."),
                    Message("A", "Poi continui per duecento metri. La stazione è sulla destra.", "Puis continuez pendant deux cents mètres. La gare est sur la droite."),
                    Message("B", "Quanto tempo ci vuole a piedi?", "Combien de temps faut-il à pied ?"),
                    Message("A", "Circa dieci minuti.", "Environ dix minutes."),
                    Message("B", "Grazie mille, molto gentile!", "Merci beaucoup, très aimable !")
                ),
                vocabulary = listOf(
                    VocabItem("la stazione", "la gare"),
                    VocabItem("dritto", "tout droit"),
                    VocabItem("a sinistra", "à gauche"),
                    VocabItem("a destra", "à droite"),
                    VocabItem("la piazza", "la place"),
                    VocabItem("a piedi", "à pied")
                ),
                tips = listOf(
                    "\"Scusi\" est la forme polie de \"excuse-moi\".",
                    "\"Ci vuole\" / \"ci vogliono\" = \"il faut\" (temps/quantité)."
                )
            ),
            Conversation(
                title = "Chez le médecin",
                icon = "🏥",
                scenario = "Consultation médicale",
                difficulty = "avancé",
                messages = listOf(
                    Message("A", "Buongiorno, come si sente oggi?", "Bonjour, comment vous sentez-vous aujourd'hui ?"),
                    Message("B", "Non mi sento bene. Ho mal di testa e febbre.", "Je ne me sens pas bien. J'ai mal à la tête et de la fièvre."),
                    Message("A", "Da quanto tempo ha questi sintomi?", "Depuis combien de temps avez-vous ces symptômes ?"),
                    Message("B", "Da tre giorni. E ho anche mal di gola.", "Depuis trois jours. Et j'ai aussi mal à la gorge."),
                    Message("A", "Ha preso qualche medicina?", "Avez-vous pris des médicaments ?"),
                    Message("B", "Solo un po' di aspirina.", "Seulement un peu d'aspirine."),
                    Message("A", "Le prescrivo un antibiotico. Prenda una compressa tre volte al giorno.", "Je vous prescris un antibiotique. Prenez un comprimé trois fois par jour."),
                    Message("B", "Per quanto tempo?", "Pendant combien de temps ?"),
                    Message("A", "Per una settimana. E riposi molto.", "Pendant une semaine. Et reposez-vous beaucoup.")
                ),
                vocabulary = listOf(
                    VocabItem("il mal di testa", "le mal de tête"),
                    VocabItem("la febbre", "la fièvre"),
                    VocabItem("il mal di gola", "le mal de gorge"),
                    VocabItem("la medicina", "le médicament"),
                    VocabItem("la compressa", "le comprimé"),
                    VocabItem("prescrivere", "prescrire")
                ),
                tips = listOf(
                    "\"Ho mal di...\" = \"J'ai mal à...\"",
                    "\"Da quanto tempo?\" = \"Depuis combien de temps ?\""
                )
            ),
            Conversation(
                title = "Faire les courses",
                icon = "🛒",
                scenario = "Au supermarché",
                difficulty = "débutant",
                messages = listOf(
                    Message("B", "Scusi, dove posso trovare il latte?", "Excusez-moi, où puis-je trouver le lait ?"),
                    Message("A", "Il latte è nel reparto frigo, in fondo a destra.", "Le lait est au rayon frais, au fond à droite."),
                    Message("B", "Grazie. E il pane fresco?", "Merci. Et le pain frais ?"),
                    Message("A", "Il pane è vicino all'entrata, sulla sinistra.", "Le pain est près de l'entrée, sur la gauche."),
                    Message("B", "Avete anche frutta biologica?", "Avez-vous aussi des fruits bio ?"),
                    Message("A", "Sì, nel reparto ortofrutta, c'è una sezione bio.", "Oui, au rayon fruits et légumes, il y a une section bio."),
                    Message("B", "Perfetto. Dov'è la cassa?", "Parfait. Où est la caisse ?"),
                    Message("A", "Le casse sono all'uscita, davanti a lei.", "Les caisses sont à la sortie, devant vous.")
                ),
                vocabulary = listOf(
                    VocabItem("il latte", "le lait"),
                    VocabItem("il reparto", "le rayon"),
                    VocabItem("il frigo", "le frigo"),
                    VocabItem("biologico", "bio"),
                    VocabItem("la cassa", "la caisse"),
                    VocabItem("l'uscita", "la sortie")
                ),
                tips = listOf(
                    "\"In fondo\" = \"au fond\".",
                    "\"Ortofrutta\" = fruits et légumes (orto = potager + frutta = fruits)."
                )
            ),
            Conversation(
                title = "Prendre le train",
                icon = "🚂",
                scenario = "Acheter un billet",
                difficulty = "intermédiaire",
                messages = listOf(
                    Message("B", "Buongiorno, vorrei un biglietto per Milano.", "Bonjour, je voudrais un billet pour Milan."),
                    Message("A", "Solo andata o andata e ritorno?", "Aller simple ou aller-retour ?"),
                    Message("B", "Andata e ritorno, per favore.", "Aller-retour, s'il vous plaît."),
                    Message("A", "Quando vuole partire?", "Quand voulez-vous partir ?"),
                    Message("B", "Oggi pomeriggio, verso le tre.", "Cet après-midi, vers trois heures."),
                    Message("A", "C'è un treno alle 15:20. Prima o seconda classe?", "Il y a un train à 15h20. Première ou deuxième classe ?"),
                    Message("B", "Seconda classe. Quanto costa?", "Deuxième classe. Combien ça coûte ?"),
                    Message("A", "Sono quarantacinque euro. Da quale binario parte?", "Ça fait quarante-cinq euros. De quel quai part-il ?"),
                    Message("A", "Binario 7. Buon viaggio!", "Quai 7. Bon voyage !")
                ),
                vocabulary = listOf(
                    VocabItem("il biglietto", "le billet"),
                    VocabItem("solo andata", "aller simple"),
                    VocabItem("andata e ritorno", "aller-retour"),
                    VocabItem("il binario", "le quai"),
                    VocabItem("partire", "partir"),
                    VocabItem("il treno", "le train")
                ),
                tips = listOf(
                    "\"Verso\" = \"vers\" (approximation d'heure).",
                    "N'oubliez pas de composter votre billet en Italie !"
                )
            ),
            Conversation(
                title = "Se présenter",
                icon = "👋",
                scenario = "Faire connaissance",
                difficulty = "débutant",
                messages = listOf(
                    Message("A", "Ciao! Come ti chiami?", "Salut ! Comment tu t'appelles ?"),
                    Message("B", "Mi chiamo Marco. E tu?", "Je m'appelle Marco. Et toi ?"),
                    Message("A", "Io sono Giulia. Piacere!", "Moi c'est Giulia. Enchanté !"),
                    Message("B", "Piacere mio! Di dove sei?", "Enchanté ! D'où es-tu ?"),
                    Message("A", "Sono di Roma, ma abito a Milano. E tu?", "Je suis de Rome, mais j'habite à Milan. Et toi ?"),
                    Message("B", "Sono francese, di Parigi.", "Je suis français, de Paris."),
                    Message("A", "Che bello! Cosa fai qui in Italia?", "Super ! Que fais-tu ici en Italie ?"),
                    Message("B", "Studio italiano all'università.", "J'étudie l'italien à l'université."),
                    Message("A", "Fantastico! Il tuo italiano è molto buono!", "Fantastique ! Ton italien est très bon !")
                ),
                vocabulary = listOf(
                    VocabItem("chiamarsi", "s'appeler"),
                    VocabItem("piacere", "enchanté"),
                    VocabItem("di dove sei?", "d'où es-tu ?"),
                    VocabItem("abitare", "habiter"),
                    VocabItem("studiare", "étudier")
                ),
                tips = listOf(
                    "\"Mi chiamo\" = littéralement \"je m'appelle\".",
                    "\"Piacere\" peut être utilisé seul ou avec \"mio\" (le plaisir est mien)."
                )
            )
        )
    }
    
    private fun getSpanishConversations(): List<Conversation> {
        return listOf(
            Conversation(
                title = "Au café",
                icon = "☕",
                scenario = "Commander au café",
                difficulty = "débutant",
                messages = listOf(
                    Message("A", "¡Buenos días! ¿Qué desea?", "Bonjour ! Que désirez-vous ?"),
                    Message("B", "¡Buenos días! Quisiera un café, por favor.", "Bonjour ! Je voudrais un café, s'il vous plaît."),
                    Message("A", "¿Solo o con leche?", "Noir ou au lait ?"),
                    Message("B", "Con leche, gracias.", "Au lait, merci."),
                    Message("A", "¿Desea algo más?", "Désirez-vous autre chose ?"),
                    Message("B", "Sí, también un cruasán.", "Oui, aussi un croissant."),
                    Message("A", "Perfecto. Son tres euros con cincuenta.", "Parfait. Ça fait trois euros cinquante."),
                    Message("B", "Aquí tiene. ¡Gracias!", "Voilà. Merci !")
                ),
                vocabulary = listOf(
                    VocabItem("el café", "le café"),
                    VocabItem("con leche", "au lait"),
                    VocabItem("el cruasán", "le croissant"),
                    VocabItem("desear", "désirer"),
                    VocabItem("algo más", "autre chose")
                ),
                tips = listOf(
                    "En Espagne, \"café con leche\" est très populaire.",
                    "\"Aquí tiene\" est une façon polie de dire \"voilà\"."
                )
            ),
            Conversation(
                title = "Au restaurant",
                icon = "🍝",
                scenario = "Réserver et commander",
                difficulty = "intermédiaire",
                messages = listOf(
                    Message("A", "Buenas noches, ¿tienen reserva?", "Bonsoir, avez-vous une réservation ?"),
                    Message("B", "Sí, a nombre de García para dos personas.", "Oui, au nom de García pour deux personnes."),
                    Message("A", "Perfecto, síganme. Aquí está la carta.", "Parfait, suivez-moi. Voici le menu."),
                    Message("B", "Gracias. ¿Qué nos recomienda?", "Merci. Que nous recommandez-vous ?"),
                    Message("A", "La paella está muy buena hoy.", "La paella est très bonne aujourd'hui."),
                    Message("B", "Perfecto, la tomo. ¿Y de segundo?", "Parfait, je la prends. Et en plat principal ?"),
                    Message("A", "Tenemos un excelente solomillo.", "Nous avons un excellent filet de bœuf."),
                    Message("B", "Vale. Y una botella de vino tinto, por favor.", "D'accord. Et une bouteille de vin rouge, s'il vous plaît.")
                ),
                vocabulary = listOf(
                    VocabItem("la reserva", "la réservation"),
                    VocabItem("la carta", "le menu"),
                    VocabItem("recomendar", "recommander"),
                    VocabItem("el primer plato", "l'entrée"),
                    VocabItem("el segundo plato", "le plat principal"),
                    VocabItem("el solomillo", "le filet")
                ),
                tips = listOf(
                    "\"A nombre de...\" signifie \"au nom de...\".",
                    "\"Vale\" est très utilisé en Espagne pour dire \"d'accord\"."
                )
            ),
            Conversation(
                title = "À l'hôtel",
                icon = "🏨",
                scenario = "Check-in à l'hôtel",
                difficulty = "intermédiaire",
                messages = listOf(
                    Message("A", "Buenos días, bienvenido al Hotel Madrid.", "Bonjour, bienvenue à l'Hôtel Madrid."),
                    Message("B", "Buenos días, tengo una reserva a nombre de López.", "Bonjour, j'ai une réservation au nom de López."),
                    Message("A", "Sí, una habitación doble para tres noches, ¿verdad?", "Oui, une chambre double pour trois nuits, n'est-ce pas ?"),
                    Message("B", "Exacto. ¿La habitación tiene baño privado?", "Exact. La chambre a une salle de bain privée ?"),
                    Message("A", "Claro, con ducha y bañera. Aquí tiene la llave, habitación 305.", "Bien sûr, avec douche et baignoire. Voici la clé, chambre 305."),
                    Message("B", "¿A qué hora es el desayuno?", "À quelle heure est le petit-déjeuner ?"),
                    Message("A", "De siete a diez, en la primera planta.", "De sept heures à dix heures, au premier étage."),
                    Message("B", "¡Perfecto, muchas gracias!", "Parfait, merci beaucoup !")
                ),
                vocabulary = listOf(
                    VocabItem("la habitación", "la chambre"),
                    VocabItem("doble/individual", "double/simple"),
                    VocabItem("la llave", "la clé"),
                    VocabItem("el desayuno", "le petit-déjeuner"),
                    VocabItem("el baño", "la salle de bain"),
                    VocabItem("la ducha", "la douche")
                ),
                tips = listOf(
                    "\"De... a...\" signifie \"de... à...\" pour les horaires.",
                    "En Espagne, \"la primera planta\" est le premier étage (pas le rez-de-chaussée)."
                )
            ),
            Conversation(
                title = "Demander son chemin",
                icon = "🗺️",
                scenario = "Se repérer en ville",
                difficulty = "débutant",
                messages = listOf(
                    Message("B", "Perdone, ¿sabe dónde está la estación?", "Excusez-moi, savez-vous où est la gare ?"),
                    Message("A", "Sí, está bastante cerca. Siga todo recto.", "Oui, elle est assez proche. Allez tout droit."),
                    Message("B", "¿Y después?", "Et ensuite ?"),
                    Message("A", "En la plaza, gire a la izquierda.", "À la place, tournez à gauche."),
                    Message("B", "A la izquierda, entendido.", "À gauche, compris."),
                    Message("A", "Luego siga doscientos metros. La estación está a la derecha.", "Puis continuez deux cents mètres. La gare est sur la droite."),
                    Message("B", "¿Cuánto tiempo se tarda andando?", "Combien de temps faut-il à pied ?"),
                    Message("A", "Unos diez minutos.", "Environ dix minutes."),
                    Message("B", "¡Muchas gracias, muy amable!", "Merci beaucoup, très aimable !")
                ),
                vocabulary = listOf(
                    VocabItem("la estación", "la gare"),
                    VocabItem("todo recto", "tout droit"),
                    VocabItem("a la izquierda", "à gauche"),
                    VocabItem("a la derecha", "à droite"),
                    VocabItem("la plaza", "la place"),
                    VocabItem("andando", "à pied")
                ),
                tips = listOf(
                    "\"Perdone\" est la forme polie de \"excuse-moi\".",
                    "\"Se tarda\" = \"il faut\" (pour le temps)."
                )
            ),
            Conversation(
                title = "Chez le médecin",
                icon = "🏥",
                scenario = "Consultation médicale",
                difficulty = "avancé",
                messages = listOf(
                    Message("A", "Buenos días, ¿cómo se encuentra hoy?", "Bonjour, comment vous sentez-vous aujourd'hui ?"),
                    Message("B", "No me encuentro bien. Tengo dolor de cabeza y fiebre.", "Je ne me sens pas bien. J'ai mal à la tête et de la fièvre."),
                    Message("A", "¿Desde cuándo tiene estos síntomas?", "Depuis quand avez-vous ces symptômes ?"),
                    Message("B", "Desde hace tres días. Y también me duele la garganta.", "Depuis trois jours. Et j'ai aussi mal à la gorge."),
                    Message("A", "¿Ha tomado algún medicamento?", "Avez-vous pris des médicaments ?"),
                    Message("B", "Solo un poco de aspirina.", "Seulement un peu d'aspirine."),
                    Message("A", "Le receto un antibiótico. Tome una pastilla tres veces al día.", "Je vous prescris un antibiotique. Prenez un comprimé trois fois par jour."),
                    Message("B", "¿Durante cuánto tiempo?", "Pendant combien de temps ?"),
                    Message("A", "Durante una semana. Y descanse mucho.", "Pendant une semaine. Et reposez-vous beaucoup.")
                ),
                vocabulary = listOf(
                    VocabItem("el dolor de cabeza", "le mal de tête"),
                    VocabItem("la fiebre", "la fièvre"),
                    VocabItem("el dolor de garganta", "le mal de gorge"),
                    VocabItem("el medicamento", "le médicament"),
                    VocabItem("la pastilla", "le comprimé"),
                    VocabItem("recetar", "prescrire")
                ),
                tips = listOf(
                    "\"Me duele...\" = \"J'ai mal à...\"",
                    "\"¿Desde cuándo?\" = \"Depuis quand ?\""
                )
            ),
            Conversation(
                title = "Faire les courses",
                icon = "🛒",
                scenario = "Au supermarché",
                difficulty = "débutant",
                messages = listOf(
                    Message("B", "Perdone, ¿dónde puedo encontrar la leche?", "Excusez-moi, où puis-je trouver le lait ?"),
                    Message("A", "La leche está en la sección de refrigerados, al fondo a la derecha.", "Le lait est au rayon frais, au fond à droite."),
                    Message("B", "Gracias. ¿Y el pan fresco?", "Merci. Et le pain frais ?"),
                    Message("A", "El pan está cerca de la entrada, a la izquierda.", "Le pain est près de l'entrée, sur la gauche."),
                    Message("B", "¿Tienen también fruta ecológica?", "Avez-vous aussi des fruits bio ?"),
                    Message("A", "Sí, en la sección de frutas y verduras, hay una zona ecológica.", "Oui, au rayon fruits et légumes, il y a une zone bio."),
                    Message("B", "Perfecto. ¿Dónde está la caja?", "Parfait. Où est la caisse ?"),
                    Message("A", "Las cajas están en la salida, delante de usted.", "Les caisses sont à la sortie, devant vous.")
                ),
                vocabulary = listOf(
                    VocabItem("la leche", "le lait"),
                    VocabItem("la sección", "le rayon"),
                    VocabItem("los refrigerados", "les produits frais"),
                    VocabItem("ecológico", "bio"),
                    VocabItem("la caja", "la caisse"),
                    VocabItem("la salida", "la sortie")
                ),
                tips = listOf(
                    "\"Al fondo\" = \"au fond\".",
                    "\"Frutas y verduras\" = fruits et légumes."
                )
            ),
            Conversation(
                title = "Prendre le train",
                icon = "🚂",
                scenario = "Acheter un billet",
                difficulty = "intermédiaire",
                messages = listOf(
                    Message("B", "Buenos días, quisiera un billete para Barcelona.", "Bonjour, je voudrais un billet pour Barcelone."),
                    Message("A", "¿Solo ida o ida y vuelta?", "Aller simple ou aller-retour ?"),
                    Message("B", "Ida y vuelta, por favor.", "Aller-retour, s'il vous plaît."),
                    Message("A", "¿Cuándo quiere salir?", "Quand voulez-vous partir ?"),
                    Message("B", "Esta tarde, sobre las tres.", "Cet après-midi, vers trois heures."),
                    Message("A", "Hay un tren a las 15:20. ¿Primera o segunda clase?", "Il y a un train à 15h20. Première ou deuxième classe ?"),
                    Message("B", "Segunda clase. ¿Cuánto cuesta?", "Deuxième classe. Combien ça coûte ?"),
                    Message("A", "Son cuarenta y cinco euros. ¿De qué andén sale?", "Ça fait quarante-cinq euros. De quel quai part-il ?"),
                    Message("A", "Andén 7. ¡Buen viaje!", "Quai 7. Bon voyage !")
                ),
                vocabulary = listOf(
                    VocabItem("el billete", "le billet"),
                    VocabItem("solo ida", "aller simple"),
                    VocabItem("ida y vuelta", "aller-retour"),
                    VocabItem("el andén", "le quai"),
                    VocabItem("salir", "partir"),
                    VocabItem("el tren", "le train")
                ),
                tips = listOf(
                    "\"Sobre\" = \"vers\" (approximation d'heure).",
                    "En Espagne, les trains AVE sont très rapides !"
                )
            ),
            Conversation(
                title = "Se présenter",
                icon = "👋",
                scenario = "Faire connaissance",
                difficulty = "débutant",
                messages = listOf(
                    Message("A", "¡Hola! ¿Cómo te llamas?", "Salut ! Comment tu t'appelles ?"),
                    Message("B", "Me llamo Carlos. ¿Y tú?", "Je m'appelle Carlos. Et toi ?"),
                    Message("A", "Yo soy María. ¡Mucho gusto!", "Moi c'est María. Enchanté !"),
                    Message("B", "¡Igualmente! ¿De dónde eres?", "De même ! D'où es-tu ?"),
                    Message("A", "Soy de Madrid, pero vivo en Barcelona. ¿Y tú?", "Je suis de Madrid, mais j'habite à Barcelone. Et toi ?"),
                    Message("B", "Soy francés, de París.", "Je suis français, de Paris."),
                    Message("A", "¡Qué bien! ¿Qué haces aquí en España?", "Super ! Que fais-tu ici en Espagne ?"),
                    Message("B", "Estudio español en la universidad.", "J'étudie l'espagnol à l'université."),
                    Message("A", "¡Genial! ¡Tu español es muy bueno!", "Génial ! Ton espagnol est très bon !")
                ),
                vocabulary = listOf(
                    VocabItem("llamarse", "s'appeler"),
                    VocabItem("mucho gusto", "enchanté"),
                    VocabItem("¿de dónde eres?", "d'où es-tu ?"),
                    VocabItem("vivir", "habiter"),
                    VocabItem("estudiar", "étudier")
                ),
                tips = listOf(
                    "\"Me llamo\" = littéralement \"je m'appelle\".",
                    "\"Igualmente\" = \"de même\" / \"pareillement\"."
                )
            )
        )
    }
}
