//
//  Store.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 18/02/2022.
//

import Foundation
import SwiftUI
import Combine

final class Store: ObservableObject {
    @Published var state: AppState = .init()
    let environment = AppEnvironment()

    private var bag: Set<AnyCancellable> = []

    func send(_ action: AppAction) {
        print("=====")
        print("Action: \(action)")
        reducer(&state, action: action, environment: environment)
        print("State: \(state)")
    }
}

enum AppAction {
    case startup
    case finish

    // Ready
    case tapRing
    case tapBox
    case tapMenuButton
    case tapScoreLine
    case tapShare
    case tapGameCenter
    case tapScoreboard(ScoreboardLine)
    case tapMenu(MenuItem)

    case finishedSplash
    case finishedIntro

    case tapNextAbout
    case finishedAbout
    case tapAboutLink(AboutLink)
    case tappedAd(URL)

    case tapBackground

    // Playing
    case played(PlayResult)
}

struct PlayResult {
    let level: Int
    let time: Double
    let missedBox: Int?
    let elapsed: Double

    var success: Bool {
        missedBox == nil
    }
}

struct AppState {
    private(set) var results: [PlayResult] = []
    private(set) var bestTimes: [Int: Double] = [:]

    var level: Int = Constants.startLevel
    var time: Double = Constants.startTime

    var screen: Screen = .splash

    // Computed

    var totalScore: Int {
        Int(ceil(bestTimes.reduce(0) { $0 + Double($1.key * $1.key) / $1.value }))
    }

    var achievedTime: Bool {
        guard let bestTime = bestTimes[level] else { return false }
        return bestTime <= time
    }

    var scoreboardLines: [ScoreboardLine] {
        let achieved = bestTimes.ordered.map { ScoreboardLine(level: $0.level, time: $0.time, achieved: true) }
        guard let last = achieved.last else { return [] }
        return achieved + [.init(level: last.level + 1, time: last.time, achieved: false)]
    }

    var hasFinishedRound: Bool {
        !bestTimes.isEmpty
    }

    func shouldShowHelp() -> Bool {
        Int.random(in: 0..<4) == 0
    }

    func shouldShowAd() -> Bool {
        true
//        results.filter(\.success).count > 20 && Int.random(in: 0..<50) == 0
    }

    func shouldMakeItEasier() -> Bool {
        results.suffix(3).allSatisfy { !$0.success && $0.time == results.last?.time }
    }

    func shouldMakeItEasierStill() -> Bool {
        results.suffix(6).allSatisfy { !$0.success }
    }

    func shouldLevelUp() -> Bool {
        guard let lastResult = results.last else { return false }
        let tries = lastResult.level == 2 ? 1 : 2 + lastResult.level
        let last5 = results.suffix(tries).filter { $0.success && $0.level == lastResult.level }
        return last5.count == tries && bestTimes[lastResult.level + 1] == nil
    }

    mutating func addResults(_ newResults: [PlayResult]) {
        results.append(contentsOf: newResults)

        for result in newResults.filter(\.success) {
            if let bestTime = bestTimes[result.level], bestTime < result.time { return }
            bestTimes[result.level] = result.time
        }
    }

    mutating func clearResults() {
        results = []
        bestTimes = [:]
    }

    mutating func setupLevelAndTime() {
        guard let latest = results.last else {
            level = Constants.startLevel
            time = Constants.startTime
            return
        }
        level = latest.level
        time = latest.time
    }

    enum Screen: Equatable {
        case splash
        case welcome(text: Bool)
        case ready(ReadyState)
        case about
        case playing
    }
}

enum ReadyState: Equatable {
    case normal(ScoreLine, Messages?, BottomMessage?)
    case menu([MenuEntry])
    case scoreboard

    static let standard: ReadyState = .normal(.display, nil, nil)
}

enum BottomMessage: Equatable {
    case help(HelpType)
    case ad(AdInfo)
}

enum HelpType: Int, Equatable, CaseIterable {
    case ring
    case menuButton
    case scoreboard
    case levelChange
//    case gameCenter
}

struct AdInfo: Equatable {
    let strings: [String]
    let url: String?
}

enum ScoreLine: Equatable {
    case display
    case failure(oldTime: Double)
    case success(oldTime: Double)
    case levelUp(oldLevel: Int)
}

private func reducer(_ state: inout AppState, action: AppAction, environment: AppEnvironment) {
    switch action {
        case .startup:
            if let results = try? environment.persistence.loadResults() {
                state.addResults(results)
                state.setupLevelAndTime()
            }
            Haptics.shared.start()

        case .finish:
            Haptics.shared.stop()

        case .tapRing:
            guard case .ready = state.screen else { break }
            state.screen = .playing
            environment.removeHelpMessage(.ring)
            Haptics.shared.playClick()

        case .tapBox:
            Haptics.shared.playClick()

        case .tapScoreLine:
            guard case .ready = state.screen else { break }
            state.screen = .ready(.scoreboard)
            environment.removeHelpMessage(.scoreboard)
            Haptics.shared.play(.openMenu)

        case .tapScoreboard(let line):
            guard case .ready(.scoreboard) = state.screen else { break }
            state.level = line.level
            state.time = line.time
            state.screen = .ready(.standard)
            environment.removeHelpMessage(.levelChange)
            Haptics.shared.play(.selectAction)

        case .tapMenuButton:
            guard case .ready = state.screen else { break }
            state.screen = .ready(.menu(mainMenu))
            environment.removeHelpMessage(.menuButton)
            Haptics.shared.play(.openMenu)

        case .tapMenu(let item):
            guard case .ready(.menu(let entries)) = state.screen else { break }

            switch entries.row(with: item) {
                case .subMenu(let newEntries):
                    state.screen = .ready(.menu(newEntries))
                    Haptics.shared.playClick()
                case .action(let item):
                    Haptics.shared.play(.selectAction)
                    switch item {
                        case .about:
                            state.screen = .about
                        case .reallyReset:
                            try? environment.persistence.resetResults()
                            state.clearResults()
                            state.setupLevelAndTime()
                            state.screen = .ready(.normal(.display, .didReset, nil))
                        case .shareScore:
                            UIPasteboard.general.string = state.bestTimes.shareString
                            state.screen = .ready(.normal(.display, .copied, nil))
                        case .gamecenter:
                            break // TODO: open gamecenter
                        case .playIntro:
                            state.screen = .welcome(text: false)
                        default:
                            state.screen = .ready(.standard)
                    }
                case .error:
                    state.screen = .ready(.standard)
            }

        case .tapShare:
            UIPasteboard.general.string = state.bestTimes.shareString
            state.screen = .ready(.normal(.display, .copied, nil))
            Haptics.shared.play(.selectAction)

        case .tapGameCenter:
            Haptics.shared.play(.selectAction)
            // TODO: open gamecenter

        case .finishedSplash:
            guard case .splash = state.screen else { break }
            if environment.hasSeenIntro {
                state.screen = .ready(.standard)
            } else {
                state.screen = .welcome(text: true)
            }

        case .finishedIntro:
            guard case .welcome = state.screen else { break }
            environment.hasSeenIntro = true
            if environment.helpMessageRemains(.ring) {
                state.screen = .ready(.normal(.display, nil, .help(.ring)))
            } else {
                state.screen = .ready(.standard)
            }

        case .tapNextAbout:
            Haptics.shared.playClick()

        case .finishedAbout:
            guard case .about = state.screen else { break }
            state.screen = .ready(.standard)

        case .tapBackground:
            switch state.screen {
                case .splash where environment.hasSeenIntro, .welcome where environment.hasSeenIntro:
                    state.screen = .ready(.standard)
                case .ready(.menu), .ready(.scoreboard):
                    state.screen = .ready(.standard)
                    Haptics.shared.playClick()
                case .ready(.normal(_, let messages?, _)) where messages.stay:
                    state.screen = .ready(.standard)
                    Haptics.shared.playClick()
                default:
                    break
            }

        case .played(let result):
            guard case .playing = state.screen else { break }
            state.addResults([result])
            try? environment.persistence.save(result: result)

            func bottomMessage() -> BottomMessage? {
                if state.shouldShowHelp(), let help = environment.firstRemainingHelp {
                    if help != .ring {
                        environment.shiftRemainingHelp()
                    }
                    return .help(help)
                } else if state.shouldShowAd(), let adInfo = environment.adInfos.randomElement() {
                    return .ad(adInfo)
                }
                return nil
            }

            Haptics.shared.play(result.success ? .success : .failure)

            if state.shouldLevelUp() {
                let level = state.level + 1
                state.screen = .ready(.normal(.levelUp(oldLevel: state.level), .levelUp(level), nil))
                state.level = level
            } else if result.success {
                state.screen = .ready(.normal(.success(oldTime: state.time), .success(), bottomMessage()))
                state.time -= max(0.01, state.time * Constants.timeDeltaSuccess)
            } else if state.shouldMakeItEasier() {
                state.screen = .ready(.normal(.failure(oldTime: state.time), .easier, nil))
                state.time += max(0.01, state.time * Constants.timeDeltaEasier)
            } else if state.shouldMakeItEasierStill() {
                state.screen = .ready(.normal(.failure(oldTime: state.time), .easier, nil))
                state.time += max(0.01, state.time * Constants.timeDeltaEasierStill)
            } else {
                state.screen = .ready(.normal(.failure(oldTime: state.time), .tryAgain, bottomMessage()))
            }

        case .tapAboutLink(let link):
            let urlString: String
            switch link {
                case .kpri:
                    urlString = "https://www.kyoto-u.ac.jp/en/research/fields/research-institutes/primate-research-institute-pri"
                case .ayumu:
                    urlString = "https://www.pri.kyoto-u.ac.jp/sections/langint/ai/en/friends/ayumu.html"
                case .greatApe:
                    urlString = "https://greatapegame.com/info"
                case .unfairAdvantage:
                    urlString = "https://unfair.me"
            }
            Haptics.shared.playClick()
            guard let url = URL(string: urlString) else { return }
            openLink(url: url)

        case .tappedAd(let url):
            openLink(url: url)
            Haptics.shared.playClick()
    }
}

private func openLink(url: URL) {
    UIApplication.shared.open(url)
}

// MARK: - CustomStringConvertible

extension AppState: CustomStringConvertible {
    var description: String {
        "\(level) \(time.timeString) s, \(screen)"
    }
}

extension AppState.Screen: CustomStringConvertible {
    var description: String {
        switch self {
            case .splash:
                return "splash"
            case .welcome:
                return "welcome"
            case .about:
                return "about"
            case .ready(let state):
                return "ready(\(state))"
            case .playing:
                return "playing"
        }
    }
}

extension ReadyState: CustomStringConvertible {
    var description: String {
        switch self {
            case .normal:
                return "normal"
            case .menu:
                return "menu"
            case .scoreboard:
                return "scoreboard"
        }
    }
}
