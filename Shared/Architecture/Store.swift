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
    static let timeDeltaFailure: Double = 0.025
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
//    var hasSeenIntro: Bool { get { false } set { _ = newValue } }
    let persistence: PersistenceController = .shared
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

    func shouldLevelUp(after result: PlayResult) -> Bool {
        let tries = result.level == 2 ? 1 : 5
        let last5 = results.suffix(tries).filter { $0.success && $0.level == result.level }
        return last5.count == tries && bestTimes[result.level + 1] == nil
    }

    func shouldMakeEasier(after result: PlayResult) -> Bool {
        results.suffix(3).filter { !$0.success && $0.time == result.time }.count == 3
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
    case normal(ScoreLine, Messages?)
    case menu([MenuEntry])
    case scoreboard

    static let mainMenu: ReadyState = .menu(apeMenu)
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

        case .tapScoreLine:
            guard case .ready = state.screen else { break }
            state.screen = .ready(.scoreboard)

        case .tapScoreboard(let line):
            guard case .ready(.scoreboard) = state.screen else { break }
            state.level = line.level
            state.time = line.time
            state.screen = .ready(.normal(.display, nil))

        case .tapMenuButton:
            guard case .ready = state.screen else { break }
            state.screen = .ready(.mainMenu)

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
                            state.screen = .ready(.normal(.display, .didReset))
                        case .shareScore:
                            UIPasteboard.general.string = state.bestTimes.shareString
                            state.screen = .ready(.normal(.display, .copied))
                        case .playIntro:
                            state.screen = .welcome
                        default:
                            state.screen = .ready(.normal(.display, nil))
                    }
                case .error:
                    state.screen = .ready(.normal(.display, nil))
            }

        case .tapShare:
            UIPasteboard.general.string = state.bestTimes.shareString
            state.screen = .ready(.normal(.display, .copied))

        case .finishedSplash:
            guard case .splash = state.screen else { break }
            if environment.hasSeenIntro {
                state.screen = .ready(.normal(.display, nil))
            } else {
                state.screen = .welcome
            }

        case .finishedIntro:
            guard case .welcome = state.screen else { break }
            state.screen = .ready(.normal(.display, nil))
            environment.hasSeenIntro = true

        case .finishedAbout:
            guard case .about = state.screen else { break }
            state.screen = .ready(.normal(.display, nil))

        case .tapBackground:
            switch state.screen {
                case .splash where environment.hasSeenIntro, .welcome where environment.hasSeenIntro, .ready(.menu), .ready(.scoreboard):
                    state.screen = .ready(.normal(.display, nil))
                case .ready(.normal(_, let messages?)) where messages.stay:
                    state.screen = .ready(.normal(.display, nil))
                default:
                    break
            }

        case .played(let result):
            guard case .playing = state.screen else { break }
            state.addResults([result])
            try? environment.persistence.save(result: result)

            if state.shouldLevelUp(after: result) {
                let level = state.level + 1
                state.screen = .ready(.normal(.levelUp(oldLevel: state.level), .levelUp(level)))
                state.level = level
            } else if result.success {
                state.screen = .ready(.normal(.success(oldTime: state.time), .success()))
                state.time -= max(0.01, state.time * Constants.timeDeltaSuccess)
            } else if state.shouldMakeEasier(after: result) {
                state.screen = .ready(.normal(.failure(oldTime: state.time), .easier))
                state.time += max(0.01, state.time * Constants.timeDeltaFailure)
            } else {
                state.screen = .ready(.normal(.failure(oldTime: state.time), .tryAgain))
            }
    }
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