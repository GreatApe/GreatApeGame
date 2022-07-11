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
        let ramps = timings.mapValues { $0.ramp.ramp ?? defaultRamp }
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
                    .onChange(of: phases, perform: logTags)
            }
        }
        .environment(\.animRamps, ramps)
    }

    func defaultRamp(_ ramp: Anim.Ramp) -> some View {
        self.environment(\.animDefaultRamp, ramp)
    }

    private let epsilon: Double = 0.01

    private func phase(time: Double, timing: Anim.Timing) -> Anim.Phase {
        let ramp = timing.ramp.ramp ?? defaultRamp
        let startFadeOut = timing.start + timing.duration - ramp.rampOut
        switch time {
            case ..<timing.start: return .before
            case startFadeOut...: return .after
            default: return .showing
        }
    }

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

        if let start = steps[.start], start != 0 { print("Start is implictly set to 0") }

        let sortedSteps = [(.start, 0)] + steps
            .sorted { $0.value < $1.value }
            .filter { $0.key != .start }

        let durations = zip(sortedSteps, sortedSteps.dropFirst()).map { this, next in
            next.value - this.value
        } + [0]

        let timings = zip(sortedSteps, durations).map { step, duration in
            (step.key, Anim.Timing.show(from: step.value, for: duration, ramp: .abrupt))
        }


        print("STEPS =====")
        // Sort, remove and re-add .start

        for s in sortedSteps {
            print("\(s.key): \(s.value)")
        }

        print("GIVES =====")
        for g in timings {
            print("\(g.0): \(g.1.start) -- \(g.1.duration) -- \(g.1.end)")
        }
        print("===//")

        self.timings = .init(uniqueKeysWithValues: timings)
        self.onFinished = onFinished
        self.content = { time in content(Anim.currentStep(time: time, timings: steps)) }
    }
}
