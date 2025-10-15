//
//  CompletedLesson.swift
//  MoveUp
//
//  Created by iOS Developer on 30/12/24.
//

import Foundation

struct CompletedLesson: Identifiable, Codable {
    let id = UUID()
    let lessonId: String
    let title: String
    let instructor: String
    let completedDate: Date
    let rating: Int
    let notes: String?
    let sport: String
    let duration: Int // in minutes
    let pointsEarned: Int
}

extension CompletedLesson {
    static let sampleLessons = [
        CompletedLesson(
            lessonId: "lesson_1",
            title: "Tennis Base - Diritto",
            instructor: "Marco Santini",
            completedDate: Date().addingTimeInterval(-86400 * 2),
            rating: 5,
            notes: "Ottima lezione, tecnica migliorata molto!",
            sport: "Tennis",
            duration: 60,
            pointsEarned: 100
        ),
        CompletedLesson(
            lessonId: "lesson_2",
            title: "Fitness - Allenamento HIIT",
            instructor: "Laura Bianchi",
            completedDate: Date().addingTimeInterval(-86400 * 5),
            rating: 4,
            notes: "Intenso ma molto efficace",
            sport: "Fitness",
            duration: 45,
            pointsEarned: 80
        ),
        CompletedLesson(
            lessonId: "lesson_3",
            title: "Nuoto - Stile Libero Avanzato",
            instructor: "Andrea Moro",
            completedDate: Date().addingTimeInterval(-86400 * 7),
            rating: 5,
            notes: nil,
            sport: "Nuoto",
            duration: 50,
            pointsEarned: 90
        )
    ]
}