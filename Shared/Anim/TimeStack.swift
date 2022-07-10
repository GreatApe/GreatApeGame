//
//  TimeStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

extension Array where Element == Anim.Timing {
    var asDict: [Int: Anim.Timing] {
        let keysAndValues = enumerated().map { ($0.offset, $0.element) }
        return .init(uniqueKeysWithValues: keysAndValues)
    }
}

struct TimeStack<Content: View>: View {
    @State private var start: Date = .now
    private let timings: [AnyHashable: Anim.Timing]
    private let onFinished: () -> Void
    private let content: (Double) -> Content

    init(@ViewBuilder content: @escaping (Double) -> Content) {
        self.timings = [:]
        self.onFinished = { }
        self.content = content
    }

    init<TagType: Hashable>(timings: [TagType: Anim.Timing],
                            onFinished: @escaping () -> Void = { },
                            @ViewBuilder content: @escaping (Double) -> Content) {
        self.timings = timings
        self.onFinished = onFinished
        self.content = content
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let time = context.date.timeIntervalSince(start) - epsilon
            ZStack {
                content(time)
                    .environment(\.animPhases, timings.mapValues { Anim.phase(time: time, timing: $0) })
                    .onChange(of: time) { t in
//                        if t > finishTime {
//                            finished()
//                        }
                    }
            }
        }
    }

    private let epsilon: Double = 0.01
}

extension TimeStack {
    init<Phase: PhaseEnum>(phaseTimings: [Phase: Double],
                           onFinished: @escaping () -> Void = { },
                           @ViewBuilder content: @escaping (Phase) -> Content) {
        self.timings = phaseTimings.mapValues(Anim.Timing.start)
        self.onFinished = onFinished
        self.content = { time in content(Anim.enumPhase(time: time, timings: phaseTimings)) }
    }
}
