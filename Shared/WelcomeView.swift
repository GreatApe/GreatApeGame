//
//  WelcomeView.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 21/06/2022.
//

import SwiftUI
import AVKit

private let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "AyumuShort", ofType: "mp4")!)

//struct UnfairLogo: Shape {
//    func path(in rect: CGRect) -> Path {
//        <#code#>
//    }
//}

struct WelcomeView: View {
    private let player = AVPlayer(url: videoURL)

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
                    .messageFade(time, timing: .init(start: 0, duration: 3, fadeIn: 0.6, fadeOut: 1.2))
                    .retro()
                ApeText(verbatim: .welcome2)
                    .messageFade(time, timing: .init(start: 3.5, duration: 3, fadeIn: 0.6, fadeOut: 1.2))
                    .retro()
                PlayerView(player: player)
                    .scaleEffect(1.35)
                    .onAppear(perform: startClip)
                    .transitionFade(time, timing: .symmetric(start: 7, duration: 12))
                ApeText(verbatim: .welcome3)
                    .messageFade(time, timing: .init(start: 20, duration: 3, fadeIn: 0.6, fadeOut: 1.2))
                    .retro()
            }
        }
    }

    private func startClip() {
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        player.play()
    }

    private let epsilon: Double = 0.01

    struct ViewModel {
        let size: CGSize
        let state: WelcomeState
        let tapBackground: () -> Void

        let delay: Double = 0.5
    }
}

struct Timing {
    let start: Double
    let duration: Double
    let fadeIn: Double
    let fadeOut: Double

    var startFadeIn: Double { start }

    var startFadeOut: Double { start + duration - fadeOut }

    static func symmetric(start: Double, duration: Double, fade: Double = 0.1) -> Self {
        .init(start: start, duration: duration, fadeIn: fade, fadeOut: fade)
    }

    static func triangle(start: Double, duration: Double, relativePeak: Double) -> Self  {
        .init(start: start, duration: duration, fadeIn: relativePeak * duration, fadeOut: (1 - relativePeak) * duration)
    }

    func staying(_ active: Bool = true) -> Self {
        guard active else { return self }
        return .init(start: start, duration: .infinity, fadeIn: fadeIn, fadeOut: 0)
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
