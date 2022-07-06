//
//  PhasedShape.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct PhasedShape: Shape {
    private var r: Double
    private var points: (Double) -> [Path.Points]

    init<P: PhaseEnum>(phase: P, points: @escaping (Double) -> [Path.Points]) {
        self.r = phase.r
        self.points = points
    }

    var animatableData: Double {
        set { r = newValue }
        get { r }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.add(points(r), in: rect)
        }
    }
}

extension Path {
    mutating func add(_ points: [Points], in frame: CGRect) {
        points.forEach { add($0, in: frame) }
    }

    mutating func add(_ points: Points, in frame: CGRect) {
        switch points {
            case .start(let point):
                move(to: frame[point])
            case .curve(let to, let control1, let control2):
                addCurve(to: frame[to], control1: frame[control1], control2: frame[control2])
            case .line(let to):
                addLine(to: frame[to])
        }
    }

    enum Points {
        case start(UnitPoint)
        case curve(to: UnitPoint, control1: UnitPoint, control2: UnitPoint)
        case line(to: UnitPoint)
    }
}
