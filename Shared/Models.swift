//
//  Models.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import Foundation
import CoreGraphics

struct BoxModel: Identifiable, Equatable {
    let id = UUID()
    let number: Int
    let location: CGPoint
}

struct ScoreboardLine: Identifiable, Equatable {
    let level: Int
    let time: Double
    let achieved: Bool

    // Identifiable

    var id: Int { level }
}

typealias ScoreDictionary = [Int: Double]

extension ScoreDictionary {
    var score: Int {
        map(scoreContribution).reduce(0, +)
    }

    var ordered: [(level: Int, time: Double)] {
        sorted { $0.key < $1.key }
            .map { (level: $0.key, time: $0.value) }
    }

    var shareString: String {
        ordered.map(shareDescription).joined(separator: "\n") + "\ngreatapegame.com/\(score)bananas"
    }
}

func scoreContribution(level: Int, time: Double) -> Int {
    Int(round(Double(level * level) / time))
}

func shareDescription(level: Int, time: Double) -> String {
    String.boxLine(level, solid: true) + " " + time.timeString
}

extension Double {
    var timeString: String {
        formatted(.number.precision(.significantDigits(self < 0.1 ? 1 : 2))) + " s"
    }

    var animationTimeString: String {
        formatted(.number.precision(.significantDigits(self < 0.1 ? 1 : (self < 1 ? 2 : 3)))) + " s"
    }
}

