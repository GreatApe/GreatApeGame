//
//  SoundManager.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 24/07/2022.
//

import AVFoundation
import CoreHaptics

class LoopPlayer {
    enum LoopPlayerError: Error { case missingFile }

    private let player: AVAudioPlayer?

    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            self.player = Self.createPlayer()
        } catch {
            print("Failed to start SoundManager \(error)")
            self.player = nil
            return
        }
    }

    func play() {
        player?.play()
    }

    func stop() {
        player?.stop()
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to start stop \(error)")
        }
    }

    private static func createPlayer() -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: "game_loop_v1", withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return nil }

        player.numberOfLoops = -1

        return player
    }
}

enum SoundFile: String, CaseIterable {
    case bananaUp = "banana_up"
    case bananaDown = "banana_down"

    case gameWin = "game_win"

    case screenSwipe = "screen_swipe"
    case selectAButton = "select_a_button"

    case successButton = "success_button"
    case screenSwipe2 = "screen_swipe_v2"

    var name: String {
        rawValue
    }
}

class Haptics {
    enum Effect: Hashable, CaseIterable {
        case showLogo
        case showAllLetters
        case success
        case failure
        case openMenu
        case selectAction
    }

    enum HapticsError: Error {
        case missingAudioFile
    }

    private let engine: CHHapticEngine?

    private var audioResources: [SoundFile: CHHapticAudioResourceID] = [:]

    static let shared = Haptics()

    private var clickPlayer: CHHapticPatternPlayer? = nil

    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            self.engine = nil
            print("Haptics not supported on hardware")
            return
        }

        do {
            let engine = try CHHapticEngine()
            engine.isAutoShutdownEnabled = true
            self.engine = engine
        } catch {
            print("Haptic engine Creation Error: \(error)")
            self.engine = nil
        }
    }

    func start() {
        do {
            try engine?.start()
            for file in SoundFile.allCases {
                loadAudioResource(file: file)
            }
            try makeClickPlayer()
        } catch {
            print("Haptic engine failed to start: \(error)")
        }
    }

    private func loadAudioResource(file: SoundFile) {
        guard let path = Bundle.main.url(forResource: file.name, withExtension: "mp3") else { return }
        audioResources[file] = try? engine?.registerAudioResource(path)
    }

    func stop() {
        engine?.stop()
    }

    func playClick() {
        _ = try? clickPlayer?.start(atTime: CHHapticTimeImmediate)
    }

    func play(_ effect: Effect) {
        guard let engine = engine else { return }
        do {
            try engine.start()
            let pattern = try pattern(for: effect)
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play slice: \(error)")
        }
    }

    // Patterns

    private func makeClickPlayer() throws {
        let pattern = try clickPattern()
        clickPlayer = try engine?.makePlayer(with: pattern)
    }

    // Patterns

    private func clickPattern() throws -> CHHapticPattern {
        guard let id = audioResources[.successButton] else { throw HapticsError.missingAudioFile }
        let sound = CHHapticEvent(audioResourceID: id, parameters: [], relativeTime: 0)

        let click = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 1.0),
                .init(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0)

        return try CHHapticPattern(events: [click, sound], parameters: [])
    }

    private func pattern(for effect: Effect) throws -> CHHapticPattern {
        switch effect {
            case .showLogo: return try showLogoPattern()
            case .showAllLetters: return try showAllLettersPattern()
            case .success: return try successPattern()
            case .failure: return try failurePattern()
            case .openMenu: return try openMenuPattern()
            case .selectAction: return try selectActionPattern()
        }
    }

    private func showLogoPattern() throws -> CHHapticPattern {
        guard let id = audioResources[.screenSwipe2] else { throw HapticsError.missingAudioFile }
        let sound = CHHapticEvent(audioResourceID: id, parameters: [.init(parameterID: .audioVolume, value: 0.5)], relativeTime: 0)

        let burr = CHHapticEvent(eventType: .hapticContinuous,
                                 parameters: [.init(parameterID: .hapticSharpness, value: 1)],
                                 relativeTime: 0,
                                 duration: 0.73)

        let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
                                           controlPoints: [.init(relativeTime: 0, value: 0),
                                                           .init(relativeTime: 0.73, value: 0.5)],
                                           relativeTime: 0)

        return try CHHapticPattern(events: [sound, burr], parameterCurves: [curve])
    }

    private func showAllLettersPattern() throws -> CHHapticPattern {
        guard let id = audioResources[.screenSwipe] else { throw HapticsError.missingAudioFile }
        let sound = CHHapticEvent(audioResourceID: id, parameters: [.init(parameterID: .audioVolume, value: 0.5)], relativeTime: 0)

        let burr = CHHapticEvent(eventType: .hapticContinuous,
                                 parameters: [.init(parameterID: .hapticSharpness, value: 0.75)],
                                 relativeTime: 0,
                                 duration: 0.84)

        let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
                                           controlPoints: [.init(relativeTime: 0, value: 0),
                                                           .init(relativeTime: 0.64, value: 0.7),
                                                           .init(relativeTime: 0.84, value: 0.7)],
                                           relativeTime: 0)

        return try CHHapticPattern(events: [sound, burr], parameterCurves: [curve])
    }

    private func successPattern() throws -> CHHapticPattern {
        guard let id = audioResources[.bananaUp] else { throw HapticsError.missingAudioFile }
        let sound = CHHapticEvent(audioResourceID: id, parameters: [.init(parameterID: .audioVolume, value: 0.5)], relativeTime: 0)

        let burr = CHHapticEvent(eventType: .hapticContinuous,
                                 parameters: [.init(parameterID: .hapticSharpness, value: 0.9)],
                                 relativeTime: 0,
                                 duration: 0.42)

        let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
                                           controlPoints: [.init(relativeTime: 0, value: 0),
                                                           .init(relativeTime: 0.06, value: 0.5),
                                                           .init(relativeTime: 0.1, value: 0),
                                                           .init(relativeTime: 0.42, value: 1)],
                                           relativeTime: 0)

        return try CHHapticPattern(events: [sound, burr], parameterCurves: [curve])
    }

    private func failurePattern() throws -> CHHapticPattern {
        guard let id = audioResources[.bananaDown] else { throw HapticsError.missingAudioFile }
        let sound = CHHapticEvent(audioResourceID: id, parameters: [.init(parameterID: .audioVolume, value: 0.5)], relativeTime: 0)

        let burr = CHHapticEvent(eventType: .hapticContinuous,
                                 parameters: [.init(parameterID: .hapticSharpness, value: 0.3)],
                                 relativeTime: 0,
                                 duration: 1)

        let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
                                           controlPoints: [.init(relativeTime: 0, value: 1),
                                                           .init(relativeTime: 1, value: 0)],
                                           relativeTime: 0)

        return try CHHapticPattern(events: [sound, burr], parameterCurves: [curve])
    }

    private func openMenuPattern() throws -> CHHapticPattern {
        guard let id = audioResources[.screenSwipe] else { throw HapticsError.missingAudioFile }
        let sound = CHHapticEvent(audioResourceID: id, parameters: [.init(parameterID: .audioVolume, value: 0.5)], relativeTime: 0)

        let click = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 0.6),
                .init(parameterID: .hapticSharpness, value: 1)
            ],
            relativeTime: 0)

        return try CHHapticPattern(events: [click, sound], parameters: [])
    }

    private func selectActionPattern() throws -> CHHapticPattern {
        guard let id = audioResources[.selectAButton] else { throw HapticsError.missingAudioFile }
        let sound = CHHapticEvent(audioResourceID: id, parameters: [.init(parameterID: .audioVolume, value: 0.5)], relativeTime: 0)

        let click = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 0.6),
                .init(parameterID: .hapticSharpness, value: 0.8)
            ],
            relativeTime: 0)

        return try CHHapticPattern(events: [click, sound], parameters: [])
    }
}
