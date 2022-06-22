//
//  PlayView.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import SwiftUI

struct PlayView: View {
    @State private var boxes: [BoxModel] = []
    @State private var showNumbers: Bool = true
    @State private var appeared: Date = .now

    let vm: ViewModel

    var body: some View {
        ZStack {
            ForEach(boxes) { box in
                Brick(size: vm.boxSize, number: box.number, showNumber: showNumbers)
                    .retro()
                    .position(box.location)
                    .onTapGesture {
                        guard Date.now.timeIntervalSince(appeared) > vm.time else { return }
                        tapped(box)
                    }
                    .transition(.opacity.animation(.linear(duration: 0.1)))
            }
        }
        .onAppear {
            boxes = makeBoxes()
            withAnimation(.easeOut(duration: 0.1).delay(vm.time)) {
                showNumbers = false
            }
        }
    }

    private var elapsed: Double {
        Date.now.timeIntervalSince(appeared)
    }

    private func tapped(_ box: BoxModel) {
        if box.number == boxes.first?.number {
            boxes.remove(at: 0)
            if boxes.isEmpty {
                vm.finished(after: elapsed)
            }
        } else {
            vm.missed(at: box.number, after: elapsed)
        }
    }

    private func makeBoxes() -> [BoxModel] {
        generateLocations().enumerated()
            .map { .init(number: $0 + 1, location: $1) }
    }

    private func generateLocations() -> [CGPoint] {
        var result: [CGPoint] = []
        while result.count < vm.level {
            let point: CGPoint = .random(in: vm.rect)
            guard result.allSatisfy({ abs($0.x - point.x) > vm.radius || abs($0.y - point.y) > vm.radius }) else { continue }
            result.append(point)
        }

        return result
    }

    // r * b + (r + 1) * m * b = h
    //  b = h / (r * (1 + m) + m)

    struct ViewModel {
        let size: CGSize
        let level: Int
        let time: Double
        let played: (PlayResult) -> Void

        var radius: CGFloat { 1.5 * boxSize }
        var rect: CGRect { .init(origin: .zero, size: size).insetBy(dx: 1.5 * boxSize, dy: 0.5 * boxSize) }

        var boxSize: CGFloat { size.height / (CGFloat(Constants.rows) * (1 + Constants.margin) + Constants.margin) }

        func missed(at number: Int, after elapsed: Double) {
            played(.init(level: level, time: time, missedBox: number, elapsed: elapsed))
        }

        func finished(after elapsed: Double) {
            played(.init(level: level, time: time, missedBox: nil, elapsed: elapsed))
        }
    }
}

struct Brick: View {
    let size: CGFloat
    let number: Int
    let showNumber: Bool

    var body: some View {
        ZStack {
            NumberView(size: size, number: number)
                .opacity(showNumber ? 1 : 0)
            BoxView(size: size)
                .opacity(showNumber ? 0 : 1)
        }
    }
}

struct BoxView: View {
    let size: CGFloat

    var body: some View {
        Rectangle()
            .fill(.white)
            .frame(width: size, height: size)
            .padding(0.5 * size)
            .contentShape(Rectangle())
    }
}

struct NumberView: View {
    let size: CGFloat
    let number: Int

    var body: some View {
        Text("\(number)")
            .font(.system(size: size))
            .foregroundColor(.white)
            .retro()
    }
}
