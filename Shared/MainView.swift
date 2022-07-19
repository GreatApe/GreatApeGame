//
//  MainView.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 17/02/2022.
//

import SwiftUI

extension Store {
    subscript(action: AppAction) -> () -> Void {
        { [weak self] in self?.send(action) }
    }

//    subscript<T>(function: @escaping (T) -> AppAction) -> (T) -> Void {
//        { [weak self] in self?.send(function($0)) }
//    }
}

struct MainView: View {
    @EnvironmentObject private var store: Store

    let size: CGSize

    var body: some View {
        switch store.state.screen {
            case .splash:
                SplashScreen(vm: splashVM)
                    .transition(.retro)
            case .welcome:
                WelcomeScreen(vm: welcomeVM)
                    .transition(.retro)
            case .about:
                AboutScreen(vm: aboutVM)
                    .transition(.retro)
            case .ready(let state):
                ReadyScreen(vm: readyVM(state: state))
                    .transition(.retro)
            case .playing:
                PlayScreen(vm: playVM)
                    .transition(.retro)
        }
    }

    private var splashVM: SplashScreen.ViewModel {
        .init(tapBackground: store[.tapBackground],
              finished: store[.finishedSplash]
        )
    }

    private var welcomeVM: WelcomeScreen.ViewModel {
        .init(tapBackground: store[.tapBackground],
              finished: store[.finishedIntro]
        )
    }

    private var aboutVM: AboutScreen.ViewModel {
        .init(finished: store[.finishedAbout],
              tapLink: { store.send(.tapAboutMenu($0)) })
    }

    private func readyVM(state: ReadyState) -> ReadyScreen.ViewModel {
        .init(size: size,
              state: state,
              level: store.state.level,
              time: store.state.time,
              achievedTime: store.state.achievedTime,
              scoreboardLines: store.state.scoreboardLines,
              hasFinishedARound: store.state.hasFinishedRound,
              tapScoreLine: store[.tapScoreLine],
              tapShare: store[.tapShare],
              tapGameCenter: store[.tapGameCenter],
              tapScoreboard: { store.send(.tapScoreboard($0)) },
              tapMenu: { store.send(.tapMenu($0)) },
              tapBackground: store[.tapBackground],
              tapRing: store[.tapRing],
              tapMenuButton: store[.tapMenuButton],
              tappedAd: { store.send(.tappedAd($0)) })
    }

    private var playVM: PlayScreen.ViewModel {
        .init(size: size,
              level: store.state.level,
              time: store.state.time,
              played: { store.send(.played($0)) })
    }
}
