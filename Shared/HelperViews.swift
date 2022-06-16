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

struct ApeBoxes: View {
    let boxes: Int
    let solid: Bool

    var body: some View {
        ApeText(verbatim: .boxLine(boxes, solid: solid))
            .lineLimit(1)
    }
}

extension String {
    static func boxLine(_ count: Int, solid: Bool) -> String {
        .init(repeating: solid ? "■" : "□", count: count)
    }
}

struct ApeText: View {
    let text: Text
    let italic: Bool
    private let font: Font

    init(verbatim string: String) {
        self.init(Text(verbatim: string))
    }

    init(_ text: Text, italic: Bool = false) {
        self.text = text
        self.italic = italic
        let fontName = "Futura Medium" + (italic ? " Italic" : "")
        self.font = .custom(fontName, size: 30, relativeTo: .title)
    }

    var body: some View {
        text
            .multilineTextAlignment(.center)
            .font(font)
            .foregroundColor(.white)
    }
}

struct MenuText: View {
    let item: MenuItem

    var body: some View {
        ApeText(ReadyView.ViewModel.text(for: item))
            .retro()
    }
}

struct LeftMaskShape: Shape {
    var ratio: Double

    var animatableData: Double {
        set { ratio = newValue }
        get { ratio }
    }

    func path(in rect: CGRect) -> Path {
        .init(rect.left(ratio: ratio))
    }
}

struct RightMaskShape: Shape {
    var ratio: Double

    var animatableData: Double {
        set { ratio = newValue }
        get { ratio }
    }

    func path(in rect: CGRect) -> Path {
        .init(rect.right(ratio: ratio))
    }
}

extension View {
    func messageFade(_ phase: FadePhase) -> some View {
        let x: Double
        switch phase {
            case .before: x = 0
            case .showing: x = midPhasePoint
            case .after: x = 1
        }

        return modifier(MessageModifier(x: x, r: midPhasePoint))
    }

    private var midPhasePoint: Double { 0.7 }
}

enum FadePhase: Equatable {
    case before
    case showing
    case after
}

struct MessageModifier: ViewModifier, Animatable {
    var x: Double
    let r: Double

    var animatableData: Double {
        set { x = newValue }
        get { x }
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
    }

    private var scale: Double {
        x < r ? 0.6 + 0.4 * unitSin(x / r) : 1
    }

    private var opacity: Double {
        x < r ? unitSin(x / r) : 1 - unitSin((x - r) / (1 - r))
    }

    private func unitSin(_ x: Double) -> Double {
        sin(0.5 * x * .pi)
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

