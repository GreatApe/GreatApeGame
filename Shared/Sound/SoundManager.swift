//
//  SoundManager.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 24/07/2022.
//

import AVFoundation

class SoundManager {
    private var player: AVAudioPlayer? = nil

    static let shared = SoundManager()

    func start() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

        } catch {
            print("Failed to start SoundManager \(error)")
        }
    }

    func stop() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to start stop \(error)")
        }
    }

    func play(_ effect: SoundEffect) {
        guard let url = Bundle.main.url(forResource: Self.file(effect: effect).name, withExtension: "mp3") else { return }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.prepareToPlay()
        player.play()
        self.player = player
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
            case .shortenTime:
                return .gameWin
            case .openMenu:
                return .screenSwipe
            case .selectAction:
                return .selectAButton
        }
    }
}

enum SoundEffect {
    case greatApeLetter
    case tapGeneric
    case tapLastBoxSuccess
    case tapLastBoxFailure
    case levelUp
    case shortenTime
    case openMenu
    case selectAction
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
