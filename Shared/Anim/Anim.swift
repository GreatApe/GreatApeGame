//
//  Anim.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI

enum Anim {
    enum Phase: Equatable {
        case before
        case during
        case after

        var x: Double {
            switch self {
                case .before: return -1
                case .during: return 0
                case .after: return 1
            }
        }
    }

    struct Timing {
        let start: Double
        let duration: Double
        let ramp: Ramp?

        var end: Double {
            start + duration
        }

        static func start(at start: Double, ramp: Ramp? = nil) -> Timing {
            .init(start: start, duration: .infinity, ramp: ramp)
        }

        static func show(from start: Double, for duration: Double, ramp: Ramp? = nil) -> Timing {
            .init(start: start, duration: duration, ramp: ramp)
        }

        static func show(from start: Double, until end: Double, ramp: Ramp? = nil) -> Timing {
            .init(start: start, duration: end - start, ramp: ramp)
        }

        private init(start: Double, duration: Double, ramp: Ramp?) {
            self.start = start
            self.duration = duration
            self.ramp = ramp
        }
    }

    struct Ramp {
        let rampIn: Double
        let rampOut: Double
        let rampInDelay: Double

        static let standard: Ramp = .init(in: standardRampTime, out: standardRampTime)
        static let abrupt: Ramp = .init(in: 0, out: 0)
        static func over(_ time: Double) -> Ramp { .init(in: time, out: time) }
        static func assymetric(in rampIn: Double, out rampOut: Double) -> Ramp { .init(in: rampIn, out: rampOut) }

        func delayRampIn(by delay: Double) -> Self {
            .init(in: rampIn, out: rampOut, rampInDelay: delay)
        }

        private init(in rampIn: Double, out rampOut: Double, rampInDelay: Double = 0) {
            self.rampIn = rampIn
            self.rampOut = rampOut
            self.rampInDelay = rampInDelay
        }

        static let standardRampTime: Double = 0.1
    }

    static func currentStep<Step: Startable>(time: Double, timings: [Step: Anim.Timing]) -> Step {
        timings.filter { $0.value.start <= time }.max { $0.value.start < $1.value.start }?.key ?? .start
    }
}

extension Anim {
    fileprivate struct PhasesKey: EnvironmentKey {
        static let defaultValue: [AnyHashable: Phase] = [:]
    }

    fileprivate struct RampsKey: EnvironmentKey {
        static let defaultValue: [AnyHashable: Ramp] = [:]
    }

    fileprivate struct RampKey: EnvironmentKey {
        static let defaultValue: Ramp = .standard
    }

    fileprivate struct DefaultRampKey: EnvironmentKey {
        static let defaultValue: Ramp = .standard
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

    var animRamps: [AnyHashable: Anim.Ramp] {
        get { self[Anim.RampsKey.self] }
        set { self[Anim.RampsKey.self] = newValue }
    }

    var animRamp: Anim.Ramp {
        get { self[Anim.RampKey.self] }
        set { self[Anim.RampKey.self] = newValue }
    }

    var animDefaultRamp: Anim.Ramp {
        get { self[Anim.DefaultRampKey.self] }
        set { self[Anim.DefaultRampKey.self] = newValue }
    }

    var animTransition: AnyTransition {
        get { self[Anim.TransitionKey.self] }
        set { self[Anim.TransitionKey.self] = newValue }
    }
}

extension Anim.Phase: CustomStringConvertible {
    var description: String {
        switch self {
            case .before: return "Before"
            case .during: return "During"
            case .after: return "After"
        }
    }
}
