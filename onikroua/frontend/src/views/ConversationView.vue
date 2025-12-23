<script setup lang="ts">
import { computed, ref } from 'vue'
import { useLearningStore } from '../stores/learning'

const learningStore = useLearningStore()
const selectedScenario = ref<string | null>(null)
const playingId = ref<string | null>(null)
const expandedConversation = ref<number | null>(null)

// TTS
const speak = (text: string, id?: string) => {
  if (playingId.value === id) {
    speechSynthesis.cancel()
    playingId.value = null
    return
  }
  
  const lang = learningStore.currentLanguage === 'it' ? 'it-IT' : 'es-ES'
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = lang
  utterance.rate = 0.8
  
  playingId.value = id || null
  utterance.onend = () => { playingId.value = null }
  utterance.onerror = () => { playingId.value = null }
  
  speechSynthesis.speak(utterance)
}

const speakConversation = (messages: { text: string }[]) => {
  speechSynthesis.cancel()
  const lang = learningStore.currentLanguage === 'it' ? 'it-IT' : 'es-ES'
  
  messages.forEach((msg, idx) => {
    const utterance = new SpeechSynthesisUtterance(msg.text)
    utterance.lang = lang
    utterance.rate = 0.8
    if (idx === 0) {
      playingId.value = 'conversation'
    }
    if (idx === messages.length - 1) {
      utterance.onend = () => { playingId.value = null }
    }
    speechSynthesis.speak(utterance)
  })
}

interface Message {
  speaker: 'A' | 'B'
  text: string
  translation: string
}

interface Conversation {
  title: string
  icon: string
  scenario: string
  difficulty: 'débutant' | 'intermédiaire' | 'avancé'
  messages: Message[]
  vocabulary: { word: string; translation: string }[]
  tips: string[]
}

const conversationsData = computed((): Conversation[] => {
  if (learningStore.currentLanguage === 'it') {
    return [
      {
        title: 'Au café',
        icon: '☕',
        scenario: 'Commander au café',
        difficulty: 'débutant',
        messages: [
          { speaker: 'A', text: 'Buongiorno! Cosa desidera?', translation: 'Bonjour ! Que désirez-vous ?' },
          { speaker: 'B', text: 'Buongiorno! Vorrei un caffè, per favore.', translation: 'Bonjour ! Je voudrais un café, s\'il vous plaît.' },
          { speaker: 'A', text: 'Espresso o cappuccino?', translation: 'Espresso ou cappuccino ?' },
          { speaker: 'B', text: 'Un cappuccino, grazie.', translation: 'Un cappuccino, merci.' },
          { speaker: 'A', text: 'Desidera qualcos\'altro?', translation: 'Désirez-vous autre chose ?' },
          { speaker: 'B', text: 'Sì, anche un cornetto.', translation: 'Oui, aussi un croissant.' },
          { speaker: 'A', text: 'Perfetto. Sono tre euro e cinquanta.', translation: 'Parfait. Ça fait trois euros cinquante.' },
          { speaker: 'B', text: 'Ecco a lei. Grazie!', translation: 'Voilà. Merci !' }
        ],
        vocabulary: [
          { word: 'il caffè', translation: 'le café' },
          { word: 'il cappuccino', translation: 'le cappuccino' },
          { word: 'il cornetto', translation: 'le croissant' },
          { word: 'desiderare', translation: 'désirer' },
          { word: 'qualcos\'altro', translation: 'autre chose' }
        ],
        tips: [
          'En Italie, le cappuccino se boit généralement le matin.',
          '"Ecco" est très utilisé pour dire "voilà" ou "voici".'
        ]
      },
      {
        title: 'Au restaurant',
        icon: '🍝',
        scenario: 'Réserver et commander',
        difficulty: 'intermédiaire',
        messages: [
          { speaker: 'A', text: 'Buonasera, avete una prenotazione?', translation: 'Bonsoir, avez-vous une réservation ?' },
          { speaker: 'B', text: 'Sì, a nome Rossi per due persone.', translation: 'Oui, au nom de Rossi pour deux personnes.' },
          { speaker: 'A', text: 'Perfetto, seguitemi. Ecco il menu.', translation: 'Parfait, suivez-moi. Voici le menu.' },
          { speaker: 'B', text: 'Grazie. Cosa ci consiglia?', translation: 'Merci. Que nous conseillez-vous ?' },
          { speaker: 'A', text: 'Le tagliatelle al ragù sono ottime oggi.', translation: 'Les tagliatelles à la bolognaise sont excellentes aujourd\'hui.' },
          { speaker: 'B', text: 'Perfetto, le prendo. E per secondo?', translation: 'Parfait, je les prends. Et en plat principal ?' },
          { speaker: 'A', text: 'Abbiamo un\'ottima bistecca alla fiorentina.', translation: 'Nous avons une excellente côte de bœuf à la florentine.' },
          { speaker: 'B', text: 'Va bene. E una bottiglia di vino rosso, per favore.', translation: 'D\'accord. Et une bouteille de vin rouge, s\'il vous plaît.' }
        ],
        vocabulary: [
          { word: 'la prenotazione', translation: 'la réservation' },
          { word: 'il menu', translation: 'le menu' },
          { word: 'consigliare', translation: 'conseiller' },
          { word: 'il primo', translation: 'l\'entrée/premier plat' },
          { word: 'il secondo', translation: 'le plat principal' },
          { word: 'la bistecca', translation: 'le steak' }
        ],
        tips: [
          'En Italie, le repas se compose souvent de: antipasto, primo, secondo, contorno, dolce.',
          '"A nome di..." signifie "au nom de...".'
        ]
      },
      {
        title: 'À l\'hôtel',
        icon: '🏨',
        scenario: 'Check-in à l\'hôtel',
        difficulty: 'intermédiaire',
        messages: [
          { speaker: 'A', text: 'Buongiorno, benvenuto all\'Hotel Roma.', translation: 'Bonjour, bienvenue à l\'Hôtel Roma.' },
          { speaker: 'B', text: 'Buongiorno, ho una prenotazione a nome Bianchi.', translation: 'Bonjour, j\'ai une réservation au nom de Bianchi.' },
          { speaker: 'A', text: 'Sì, una camera doppia per tre notti, giusto?', translation: 'Oui, une chambre double pour trois nuits, c\'est bien ça ?' },
          { speaker: 'B', text: 'Esatto. La camera ha il bagno privato?', translation: 'Exact. La chambre a une salle de bain privée ?' },
          { speaker: 'A', text: 'Certo, con doccia e vasca. Ecco la chiave, camera 305.', translation: 'Bien sûr, avec douche et baignoire. Voici la clé, chambre 305.' },
          { speaker: 'B', text: 'A che ora è la colazione?', translation: 'À quelle heure est le petit-déjeuner ?' },
          { speaker: 'A', text: 'Dalle sette alle dieci, al primo piano.', translation: 'De sept heures à dix heures, au premier étage.' },
          { speaker: 'B', text: 'Perfetto, grazie mille!', translation: 'Parfait, merci beaucoup !' }
        ],
        vocabulary: [
          { word: 'la camera', translation: 'la chambre' },
          { word: 'doppia/singola', translation: 'double/simple' },
          { word: 'la chiave', translation: 'la clé' },
          { word: 'la colazione', translation: 'le petit-déjeuner' },
          { word: 'il bagno', translation: 'la salle de bain' },
          { word: 'la doccia', translation: 'la douche' }
        ],
        tips: [
          '"Dalle... alle..." signifie "de... à..." pour les horaires.',
          'En Italie, le premier étage est "il primo piano" (pas le rez-de-chaussée).'
        ]
      },
      {
        title: 'Demander son chemin',
        icon: '🗺️',
        scenario: 'Se repérer en ville',
        difficulty: 'débutant',
        messages: [
          { speaker: 'B', text: 'Scusi, sa dov\'è la stazione?', translation: 'Excusez-moi, savez-vous où est la gare ?' },
          { speaker: 'A', text: 'Sì, è abbastanza vicina. Vada sempre dritto.', translation: 'Oui, elle est assez proche. Allez tout droit.' },
          { speaker: 'B', text: 'E poi?', translation: 'Et ensuite ?' },
          { speaker: 'A', text: 'Alla piazza, giri a sinistra.', translation: 'À la place, tournez à gauche.' },
          { speaker: 'B', text: 'A sinistra, ho capito.', translation: 'À gauche, j\'ai compris.' },
          { speaker: 'A', text: 'Poi continui per duecento metri. La stazione è sulla destra.', translation: 'Puis continuez pendant deux cents mètres. La gare est sur la droite.' },
          { speaker: 'B', text: 'Quanto tempo ci vuole a piedi?', translation: 'Combien de temps faut-il à pied ?' },
          { speaker: 'A', text: 'Circa dieci minuti.', translation: 'Environ dix minutes.' },
          { speaker: 'B', text: 'Grazie mille, molto gentile!', translation: 'Merci beaucoup, très aimable !' }
        ],
        vocabulary: [
          { word: 'la stazione', translation: 'la gare' },
          { word: 'dritto', translation: 'tout droit' },
          { word: 'a sinistra', translation: 'à gauche' },
          { word: 'a destra', translation: 'à droite' },
          { word: 'la piazza', translation: 'la place' },
          { word: 'a piedi', translation: 'à pied' }
        ],
        tips: [
          '"Scusi" est la forme polie de "excuse-moi".',
          '"Ci vuole" / "ci vogliono" = "il faut" (temps/quantité).'
        ]
      },
      {
        title: 'Chez le médecin',
        icon: '🏥',
        scenario: 'Consultation médicale',
        difficulty: 'avancé',
        messages: [
          { speaker: 'A', text: 'Buongiorno, come si sente oggi?', translation: 'Bonjour, comment vous sentez-vous aujourd\'hui ?' },
          { speaker: 'B', text: 'Non mi sento bene. Ho mal di testa e febbre.', translation: 'Je ne me sens pas bien. J\'ai mal à la tête et de la fièvre.' },
          { speaker: 'A', text: 'Da quanto tempo ha questi sintomi?', translation: 'Depuis combien de temps avez-vous ces symptômes ?' },
          { speaker: 'B', text: 'Da tre giorni. E ho anche mal di gola.', translation: 'Depuis trois jours. Et j\'ai aussi mal à la gorge.' },
          { speaker: 'A', text: 'Ha preso qualche medicina?', translation: 'Avez-vous pris des médicaments ?' },
          { speaker: 'B', text: 'Solo un po\' di aspirina.', translation: 'Seulement un peu d\'aspirine.' },
          { speaker: 'A', text: 'Le prescrivo un antibiotico. Prenda una compressa tre volte al giorno.', translation: 'Je vous prescris un antibiotique. Prenez un comprimé trois fois par jour.' },
          { speaker: 'B', text: 'Per quanto tempo?', translation: 'Pendant combien de temps ?' },
          { speaker: 'A', text: 'Per una settimana. E riposi molto.', translation: 'Pendant une semaine. Et reposez-vous beaucoup.' }
        ],
        vocabulary: [
          { word: 'il mal di testa', translation: 'le mal de tête' },
          { word: 'la febbre', translation: 'la fièvre' },
          { word: 'il mal di gola', translation: 'le mal de gorge' },
          { word: 'la medicina', translation: 'le médicament' },
          { word: 'la compressa', translation: 'le comprimé' },
          { word: 'prescrivere', translation: 'prescrire' }
        ],
        tips: [
          '"Ho mal di..." = "J\'ai mal à..."',
          '"Da quanto tempo?" = "Depuis combien de temps ?"'
        ]
      },
      {
        title: 'Faire les courses',
        icon: '🛒',
        scenario: 'Au supermarché',
        difficulty: 'débutant',
        messages: [
          { speaker: 'B', text: 'Scusi, dove posso trovare il latte?', translation: 'Excusez-moi, où puis-je trouver le lait ?' },
          { speaker: 'A', text: 'Il latte è nel reparto frigo, in fondo a destra.', translation: 'Le lait est au rayon frais, au fond à droite.' },
          { speaker: 'B', text: 'Grazie. E il pane fresco?', translation: 'Merci. Et le pain frais ?' },
          { speaker: 'A', text: 'Il pane è vicino all\'entrata, sulla sinistra.', translation: 'Le pain est près de l\'entrée, sur la gauche.' },
          { speaker: 'B', text: 'Avete anche frutta biologica?', translation: 'Avez-vous aussi des fruits bio ?' },
          { speaker: 'A', text: 'Sì, nel reparto ortofrutta, c\'è una sezione bio.', translation: 'Oui, au rayon fruits et légumes, il y a une section bio.' },
          { speaker: 'B', text: 'Perfetto. Dov\'è la cassa?', translation: 'Parfait. Où est la caisse ?' },
          { speaker: 'A', text: 'Le casse sono all\'uscita, davanti a lei.', translation: 'Les caisses sont à la sortie, devant vous.' }
        ],
        vocabulary: [
          { word: 'il latte', translation: 'le lait' },
          { word: 'il reparto', translation: 'le rayon' },
          { word: 'il frigo', translation: 'le frigo' },
          { word: 'biologico', translation: 'bio' },
          { word: 'la cassa', translation: 'la caisse' },
          { word: 'l\'uscita', translation: 'la sortie' }
        ],
        tips: [
          '"In fondo" = "au fond".',
          '"Ortofrutta" = fruits et légumes (orto = potager + frutta = fruits).'
        ]
      },
      {
        title: 'Prendre le train',
        icon: '🚂',
        scenario: 'Acheter un billet',
        difficulty: 'intermédiaire',
        messages: [
          { speaker: 'B', text: 'Buongiorno, vorrei un biglietto per Milano.', translation: 'Bonjour, je voudrais un billet pour Milan.' },
          { speaker: 'A', text: 'Solo andata o andata e ritorno?', translation: 'Aller simple ou aller-retour ?' },
          { speaker: 'B', text: 'Andata e ritorno, per favore.', translation: 'Aller-retour, s\'il vous plaît.' },
          { speaker: 'A', text: 'Quando vuole partire?', translation: 'Quand voulez-vous partir ?' },
          { speaker: 'B', text: 'Oggi pomeriggio, verso le tre.', translation: 'Cet après-midi, vers trois heures.' },
          { speaker: 'A', text: 'C\'è un treno alle 15:20. Prima o seconda classe?', translation: 'Il y a un train à 15h20. Première ou deuxième classe ?' },
          { speaker: 'B', text: 'Seconda classe. Quanto costa?', translation: 'Deuxième classe. Combien ça coûte ?' },
          { speaker: 'A', text: 'Sono quarantacinque euro. Da quale binario parte?', translation: 'Ça fait quarante-cinq euros. De quel quai part-il ?' },
          { speaker: 'A', text: 'Binario 7. Buon viaggio!', translation: 'Quai 7. Bon voyage !' }
        ],
        vocabulary: [
          { word: 'il biglietto', translation: 'le billet' },
          { word: 'solo andata', translation: 'aller simple' },
          { word: 'andata e ritorno', translation: 'aller-retour' },
          { word: 'il binario', translation: 'le quai' },
          { word: 'partire', translation: 'partir' },
          { word: 'il treno', translation: 'le train' }
        ],
        tips: [
          '"Verso" = "vers" (approximation d\'heure).',
          'N\'oubliez pas de composter votre billet en Italie !'
        ]
      },
      {
        title: 'Se présenter',
        icon: '👋',
        scenario: 'Faire connaissance',
        difficulty: 'débutant',
        messages: [
          { speaker: 'A', text: 'Ciao! Come ti chiami?', translation: 'Salut ! Comment tu t\'appelles ?' },
          { speaker: 'B', text: 'Mi chiamo Marco. E tu?', translation: 'Je m\'appelle Marco. Et toi ?' },
          { speaker: 'A', text: 'Io sono Giulia. Piacere!', translation: 'Moi c\'est Giulia. Enchanté !' },
          { speaker: 'B', text: 'Piacere mio! Di dove sei?', translation: 'Enchanté ! D\'où es-tu ?' },
          { speaker: 'A', text: 'Sono di Roma, ma abito a Milano. E tu?', translation: 'Je suis de Rome, mais j\'habite à Milan. Et toi ?' },
          { speaker: 'B', text: 'Sono francese, di Parigi.', translation: 'Je suis français, de Paris.' },
          { speaker: 'A', text: 'Che bello! Cosa fai qui in Italia?', translation: 'Super ! Que fais-tu ici en Italie ?' },
          { speaker: 'B', text: 'Studio italiano all\'università.', translation: 'J\'étudie l\'italien à l\'université.' },
          { speaker: 'A', text: 'Fantastico! Il tuo italiano è molto buono!', translation: 'Fantastique ! Ton italien est très bon !' }
        ],
        vocabulary: [
          { word: 'chiamarsi', translation: 's\'appeler' },
          { word: 'piacere', translation: 'enchanté' },
          { word: 'di dove sei?', translation: 'd\'où es-tu ?' },
          { word: 'abitare', translation: 'habiter' },
          { word: 'studiare', translation: 'étudier' }
        ],
        tips: [
          '"Mi chiamo" = littéralement "je m\'appelle".',
          '"Piacere" peut être utilisé seul ou avec "mio" (le plaisir est mien).'
        ]
      }
    ]
  } else {
    return [
      {
        title: 'Au café',
        icon: '☕',
        scenario: 'Commander au café',
        difficulty: 'débutant',
        messages: [
          { speaker: 'A', text: '¡Buenos días! ¿Qué desea?', translation: 'Bonjour ! Que désirez-vous ?' },
          { speaker: 'B', text: '¡Buenos días! Quisiera un café, por favor.', translation: 'Bonjour ! Je voudrais un café, s\'il vous plaît.' },
          { speaker: 'A', text: '¿Solo o con leche?', translation: 'Noir ou au lait ?' },
          { speaker: 'B', text: 'Con leche, gracias.', translation: 'Au lait, merci.' },
          { speaker: 'A', text: '¿Desea algo más?', translation: 'Désirez-vous autre chose ?' },
          { speaker: 'B', text: 'Sí, también un cruasán.', translation: 'Oui, aussi un croissant.' },
          { speaker: 'A', text: 'Perfecto. Son tres euros con cincuenta.', translation: 'Parfait. Ça fait trois euros cinquante.' },
          { speaker: 'B', text: 'Aquí tiene. ¡Gracias!', translation: 'Voilà. Merci !' }
        ],
        vocabulary: [
          { word: 'el café', translation: 'le café' },
          { word: 'con leche', translation: 'au lait' },
          { word: 'el cruasán', translation: 'le croissant' },
          { word: 'desear', translation: 'désirer' },
          { word: 'algo más', translation: 'autre chose' }
        ],
        tips: [
          'En Espagne, "café con leche" est très populaire.',
          '"Aquí tiene" est une façon polie de dire "voilà".'
        ]
      },
      {
        title: 'Au restaurant',
        icon: '🍝',
        scenario: 'Réserver et commander',
        difficulty: 'intermédiaire',
        messages: [
          { speaker: 'A', text: 'Buenas noches, ¿tienen reserva?', translation: 'Bonsoir, avez-vous une réservation ?' },
          { speaker: 'B', text: 'Sí, a nombre de García para dos personas.', translation: 'Oui, au nom de García pour deux personnes.' },
          { speaker: 'A', text: 'Perfecto, síganme. Aquí está la carta.', translation: 'Parfait, suivez-moi. Voici le menu.' },
          { speaker: 'B', text: 'Gracias. ¿Qué nos recomienda?', translation: 'Merci. Que nous recommandez-vous ?' },
          { speaker: 'A', text: 'La paella está muy buena hoy.', translation: 'La paella est très bonne aujourd\'hui.' },
          { speaker: 'B', text: 'Perfecto, la tomo. ¿Y de segundo?', translation: 'Parfait, je la prends. Et en plat principal ?' },
          { speaker: 'A', text: 'Tenemos un excelente solomillo.', translation: 'Nous avons un excellent filet de bœuf.' },
          { speaker: 'B', text: 'Vale. Y una botella de vino tinto, por favor.', translation: 'D\'accord. Et une bouteille de vin rouge, s\'il vous plaît.' }
        ],
        vocabulary: [
          { word: 'la reserva', translation: 'la réservation' },
          { word: 'la carta', translation: 'le menu' },
          { word: 'recomendar', translation: 'recommander' },
          { word: 'el primer plato', translation: 'l\'entrée' },
          { word: 'el segundo plato', translation: 'le plat principal' },
          { word: 'el solomillo', translation: 'le filet' }
        ],
        tips: [
          '"A nombre de..." signifie "au nom de...".',
          '"Vale" est très utilisé en Espagne pour dire "d\'accord".'
        ]
      },
      {
        title: 'À l\'hôtel',
        icon: '🏨',
        scenario: 'Check-in à l\'hôtel',
        difficulty: 'intermédiaire',
        messages: [
          { speaker: 'A', text: 'Buenos días, bienvenido al Hotel Madrid.', translation: 'Bonjour, bienvenue à l\'Hôtel Madrid.' },
          { speaker: 'B', text: 'Buenos días, tengo una reserva a nombre de López.', translation: 'Bonjour, j\'ai une réservation au nom de López.' },
          { speaker: 'A', text: 'Sí, una habitación doble para tres noches, ¿verdad?', translation: 'Oui, une chambre double pour trois nuits, n\'est-ce pas ?' },
          { speaker: 'B', text: 'Exacto. ¿La habitación tiene baño privado?', translation: 'Exact. La chambre a une salle de bain privée ?' },
          { speaker: 'A', text: 'Claro, con ducha y bañera. Aquí tiene la llave, habitación 305.', translation: 'Bien sûr, avec douche et baignoire. Voici la clé, chambre 305.' },
          { speaker: 'B', text: '¿A qué hora es el desayuno?', translation: 'À quelle heure est le petit-déjeuner ?' },
          { speaker: 'A', text: 'De siete a diez, en la primera planta.', translation: 'De sept heures à dix heures, au premier étage.' },
          { speaker: 'B', text: '¡Perfecto, muchas gracias!', translation: 'Parfait, merci beaucoup !' }
        ],
        vocabulary: [
          { word: 'la habitación', translation: 'la chambre' },
          { word: 'doble/individual', translation: 'double/simple' },
          { word: 'la llave', translation: 'la clé' },
          { word: 'el desayuno', translation: 'le petit-déjeuner' },
          { word: 'el baño', translation: 'la salle de bain' },
          { word: 'la ducha', translation: 'la douche' }
        ],
        tips: [
          '"De... a..." signifie "de... à..." pour les horaires.',
          'En Espagne, "la primera planta" est le premier étage (pas le rez-de-chaussée).'
        ]
      },
      {
        title: 'Demander son chemin',
        icon: '🗺️',
        scenario: 'Se repérer en ville',
        difficulty: 'débutant',
        messages: [
          { speaker: 'B', text: 'Perdone, ¿sabe dónde está la estación?', translation: 'Excusez-moi, savez-vous où est la gare ?' },
          { speaker: 'A', text: 'Sí, está bastante cerca. Siga todo recto.', translation: 'Oui, elle est assez proche. Allez tout droit.' },
          { speaker: 'B', text: '¿Y después?', translation: 'Et ensuite ?' },
          { speaker: 'A', text: 'En la plaza, gire a la izquierda.', translation: 'À la place, tournez à gauche.' },
          { speaker: 'B', text: 'A la izquierda, entendido.', translation: 'À gauche, compris.' },
          { speaker: 'A', text: 'Luego siga doscientos metros. La estación está a la derecha.', translation: 'Puis continuez deux cents mètres. La gare est sur la droite.' },
          { speaker: 'B', text: '¿Cuánto tiempo se tarda andando?', translation: 'Combien de temps faut-il à pied ?' },
          { speaker: 'A', text: 'Unos diez minutos.', translation: 'Environ dix minutes.' },
          { speaker: 'B', text: '¡Muchas gracias, muy amable!', translation: 'Merci beaucoup, très aimable !' }
        ],
        vocabulary: [
          { word: 'la estación', translation: 'la gare' },
          { word: 'todo recto', translation: 'tout droit' },
          { word: 'a la izquierda', translation: 'à gauche' },
          { word: 'a la derecha', translation: 'à droite' },
          { word: 'la plaza', translation: 'la place' },
          { word: 'andando', translation: 'à pied' }
        ],
        tips: [
          '"Perdone" est la forme polie de "excuse-moi".',
          '"Se tarda" = "il faut" (pour le temps).'
        ]
      },
      {
        title: 'Chez le médecin',
        icon: '🏥',
        scenario: 'Consultation médicale',
        difficulty: 'avancé',
        messages: [
          { speaker: 'A', text: 'Buenos días, ¿cómo se encuentra hoy?', translation: 'Bonjour, comment vous sentez-vous aujourd\'hui ?' },
          { speaker: 'B', text: 'No me encuentro bien. Tengo dolor de cabeza y fiebre.', translation: 'Je ne me sens pas bien. J\'ai mal à la tête et de la fièvre.' },
          { speaker: 'A', text: '¿Desde cuándo tiene estos síntomas?', translation: 'Depuis quand avez-vous ces symptômes ?' },
          { speaker: 'B', text: 'Desde hace tres días. Y también me duele la garganta.', translation: 'Depuis trois jours. Et j\'ai aussi mal à la gorge.' },
          { speaker: 'A', text: '¿Ha tomado algún medicamento?', translation: 'Avez-vous pris des médicaments ?' },
          { speaker: 'B', text: 'Solo un poco de aspirina.', translation: 'Seulement un peu d\'aspirine.' },
          { speaker: 'A', text: 'Le receto un antibiótico. Tome una pastilla tres veces al día.', translation: 'Je vous prescris un antibiotique. Prenez un comprimé trois fois par jour.' },
          { speaker: 'B', text: '¿Durante cuánto tiempo?', translation: 'Pendant combien de temps ?' },
          { speaker: 'A', text: 'Durante una semana. Y descanse mucho.', translation: 'Pendant une semaine. Et reposez-vous beaucoup.' }
        ],
        vocabulary: [
          { word: 'el dolor de cabeza', translation: 'le mal de tête' },
          { word: 'la fiebre', translation: 'la fièvre' },
          { word: 'el dolor de garganta', translation: 'le mal de gorge' },
          { word: 'el medicamento', translation: 'le médicament' },
          { word: 'la pastilla', translation: 'le comprimé' },
          { word: 'recetar', translation: 'prescrire' }
        ],
        tips: [
          '"Me duele..." = "J\'ai mal à..."',
          '"¿Desde cuándo?" = "Depuis quand ?"'
        ]
      },
      {
        title: 'Faire les courses',
        icon: '🛒',
        scenario: 'Au supermarché',
        difficulty: 'débutant',
        messages: [
          { speaker: 'B', text: 'Perdone, ¿dónde puedo encontrar la leche?', translation: 'Excusez-moi, où puis-je trouver le lait ?' },
          { speaker: 'A', text: 'La leche está en la sección de refrigerados, al fondo a la derecha.', translation: 'Le lait est au rayon frais, au fond à droite.' },
          { speaker: 'B', text: 'Gracias. ¿Y el pan fresco?', translation: 'Merci. Et le pain frais ?' },
          { speaker: 'A', text: 'El pan está cerca de la entrada, a la izquierda.', translation: 'Le pain est près de l\'entrée, sur la gauche.' },
          { speaker: 'B', text: '¿Tienen también fruta ecológica?', translation: 'Avez-vous aussi des fruits bio ?' },
          { speaker: 'A', text: 'Sí, en la sección de frutas y verduras, hay una zona ecológica.', translation: 'Oui, au rayon fruits et légumes, il y a une zone bio.' },
          { speaker: 'B', text: 'Perfecto. ¿Dónde está la caja?', translation: 'Parfait. Où est la caisse ?' },
          { speaker: 'A', text: 'Las cajas están en la salida, delante de usted.', translation: 'Les caisses sont à la sortie, devant vous.' }
        ],
        vocabulary: [
          { word: 'la leche', translation: 'le lait' },
          { word: 'la sección', translation: 'le rayon' },
          { word: 'los refrigerados', translation: 'les produits frais' },
          { word: 'ecológico', translation: 'bio' },
          { word: 'la caja', translation: 'la caisse' },
          { word: 'la salida', translation: 'la sortie' }
        ],
        tips: [
          '"Al fondo" = "au fond".',
          '"Frutas y verduras" = fruits et légumes.'
        ]
      },
      {
        title: 'Prendre le train',
        icon: '🚂',
        scenario: 'Acheter un billet',
        difficulty: 'intermédiaire',
        messages: [
          { speaker: 'B', text: 'Buenos días, quisiera un billete para Barcelona.', translation: 'Bonjour, je voudrais un billet pour Barcelone.' },
          { speaker: 'A', text: '¿Solo ida o ida y vuelta?', translation: 'Aller simple ou aller-retour ?' },
          { speaker: 'B', text: 'Ida y vuelta, por favor.', translation: 'Aller-retour, s\'il vous plaît.' },
          { speaker: 'A', text: '¿Cuándo quiere salir?', translation: 'Quand voulez-vous partir ?' },
          { speaker: 'B', text: 'Esta tarde, sobre las tres.', translation: 'Cet après-midi, vers trois heures.' },
          { speaker: 'A', text: 'Hay un tren a las 15:20. ¿Primera o segunda clase?', translation: 'Il y a un train à 15h20. Première ou deuxième classe ?' },
          { speaker: 'B', text: 'Segunda clase. ¿Cuánto cuesta?', translation: 'Deuxième classe. Combien ça coûte ?' },
          { speaker: 'A', text: 'Son cuarenta y cinco euros. ¿De qué andén sale?', translation: 'Ça fait quarante-cinq euros. De quel quai part-il ?' },
          { speaker: 'A', text: 'Andén 7. ¡Buen viaje!', translation: 'Quai 7. Bon voyage !' }
        ],
        vocabulary: [
          { word: 'el billete', translation: 'le billet' },
          { word: 'solo ida', translation: 'aller simple' },
          { word: 'ida y vuelta', translation: 'aller-retour' },
          { word: 'el andén', translation: 'le quai' },
          { word: 'salir', translation: 'partir' },
          { word: 'el tren', translation: 'le train' }
        ],
        tips: [
          '"Sobre" = "vers" (approximation d\'heure).',
          'En Espagne, les trains AVE sont très rapides !'
        ]
      },
      {
        title: 'Se présenter',
        icon: '👋',
        scenario: 'Faire connaissance',
        difficulty: 'débutant',
        messages: [
          { speaker: 'A', text: '¡Hola! ¿Cómo te llamas?', translation: 'Salut ! Comment tu t\'appelles ?' },
          { speaker: 'B', text: 'Me llamo Carlos. ¿Y tú?', translation: 'Je m\'appelle Carlos. Et toi ?' },
          { speaker: 'A', text: 'Yo soy María. ¡Mucho gusto!', translation: 'Moi c\'est María. Enchanté !' },
          { speaker: 'B', text: '¡Igualmente! ¿De dónde eres?', translation: 'De même ! D\'où es-tu ?' },
          { speaker: 'A', text: 'Soy de Madrid, pero vivo en Barcelona. ¿Y tú?', translation: 'Je suis de Madrid, mais j\'habite à Barcelone. Et toi ?' },
          { speaker: 'B', text: 'Soy francés, de París.', translation: 'Je suis français, de Paris.' },
          { speaker: 'A', text: '¡Qué bien! ¿Qué haces aquí en España?', translation: 'Super ! Que fais-tu ici en Espagne ?' },
          { speaker: 'B', text: 'Estudio español en la universidad.', translation: 'J\'étudie l\'espagnol à l\'université.' },
          { speaker: 'A', text: '¡Genial! ¡Tu español es muy bueno!', translation: 'Génial ! Ton espagnol est très bon !' }
        ],
        vocabulary: [
          { word: 'llamarse', translation: 's\'appeler' },
          { word: 'mucho gusto', translation: 'enchanté' },
          { word: '¿de dónde eres?', translation: 'd\'où es-tu ?' },
          { word: 'vivir', translation: 'habiter' },
          { word: 'estudiar', translation: 'étudier' }
        ],
        tips: [
          '"Me llamo" = littéralement "je m\'appelle".',
          '"Igualmente" = "de même" / "pareillement".'
        ]
      }
    ]
  }
})

const scenarios = computed(() => {
  const unique = new Set(conversationsData.value.map(c => c.scenario))
  return Array.from(unique)
})

const filteredConversations = computed(() => {
  if (!selectedScenario.value) return conversationsData.value
  return conversationsData.value.filter(c => c.scenario === selectedScenario.value)
})

const languageLabel = computed(() => 
  learningStore.currentLanguage === 'it' ? '🇮🇹 Italien' : '🇪🇸 Espagnol'
)

const getDifficultyColor = (difficulty: string) => {
  switch (difficulty) {
    case 'débutant': return '#27ae60'
    case 'intermédiaire': return '#f39c12'
    case 'avancé': return '#e74c3c'
    default: return '#7f8c8d'
  }
}
</script>

<template>
  <div class="section-container">
    <header class="section-header">
      <h1>💬 Conversations</h1>
      <p class="section-subtitle">Apprenez avec des dialogues réels en {{ languageLabel }}</p>
      
      <div class="language-toggle">
        <button 
          :class="['lang-btn', { active: learningStore.currentLanguage === 'it' }]"
          @click="learningStore.setLanguage('it')"
        >
          🇮🇹 Italien
        </button>
        <button 
          :class="['lang-btn', { active: learningStore.currentLanguage === 'es' }]"
          @click="learningStore.setLanguage('es')"
        >
          🇪🇸 Espagnol
        </button>
      </div>
    </header>

    <!-- Scenario filter -->
    <div class="scenario-filter">
      <button 
        :class="['scenario-btn', { active: !selectedScenario }]"
        @click="selectedScenario = null"
      >
        📋 Tous
      </button>
      <button 
        v-for="scenario in scenarios" 
        :key="scenario"
        :class="['scenario-btn', { active: selectedScenario === scenario }]"
        @click="selectedScenario = scenario"
      >
        {{ scenario }}
      </button>
    </div>

    <!-- Conversations list -->
    <div class="conversations-list">
      <div 
        v-for="(conv, idx) in filteredConversations" 
        :key="idx" 
        class="conversation-card card"
      >
        <div 
          class="conversation-header"
          @click="expandedConversation = expandedConversation === idx ? null : idx"
        >
          <div class="conv-icon">{{ conv.icon }}</div>
          <div class="conv-info">
            <h3>{{ conv.title }}</h3>
            <p class="conv-scenario">{{ conv.scenario }}</p>
          </div>
          <span 
            class="difficulty-badge"
            :style="{ background: getDifficultyColor(conv.difficulty) }"
          >
            {{ conv.difficulty }}
          </span>
          <button 
            class="play-all-btn"
            @click.stop="speakConversation(conv.messages)"
            :class="{ playing: playingId === 'conversation' }"
          >
            🔊 Écouter
          </button>
          <span class="expand-icon">{{ expandedConversation === idx ? '▼' : '▶' }}</span>
        </div>

        <div v-if="expandedConversation === idx" class="conversation-content">
          <!-- Messages -->
          <div class="messages">
            <div 
              v-for="(msg, msgIdx) in conv.messages" 
              :key="msgIdx"
              class="message"
              :class="msg.speaker === 'A' ? 'speaker-a' : 'speaker-b'"
            >
              <div class="message-bubble">
                <div class="message-text">{{ msg.text }}</div>
                <div class="message-translation">{{ msg.translation }}</div>
                <button 
                  class="message-audio"
                  @click="speak(msg.text, `msg-${idx}-${msgIdx}`)"
                  :class="{ playing: playingId === `msg-${idx}-${msgIdx}` }"
                >
                  🔊
                </button>
              </div>
              <div class="speaker-label">{{ msg.speaker === 'A' ? '👤 A' : '👥 B' }}</div>
            </div>
          </div>

          <!-- Vocabulary -->
          <div class="vocabulary-section">
            <h4>📚 Vocabulaire clé</h4>
            <div class="vocab-list">
              <div 
                v-for="(vocab, vIdx) in conv.vocabulary" 
                :key="vIdx"
                class="vocab-item"
                @click="speak(vocab.word, `vocab-${idx}-${vIdx}`)"
              >
                <span class="vocab-word">{{ vocab.word }}</span>
                <span class="vocab-trans">{{ vocab.translation }}</span>
                <span class="vocab-audio" :class="{ playing: playingId === `vocab-${idx}-${vIdx}` }">🔊</span>
              </div>
            </div>
          </div>

          <!-- Tips -->
          <div class="tips-section">
            <h4>💡 Conseils</h4>
            <ul class="tips-list">
              <li v-for="(tip, tIdx) in conv.tips" :key="tIdx">{{ tip }}</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.section-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.section-header {
  text-align: center;
  margin-bottom: 2rem;
}

.section-header h1 {
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.section-subtitle {
  color: #7f8c8d;
  margin-bottom: 1.5rem;
}

.language-toggle {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.lang-btn {
  padding: 0.75rem 1.5rem;
  border: 2px solid #ddd;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.lang-btn:hover {
  border-color: #3498db;
}

.lang-btn.active {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

/* Scenario filter */
.scenario-filter {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.scenario-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  background: white;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
}

.scenario-btn:hover {
  border-color: #9b59b6;
}

.scenario-btn.active {
  background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%);
  color: white;
  border-color: transparent;
}

/* Conversations */
.conversations-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.conversation-card {
  overflow: hidden;
  transition: all 0.3s;
}

.conversation-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.25rem;
  cursor: pointer;
  transition: background 0.2s;
}

.conversation-header:hover {
  background: #f8f9fa;
}

.conv-icon {
  font-size: 2.5rem;
}

.conv-info {
  flex: 1;
}

.conv-info h3 {
  margin: 0 0 0.25rem 0;
  color: #2c3e50;
  font-size: 1.1rem;
}

.conv-scenario {
  margin: 0;
  color: #7f8c8d;
  font-size: 0.9rem;
}

.difficulty-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 15px;
  color: white;
  font-size: 0.8rem;
  font-weight: 500;
}

.play-all-btn {
  padding: 0.5rem 1rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.85rem;
  transition: all 0.2s;
}

.play-all-btn:hover {
  transform: scale(1.05);
}

.play-all-btn.playing {
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.expand-icon {
  color: #7f8c8d;
  font-size: 0.8rem;
}

/* Conversation content */
.conversation-content {
  padding: 0 1.25rem 1.25rem;
  animation: slideDown 0.3s ease;
}

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Messages */
.messages {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 12px;
}

.message {
  display: flex;
  flex-direction: column;
  max-width: 80%;
}

.message.speaker-a {
  align-self: flex-start;
}

.message.speaker-b {
  align-self: flex-end;
}

.message-bubble {
  padding: 1rem;
  border-radius: 16px;
  position: relative;
}

.speaker-a .message-bubble {
  background: white;
  border: 1px solid #e0e0e0;
  border-bottom-left-radius: 4px;
}

.speaker-b .message-bubble {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-bottom-right-radius: 4px;
}

.message-text {
  font-size: 1rem;
  margin-bottom: 0.5rem;
}

.message-translation {
  font-size: 0.85rem;
  opacity: 0.7;
  font-style: italic;
}

.message-audio {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 0.9rem;
  opacity: 0.5;
  transition: all 0.2s;
}

.message-audio:hover, .message-audio.playing {
  opacity: 1;
  transform: scale(1.1);
}

.speaker-label {
  font-size: 0.75rem;
  color: #7f8c8d;
  margin-top: 0.25rem;
}

.speaker-a .speaker-label {
  margin-left: 0.5rem;
}

.speaker-b .speaker-label {
  margin-right: 0.5rem;
  text-align: right;
}

/* Vocabulary */
.vocabulary-section {
  margin-bottom: 1.5rem;
}

.vocabulary-section h4 {
  margin: 0 0 0.75rem 0;
  color: #2c3e50;
}

.vocab-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.vocab-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: #f0f4ff;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.vocab-item:hover {
  background: #e0e8ff;
  transform: translateY(-2px);
}

.vocab-word {
  font-weight: 600;
  color: #667eea;
}

.vocab-trans {
  color: #666;
  font-size: 0.9rem;
}

.vocab-audio {
  font-size: 0.8rem;
  opacity: 0.5;
}

.vocab-item:hover .vocab-audio, .vocab-audio.playing {
  opacity: 1;
}

/* Tips */
.tips-section h4 {
  margin: 0 0 0.75rem 0;
  color: #2c3e50;
}

.tips-list {
  margin: 0;
  padding-left: 1.5rem;
}

.tips-list li {
  color: #555;
  margin-bottom: 0.5rem;
  line-height: 1.5;
}

/* Responsive */
@media (max-width: 768px) {
  .conversation-header {
    flex-wrap: wrap;
    gap: 0.75rem;
  }
  
  .conv-icon {
    font-size: 2rem;
  }
  
  .play-all-btn {
    order: 5;
    width: 100%;
    margin-top: 0.5rem;
  }
  
  .message {
    max-width: 90%;
  }
  
  .vocab-list {
    flex-direction: column;
  }
  
  .vocab-item {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .section-header h1 {
    font-size: 1.8rem;
  }
  
  .language-toggle {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .scenario-filter {
    gap: 0.25rem;
  }
  
  .scenario-btn {
    padding: 0.4rem 0.75rem;
    font-size: 0.8rem;
  }
  
  .message-bubble {
    padding: 0.75rem;
  }
  
  .message-text {
    font-size: 0.95rem;
  }
}
</style>
