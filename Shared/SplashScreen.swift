//
//  SplashScreen.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct SplashScreen: View {
    let vm: ViewModel

    var body: some View {
        TStack(after: 5, perform: vm.finished) { time in
            UnfairLogo()
                .simpleFade(time, timing: .symmetric(start: 1, duration: 3))
        }
        .border(.pink)
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
    }
}

struct UnfairLogo: View {
    var body: some View {
        UnfairLogoShape()
            .stroke(.white, lineWidth: 4)
            .retro()
    }
}

struct UnfairLogoShape: Shape {
    //    var animatableData: Double {
//        set { x = newValue }
//        get { x }
//    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            let frame = rect.insetBy(dx: 0.1 * rect.width, dy: 0.1 * rect.height)
            path.move(to: frame[.init(x: 0, y: 0.9)])
            path.addQuadCurve(to: frame[.init(x: 1, y: 0.9)], control: frame[.init(x: 0.5, y: 0.2)])
        }
    }
}
