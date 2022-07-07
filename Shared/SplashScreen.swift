//
//  SplashScreen.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct SplashScreen: View {
    let vm: ViewModel

    var body: some View {
        TStack { time in
            let phase = vm.phase(at: time)
            UnfairLogoView(phase: phase)
                .simpleFade(time, timing: .inOnly(start: 1))
            UnfairTextView(phase: phase)
                .simpleFade(time, timing: .inOnly(start: 1.6))
        }
        .finish(after: 25, perform: vm.finished)
        .border(.white)
//        .onAppear {
//            for i in 0..<40 {
//                let r = 0.1 * Double(i)
//                let fractions = LogoPhase.fractions(r: r)
//                print("\(r.timeString): \(fractions[.start].timeString) \(fractions[.bell].timeString) \(fractions[.offset].timeString)")
//            }
//        }
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
        let phase: PhaseTimings<LogoPhase> = [(1, .wide), (3, .bell), (5, .offset)]
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

struct UnfairTextView: View {
    let phase: LogoPhase

    var body: some View {
        ApeText(verbatim: "Unfair Advantage")
            .retro()
//            .offset(x: phase == .offset ? 25 : 0)
//            .animation(.spring().repeatCount(1, autoreverses: true), value: phase)
    }
}

enum LogoPhase: Int, PhaseEnum {
    case start
    case wide
    case bell
    case offset
}

struct UnfairLogo {
    static func points(r: Double) -> [Path.Points] {
        let wide = LogoPhase.fraction(r: r, in: .wide)
        let bell = LogoPhase.fraction(r: r, in: .bell)
        let offset = LogoPhase.fraction(r: r, in: .offset)

        let peak: UnitPoint = .center + bell * peakShift * peakHeight * .up
        let trough: UnitPoint = peak + bell * peakHeight * .down

        let left = trough + 0.5 * wide * bellWidth * .left
        let right = trough + 0.5 * wide * bellWidth * .right

        let lineDelta: UnitPoint = offset * lineOffset * .right

        print("\(r): \(offset) \(LogoPhase.phase(for: r))")

        let curve: [Path.Points] = [.start(left),
                                    .curve(to: peak, control1: left + bell * sideDelta, control2: peak - bell * midDelta),
                                    .curve(to: right, control1: peak + bell * midDelta, control2: right - bell * sideDelta)]
        let line: [Path.Points] = [.start(peak + wide * margin * .up + lineDelta),
                                   .line(to: trough + wide * margin * .down + lineDelta)]

        return curve + line
    }

    private static let peakShift: CGFloat = 0.7

    private static let peakHeight: CGFloat = 0.5
    private static let margin: CGFloat = 0.05
    private static let bellWidth: CGFloat = 0.8
    private static let lineOffset: CGFloat = 0.25

    private static let midDelta: UnitPoint = .init(x: 0.13, y: 0)
    private static let sideDelta: UnitPoint = .init(x: 0.3, y: 0)
}
