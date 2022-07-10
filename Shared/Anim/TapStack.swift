//
//  TapStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI

struct TapStack<TagType: Hashable & Startable, Content: View>: View {
    @State private var phases: [AnyHashable: Anim.Phase] = [:]
    @State private var currentTag: TagType? = nil
    private var tappable: Bool = false
    private var onFinish: () -> Void
    private let order: [TagType]
    private let content: (TagType) -> Content

    init<Order: Collection>(order: Order, onFinish: @escaping () -> Void = { }, @ViewBuilder content: @escaping (TagType) -> Content) where Order.Element == TagType {
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
        phases = .init(uniqueKeysWithValues: order.map { (.init($0), $0 == first ? .showing : .before) })

        logTags()
    }

    private func nextTag() {
        defer { logTags() }
        phases[currentTag] = .after
        let current = currentTag.flatMap(order.firstIndex) ?? 0
        guard order.indices.contains(current + 1) else {
            onFinish()
            currentTag = nil
            return
        }

        currentTag = order[current + 1]
        phases[currentTag] = .showing
    }

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

extension TapStack where TagType: PhaseEnum {
    init(phased: TagType.Type, onFinish: @escaping () -> Void = { }, @ViewBuilder content: @escaping (TagType) -> Content) {
        self.order = Array(TagType.allCases)
        self.onFinish = onFinish
        self.content = content
    }
}
