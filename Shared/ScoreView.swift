//
//  ScoreView.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import SwiftUI

struct ScoreView: View {
    let vm: ViewModel

    @State private var appearanceDate: Date = .now

    var body: some View {
        EmptyView()
        TimelineView(.animation) { context in
            let instant = context.date.timeIntervalSince(appearanceDate)
            let values = vm.values(at: instant)
            HStack {
                LevelBoxView(vm: .init(level: values.level, phase: values.boxPhase))
                TimeView(time: values.time.tick)
            }
            .animation(.spring(), value: values.level)
            .retro()
        }
    }

    struct ViewModel {
        private let inititalValues: Values
        private let phaseValues: [PhaseValues]

        init(level: Int, time: Double, scoreLine: ScoreLine, achievedTime: Bool) {
            switch scoreLine {
                case .display:
                    let boxPhase: LevelBoxView.Phase = achievedTime ? .displaySolid : .displayEmpty
                    self.inititalValues = .init(level: level, time: time, boxPhase: boxPhase)
                    self.phaseValues = []
                case .failure(let oldTime):
                    self.inititalValues = .init(level: level, time: oldTime, boxPhase: .start)
                    self.phaseValues = [(1, .init(level: level, time: time, boxPhase: .slide))]
                case .success(let oldTime):
                    self.inititalValues = .init(level: level, time: oldTime, boxPhase: .start)
                    self.phaseValues = [(1, .init(level: level, time: oldTime, boxPhase: .flash)),
                                        (2, .init(level: level, time: time, boxPhase: .slide))]
                case .levelUp(let oldLevel):
                    self.inititalValues = .init(level: oldLevel, time: time, boxPhase: .start)
                    self.phaseValues = [(1, .init(level: oldLevel, time: time, boxPhase: .flash)),
                                        (2, .init(level: oldLevel, time: time, boxPhase: .slide)),
                                        (2 + slideDuration, .init(level: level, time: time, boxPhase: .slide))
                    ]
            }
        }

        func values(at instant: TimeInterval) -> Values {
            phaseValues.last { $0.start <= instant }?.values ?? inititalValues
        }

        struct Values: Equatable {
            let level: Int
            let time: Double
            let boxPhase: LevelBoxView.Phase
        }

        typealias PhaseValues = (start: TimeInterval, values: Values)
    }
}

private extension Double {
    var tick: Double {
        0.01 * Foundation.round(100 * self)
    }
}

private let slideDuration: Double = 1

struct TimeView: View {
    let time: Double

    var body: some View {
        Text(verbatim: "2345")
            .ape
            .opacity(0)
            .modifier(TimeModifier(time: time))
            .animation(.easeInOut(duration: slideDuration), value: time)
    }
}

struct TimeModifier: ViewModifier, Animatable {
    var time: Double

    var animatableData: Double {
        set { time = newValue }
        get { 0.01 * round(time * 100) }
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    HStack(spacing: 0) {
                        let ticksRaw = 100 * time
                        let ticks = Int(floor(ticksRaw))

                        let seconds = ticks / 100
                        let tenths = (ticks - 100 * seconds) / 10
                        let hundreths = ticks % 10

                        let hundrethsExcess = ticksRaw - Double(ticks)
                        let tenthsExcess = hundreths == 9 ? hundrethsExcess : 0
                        let secondsExcess = tenths == 9 ? tenthsExcess : 0

                        let height = proxy.size.height
                        CounterDigit(height: height, digit: seconds, excess: secondsExcess)
                        Text(verbatim: ".")
                        CounterDigit(height: height, digit: tenths, excess: tenthsExcess)
                        CounterDigit(height: height, digit: hundreths, excess: hundrethsExcess)
                    }
                    .ape
                }
            }
    }
}

struct CounterDigit: View {
    let height: CGFloat
    let digit: Int
    let excess: Double

    private let anchorZ: Double = -1.22

    var body: some View {
        ZStack {
            Text(verbatim: String(digit))
                .rotation3DEffect(.degrees(excess * 36), axis: (1, 0, 0), anchorZ: anchorZ * height, perspective: 0)
                .opacity(1 - pow(abs(excess), 0.5))
            Text(verbatim: String((digit + 1) % 10))
                .rotation3DEffect(.degrees((excess - 1) * 36), axis: (1, 0, 0), anchorZ: anchorZ * height, perspective: 0)
                .opacity(1 - pow(abs(1 - excess), 0.5))
        }
    }
}

struct LevelBoxView: View {
    let vm: ViewModel

    var body: some View {
        ZStack {
            LevelBoxes(count: vm.level, solid: false)
            if vm.solid {
                LevelBoxes(count: vm.level, solid: true)
                    .mask {
                        LeftMaskShape(side: vm.slide ? .left : .right)
                    }
                    .animation(.easeInOut(duration: slideDuration), value: vm.slide)
                    .transition(.opacity.animation(.easeInOut(duration: 0.1).repeatCount(5)))
            }
        }
    }

    struct ViewModel: Equatable {
        let level: Int
        let phase: Phase

        var solid: Bool { phase == .flash || phase == .slide || phase == .displaySolid }
        var slide: Bool { phase == .slide }
    }

    enum Phase {
        case start
        case flash
        case slide
        case displaySolid
        case displayEmpty
    }
}

struct LevelBoxes: View {
    let count: Int
    let solid: Bool

    var body: some View {
        HStack(spacing: 1) {
            ForEach(boxes) { _ in
                Text(verbatim: .boxLine(1, solid: solid))
                    .transition(.scale)
            }
        }
        .ape
    }

    private var boxes: [BoxModel] {
        (0..<count).map { .init(id: count - $0) }
    }

    private struct BoxModel: Identifiable {
        let id: Int
    }
}
