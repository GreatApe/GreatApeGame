//
//  GeometryExtensions.swift
//  GreatApeTest
//
//  Created by Gustaf Kugelberg on 23/02/2022.
//

import CoreGraphics
import SwiftUI

extension CGPoint {
    static let one: CGPoint = .init(x: 1, y: 1)

    static func random(in rect: CGRect) -> CGPoint {
        .init(x: .random(in: rect.minX...rect.maxX), y: .random(in: rect.minY...rect.maxY))
    }

    func dist(to point: CGPoint) -> CGFloat {
        sqrt(pow(point.x - x, 2) + pow(point.y - y, 2))
    }

    static func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        .init(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    static func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    var asSize: CGSize {
        .init(width: x, height: y)
    }
}

extension CGSize {
    static let one: CGSize = .init(width: 1, height: 1)

    static func *(lhs: UnitPoint, rhs: CGSize) -> CGPoint {
        .init(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
    }

    static func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
        .init(width: lhs * rhs.width, height: lhs * rhs.height)
    }

    static func *(lhs: CGSize, rhs: CGSize) -> CGSize {
        .init(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }

    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    var largerSide: CGFloat {
        max(width, height)
    }

    var smallerSide: CGFloat {
        min(width, height)
    }

    var asPoint: CGPoint {
        .init(x: width, y: height)
    }
}

extension CGRect {
    subscript(unitPoint: UnitPoint) -> CGPoint {
        origin + unitPoint * size
    }
}

extension UnitPoint {
    static func *(lhs: CGFloat, rhs: UnitPoint) -> UnitPoint {
        .init(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    static func +(lhs: UnitPoint, rhs: UnitPoint) -> UnitPoint {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: UnitPoint, rhs: UnitPoint) -> UnitPoint {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

//extension Path.Points {
//    private static func apply(f: (UnitPoint) -> UnitPoint) -> Self {
//        let ff: Self = .start(.top)
//        
//    }
//
//    static func *(lhs: CGFloat, rhs: Path.Points) -> UnitPoint {
//        .init(x: lhs * rhs.x, y: lhs * rhs.y)
//    }
//
//    static func +(lhs: UnitPoint, rhs: UnitPoint) -> UnitPoint {
//        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
//    }
//
//    static func -(lhs: UnitPoint, rhs: UnitPoint) -> UnitPoint {
//        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
//    }
//}
