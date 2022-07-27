//
//  PlayScreen.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import SwiftUI

struct PlayScreen: View {
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
            } else {
                vm.onTap()
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
        let paddedSide = vm.boxSize * (1 + Constants.margin)
        let origin = 0.5 * vm.size.asPoint - 0.5 * paddedSide * CGPoint(x: Constants.columns - 1, y: Constants.rows - 1)

        var result: Set<Int> = []

        while result.count < vm.level {
            result.insert(Int.random(in: 0..<Constants.rows * Constants.columns))
        }

        return result.map { i in
            origin + paddedSide * CGPoint(x: i / Constants.rows, y: i % Constants.rows )
        }
    }

    struct ViewModel {
        let size: CGSize
        let level: Int
        let time: Double
        let onTap: () -> Void
        let played: (PlayResult) -> Void

        var boxSize: CGFloat {
            let m = Constants.margin
            let width = size.width / (CGFloat(Constants.columns) * (1 + m) + m)
            let height = size.height / (CGFloat(Constants.rows) * (1 + m) + m)
            return min(width, height)
        }

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
