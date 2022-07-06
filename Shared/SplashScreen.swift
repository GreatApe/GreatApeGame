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
}

extension PhaseEnum {
    var r: Double { Double(rawValue) }
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
            UnfairLogo(phase: vm.phase(at: time))
                .simpleFade(time, timing: .inOnly(start: 1))
        }
        .finish(after: 15, perform: vm.finished)
        .border(.white)
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
        let phase: PhaseTiming<LogoPhase> = [(2, .bell), (5, .offset)]
    }
}

struct UnfairLogo: View {
    let phase: LogoPhase

    var body: some View {
        UnfairLogoShape(phase: phase)
            .stroke(.white, lineWidth: 4)
            .retro()
            .animation(.spring(), value: phase)
    }
}

enum LogoPhase: Int, PhaseEnum {
    case start
    case bell
    case offset
}

struct UnfairLogoShape: Shape {
    private var r: Double

    init(phase: LogoPhase) {
        self.r = phase.r
    }

    var animatableData: Double {
        set { r = newValue }
        get { r }
    }

    func path(in rect: CGRect) -> Path {
        let frame = rect.insetBy(dx: 0.1 * rect.width, dy: 0.1 * rect.height)
        let baseY = 0.9
        let y = baseY - min(animatableData, 1) * 0.7

        let left = frame[.init(x: 0, y: baseY)]
        let leftControl = frame[.init(x: 0.4, y: baseY)]

        let right = frame[.init(x: 1, y: baseY)]
        let rightControl = frame[.init(x: 0.6, y: baseY)]

        let midCurve = frame[.init(x: 0.5, y: y)]
        let midCurveControlLeft = frame[.init(x: 0.3, y: y)]
        let midCurveControlRight = frame[.init(x: 0.7, y: y)]

        let midCurveAbove = frame[.init(x: 0.5, y: y - 0.1)]
        let midBottomBelow = frame[.init(x: 0.5, y: baseY + 0.1)]

        return Path { path in
            path.move(to: left)
            path.addCurve(to: midCurve, control1: leftControl , control2: midCurveControlLeft)
            path.addCurve(to: right, control1: midCurveControlRight, control2: rightControl)

            path.move(to: midBottomBelow)
            path.addLine(to: midCurveAbove)
        }
    }
}
