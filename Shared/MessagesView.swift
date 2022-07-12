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
                    .ape(large: true)
                    .animated(using: MessageFade.self, tag: index)
                    .retro()
            }
        }
//        .animationRamping(.simple(0.6))
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
    static let copied: Self = .init(strings: [.copied], small: true)
    static let didReset: Self = .init(strings: [.didReset])

    static func levelUp(_ level: Int) -> Self {
        .init(strings: String.levelUp(boxes: level), delay: 1)
    }
}

extension String {
    static let welcome1 = "Are you smarter than a chimpanzee?"
    static let welcome2 = "Tap the boxes in order, once the numbers disappear"
    static let welcome3 = "Ayumu can do 10, how many can you handle?"

    static let about = [
        "The Great Ape Game was conceived after a visit to the chimpanzees and researchers at the Kyoto Primate Research Institute",
        "The chimpanzee Ayumu lives in a beautiful tree filled facility with his friends, and volunteers in cognitive reasearch",
        "A viral video shows how he quickly identifies and memorizes up to 9 numbers, that only flash very briefly",
        "We wanted to see how well human subjects perform on the same game, so we built this game",
        "Most people can't manage more than 5 numbers when times get below 0.5 s, what's _your_ records?",
        "Designed and developed by\n\nUnfair Advantage\n\nsales@unfair.me",
    ]

    static let about1 = "Are you smarter than a chimpanzee? Are you smarter than a chimpanzee? Are you smarter than a chimpanzee?"
    static let about2 = "Tap the boxes in order, once the numbers disappear Tap the boxes in order, once the numbers disappear Tap the boxes in order, once the numbers disappear"
    static let about3 = "Ayumu can do 10, how many can you handle? Ayumu can do 10, how many can you handle? Ayumu can do 10, how many can you handle?"
    static let about4 = "Are you smarter than a chimpanzee? Are you smarter than a chimpanzee? Are you smarter than a chimpanzee?"

    static let successStrings = ["Awesome", "Fantastic", "Amazing", "Nice work", "Great!", "Not bad!", "Wonderful"]

    static let tryAgain = "Try again!"

    static let easier = "Let's make it easier"

    static let scoreboard = "Tap the score to see all your best times in the scoreboard"

    static let levelChange = "Tap a line on the scoreboard to try that level"

    static let copied = "Your best times have been copied to the clipboard!"

    static let didReset = "All scores have been cleared"

    static func levelUp(boxes: Int) -> [String] {
        if boxes == 3 {
            return ["Good job!", "Now let's try with 3 boxes"]
        } else {
            return ["This is getting easy", "Let's try \(boxes) boxes"]
        }
    }
}
