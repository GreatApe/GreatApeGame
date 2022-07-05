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
                    .messageFade(time, timing: .triangle(start: 0, duration: 2, relativePeak: 0.3))
                ApeText(verbatim: .welcome2)
                    .messageFade(time, timing: .triangle(start: 2, duration: 2, relativePeak: 0.3))
                ApeText(verbatim: .welcome3)
                    .messageFade(time, timing: .triangle(start: 4, duration: 2, relativePeak: 0.3).staying())


                //                    PlayerView(player: player)
                //                        .scaleEffect(1.35)
                //                        .onAppear(perform: movieStart)

            }
            .retro()
        }
    }

    private func startClip() {
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        player.play()
    }

    private let epsilon: Double = 0.01

    struct ViewModel {
        let state: WelcomeState
        let tapBackground: () -> Void

        let delay: Double = 0.5
    }
}

struct Timing {
    let start: Double
    let end: Double
    let fadeIn: Double
    let fadeOut: Double

    var startFadeIn: Double { start }

    var startFadeOut: Double { end - fadeOut }

    static func simpleFade(start: Double, end: Double, fade: Double) -> Self {
        .init(start: start, end: end, fadeIn: fade, fadeOut: fade)
    }

    static func triangle(start: Double, duration: Double, relativePeak: Double) -> Self  {
        .init(start: start, end: start + duration, fadeIn: relativePeak * duration, fadeOut: (1 - relativePeak) * duration)
    }

    func staying(_ active: Bool = true) -> Self {
        guard active else { return self }
        return .init(start: start, end: .infinity, fadeIn: fadeIn, fadeOut: 0)
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
