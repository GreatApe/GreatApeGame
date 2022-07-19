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
    private let timings: [AnyHashable: Aneem.Timing]
    private let onFinished: () -> Void
    private let content: (Double) -> Content

    init(@ViewBuilder contentAtTime content: @escaping (Double) -> Content) {
        self.timings = [:]
        self.onFinished = { }
        self.content = content
    }

    init<Tag: Hashable>(timings: [Tag: Aneem.Timing],
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

    func defaultRamp(_ ramp: Aneem.Ramp) -> some View {
        self.environment(\.animDefaultRamp, ramp)
    }

    private let epsilon: Double = 0.01

    private func phase(time: Double, timing: Aneem.Timing) -> Aneem.Phase {
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
    init<Data: RandomAccessCollection, V: View, AnimatorType: Animator>(forEach data: Data,
                                                                        configuration: Aneem.Timing.Configuration,
                                                                        animator: AnimatorType.Type,
                                                                        onFinished: @escaping () -> Void = { },
                                                                        @ViewBuilder content: @escaping (Data.Element) -> V)
    where Content == ForEach<Array<(offset: Int, element: Data.Element)>, Int, AnimatedView<AnimatorType, V>> {
        self.init(timings: .sequenced(data.count, config: configuration), onFinished: onFinished) { time in
            ForEach(Array(data.enumerated()), id: \.offset) { (offset, dataElement) in
                AnimatedView(animator: AnimatorType.self, tag: offset + 1, content: content(dataElement))
            }
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
        self.content = { time in content(Aneem.currentStep(time: time, timings: timings)) }
    }

    private static func stepTimings<Step: StepEnum>(durations: [Step: Double]) -> [Step: Aneem.Timing] {
        guard !durations.isEmpty else { return [:] }
        var elapsed: Double = 0
        var timings: [Step: Aneem.Timing] = [:]
        for step in Step.allCases {
            let duration = durations[step, default: 0]
            timings[step] = .show(from: elapsed, for: duration, ramp: .abrupt)
            elapsed += duration
        }

        return timings
    }
}

extension Dictionary where Key == Int, Value == Aneem.Timing {
    static func ordered(_ timings: [Aneem.Timing]) -> Self {
        let keysAndValues = timings.enumerated().map { ($0.offset, $0.element) }
        return .init(uniqueKeysWithValues: keysAndValues)
    }

    static func sequenced(_ items: Int, config: Aneem.Timing.Configuration) -> Self {
        let overlap = config.join.overlap(rampTime: config.rampTime)

        let timings = (0...items).map { i -> (Int, Aneem.Timing) in
            if i == 0 {
                return (0, .show(from: 0, for: config.delay, ramp: .over(config.rampTime)))
            } else {
                let thisDuration = config.stay && i == items ? .infinity : config.duration
                return (i, .show(from: config.delay + Double(i - 1) * (config.duration - overlap), for: thisDuration, ramp: .over(config.rampTime)))
            }
        }

        return .init(uniqueKeysWithValues: timings)
    }
}

