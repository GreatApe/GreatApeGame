//
//  AboutScreen.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI

struct AboutScreen: View {
    let vm: ViewModel

    var body: some View {
        TapStack(order: vm.order, onFinish: vm.finished) { tag in
            Text(verbatim: .about1)
                .animated(using: MessageFade.self, tag: 1)
                .retro()
            Text(verbatim: .about2)
                .animated(using: MessageFade.self, tag: 2)
                .retro()
            Text(verbatim: .about3)
                .animated(using: MessageFade.self, tag: 3)
                .retro()
            Text(verbatim: .about4)
                .animated(using: MessageFade.self, tag: 4)
                .retro()
        }
        .ape
        .animationRamping(.assymetric(rampIn: 0.3, rampOut: 0.7).delayed(by: 0.7))
        .overlay(alignment: .topTrailing) {
            Button(action: vm.finished) {
                Image(systemName: "xmark")
                    .apeLarge
                    .padding(20)
            }
        }
    }

    struct ViewModel {
        let finished: () -> Void
        let order: [Int] = [1, 2, 3, 4]
    }
}
