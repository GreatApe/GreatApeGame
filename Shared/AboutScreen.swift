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
        TapStack(forEachTag: 0...5, ramp: vm.ramp, animator: MessageFade.self, onFinished: vm.finished) { index in
            if index == 5 {
                VStack {
                    Text("Links")
                        .retro()
                        .padding(.vertical)
                    MultiLineView(lines: vm.links, action: vm.tapLink, contents: AboutLine.init)
                }
            } else {
                Text(String.about[index])
                    .retro()
                    .padding(.horizontal, 100)
                    .allowsHitTesting(false)
            }
        }
        .ape()
        .overlay(alignment: .topTrailing) {
            Button(action: vm.finished) {
                Image(systemName: "xmark")
                    .ape(style: .largeText)
                    .padding(20)
            }
        }
    }

    struct ViewModel {
        let finished: () -> Void
        let tapLink: (AboutLink) -> Void
        let links: [AboutLink] = [.ayumu, .kpri]
//        let links: [AboutLink] = [.ayumu, .kpri, .unfairAdvantage]
        let ramp: Anim.Ramp = .assymetric(in: 0.3, out: 0.3)
    }
}

struct AboutLine: View {
    let link: AboutLink

    var body: some View {
        Text(link.string)
            .ape()
            .retro()
    }
}

enum AboutLink: Int, Identifiable, Equatable {
    case kpri
    case ayumu
    case unfairAdvantage

    var string: String {
        switch self {
            case .kpri:
                return "Kyoto Primate Research Institute"
            case .ayumu:
                return "Ayumu the chimpanzee"
            case .unfairAdvantage:
                return "Unfair Advantage Studios"
        }
    }

    var id: Int {
        rawValue
    }
}
