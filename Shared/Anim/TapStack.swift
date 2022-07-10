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
    private var finished: () -> Void = { }
    private let tappable: Bool
    private let order: [TagType]
    private let content: (TagType) -> Content

    init(order: [TagType], tappable: Bool = false, @ViewBuilder content: @escaping (TagType) -> Content) {
        self.tappable = tappable
        self.order = order
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

    func onFinish(perform finished: @escaping () -> Void) -> Self {
        var result = self
        result.finished = finished
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
            finished()
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

extension TapStack where TagType == Int {
    init(count: Int = 10, tappable: Bool = false, @ViewBuilder content: @escaping (Int) -> Content) {
        self.tappable = tappable
        self.order = Array(0..<count)
        self.content = content
    }
}

extension TapStack where TagType: PhaseEnum {
    init(phased: TagType.Type, tappable: Bool = false, @ViewBuilder content: @escaping (TagType) -> Content) {
        self.tappable = tappable
        self.order = Array(TagType.allCases)
        self.content = content
    }
}
