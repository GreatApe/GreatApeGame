//
//  Scoreboard.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import SwiftUI

struct ScoreboardView: View {
    let vm: ViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                MultiLineView(lines: vm.scoreboard, action: vm.tapScoreboard, contents: ScoreboardLineView.init)
                    .retro()
            }
            .onTapGesture(perform: vm.tapBackground)
            .onChange(of: vm.scoreboard) { lines in
                guard !lines.isEmpty else { return }
                proxy.scrollTo(vm.level)
            }
            .mask {
                ScrollViewMask()
            }
        }
    }

    struct ViewModel {
        let level: Int
        let scoreboard: [ScoreboardLine]
        let tapScoreboard: (ScoreboardLine) -> Void
        let tapBackground: () -> Void
    }
}

struct ScrollViewMask: View {
    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.clear, .white], startPoint: .top, endPoint: .bottom)
                .frame(height: 10)
            Rectangle()
                .fill(.white)
            LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 10)
        }
    }
}

struct ScoreboardLineView: View {
    let line: ScoreboardLine

    var body: some View {
        HStack {
            ApeBoxes(boxes: line.level, solid: line.achieved)
                .alignmentGuide(.menuAlignment) { d in d[.trailing] }
            if line.achieved {
                ApeText(Text(line.time.timeString))
            } else {
                ApeText(Text("Try it!"))
            }
        }
    }
}

extension HorizontalAlignment {
    private enum MenuAlignment: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[HorizontalAlignment.center]
        }
    }

    static let menuAlignment: HorizontalAlignment = .init(MenuAlignment.self)
}
