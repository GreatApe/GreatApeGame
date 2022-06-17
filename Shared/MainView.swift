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
            case .welcome:
                WelcomeView()
            case .ready(let state):
                ReadyView(vm: readyVM(state: state))
                    .transition(.retro)
            case .playing:
                PlayView(vm: playVM)
                    .transition(.retro)
        }
    }

    private func readyVM(state: ReadyState) -> ReadyView.ViewModel {
        .init(size: size,
              state: state,
              level: store.state.level,
              time: store.state.time,
              achievedTime: store.state.achievedTime,
              scoreboardLines: store.state.scoreboardLines,
              tapScoreLine: store[.tapScoreLine],
              tapShare: store[.tapShare],
              tapScoreboard: { store.send(.tapScoreboard($0)) },
              tapMenu: { store.send(.tapMenu($0)) },
              tapBackground: store[.tapBackground],
              swipe: { store.send(.swipe($0)) },
              tapRing: store[.tapRing],
              tapMenuButton: store[.tapMenuButton])
    }

    private var playVM: PlayView.ViewModel {
        .init(size: size,
              level: store.state.level,
              time: store.state.time,
              played: { store.send(.played($0)) })
    }
}

struct WelcomeView: View {
    @EnvironmentObject private var store: Store
    @State private var didShowVideo: Bool = false

    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .onTapGesture { store.send(.tapBackground) }
            MessagesView(vm: introVM)
                .disabled(true)
        }
    }

    private var introVM: MessagesView.ViewModel {
        .init(strings: ["Hello", "How are you"], delay: 0, stay: true)
    }
}
