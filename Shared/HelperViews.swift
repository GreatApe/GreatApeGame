//
//  HelperViews.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import SwiftUI

extension AnyTransition {
    static let retro2: Self = .scale.animation(.linear(duration: 2))

    static let retro: Self = .retro(0)
    static func retro(_ delay: Double) -> Self { .asymmetric(insertion: .opacity.animation(.default.delay(delay)),
                                                             removal: .opacity.animation(.linear(duration: 0.012))) }
}

extension View {
    func retro() -> some View {
        ZStack {
            blur(radius: 5)
            self
        }
    }
}

struct MultiLineView<T: Identifiable, Contents: View>: View {
    let lines: [T]
    let action: (T) -> Void
    let contents: (T) -> Contents

    var body: some View {
        VStack(alignment: .menuAlignment, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
                Button(action: { action(line) }) {
                    contents(line)
                        .padding(3)
                }
                .transition(.retro(unitDelay * Double(index)))
            }
        }
    }

    private let unitDelay: Double = 0.05
}

extension String {
    static func boxLine(_ count: Int, solid: Bool) -> String {
        .init(repeating: solid ? "■" : "□", count: count)
    }
}

struct ApeLabel: View {
    let systemName: String
    let text: Text

    var body: some View {
        HStack {
            Image(systemName: systemName)
            text
        }
        .ape
    }
}

struct ApeText: View {
    let text: Text

    init(verbatim string: String) {
        self.init(Text(verbatim: string))
    }

    init(_ text: Text) {
        self.text = text
    }

    var body: some View {
        text.ape
    }
}

extension View {
    var ape: some View {
        modifier(ApeModifier())
    }

    var apeLarge: some View {
        modifier(ApeModifier(large: true))
    }
}

struct ApeModifier: ViewModifier {
    private let font: Font

    init(large: Bool = false) {
        self.font = .custom("Futura Medium", size: large ? 50 : 30, relativeTo: .title)
    }

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .font(font)
            .foregroundColor(.white)
    }
}

struct MenuText: View {
    let item: MenuItem

    var body: some View {
        ApeText(ReadyScreen.ViewModel.text(for: item))
            .retro()
    }
}

enum Side: Double {
    case left = 0
    case right = 1
}

struct LeftMaskShape: Shape {
    private var ratio: Double

    init(side: Side) {
        self.ratio = side.rawValue
    }

    var animatableData: Double {
        set { ratio = newValue }
        get { ratio }
    }

    func path(in rect: CGRect) -> Path {
        .init(rect.left(ratio: ratio))
    }
}

struct RightMaskShape: Shape {
    private var ratio: Double

    init(side: Side) {
        self.ratio = side.rawValue
    }

    var animatableData: Double {
        set { ratio = newValue }
        get { ratio }
    }

    func path(in rect: CGRect) -> Path {
        .init(rect.right(ratio: ratio))
    }
}

extension CGRect {
    func left(ratio: CGFloat) -> CGRect {
        .init(origin: origin, size: .init(width: width * ratio, height: height))
    }

    func right(ratio: CGFloat) -> CGRect {
        .init(origin: .init(x: width * (1 - ratio), y: origin.y), size: .init(width: width * ratio, height: height))
    }
}

struct MyTestView: View {
    @State private var time: Double = 1.56
    @State private var level: Int = 5

    @State private var excess: Double = 0
    @State private var anchorZ: Double = -1.12
    @State private var perspective: Double = 0.2
    @State private var angle: Double = 36

    var body: some View {
        HStack {
            VStack {
                HStack(spacing: 10) {
                    Spacer()
                    Button("Level -") {
                        level -= 1
                    }
                    Button("Level +") {
                        level += 1
                    }
                    Button("Time -") {
                        time *= 0.99
                    }
                    Button("Time +") {
                        time *= 1.01
                    }
                    Spacer()
                }
                //                FeedbackView(vm: .init(level: level, time: time, newTime: time, success: true))
                .padding(25)
                .background(.black)
                //                Slider(value: $excess, in: -1...1)
                //                Slider(value: $anchorZ, in: -2...2)
                //                Text(verbatim: "anchorZ: \(anchorZ)")
                //                Slider(value: $perspective, in: 0...3)
                //                Text(verbatim: "perspective: \(perspective)")
                //                Slider(value: $angle, in: 20...45)
                //                Text(verbatim: "angle: \(angle)")
            }
            .frame(width: 400)

        }
    }
}

