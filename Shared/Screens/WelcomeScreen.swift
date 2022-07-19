//
//  WelcomeScreen.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 21/06/2022.
//

import SwiftUI

private let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "AyumuPrepared", ofType: "mp4")!)

struct WelcomeScreen: View {
    let vm: ViewModel

    var body: some View {
        TimeStack(timings: vm.timings, onFinished: vm.finished) { time in
            Text(verbatim: .welcome1)
                .fixedSize(horizontal: false, vertical: true)
                .animated(using: MessageFade.self, tag: 1)
                .retro()
            Text(verbatim: .welcome2)
                .fixedSize(horizontal: false, vertical: true)
                .animated(using: MessageFade.self, tag: 2)
                .retro()
            VideoClipView(url: videoURL)
                .transitioned(tag: 3)
            Text(verbatim: .welcome3)
                .fixedSize(horizontal: false, vertical: true)
                .animated(using: MessageFade.self, tag: 4)
                .retro()
            TapView(perform: vm.tapBackground)
        }
        .defaultRamp(.over(0.4))
        .ape(style: .largeText)
    }
    
    struct ViewModel {
        let text: Bool
        let tapBackground: () -> Void
        let finished: () -> Void

        var timings: [Int: Aneem.Timing] {
            text ? timingsWithText : timingsWithoutText
        }

        private let timingsWithText: [Int: Aneem.Timing] = [1: .show(from: 1, for: 2.5),
                                                            2: .show(from: 4, for: 2.5),
                                                            3: .show(from: 7, for: 14, ramp: .over(0.5)),
                                                            4: .show(from: 20.5, for: 2)]

        private let timingsWithoutText: [Int: Aneem.Timing] = [3: .show(from: 0, for: 14, ramp: .over(0.5))]
    }
}
