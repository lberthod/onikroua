import SwiftUI

struct GrammarView: View {
    let grammarTopics = [
        GrammarTopic(title: "📌 Les articles définis", content: "Masculin: il (sing.), i (plur.), lo/gli (devant s+consonne, z, ps, gn)\nFéminin: la (sing.), le (plur.)\nExemple: il libro (le livre), la casa (la maison), lo studente (l'étudiant)"),
        GrammarTopic(title: "📍 Les prépositions simples", content: "di (de), a (à), da (de/depuis), in (dans), con (avec), su (sur), per (pour), tra/fra (entre)\nExemple: Vado a Roma (Je vais à Rome), Vengo da Milano (Je viens de Milan)"),
        GrammarTopic(title: "🔗 Les prépositions articulées", content: "Contraction préposition + article:\ndel (di+il), della (di+la), dello (di+lo)\nal (a+il), alla (a+la), allo (a+lo)\nExemple: Vado al cinema (Je vais au cinéma)"),
        GrammarTopic(title: "👤 Les pronoms personnels", content: "Sujets: io, tu, lui/lei, noi, voi, loro\nCompléments directs: mi, ti, lo/la, ci, vi, li/le\nCompléments indirects: mi, ti, gli/le, ci, vi, gli\nExemple: Ti amo (Je t'aime)"),
        GrammarTopic(title: "🏠 Les adjectifs possessifs", content: "mio/mia (mon/ma), tuo/tua (ton/ta), suo/sua (son/sa)\nnostro/nostra (notre), vostro/vostra (votre), loro (leur)\nExemple: il mio libro (mon livre), la mia casa (ma maison)"),
        GrammarTopic(title: "⚖️ Genre et nombre", content: "Masculin -o → pluriel -i: libro/libri\nFéminin -a → pluriel -e: casa/case\nMasculin/Féminin -e → pluriel -i: studente/studenti\nExemple: il ragazzo bello → i ragazzi belli"),
        GrammarTopic(title: "🔄 Les verbes modaux", content: "Dovere (devoir): devo, devi, deve, dobbiamo, dovete, devono\nPotere (pouvoir): posso, puoi, può, possiamo, potete, possono\nVolere (vouloir): voglio, vuoi, vuole, vogliamo, volete, vogliono\nExemple: Devo andare (Je dois aller)"),
        GrammarTopic(title: "✨ L'accord des adjectifs", content: "Les adjectifs s'accordent en genre et nombre:\nbello/bella/belli/belle (beau/belle/beaux/belles)\ngrande → grandi (grand/grands)\nExemple: una bella ragazza, dei ragazzi belli"),
        GrammarTopic(title: "❓ Les interrogatifs", content: "Chi? (Qui?), Che/Che cosa? (Quoi?), Dove? (Où?)\nQuando? (Quand?), Perché? (Pourquoi?), Come? (Comment?)\nQuanto/a/i/e? (Combien?)\nExemple: Dove vai? (Où vas-tu?)"),
        GrammarTopic(title: "⏰ Les temps composés", content: "Passé composé = auxiliaire (avere/essere) + participe passé\navere: ho mangiato (j'ai mangé)\nessere: sono andato/a (je suis allé/e)\nVerbes de mouvement utilisent 'essere'"),
        GrammarTopic(title: "🔊 L'impératif", content: "Tu: Mangia! (Mange!), Parla! (Parle!)\nLei (formel): Mangi! (Mangez!), Parli! (Parlez!)\nNoi: Mangiamo! (Mangeons!)\nVoi: Mangiate! (Mangez!)\nExemple: Vieni qui! (Viens ici!)"),
        GrammarTopic(title: "↔️ Le comparatif", content: "più... di (plus... que): più grande di (plus grand que)\nmeno... di (moins... que): meno caro di (moins cher que)\ncome/quanto (aussi... que): bello come (aussi beau que)\nExemple: Roma è più grande di Firenze"),
        GrammarTopic(title: "Les verbes réguliers", content: "Les verbes réguliers se conjuguent en ajoutant les terminaisons suivantes:\n-are: amo, ami, ama, amiamo, amate, amano\n-ere: vedo, vedi, vede, vediamo, vedete, vedono\n-ire: finisco, finisci, finisce, finiamo, finite, finiscono"),
        GrammarTopic(title: "Les verbes irréguliers", content: "Les verbes irréguliers ont des conjugaisons particulières:\nandare (aller): vado, vai, va, andiamo, andate, vanno\nfare (faire): faccio, fai, fa, facciamo, fate, fanno"),
        GrammarTopic(title: "Les verbes réfléchis", content: "Les verbes réfléchis se conjuguent avec le pronom réfléchi:\nlavarsi (se laver): mi lavo, ti lavi, si lava, ci laviamo, vi lavate, si lavano"),
        GrammarTopic(title: "Les verbes pronominaux", content: "Les verbes pronominaux se conjuguent avec le pronom personnel:\nappoggiarsi (s'appuyer): mi appoggio, ti appoggi, si appoggia, ci appoggiamo, vi appoggiate, si appoggiano")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(grammarTopics) { topic in
                    GrammarTopicCard(topic: topic)
                }
            }
            .padding()
        }
        .navigationTitle("Grammaire")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct GrammarTopic: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

struct GrammarTopicCard: View {
    let topic: GrammarTopic
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(topic.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.secondary)
            }
            
            if isExpanded {
                Text(topic.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
    }
}

#Preview {
    NavigationView {
        GrammarView()
    }
}
