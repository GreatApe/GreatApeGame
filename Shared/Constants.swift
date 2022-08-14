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

    static let idiom: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom

    static let idiomatic: Idiomatic = .init(ipad: idiom == .pad)

    struct Idiomatic {
        private let ipad: Bool
        let boardSize: CGSize
        let scaleFactor: CGFloat
        let horizontalPadding: CGFloat

        func fontName(for style: TextStyle) -> String {
            switch style {
                case .smallText, .largeText, .menu, .link, .linkHeader, .title:
                    return "AmericanTypeWriter"
                case .boxes, .logo, .ad:
                    return "Futura Medium"
            }
        }

        func fontSize(for style: TextStyle) -> Double {
            switch style {
                case .smallText, .boxes:
                    return ipad ? 50 : 30
                case .largeText:
                    return ipad ? 60 : 50
                case .menu:
                    return ipad ? 60 : 40
                case .logo:
                    return 61
                case .title:
                    return 150
                case .linkHeader, .link:
                    return ipad ? 45 : 35
                case .ad:
                    return ipad ? 35 : 25
            }
        }

        init(ipad: Bool) {
            self.ipad = ipad
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
}
