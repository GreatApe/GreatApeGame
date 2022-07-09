//
//  WelcomeScreen.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 21/06/2022.
//

import SwiftUI
import AVKit

private let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "AyumuShort", ofType: "mp4")!)

struct WelcomeScreen__: View {
    let vm: ViewModel

    var body: some View {
        TimeStack(vm.timings) { time in
            Text(verbatim: .welcome1)
                .animated(using: MessageFade.self, tag: 1)
                .retro()
            Text(verbatim: .welcome2)
                .animated(using: MessageFade.self, tag: 2)
                .retro()
            VideoClipView()
                .transitionFade(tag: 3)
                .animationRamping(.simple(0.3))
            Text(verbatim: .welcome3)
                .animated(using: MessageFade.self, tag: 4)
                .retro()
            TapView(perform: vm.tapBackground)
        }
        .finish(23, perform: vm.finished)
        .animationRamping(.simple(0.7))
        .apeLarge
    }
    
    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void

        let timings: [Int: Anim.Timing] = [1: .init(start: 1, duration: 2),
                                           2: .init(start: 4, duration: 2),
                                           3: .init(start: 7, duration: 13),
                                           4: .init(start: 20, duration: 2)]
    }
}

struct WelcomeScreen: View {
    let vm: ViewModel

    var body: some View {
        TapStack(order: vm.order, startEmpty: true) {
            Text(verbatim: .welcome1)
                .animated(using: MessageFade.self, tag: 1)
                .retro()
            Text(verbatim: .welcome2)
                .animated(using: MessageFade.self, tag: 2)
                .retro()
            Text(verbatim: .welcome3)
                .animated(using: MessageFade.self, tag: 4)
                .retro()
        }
        .finish(perform: vm.finished)
        .animationRamping(.simple(0.7).delayed(by: 0.7))
        .apeLarge
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void

        let order: [Int] = [1, 2, 4]
    }
}

struct VideoClipView: View {
    private let player = AVPlayer(url: videoURL)

    var body: some View {
        PlayerView(player: player)
            .scaleEffect(1.35)
            .onAppear(perform: startClip)
    }

    private func startClip() {
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        player.play()
    }
}

struct PlayerView: UIViewRepresentable {
    let player: AVPlayer

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) { }

    func makeUIView(context: Context) -> UIView {
        PlayerUIView(player: player)
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
