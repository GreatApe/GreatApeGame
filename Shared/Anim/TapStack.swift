//
//  TapStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI


struct TapStack<Tag: Hashable & Startable, Content: View>: View {
    @State private var phases: [AnyHashable: Anim.Phase] = [:]
    @State private var currentTag: Tag? = nil
    private var tappable: Bool = false
    private var onFinish: () -> Void
    private let order: [Tag]
    private let content: (Tag) -> Content

    init<Order: Collection>(order: Order, onFinish: @escaping () -> Void = { }, @ViewBuilder content: @escaping (Tag) -> Content) where Order.Element == Tag {
        self.onFinish = onFinish
        self.order = Array(order)
        self.content = content
    }

    var body: some View {
        ZStack {
            TapView(perform: nextTag)
            content(currentTag ?? .start)
                .allowsHitTesting(tappable)
                .environment(\.animPhases, phases)
        }
        .onAppear(perform: setupTags)
    }

    func tappable(active: Bool = true) -> some View {
        var result = self
        result.tappable = tappable
        return result
    }

    private func setupTags() {
        let first = order.first ?? .start
        currentTag = first
        phases = .init(uniqueKeysWithValues: order.map { (.init($0), $0 == first ? .during : .before) })

        logTags() // FIXME: remove
    }

    private func nextTag() {
        defer { logTags() } // FIXME: remove
        phases[currentTag] = .after
        let current = currentTag.flatMap(order.firstIndex) ?? 0
        guard order.indices.contains(current + 1) else {
            onFinish()
            currentTag = nil
            return
        }

        currentTag = order[current + 1]
        phases[currentTag] = .during
    }

    // FIXME: remove
    private func logTags() {
        print("-- \(currentTag) --")
        phases.compactMap { tag, phase -> (tag: Int, phase: Anim.Phase)? in
            guard let intTag = tag.base as? Int else { return nil }
            return (intTag, phase)
        }
        .sorted { $0.tag < $1.tag }
        .forEach { print("\($0.tag): \($0.phase)") }
    }
}

extension TapStack where Tag: StepEnum {
    init(stepped: Tag.Type, onFinish: @escaping () -> Void = { }, @ViewBuilder content: @escaping (Tag) -> Content) {
        self.order = Array(Tag.allCases)
        self.onFinish = onFinish
        self.content = content
    }
}
