//
//  Aneem.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI

enum Aneem {
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

        struct Configuration: Equatable {
            let delay: Double
            let duration: Double
            let rampTime: Double
            let join: Aneem.Join
            let stay: Bool

            init(delay: Double, duration: Double, rampTime: Double, join: Aneem.Join = .crossFade, stay: Bool = false) {
                self.delay = delay
                self.duration = duration
                self.rampTime = rampTime
                self.join = join
                self.stay = stay
            }
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

    enum Join: Equatable {
        case gap(time: Double)
        case juxtapose
        case mix(Double)
        case crossFade // mix(1)
        case overlap(time: Double)

        func overlap(rampTime: Double) -> Double {
            switch self {
                case .gap(let time):
                    return -time
                case .juxtapose:
                    return 0
                case .mix(let amount):
                    return amount.clamped(between: 0, and: 2) * rampTime
                case .crossFade:
                    return rampTime
                case .overlap(let time):
                    return 2 * rampTime + time
            }
        }
    }

    static func currentStep<Step: Startable>(time: Double, timings: [Step: Aneem.Timing]) -> Step {
        timings.filter { $0.value.start <= time }.max { $0.value.start < $1.value.start }?.key ?? .start
    }
}

extension Aneem {
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
    var animPhases: [AnyHashable: Aneem.Phase] {
        get { self[Aneem.PhasesKey.self] }
        set { self[Aneem.PhasesKey.self] = newValue }
    }

    var animRamps: [AnyHashable: Aneem.Ramp] {
        get { self[Aneem.RampsKey.self] }
        set { self[Aneem.RampsKey.self] = newValue }
    }

    var animRamp: Aneem.Ramp {
        get { self[Aneem.RampKey.self] }
        set { self[Aneem.RampKey.self] = newValue }
    }

    var animDefaultRamp: Aneem.Ramp {
        get { self[Aneem.DefaultRampKey.self] }
        set { self[Aneem.DefaultRampKey.self] = newValue }
    }

    var animTransition: AnyTransition {
        get { self[Aneem.TransitionKey.self] }
        set { self[Aneem.TransitionKey.self] = newValue }
    }
}

extension Aneem.Phase: CustomStringConvertible {
    var description: String {
        switch self {
            case .before: return "Before"
            case .during: return "During"
            case .after: return "After"
        }
    }
}
