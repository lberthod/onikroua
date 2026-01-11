<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'

interface VocabWord {
  french: string
  italian: string
  spanish: string
  italianPhonetic: string
  spanishPhonetic: string
  category: string
  imageQuery: string
  exampleIT: string
  exampleES: string
}

interface Photo {
  id: number
  width: number
  height: number
  url: string
  photographer: string
  photographer_url: string
  src: {
    original: string
    large2x: string
    large: string
    medium: string
    small: string
    portrait: string
    landscape: string
    tiny: string
  }
}

interface VocabCard {
  word: VocabWord
  photo: Photo | null
}

const PEXELS_API_KEY = 'BbFWiz2zJTzLh0zRkIKsuaqXuQ9tVfx9oPiFg4wmy8BzwDQsEkUCrIZk'

// Vocabulaire par catégories avec phonétique et exemples
const vocabulary: VocabWord[] = [
  // Animaux (15 mots)
  { french: 'Chat', italian: 'Gatto', spanish: 'Gato', italianPhonetic: 'GAT-to', spanishPhonetic: 'GA-to', category: 'Animaux', imageQuery: 'cat', exampleIT: 'Il gatto dorme.', exampleES: 'El gato duerme.' },
  { french: 'Chien', italian: 'Cane', spanish: 'Perro', italianPhonetic: 'KA-ne', spanishPhonetic: 'PÈ-ro', category: 'Animaux', imageQuery: 'dog', exampleIT: 'Il cane corre.', exampleES: 'El perro corre.' },
  { french: 'Oiseau', italian: 'Uccello', spanish: 'Pájaro', italianPhonetic: 'ou-TCHÈ-lo', spanishPhonetic: 'PA-ha-ro', category: 'Animaux', imageQuery: 'bird', exampleIT: "L'uccello canta.", exampleES: 'El pájaro canta.' },
  { french: 'Poisson', italian: 'Pesce', spanish: 'Pez', italianPhonetic: 'PÈ-che', spanishPhonetic: 'PÈSS', category: 'Animaux', imageQuery: 'fish', exampleIT: 'Il pesce nuota.', exampleES: 'El pez nada.' },
  { french: 'Cheval', italian: 'Cavallo', spanish: 'Caballo', italianPhonetic: 'ka-VAL-lo', spanishPhonetic: 'ka-BA-yo', category: 'Animaux', imageQuery: 'horse', exampleIT: 'Il cavallo galoppa.', exampleES: 'El caballo galopa.' },
  { french: 'Papillon', italian: 'Farfalla', spanish: 'Mariposa', italianPhonetic: 'far-FAL-la', spanishPhonetic: 'ma-ri-PO-sa', category: 'Animaux', imageQuery: 'butterfly', exampleIT: 'La farfalla vola.', exampleES: 'La mariposa vuela.' },
  { french: 'Vache', italian: 'Mucca', spanish: 'Vaca', italianPhonetic: 'MOU-ka', spanishPhonetic: 'BA-ka', category: 'Animaux', imageQuery: 'cow', exampleIT: 'La mucca fa il latte.', exampleES: 'La vaca da leche.' },
  { french: 'Mouton', italian: 'Pecora', spanish: 'Oveja', italianPhonetic: 'PÈ-ko-ra', spanishPhonetic: 'o-BÈ-ha', category: 'Animaux', imageQuery: 'sheep', exampleIT: 'La pecora mangia erba.', exampleES: 'La oveja come hierba.' },
  { french: 'Cochon', italian: 'Maiale', spanish: 'Cerdo', italianPhonetic: 'ma-YA-le', spanishPhonetic: 'SÈR-do', category: 'Animaux', imageQuery: 'pig', exampleIT: 'Il maiale è rosa.', exampleES: 'El cerdo es rosa.' },
  { french: 'Lapin', italian: 'Coniglio', spanish: 'Conejo', italianPhonetic: 'ko-NI-lyo', spanishPhonetic: 'ko-NÈ-ho', category: 'Animaux', imageQuery: 'rabbit', exampleIT: 'Il coniglio salta.', exampleES: 'El conejo salta.' },
  { french: 'Souris', italian: 'Topo', spanish: 'Ratón', italianPhonetic: 'TO-po', spanishPhonetic: 'ra-TON', category: 'Animaux', imageQuery: 'mouse', exampleIT: 'Il topo è piccolo.', exampleES: 'El ratón es pequeño.' },
  { french: 'Lion', italian: 'Leone', spanish: 'León', italianPhonetic: 'lè-O-ne', spanishPhonetic: 'lè-ON', category: 'Animaux', imageQuery: 'lion', exampleIT: 'Il leone ruggisce.', exampleES: 'El león ruge.' },
  { french: 'Éléphant', italian: 'Elefante', spanish: 'Elefante', italianPhonetic: 'è-lè-FAN-te', spanishPhonetic: 'è-lè-FAN-tè', category: 'Animaux', imageQuery: 'elephant', exampleIT: "L'elefante è grande.", exampleES: 'El elefante es grande.' },
  { french: 'Singe', italian: 'Scimmia', spanish: 'Mono', italianPhonetic: 'CHIM-mia', spanishPhonetic: 'MO-no', category: 'Animaux', imageQuery: 'monkey', exampleIT: 'La scimmia mangia banane.', exampleES: 'El mono come plátanos.' },
  { french: 'Aigle', italian: 'Aquila', spanish: 'Águila', italianPhonetic: 'A-koui-la', spanishPhonetic: 'A-gui-la', category: 'Animaux', imageQuery: 'eagle', exampleIT: "L'aquila vola alto.", exampleES: 'El águila vuela alto.' },
  
  // Nourriture (20 mots)
  { french: 'Pizza', italian: 'Pizza', spanish: 'Pizza', italianPhonetic: 'PIT-tsa', spanishPhonetic: 'PIT-sa', category: 'Nourriture', imageQuery: 'pizza', exampleIT: 'La pizza è buona.', exampleES: 'La pizza es buena.' },
  { french: 'Pâtes', italian: 'Pasta', spanish: 'Pasta', italianPhonetic: 'PA-sta', spanishPhonetic: 'PA-sta', category: 'Nourriture', imageQuery: 'pasta', exampleIT: 'La pasta è italiana.', exampleES: 'La pasta es italiana.' },
  { french: 'Pain', italian: 'Pane', spanish: 'Pan', italianPhonetic: 'PA-ne', spanishPhonetic: 'PAN', category: 'Nourriture', imageQuery: 'bread', exampleIT: 'Il pane è fresco.', exampleES: 'El pan es fresco.' },
  { french: 'Fromage', italian: 'Formaggio', spanish: 'Queso', italianPhonetic: 'for-MA-djo', spanishPhonetic: 'KÈ-so', category: 'Nourriture', imageQuery: 'cheese', exampleIT: 'Il formaggio è buono.', exampleES: 'El queso es bueno.' },
  { french: 'Café', italian: 'Caffè', spanish: 'Café', italianPhonetic: 'kaf-FÈ', spanishPhonetic: 'ka-FÈ', category: 'Nourriture', imageQuery: 'coffee', exampleIT: 'Il caffè è caldo.', exampleES: 'El café está caliente.' },
  { french: 'Eau', italian: 'Acqua', spanish: 'Agua', italianPhonetic: 'A-koua', spanishPhonetic: 'A-goua', category: 'Nourriture', imageQuery: 'water', exampleIT: "L'acqua è fresca.", exampleES: 'El agua es fresca.' },
  { french: 'Vin', italian: 'Vino', spanish: 'Vino', italianPhonetic: 'VI-no', spanishPhonetic: 'BI-no', category: 'Nourriture', imageQuery: 'wine', exampleIT: 'Il vino è rosso.', exampleES: 'El vino es rojo.' },
  { french: 'Pomme', italian: 'Mela', spanish: 'Manzana', italianPhonetic: 'MÈ-la', spanishPhonetic: 'man-SA-na', category: 'Nourriture', imageQuery: 'apple', exampleIT: 'La mela è rossa.', exampleES: 'La manzana es roja.' },
  { french: 'Orange', italian: 'Arancia', spanish: 'Naranja', italianPhonetic: 'a-RAN-tcha', spanishPhonetic: 'na-RAN-ha', category: 'Nourriture', imageQuery: 'orange', exampleIT: "L'arancia è dolce.", exampleES: 'La naranja es dulce.' },
  { french: 'Banane', italian: 'Banana', spanish: 'Plátano', italianPhonetic: 'ba-NA-na', spanishPhonetic: 'PLA-ta-no', category: 'Nourriture', imageQuery: 'banana', exampleIT: 'La banana è gialla.', exampleES: 'El plátano es amarillo.' },
  { french: 'Tomate', italian: 'Pomodoro', spanish: 'Tomate', italianPhonetic: 'po-mo-DO-ro', spanishPhonetic: 'to-MA-tè', category: 'Nourriture', imageQuery: 'tomato', exampleIT: 'Il pomodoro è rosso.', exampleES: 'El tomate es rojo.' },
  { french: 'Salade', italian: 'Insalata', spanish: 'Ensalada', italianPhonetic: 'in-sa-LA-ta', spanishPhonetic: 'èn-sa-LA-da', category: 'Nourriture', imageQuery: 'salad', exampleIT: "L'insalata è verde.", exampleES: 'La ensalada es verde.' },
  { french: 'Viande', italian: 'Carne', spanish: 'Carne', italianPhonetic: 'KAR-ne', spanishPhonetic: 'KAR-nè', category: 'Nourriture', imageQuery: 'meat', exampleIT: 'La carne è cotta.', exampleES: 'La carne está cocida.' },
  { french: 'Poulet', italian: 'Pollo', spanish: 'Pollo', italianPhonetic: 'POL-lo', spanishPhonetic: 'PO-yo', category: 'Nourriture', imageQuery: 'chicken', exampleIT: 'Il pollo è buono.', exampleES: 'El pollo es bueno.' },
  { french: 'Œuf', italian: 'Uovo', spanish: 'Huevo', italianPhonetic: 'OU-o-vo', spanishPhonetic: 'ouÈ-bo', category: 'Nourriture', imageQuery: 'egg', exampleIT: "L'uovo è fresco.", exampleES: 'El huevo es fresco.' },
  { french: 'Lait', italian: 'Latte', spanish: 'Leche', italianPhonetic: 'LAT-te', spanishPhonetic: 'LÈ-tchè', category: 'Nourriture', imageQuery: 'milk', exampleIT: 'Il latte è bianco.', exampleES: 'La leche es blanca.' },
  { french: 'Gâteau', italian: 'Torta', spanish: 'Pastel', italianPhonetic: 'TOR-ta', spanishPhonetic: 'pa-STÈL', category: 'Nourriture', imageQuery: 'cake', exampleIT: 'La torta è dolce.', exampleES: 'El pastel es dulce.' },
  { french: 'Glace', italian: 'Gelato', spanish: 'Helado', italianPhonetic: 'djè-LA-to', spanishPhonetic: 'è-LA-do', category: 'Nourriture', imageQuery: 'ice cream', exampleIT: 'Il gelato è freddo.', exampleES: 'El helado está frío.' },
  { french: 'Chocolat', italian: 'Cioccolato', spanish: 'Chocolate', italianPhonetic: 'tchok-ko-LA-to', spanishPhonetic: 'tcho-ko-LA-tè', category: 'Nourriture', imageQuery: 'chocolate', exampleIT: 'Il cioccolato è dolce.', exampleES: 'El chocolate es dulce.' },
  { french: 'Soupe', italian: 'Zuppa', spanish: 'Sopa', italianPhonetic: 'TSOU-pa', spanishPhonetic: 'SO-pa', category: 'Nourriture', imageQuery: 'soup', exampleIT: 'La zuppa è calda.', exampleES: 'La sopa está caliente.' },
  
  // Nature (15 mots)
  { french: 'Montagne', italian: 'Montagna', spanish: 'Montaña', italianPhonetic: 'mon-TA-nya', spanishPhonetic: 'mon-TA-nya', category: 'Nature', imageQuery: 'mountain', exampleIT: 'La montagna è alta.', exampleES: 'La montaña es alta.' },
  { french: 'Mer', italian: 'Mare', spanish: 'Mar', italianPhonetic: 'MA-re', spanishPhonetic: 'MAR', category: 'Nature', imageQuery: 'sea', exampleIT: 'Il mare è blu.', exampleES: 'El mar es azul.' },
  { french: 'Plage', italian: 'Spiaggia', spanish: 'Playa', italianPhonetic: 'SPI-a-dja', spanishPhonetic: 'PLA-ya', category: 'Nature', imageQuery: 'beach', exampleIT: 'La spiaggia è bella.', exampleES: 'La playa es bonita.' },
  { french: 'Arbre', italian: 'Albero', spanish: 'Árbol', italianPhonetic: 'AL-bè-ro', spanishPhonetic: 'AR-bol', category: 'Nature', imageQuery: 'tree', exampleIT: "L'albero è grande.", exampleES: 'El árbol es grande.' },
  { french: 'Fleur', italian: 'Fiore', spanish: 'Flor', italianPhonetic: 'FIO-re', spanishPhonetic: 'FLOR', category: 'Nature', imageQuery: 'flower', exampleIT: 'Il fiore è bello.', exampleES: 'La flor es bonita.' },
  { french: 'Soleil', italian: 'Sole', spanish: 'Sol', italianPhonetic: 'SO-le', spanishPhonetic: 'SOL', category: 'Nature', imageQuery: 'sun', exampleIT: 'Il sole brilla.', exampleES: 'El sol brilla.' },
  { french: 'Lune', italian: 'Luna', spanish: 'Luna', italianPhonetic: 'LOU-na', spanishPhonetic: 'LOU-na', category: 'Nature', imageQuery: 'moon', exampleIT: 'La luna è bianca.', exampleES: 'La luna es blanca.' },
  { french: 'Étoile', italian: 'Stella', spanish: 'Estrella', italianPhonetic: 'STÈL-la', spanishPhonetic: 'è-STRÈ-ya', category: 'Nature', imageQuery: 'star', exampleIT: 'La stella brilla.', exampleES: 'La estrella brilla.' },
  { french: 'Nuage', italian: 'Nuvola', spanish: 'Nube', italianPhonetic: 'NOU-vo-la', spanishPhonetic: 'NOU-bè', category: 'Nature', imageQuery: 'cloud', exampleIT: 'La nuvola è bianca.', exampleES: 'La nube es blanca.' },
  { french: 'Pluie', italian: 'Pioggia', spanish: 'Lluvia', italianPhonetic: 'PIO-dja', spanishPhonetic: 'YOU-bia', category: 'Nature', imageQuery: 'rain', exampleIT: 'La pioggia cade.', exampleES: 'La lluvia cae.' },
  { french: 'Neige', italian: 'Neve', spanish: 'Nieve', italianPhonetic: 'NÈ-ve', spanishPhonetic: 'NIÈ-bè', category: 'Nature', imageQuery: 'snow', exampleIT: 'La neve è bianca.', exampleES: 'La nieve es blanca.' },
  { french: 'Vent', italian: 'Vento', spanish: 'Viento', italianPhonetic: 'VÈN-to', spanishPhonetic: 'BIÈN-to', category: 'Nature', imageQuery: 'wind', exampleIT: 'Il vento soffia.', exampleES: 'El viento sopla.' },
  { french: 'Rivière', italian: 'Fiume', spanish: 'Río', italianPhonetic: 'FI-ou-me', spanishPhonetic: 'RI-o', category: 'Nature', imageQuery: 'river', exampleIT: 'Il fiume scorre.', exampleES: 'El río corre.' },
  { french: 'Lac', italian: 'Lago', spanish: 'Lago', italianPhonetic: 'LA-go', spanishPhonetic: 'LA-go', category: 'Nature', imageQuery: 'lake', exampleIT: 'Il lago è calmo.', exampleES: 'El lago está tranquilo.' },
  { french: 'Forêt', italian: 'Foresta', spanish: 'Bosque', italianPhonetic: 'fo-RÈ-sta', spanishPhonetic: 'BO-skè', category: 'Nature', imageQuery: 'forest', exampleIT: 'La foresta è verde.', exampleES: 'El bosque es verde.' },
  
  // Ville (15 mots)
  { french: 'Rue', italian: 'Strada', spanish: 'Calle', italianPhonetic: 'STRA-da', spanishPhonetic: 'KA-yè', category: 'Ville', imageQuery: 'street', exampleIT: 'La strada è lunga.', exampleES: 'La calle es larga.' },
  { french: 'Maison', italian: 'Casa', spanish: 'Casa', italianPhonetic: 'KA-sa', spanishPhonetic: 'KA-sa', category: 'Ville', imageQuery: 'house', exampleIT: 'La casa è grande.', exampleES: 'La casa es grande.' },
  { french: 'Voiture', italian: 'Macchina', spanish: 'Coche', italianPhonetic: 'MA-ki-na', spanishPhonetic: 'KO-tchè', category: 'Ville', imageQuery: 'car', exampleIT: 'La macchina è veloce.', exampleES: 'El coche es rápido.' },
  { french: 'Bus', italian: 'Autobus', spanish: 'Autobús', italianPhonetic: 'a-ou-to-BOUS', spanishPhonetic: 'a-ou-to-BOUS', category: 'Ville', imageQuery: 'bus', exampleIT: "L'autobus arriva.", exampleES: 'El autobús llega.' },
  { french: 'Vélo', italian: 'Bicicletta', spanish: 'Bicicleta', italianPhonetic: 'bi-tchi-KLÈT-ta', spanishPhonetic: 'bi-si-KLÈ-ta', category: 'Ville', imageQuery: 'bicycle', exampleIT: 'La bicicletta è rossa.', exampleES: 'La bicicleta es roja.' },
  { french: 'Pont', italian: 'Ponte', spanish: 'Puente', italianPhonetic: 'PON-te', spanishPhonetic: 'POUÈN-tè', category: 'Ville', imageQuery: 'bridge', exampleIT: 'Il ponte è lungo.', exampleES: 'El puente es largo.' },
  { french: 'Église', italian: 'Chiesa', spanish: 'Iglesia', italianPhonetic: 'KIÈ-sa', spanishPhonetic: 'i-GLÈ-sia', category: 'Ville', imageQuery: 'church', exampleIT: 'La chiesa è antica.', exampleES: 'La iglesia es antigua.' },
  { french: 'Place', italian: 'Piazza', spanish: 'Plaza', italianPhonetic: 'PI-at-tsa', spanishPhonetic: 'PLA-sa', category: 'Ville', imageQuery: 'square', exampleIT: 'La piazza è bella.', exampleES: 'La plaza es bonita.' },
  { french: 'Banque', italian: 'Banca', spanish: 'Banco', italianPhonetic: 'BAN-ka', spanishPhonetic: 'BAN-ko', category: 'Ville', imageQuery: 'bank', exampleIT: 'La banca è chiusa.', exampleES: 'El banco está cerrado.' },
  { french: 'Magasin', italian: 'Negozio', spanish: 'Tienda', italianPhonetic: 'nè-GO-tsio', spanishPhonetic: 'TIÈN-da', category: 'Ville', imageQuery: 'shop', exampleIT: 'Il negozio è aperto.', exampleES: 'La tienda está abierta.' },
  { french: 'Restaurant', italian: 'Ristorante', spanish: 'Restaurante', italianPhonetic: 'ri-sto-RAN-te', spanishPhonetic: 'rè-stao-RAN-tè', category: 'Ville', imageQuery: 'restaurant', exampleIT: 'Il ristorante è buono.', exampleES: 'El restaurante es bueno.' },
  { french: 'Hôpital', italian: 'Ospedale', spanish: 'Hospital', italianPhonetic: 'o-spè-DA-le', spanishPhonetic: 'o-spi-TAL', category: 'Ville', imageQuery: 'hospital', exampleIT: "L'ospedale è grande.", exampleES: 'El hospital es grande.' },
  { french: 'École', italian: 'Scuola', spanish: 'Escuela', italianPhonetic: 'SKOU-o-la', spanishPhonetic: 'è-SKOU-è-la', category: 'Ville', imageQuery: 'school', exampleIT: 'La scuola è vicina.', exampleES: 'La escuela está cerca.' },
  { french: 'Parc', italian: 'Parco', spanish: 'Parque', italianPhonetic: 'PAR-ko', spanishPhonetic: 'PAR-kè', category: 'Ville', imageQuery: 'park', exampleIT: 'Il parco è verde.', exampleES: 'El parque es verde.' },
  { french: 'Gare', italian: 'Stazione', spanish: 'Estación', italianPhonetic: 'sta-TSI-o-ne', spanishPhonetic: 'è-sta-SION', category: 'Ville', imageQuery: 'train station', exampleIT: 'La stazione è affollata.', exampleES: 'La estación está llena.' },
  
  // Corps (12 mots)
  { french: 'Tête', italian: 'Testa', spanish: 'Cabeza', italianPhonetic: 'TÈ-sta', spanishPhonetic: 'ka-BÈ-sa', category: 'Corps', imageQuery: 'head', exampleIT: 'La testa è rotonda.', exampleES: 'La cabeza es redonda.' },
  { french: 'Œil', italian: 'Occhio', spanish: 'Ojo', italianPhonetic: 'OK-kio', spanishPhonetic: 'O-ho', category: 'Corps', imageQuery: 'eye', exampleIT: "L'occhio è blu.", exampleES: 'El ojo es azul.' },
  { french: 'Nez', italian: 'Naso', spanish: 'Nariz', italianPhonetic: 'NA-so', spanishPhonetic: 'na-RIS', category: 'Corps', imageQuery: 'nose', exampleIT: 'Il naso è grande.', exampleES: 'La nariz es grande.' },
  { french: 'Bouche', italian: 'Bocca', spanish: 'Boca', italianPhonetic: 'BOK-ka', spanishPhonetic: 'BO-ka', category: 'Corps', imageQuery: 'mouth', exampleIT: 'La bocca sorride.', exampleES: 'La boca sonríe.' },
  { french: 'Oreille', italian: 'Orecchio', spanish: 'Oreja', italianPhonetic: 'o-RÈK-kio', spanishPhonetic: 'o-RÈ-ha', category: 'Corps', imageQuery: 'ear', exampleIT: "L'orecchio sente.", exampleES: 'La oreja escucha.' },
  { french: 'Main', italian: 'Mano', spanish: 'Mano', italianPhonetic: 'MA-no', spanishPhonetic: 'MA-no', category: 'Corps', imageQuery: 'hand', exampleIT: 'La mano è aperta.', exampleES: 'La mano está abierta.' },
  { french: 'Pied', italian: 'Piede', spanish: 'Pie', italianPhonetic: 'PIÈ-de', spanishPhonetic: 'PIÈ', category: 'Corps', imageQuery: 'foot', exampleIT: 'Il piede cammina.', exampleES: 'El pie camina.' },
  { french: 'Bras', italian: 'Braccio', spanish: 'Brazo', italianPhonetic: 'BRAT-tcho', spanishPhonetic: 'BRA-so', category: 'Corps', imageQuery: 'arm', exampleIT: 'Il braccio è lungo.', exampleES: 'El brazo es largo.' },
  { french: 'Jambe', italian: 'Gamba', spanish: 'Pierna', italianPhonetic: 'GAM-ba', spanishPhonetic: 'PIÉR-na', category: 'Corps', imageQuery: 'leg', exampleIT: 'La gamba è forte.', exampleES: 'La pierna es fuerte.' },
  { french: 'Cœur', italian: 'Cuore', spanish: 'Corazón', italianPhonetic: 'KOU-o-re', spanishPhonetic: 'ko-ra-SON', category: 'Corps', imageQuery: 'heart', exampleIT: 'Il cuore batte.', exampleES: 'El corazón late.' },
  { french: 'Cheveux', italian: 'Capelli', spanish: 'Pelo', italianPhonetic: 'ka-PÈL-li', spanishPhonetic: 'PÈ-lo', category: 'Corps', imageQuery: 'hair', exampleIT: 'I capelli sono lunghi.', exampleES: 'El pelo es largo.' },
  { french: 'Dent', italian: 'Dente', spanish: 'Diente', italianPhonetic: 'DÈN-te', spanishPhonetic: 'DIÈN-tè', category: 'Corps', imageQuery: 'tooth', exampleIT: 'Il dente è bianco.', exampleES: 'El diente es blanco.' },
  
  // Vêtements (12 mots)
  { french: 'Chemise', italian: 'Camicia', spanish: 'Camisa', italianPhonetic: 'ka-MI-tcha', spanishPhonetic: 'ka-MI-sa', category: 'Vêtements', imageQuery: 'shirt', exampleIT: 'La camicia è bianca.', exampleES: 'La camisa es blanca.' },
  { french: 'Pantalon', italian: 'Pantaloni', spanish: 'Pantalón', italianPhonetic: 'pan-ta-LO-ni', spanishPhonetic: 'pan-ta-LON', category: 'Vêtements', imageQuery: 'pants', exampleIT: 'I pantaloni sono blu.', exampleES: 'El pantalón es azul.' },
  { french: 'Robe', italian: 'Vestito', spanish: 'Vestido', italianPhonetic: 'vè-STI-to', spanishPhonetic: 'bè-STI-do', category: 'Vêtements', imageQuery: 'dress', exampleIT: 'Il vestito è rosso.', exampleES: 'El vestido es rojo.' },
  { french: 'Chaussures', italian: 'Scarpe', spanish: 'Zapatos', italianPhonetic: 'SKAR-pe', spanishPhonetic: 'sa-PA-tos', category: 'Vêtements', imageQuery: 'shoes', exampleIT: 'Le scarpe sono nuove.', exampleES: 'Los zapatos son nuevos.' },
  { french: 'Chapeau', italian: 'Cappello', spanish: 'Sombrero', italianPhonetic: 'kap-PÈL-lo', spanishPhonetic: 'som-BRÈ-ro', category: 'Vêtements', imageQuery: 'hat', exampleIT: 'Il cappello è nero.', exampleES: 'El sombrero es negro.' },
  { french: 'Manteau', italian: 'Cappotto', spanish: 'Abrigo', italianPhonetic: 'kap-POT-to', spanishPhonetic: 'a-BRI-go', category: 'Vêtements', imageQuery: 'coat', exampleIT: 'Il cappotto è caldo.', exampleES: 'El abrigo es cálido.' },
  { french: 'Écharpe', italian: 'Sciarpa', spanish: 'Bufanda', italianPhonetic: 'CHAR-pa', spanishPhonetic: 'bou-FAN-da', category: 'Vêtements', imageQuery: 'scarf', exampleIT: 'La sciarpa è lunga.', exampleES: 'La bufanda es larga.' },
  { french: 'Gants', italian: 'Guanti', spanish: 'Guantes', italianPhonetic: 'GOUAN-ti', spanishPhonetic: 'GOUAN-tès', category: 'Vêtements', imageQuery: 'gloves', exampleIT: 'I guanti sono caldi.', exampleES: 'Los guantes son cálidos.' },
  { french: 'Lunettes', italian: 'Occhiali', spanish: 'Gafas', italianPhonetic: 'ok-KIA-li', spanishPhonetic: 'GA-fas', category: 'Vêtements', imageQuery: 'glasses', exampleIT: 'Gli occhiali sono nuovi.', exampleES: 'Las gafas son nuevas.' },
  { french: 'Ceinture', italian: 'Cintura', spanish: 'Cinturón', italianPhonetic: 'tchin-TOU-ra', spanishPhonetic: 'sin-tou-RON', category: 'Vêtements', imageQuery: 'belt', exampleIT: 'La cintura è di cuoio.', exampleES: 'El cinturón es de cuero.' },
  { french: 'Chaussettes', italian: 'Calzini', spanish: 'Calcetines', italianPhonetic: 'kal-TSI-ni', spanishPhonetic: 'kal-sè-TI-nès', category: 'Vêtements', imageQuery: 'socks', exampleIT: 'I calzini sono bianchi.', exampleES: 'Los calcetines son blancos.' },
  { french: 'Jupe', italian: 'Gonna', spanish: 'Falda', italianPhonetic: 'GON-na', spanishPhonetic: 'FAL-da', category: 'Vêtements', imageQuery: 'skirt', exampleIT: 'La gonna è corta.', exampleES: 'La falda es corta.' },
  
  // Couleurs (10 mots)
  { french: 'Rouge', italian: 'Rosso', spanish: 'Rojo', italianPhonetic: 'ROS-so', spanishPhonetic: 'RO-ho', category: 'Couleurs', imageQuery: 'red color', exampleIT: 'Il rosso è bello.', exampleES: 'El rojo es bonito.' },
  { french: 'Bleu', italian: 'Blu', spanish: 'Azul', italianPhonetic: 'BLOU', spanishPhonetic: 'a-SOUL', category: 'Couleurs', imageQuery: 'blue color', exampleIT: 'Il blu è calmo.', exampleES: 'El azul es tranquilo.' },
  { french: 'Vert', italian: 'Verde', spanish: 'Verde', italianPhonetic: 'VÈR-de', spanishPhonetic: 'BÈR-dè', category: 'Couleurs', imageQuery: 'green color', exampleIT: 'Il verde è fresco.', exampleES: 'El verde es fresco.' },
  { french: 'Jaune', italian: 'Giallo', spanish: 'Amarillo', italianPhonetic: 'DJAL-lo', spanishPhonetic: 'a-ma-RI-yo', category: 'Couleurs', imageQuery: 'yellow color', exampleIT: 'Il giallo è luminoso.', exampleES: 'El amarillo es brillante.' },
  { french: 'Noir', italian: 'Nero', spanish: 'Negro', italianPhonetic: 'NÈ-ro', spanishPhonetic: 'NÈ-gro', category: 'Couleurs', imageQuery: 'black color', exampleIT: 'Il nero è scuro.', exampleES: 'El negro es oscuro.' },
  { french: 'Blanc', italian: 'Bianco', spanish: 'Blanco', italianPhonetic: 'BIAN-ko', spanishPhonetic: 'BLAN-ko', category: 'Couleurs', imageQuery: 'white color', exampleIT: 'Il bianco è puro.', exampleES: 'El blanco es puro.' },
  { french: 'Orange', italian: 'Arancione', spanish: 'Naranja', italianPhonetic: 'a-ran-TCHO-ne', spanishPhonetic: 'na-RAN-ha', category: 'Couleurs', imageQuery: 'orange color', exampleIT: "L'arancione è caldo.", exampleES: 'El naranja es cálido.' },
  { french: 'Violet', italian: 'Viola', spanish: 'Morado', italianPhonetic: 'VI-o-la', spanishPhonetic: 'mo-RA-do', category: 'Couleurs', imageQuery: 'purple color', exampleIT: 'Il viola è elegante.', exampleES: 'El morado es elegante.' },
  { french: 'Rose', italian: 'Rosa', spanish: 'Rosa', italianPhonetic: 'RO-sa', spanishPhonetic: 'RO-sa', category: 'Couleurs', imageQuery: 'pink color', exampleIT: 'Il rosa è dolce.', exampleES: 'El rosa es dulce.' },
  { french: 'Gris', italian: 'Grigio', spanish: 'Gris', italianPhonetic: 'GRI-djo', spanishPhonetic: 'GRIS', category: 'Couleurs', imageQuery: 'gray color', exampleIT: 'Il grigio è neutro.', exampleES: 'El gris es neutro.' }
]

const selectedLanguage = ref<'italian' | 'spanish' | 'both'>('both')
const selectedCategory = ref<string>('Tous')
const mode = ref<'learn' | 'quiz'>('learn')
const vocabCards = ref<VocabCard[]>([])
const loading = ref(false)
const error = ref('')
const selectedCard = ref<VocabCard | null>(null)
const quizScore = ref(0)
const quizTotal = ref(0)
const showAnswer = ref(false)

const categories = computed(() => {
  const cats = ['Tous', ...new Set(vocabulary.map(v => v.category))]
  return cats
})

const filteredVocabulary = computed(() => {
  if (selectedCategory.value === 'Tous') {
    return vocabulary
  }
  return vocabulary.filter(v => v.category === selectedCategory.value)
})

const fetchPhotoForWord = async (word: VocabWord): Promise<Photo | null> => {
  try {
    const response = await fetch(
      `https://api.pexels.com/v1/search?query=${encodeURIComponent(word.imageQuery)}&per_page=1`,
      {
        headers: {
          Authorization: PEXELS_API_KEY
        }
      }
    )
    
    if (!response.ok) return null
    
    const data = await response.json()
    return data.photos?.[0] || null
  } catch (err) {
    console.error(err)
    return null
  }
}

const loadVocabularyCards = async () => {
  loading.value = true
  error.value = ''
  
  try {
    const words = filteredVocabulary.value.slice(0, 18)
    const cards: VocabCard[] = []
    
    for (const word of words) {
      const photo = await fetchPhotoForWord(word)
      cards.push({ word, photo })
    }
    
    vocabCards.value = cards
    if (mode.value === 'quiz') {
      shuffleCards()
    }
  } catch (err) {
    error.value = 'Erreur lors du chargement des images.'
    console.error(err)
  } finally {
    loading.value = false
  }
}

const shuffleCards = () => {
  vocabCards.value = vocabCards.value.sort(() => Math.random() - 0.5)
}

const openCard = (card: VocabCard) => {
  selectedCard.value = card
  showAnswer.value = mode.value === 'learn'
}

const closeCard = () => {
  selectedCard.value = null
  showAnswer.value = false
}

const revealAnswer = () => {
  showAnswer.value = true
}

const markCorrect = () => {
  quizScore.value++
  quizTotal.value++
  closeCard()
}

const markIncorrect = () => {
  quizTotal.value++
  closeCard()
}

const changeMode = (newMode: 'learn' | 'quiz') => {
  mode.value = newMode
  if (newMode === 'quiz') {
    quizScore.value = 0
    quizTotal.value = 0
    shuffleCards()
  }
}

const changeCategory = (category: string) => {
  selectedCategory.value = category
  loadVocabularyCards()
}

const changeLanguage = (lang: 'italian' | 'spanish' | 'both') => {
  selectedLanguage.value = lang
}

const speakText = (text: string, lang: 'it-IT' | 'es-ES') => {
  if ('speechSynthesis' in window) {
    window.speechSynthesis.cancel()
    const utterance = new SpeechSynthesisUtterance(text)
    utterance.lang = lang
    utterance.rate = 0.85
    utterance.pitch = 1
    window.speechSynthesis.speak(utterance)
  }
}

const speakWord = (word: VocabWord, lang: 'italian' | 'spanish') => {
  const text = lang === 'italian' ? word.italian : word.spanish
  const langCode = lang === 'italian' ? 'it-IT' : 'es-ES'
  speakText(text, langCode)
}

const speakExample = (word: VocabWord, lang: 'italian' | 'spanish') => {
  const text = lang === 'italian' ? word.exampleIT : word.exampleES
  const langCode = lang === 'italian' ? 'it-IT' : 'es-ES'
  speakText(text, langCode)
}

onMounted(() => {
  loadVocabularyCards()
})
</script>

<template>
  <div class="images-container">
    <div class="images-header">
      <h1>🖼️ Apprendre avec des Images</h1>
      <p class="subtitle">Vocabulaire Italien & Espagnol en images</p>
    </div>

    <!-- Controls -->
    <div class="controls-section">
      <!-- Mode Selection -->
      <div class="mode-selector">
        <button
          @click="changeMode('learn')"
          class="mode-btn"
          :class="{ active: mode === 'learn' }"
        >
          📚 Apprendre
        </button>
        <button
          @click="changeMode('quiz')"
          class="mode-btn"
          :class="{ active: mode === 'quiz' }"
        >
          🎯 Quiz
        </button>
      </div>

      <!-- Language Selection -->
      <div class="language-selector">
        <button
          @click="changeLanguage('both')"
          class="lang-btn"
          :class="{ active: selectedLanguage === 'both' }"
        >
          🇮🇹 + 🇪🇸 Les deux
        </button>
        <button
          @click="changeLanguage('italian')"
          class="lang-btn"
          :class="{ active: selectedLanguage === 'italian' }"
        >
          🇮🇹 Italien
        </button>
        <button
          @click="changeLanguage('spanish')"
          class="lang-btn"
          :class="{ active: selectedLanguage === 'spanish' }"
        >
          🇪🇸 Espagnol
        </button>
      </div>

      <!-- Category Selection -->
      <div class="category-selector">
        <button
          v-for="category in categories"
          :key="category"
          @click="changeCategory(category)"
          class="category-btn"
          :class="{ active: selectedCategory === category }"
        >
          {{ category }}
        </button>
      </div>

      <!-- Quiz Score -->
      <div v-if="mode === 'quiz' && quizTotal > 0" class="quiz-score">
        Score: {{ quizScore }} / {{ quizTotal }} ({{ Math.round((quizScore / quizTotal) * 100) }}%)
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="error" class="error-message">
      {{ error }}
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
      <p>Chargement du vocabulaire...</p>
    </div>

    <!-- Vocabulary Cards Grid -->
    <div v-else-if="vocabCards.length > 0" class="vocab-grid">
      <div
        v-for="card in vocabCards"
        :key="card.word.french"
        class="vocab-card"
        @click="openCard(card)"
      >
        <div class="vocab-image-wrapper">
          <img
            v-if="card.photo"
            :src="card.photo.src.medium"
            :alt="card.word.french"
            loading="lazy"
            class="vocab-img"
          />
          <div v-else class="vocab-placeholder">
            <span class="placeholder-icon">🖼️</span>
          </div>
          <div class="vocab-overlay">
            <span v-if="selectedLanguage === 'italian' || selectedLanguage === 'both'" class="translated-word">
              🇮🇹 {{ card.word.italian }}
            </span>
            <span v-if="selectedLanguage === 'spanish' || selectedLanguage === 'both'" class="translated-word">
              🇪🇸 {{ card.word.spanish }}
            </span>
          </div>
        </div>
        <div class="vocab-text">
          <p class="french-word">{{ card.word.french }}</p>
          <span class="category-tag">{{ card.word.category }}</span>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else-if="!loading" class="empty-state">
      <p>Aucun mot disponible dans cette catégorie.</p>
    </div>

    <!-- Vocabulary Modal -->
    <div v-if="selectedCard" class="modal-overlay" @click="closeCard">
      <div class="modal-content vocab-modal" @click.stop>
        <button class="modal-close" @click="closeCard">✕</button>
        
        <div class="modal-image-section">
          <img
            v-if="selectedCard.photo"
            :src="selectedCard.photo.src.large2x"
            :alt="selectedCard.word.french"
            class="modal-img"
          />
          <div v-else class="modal-placeholder">
            <span class="placeholder-icon">🖼️</span>
          </div>
        </div>

        <div class="modal-vocab-section">
          <h2 class="modal-french">{{ selectedCard.word.french }}</h2>
          
          <div v-if="showAnswer" class="translations">
            <div v-if="selectedLanguage === 'italian' || selectedLanguage === 'both'" class="translation-block">
              <div class="translation">
                <span class="flag">🇮🇹</span>
                <div class="translation-content">
                  <div class="word-row">
                    <span class="word">{{ selectedCard.word.italian }}</span>
                    <button @click.stop="speakWord(selectedCard.word, 'italian')" class="audio-btn" title="Écouter">
                      🔊
                    </button>
                  </div>
                  <span class="phonetic">{{ selectedCard.word.italianPhonetic }}</span>
                </div>
              </div>
              <div class="example">
                <div class="example-header">
                  <span class="example-label">Exemple :</span>
                  <button @click.stop="speakExample(selectedCard.word, 'italian')" class="audio-btn-small" title="Écouter la phrase">
                    🔊
                  </button>
                </div>
                <span class="example-text">{{ selectedCard.word.exampleIT }}</span>
                <span class="example-translation">({{ selectedCard.word.french }} dort.)</span>
              </div>
            </div>
            <div v-if="selectedLanguage === 'spanish' || selectedLanguage === 'both'" class="translation-block">
              <div class="translation">
                <span class="flag">🇪🇸</span>
                <div class="translation-content">
                  <div class="word-row">
                    <span class="word">{{ selectedCard.word.spanish }}</span>
                    <button @click.stop="speakWord(selectedCard.word, 'spanish')" class="audio-btn" title="Écouter">
                      🔊
                    </button>
                  </div>
                  <span class="phonetic">{{ selectedCard.word.spanishPhonetic }}</span>
                </div>
              </div>
              <div class="example">
                <div class="example-header">
                  <span class="example-label">Exemple :</span>
                  <button @click.stop="speakExample(selectedCard.word, 'spanish')" class="audio-btn-small" title="Écouter la phrase">
                    🔊
                  </button>
                </div>
                <span class="example-text">{{ selectedCard.word.exampleES }}</span>
                <span class="example-translation">({{ selectedCard.word.french }} dort.)</span>
              </div>
            </div>
          </div>

          <div v-if="mode === 'quiz' && !showAnswer" class="quiz-actions">
            <button @click="revealAnswer" class="reveal-btn">
              👁️ Révéler la réponse
            </button>
          </div>

          <div v-if="mode === 'quiz' && showAnswer" class="quiz-feedback">
            <p class="quiz-question">Connaissiez-vous la traduction ?</p>
            <div class="quiz-buttons">
              <button @click="markCorrect" class="correct-btn">
                ✅ Oui
              </button>
              <button @click="markIncorrect" class="incorrect-btn">
                ❌ Non
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.images-container {
  min-height: calc(100vh - 56px);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1.5rem;
}

.images-header {
  text-align: center;
  color: white;
  margin-bottom: 1.75rem;
}

.images-header h1 {
  font-size: 1.75rem;
  margin-bottom: 0.4rem;
  font-weight: 600;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.subtitle {
  font-size: 0.95rem;
  opacity: 0.9;
}

/* Controls Section */
.controls-section {
  max-width: 1200px;
  margin: 0 auto 2rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.mode-selector {
  display: flex;
  gap: 0.75rem;
  justify-content: center;
}

.mode-btn {
  padding: 0.65rem 1.5rem;
  background: rgba(255, 255, 255, 0.15);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.mode-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: translateY(-2px);
}

.mode-btn.active {
  background: white;
  color: #667eea;
  border-color: white;
}

.language-selector {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
  flex-wrap: wrap;
}

.lang-btn {
  padding: 0.5rem 1rem;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.lang-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.lang-btn.active {
  background: rgba(255, 255, 255, 0.25);
  border-color: rgba(255, 255, 255, 0.5);
  font-weight: 600;
}

.category-selector {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
  flex-wrap: wrap;
}

.category-btn {
  padding: 0.45rem 0.9rem;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.category-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-1px);
}

.category-btn.active {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  border-color: transparent;
  font-weight: 600;
}

.quiz-score {
  text-align: center;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border-radius: 8px;
  font-size: 0.95rem;
  font-weight: 600;
}

/* Error & Loading */
.error-message {
  max-width: 600px;
  margin: 2rem auto;
  padding: 1rem 1.5rem;
  background: rgba(231, 76, 60, 0.2);
  border: 1px solid rgba(231, 76, 60, 0.5);
  border-radius: 8px;
  color: white;
  text-align: center;
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 3rem;
  color: white;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Vocabulary Grid */
.vocab-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
  max-width: 1400px;
  margin: 0 auto;
}

.vocab-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.vocab-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
}

.vocab-image-wrapper {
  width: 100%;
  aspect-ratio: 4/3;
  overflow: hidden;
  background: #f0f0f0;
  position: relative;
}

.vocab-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

.vocab-card:hover .vocab-img {
  transform: scale(1.1);
}

.vocab-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 0.75rem 0.5rem;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.85), transparent);
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  opacity: 0;
  transition: opacity 0.3s;
}

.vocab-card:hover .vocab-overlay {
  opacity: 1;
}

.translated-word {
  color: white;
  font-size: 0.85rem;
  font-weight: 600;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5);
}

.vocab-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #e0e0e0 0%, #f5f5f5 100%);
}

.placeholder-icon {
  font-size: 3rem;
  opacity: 0.3;
}

.vocab-text {
  padding: 0.85rem 1rem;
}

.french-word {
  margin: 0 0 0.4rem 0;
  font-size: 1rem;
  font-weight: 600;
  color: #1a202c;
}

.category-tag {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  background: #e8f5e9;
  color: #2e7d32;
  border-radius: 12px;
  font-size: 0.7rem;
  font-weight: 500;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: white;
  font-size: 1.1rem;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 2rem;
  backdrop-filter: blur(4px);
}

.vocab-modal {
  position: relative;
  max-width: 900px;
  width: 100%;
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  max-height: 90vh;
}

.modal-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  width: 40px;
  height: 40px;
  background: rgba(0, 0, 0, 0.6);
  color: white;
  border: none;
  border-radius: 50%;
  font-size: 1.5rem;
  cursor: pointer;
  transition: all 0.2s;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close:hover {
  background: rgba(0, 0, 0, 0.8);
  transform: rotate(90deg);
}

.modal-image-section {
  width: 100%;
  max-height: 50vh;
  background: #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-img {
  width: 100%;
  max-height: 50vh;
  object-fit: contain;
  display: block;
}

.modal-placeholder {
  width: 100%;
  height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #e0e0e0 0%, #f5f5f5 100%);
}

.modal-placeholder .placeholder-icon {
  font-size: 5rem;
}

.modal-vocab-section {
  padding: 2rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.modal-french {
  margin: 0;
  font-size: 2rem;
  color: #1a202c;
  text-align: center;
  font-weight: 700;
}

.translations {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.translation-block {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.translation {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: #f8f9fa;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.translation .flag {
  font-size: 2rem;
  flex-shrink: 0;
}

.translation-content {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  flex: 1;
}

.word-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.translation .word {
  font-size: 1.5rem;
  font-weight: 600;
  color: #2c3e50;
}

.phonetic {
  font-size: 0.95rem;
  color: #667eea;
  font-weight: 500;
  font-style: italic;
}

.example {
  padding: 0.75rem 1rem;
  background: #e8f4f8;
  border-radius: 8px;
  border-left: 3px solid #3498db;
  margin-left: 3rem;
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.example-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.example-label {
  font-size: 0.8rem;
  font-weight: 600;
  color: #2c3e50;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-right: 0.5rem;
}

.example-text {
  font-size: 1rem;
  color: #34495e;
  font-style: italic;
}

.example-translation {
  font-size: 0.85rem;
  color: #7f8c8d;
  margin-top: 0.25rem;
}

.audio-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  padding: 0.5rem 0.75rem;
  border-radius: 8px;
  font-size: 1.1rem;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.audio-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.audio-btn:active {
  transform: translateY(0);
}

.audio-btn-small {
  background: rgba(52, 152, 219, 0.15);
  border: 1px solid rgba(52, 152, 219, 0.3);
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.2s;
}

.audio-btn-small:hover {
  background: rgba(52, 152, 219, 0.25);
  transform: translateY(-1px);
}

.quiz-actions {
  text-align: center;
}

.reveal-btn {
  padding: 0.85rem 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.reveal-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.quiz-feedback {
  text-align: center;
}

.quiz-question {
  margin: 0 0 1rem 0;
  font-size: 1.1rem;
  color: #555;
}

.quiz-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
}

.correct-btn,
.incorrect-btn {
  padding: 0.75rem 1.75rem;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.correct-btn {
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  color: white;
}

.correct-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.3);
}

.incorrect-btn {
  background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
  color: white;
}

.incorrect-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
}

/* Responsive */
@media (max-width: 768px) {
  .images-container {
    padding: 1rem;
  }

  .images-header h1 {
    font-size: 1.35rem;
  }

  .mode-selector {
    flex-direction: column;
  }

  .mode-btn {
    width: 100%;
  }

  .vocab-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 0.75rem;
  }

  .modal-overlay {
    padding: 1rem;
  }

  .vocab-modal {
    max-height: 95vh;
  }

  .modal-vocab-section {
    padding: 1.5rem 1rem;
  }

  .modal-french {
    font-size: 1.5rem;
  }

  .translation .word {
    font-size: 1.2rem;
  }
  
  .example {
    margin-left: 0;
  }

  .quiz-buttons {
    flex-direction: column;
  }

  .correct-btn,
  .incorrect-btn {
    width: 100%;
  }
}

@media (max-width: 576px) {
  .vocab-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .category-selector {
    gap: 0.4rem;
  }

  .category-btn {
    font-size: 0.75rem;
    padding: 0.4rem 0.75rem;
  }
  
  .translated-word {
    font-size: 0.75rem;
  }
  
  .word-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}
</style>
