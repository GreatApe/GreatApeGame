//
//  Constants.swift
//  GreatApeGame
//
//  Created by Gustaf Kugelberg on 12/08/2022.
//

import CoreGraphics
import SwiftUI

struct Constants {
    static let rows: Int = 7
    static let columns: Int = 10
    static let margin: CGFloat = 0.14
    static let controlSize: CGFloat = 0.14
    static let startLevel: Int = 2
    static let startTime: Double = 1
    static let timeDeltaSuccess: Double = 0.05
    static let timeDeltaEasier: Double = 0.05
    static let timeDeltaEasierStill: Double = 0.1

    let boardSize: CGSize
    let scaleFactor: CGFloat
    let horizontalPadding: CGFloat

    init(ipad: Bool) {
        if ipad {
            self.boardSize = .init(width: 0.84, height: 0.77)
            self.scaleFactor = 1
            self.horizontalPadding = -0.2
        } else {
            self.boardSize = .init(width: 0.75, height: 0.9)
            self.scaleFactor = 1.22
            self.horizontalPadding = 0
        }
    }
}

struct ConstantsKey: EnvironmentKey {
    static let defaultValue: Constants = .init(ipad: false)
}

extension EnvironmentValues {
    var constants: Constants {
        get { self[ConstantsKey.self] }
        set { self[ConstantsKey.self] = newValue }
    }
}
