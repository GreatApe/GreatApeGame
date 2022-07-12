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
        TapStack(forEach: 1...4, ramp: vm.ramp, animator: MessageFade.self, onFinish: vm.finished) { index in
            Text(verbatim: "\(index)" + .about1)
                .retro()
        }
        .ape()
        .overlay(alignment: .topTrailing) {
            Button(action: vm.finished) {
                Image(systemName: "xmark")
                    .ape(large: true)
                    .padding(20)
            }
        }
    }

    struct ViewModel {
        let finished: () -> Void

        let order: [Int] = [1, 2, 3, 4]
        let ramp: Anim.Ramp = .assymetric(in: 0.3, out: 0.7)
    }
}
