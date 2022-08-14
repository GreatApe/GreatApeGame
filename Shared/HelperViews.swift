//
//  HelperViews.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import SwiftUI

extension AnyTransition {
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

extension View {
    func ape(style: TextStyle = .smallText) -> some View {
        modifier(ApeModifier(style: style))
    }
}

struct ApeModifier: ViewModifier {
    private let font: Font

    init(style: TextStyle) {
        self.font = .custom(Constants.idiomatic.fontName(for: style), size: Constants.idiomatic.fontSize(for: style), relativeTo: .title)
    }

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .font(font)
            .foregroundColor(.white)
    }
}

enum TextStyle: Equatable {
    case smallText
    case boxes
    case largeText
    case menu
    case title
    case logo
    case linkHeader
    case link
    case ad
}

struct MenuText: View {
    let item: MenuItem

    var body: some View {
        ReadyScreen.ViewModel.text(for: item)
            .ape(style: .menu)
            .retro()
    }
}

enum Side: Double {
    case left = 0
    case right = 1
}

struct LeftMaskShape: Shape {
    private var ratio: Double

    var animatableData: Double {
        set { ratio = newValue }
        get { ratio }
    }

    init(side: Side) {
        self.ratio = side.rawValue
    }

    func path(in rect: CGRect) -> Path {
        .init(rect.left(ratio: ratio))
    }
}

struct RightMaskShape: Shape {
    private var ratio: Double

    var animatableData: Double {
        set { ratio = newValue }
        get { ratio }
    }

    init(side: Side) {
        self.ratio = side.rawValue
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

struct TapView: View {
    let perform: () -> Void

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture(perform: perform)
    }
}
