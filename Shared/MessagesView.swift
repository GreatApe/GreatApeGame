//
//  MessagesView.swift
//  GreatApeGame
//
//  Created by Gustaf Kugelberg on 17/06/2022.
//

import SwiftUI

struct MessagesView: View {
    let vm: ViewModel
    @State private var start: Date = .now

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.25)) { context in
            let timePassed = context.date.timeIntervalSince(start) - epsilon
            ZStack {
                ForEach(Array(vm.strings.enumerated()), id: \.offset) { (index, string) in
                    MessageView(text: string, duration: vm.timePerMessage, phase: phase(for: index, after: timePassed))
                }
            }
        }
    }

    private func phase(for i: Int, after timePassed: Double) -> FadePhase {
        let stay = vm.stay && i == vm.strings.endIndex - 1
        return (timePassed - vm.delay) / vm.timePerMessage > Double(i) ? (stay ? .showing : .after) : .before
    }

    typealias ViewModel = Messages
    private let epsilon = 0.01
}

struct MessageView: View {
    let text: String
    let duration: Double
    let phase: FadePhase

    var body: some View {
        ApeText(verbatim: text)
            .messageFade(phase)
            .animation(.linear(duration: duration), value: phase)
            .retro()
    }
}

extension Optional {
    var asArray: [Wrapped] {
        map { [$0] } ?? []
    }
}

struct Messages: Equatable {
    let strings: [String]
    var delay: Double = 0
    var timePerMessage: Double = 2
    var stay: Bool = false

    static func success() -> Self {
        .init(strings: String.successStrings.randomElement().asArray)
    }

    static let tryAgain: Self = .init(strings: [.tryAgain])
    static let easier: Self = .init(strings: [.easier])
    static let scoreboard: Self = .init(strings: [.scoreboard])
    static let levelChange: Self = .init(strings: [.levelChange])
    static let copied: Self = .init(strings: [.copied], stay: true)
    static let didReset: Self = .init(strings: [.didReset])

    static func levelUp(_ level: Int) -> Self {
        .init(strings: String.levelUp(boxes: level), delay: 1, stay: false)
    }
}

extension String {
    static let welcome1 = "Are you smarter than a chimpanzee?"
    static let welcome2 = "Tap the numbers in order, like this"

    static let welcome3 = "Ayumu can do 10, how many can you handle?"



    static let successStrings = ["Awesome", "Fantastic", "Amazing", "Nice work", "Great!", "Not bad!"]

    static let tryAgain = "Try again!"

    static let easier = "Let's make it easier"

    static let scoreboard = "Tap the score to see all your best times in the scoreboard"

    static let levelChange = "Tap a line on the scoreboard to try that level"

    static let copied = "Your best times have been copied to the clipboard!"

    static let didReset = "All scores have been cleared"

    static let about = "Designed and developed by Unfair Advantage. sales@unfair.me"


    static func levelUp(boxes: Int) -> [String] {
        if boxes == 3 {
            return ["Good job!", "Now let's try with 3 boxes"]
        } else {
            return ["This is getting easy", "Let's try \(boxes) boxes"]
        }
    }
}
