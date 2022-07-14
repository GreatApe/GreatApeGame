//
//  MessagesView.swift
//  GreatApeGame
//
//  Created by Gustaf Kugelberg on 17/06/2022.
//

import SwiftUI

struct MessagesView: View {
    let vm: ViewModel

    var body: some View {
        TimeStack(timings: .ordered(timings)) { time in
            ForEach(Array(vm.strings.enumerated()), id: \.offset) { (index, string) in
                Text(string)
                    .ape(style: .largeText)
                    .animated(using: MessageFade.self, tag: index)
                    .retro()
                    .border(.white)
            }
        }
    }

    private var timings: [Anim.Timing] {
        vm.strings.indices.map { index in
            let duration = vm.stay && index == vm.strings.endIndex - 1 ? .infinity : vm.timePerMessage
            return .show(from: vm.timePerMessage * Double(index) + vm.delay, for: duration)
        }
    }

    typealias ViewModel = Messages
}

extension Optional {
    var asArray: [Wrapped] {
        map { [$0] } ?? []
    }
}

struct Messages: Equatable {
    let strings: [String]
    var delay: Double = 0
    var timePerMessage: Double = 2.5
    var stay: Bool = false
    var small: Bool = false

    static func success() -> Self {
        .init(strings: String.successStrings.randomElement().asArray)
    }

    static let tryAgain: Self = .init(strings: [.tryAgain])
    static let easier: Self = .init(strings: [.easier])
    static let scoreboard: Self = .init(strings: [.scoreboard])
    static let levelChange: Self = .init(strings: [.levelChange])
    static let copied: Self = .init(strings: [.copied], stay: true)
    static let didReset: Self = .init(strings: [.didReset], stay: true)

    static func levelUp(_ level: Int) -> Self {
        .init(strings: String.levelUp(boxes: level), delay: 1)
    }
}

extension String {
    static let welcome1 = "Are you smarter than a chimpanzee?"
    static let welcome2 = "Tap the numbers in order, once they turn into boxes"
    static let welcome3 = "Ayumu can do 9, how many can you handle?"

    static let about = [
        "The Great Ape Game was conceived after a visit to the chimpanzees and researchers at the Kyoto Primate Research Institute",
        "Here the chimpanzee Ayumu lives in a beautiful tree filled facility with his friends, and volunteers in cognitive reasearch, only asking for fruit in return",
        "The clip in the intro shows how he quickly identifies and memorizes up to 9 numbers, after seeing them for less than a second",
        "We wanted to see how well human subjects perform on the same task, so we built this game. It turns out most people can't get past 5 or 6 numbers.",
        "Designed and developed by\n\nUnfair Advantage\nsales@unfair.me",
    ]

    static let successStrings = ["Awesome", "Fantastic", "Amazing", "Nice work", "Great!", "Not bad!", "Wonderful"]

    static let tryAgain = "Try again!"

    static let easier = "Let's make it easier"

    static let scoreboard = "Tap the score to see all your best times in the scoreboard"

    static let levelChange = "Tap a line on the scoreboard to try that level"

    static let copied = "Your best times have been copied to the clipboard"

    static let didReset = "All scores have been cleared"

    static func levelUp(boxes: Int) -> [String] {
        if boxes == 3 {
            return ["Good job!", "Now let's try with 3 boxes"]
        } else {
            return ["This is getting easy", "Let's try \(boxes) boxes"]
        }
    }
}
