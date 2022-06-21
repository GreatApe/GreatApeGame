//
//  WelcomeView.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 21/06/2022.
//

import SwiftUI
import AVKit


private let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "AyumuShort", ofType: "mp4")!)


struct WelcomeView: View {
    private let player = AVPlayer(url: videoURL)
    let vm: ViewModel

//    @State private var didShowVideo: Bool = false

    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .onTapGesture(perform: vm.tapBackground)

            switch vm.state {
                case .splash:
                    EmptyView()
                case .introText:
                    MessagesView(vm: introVM)
                        .disabled(true)
                case .clip:
                    PlayerView(player: player)
                        .scaleEffect(1.35)
                        .onAppear(perform: movieStart)
            }
        }
    }

    private func movieStart() {
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        player.play()
    }

    private var introVM: MessagesView.ViewModel {
        .init(strings: ["Hello 0", "How are you 1", "How are 2", "How are 3", "How are 4"], delay: 0.5, stay: true)
    }

    struct ViewModel {
        let state: WelcomeState
        let tapBackground: () -> Void
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
