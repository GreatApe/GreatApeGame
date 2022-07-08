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
    var content: (Double) -> Content

    init(@ViewBuilder content: @escaping (Double) -> Content) {
        self.content = content
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let time = context.date.timeIntervalSince(start) - epsilon - delay
            ZStack {
                content(time)
                    .environment(\.tStackTime, time)
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
    func animated<AnimatorType: Animator>(using animator: AnimatorType.Type, timing: Timing) -> some View {
        AnimatedView(timing: timing, animator: animator, content: self)
    }

    @ViewBuilder
    func transitionFade(_ time: Double, timing: Timing, transition: AnyTransition = .opacity) -> some View {
        let phase: Timing.Phase = timing.phase(at: time)
        if phase == .showing {
            self.transition(.asymmetric(insertion: transition.animation(.easeIn(duration: timing.rampIn)),
                                        removal: transition.animation(.easeOut(duration: timing.rampOut))))
        }

    }
}

protocol Animator: ViewModifier {
    init(phase: Timing.Phase)
}

private struct AnimatedView<Content: View, AnimatorType: Animator>: View {
    @Environment(\.tStackTime) private var time
    let content: Content
    let timing: Timing

    init(timing: Timing, animator: AnimatorType.Type, content: Content) {
        self.timing = timing
        self.content = content
    }

    var body: some View {
        let phase = timing.phase(at: time)
        content
            .modifier(AnimatorType(phase: phase))
            .animation(.linear(duration: phase == .showing ? timing.rampIn : timing.rampOut), value: phase)
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

struct Timing {
    let start: Double
    let duration: Double
    let rampIn: Double
    let rampOut: Double

    static func simple(duration: Double, ramp: Double = 0.1) -> Self {
        .init(start: 0, duration: duration, rampIn: ramp, rampOut: ramp)
    }

    static func inOnly(fadeIn: Double = 0.1) -> Self {
        return .init(start: 0, duration: .infinity, rampIn: fadeIn, rampOut: 0)
    }

    static func triangle(duration: Double, relativePeak: Double) -> Self  {
        .init(start: 0, duration: duration, rampIn: relativePeak * duration, rampOut: (1 - relativePeak) * duration)
    }

    func stay(_ active: Bool = true) -> Self {
        guard active else { return self }
        return .init(start: start, duration: .infinity, rampIn: rampIn, rampOut: 0)
    }

    func start(at time: Double) -> Self {
        .init(start: time, duration: duration, rampIn: rampIn, rampOut: rampOut)
    }

    fileprivate func phase(at time: Double) -> Phase {
        let startFadeOut = start + duration - rampOut
        switch time {
            case ..<start: return .before
            case startFadeOut...: return .after
            default: return .showing
        }
    }

    enum Phase: Double, Equatable {
        case before = -1
        case showing = 0
        case after = 1
    }
}

// MARK: Message fade

extension View {
    func messageFade(_ timing: Timing) -> some View {
        animated(using: MessageFade.self, timing: timing)
    }
}

struct MessageFade: Animator, Animatable {
    private var x: Double

    init(phase: Timing.Phase) {
        self.x = phase.rawValue
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

extension View {
    func simpleFade(_ timing: Timing) -> some View {
        animated(using: SimpleFade.self, timing: timing)
    }
}

struct SimpleFade: Animator, Animatable {
    private var x: Double

    init(phase: Timing.Phase) {
        self.x = phase.rawValue
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
