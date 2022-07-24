//
//  SoundManager.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 24/07/2022.
//

import AVFoundation

enum SoundEffect: String, CaseIterable {
    case greatApeLetter
    case tapGeneric
    case tapLastBoxSuccess
    case tapLastBoxFailure
    case levelUp
    case gameSuccess
    case openMenu
    case selectAction

    var id: SoundIdentifier {
        rawValue
    }
}

enum SoundEffectFile: String {
    case successButton = "success_button"

    case bananaUp = "banana_up"
    case bananaDown = "banana_down"

    case unlock = "unlock"
    case gameWin = "game_win"

    case screenSwipe = "screen_swipe"
    case selectAButton = "select_a_button"

    var name: String {
        rawValue
    }
}

extension Starling {
    func load(_ effect: SoundEffect) {
        load(resource: Starling.file(effect: effect).name, type: "mp3", for: effect.id)
    }

    func play(_ effect: SoundEffect) {
        play(effect.id)
    }

    private static func file(effect: SoundEffect) -> SoundEffectFile {
        switch effect {
            case .greatApeLetter:
                return .successButton
            case .tapGeneric:
                return .successButton
            case .tapLastBoxSuccess:
                return .bananaUp
            case .tapLastBoxFailure:
                return .bananaDown
            case .levelUp:
                return .unlock
            case .gameSuccess:
                return .gameWin
            case .openMenu:
                return .screenSwipe
            case .selectAction:
                return .selectAButton
        }
    }
}
