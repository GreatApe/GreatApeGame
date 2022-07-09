//
//  WelcomeScreen.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 21/06/2022.
//

import SwiftUI
import AVKit

private let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "AyumuShort", ofType: "mp4")!)

struct WelcomeScreen: View {
    let vm: ViewModel
    @State private var start: Date = .now

    var body: some View {
        TapStack(timings: vm.timings) { time in
            Text(verbatim: .welcome1)
                .animated(using: MessageFade.self, tag: 1)
                .retro()
            Text(verbatim: .welcome2)
                .animated(using: MessageFade.self, tag: 2)
                .retro()
            VideoClipView()
                .transitionFade(time, timing: .simple(duration: 13, ramp: 0.7).start(at: 7))
            Text(verbatim: .welcome3)
                .animated(using: MessageFade.self, tag: 3)
                .retro()
            TapView(perform: vm.tapBackground)
        }
        .finish(22, perform: vm.finished)
        .apeLarge
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void

        let timing: Timing = .simple(duration: 2.5, ramp: 0.6)
        let startTimes: [Int: Double] = [1: 1,
                                         2: 4,
                                         3: 20]
        var timings: [Int: Timing] { startTimes.mapValues(timing.start) }
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
