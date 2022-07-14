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
        TimeStack(steps: vm.timings, onFinished: vm.finished) { step in
            UnfairLogoView(step: step)
            UnfairTextView(step: step)
            TapView(perform: vm.tapBackground)
        }
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void

        var timings: [LogoStep: Double] {
            [.wide: 1,
             .bell: 1.5,
             .offset: 2,
             .finish: 4]
        }
    }
}

struct SplashScreen__: View {
    let vm: ViewModel

    var body: some View {
        TapStack(stepped: LogoStep.self, onFinish: vm.finished) { step in
            UnfairLogoView(step: step)
            UnfairTextView(step: step)
        }
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
    }
}

struct UnfairLogoView: View {
    let step: LogoStep

    var body: some View {
        SteppedUnitShape(step: step, points: UnfairLogo.points)
            .stroke(.white, lineWidth: 4)
            .retro()
            .animation(.spring(), value: step)
    }
}

struct UnfairTextView: View {
    private let show: Bool

    init(step: LogoStep) {
        self.show = step >= .offset
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                Text(verbatim: "Unfair Advantage")
                    .ape(style: .logo)
                    .retro()
                    .offset(x: show ? 0 : -0.1 * proxy.size.width, y: proxy.size.height * offset)
                    .opacity(show ? 1 : 0)
                    .animation(.spring(), value: show)
                Spacer()
            }
        }
    }

    private let offset: CGFloat = 0.5 + 0.5 * (1 - UnfairLogo.peakShift) + UnfairLogo.margin
}

enum LogoStep: Int, StepEnum {
    case start
    case wide
    case bell
    case offset
    case finish
}

struct UnfairLogo {
    static func points(steps: Steps<LogoStep>) -> [Path.Points] {
        let wide = steps[.wide]
        let bell = steps[.bell]
        let offset = steps[.offset]

        let peak: UnitPoint = .center + bell * peakShift * peakHeight * .up
        let trough: UnitPoint = peak + bell * peakHeight * .down

        let left = trough + 0.5 * wide * bellWidth * .left
        let right = trough + 0.5 * wide * bellWidth * .right

        let lineOffsetX: UnitPoint = lineOffset * .right
        let lineOffsetY: UnitPoint = (peakHeight + 2 * margin - sigmaHeight) * .down
        let lineTop = peak + wide * margin * .up + offset * lineOffsetX + offset * lineOffsetY
        let lineBottom = trough + wide * margin * .down + offset * lineOffsetX

        let control = 0.7 * (wide - bell) + bell

        let curve: [Path.Points] = [.start(left),
                                    .curve(to: peak, control1: left + control * sideDelta, control2: peak - control * midDelta),
                                    .curve(to: right, control1: peak + control * midDelta, control2: right - control * sideDelta)]
        let line: [Path.Points] = [.start(lineTop),
                                   .line(to: lineBottom)]

        return curve + line
    }

    static let peakShift: CGFloat = 0.7
    static let margin: CGFloat = 0.07

    private static let peakHeight: CGFloat = 0.5
    private static let sigmaHeight: CGFloat = 0.23
    private static let bellWidth: CGFloat = 0.8
    private static let lineOffset: CGFloat = 0.25

    private static let midDelta: UnitPoint = .init(x: 0.13, y: 0)
    private static let sideDelta: UnitPoint = .init(x: 0.3, y: 0)
}
