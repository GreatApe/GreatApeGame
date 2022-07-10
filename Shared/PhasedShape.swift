//
//  PhasedShape.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct TimedShape: Shape {
    var r: Double
    var points: (Double) -> [Path.Points]

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

struct PhasedShape<P: PhaseEnum>: Shape {
    private var r: Double
    private var phase: P
    private var points: (Steps<P>) -> [Path.Points]

    init(phase: P, points: @escaping (Steps<P>) -> [Path.Points]) {
        self.r = phase.r
        self.phase = phase
        self.points = points
    }

    var animatableData: Double {
        set { r = newValue }
        get { r }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.add(points(.init(r: r, phase: phase)), in: rect)
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

protocol PhaseEnum: CaseIterable, Startable, RawRepresentable where RawValue == Double { }

protocol Startable {
    static var start: Self { get }
}

extension PhaseEnum {
    var time: Double {
        rawValue
    }

    var r: Double {
        Double(Self.allCases.enumerated().first { $0.element == self }?.offset ?? 0)
    }

    init(at time: Double) {
        self = Self.allCases.reversed().first { $0.rawValue <= time } ?? .start
    }
}

struct Steps<P: PhaseEnum> {
    let r: Double
    let phase: P

    subscript(phase: P) -> Double {
        if phase == self.phase {
            return 1 + r - phase.r
        }

        return self.phase.rawValue < phase.rawValue ? 0 : 1
    }
}
