//
//  SplashScreen.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

protocol PhaseEnum: RawRepresentable where RawValue == Int {
    static var start: Self { get }
    var r: Double { get }
    static func phase(for r: Double) -> Self
    static func fraction(for r: Double) -> Double
}

extension PhaseEnum {
    var r: Double { Double(rawValue) }

    static func phase(for r: Double) -> Self {
        .init(rawValue: Int(floor(r))) ?? .start
    }

    static func fraction(for r: Double) -> Double {
        r - floor(r)
    }
}

struct PhaseTiming<P: PhaseEnum>: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: (start: Double, phase: P)...) {
        stops = elements
    }

    func callAsFunction(at time: Double) -> P {
        stops.last { $0.start <= time }?.phase ?? .start
    }

    private var stops: [(start: Double, phase: P)]
}

struct SplashScreen: View {
    let vm: ViewModel

    var body: some View {
        TStack { time in
            UnfairLogoView(phase: vm.phase(at: time))
                .simpleFade(time, timing: .inOnly(start: 1))
        }
        .finish(after: 25, perform: vm.finished)
        .border(.white)
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
        let phase: PhaseTiming<LogoPhase> = [(2, .bell), (5, .offset)]
    }
}

struct UnfairLogoView: View {
    let phase: LogoPhase

    var body: some View {
        PhasedShape(phase: phase, points: UnfairLogo.points)
            .stroke(.white, lineWidth: 4)
            .retro()
            .animation(.spring(), value: phase)
    }
}

enum LogoPhase: Int, PhaseEnum {
    case start
//    case centered
    case bell
    case offset
}

struct UnfairLogo {
    static func points(r: Double) -> [Path.Points] {
        let phase = LogoPhase.phase(for: r)
        let fraction = LogoPhase.fraction(for: r)

        let height = (phase == .start ? fraction : 1) * peakHeight

        let left: UnitPoint = .leading + sideMargin + 0.3 * height
        let right: UnitPoint = .trailing - sideMargin + 0.3 * height
        let peak: UnitPoint = .center - 0.7 * height
        let bottom = 0.5 * (left + right)

        let curve: [Path.Points] = [.start(left),
                                    .curve(to: peak, control1: left + sideDelta, control2: peak - midDelta),
                                    .curve(to: right, control1: peak + midDelta, control2: right - sideDelta)]
        let line: [Path.Points] = [.start(bottom + lineMargin),
                                   .line(to: peak - lineMargin)]

        return curve + line
    }

    private static let peakHeight: UnitPoint = .init(x: 0, y: 0.5)
    private static let lineMargin: UnitPoint = .init(x: 0, y: 0.05)
    private static let sideMargin: UnitPoint = .init(x: 0.2, y: 0)
    private static let midDelta: UnitPoint = .init(x: 0.1, y: 0)
    private static let sideDelta: UnitPoint = .init(x: 0.2, y: 0)
}
