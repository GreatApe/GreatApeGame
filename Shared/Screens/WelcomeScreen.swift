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
        TimeStack(timings: vm.timings) { time in
            Text(verbatim: .welcome1)
                .animated(using: MessageFade.self, tag: 1)
                .retro()
            Text(verbatim: .welcome2)
                .animated(using: MessageFade.self, tag: 2)
                .retro()
            VideoClipView(url: videoURL)
                .transitionFade(tag: 3)
                .animationRamping(.simple(0.3))
            Text(verbatim: .welcome3)
                .animated(using: MessageFade.self, tag: 4)
                .retro()
            TapView(perform: vm.tapBackground)
        }
        .after(23, perform: vm.finished)
        .animationRamping(.simple(0.7))
        .apeLarge
    }
    
    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
        let timings: [Int: Anim.Timing] = [1: .show(from: 1, for: 2),
                                           2: .show(from: 4, for: 2),
                                           3: .show(from: 7, for: 13),
                                           4: .show(from: 20, for: 2)]
    }
}
