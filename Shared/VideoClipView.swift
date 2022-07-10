//
//  VideoClipView.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI
import AVKit

struct VideoClipView: View {
    private let player: AVPlayer

    init(url: URL) {
        self.player = AVPlayer(url: url)
    }

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
