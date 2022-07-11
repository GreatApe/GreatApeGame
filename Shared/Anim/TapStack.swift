//
//  TapStack.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 10/07/2022.
//

import SwiftUI


struct TapStack<Tag: Hashable & Startable, Content: View>: View {
    @Environment(\.animDefaultRamp) private var defaultRamp
    @State private var phases: [AnyHashable: Anim.Phase] = [:]
    @State private var currentTag: Tag = .start
    private var tappable: Bool = false
    private var onFinish: () -> Void
    private let order: [Tag]
    private let ramps: [Tag: Anim.Ramp]
    private let content: (Tag) -> Content

    init<Order: Collection>(order: Order,
                            ramps: [Tag: Anim.Ramp] = [:],
                            onFinish: @escaping () -> Void = { },
                            @ViewBuilder content: @escaping (Tag) -> Content) where Order.Element == Tag {
        self.onFinish = onFinish
        self.order = Array(order)
        self.ramps = ramps
        self.content = content
    }

    var body: some View {
        let rampTimes = order.map { ($0, ramps[$0] ?? defaultRamp) }
        ZStack {
            TapView(perform: nextTag)
            content(currentTag)
                .allowsHitTesting(tappable)
                .environment(\.animPhases, phases)
        }
        .environment(\.animRamps, .init(rampTimes) { $1 })
        .onAppear(perform: setupTags)
    }

    func tappable(active: Bool = true) -> Self {
        var result = self
        result.tappable = tappable
        return result
    }

    func defaultRamp(_ ramp: Anim.Ramp) -> some View {
        self.environment(\.animDefaultRamp, ramp)
    }

    private func setupTags() {
        let first = order.first ?? .start
        currentTag = first
        phases = .init(order.map { (.init($0), $0 == first ? .during : .before) }) { $1 }

        logTags() // FIXME: remove
    }

    private func nextTag() {
        defer { logTags() } // FIXME: remove
        phases[currentTag] = .after
        let current = order.firstIndex(of: currentTag) ?? 0
        guard order.indices.contains(current + 1) else {
            let delay = (ramps[currentTag] ?? defaultRamp).rampOut
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                onFinish()
            }

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
    init(stepped: Tag.Type,
         ramps: [Tag: Anim.Ramp] = [:],
         onFinish: @escaping () -> Void = { },
         @ViewBuilder content: @escaping (Tag) -> Content) {
        self.order = Array(Tag.allCases)
        self.ramps = ramps
        self.onFinish = onFinish
        self.content = content
    }
}
