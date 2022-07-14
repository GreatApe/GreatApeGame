//
//  WelcomeScreen.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 21/06/2022.
//

import SwiftUI

private let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "AyumuShort", ofType: "mp4")!)

struct WelcomeScreen: View {
    let vm: ViewModel

    var body: some View {
        TimeStack(timings: vm.timings, onFinished: vm.finished) { time in
            Text(verbatim: .welcome1)
                .animated(using: MessageFade.self, tag: 1)
                .retro()
            Text(verbatim: .welcome2)
                .animated(using: MessageFade.self, tag: 2)
                .retro()
            VideoClipView(url: videoURL)
                .transitioned(tag: 3)
            Text(verbatim: .welcome3)
                .animated(using: MessageFade.self, tag: 4)
                .retro()
            TapView(perform: vm.tapBackground)
        }
        .defaultRamp(.over(0.6))
        .ape(style: .largeText)
    }
    
    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
        let timings: [Int: Anim.Timing] = [1: .show(from: 1, for: 2),
                                           2: .show(from: 4, for: 2),
                                           3: .show(from: 7, for: 13, ramp: .over(0.3)),
                                           4: .show(from: 20, for: 2)]
    }
}

struct WelcomeScreen2: View {
    let vm: ViewModel

    var body: some View {
        TapStack(order: 0...3, ramps: vm.ramps, onFinish: vm.finished) { tag in
            Text(verbatim: .welcome1)
                .transitioned(tag: 1)
                .retro()
            Text(verbatim: .welcome2)
                .transitioned(tag: 2)
                .retro()
            Text(verbatim: .welcome3)
                .transitioned(tag: 3)
                .retro()
        }
        .defaultRamp(.over(0.7))
        .ape(style: .largeText)
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
        let ramps: [Int: Anim.Ramp] = [1: .over(0.6),
                                       2: .over(0.6).delayRampIn(by: 0.6),
                                       3: .over(0.6).delayRampIn(by: 0.6)]
    }
}
