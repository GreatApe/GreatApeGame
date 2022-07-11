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
        case showing
        case after

        var x: Double {
            switch self {
                case .before: return -1
                case .showing: return 0
                case .after: return 1
            }
        }
    }

    struct Timing {
        let start: Double
        let duration: Double
        let ramp: Ramp?

        static func start(at start: Double) -> Timing {
            .init(start: start, duration: .infinity)
        }

        static func show(from start: Double, for duration: Double) -> Timing {
            .init(start: start, duration: duration)
        }

        static func show(from start: Double, until end: Double) -> Timing {
            .init(start: start, duration: end - start)
        }

        func ramp(over rampTime: Double) -> Timing {
            ramp(in: rampTime, out: rampTime)
        }

        func ramp(in rampIn: Double, out rampOut: Double) -> Timing {
            .init(start: start, duration: duration, ramp: .init(rampIn: rampIn, rampOut: rampOut))
        }

        private init(start: Double, duration: Double, ramp: Ramp = .standard) {
            self.start = start
            self.duration = duration
            self.ramp = ramp
        }

        struct Ramp {
            let rampIn: Double
            let rampOut: Double

            static let none: Self = .init(rampIn: 0, rampOut: 0)
            static let standard: Self = .init(rampIn: defaultRamp, rampOut: defaultRamp)
            private static let defaultRamp: Double = 0.1
        }
    }

    static func step<Step: StepEnum>(time: Double, timings: [Step: Double]) -> Step {
        timings.filter { $0.value < time }.max { $0.value < $1.value }?.key ?? .start
    }
}

extension Dictionary where Key == Int, Value == Anim.Timing {
    static func ordered(_ timings: [Anim.Timing]) -> Self {
        let keysAndValues = timings.enumerated().map { ($0.offset, $0.element) }
        return .init(uniqueKeysWithValues: keysAndValues)
    }

    static func sequence(_ startTimes: [Double], cross: Bool) -> Self {
        fatalError()
        //            .init(timings: timings)
    }
}

extension Anim {
    fileprivate struct PhasesKey: EnvironmentKey {
        static let defaultValue: [AnyHashable: Anim.Phase] = [:]
    }

    fileprivate struct RampsKey: EnvironmentKey {
        static let defaultValue: [AnyHashable: Anim.Timing.Ramp] = [:]
    }

    fileprivate struct RampKey: EnvironmentKey {
        static let defaultValue: Anim.Timing.Ramp = .standard
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

    var animRamps: [AnyHashable: Anim.Timing.Ramp] {
        get { self[Anim.RampsKey.self] }
        set { self[Anim.RampsKey.self] = newValue }
    }

    var animRamp: Anim.Timing.Ramp {
        get { self[Anim.RampKey.self] }
        set { self[Anim.RampKey.self] = newValue }
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
            case .showing: return "Showing"
            case .after: return "After"
        }
    }
}
