//
//  TStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct TStack<Content: View>: View {
    @State private var start: Date = .now
    private var finishTime: Double
    private var finished: () -> Void
    private var content: (Double) -> Content

    init(@ViewBuilder content: @escaping (Double) -> Content) {
        self.finishTime = .infinity
        self.finished = { }
        self.content = content
    }

    init(after finishTime: Double, perform finished: @escaping () -> Void, @ViewBuilder content: @escaping (Double) -> Content) {
        self.finishTime = finishTime
        self.finished = finished
        self.content = content
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let time = context.date.timeIntervalSince(start) - epsilon
            ZStack {
                content(time)
                    .onChange(of: time) { t in
                        if t > 22 {
                            finished()
                        }
                    }
            }
        }
    }

    private let epsilon: Double = 0.01
}

struct Timing {
    let start: Double
    let duration: Double
    let fadeIn: Double
    let fadeOut: Double

    var startFadeIn: Double { start }

    var startFadeOut: Double { start + duration - fadeOut }

    static func symmetric(start: Double, duration: Double, fade: Double = 0.1) -> Self {
        .init(start: start, duration: duration, fadeIn: fade, fadeOut: fade)
    }

    static func inOnly(start: Double, fadeIn: Double = 0.1) -> Self {
        return .init(start: start, duration: .infinity, fadeIn: fadeIn, fadeOut: 0)
    }

    static func triangle(start: Double, duration: Double, relativePeak: Double) -> Self  {
        .init(start: start, duration: duration, fadeIn: relativePeak * duration, fadeOut: (1 - relativePeak) * duration)
    }

    func staying(_ active: Bool = true) -> Self {
        guard active else { return self }
        return .init(start: start, duration: .infinity, fadeIn: fadeIn, fadeOut: 0)
    }
}

enum FadePhase: Int, Equatable {
    case before = -1
    case showing = 0
    case after = 1

    init(time: Double, timing: Timing) {
        switch time {
            case ..<timing.startFadeIn: self = .before
            case timing.startFadeOut...: self = .after
            default: self = .showing
        }
    }
}

// MARK: Message fade

extension View {
    @ViewBuilder
    func transitionFade(_ time: Double, timing: Timing, transition: AnyTransition = .opacity) -> some View {
        let phase: FadePhase = .init(time: time, timing: timing)
        if phase == .showing {
            self
                .transition(.asymmetric(insertion: transition.animation(.easeIn(duration: timing.fadeIn)),
                                        removal: transition.animation(.easeOut(duration: timing.fadeOut))))
        }

    }

    func messageFade(_ time: Double, timing: Timing) -> some View {
        fade(time, timing: timing, using: MessageFade.init)
    }

    func simpleFade(_ time: Double, timing: Timing) -> some View {
        fade(time, timing: timing, using: SimpleFade.init)
    }



    func fade<Fader: ViewModifier & Animatable>(_ time: Double, timing: Timing, using fader: (Double) -> Fader) -> some View {
        let phase: FadePhase = .init(time: time, timing: timing)
        return modifier(fader(Double(phase.rawValue)))
            .animation(.linear(duration: phase == .showing ? timing.fadeIn : timing.fadeOut), value: phase)
    }
}

struct MessageFade: ViewModifier, Animatable {
    var x: Double

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

struct SimpleFade: ViewModifier, Animatable {
    var x: Double

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
