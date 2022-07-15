//
//  TimeStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct TimeStack<Content: View>: View {
    @Environment(\.animDefaultRamp) private var defaultRamp
    @State private var start: Date = .now
    @State private var didFinish: Bool = false
    private let timings: [AnyHashable: Anim.Timing]
    private let onFinished: () -> Void
    private let content: (Double) -> Content

    init(@ViewBuilder content: @escaping (Double) -> Content) {
        self.timings = [:]
        self.onFinished = { }
        self.content = content
    }

    init<Tag: Hashable>(timings: [Tag: Anim.Timing],
                        onFinished: @escaping () -> Void = { },
                        @ViewBuilder content: @escaping (Double) -> Content) {
        self.timings = timings
        self.onFinished = onFinished
        self.content = content
    }

    var body: some View {
        let finishTime = timings.values.map(\.end).max() ?? .infinity
        let ramps = timings.mapValues { $0.ramp ?? defaultRamp }
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let time = context.date.timeIntervalSince(start) - epsilon
            let phases = timings.mapValues { phase(time: time, timing: $0) }
            ZStack {
                content(time)
                    .environment(\.animPhases, phases)
                    .onChange(of: time) { t in
                        if t > finishTime, !didFinish {
                            onFinished()
                            didFinish = true
                        }
                    }
            }
        }
        .environment(\.animRamps, ramps)
    }

    func defaultRamp(_ ramp: Anim.Ramp) -> some View {
        self.environment(\.animDefaultRamp, ramp)
    }

    private let epsilon: Double = 0.01

    private func phase(time: Double, timing: Anim.Timing) -> Anim.Phase {
        let ramp = timing.ramp ?? defaultRamp
        let startFadeOut = timing.start + timing.duration - ramp.rampOut
        switch time {
            case ..<timing.start: return .before
            case startFadeOut...: return .after
            default: return .during
        }
    }
}

extension TimeStack {
    init<Step: StepEnum>(durations: [Step: Double],
                         onFinished: @escaping () -> Void = { },
                         @ViewBuilder content: @escaping (Step) -> Content) {
        let timings = TimeStack.stepTimings(durations: durations)
        self.timings = timings
        self.onFinished = onFinished
        self.content = { time in content(Anim.currentStep(time: time, timings: timings)) }
    }

    private static func stepTimings<Step: StepEnum>(durations: [Step: Double]) -> [Step: Anim.Timing] {
        guard !durations.isEmpty else { return [:] }
        var elapsed: Double = 0
        var timings: [Step: Anim.Timing] = [:]
        for step in Step.allCases {
            let duration = durations[step, default: 0]
            timings[step] = .show(from: elapsed, for: duration, ramp: .abrupt)
            elapsed += duration
        }

        return timings
    }
}

extension Dictionary where Key == Int, Value == Anim.Timing {
    static func ordered(_ timings: [Anim.Timing]) -> Self {
        let keysAndValues = timings.enumerated().map { ($0.offset, $0.element) }
        return .init(uniqueKeysWithValues: keysAndValues)
    }

//    static func sequenced(_ durations: [Double], overlap: Double) -> Self {
//        let sorted = Set(startTimes + [0]).sorted().enumerated()
//
//        let timings = zip(sorted, sorted.dropFirst()).map { this, next in
//            (this.offset, Anim.Timing.show(from: this.element, until: next.element, ramp: .abrupt))
//        }
//
//        print("====")
//        for xxx in timings {
//            print("\(xxx.0): \(xxx.1.start) -- \(xxx.1.duration) -- \(xxx.1.end)")
//        }
//
//        return .init(uniqueKeysWithValues: timings)
//    }
}
