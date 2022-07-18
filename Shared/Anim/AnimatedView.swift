//
//  AnimatedView.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI

struct AnimatedView<AnimatorType: Animator, Content: View>: View {
    @Environment(\.animPhases) private var phases
    @Environment(\.animRamps) private var ramps
    private let tag: AnyHashable
    private let content: Content

    init(animator: AnimatorType.Type, tag: AnyHashable, content: Content) {
        self.tag = tag
        self.content = content
    }

    var body: some View {
        let phase = phases[tag] ?? .before
        let ramp = ramps[tag] ?? .standard
        let (duration, delay) = phase == .during ? (ramp.rampIn, ramp.rampInDelay) : (ramp.rampOut, 0)
        content
            .modifier(AnimatorType(phase: phase))
            .environment(\.animRamp, ramp)
            .animation(.linear(duration: duration).delay(delay), value: phase)
    }
}

extension View {
    func animated<AnimatorType: Animator>(using animator: AnimatorType.Type, tag: AnyHashable) -> some View {
        AnimatedView(animator: animator, tag: tag, content: self)
    }

    func transitioned(with transition: AnyTransition = .opacity, tag: AnyHashable) -> some View {
        AnimatedView(animator: TransitionAnimator.self, tag: tag, content: self)
            .environment(\.animTransition, transition)
    }
}
