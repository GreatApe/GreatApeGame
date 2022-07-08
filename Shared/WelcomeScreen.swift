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
        TStack { time in
            Text(verbatim: .welcome1)
                .messageFade(time, fading: fade.start(at: 1))
                .retro()
            Text(verbatim: .welcome2)
                .messageFade(time, fading: fade.start(at: 4))
                .retro()
            VideoClipView()
                .transitionFade(time, fading: .symmetric(duration: 13, fade: 0.5).start(at: 7))
            Text(verbatim: .welcome3)
                .messageFade(time, fading: fade.start(at: 20))
                .retro()
        }
        .finish(after: 22, perform: vm.finished)
        .onTapGesture(perform: vm.tapBackground)
        .apeLarge
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
    }

    private let fade: Fading = .init(start: 1, duration: 2.5, fadeIn: 0.6, fadeOut: 0.7)
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
