//
//  ReadyView.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import SwiftUI

struct ReadyView: View {
    let vm: ViewModel

    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .onTapGesture(perform: vm.tapBackground)
                .gesture(dragGesture)
            MultiLineView(lines: vm.menuItems, action: vm.tapMenu, contents: MenuText.init)
            ScoreboardView(vm: scoreboardVM)

            if let scoreVM = scoreVM {
                Group {
                    MenuButton(side: vm.buttonSize, action: vm.tapMenuButton)
                        .position(vm.menuButtonPosition)
                    RingButton(ringSize: vm.buttonSize, action: vm.tapRing)
                        .position(vm.readyButtonPosition)

                    if !vm.hideScore {
                        Button(action: vm.tapScoreLine) {
                            ScoreView(vm: scoreVM)
                        }
                        .frame(height: vm.size.height, alignment: .top)
                    }
                }
                .transition(.retro)
            }
        }
    }

    @GestureState private var dragOffset: CGFloat = 0

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .updating($dragOffset) { value, state, transaction in
                vm.swipe(value.translation.height - state)
                state = value.translation.height
            }
    }

    private var scoreVM: ScoreView.ViewModel? {
        guard case .normal(let scoreLine) = vm.state else { return nil }
        return .init(level: vm.level,
                     time: vm.time,
                     scoreLine: scoreLine,
                     achievedTime: vm.achievedTime)
    }

    private var scoreboardVM: ScoreboardView.ViewModel {
        .init(level: vm.level,
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
        let tapScoreLine: () -> Void
        let tapScoreboard: (ScoreboardLine) -> Void
        let tapMenu: (MenuItem) -> Void
        let tapBackground: () -> Void
        let swipe: (CGFloat) -> Void
        let tapRing: () -> Void
        let tapMenuButton: () -> Void

        var menuItems: [MenuItem] {
            guard case .menu(let entries) = state else { return [] }
            return entries.map(\.item)
        }

        var scoreboard: [ScoreboardLine] { state == .scoreboard && !hideScore ? scoreboardLines : [] }

        var hideScore: Bool { !scoreboardLines.contains(where: \.achieved) }

        var menuButtonPosition: CGPoint { insetRect[.bottomTrailing] }
        var readyButtonPosition: CGPoint { insetRect[.bottomLeading] }
        var buttonSize: CGFloat { size.smallerSide * Constants.shapeSize }

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
