//
//  TimedShape.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI

struct TimedShape: Shape {
    private var r: Double
    private var makePath: (Double, CGRect) -> Path

    var animatableData: Double {
        set { r = newValue }
        get { r }
    }

    init(r: Double, path makePath: @escaping (Double, CGRect) -> Path) {
        self.r = r
        self.makePath = makePath
    }

    func path(in rect: CGRect) -> Path {
        makePath(r, rect)
    }
}

struct TimedUnitShape: Shape {
    private var r: Double
    private var points: (Double) -> [Path.Points]

    var animatableData: Double {
        set { r = newValue }
        get { r }
    }

    init(r: Double, points: @escaping (Double) -> [Path.Points]) {
        self.r = r
        self.points = points
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.add(points(r), in: rect)
        }
    }
}
