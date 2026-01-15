import Foundation
import SwiftUI

struct AssessmentQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
    let level: CEFRLevel
    let explanation: String
}

@Observable
final class LevelAssessmentService {
    
    var questions: [AssessmentQuestion] = []
    var currentQuestionIndex: Int = 0
    var userAnswers: [Int] = []
    var assessedLevel: CEFRLevel = .a1
    
    init() {
        generateQuestions()
    }
    
    func generateQuestions() {
        questions = [
            AssessmentQuestion(
                question: "Comment dit-on 'Bonjour' en italien ?",
                options: ["Arrivederci", "Buongiorno", "Grazie", "Prego"],
                correctAnswer: 1,
                level: .a1,
                explanation: "'Buongiorno' signifie 'Bonjour' en italien."
            ),
            
            AssessmentQuestion(
                question: "Complétez : 'Io ____ italiano.'",
                options: ["parla", "parlo", "parli", "parlano"],
                correctAnswer: 1,
                level: .a1,
                explanation: "La première personne du singulier de 'parlare' est 'parlo'."
            ),
            
            AssessmentQuestion(
                question: "Que signifie 'Mi piace la pizza' ?",
                options: ["Je déteste la pizza", "J'aime la pizza", "Je mange la pizza", "Je veux la pizza"],
                correctAnswer: 1,
                level: .a2,
                explanation: "'Mi piace' signifie 'j'aime' en italien."
            ),
            
            AssessmentQuestion(
                question: "Quel est le passé composé de 'andare' (1ère personne) ?",
                options: ["sono andato", "ho andato", "ero andato", "andrò"],
                correctAnswer: 0,
                level: .a2,
                explanation: "'Andare' utilise l'auxiliaire 'essere' au passé composé."
            ),
            
            AssessmentQuestion(
                question: "Choisissez la forme correcte : 'Se ____ tempo, verrei con te.'",
                options: ["ho", "avrò", "avessi", "avevo"],
                correctAnswer: 2,
                level: .b1,
                explanation: "Le conditionnel avec 'se' nécessite le subjonctif imparfait 'avessi'."
            ),
            
            AssessmentQuestion(
                question: "Que signifie 'Ne ho abbastanza' ?",
                options: ["J'en ai assez", "Je n'en ai pas", "J'en veux plus", "Je le comprends"],
                correctAnswer: 0,
                level: .b1,
                explanation: "'Ne ho abbastanza' est une expression idiomatique signifiant 'j'en ai assez'."
            ),
            
            AssessmentQuestion(
                question: "Transformez au discours indirect : Marco disse: 'Partirò domani.'",
                options: ["Marco disse che partirà domani", "Marco disse che sarebbe partito il giorno dopo", "Marco disse che partiva domani", "Marco disse che è partito domani"],
                correctAnswer: 1,
                level: .b2,
                explanation: "Le discours indirect nécessite le conditionnel passé et l'ajustement temporel."
            ),
            
            AssessmentQuestion(
                question: "Quelle phrase utilise correctement le subjonctif ?",
                options: ["Penso che lui è bravo", "Credo che lui sia bravo", "So che lui sia bravo", "Dico che lui sia bravo"],
                correctAnswer: 1,
                level: .b2,
                explanation: "'Credere che' requiert le subjonctif, contrairement à 'sapere che'."
            ),
            
            AssessmentQuestion(
                question: "Identifiez l'erreur : 'Benché ha studiato molto, non ha superato l'esame.'",
                options: ["Benché → Sebbene", "ha studiato → avesse studiato", "non ha → non avrebbe", "l'esame → gli esami"],
                correctAnswer: 1,
                level: .c1,
                explanation: "'Benché' requiert le subjonctif, donc 'avesse studiato' au lieu de 'ha studiato'."
            ),
            
            AssessmentQuestion(
                question: "Quelle nuance exprime 'Sarà pure bravo, ma non mi convince' ?",
                options: ["Certitude absolue", "Doute et concession", "Hypothèse future", "Souhait"],
                correctAnswer: 1,
                level: .c1,
                explanation: "'Sarà pure' exprime une concession avec une nuance de doute."
            )
        ]
    }
    
    func submitAnswer(_ answer: Int) {
        userAnswers.append(answer)
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func evaluateLevel() -> CEFRLevel {
        var correctByLevel: [CEFRLevel: Int] = [:]
        
        for (index, question) in questions.enumerated() {
            if index < userAnswers.count && userAnswers[index] == question.correctAnswer {
                correctByLevel[question.level, default: 0] += 1
            }
        }
        
        let _ = correctByLevel[.a1] ?? 0
        let a2Correct = correctByLevel[.a2] ?? 0
        let b1Correct = correctByLevel[.b1] ?? 0
        let b2Correct = correctByLevel[.b2] ?? 0
        let c1Correct = correctByLevel[.c1] ?? 0
        
        if c1Correct >= 2 {
            assessedLevel = .c1
        } else if b2Correct >= 2 {
            assessedLevel = .b2
        } else if b1Correct >= 2 {
            assessedLevel = .b1
        } else if a2Correct >= 2 {
            assessedLevel = .a2
        } else {
            assessedLevel = .a1
        }
        
        return assessedLevel
    }
    
    func getCorrectCount() -> Int {
        var count = 0
        for (index, question) in questions.enumerated() {
            if index < userAnswers.count && userAnswers[index] == question.correctAnswer {
                count += 1
            }
        }
        return count
    }
    
    func reset() {
        currentQuestionIndex = 0
        userAnswers = []
        assessedLevel = .a1
    }
}
