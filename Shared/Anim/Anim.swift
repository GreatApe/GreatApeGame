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

        static func start(at start: Double) -> Timing {
            .init(start: start, duration: .infinity)
        }

        static func show(from start: Double, for duration: Double) -> Timing {
            .init(start: start, duration: duration)
        }

        static func show(from start: Double, until end: Double) -> Timing {
            .init(start: start, duration: end - start)
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

    static func phase(time: Double, timing: Timing) -> Phase {
        let startFadeOut = timing.start + timing.duration
        switch time {
            case ..<timing.start: return .before
            case startFadeOut...: return .after
            default: return .showing
        }
    }

    static func enumPhase<EnumPhase: PhaseEnum>(time: Double, timings: [EnumPhase: Double]) -> EnumPhase {
        timings.filter { $0.value < time }.max { $0.value < $1.value }?.key ?? .start
    }
}

extension Anim {
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

    var animRamping: Anim.Ramping {
        get { self[Anim.RampingKey.self] }
        set { self[Anim.RampingKey.self] = newValue }
    }

    var animTransition: AnyTransition {
        get { self[Anim.TransitionKey.self] }
        set { self[Anim.TransitionKey.self] = newValue }
    }
}

extension View {
    func animationRamping(_ ramping: Anim.Ramping) -> some View {
        environment(\.animRamping, ramping)
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
