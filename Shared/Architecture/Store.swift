//
//  Store.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 18/02/2022.
//

import Foundation
import SwiftUI
import Combine

enum Constants {
    static let rows: Int = 7
    static let columns: Int = 10
    static let margin: CGFloat = 0.14
    static let controlSize: CGFloat = 0.14
    static let startLevel: Int = 2
    static let startTime: Double = 1
    static let timeDeltaSuccess: Double = 0.05
    static let timeDeltaEasier: Double = 0.05
    static let timeDeltaEasierStill: Double = 0.1
}

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

class AppEnvironment {
    @UserDefault(key: "hasSeenIntro", defaultValue: false) var hasSeenIntro: Bool
    @UserDefault(key: "helpMessagesLeft", defaultValue: HelpType.allCases.map(\.rawValue)) private var helpMessagesLeft: [HelpType.RawValue]
    let persistence: PersistenceController = .shared

    var firstRemainingHelp: HelpType? {
        helpMessagesLeft.first.flatMap(HelpType.init)
    }

    func shiftRemainingHelp() {
        helpMessagesLeft = helpMessagesLeft.shifted()
        print("Shifed: \(helpMessagesLeft.compactMap(HelpType.init))")
    }

    func removeHelpMessage(_ type: HelpType) {
        helpMessagesLeft.remove(type.rawValue)
        print("REMOVED \(type)")
    }

    func helpMessageRemains(_ type: HelpType) -> Bool {
        helpMessagesLeft.contains(type.rawValue)
    }

    var adInfos: [AdInfo]

    init() {
        let strings = ["You like podcasts?", "You'll love KeepTalking", "The social network about podcasts", "Tap to reserve your @username"]
        self.adInfos = [.init(strings: strings, url: "https://keeptalking.fm")]

        helpMessagesLeft = HelpType.allCases.map(\.rawValue)
        hasSeenIntro = false
    }
}

enum AppAction {
    case startup

    // Ready
    case tapRing
    case tapMenuButton
    case tapScoreLine
    case tapShare
    case tapScoreboard(ScoreboardLine)
    case tapMenu(MenuItem)

    case finishedSplash
    case finishedIntro
    case finishedAbout

    case tapAboutMenu(AboutLink)
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
        results.filter(\.success).count > 10 && Int.random(in: 0..<10) == 0
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
        case welcome
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

    static let mainMenu: ReadyState = .menu(apeMenu)
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
    case gameCenter
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

        case .tapRing:
            guard case .ready = state.screen else { break }
            state.screen = .playing
            environment.removeHelpMessage(.ring)

        case .tapScoreLine:
            guard case .ready = state.screen else { break }
            state.screen = .ready(.scoreboard)
            environment.removeHelpMessage(.scoreboard)

        case .tapScoreboard(let line):
            guard case .ready(.scoreboard) = state.screen else { break }
            state.level = line.level
            state.time = line.time
            state.screen = .ready(.standard)
            environment.removeHelpMessage(.levelChange)

        case .tapMenuButton:
            guard case .ready = state.screen else { break }
            state.screen = .ready(.mainMenu)
            environment.removeHelpMessage(.menuButton)

        case .tapMenu(let item):
            guard case .ready(.menu(let entries)) = state.screen else { break }

            switch entries.row(with: item) {
                case .subMenu(let newEntries):
                    state.screen = .ready(.menu(newEntries))
                case .action(let item):
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
                        case .playIntro:
                            state.screen = .welcome
                        default:
                            state.screen = .ready(.standard)
                    }
                case .error:
                    state.screen = .ready(.standard)
            }

        case .tapShare:
            UIPasteboard.general.string = state.bestTimes.shareString
            state.screen = .ready(.normal(.display, .copied, nil))

        case .finishedSplash:
            guard case .splash = state.screen else { break }
            if environment.hasSeenIntro {
                state.screen = .ready(.standard)
            } else {
                state.screen = .welcome
            }

        case .finishedIntro:
            guard case .welcome = state.screen else { break }
            environment.hasSeenIntro = true
            if environment.helpMessageRemains(.ring) {
                state.screen = .ready(.normal(.display, nil, .help(.ring)))
            } else {
                state.screen = .ready(.standard)
            }

        case .finishedAbout:
            guard case .about = state.screen else { break }
            state.screen = .ready(.standard)

        case .tapBackground:
            switch state.screen {
                case .splash where environment.hasSeenIntro, .welcome where environment.hasSeenIntro, .ready(.menu), .ready(.scoreboard):
                    state.screen = .ready(.standard)
                case .ready(.normal(_, let messages?, _)) where messages.stay:
                    state.screen = .ready(.standard)
                default:
                    break
            }

        case .played(let result):
            guard case .playing = state.screen else { break }
            state.addResults([result])
            try? environment.persistence.save(result: result)

            func bottomMessage() -> BottomMessage? {
                if state.shouldShowHelp(), let help = environment.firstRemainingHelp {
                    environment.shiftRemainingHelp()
                    return .help(help)
                } else if state.shouldShowAd(), let adInfo = environment.adInfos.randomElement() {
                    return .ad(adInfo)
                }
                return nil
            }

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

        case .tapAboutMenu(let link):
            let urlString: String
            switch link {
                case .kpri:
                    urlString = "https://www.kyoto-u.ac.jp/en/research/fields/research-institutes/primate-research-institute-pri"
                case .ayumu:
                    urlString = "https://www.pri.kyoto-u.ac.jp/sections/langint/ai/en/friends/ayumu.html"
                case .unfairAdvantage:
                    urlString = "https://unfair.me"
            }
            guard let url = URL(string: urlString) else { return }
            openLink(url: url)
        case .tappedAd(let url):
            openLink(url: url)
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
