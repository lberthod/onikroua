import Foundation

public class VerbData {
    public static func getVerbsByLanguage(_ language: String) -> [Verb] {
        return language == "it" ? getItalianVerbs() : getSpanishVerbs()
    }
    
    // MARK: - Italian Verbs (21 verbs)
    private static func getItalianVerbs() -> [Verb] {
        return [
            // Auxiliaires
            Verb(
                id: "it-essere",
                verb: "essere --",
                translation: "être",
                conjugations: [
                    "Présent": ["io": "sono", "tu": "sei", "lui/lei": "è", "noi": "siamo", "voi": "siete", "loro": "sono"],
                    "Imparfait": ["io": "ero", "tu": "eri", "lui/lei": "era", "noi": "eravamo", "voi": "eravate", "loro": "erano"],
                    "Futur": ["io": "sarò", "tu": "sarai", "lui/lei": "sarà", "noi": "saremo", "voi": "sarete", "loro": "saranno"]
                ],
                group: "Auxiliaire",
                isIrregular: true
            ),
            Verb(
                id: "it-avere",
                verb: "avere",
                translation: "avoir",
                conjugations: [
                    "Présent": ["io": "ho", "tu": "hai", "lui/lei": "ha", "noi": "abbiamo", "voi": "avete", "loro": "hanno"],
                    "Imparfait": ["io": "avevo", "tu": "avevi", "lui/lei": "aveva", "noi": "avevamo", "voi": "avevate", "loro": "avevano"],
                    "Futur": ["io": "avrò", "tu": "avrai", "lui/lei": "avrà", "noi": "avremo", "voi": "avrete", "loro": "avranno"]
                ],
                group: "Auxiliaire",
                isIrregular: true
            ),
            
            // Verbes de mouvement
            Verb(
                id: "it-andare",
                verb: "andare",
                translation: "aller",
                conjugations: [
                    "Présent": ["io": "vado", "tu": "vai", "lui/lei": "va", "noi": "andiamo", "voi": "andate", "loro": "vanno"],
                    "Passato prossimo": ["io": "sono andato", "tu": "sei andato", "lui/lei": "è andato", "noi": "siamo andati", "voi": "siete andati", "loro": "sono andati"],
                    "Futur": ["io": "andrò", "tu": "andrai", "lui/lei": "andrà", "noi": "andremo", "voi": "andrete", "loro": "andranno"]
                ],
                group: "Mouvement",
                isIrregular: true
            ),
            Verb(
                id: "it-venire",
                verb: "venire",
                translation: "venir",
                conjugations: [
                    "Présent": ["io": "vengo", "tu": "vieni", "lui/lei": "viene", "noi": "veniamo", "voi": "venite", "loro": "vengono"],
                    "Passato prossimo": ["io": "sono venuto", "tu": "sei venuto", "lui/lei": "è venuto", "noi": "siamo venuti", "voi": "siete venuti", "loro": "sono venuti"]
                ],
                group: "Mouvement",
                isIrregular: true
            ),
            Verb(
                id: "it-partire",
                verb: "partire",
                translation: "partir",
                conjugations: [
                    "Présent": ["io": "parto", "tu": "parti", "lui/lei": "parte", "noi": "partiamo", "voi": "partite", "loro": "partono"],
                    "Passato prossimo": ["io": "sono partito", "tu": "sei partito", "lui/lei": "è partito", "noi": "siamo partiti", "voi": "siete partiti", "loro": "sono partiti"]
                ],
                group: "Mouvement",
                isIrregular: false
            ),
            Verb(
                id: "it-uscire",
                verb: "uscire",
                translation: "sortir",
                conjugations: [
                    "Présent": ["io": "esco", "tu": "esci", "lui/lei": "esce", "noi": "usciamo", "voi": "uscite", "loro": "escono"],
                    "Passato prossimo": ["io": "sono uscito", "tu": "sei uscito", "lui/lei": "è uscito", "noi": "siamo usciti", "voi": "siete usciti", "loro": "sono usciti"]
                ],
                group: "Mouvement",
                isIrregular: true
            ),
            
            // Verbes modaux
            Verb(
                id: "it-potere",
                verb: "potere",
                translation: "pouvoir",
                conjugations: [
                    "Présent": ["io": "posso", "tu": "puoi", "lui/lei": "può", "noi": "possiamo", "voi": "potete", "loro": "possono"]
                ],
                group: "Modal",
                isIrregular: true
            ),
            Verb(
                id: "it-volere",
                verb: "volere",
                translation: "vouloir",
                conjugations: [
                    "Présent": ["io": "voglio", "tu": "vuoi", "lui/lei": "vuole", "noi": "vogliamo", "voi": "volete", "loro": "vogliono"]
                ],
                group: "Modal",
                isIrregular: true
            ),
            Verb(
                id: "it-dovere",
                verb: "dovere",
                translation: "devoir",
                conjugations: [
                    "Présent": ["io": "devo", "tu": "devi", "lui/lei": "deve", "noi": "dobbiamo", "voi": "dovete", "loro": "devono"]
                ],
                group: "Modal",
                isIrregular: true
            ),
            
            // Autres verbes courants
            Verb(
                id: "it-fare",
                verb: "fare",
                translation: "faire",
                conjugations: [
                    "Présent": ["io": "faccio", "tu": "fai", "lui/lei": "fa", "noi": "facciamo", "voi": "fate", "loro": "fanno"],
                    "Passato prossimo": ["io": "ho fatto", "tu": "hai fatto", "lui/lei": "ha fatto", "noi": "abbiamo fatto", "voi": "avete fatto", "loro": "hanno fatto"]
                ],
                group: "-ARE",
                isIrregular: true
            ),
            Verb(
                id: "it-dire",
                verb: "dire",
                translation: "dire",
                conjugations: [
                    "Présent": ["io": "dico", "tu": "dici", "lui/lei": "dice", "noi": "diciamo", "voi": "dite", "loro": "dicono"],
                    "Passato prossimo": ["io": "ho detto", "tu": "hai detto", "lui/lei": "ha detto", "noi": "abbiamo detto", "voi": "avete detto", "loro": "hanno detto"]
                ],
                group: "-IRE",
                isIrregular: true
            ),
            Verb(
                id: "it-stare",
                verb: "stare",
                translation: "rester / être",
                conjugations: [
                    "Présent": ["io": "sto", "tu": "stai", "lui/lei": "sta", "noi": "stiamo", "voi": "state", "loro": "stanno"],
                    "Passato prossimo": ["io": "sono stato", "tu": "sei stato", "lui/lei": "è stato", "noi": "siamo stati", "voi": "siete stati", "loro": "sono stati"]
                ],
                group: "-ARE",
                isIrregular: true
            ),
            Verb(
                id: "it-dare",
                verb: "dare",
                translation: "donner",
                conjugations: [
                    "Présent": ["io": "do", "tu": "dai", "lui/lei": "dà", "noi": "diamo", "voi": "date", "loro": "danno"],
                    "Passato prossimo": ["io": "ho dato", "tu": "hai dato", "lui/lei": "ha dato", "noi": "abbiamo dato", "voi": "avete dato", "loro": "hanno dato"]
                ],
                group: "-ARE",
                isIrregular: true
            ),
            Verb(
                id: "it-sapere",
                verb: "sapere",
                translation: "savoir",
                conjugations: [
                    "Présent": ["io": "so", "tu": "sai", "lui/lei": "sa", "noi": "sappiamo", "voi": "sapete", "loro": "sanno"],
                    "Passato prossimo": ["io": "ho saputo", "tu": "hai saputo", "lui/lei": "ha saputo", "noi": "abbiamo saputo", "voi": "avete saputo", "loro": "hanno saputo"]
                ],
                group: "-ERE",
                isIrregular: true
            ),
            Verb(
                id: "it-conoscere",
                verb: "conoscere",
                translation: "connaître",
                conjugations: [
                    "Présent": ["io": "conosco", "tu": "conosci", "lui/lei": "conosce", "noi": "conosciamo", "voi": "conoscete", "loro": "conoscono"],
                    "Passato prossimo": ["io": "ho conosciuto", "tu": "hai conosciuto", "lui/lei": "ha conosciuto", "noi": "abbiamo conosciuto", "voi": "avete conosciuto", "loro": "hanno conosciuto"]
                ],
                group: "-ERE",
                isIrregular: false
            ),
            
            // Verbes réguliers -ARE
            Verb(
                id: "it-parlare",
                verb: "parlare",
                translation: "parler",
                conjugations: [
                    "Présent": ["io": "parlo", "tu": "parli", "lui/lei": "parla", "noi": "parliamo", "voi": "parlate", "loro": "parlano"],
                    "Passato prossimo": ["io": "ho parlato", "tu": "hai parlato", "lui/lei": "ha parlato", "noi": "abbiamo parlato", "voi": "avete parlato", "loro": "hanno parlato"]
                ],
                group: "-ARE",
                isIrregular: false
            ),
            Verb(
                id: "it-mangiare",
                verb: "mangiare",
                translation: "manger",
                conjugations: [
                    "Présent": ["io": "mangio", "tu": "mangi", "lui/lei": "mangia", "noi": "mangiamo", "voi": "mangiate", "loro": "mangiano"],
                    "Passato prossimo": ["io": "ho mangiato", "tu": "hai mangiato", "lui/lei": "ha mangiato", "noi": "abbiamo mangiato", "voi": "avete mangiato", "loro": "hanno mangiato"]
                ],
                group: "-ARE",
                isIrregular: false
            ),
            
            // Verbes réguliers -ERE
            Verb(
                id: "it-vedere",
                verb: "vedere",
                translation: "voir",
                conjugations: [
                    "Présent": ["io": "vedo", "tu": "vedi", "lui/lei": "vede", "noi": "vediamo", "voi": "vedete", "loro": "vedono"],
                    "Passato prossimo": ["io": "ho visto", "tu": "hai visto", "lui/lei": "ha visto", "noi": "abbiamo visto", "voi": "avete visto", "loro": "hanno visto"]
                ],
                group: "-ERE",
                isIrregular: false
            ),
            Verb(
                id: "it-leggere",
                verb: "leggere",
                translation: "lire",
                conjugations: [
                    "Présent": ["io": "leggo", "tu": "leggi", "lui/lei": "legge", "noi": "leggiamo", "voi": "leggete", "loro": "leggono"],
                    "Passato prossimo": ["io": "ho letto", "tu": "hai letto", "lui/lei": "ha letto", "noi": "abbiamo letto", "voi": "avete letto", "loro": "hanno letto"]
                ],
                group: "-ERE",
                isIrregular: false
            ),
            Verb(
                id: "it-scrivere",
                verb: "scrivere",
                translation: "écrire",
                conjugations: [
                    "Présent": ["io": "scrivo", "tu": "scrivi", "lui/lei": "scrive", "noi": "scriviamo", "voi": "scrivete", "loro": "scrivono"],
                    "Passato prossimo": ["io": "ho scritto", "tu": "hai scritto", "lui/lei": "ha scritto", "noi": "abbiamo scritto", "voi": "avete scritto", "loro": "hanno scritto"]
                ],
                group: "-ERE",
                isIrregular: false
            ),
            Verb(
                id: "it-prendere",
                verb: "prendere",
                translation: "prendre",
                conjugations: [
                    "Présent": ["io": "prendo", "tu": "prendi", "lui/lei": "prende", "noi": "prendiamo", "voi": "prendete", "loro": "prendono"],
                    "Passato prossimo": ["io": "ho preso", "tu": "hai preso", "lui/lei": "ha preso", "noi": "abbiamo preso", "voi": "avete preso", "loro": "hanno preso"]
                ],
                group: "-ERE",
                isIrregular: false
            ),
            Verb(
                id: "it-bere",
                verb: "bere",
                translation: "boire",
                conjugations: [
                    "Présent": ["io": "bevo", "tu": "bevi", "lui/lei": "beve", "noi": "beviamo", "voi": "bevete", "loro": "bevono"],
                    "Passato prossimo": ["io": "ho bevuto", "tu": "hai bevuto", "lui/lei": "ha bevuto", "noi": "abbiamo bevuto", "voi": "avete bevuto", "loro": "hanno bevuto"]
                ],
                group: "-ERE",
                isIrregular: true
            ),
            
            // Verbes réguliers -IRE
            Verb(
                id: "it-dormire",
                verb: "dormire",
                translation: "dormir",
                conjugations: [
                    "Présent": ["io": "dormo", "tu": "dormi", "lui/lei": "dorme", "noi": "dormiamo", "voi": "dormite", "loro": "dormono"],
                    "Passato prossimo": ["io": "ho dormito", "tu": "hai dormito", "lui/lei": "ha dormito", "noi": "abbiamo dormito", "voi": "avete dormito", "loro": "hanno dormito"]
                ],
                group: "-IRE",
                isIrregular: false
            ),
            Verb(
                id: "it-capire",
                verb: "capire",
                translation: "comprendre",
                conjugations: [
                    "Présent": ["io": "capisco", "tu": "capisci", "lui/lei": "capisce", "noi": "capiamo", "voi": "capite", "loro": "capiscono"],
                    "Passato prossimo": ["io": "ho capito", "tu": "hai capito", "lui/lei": "ha capito", "noi": "abbiamo capito", "voi": "avete capito", "loro": "hanno capito"]
                ],
                group: "-IRE",
                isIrregular: false
            ),
            Verb(
                id: "it-finire",
                verb: "finire",
                translation: "finir",
                conjugations: [
                    "Présent": ["io": "finisco", "tu": "finisci", "lui/lei": "finisce", "noi": "finiamo", "voi": "finite", "loro": "finiscono"],
                    "Passato prossimo": ["io": "ho finito", "tu": "hai finito", "lui/lei": "ha finito", "noi": "abbiamo finito", "voi": "avete finito", "loro": "hanno finito"]
                ],
                group: "-IRE",
                isIrregular: false
            )
        ]
    }
    
    // MARK: - Spanish Verbs (24 verbs)
    private static func getSpanishVerbs() -> [Verb] {
        return [
            // Auxiliaires / Verbes clés
            Verb(
                id: "es-ser",
                verb: "ser",
                translation: "être (permanent)",
                conjugations: [
                    "Presente": ["yo": "soy", "tú": "eres", "él/ella": "es", "nosotros": "somos", "vosotros": "sois", "ellos": "son"],
                    "Pretérito perfecto": ["yo": "he sido", "tú": "has sido", "él/ella": "ha sido", "nosotros": "hemos sido", "vosotros": "habéis sido", "ellos": "han sido"],
                    "Imparfait": ["yo": "era", "tú": "eras", "él/ella": "era", "nosotros": "éramos", "vosotros": "erais", "ellos": "eran"]
                ],
                group: "Verbe clé",
                isIrregular: true
            ),
            Verb(
                id: "es-estar",
                verb: "estar",
                translation: "être (temporaire)",
                conjugations: [
                    "Presente": ["yo": "estoy", "tú": "estás", "él/ella": "está", "nosotros": "estamos", "vosotros": "estáis", "ellos": "están"],
                    "Pretérito perfecto": ["yo": "he estado", "tú": "has estado", "él/ella": "ha estado", "nosotros": "hemos estado", "vosotros": "habéis estado", "ellos": "han estado"]
                ],
                group: "Verbe clé",
                isIrregular: true
            ),
            Verb(
                id: "es-haber",
                verb: "haber",
                translation: "avoir (auxiliaire)",
                conjugations: [
                    "Presente": ["yo": "he", "tú": "has", "él/ella": "ha", "nosotros": "hemos", "vosotros": "habéis", "ellos": "han"]
                ],
                group: "Verbe clé",
                isIrregular: true
            ),
            Verb(
                id: "es-tener",
                verb: "tener",
                translation: "avoir (posséder)",
                conjugations: [
                    "Presente": ["yo": "tengo", "tú": "tienes", "él/ella": "tiene", "nosotros": "tenemos", "vosotros": "tenéis", "ellos": "tienen"],
                    "Pretérito perfecto": ["yo": "he tenido", "tú": "has tenido", "él/ella": "ha tenido", "nosotros": "hemos tenido", "vosotros": "habéis tenido", "ellos": "han tenido"]
                ],
                group: "Modal",
                isIrregular: true
            ),
            
            // Verbes de mouvement
            Verb(
                id: "es-ir",
                verb: "ir",
                translation: "aller",
                conjugations: [
                    "Presente": ["yo": "voy", "tú": "vas", "él/ella": "va", "nosotros": "vamos", "vosotros": "vais", "ellos": "van"],
                    "Pretérito perfecto": ["yo": "he ido", "tú": "has ido", "él/ella": "ha ido", "nosotros": "hemos ido", "vosotros": "habéis ido", "ellos": "han ido"]
                ],
                group: "Mouvement",
                isIrregular: true
            ),
            Verb(
                id: "es-venir",
                verb: "venir",
                translation: "venir",
                conjugations: [
                    "Presente": ["yo": "vengo", "tú": "vienes", "él/ella": "viene", "nosotros": "venimos", "vosotros": "venís", "ellos": "vienen"],
                    "Pretérito perfecto": ["yo": "he venido", "tú": "has venido", "él/ella": "ha venido", "nosotros": "hemos venido", "vosotros": "habéis venido", "ellos": "han venido"]
                ],
                group: "Mouvement",
                isIrregular: true
            ),
            Verb(
                id: "es-salir",
                verb: "salir",
                translation: "sortir",
                conjugations: [
                    "Presente": ["yo": "salgo", "tú": "sales", "él/ella": "sale", "nosotros": "salimos", "vosotros": "salís", "ellos": "salen"],
                    "Pretérito perfecto": ["yo": "he salido", "tú": "has salido", "él/ella": "ha salido", "nosotros": "hemos salido", "vosotros": "habéis salido", "ellos": "han salido"]
                ],
                group: "Mouvement",
                isIrregular: true
            ),
            
            // Verbes modaux
            Verb(
                id: "es-poder",
                verb: "poder",
                translation: "pouvoir",
                conjugations: [
                    "Presente": ["yo": "puedo", "tú": "puedes", "él/ella": "puede", "nosotros": "podemos", "vosotros": "podéis", "ellos": "pueden"]
                ],
                group: "Modal",
                isIrregular: true
            ),
            Verb(
                id: "es-querer",
                verb: "querer",
                translation: "vouloir",
                conjugations: [
                    "Presente": ["yo": "quiero", "tú": "quieres", "él/ella": "quiere", "nosotros": "queremos", "vosotros": "queréis", "ellos": "quieren"]
                ],
                group: "Modal",
                isIrregular: true
            ),
            Verb(
                id: "es-saber",
                verb: "saber",
                translation: "savoir",
                conjugations: [
                    "Presente": ["yo": "sé", "tú": "sabes", "él/ella": "sabe", "nosotros": "sabemos", "vosotros": "sabéis", "ellos": "saben"]
                ],
                group: "Modal",
                isIrregular: true
            ),
            
            // Autres verbes courants
            Verb(
                id: "es-hacer",
                verb: "hacer",
                translation: "faire",
                conjugations: [
                    "Presente": ["yo": "hago", "tú": "haces", "él/ella": "hace", "nosotros": "hacemos", "vosotros": "hacéis", "ellos": "hacen"],
                    "Pretérito perfecto": ["yo": "he hecho", "tú": "has hecho", "él/ella": "ha hecho", "nosotros": "hemos hecho", "vosotros": "habéis hecho", "ellos": "han hecho"]
                ],
                group: "-ER",
                isIrregular: true
            ),
            Verb(
                id: "es-decir",
                verb: "decir",
                translation: "dire",
                conjugations: [
                    "Presente": ["yo": "digo", "tú": "dices", "él/ella": "dice", "nosotros": "decimos", "vosotros": "decís", "ellos": "dicen"],
                    "Pretérito perfecto": ["yo": "he dicho", "tú": "has dicho", "él/ella": "ha dicho", "nosotros": "hemos dicho", "vosotros": "habéis dicho", "ellos": "han dicho"]
                ],
                group: "-IR",
                isIrregular: true
            ),
            Verb(
                id: "es-dar",
                verb: "dar",
                translation: "donner",
                conjugations: [
                    "Presente": ["yo": "doy", "tú": "das", "él/ella": "da", "nosotros": "damos", "vosotros": "dais", "ellos": "dan"],
                    "Pretérito perfecto": ["yo": "he dado", "tú": "has dado", "él/ella": "ha dado", "nosotros": "hemos dado", "vosotros": "habéis dado", "ellos": "han dado"]
                ],
                group: "-AR",
                isIrregular: true
            ),
            Verb(
                id: "es-poner",
                verb: "poner",
                translation: "mettre",
                conjugations: [
                    "Presente": ["yo": "pongo", "tú": "pones", "él/ella": "pone", "nosotros": "ponemos", "vosotros": "ponéis", "ellos": "ponen"],
                    "Pretérito perfecto": ["yo": "he puesto", "tú": "has puesto", "él/ella": "ha puesto", "nosotros": "hemos puesto", "vosotros": "habéis puesto", "ellos": "han puesto"]
                ],
                group: "-ER",
                isIrregular: true
            ),
            Verb(
                id: "es-traer",
                verb: "traer",
                translation: "apporter",
                conjugations: [
                    "Presente": ["yo": "traigo", "tú": "traes", "él/ella": "trae", "nosotros": "traemos", "vosotros": "traéis", "ellos": "traen"],
                    "Pretérito perfecto": ["yo": "he traído", "tú": "has traído", "él/ella": "ha traído", "nosotros": "hemos traído", "vosotros": "habéis traído", "ellos": "han traído"]
                ],
                group: "-ER",
                isIrregular: true
            ),
            Verb(
                id: "es-conocer",
                verb: "conocer",
                translation: "connaître",
                conjugations: [
                    "Presente": ["yo": "conozco", "tú": "conoces", "él/ella": "conoce", "nosotros": "conocemos", "vosotros": "conocéis", "ellos": "conocen"],
                    "Pretérito perfecto": ["yo": "he conocido", "tú": "has conocido", "él/ella": "ha conocido", "nosotros": "hemos conocido", "vosotros": "habéis conocido", "ellos": "han conocido"]
                ],
                group: "-ER",
                isIrregular: false
            ),
            Verb(
                id: "es-entender",
                verb: "entender",
                translation: "comprendre",
                conjugations: [
                    "Presente": ["yo": "entiendo", "tú": "entiendes", "él/ella": "entiende", "nosotros": "entendemos", "vosotros": "entendéis", "ellos": "entienden"],
                    "Pretérito perfecto": ["yo": "he entendido", "tú": "has entendido", "él/ella": "ha entendido", "nosotros": "hemos entendido", "vosotros": "habéis entendido", "ellos": "han entendido"]
                ],
                group: "-ER",
                isIrregular: false
            ),
            
            // Verbes réguliers -AR
            Verb(
                id: "es-hablar",
                verb: "hablar",
                translation: "parler",
                conjugations: [
                    "Presente": ["yo": "hablo", "tú": "hablas", "él/ella": "habla", "nosotros": "hablamos", "vosotros": "habláis", "ellos": "hablan"],
                    "Pretérito perfecto": ["yo": "he hablado", "tú": "has hablado", "él/ella": "ha hablado", "nosotros": "hemos hablado", "vosotros": "habéis hablado", "ellos": "han hablado"]
                ],
                group: "-AR",
                isIrregular: false
            ),
            
            // Verbes réguliers -ER
            Verb(
                id: "es-comer",
                verb: "comer",
                translation: "manger",
                conjugations: [
                    "Presente": ["yo": "como", "tú": "comes", "él/ella": "come", "nosotros": "comemos", "vosotros": "coméis", "ellos": "comen"],
                    "Pretérito perfecto": ["yo": "he comido", "tú": "has comido", "él/ella": "ha comido", "nosotros": "hemos comido", "vosotros": "habéis comido", "ellos": "han comido"]
                ],
                group: "-ER",
                isIrregular: false
            ),
            Verb(
                id: "es-beber",
                verb: "beber",
                translation: "boire",
                conjugations: [
                    "Presente": ["yo": "bebo", "tú": "bebes", "él/ella": "bebe", "nosotros": "bebemos", "vosotros": "bebéis", "ellos": "beben"],
                    "Pretérito perfecto": ["yo": "he bebido", "tú": "has bebido", "él/ella": "ha bebido", "nosotros": "hemos bebido", "vosotros": "habéis bebido", "ellos": "han bebido"]
                ],
                group: "-ER",
                isIrregular: false
            ),
            Verb(
                id: "es-ver",
                verb: "ver",
                translation: "voir",
                conjugations: [
                    "Presente": ["yo": "veo", "tú": "ves", "él/ella": "ve", "nosotros": "vemos", "vosotros": "veis", "ellos": "ven"],
                    "Pretérito perfecto": ["yo": "he visto", "tú": "has visto", "él/ella": "ha visto", "nosotros": "hemos visto", "vosotros": "habéis visto", "ellos": "han visto"]
                ],
                group: "-ER",
                isIrregular: false
            ),
            Verb(
                id: "es-leer",
                verb: "leer",
                translation: "lire",
                conjugations: [
                    "Presente": ["yo": "leo", "tú": "lees", "él/ella": "lee", "nosotros": "leemos", "vosotros": "leéis", "ellos": "leen"],
                    "Pretérito perfecto": ["yo": "he leído", "tú": "has leído", "él/ella": "ha leído", "nosotros": "hemos leído", "vosotros": "habéis leído", "ellos": "han leído"]
                ],
                group: "-ER",
                isIrregular: false
            ),
            
            // Verbes réguliers -IR
            Verb(
                id: "es-vivir",
                verb: "vivir",
                translation: "vivre",
                conjugations: [
                    "Presente": ["yo": "vivo", "tú": "vives", "él/ella": "vive", "nosotros": "vivimos", "vosotros": "vivís", "ellos": "viven"],
                    "Pretérito perfecto": ["yo": "he vivido", "tú": "has vivido", "él/ella": "ha vivido", "nosotros": "hemos vivido", "vosotros": "habéis vivido", "ellos": "han vivido"]
                ],
                group: "-IR",
                isIrregular: false
            ),
            Verb(
                id: "es-escribir",
                verb: "escribir",
                translation: "écrire",
                conjugations: [
                    "Presente": ["yo": "escribo", "tú": "escribes", "él/ella": "escribe", "nosotros": "escribimos", "vosotros": "escribís", "ellos": "escriben"],
                    "Pretérito perfecto": ["yo": "he escrito", "tú": "has escrito", "él/ella": "ha escrito", "nosotros": "hemos escrito", "vosotros": "habéis escrito", "ellos": "han escrito"]
                ],
                group: "-IR",
                isIrregular: false
            )
        ]
    }
}
