//
//  TimeStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct TimeStack<Content: View>: View {
    @State private var start: Date = .now
    @State private var didFinish: Bool = false
    private let lastTag: AnyHashable?
    private let timings: [AnyHashable: Anim.Timing]
    private let defaultRamp: Anim.Timing.Ramp
    private let onFinished: () -> Void
    private let content: (Double) -> Content

    init(@ViewBuilder content: @escaping (Double) -> Content) {
        self.lastTag = nil
        self.timings = [:]
        self.defaultRamp = .none
        self.onFinished = { }
        self.content = content
    }

    init<Tag: Hashable>(timings: [Tag: Anim.Timing],
                        defaultRamp: Anim.Timing.Ramp = .standard,
                        onFinished: @escaping () -> Void = { },
                        @ViewBuilder content: @escaping (Double) -> Content) {
        self.lastTag = nil
        self.timings = timings
        self.defaultRamp = defaultRamp
        self.onFinished = onFinished
        self.content = content
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let time = context.date.timeIntervalSince(start) - epsilon
            ZStack {
                content(time)
                    .environment(\.animPhases, timings.mapValues { phase(time: time, timing: $0) })
                    .environment(\.animRamps, timings.mapValues { $0.ramp ?? defaultRamp })
                    .onChange(of: time) { t in
//                        if t > finishTime {
//                            finished()
//                        }
                    }
            }
        }
    }

    private let epsilon: Double = 0.01

    private func phase(time: Double, timing: Anim.Timing) -> Anim.Phase {
        let startFadeOut = timing.start + timing.duration - (timing.ramp?.rampOut ?? defaultRamp.rampOut)
        switch time {
            case ..<timing.start: return .before
            case startFadeOut...: return .after
            default: return .showing
        }
    }
}

extension TimeStack {
    init<Step: StepEnum>(steps: [Step: Double],
                         onFinished: @escaping () -> Void = { },
                         @ViewBuilder content: @escaping (Step) -> Content) {
        self.lastTag = nil
        self.timings = steps.mapValues(Anim.Timing.start)
        self.defaultRamp = .none
        self.onFinished = onFinished
        self.content = { time in content(Anim.step(time: time, timings: steps)) }
    }
}
