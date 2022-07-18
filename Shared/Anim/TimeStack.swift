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

    init(@ViewBuilder contentAtTime content: @escaping (Double) -> Content) {
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
    init<Data: RandomAccessCollection, V: View, AnimatorType: Animator>(forEach data: Data,
                                                                        configuration: Anim.Timing.Configuration,
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

//    init(durations: [Double],
//         delay: Double = 0,
//         onFinished: @escaping () -> Void = { },
//         @ViewBuilder content: @escaping (Int) -> Content) {
//        let timings = TimeStack.timings(durations: durations, delay: delay)
//        self.delay = delay
//        self.timings = timings
//        self.onFinished = onFinished
//        self.content = { time in content(Anim.currentStep(time: time, timings: timings)) }
//    }
//
//    private static func timings(durations: [Double], delay: Double) -> [Int: Anim.Timing] {
//        guard !durations.isEmpty else { return [:] }
//        var elapsed: Double = delay
//        var timings: [Int: Anim.Timing] = [:]
//        for (step, duration) in durations.enumerated() {
//            timings[step] = .show(from: elapsed, for: duration, ramp: .abrupt)
//            elapsed += duration
//        }
//
//        return timings
//    }
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

    static func sequenced(_ items: Int, config: Anim.Timing.Configuration) -> Self {
        let overlap = config.join.overlap(rampTime: config.rampTime)

        let timings = (0...items).map { i -> (Int, Anim.Timing) in
            if i == 0 {
                return (0, .show(from: 0, for: config.delay, ramp: .over(config.rampTime)))
            } else {
                let thisDuration = config.stay && i == items ? .infinity : config.duration
                return (i, .show(from: config.delay + Double(i - 1) * (config.duration - overlap), for: thisDuration, ramp: .over(config.rampTime)))
            }
        }

        print("====")
        for xxx in timings {
            print("\(xxx.0): \(xxx.1.start) -- \(xxx.1.duration) -- \(xxx.1.end)")
        }

        return .init(uniqueKeysWithValues: timings)
    }
}

extension Anim.Timing {
    struct Configuration: Equatable {
        let delay: Double
        let duration: Double
        let rampTime: Double
        let join: Anim.Join
        let stay: Bool

        init(delay: Double, duration: Double, rampTime: Double, join: Anim.Join = .crossFade, stay: Bool = false) {
            self.delay = delay
            self.duration = duration
            self.rampTime = rampTime
            self.join = join
            self.stay = stay
        }
    }
}

extension Anim {
    enum Join: Equatable {
        case gap(time: Double)
        case juxtapose
        case mix(Double)
        case crossFade // mix(1)
        case overlap(time: Double)

        func overlap(rampTime: Double) -> Double {
            switch self {
                case .gap(let time):
                    return -time
                case .juxtapose:
                    return 0
                case .mix(let amount):
                    return amount.clamped(between: 0, and: 2) * rampTime
                case .crossFade:
                    return rampTime
                case .overlap(let time):
                    return 2 * rampTime + time
            }
        }
    }
}

