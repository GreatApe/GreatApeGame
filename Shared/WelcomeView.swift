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

    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .onTapGesture(perform: vm.tapBackground)

            MessagesView(vm: introVM)
                .disabled(true)

//            switch vm.state {
//                case .splashOnly:
//                    MessagesView(vm: introVM)
//                        .disabled(true)
//                case .fullIntro:
//                    PlayerView(player: player)
//                        .scaleEffect(1.35)
//                        .onAppear(perform: movieStart)
//            }
        }
    }

    private func movieStart() {
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        player.play()
    }

    private var introVM: MessagesView.ViewModel {
//        .init(strings: ["Hello 0", "How are you 1", "How are 2", "How are 3", "How are 4"], delay: 0.5, stay: true)
        .init(strings: [.welcome1, .welcome2, .welcome3], delay: 0.5, stay: false)
    }

    struct ViewModel {
        let state: WelcomeState
        let tapBackground: () -> Void
    }
}

struct WelcomeView2: View {
    private let player = AVPlayer(url: videoURL)
    let vm: ViewModel

    /*
     Unfair advantage - Logo
     Presents
     Great Ape - random letters

     "Are you smarter than a chimpanzee?"
     "Tap the numbers in order, like this"
     Video
     "Ayumu can do 10, how many can you handle?"
     */

    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .onTapGesture(perform: vm.tapBackground)

            TimelineView(.explicit([])) { context in
                

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

//struct UnfairLogo: Shape {
//    func path(in rect: CGRect) -> Path {
//        <#code#>
//    }
//}


struct WelcomeView3: View {
    let vm: ViewModel

    @State private var start: Date = .now

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.25)) { context in
            let timePassed = context.date.timeIntervalSince(start) - epsilon
            ZStack {
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: vm.tapBackground)
                MessageView(text: .welcome1, duration: duration(for: 0), phase: phase(for: 0, after: timePassed))
                MessageView(text: .welcome2, duration: duration(for: 1), phase: phase(for: 1, after: timePassed))
//                MessageView(text: .welcome3, duration: duration(for: 2), phase: phase(for: 2, after: timePassed))
                if phase(for: 3, after: timePassed) == .showing {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 100, height: 100)
                        .transition(.opacity)
                }
            }
        }
    }

    private func phase(for i: Int, after timePassed: Double) -> FadePhase {
        let time = timePassed - vm.delay
        let timing = vm.timing[i]
        switch timing.type {
            case .simple:
                switch time {
                    case ..<timing.start: return .before
                    case timing.end...: return .after
                    default: return .showing
                }
            case .message:
                return time > timing.start ? .after : .before
        }
    }

    private func duration(for i: Int) -> Double {
        vm.timing[i].end - vm.timing[i].start
    }

    private let epsilon: Double = 0.01

    struct ViewModel {
        let state: WelcomeState
        let tapBackground: () -> Void

        let timing: [Timing] = [
            .message(start: 0, end: 2),
            .message(start: 2, end: 4),
            .message(start: 4, end: 6),
            .simple(start: 6, end: 10)]
        let delay: Double = 0.5
    }
}

struct Timing {
    let start: Double
    let end: Double
    let type: FadeType

    static func message(start: Double, end: Double) -> Self {
        .init(start: start, end: end, type: .message)
    }

    static func simple(start: Double, end: Double) -> Self {
        .init(start: start, end: end, type: .simple)
    }

    enum FadeType {
        case simple
        case message
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
