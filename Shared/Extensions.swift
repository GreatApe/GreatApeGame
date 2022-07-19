//
//  Extensions.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import Foundation
import CoreGraphics

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

extension Double {
    func clamped(between lower: Double, and upper: Double) -> Double {
        min(max(lower, self), upper)
    }

    var unitClamped: Double {
        clamped(between: 0, and: 1)
    }
}

extension Double {
    var sigmoid: Double {
        0.5 - 0.5 * cos(.pi * self)
    }

    var sigmoid2: Double {
        let s = sigmoid
        return s * s
    }
}

extension Collection {
    public func min<C: Comparable>(by keyPath: KeyPath<Element, C>)  -> Element? {
        self.min { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}

extension Array where Element: Equatable {
    mutating public func remove(_ element: Element) {
        removeAll { $0 == element }
    }
}

extension Array {
    public func shifted(by distance: Int = 1) -> Self {
        let dist = ((distance % count) + count) % count
        return dropFirst(dist) + Array(prefix(dist))
    }
}

