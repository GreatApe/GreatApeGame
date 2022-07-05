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
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let time = context.date.timeIntervalSince(start) - epsilon - vm.delay
            ZStack {
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: vm.tapBackground)
                ApeText(verbatim: .welcome1)
                    .messageFade(time, timing: .init(start: 0, duration: 2.5, fadeIn: 0.6, fadeOut: 0.7))
                    .retro()
                ApeText(verbatim: .welcome2)
                    .messageFade(time, timing: .init(start: 3, duration: 2.5, fadeIn: 0.6, fadeOut: 0.7))
                    .retro()
                VideoClipView()
                    .transitionFade(time, timing: .symmetric(start: 6, duration: 13, fade: 0.5))
                ApeText(verbatim: .welcome3)
                    .messageFade(time, timing: .init(start: 19, duration: 3, fadeIn: 0.6, fadeOut: 0.7))
                    .retro()
            }
            .onChange(of: time) { t in
                if t > 22 {
                    vm.finished()
                }
            }
        }
    }

    private let epsilon: Double = 0.01

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
        let delay: Double = 0.5
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
