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
    func animated<AnimatorType: Animator>(with animator: AnimatorType.Type, fading: Fading) -> some View {
        AnimatedView(fading: fading, animator: animator, content: self)
    }
}

struct AnimatedView<Content: View, AnimatorType: Animator>: View {
    @Environment(\.tStackTime) private var time
    let content: Content
    let fading: Fading

    init(fading: Fading, animator: AnimatorType.Type, content: Content) {
        self.fading = fading
        self.content = content
    }

    var body: some View {
        let phase = fading.phase(at: time)
        content
            .modifier(AnimatorType(phase: phase))
            .animation(.linear(duration: phase == .showing ? fading.fadeIn : fading.fadeOut), value: phase)
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

struct Fading {
    let start: Double
    let duration: Double
    let fadeIn: Double
    let fadeOut: Double

    var startFadeOut: Double { start + duration - fadeOut }

    static func symmetric(duration: Double, fade: Double = 0.1) -> Self {
        .init(start: 0, duration: duration, fadeIn: fade, fadeOut: fade)
    }

    static func inOnly(fadeIn: Double = 0.1) -> Self {
        return .init(start: 0, duration: .infinity, fadeIn: fadeIn, fadeOut: 0)
    }

    static func triangle(duration: Double, relativePeak: Double) -> Self  {
        .init(start: 0, duration: duration, fadeIn: relativePeak * duration, fadeOut: (1 - relativePeak) * duration)
    }

    func staying(_ active: Bool = true) -> Self {
        guard active else { return self }
        return .init(start: start, duration: .infinity, fadeIn: fadeIn, fadeOut: 0)
    }

    func start(at time: Double) -> Self {
        .init(start: time, duration: duration, fadeIn: fadeIn, fadeOut: fadeOut)
    }

    func phase(at time: Double) -> FadePhase {
        switch time {
            case ..<start: return .before
            case startFadeOut...: return .after
            default: return .showing
        }
    }
}

enum FadePhase: Double, Equatable {
    case before = -1
    case showing = 0
    case after = 1
}

// MARK: Message fade

extension View {
    @ViewBuilder
    func transitionFade(_ time: Double, fading: Fading, transition: AnyTransition = .opacity) -> some View {
        let phase: FadePhase = fading.phase(at: time)
        if phase == .showing {
            self.transition(.asymmetric(insertion: transition.animation(.easeIn(duration: fading.fadeIn)),
                                    removal: transition.animation(.easeOut(duration: fading.fadeOut))))
        }

    }

    func messageFade(_ time: Double, fading: Fading) -> some View {
        fade(time, fading: fading, using: MessageFade.self)
    }

    func simpleFade(_ time: Double, fading: Fading) -> some View {
        fade(time, fading: fading, using: SimpleFade.self)
    }

    func fade<A: Animator>(_ time: Double, fading: Fading, using animatorType: A.Type) -> some View {
        let phase: FadePhase = fading.phase(at: time)
        return modifier(animatorType.init(phase: phase))
            .animation(.linear(duration: phase == .showing ? fading.fadeIn : fading.fadeOut), value: phase)
    }
}

protocol Animator: ViewModifier {
    init(phase: FadePhase)
}

struct MessageFade: Animator, Animatable {
    private var x: Double

    init(phase: FadePhase) {
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

struct SimpleFade: Animator, Animatable {
    private var x: Double

    init(phase: FadePhase) {
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
