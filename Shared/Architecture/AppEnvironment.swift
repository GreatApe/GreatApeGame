//
//  AppEnvironment.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 23/07/2022.
//

import Foundation
import GameKit

class AppEnvironment {
    @UserDefault(key: "hasSeenIntro", defaultValue: false) var hasSeenIntro: Bool
    @UserDefault(key: "helpMessagesLeft", defaultValue: HelpType.allCases.map(\.rawValue)) private var helpMessagesLeft: [HelpType.RawValue]
    let persistence: PersistenceController = .shared

    var firstRemainingHelp: HelpType? {
        helpMessagesLeft.first.flatMap(HelpType.init)
    }

    func shiftRemainingHelp() {
        helpMessagesLeft = helpMessagesLeft.shifted()
    }

    func removeHelpMessage(_ type: HelpType) {
        helpMessagesLeft.remove(type.rawValue)
    }

    func helpMessageRemains(_ type: HelpType) -> Bool {
        helpMessagesLeft.contains(type.rawValue)
    }

    var adInfos: [AdInfo]

    init() {
        let strings = ["You like podcasts?", "You'll love KeepTalking", "The social network about podcasts", "Tap to reserve your @username"]
        self.adInfos = [.init(strings: strings, url: "https://keeptalking.fm")]

        //        helpMessagesLeft = HelpType.allCases.map(\.rawValue)
        //        hasSeenIntro = false
    }
}
