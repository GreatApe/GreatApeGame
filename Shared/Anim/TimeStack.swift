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
                        if t > finishTime {
                            onFinished()
                        }
                    }
                    .onChange(of: phases, perform: logTags) // FIXME: remove
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

    // FIXME: remove
    private func logTags(phases: [AnyHashable: Anim.Phase]) {
        print("----")
        phases.compactMap { tag, phase -> (tag: LogoStep, phase: Anim.Phase)? in
            guard let intTag = tag.base as? LogoStep else { return nil }
            return (intTag, phase)
        }
        .sorted { $0.tag < $1.tag }
        .forEach { print("\($0.tag): \($0.phase)") }
    }
}

extension TimeStack {
    init<Step: StepEnum>(steps: [Step: Double],
                         onFinished: @escaping () -> Void = { },
                         @ViewBuilder content: @escaping (Step) -> Content) {
        self.timings = TimeStack.stepTimings(steps: steps)
        self.onFinished = onFinished
        self.content = { time in content(Anim.currentStep(time: time, timings: steps)) }
    }

    private static func stepTimings<Step: StepEnum>(steps: [Step: Double]) -> [AnyHashable: Anim.Timing] {
        var steps = steps
        steps[.start] = 0
        let sorted = steps.sorted { $0.value < $1.value }
        let timings = zip(sorted, sorted.dropFirst() + [sorted[sorted.endIndex - 1]]).map { this, next in
            (this.key, Anim.Timing.show(from: this.value, until: next.value, ramp: .abrupt))
        }

        return .init(uniqueKeysWithValues: timings)
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
