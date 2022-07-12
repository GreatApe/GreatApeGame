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
        TapStack(forEachTag: 0...5, ramp: vm.ramp, animator: MessageFade.self, onFinish: vm.finished) { index in
            Text(String.about[index])
                .retro()
                .padding(.horizontal, 100)
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
        let ramp: Anim.Ramp = .assymetric(in: 0.3, out: 0.7)
    }
}
