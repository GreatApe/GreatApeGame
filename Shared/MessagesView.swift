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
        TapStack(timings: timings) { time in
            ForEach(Array(vm.strings.enumerated()), id: \.offset) { (index, string) in
                Text(string)
                    .apeLarge
                    .animated(using: MessageFade.self, tag: index)
                    .retro()
            }
        }
        .delay(vm.delay)
    }

    private var timings: [Int: Timing] {
        var result: [Int: Timing] = [:]

        for index in vm.strings.indices {
            result[index] = .triangle(duration: vm.timePerMessage, relativePeak: 0.3)
                .start(at: vm.timePerMessage * Double(index))
                .stay(vm.stay && index == vm.strings.endIndex - 1)
        }
        
        return result
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
    var timePerMessage: Double = 2
    var stay: Bool = false

    static func success() -> Self {
        .init(strings: String.successStrings.randomElement().asArray)
    }

    static let tryAgain: Self = .init(strings: [.tryAgain])
    static let easier: Self = .init(strings: [.easier])
    static let scoreboard: Self = .init(strings: [.scoreboard])
    static let levelChange: Self = .init(strings: [.levelChange])
    static let copied: Self = .init(strings: [.copied])
    static let didReset: Self = .init(strings: [.didReset])

    static func levelUp(_ level: Int) -> Self {
        .init(strings: String.levelUp(boxes: level), delay: 1)
    }
}

extension String {
    static let welcome1 = "Are you smarter than a chimpanzee?"
    static let welcome2 = "Tap the boxes in order, once the numbers disappear"
    static let welcome3 = "Ayumu can do 10, how many can you handle?"

    static let successStrings = ["Awesome", "Fantastic", "Amazing", "Nice work", "Great!", "Not bad!", "Wonderful"]

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
