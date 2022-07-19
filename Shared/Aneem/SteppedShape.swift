//
//  SteppedShape.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

struct SteppedShape<Step: StepEnum>: Shape {
    private var r: Double
    private var step: Step
    private var makePath: (Steps<Step>, CGRect) -> Path

    var animatableData: Double {
        set { r = newValue }
        get { r }
    }

    init(step: Step, path makePath: @escaping (Steps<Step>, CGRect) -> Path) {
        self.r = step.r
        self.step = step
        self.makePath = makePath
    }

    func path(in rect: CGRect) -> Path {
        makePath(.init(r: r, currentStep: step), rect)
    }
}

struct SteppedUnitShape<Step: StepEnum>: Shape {
    private var r: Double
    private var step: Step
    private var points: (Steps<Step>) -> [Path.Points]

    var animatableData: Double {
        set { r = newValue }
        get { r }
    }

    init(step: Step, points: @escaping (Steps<Step>) -> [Path.Points]) {
        self.r = step.r
        self.step = step
        self.points = points
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.add(points(.init(r: r, currentStep: step)), in: rect)
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

protocol StepEnum: Startable, CaseIterable, Comparable, RawRepresentable where RawValue == Int { }

protocol Startable {
    static var start: Self { get }
}

extension Int: Startable {
    static let start: Int = 0
}

extension StepEnum {
    var r: Double {
        Double(rawValue)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct Steps<Step: StepEnum> {
    let r: Double
    let currentStep: Step

    subscript(step: Step) -> Double {
        if step == currentStep {
            return 1 + r - step.r
        }

        return step > currentStep ? 0 : 1
    }
}
