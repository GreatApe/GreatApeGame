//
//  TStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct TStack<Content: View>: View {
    @State private var start: Date = .now
    private var finishTime: Double = .infinity
    private var finished: () -> Void = { }
    private var delay: Double = 0
    var timings: [AnyHashable: Anim.Timing]
    var content: (Double) -> Content

    init<TagType: Hashable>(_ timings: [TagType: Anim.Timing], @ViewBuilder content: @escaping (Double) -> Content) {
        self.timings = timings
        self.content = content
    }

    init(_ timings: [Anim.Timing] = [], @ViewBuilder content: @escaping (Double) -> Content) {
        let keysAndValues = timings.enumerated().map { ($0.offset, $0.element) }
        self.timings = .init(uniqueKeysWithValues: keysAndValues)
        self.content = content
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let time = context.date.timeIntervalSince(start) - epsilon - delay
            ZStack {
                content(time)
                    .environment(\.tStackTime, time)
                    .environment(\.tStackTimings, timings)
                    .onChange(of: time) { t in
                        if t > finishTime {
                            finished()
                        }
                    }
            }
        }
    }

    func finish(_ finishTime: Double, perform finished: @escaping () -> Void) -> Self {
        var result = self
        result.finished = finished
        result.finishTime = finishTime
        return result
    }

    func delay(_ delay: Double) -> Self {
        var result = self
        result.delay = delay
        return result
    }

    private let epsilon: Double = 0.01
}

extension View {
    func animated<AnimatorType: Animator>(using animator: AnimatorType.Type, tag: AnyHashable) -> AnimatedView<AnimatorType, Self> {
        AnimatedView(animator: animator, tag: tag, content: self)
    }

    @ViewBuilder
    func transitionFade(tag: AnyHashable) -> some View {
//        if Anim.Phase(time: time, timing: timing, ramping: ramping) == .showing {
//            self.transition(.asymmetric(insertion: transition.animation(.easeIn(duration: ramping.rampIn)),
//                                        removal: transition.animation(.easeOut(duration: ramping.rampOut))))
//        }
        TransitioningView(tag: tag, content: self)
    }

    func animationRamping(_ ramping: Anim.Ramping) -> some View {
        environment(\.tStackRamping, ramping)
    }
}

struct TransitioningView<Content: View>: View {
    @Environment(\.tStackTime) private var time
    @Environment(\.tStackTimings) private var timings
    @Environment(\.tStackRamping) private var ramping
    let tag: AnyHashable
    let content: Content

    init(tag: AnyHashable, content: Content) {
        self.tag = tag
        self.content = content
    }

    var body: some View {
        let timing = timings[tag, default: .init(start: 1)]
        let phase: Anim.Phase = .init(time: time, timing: timing, ramping: ramping)
//        let duration = phase == .showing ? ramping.rampIn : ramping.rampOut

        if phase == .showing {
            content
                .transition(.asymmetric(insertion: .scale.animation(.easeIn(duration: ramping.rampIn)),
                                        removal: .scale.animation(.easeOut(duration: ramping.rampOut))))
        }
//        content
//            .modifier(AnimatorType(phase: phase))
//            .animation(.linear(duration: duration), value: phase)
    }
}




protocol Animator: ViewModifier {
    init(phase: Anim.Phase)
}

struct AnimatedView<AnimatorType: Animator, Content: View>: View {
    @Environment(\.tStackTime) private var time
    @Environment(\.tStackTimings) private var timings
    @Environment(\.tStackRamping) private var ramping
    let tag: AnyHashable
    let content: Content

    init(animator: AnimatorType.Type, tag: AnyHashable, content: Content) {
        self.tag = tag
        self.content = content
    }

    var body: some View {
        let timing = timings[tag, default: .init(start: 1)]
        let phase: Anim.Phase = .init(time: time, timing: timing, ramping: ramping)
        let duration = phase == .showing ? ramping.rampIn : ramping.rampOut
        content
            .modifier(AnimatorType(phase: phase))
            .animation(.linear(duration: duration), value: phase)
    }
}

private struct TStackTimeKey: EnvironmentKey {
    static let defaultValue: Double = 0
}

extension EnvironmentValues {
    var tStackTime: Double {
        get { self[TStackTimeKey.self] }
        set { self[TStackTimeKey.self] = newValue }
    }
}

private struct TStackTimingsKey: EnvironmentKey {
    static let defaultValue: [AnyHashable: Anim.Timing] = [:]
}

extension EnvironmentValues {
    var tStackTimings: [AnyHashable: Anim.Timing] {
        get { self[TStackTimingsKey.self] }
        set { self[TStackTimingsKey.self] = newValue }
    }
}

private struct TStackRampingKey: EnvironmentKey {
    static let defaultValue: Anim.Ramping = .standard
}

extension EnvironmentValues {
    var tStackRamping: Anim.Ramping {
        get { self[TStackRampingKey.self] }
        set { self[TStackRampingKey.self] = newValue }
    }
}

enum Anim {
    enum Phase: Equatable {
        case before
        case showing
        case after

        var x: Double {
            switch self {
                case .before: return -1
                case .showing: return 0
                case .after: return 1
            }
        }

        init(time: Double, timing: Timing, ramping: Ramping) {
            let startFadeOut = timing.start + timing.duration - ramping.rampOut
            switch time {
                case ..<timing.start: self = .before
                case startFadeOut...: self = .after
                default: self = .showing
            }
        }
    }

    struct Timing {
        let start: Double
        let duration: Double

        init(start: Double, duration: Double = .infinity) {
            self.start = start
            self.duration = duration
        }

        init(start: Double, end: Double) {
            self.start = start
            self.duration = end - start
        }
    }

    struct Ramping {
        let rampIn: Double
        let rampOut: Double

        static var standard: Ramping { .simple(0.1) }
        static func simple(_ ramp: Double) -> Ramping { .init(rampIn: ramp, rampOut: ramp) }
        static func assymetric(rampIn: Double, rampOut: Double) -> Ramping { .init(rampIn: rampIn, rampOut: rampOut) }
    }
}

// MARK: Message fade

struct MessageFade: Animator, Animatable {
    private var x: Double

    init(phase: Anim.Phase) {
        self.x = phase.x
    }

    var animatableData: Double {
        set { x = newValue }
        get { x }
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
    }

    private var scale: Double {
        x < 0 ? 0.6 + 0.4 * unitSin(x + 1) : 1
    }

    private var opacity: Double {
        x < 0 ? unitSin(x + 1) : 1 - unitSin(x)
    }

    private func unitSin(_ x: Double) -> Double {
        sin(0.5 * .pi * x)
    }
}

// MARK: Simple fade

struct SimpleFade: Animator, Animatable {
    private var x: Double

    init(phase: Anim.Phase) {
        self.x = phase.x
    }

    var animatableData: Double {
        set { x = newValue }
        get { x }
    }

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
    }

    private var opacity: Double {
        1 - abs(x)
    }
}
