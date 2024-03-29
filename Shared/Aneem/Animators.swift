//
//  Animators.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI

protocol Animator: ViewModifier {
    init(phase: Aneem.Phase)
}

// MARK: Message Fade

struct MessageFade: Animator, Animatable {
    private var x: Double

    var animatableData: Double {
        set { x = newValue }
        get { x }
    }

    init(phase: Aneem.Phase) {
        self.x = phase.x
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

// MARK: Simple Fade

extension View {
    func faded(tag: AnyHashable) -> some View {
        AnimatedView(animator: SimpleFade.self, tag: tag, content: self)
    }
}

struct SimpleFade: Animator, Animatable {
    private var x: Double

    var animatableData: Double {
        set { x = newValue }
        get { x }
    }

    init(phase: Aneem.Phase) {
        self.x = phase.x
    }

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
    }

    private var opacity: Double {
        1 - abs(x)
    }
}

// MARK: Transition Animator

struct TransitionAnimator: Animator {
    @Environment(\.animRamp) private var ramp
    @Environment(\.animTransition) private var transition

    private let showing: Bool

    init(phase: Aneem.Phase) {
        self.showing = phase == .during
    }

    func body(content: Content) -> some View {
        if showing {
            content.transition(.asymmetric(insertion: transition.animation(.easeIn(duration: ramp.rampIn).delay(ramp.rampInDelay)),
                                           removal: transition.animation(.easeOut(duration: ramp.rampOut))))
        }
    }
}
