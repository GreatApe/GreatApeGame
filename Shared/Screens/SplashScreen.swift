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
        TimeStack(durations: vm.durations, onFinished: vm.finished) { step in
            let _ = print("STEP: \(step)")
            TitleView(step: step)
            UnfairLogoView(step: step)
            UnfairTextView(step: step)
            TapView(perform: vm.tapBackground)
        }
        .frame(width: Self.size.width, height: Self.size.height)
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void

        let durations: [LogoStep: Double] = [.start: 0.5,
                                             .wide: 0.5,
                                             .bell: 0.5,
                                             .offset: 1,
                                             .blank: 0.5,
                                             .titleA: 0.2,
                                             .titleG: 0.2,
                                             .titleE2: 0.2,
                                             .titleR: 0.2,
                                             .titleA2: 0.2,
                                             .titleE: 0.2,
                                             .titleP: 0.2,
                                             .titleT: 0.2,
                                             .titleNone: 0.4,
                                             .titleFull: 1.3]
    }

    static let size: CGSize = .init(width: 609, height: 337.5)
}

struct TitleView: View {
    let step: LogoStep

    var body: some View {
        VStack {
            HStack {
                Text("G").opacity(step == .titleG || step == .titleFull ? 1 : 0)
                Text("R").opacity(step == .titleR || step == .titleFull ? 1 : 0)
                Text("E").opacity(step == .titleE || step == .titleFull ? 1 : 0)
                Text("A").opacity(step == .titleA || step == .titleFull ? 1 : 0)
                Text("T").opacity(step == .titleT || step == .titleFull ? 1 : 0)
            }
            HStack {
                Text("A").opacity(step == .titleA2 || step == .titleFull ? 1 : 0)
                Text("P").opacity(step == .titleP || step == .titleFull ? 1 : 0)
                Text("E").opacity(step == .titleE2 || step == .titleFull ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: step)
        .ape(style: .title)
    }
}

struct UnfairLogoView: View {
    let step: LogoStep

    var body: some View {
        SteppedUnitShape(step: step, points: UnfairLogo.points)
            .stroke(.white, lineWidth: 4)
            .retro()
            .opacity(hide ? 0 : 1)
            .animation(.spring(), value: step)
            .animation(.easeInOut(duration: 0.5), value: hide)
    }

    private var hide: Bool { step > .offset }
}

struct UnfairTextView: View {
    private var show: Bool { step >= .offset }
    private var hide: Bool { step > .offset }
    let step: LogoStep

    var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                Text(verbatim: "Unfair Advantage")
                    .ape(style: .logo)
                    .retro()
                    .offset(x: show ? 0 : -0.1 * proxy.size.width, y: proxy.size.height * offset)
                    .opacity(show && !hide ? 1 : 0)
                    .animation(.spring(), value: show)
                    .animation(.easeInOut(duration: 0.5), value: hide)
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
    case blank
    case titleA
    case titleG
    case titleE2
    case titleR
    case titleA2
    case titleE
    case titleP
    case titleT
    case titleNone
    case titleFull
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
    private static let lineOffset: CGFloat = 0.26

    private static let midDelta: UnitPoint = .init(x: 0.1, y: 0)
    private static let sideDelta: UnitPoint = .init(x: 0.27, y: 0)
}
