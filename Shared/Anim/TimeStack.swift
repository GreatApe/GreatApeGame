//
//  TimeStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct TimeStack<Content: View>: View {
    @State private var start: Date = .now
    private var finishTime: Double = .infinity
    private var finished: () -> Void = { }
    private let timings: [AnyHashable: Anim.Timing]
    private let content: (Double) -> Content

    init<TagType: Hashable>(timings: [TagType: Anim.Timing], @ViewBuilder content: @escaping (Double) -> Content) {
        self.timings = timings
        self.content = content
    }

    init(timings: [Anim.Timing] = [], @ViewBuilder content: @escaping (Double) -> Content) {
        let keysAndValues = timings.enumerated().map { ($0.offset, $0.element) }
        self.timings = .init(uniqueKeysWithValues: keysAndValues)
        self.content = content
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let time = context.date.timeIntervalSince(start) - epsilon
            ZStack {
                content(time)
                    .environment(\.animPhases, timings.mapValues { Anim.phase(time: time, timing: $0) })
                    .onChange(of: time) { t in
                        if t > finishTime {
                            finished()
                        }
                    }
            }
        }
    }

    func after(_ finishTime: Double, perform finished: @escaping () -> Void) -> Self {
        var result = self
        result.finished = finished
        result.finishTime = finishTime
        return result
    }

    private let epsilon: Double = 0.01
}

extension TimeStack {
    init<Phase: PhaseEnum>(phaseTimings: [Phase: Double], @ViewBuilder content: @escaping (Phase) -> Content) {
        self.timings = phaseTimings.mapValues(Anim.Timing.start)
        self.content = { time in content(Anim.enumPhase(time: time, timings: phaseTimings)) }
    }
}
