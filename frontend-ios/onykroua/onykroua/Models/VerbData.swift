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
            ),
            
            // MOUVEMENT ADDITIONNELS
            Verb(
                id: "it-tornare",
                verb: "tornare",
                translation: "revenir / retourner",
                conjugations: [
                    "Présent": ["io": "torno", "tu": "torni", "lui/lei": "torna", "noi": "torniamo", "voi": "tornate", "loro": "tornano"],
                    "Passato prossimo": ["io": "sono tornato", "tu": "sei tornato", "lui/lei": "è tornato", "noi": "siamo tornati", "voi": "siete tornati", "loro": "sono tornati"]
                ],
                group: "Mouvement",
                isIrregular: false
            ),
            Verb(
                id: "it-arrivare",
                verb: "arrivare",
                translation: "arriver",
                conjugations: [
                    "Présent": ["io": "arrivo", "tu": "arrivi", "lui/lei": "arriva", "noi": "arriviamo", "voi": "arrivate", "loro": "arrivano"],
                    "Passato prossimo": ["io": "sono arrivato", "tu": "sei arrivato", "lui/lei": "è arrivato", "noi": "siamo arrivati", "voi": "siete arrivati", "loro": "sono arrivati"]
                ],
                group: "Mouvement",
                isIrregular: false
            ),
            Verb(
                id: "it-entrare",
                verb: "entrare",
                translation: "entrer",
                conjugations: [
                    "Présent": ["io": "entro", "tu": "entri", "lui/lei": "entra", "noi": "entriamo", "voi": "entrate", "loro": "entrano"],
                    "Passato prossimo": ["io": "sono entrato", "tu": "sei entrato", "lui/lei": "è entrato", "noi": "siamo entrati", "voi": "siete entrati", "loro": "sono entrati"]
                ],
                group: "Mouvement",
                isIrregular: false
            ),
            Verb(
                id: "it-scendere",
                verb: "scendere",
                translation: "descendre",
                conjugations: [
                    "Présent": ["io": "scendo", "tu": "scendi", "lui/lei": "scende", "noi": "scendiamo", "voi": "scendete", "loro": "scendono"],
                    "Passato prossimo": ["io": "sono sceso", "tu": "sei sceso", "lui/lei": "è sceso", "noi": "siamo scesi", "voi": "siete scesi", "loro": "sono scesi"]
                ],
                group: "Mouvement",
                isIrregular: true
            ),
            Verb(
                id: "it-salire",
                verb: "salire",
                translation: "monter",
                conjugations: [
                    "Présent": ["io": "salgo", "tu": "sali", "lui/lei": "sale", "noi": "saliamo", "voi": "salite", "loro": "salgono"],
                    "Passato prossimo": ["io": "sono salito", "tu": "sei salito", "lui/lei": "è salito", "noi": "siamo saliti", "voi": "siete saliti", "loro": "sono saliti"]
                ],
                group: "Mouvement",
                isIrregular: true
            ),
            Verb(
                id: "it-correre",
                verb: "correre",
                translation: "courir",
                conjugations: [
                    "Présent": ["io": "corro", "tu": "corri", "lui/lei": "corre", "noi": "corriamo", "voi": "correte", "loro": "corrono"],
                    "Passato prossimo": ["io": "ho corso", "tu": "hai corso", "lui/lei": "ha corso", "noi": "abbiamo corso", "voi": "avete corso", "loro": "hanno corso"]
                ],
                group: "Mouvement",
                isIrregular: false
            ),
            
            // COMMUNICATION
            Verb(
                id: "it-raccontare",
                verb: "raccontare",
                translation: "raconter",
                conjugations: [
                    "Présent": ["io": "racconto", "tu": "racconti", "lui/lei": "racconta", "noi": "raccontiamo", "voi": "raccontate", "loro": "raccontano"],
                    "Passato prossimo": ["io": "ho raccontato", "tu": "hai raccontato", "lui/lei": "ha raccontato", "noi": "abbiamo raccontato", "voi": "avete raccontato", "loro": "hanno raccontato"]
                ],
                group: "Communication",
                isIrregular: false
            ),
            Verb(
                id: "it-chiedere",
                verb: "chiedere",
                translation: "demander",
                conjugations: [
                    "Présent": ["io": "chiedo", "tu": "chiedi", "lui/lei": "chiede", "noi": "chiediamo", "voi": "chiedete", "loro": "chiedono"],
                    "Passato prossimo": ["io": "ho chiesto", "tu": "hai chiesto", "lui/lei": "ha chiesto", "noi": "abbiamo chiesto", "voi": "avete chiesto", "loro": "hanno chiesto"]
                ],
                group: "Communication",
                isIrregular: true
            ),
            Verb(
                id: "it-rispondere",
                verb: "rispondere",
                translation: "répondre",
                conjugations: [
                    "Présent": ["io": "rispondo", "tu": "rispondi", "lui/lei": "risponde", "noi": "rispondiamo", "voi": "rispondete", "loro": "rispondono"],
                    "Passato prossimo": ["io": "ho risposto", "tu": "hai risposto", "lui/lei": "ha risposto", "noi": "abbiamo risposto", "voi": "avete risposto", "loro": "hanno risposto"]
                ],
                group: "Communication",
                isIrregular: true
            ),
            Verb(
                id: "it-telefonare",
                verb: "telefonare",
                translation: "téléphoner",
                conjugations: [
                    "Présent": ["io": "telefono", "tu": "telefoni", "lui/lei": "telefona", "noi": "telefoniamo", "voi": "telefonate", "loro": "telefonano"],
                    "Passato prossimo": ["io": "ho telefonato", "tu": "hai telefonato", "lui/lei": "ha telefonato", "noi": "abbiamo telefonato", "voi": "avete telefonato", "loro": "hanno telefonato"]
                ],
                group: "Communication",
                isIrregular: false
            ),
            
            // PERCEPTION
            Verb(
                id: "it-sentire",
                verb: "sentire",
                translation: "entendre / sentir",
                conjugations: [
                    "Présent": ["io": "sento", "tu": "senti", "lui/lei": "sente", "noi": "sentiamo", "voi": "sentite", "loro": "sentono"],
                    "Passato prossimo": ["io": "ho sentito", "tu": "hai sentito", "lui/lei": "ha sentito", "noi": "abbiamo sentito", "voi": "avete sentito", "loro": "hanno sentito"]
                ],
                group: "Perception",
                isIrregular: false
            ),
            Verb(
                id: "it-ascoltare",
                verb: "ascoltare",
                translation: "écouter",
                conjugations: [
                    "Présent": ["io": "ascolto", "tu": "ascolti", "lui/lei": "ascolta", "noi": "ascoltiamo", "voi": "ascoltate", "loro": "ascoltano"],
                    "Passato prossimo": ["io": "ho ascoltato", "tu": "hai ascoltato", "lui/lei": "ha ascoltato", "noi": "abbiamo ascoltato", "voi": "avete ascoltato", "loro": "hanno ascoltato"]
                ],
                group: "Perception",
                isIrregular: false
            ),
            Verb(
                id: "it-guardare",
                verb: "guardare",
                translation: "regarder",
                conjugations: [
                    "Présent": ["io": "guardo", "tu": "guardi", "lui/lei": "guarda", "noi": "guardiamo", "voi": "guardate", "loro": "guardano"],
                    "Passato prossimo": ["io": "ho guardato", "tu": "hai guardato", "lui/lei": "ha guardato", "noi": "abbiamo guardato", "voi": "avete guardato", "loro": "hanno guardato"]
                ],
                group: "Perception",
                isIrregular: false
            ),
            Verb(
                id: "it-toccare",
                verb: "toccare",
                translation: "toucher",
                conjugations: [
                    "Présent": ["io": "tocco", "tu": "tocchi", "lui/lei": "tocca", "noi": "tocchiamo", "voi": "toccate", "loro": "toccano"],
                    "Passato prossimo": ["io": "ho toccato", "tu": "hai toccato", "lui/lei": "ha toccato", "noi": "abbiamo toccato", "voi": "avete toccato", "loro": "hanno toccato"]
                ],
                group: "Perception",
                isIrregular: false
            ),
            
            // VIE QUOTIDIENNE
            Verb(
                id: "it-svegliarsi",
                verb: "svegliarsi",
                translation: "se réveiller",
                conjugations: [
                    "Présent": ["io": "mi sveglio", "tu": "ti svegli", "lui/lei": "si sveglia", "noi": "ci svegliamo", "voi": "vi svegliate", "loro": "si svegliano"],
                    "Passato prossimo": ["io": "mi sono svegliato", "tu": "ti sei svegliato", "lui/lei": "si è svegliato", "noi": "ci siamo svegliati", "voi": "vi siete svegliati", "loro": "si sono svegliati"]
                ],
                group: "Vie quotidienne",
                isIrregular: false
            ),
            Verb(
                id: "it-alzarsi",
                verb: "alzarsi",
                translation: "se lever",
                conjugations: [
                    "Présent": ["io": "mi alzo", "tu": "ti alzi", "lui/lei": "si alza", "noi": "ci alziamo", "voi": "vi alzate", "loro": "si alzano"],
                    "Passato prossimo": ["io": "mi sono alzato", "tu": "ti sei alzato", "lui/lei": "si è alzato", "noi": "ci siamo alzati", "voi": "vi siete alzati", "loro": "si sono alzati"]
                ],
                group: "Vie quotidienne",
                isIrregular: false
            ),
            Verb(
                id: "it-lavarsi",
                verb: "lavarsi",
                translation: "se laver",
                conjugations: [
                    "Présent": ["io": "mi lavo", "tu": "ti lavi", "lui/lei": "si lava", "noi": "ci laviamo", "voi": "vi lavate", "loro": "si lavano"],
                    "Passato prossimo": ["io": "mi sono lavato", "tu": "ti sei lavato", "lui/lei": "si è lavato", "noi": "ci siamo lavati", "voi": "vi siete lavati", "loro": "si sono lavati"]
                ],
                group: "Vie quotidienne",
                isIrregular: false
            ),
            Verb(
                id: "it-vestirsi",
                verb: "vestirsi",
                translation: "s'habiller",
                conjugations: [
                    "Présent": ["io": "mi vesto", "tu": "ti vesti", "lui/lei": "si veste", "noi": "ci vestiamo", "voi": "vi vestite", "loro": "si vestono"],
                    "Passato prossimo": ["io": "mi sono vestito", "tu": "ti sei vestito", "lui/lei": "si è vestito", "noi": "ci siamo vestiti", "voi": "vi siete vestiti", "loro": "si sono vestiti"]
                ],
                group: "Vie quotidienne",
                isIrregular: false
            ),
            Verb(
                id: "it-cucinare",
                verb: "cucinare",
                translation: "cuisiner",
                conjugations: [
                    "Présent": ["io": "cucino", "tu": "cucini", "lui/lei": "cucina", "noi": "cuciniamo", "voi": "cucinate", "loro": "cucinano"],
                    "Passato prossimo": ["io": "ho cucinato", "tu": "hai cucinato", "lui/lei": "ha cucinato", "noi": "abbiamo cucinato", "voi": "avete cucinato", "loro": "hanno cucinato"]
                ],
                group: "Vie quotidienne",
                isIrregular: false
            ),
            Verb(
                id: "it-pulire",
                verb: "pulire",
                translation: "nettoyer",
                conjugations: [
                    "Présent": ["io": "pulisco", "tu": "pulisci", "lui/lei": "pulisce", "noi": "puliamo", "voi": "pulite", "loro": "puliscono"],
                    "Passato prossimo": ["io": "ho pulito", "tu": "hai pulito", "lui/lei": "ha pulito", "noi": "abbiamo pulito", "voi": "avete pulito", "loro": "hanno pulito"]
                ],
                group: "Vie quotidienne",
                isIrregular: false
            ),
            
            // TRAVAIL & ÉTUDE
            Verb(
                id: "it-lavorare",
                verb: "lavorare",
                translation: "travailler",
                conjugations: [
                    "Présent": ["io": "lavoro", "tu": "lavori", "lui/lei": "lavora", "noi": "lavoriamo", "voi": "lavorate", "loro": "lavorano"],
                    "Passato prossimo": ["io": "ho lavorato", "tu": "hai lavorato", "lui/lei": "ha lavorato", "noi": "abbiamo lavorato", "voi": "avete lavorato", "loro": "hanno lavorato"]
                ],
                group: "Travail",
                isIrregular: false
            ),
            Verb(
                id: "it-studiare",
                verb: "studiare",
                translation: "étudier",
                conjugations: [
                    "Présent": ["io": "studio", "tu": "studi", "lui/lei": "studia", "noi": "studiamo", "voi": "studiate", "loro": "studiano"],
                    "Passato prossimo": ["io": "ho studiato", "tu": "hai studiato", "lui/lei": "ha studiato", "noi": "abbiamo studiato", "voi": "avete studiato", "loro": "hanno studiato"]
                ],
                group: "Travail",
                isIrregular: false
            ),
            Verb(
                id: "it-imparare",
                verb: "imparare",
                translation: "apprendre",
                conjugations: [
                    "Présent": ["io": "imparo", "tu": "impari", "lui/lei": "impara", "noi": "impariamo", "voi": "imparate", "loro": "imparano"],
                    "Passato prossimo": ["io": "ho imparato", "tu": "hai imparato", "lui/lei": "ha imparato", "noi": "abbiamo imparato", "voi": "avete imparato", "loro": "hanno imparato"]
                ],
                group: "Travail",
                isIrregular: false
            ),
            Verb(
                id: "it-insegnare",
                verb: "insegnare",
                translation: "enseigner",
                conjugations: [
                    "Présent": ["io": "insegno", "tu": "insegni", "lui/lei": "insegna", "noi": "insegniamo", "voi": "insegnate", "loro": "insegnano"],
                    "Passato prossimo": ["io": "ho insegnato", "tu": "hai insegnato", "lui/lei": "ha insegnato", "noi": "abbiamo insegnato", "voi": "avete insegnato", "loro": "hanno insegnato"]
                ],
                group: "Travail",
                isIrregular: false
            ),
            Verb(
                id: "it-guadagnare",
                verb: "guadagnare",
                translation: "gagner (argent)",
                conjugations: [
                    "Présent": ["io": "guadagno", "tu": "guadagni", "lui/lei": "guadagna", "noi": "guadagniamo", "voi": "guadagnate", "loro": "guadagnano"],
                    "Passato prossimo": ["io": "ho guadagnato", "tu": "hai guadagnato", "lui/lei": "ha guadagnato", "noi": "abbiamo guadagnato", "voi": "avete guadagnato", "loro": "hanno guadagnato"]
                ],
                group: "Travail",
                isIrregular: false
            ),
            Verb(
                id: "it-perdere",
                verb: "perdere",
                translation: "perdre",
                conjugations: [
                    "Présent": ["io": "perdo", "tu": "perdi", "lui/lei": "perde", "noi": "perdiamo", "voi": "perdete", "loro": "perdono"],
                    "Passato prossimo": ["io": "ho perso", "tu": "hai perso", "lui/lei": "ha perso", "noi": "abbiamo perso", "voi": "avete perso", "loro": "hanno perso"]
                ],
                group: "Travail",
                isIrregular: true
            ),
            Verb(
                id: "it-vincere",
                verb: "vincere",
                translation: "gagner (victoire)",
                conjugations: [
                    "Présent": ["io": "vinco", "tu": "vinci", "lui/lei": "vince", "noi": "vinciamo", "voi": "vincete", "loro": "vincono"],
                    "Passato prossimo": ["io": "ho vinto", "tu": "hai vinto", "lui/lei": "ha vinto", "noi": "abbiamo vinto", "voi": "avete vinto", "loro": "hanno vinto"]
                ],
                group: "Travail",
                isIrregular: true
            ),
            
            // ÉMOTIONS
            Verb(
                id: "it-amare",
                verb: "amare",
                translation: "aimer",
                conjugations: [
                    "Présent": ["io": "amo", "tu": "ami", "lui/lei": "ama", "noi": "amiamo", "voi": "amate", "loro": "amano"],
                    "Passato prossimo": ["io": "ho amato", "tu": "hai amato", "lui/lei": "ha amato", "noi": "abbiamo amato", "voi": "avete amato", "loro": "hanno amato"]
                ],
                group: "Émotions",
                isIrregular: false
            ),
            Verb(
                id: "it-odiare",
                verb: "odiare",
                translation: "détester",
                conjugations: [
                    "Présent": ["io": "odio", "tu": "odi", "lui/lei": "odia", "noi": "odiamo", "voi": "odiate", "loro": "odiano"],
                    "Passato prossimo": ["io": "ho odiato", "tu": "hai odiato", "lui/lei": "ha odiato", "noi": "abbiamo odiato", "voi": "avete odiato", "loro": "hanno odiato"]
                ],
                group: "Émotions",
                isIrregular: false
            ),
            Verb(
                id: "it-preferire",
                verb: "preferire",
                translation: "préférer",
                conjugations: [
                    "Présent": ["io": "preferisco", "tu": "preferisci", "lui/lei": "preferisce", "noi": "preferiamo", "voi": "preferite", "loro": "preferiscono"],
                    "Passato prossimo": ["io": "ho preferito", "tu": "hai preferito", "lui/lei": "ha preferito", "noi": "abbiamo preferito", "voi": "avete preferito", "loro": "hanno preferito"]
                ],
                group: "Émotions",
                isIrregular: false
            ),
            Verb(
                id: "it-piacere",
                verb: "piacere",
                translation: "plaire",
                conjugations: [
                    "Présent": ["mi": "piace/piacciono", "ti": "piace/piacciono", "gli/le": "piace/piacciono", "ci": "piace/piacciono", "vi": "piace/piacciono", "loro": "piace/piacciono"],
                    "Passato prossimo": ["mi": "è piaciuto/a", "ti": "è piaciuto/a", "gli/le": "è piaciuto/a", "ci": "è piaciuto/a", "vi": "è piaciuto/a", "loro": "è piaciuto/a"]
                ],
                group: "Émotions",
                isIrregular: true
            ),
            Verb(
                id: "it-sperare",
                verb: "sperare",
                translation: "espérer",
                conjugations: [
                    "Présent": ["io": "spero", "tu": "speri", "lui/lei": "spera", "noi": "speriamo", "voi": "sperate", "loro": "sperano"],
                    "Passato prossimo": ["io": "ho sperato", "tu": "hai sperato", "lui/lei": "ha sperato", "noi": "abbiamo sperato", "voi": "avete sperato", "loro": "hanno sperato"]
                ],
                group: "Émotions",
                isIrregular: false
            ),
            Verb(
                id: "it-temere",
                verb: "temere",
                translation: "craindre",
                conjugations: [
                    "Présent": ["io": "temo", "tu": "temi", "lui/lei": "teme", "noi": "temiamo", "voi": "temete", "loro": "temono"],
                    "Passato prossimo": ["io": "ho temuto", "tu": "hai temuto", "lui/lei": "ha temuto", "noi": "abbiamo temuto", "voi": "avete temuto", "loro": "hanno temuto"]
                ],
                group: "Émotions",
                isIrregular: false
            ),
            
            // ACTIONS
            Verb(
                id: "it-portare",
                verb: "portare",
                translation: "porter / apporter",
                conjugations: [
                    "Présent": ["io": "porto", "tu": "porti", "lui/lei": "porta", "noi": "portiamo", "voi": "portate", "loro": "portano"],
                    "Passato prossimo": ["io": "ho portato", "tu": "hai portato", "lui/lei": "ha portato", "noi": "abbiamo portato", "voi": "avete portato", "loro": "hanno portato"]
                ],
                group: "Actions",
                isIrregular: false
            ),
            Verb(
                id: "it-mettere",
                verb: "mettere",
                translation: "mettre",
                conjugations: [
                    "Présent": ["io": "metto", "tu": "metti", "lui/lei": "mette", "noi": "mettiamo", "voi": "mettete", "loro": "mettono"],
                    "Passato prossimo": ["io": "ho messo", "tu": "hai messo", "lui/lei": "ha messo", "noi": "abbiamo messo", "voi": "avete messo", "loro": "hanno messo"]
                ],
                group: "Actions",
                isIrregular: true
            ),
            Verb(
                id: "it-aprire",
                verb: "aprire",
                translation: "ouvrir",
                conjugations: [
                    "Présent": ["io": "apro", "tu": "apri", "lui/lei": "apre", "noi": "apriamo", "voi": "aprite", "loro": "aprono"],
                    "Passato prossimo": ["io": "ho aperto", "tu": "hai aperto", "lui/lei": "ha aperto", "noi": "abbiamo aperto", "voi": "avete aperto", "loro": "hanno aperto"]
                ],
                group: "Actions",
                isIrregular: true
            ),
            Verb(
                id: "it-chiudere",
                verb: "chiudere",
                translation: "fermer",
                conjugations: [
                    "Présent": ["io": "chiudo", "tu": "chiudi", "lui/lei": "chiude", "noi": "chiudiamo", "voi": "chiudete", "loro": "chiudono"],
                    "Passato prossimo": ["io": "ho chiuso", "tu": "hai chiuso", "lui/lei": "ha chiuso", "noi": "abbiamo chiuso", "voi": "avete chiuso", "loro": "hanno chiuso"]
                ],
                group: "Actions",
                isIrregular: true
            ),
            Verb(
                id: "it-comprare",
                verb: "comprare",
                translation: "acheter",
                conjugations: [
                    "Présent": ["io": "compro", "tu": "compri", "lui/lei": "compra", "noi": "compriamo", "voi": "comprate", "loro": "comprano"],
                    "Passato prossimo": ["io": "ho comprato", "tu": "hai comprato", "lui/lei": "ha comprato", "noi": "abbiamo comprato", "voi": "avete comprato", "loro": "hanno comprato"]
                ],
                group: "Actions",
                isIrregular: false
            ),
            Verb(
                id: "it-vendere",
                verb: "vendere",
                translation: "vendre",
                conjugations: [
                    "Présent": ["io": "vendo", "tu": "vendi", "lui/lei": "vende", "noi": "vendiamo", "voi": "vendete", "loro": "vendono"],
                    "Passato prossimo": ["io": "ho venduto", "tu": "hai venduto", "lui/lei": "ha venduto", "noi": "abbiamo venduto", "voi": "avete venduto", "loro": "hanno venduto"]
                ],
                group: "Actions",
                isIrregular: false
            ),
            Verb(
                id: "it-pagare",
                verb: "pagare",
                translation: "payer",
                conjugations: [
                    "Présent": ["io": "pago", "tu": "paghi", "lui/lei": "paga", "noi": "paghiamo", "voi": "pagate", "loro": "pagano"],
                    "Passato prossimo": ["io": "ho pagato", "tu": "hai pagato", "lui/lei": "ha pagato", "noi": "abbiamo pagato", "voi": "avete pagato", "loro": "hanno pagato"]
                ],
                group: "Actions",
                isIrregular: false
            ),
            Verb(
                id: "it-trovare",
                verb: "trovare",
                translation: "trouver",
                conjugations: [
                    "Présent": ["io": "trovo", "tu": "trovi", "lui/lei": "trova", "noi": "troviamo", "voi": "trovate", "loro": "trovano"],
                    "Passato prossimo": ["io": "ho trovato", "tu": "hai trovato", "lui/lei": "ha trovato", "noi": "abbiamo trovato", "voi": "avete trovato", "loro": "hanno trovato"]
                ],
                group: "Actions",
                isIrregular: false
            ),
            Verb(
                id: "it-cercare",
                verb: "cercare",
                translation: "chercher",
                conjugations: [
                    "Présent": ["io": "cerco", "tu": "cerchi", "lui/lei": "cerca", "noi": "cerchiamo", "voi": "cercate", "loro": "cercano"],
                    "Passato prossimo": ["io": "ho cercato", "tu": "hai cercato", "lui/lei": "ha cercato", "noi": "abbiamo cercato", "voi": "avete cercato", "loro": "hanno cercato"]
                ],
                group: "Actions",
                isIrregular: false
            ),
            Verb(
                id: "it-lasciare",
                verb: "lasciare",
                translation: "laisser",
                conjugations: [
                    "Présent": ["io": "lascio", "tu": "lasci", "lui/lei": "lascia", "noi": "lasciamo", "voi": "lasciate", "loro": "lasciano"],
                    "Passato prossimo": ["io": "ho lasciato", "tu": "hai lasciato", "lui/lei": "ha lasciato", "noi": "abbiamo lasciato", "voi": "avete lasciato", "loro": "hanno lasciato"]
                ],
                group: "Actions",
                isIrregular: false
            ),
            
            // COGNITIF
            Verb(
                id: "it-pensare",
                verb: "pensare",
                translation: "penser",
                conjugations: [
                    "Présent": ["io": "penso", "tu": "pensi", "lui/lei": "pensa", "noi": "pensiamo", "voi": "pensate", "loro": "pensano"],
                    "Passato prossimo": ["io": "ho pensato", "tu": "hai pensato", "lui/lei": "ha pensato", "noi": "abbiamo pensato", "voi": "avete pensato", "loro": "hanno pensato"]
                ],
                group: "Cognitif",
                isIrregular: false
            ),
            Verb(
                id: "it-credere",
                verb: "credere",
                translation: "croire",
                conjugations: [
                    "Présent": ["io": "credo", "tu": "credi", "lui/lei": "crede", "noi": "crediamo", "voi": "credete", "loro": "credono"],
                    "Passato prossimo": ["io": "ho creduto", "tu": "hai creduto", "lui/lei": "ha creduto", "noi": "abbiamo creduto", "voi": "avete creduto", "loro": "hanno creduto"]
                ],
                group: "Cognitif",
                isIrregular: false
            ),
            Verb(
                id: "it-ricordare",
                verb: "ricordare",
                translation: "se souvenir",
                conjugations: [
                    "Présent": ["io": "ricordo", "tu": "ricordi", "lui/lei": "ricorda", "noi": "ricordiamo", "voi": "ricordate", "loro": "ricordano"],
                    "Passato prossimo": ["io": "ho ricordato", "tu": "hai ricordato", "lui/lei": "ha ricordato", "noi": "abbiamo ricordato", "voi": "avete ricordato", "loro": "hanno ricordato"]
                ],
                group: "Cognitif",
                isIrregular: false
            ),
            Verb(
                id: "it-dimenticare",
                verb: "dimenticare",
                translation: "oublier",
                conjugations: [
                    "Présent": ["io": "dimentico", "tu": "dimentichi", "lui/lei": "dimentica", "noi": "dimentichiamo", "voi": "dimenticate", "loro": "dimenticano"],
                    "Passato prossimo": ["io": "ho dimenticato", "tu": "hai dimenticato", "lui/lei": "ha dimenticato", "noi": "abbiamo dimenticato", "voi": "avete dimenticato", "loro": "hanno dimenticato"]
                ],
                group: "Cognitif",
                isIrregular: false
            ),
            Verb(
                id: "it-decidere",
                verb: "decidere",
                translation: "décider",
                conjugations: [
                    "Présent": ["io": "decido", "tu": "decidi", "lui/lei": "decide", "noi": "decidiamo", "voi": "decidete", "loro": "decidono"],
                    "Passato prossimo": ["io": "ho deciso", "tu": "hai deciso", "lui/lei": "ha deciso", "noi": "abbiamo deciso", "voi": "avete deciso", "loro": "hanno deciso"]
                ],
                group: "Cognitif",
                isIrregular: true
            ),
            
            // SOCIAL
            Verb(
                id: "it-incontrare",
                verb: "incontrare",
                translation: "rencontrer",
                conjugations: [
                    "Présent": ["io": "incontro", "tu": "incontri", "lui/lei": "incontra", "noi": "incontriamo", "voi": "incontrate", "loro": "incontrano"],
                    "Passato prossimo": ["io": "ho incontrato", "tu": "hai incontrato", "lui/lei": "ha incontrato", "noi": "abbiamo incontrato", "voi": "avete incontrato", "loro": "hanno incontrato"]
                ],
                group: "Social",
                isIrregular: false
            ),
            Verb(
                id: "it-salutare",
                verb: "salutare",
                translation: "saluer",
                conjugations: [
                    "Présent": ["io": "saluto", "tu": "saluti", "lui/lei": "saluta", "noi": "salutiamo", "voi": "salutate", "loro": "salutano"],
                    "Passato prossimo": ["io": "ho salutato", "tu": "hai salutato", "lui/lei": "ha salutato", "noi": "abbiamo salutato", "voi": "avete salutato", "loro": "hanno salutato"]
                ],
                group: "Social",
                isIrregular: false
            ),
            Verb(
                id: "it-aiutare",
                verb: "aiutare",
                translation: "aider",
                conjugations: [
                    "Présent": ["io": "aiuto", "tu": "aiuti", "lui/lei": "aiuta", "noi": "aiutiamo", "voi": "aiutate", "loro": "aiutano"],
                    "Passato prossimo": ["io": "ho aiutato", "tu": "hai aiutato", "lui/lei": "ha aiutato", "noi": "abbiamo aiutato", "voi": "avete aiutato", "loro": "hanno aiutato"]
                ],
                group: "Social",
                isIrregular: false
            ),
            Verb(
                id: "it-ringraziare",
                verb: "ringraziare",
                translation: "remercier",
                conjugations: [
                    "Présent": ["io": "ringrazio", "tu": "ringrazi", "lui/lei": "ringrazia", "noi": "ringraziamo", "voi": "ringraziate", "loro": "ringraziano"],
                    "Passato prossimo": ["io": "ho ringraziato", "tu": "hai ringraziato", "lui/lei": "ha ringraziato", "noi": "abbiamo ringraziato", "voi": "avete ringraziato", "loro": "hanno ringraziato"]
                ],
                group: "Social",
                isIrregular: false
            ),
            Verb(
                id: "it-invitare",
                verb: "invitare",
                translation: "inviter",
                conjugations: [
                    "Présent": ["io": "invito", "tu": "inviti", "lui/lei": "invita", "noi": "invitiamo", "voi": "invitate", "loro": "invitano"],
                    "Passato prossimo": ["io": "ho invitato", "tu": "hai invitato", "lui/lei": "ha invitato", "noi": "abbiamo invitato", "voi": "avete invitato", "loro": "hanno invitato"]
                ],
                group: "Social",
                isIrregular: false
            ),
            
            // MÉTÉO
            Verb(
                id: "it-piovere",
                verb: "piovere",
                translation: "pleuvoir",
                conjugations: [
                    "Présent": ["": "piove"],
                    "Passato prossimo": ["": "è piovuto"]
                ],
                group: "Météo",
                isIrregular: false
            ),
            Verb(
                id: "it-nevicare",
                verb: "nevicare",
                translation: "neiger",
                conjugations: [
                    "Présent": ["": "nevica"],
                    "Passato prossimo": ["": "è nevicato"]
                ],
                group: "Météo",
                isIrregular: false
            ),
            
            // MODAL ADDITIONNEL
            Verb(
                id: "it-sapere-modal",
                verb: "sapere",
                translation: "savoir / pouvoir",
                conjugations: [
                    "Présent": ["io": "so", "tu": "sai", "lui/lei": "sa", "noi": "sappiamo", "voi": "sapete", "loro": "sanno"],
                    "Passato prossimo": ["io": "ho saputo", "tu": "hai saputo", "lui/lei": "ha saputo", "noi": "abbiamo saputo", "voi": "avete saputo", "loro": "hanno saputo"]
                ],
                group: "Modal",
                isIrregular: true
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
