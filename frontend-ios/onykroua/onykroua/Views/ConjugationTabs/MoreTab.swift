import SwiftUI

public struct MoreTab: View {
    public let grammarData: GrammarData
    public let language: String
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedSection = "pronouns"
    
    private var sections = ["pronouns", "expressions", "tips"]
    
    public init(grammarData: GrammarData, language: String) {
        self.grammarData = grammarData
        self.language = language
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Section Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sections, id: \.self) { section in
                        Button(action: { 
                            withAnimation(.spring()) { selectedSection = section }
                        }) {
                            Text(getSectionTitle(section))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedSection == section ? Color.blue : Color(.systemGray6))
                                .foregroundColor(selectedSection == section ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Content
            ScrollView {
                LazyVStack(spacing: 16) {
                    switch selectedSection {
                    case "pronouns":
                        PronounsSection(grammarData: grammarData, language: language, speechService: env.speechService)
                    case "expressions":
                        ExpressionsSection(language: language, speechService: env.speechService)
                    case "tips":
                        TipsSection(language: language, speechService: env.speechService)
                    default:
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }
    
    private func getSectionTitle(_ section: String) -> String {
        switch section {
        case "pronouns": return "Pronoms"
        case "expressions": return "Expressions"
        case "tips": return "Conseils"
        default: return section
        }
    }
}

public struct PronounsSection: View {
    let grammarData: GrammarData
    let language: String
    @ObservedObject var speechService: SpeechService
    
    private var pronouns: [Pronoun] {
        grammarData.getPronouns(language: language)
    }
    
    private var subjectPronouns: [Pronoun] {
        pronouns.filter { $0.type == "subject" }
    }
    
    private var directPronouns: [Pronoun] {
        pronouns.filter { $0.type == "direct" }
    }
    
    private var indirectPronouns: [Pronoun] {
        pronouns.filter { $0.type == "indirect" }
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Les pronoms personnels")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            PronounGroup(title: "Sujet", pronouns: subjectPronouns, speechService: speechService, language: language)
            PronounGroup(title: "Direct", pronouns: directPronouns, speechService: speechService, language: language)
            PronounGroup(title: "Indirect", pronouns: indirectPronouns, speechService: speechService, language: language)
        }
    }
}

public struct PronounGroup: View {
    let title: String
    let pronouns: [Pronoun]
    @ObservedObject var speechService: SpeechService
    let language: String
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                ForEach(pronouns) { pronoun in
                    HStack {
                        Text(pronoun.pronoun)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(width: 80, alignment: .leading)
                        
                        Text("→ \(pronoun.translation)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: { 
                            speechService.speak(pronoun.pronoun, language: language == "it" ? "it-IT" : "es-ES")
                        }) {
                            Image(systemName: "speaker.wave.1.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

public struct ExpressionsSection: View {
    let language: String
    @ObservedObject var speechService: SpeechService
    
    private var expressions: [(String, String, String)] {
        if language == "it" {
            return [
                ("In bocca al lupo!", "Bonne chance!", "Dans la gueule du loup"),
                ("Che bello!", "Que c'est beau!", ""),
                ("Non vedo l'ora!", "J'ai hâte!", "Je ne vois pas l'heure"),
                ("Mamma mia!", "Mon Dieu!", "Ma mère!"),
                ("Fare bella figura", "Faire bonne impression", ""),
                ("Avere voglia di", "Avoir envie de", ""),
                ("Andare d'accordo", "S'entendre bien", ""),
                ("Essere al verde", "Être fauché", "Être au vert")
            ]
        } else {
            return [
                ("¡Buena suerte!", "Bonne chance!", ""),
                ("¡Qué guay!", "Trop cool!", ""),
                ("¡No me digas!", "Sans blague!", "Ne me dis pas!"),
                ("Tener ganas de", "Avoir envie de", ""),
                ("Echar de menos", "Manquer (qqn)", "Jeter de moins"),
                ("Llevarse bien", "S'entendre bien", ""),
                ("Estar hecho polvo", "Être épuisé", "Être fait poussière"),
                ("Costar un ojo de la cara", "Coûter les yeux de la tête", "Coûter un œil du visage")
            ]
        }
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Expressions courantes")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(spacing: 12) {
                ForEach(Array(expressions.enumerated()), id: \.offset) { index, expression in
                    ExpressionCard(
                        phrase: expression.0,
                        translation: expression.1,
                        literal: expression.2,
                        speechService: speechService,
                        language: language
                    )
                }
            }
        }
    }
}

public struct ExpressionCard: View {
    let phrase: String
    let translation: String
    let literal: String
    @ObservedObject var speechService: SpeechService
    let language: String
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(phrase)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("→ \(translation)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !literal.isEmpty {
                        Text("Lit: \(literal)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Spacer()
                
                Button(action: { 
                    speechService.speak(phrase, language: language == "it" ? "it-IT" : "es-ES")
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

public struct TipsSection: View {
    let language: String
    @ObservedObject var speechService: SpeechService
    
    private var tips: [(String, [String])] {
        if language == "it" {
            return [
                ("Conseils pour les débutants", [
                    "Commencez par les verbes réguliers en -ARE, -ERE, -IRE",
                    "Apprenez les auxiliaires ESSERE et AVERE en priorité",
                    "Pratiquez la prononciation des double consonnes (tt, rr, ll)",
                    "Mémorisez les pronoms personnels sujets"
                ]),
                ("Règles importantes", [
                    "Les adjectifs s'accordent en genre et en nombre",
                    "Les verbes réfléchis utilisent le pronom 'mi, ti, si, ci, vi, si'",
                    "Le passé composé se forme avec avere ou essere + participe passé",
                    "L'imparfait décrit des actions habituelles dans le passé"
                ]),
                ("Erreurs communes", [
                    "Ne pas confondre ESSERE et AVERE",
                    "Oublier l'accord des participes passés avec ESSERE",
                    "Mauvaise prononciation du 'c' et du 'g'",
                    "Ne pas accorder les adjectifs avec le nom"
                ])
            ]
        } else {
            return [
                ("Conseils pour les débutants", [
                    "Commencez par les verbes réguliers en -AR, -ER, -IR",
                    "Apprenez la différence entre SER et ESTAR",
                    "Pratiquez la prononciation du 'j' et du 'ñ'",
                    "Mémorisez les pronoms personnels sujets"
                ]),
                ("Règles importantes", [
                    "Les adjectifs s'accordent en genre et en nombre",
                    "Les verbes réfléchis utilisent 'me, te, se, nos, os, se'",
                    "Le passé composé se forme avec HABER + participe passé",
                    "L'imparfait décrit des actions habituelles dans le passé"
                ]),
                ("Erreurs communes", [
                    "Confondre SER et ESTAR",
                    "Mauvais usage du subjonctif",
                    "Oublier la différence entre vosotros/ustedes",
                    "Ne pas accorder les adjectifs avec le nom"
                ])
            ]
        }
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Conseils & Astuces")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(spacing: 16) {
                ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                    TipCard(title: tip.0, points: tip.1)
                }
            }
        }
    }
}

public struct TipCard: View {
    let title: String
    let points: [String]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text(point)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
