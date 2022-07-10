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
                    .environment(\.animPhases, timings.mapValues { .init(time: time, timing: $0) })
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

    private let epsilon: Double = 0.01
}

struct TapStack<Content: View>: View {
    @State private var phases: [AnyHashable: Anim.Phase] = [:]
    @State private var currentTag: AnyHashable = nil as Int?
    private var finished: () -> Void = { }
    private let tappable: Bool
    private let order: [AnyHashable]
    private let content: Content

    init<TagType: Hashable>(order: [TagType], startEmpty: Bool = false, tappable: Bool = false, @ViewBuilder content: () -> Content) {
        self.tappable = tappable
        self.order = startEmpty ? [nil as TagType?] + order : order
        self.content = content()
    }

    init(tappable: Bool = false, @ViewBuilder content: () -> Content) {
        self.tappable = tappable
        self.order = Array(0..<1000)
        self.content = content()
    }

    var body: some View {
        ZStack {
            TapView(perform: nextTag)
            content
                .allowsHitTesting(tappable)
                .environment(\.animPhases, phases)
        }
        .onAppear(perform: setupTags)
    }

    func onFinish(perform finished: @escaping () -> Void) -> Self {
        var result = self
        result.finished = finished
        return result
    }

    private func setupTags() {
        guard let first = order.first else { return }
        currentTag = first
        phases = .init(uniqueKeysWithValues: order.map { ($0, $0 == first ? .showing : .before) })

        logTags()
    }

    private func nextTag() {
        defer { logTags() }
        phases[currentTag] = .after
        guard let current = order.firstIndex(of: currentTag) else { return }
        guard order.indices.contains(current + 1) else {
            finished()
            currentTag = nil as Int?
            return
        }

        currentTag = order[current + 1]
        phases[currentTag] = .showing
    }

    private func logTags() {
        print("-- \(currentTag) --")
        phases.compactMap { tag, phase -> (tag: Int, phase: Anim.Phase)? in
            guard let intTag = tag.base as? Int else { return nil }
            return (intTag, phase)
        }
        .sorted { $0.tag < $1.tag }
        .forEach { print("\($0.tag): \($0.phase)") }
    }
}

extension View {
    func faded(tag: AnyHashable) -> some View {
        AnimatedView(animator: SimpleFade.self, tag: tag, content: self)
    }

    func animated<AnimatorType: Animator>(using animator: AnimatorType.Type, tag: AnyHashable) -> some View {
        AnimatedView(animator: animator, tag: tag, content: self)
    }

    func transitionFade(transition: AnyTransition = .opacity, tag: AnyHashable) -> some View {
        AnimatedView(animator: TransitionAnimator.self, tag: tag, content: self)
            .environment(\.animTransition, transition)
    }

    func animationRamping(_ ramping: Anim.Ramping) -> some View {
        environment(\.animRamping, ramping)
    }
}

protocol Animator: ViewModifier {
    init(phase: Anim.Phase)
}

struct AnimatedView<AnimatorType: Animator, Content: View>: View {
    @Environment(\.animPhases) private var phases
    @Environment(\.animRamping) private var ramping
    private let tag: AnyHashable
    private let content: Content

    init(animator: AnimatorType.Type, tag: AnyHashable, content: Content) {
        self.tag = tag
        self.content = content
    }

    var body: some View {
        let phase = phases[tag] ?? .before
        let duration = phase == .showing ? ramping.rampIn : ramping.rampOut
        let delay = phase == .showing ? ramping.rampInDelay : 0
        content
            .modifier(AnimatorType(phase: phase))
            .animation(.linear(duration: duration).delay(delay), value: phase)
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

        init(time: Double, timing: Timing) {
            let startFadeOut = timing.start + timing.duration
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
        let rampInDelay: Double

        static var standard: Ramping { .simple(0.1) }
        static func simple(_ ramp: Double) -> Ramping { .init(rampIn: ramp, rampOut: ramp, rampInDelay: 0) }
        static func assymetric(rampIn: Double, rampOut: Double) -> Ramping { .init(rampIn: rampIn, rampOut: rampOut, rampInDelay: 0) }

        func delayed(by delay: Double) -> Ramping {
            .init(rampIn: rampIn, rampOut: rampOut, rampInDelay: rampInDelay + delay)
        }
    }

    fileprivate struct PhasesKey: EnvironmentKey {
        static let defaultValue: [AnyHashable: Anim.Phase] = [:]
    }

    fileprivate struct RampingKey: EnvironmentKey {
        static let defaultValue: Ramping = .standard
    }

    fileprivate struct TransitionKey: EnvironmentKey {
        static let defaultValue: AnyTransition = .opacity
    }
}

extension EnvironmentValues {
    var animPhases: [AnyHashable: Anim.Phase] {
        get { self[Anim.PhasesKey.self] }
        set { self[Anim.PhasesKey.self] = newValue }
    }
}

extension EnvironmentValues {
    var animRamping: Anim.Ramping {
        get { self[Anim.RampingKey.self] }
        set { self[Anim.RampingKey.self] = newValue }
    }
}

extension EnvironmentValues {
    var animTransition: AnyTransition {
        get { self[Anim.TransitionKey.self] }
        set { self[Anim.TransitionKey.self] = newValue }
    }
}

extension Anim.Phase: CustomStringConvertible {
    var description: String {
        switch self {
            case .before: return "Before"
            case .showing: return "Showing"
            case .after: return "After"
        }
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

struct TransitionAnimator: Animator {
    @Environment(\.animRamping) private var ramping
    @Environment(\.animTransition) private var transition

    private let showing: Bool

    init(phase: Anim.Phase) {
        self.showing = phase == .showing
    }

    func body(content: Content) -> some View {
        if showing {
            content.transition(.asymmetric(insertion: transition.animation(.easeIn(duration: ramping.rampIn).delay(ramping.rampInDelay)),
                                           removal: transition.animation(.easeOut(duration: ramping.rampOut))))
        }
    }
}

