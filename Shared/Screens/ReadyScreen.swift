//
//  ReadyScreen.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import SwiftUI

struct ReadyScreen: View {
    let vm: ViewModel

    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .onTapGesture(perform: vm.tapBackground)
            MultiLineView(lines: vm.menuItems, action: vm.tapMenu, contents: MenuText.init)
            scoreBoard
            message
            controls
        }
    }

    // View components

    @ViewBuilder
    private var scoreBoard: some View {
        ScoreboardView(vm: scoreboardVM)
        if vm.showScoreboardButtons {
            HStack {
                Spacer()
                VStack {
                    Button(action: vm.tapShare) {
                        Image(systemName: "square.and.arrow.up")
                            .retro()
                            .padding()
                    }
//                    Button(action: vm.tapGameCenter) {
//                        Image(systemName: "gamecontroller")
//                            .retro()
//                            .padding()
//                    }
                }
            }
            .transition(.retro(2))
            .ape(style: .largeText)
        }
    }

    @ViewBuilder
    private var message: some View {
        if let messageVM = messageVM {
            MessagesView(vm: messageVM)
                .frame(width: 0.75 * vm.size.width)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var controls: some View {
        if messageVM?.stay != true, let scoreVM = scoreVM {
            Group {
                RingButton(ringSize: vm.buttonSize, action: vm.tapRing)
                    .position(vm.readyButtonPosition)
                if vm.hasFinishedARound {
                    MenuButton(side: vm.buttonSize, action: vm.tapMenuButton)
                        .position(vm.menuButtonPosition)
                    if let bottomVM = bottomVM {
                        BottomMessageView(vm: bottomVM)
                            .padding(.horizontal, vm.buttonSize + 50)
                            .position(vm.adTextPosition)
                    }
                    Button(action: vm.tapScoreLine) {
                        ScoreView(vm: scoreVM)
                    }
                    .frame(height: vm.size.height, alignment: .top)
                }
            }
            .transition(.retro)
        }
    }

    // View helpers

    private var scoreVM: ScoreView.ViewModel? {
        guard case .normal(let scoreLine, _, _) = vm.state else { return nil }
        return .init(level: vm.level,
                     time: vm.time,
                     scoreLine: scoreLine,
                     achievedTime: vm.achievedTime)
    }

    private var messageVM: MessagesView.ViewModel? {
        guard case .normal(_, let message?, _) = vm.state else { return nil }
        return message
    }

    private var bottomVM: BottomMessageView.ViewModel? {
        guard case .normal(_, _, let message?) = vm.state else { return nil }
        switch message {
            case .ad(let adInfo):
                return .init(labels: adInfo.strings, url: adInfo.url, stay: true, tappedAd: vm.tappedAd)
            case .help(let type):
                return .init(labels: [.helpMessage(type)], url: nil, stay: false, tappedAd: nil)
        }
    }

    private var scoreboardVM: ScoreboardView.ViewModel {
        .init(size: vm.size,
              level: vm.level,
              scoreboard: vm.scoreboard,
              tapScoreboard: vm.tapScoreboard,
              tapBackground: vm.tapBackground)
    }

    struct ViewModel {
        let size: CGSize
        let state: ReadyState
        let level: Int
        let time: Double
        let achievedTime: Bool
        let scoreboardLines: [ScoreboardLine]
        let hasFinishedARound: Bool
        let tapScoreLine: () -> Void
        let tapShare: () -> Void
        let tapGameCenter: () -> Void
        let tapScoreboard: (ScoreboardLine) -> Void
        let tapMenu: (MenuItem) -> Void
        let tapBackground: () -> Void
        let tapRing: () -> Void
        let tapMenuButton: () -> Void
        let tappedAd: (URL) -> Void

        var menuItems: [MenuItem] {
            guard case .menu(let entries) = state else { return [] }
            return entries.map(\.item)
        }
        var showScoreboard: Bool { state == .scoreboard && hasFinishedARound }
        var showScoreboardButtons: Bool { showScoreboard && scoreboardLines.count >= 3 }

        var scoreboard: [ScoreboardLine] { showScoreboard ? scoreboardLines : [] }

        var menuButtonPosition: CGPoint { insetRect[.bottomTrailing] }
        var readyButtonPosition: CGPoint { insetRect[.bottomLeading] }
        var adTextPosition: CGPoint { insetRect[.bottom] }

        var buttonSize: CGFloat { size.smallerSide * Constants.controlSize }

        private var insetRect: CGRect { .init(origin: .zero, size: size).insetBy(dx: buttonMargin, dy: buttonMargin) }
        private var buttonMargin: CGFloat { size.smallerSide * buttonMarginRatio }
        private let buttonMarginRatio: CGFloat = 0.13

        static func text(for menuItem: MenuItem) -> Text {
            switch menuItem {
                case .about:
                    return Text("About")
                case .playIntro:
                    return Text("Play intro")
                case .shareScore:
                    return Text("Share my score")
                case .reset:
                    return Text("Reset scores")
                case .gamecenter:
                    return Text("GameCenter")
                case .reallyReset:
                    return Text("Reset all my scores")
                case .cancelReset:
                    return Text("Cancel")
            }
        }
    }
}

struct MenuButton: View {
    let side: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: spacing) {
                Rectangle()
                Rectangle()
                Rectangle()
            }
            .foregroundColor(.white)
            .frame(width: side, height: side)
            .retro()
            .padding(0.5 * side)
            .contentShape(Rectangle())
        }
    }

    var spacing: CGFloat {
        0.2 * side
    }
}

struct RingButton: View {
    let ringSize: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .stroke(.white, lineWidth: ringSize * ringWidthRatio)
                .frame(width: ringSize, height: ringSize)
                .retro()
                .padding(0.5 * ringSize)
                .contentShape(Rectangle())
        }
    }

    private let ringWidthRatio: CGFloat = 0.14
}

struct BottomMessageView: View {
    let vm: ViewModel

    var body: some View {
        if let urlString = vm.url, let url = URL(string: urlString), let action = vm.tappedAd {
            Button {
                action(url)
            } label: {
                text
            }
        } else {
            text
        }
    }

    private var text: some View {
        TimeStack(forEach: vm.labels, configuration: vm.config, animator: MessageFade.self) { label in
            Text(label)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .retro()
        }
        .ape(style: .ad)
    }

    struct ViewModel {
        let labels: [String]
        let url: String?
        let stay: Bool
        let tappedAd: ((URL) -> Void)?

        var config: Aneem.Timing.Configuration { .init(delay: 5, duration: stay ? 2.5 : 5, rampTime: 0.3, join: .juxtapose, stay: stay) }
    }
}
