//
//  SoundManager.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 24/07/2022.
//

import AVFoundation

class Sounds {
    private var players: [Effect: AVAudioPlayer] = [:]

    static let shared = Sounds()

    func start(effects: [Effect]) {
        for effect in effects {
            players[effect] = Self.createPlayer(effect)
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true)

        } catch {
            print("Failed to start SoundManager \(error)")
        }
    }

    func prepare(_ effect: Effect) {
        players[effect]?.prepareToPlay()
    }

    func play(_ effect: Effect) {
        players[effect]?.play()
    }

    func stop() {
        players.removeAll()
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to start stop \(error)")
        }
    }

    private static func createPlayer(_ effect: Effect) -> AVAudioPlayer {
        guard let url = Bundle.main.url(forResource: file(effect: effect).name, withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return .init() }

        return player
    }

    private static func file(effect: Effect) -> File {
        switch effect {
            case .tapLastBoxSuccess:
                return .bananaUp
            case .tapLastBoxFailure:
                return .bananaDown
            case .levelUp:
                return .gameWin
            case .openMenu:
                return .screenSwipe
            case .selectAction:
                return .selectAButton
        }
    }

    enum Effect: String, CaseIterable, Hashable {
        case tapLastBoxSuccess
        case tapLastBoxFailure
        case levelUp
        case openMenu
        case selectAction
    }

    enum File: String {
        case bananaUp = "banana_up"
        case bananaDown = "banana_down"

        case gameWin = "game_win"

        case screenSwipe = "screen_swipe"
        case selectAButton = "select_a_button"

        var name: String {
            rawValue
        }
    }
}

import CoreHaptics

class Haptics {
    enum Effect: Hashable, CaseIterable {
        case click
        case success
        case failure
        case openMenu
        case selectAction
    }

    private let hapticEngine: CHHapticEngine?

    private var audioResources: [Effect: CHHapticAudioResourceID] = [:]

    static let shared = Haptics()

    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            self.hapticEngine = nil
            print("Haptics not supported on hardware")
            return
        }

        do {
            let hapticEngine = try CHHapticEngine()
            hapticEngine.isAutoShutdownEnabled = true
            try hapticEngine.start()
            self.hapticEngine = hapticEngine
        } catch {
            print("Haptic engine Creation Error: \(error)")
            self.hapticEngine = nil
        }

        for effect in Effect.allCases {
            audioResources[effect] = audioResource(for: effect)
        }
    }

    func prepare(_ effect: Effect) {
    }

    func play(_ effect: Effect) {
        guard let hapticEngine = hapticEngine else { return }

        do {
            try hapticEngine.start()
            let pattern = try Self.pattern(for: effect)
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play slice: \(error)")
        }
    }

    private func audioResource(for effect: Effect) -> CHHapticAudioResourceID? {
        guard let filename = Self.resourceFilename(for: effect),
              let path = Bundle.main.url(forResource: filename, withExtension: "mp3") else { return nil }

        return try? hapticEngine?.registerAudioResource(path)
    }

    private static func resourceFilename(for effect: Effect) -> String? {
        switch effect {
            case .click:
                return nil
            case .success:
                return nil
            case .failure:
                return nil
            case .openMenu:
                return nil
            case .selectAction:
                return nil
        }
    }

    // Patterns

    private static func pattern(for effect: Effect) throws -> CHHapticPattern {
        switch effect {
            case .click: return try clickPattern()
            case .success: return try successPattern()
            case .failure: return try failurePattern()
            case .openMenu: return try openMenuPattern()
            case .selectAction: return try selectActionPattern()
        }
    }

    private static func clickPattern() throws -> CHHapticPattern {
        let click = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 1.0),
                .init(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0)

        return try CHHapticPattern(events: [click], parameters: [])
    }

    private static func successPattern() throws -> CHHapticPattern {
        let click = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 1.0),
                .init(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0)

        return try CHHapticPattern(events: [click], parameters: [])
    }

    private static func failurePattern() throws -> CHHapticPattern {
        let click = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 1.0),
                .init(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0)

        return try CHHapticPattern(events: [click], parameters: [])
    }

    private static func openMenuPattern() throws -> CHHapticPattern {
        let click = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 1.0),
                .init(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0)

        return try CHHapticPattern(events: [click], parameters: [])
    }

    private static func selectActionPattern() throws -> CHHapticPattern {
        let click = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 1.0),
                .init(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0)

        return try CHHapticPattern(events: [click], parameters: [])
    }
}
