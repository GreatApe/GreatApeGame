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
    @State private var currentTag: Tag? = nil
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
        ZStack {
            TapView(perform: nextTag)
            content(currentTag ?? .start)
                .allowsHitTesting(tappable)
                .environment(\.animPhases, phases)
        }
        .environment(\.animRamps, rampTimes())
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

    private func rampTimes() -> [Tag: Anim.Ramp] {
        let rampTimes = order.map { ramps[$0] ?? defaultRamp }

        var result: [Tag: Anim.Ramp] = [:]
        for (index, tag) in order.enumerated() {
            let delay = rampTimes.indices.contains(index - 1) ? rampTimes[index - 1].rampOut : 0
            result[tag] = rampTimes[index]//.delayRampIn(by: delay)
        }

        for tag in order {
            if let ramp = result[tag] {
                print("TAG: \(tag): \(ramp.rampIn) - \(ramp.rampOut) - D:\(ramp.rampInDelay)")
            }
        }

        return result
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
